# ticket.sh — Linear-ticket-driven git worktrees + a tmux SESSION per ticket
#
# Install: save this file, then add to ~/.zshrc:   source ~/dotfiles/ticket.sh
#          open a new shell (or: source ~/.zshrc)
#
# Usage (run from anywhere inside your repo, or from anywhere with --fe / --be):
#   ticket <linear-branch-name>            # uses the current repo
#   ticket --fe kad/eng-123-fix-login      # forces TICKET_FE_REPO (works from any dir)
#   ticket --be kad/eng-123-fix-login      # forces TICKET_BE_REPO (works from any dir)
#   tickets [--fe|--be]                    # list active worktrees
#   unticket [--fe|--be] eng-123           # kill the session + remove the worktree (branch is kept)
#
# Each `ticket` creates a git worktree and a dedicated tmux SESSION named after the
# ticket, with three windows:
#   claude : the agent, running in the worktree
#   nvim   : your editor, opened in the worktree
#   cli    : scratch shell (left) + dev server (top-right) + scratch shell (bottom-right)
# Switch windows with prefix n/p; switch tickets (sessions) with prefix s, sesh, or tms.

# Make dotfiles/bin scripts available (ticket-linear-fetch, ticket-dashboard, ...)
case ":$PATH:" in
  *":$HOME/dotfiles/bin:"*) ;;
  *) export PATH="$HOME/dotfiles/bin:$PATH" ;;
esac

# ----------------------------- config (edit these) -----------------------------
: "${TICKET_WT_ROOT:=$HOME/worktrees}"   # worktrees live here, grouped per repo
: "${TICKET_PORT_BASE:=5000}"            # dev port = base + (issue number mod 1000)
: "${TICKET_AGENT_CMD:=claude}"          # command for the claude window
: "${TICKET_EDITOR_CMD:=nvim}"           # command for the nvim window (leave blank for a plain shell)
: "${TICKET_BASE_BRANCH:=master}"        # new branches are forked from this branch
# Optional repo paths so `ticket --fe` / `ticket --be` work from any directory.
# Point these at the MAIN clone of each repo (not a worktree).
: "${TICKET_FE_REPO:=$HOME/Desktop/code/cord-frontend}"
: "${TICKET_BE_REPO:=$HOME/Desktop/code/cord-backend}"
# Dev server command; __PORT__ is replaced with the computed port. Match your framework:
#   Vite:     pnpm dev --port __PORT__
#   Next.js:  pnpm dev -- -p __PORT__
: "${TICKET_DEV_CMD:=pnpm dev --port __PORT__}"
# -------------------------------------------------------------------------------

_ticket_main_repo() {
  local common
  common="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  ( cd "$(dirname "$common")" && pwd )
}

# Resolve a repo path from an optional --fe/--be flag (first arg).
# Prints "<repo-path> <shift-count>": 1 if a flag was consumed, 0 otherwise.
# Falls back to the current repo (via _ticket_main_repo) when no flag is given.
_ticket_resolve_repo() {
  local flag="$1" path=""
  case "$flag" in
    --fe)
      [ -n "$TICKET_FE_REPO" ] || { echo "ticket: TICKET_FE_REPO is not set" >&2; return 1; }
      [ -d "$TICKET_FE_REPO/.git" ] || [ -f "$TICKET_FE_REPO/.git" ] \
        || { echo "ticket: '$TICKET_FE_REPO' is not a git repo" >&2; return 1; }
      printf '%s 1\n' "$TICKET_FE_REPO"; return 0 ;;
    --be)
      [ -n "$TICKET_BE_REPO" ] || { echo "ticket: TICKET_BE_REPO is not set" >&2; return 1; }
      [ -d "$TICKET_BE_REPO/.git" ] || [ -f "$TICKET_BE_REPO/.git" ] \
        || { echo "ticket: '$TICKET_BE_REPO' is not a git repo" >&2; return 1; }
      printf '%s 1\n' "$TICKET_BE_REPO"; return 0 ;;
    *)
      path="$(_ticket_main_repo)" || return 1
      printf '%s 0\n' "$path"; return 0 ;;
  esac
}

_ticket_id() {
  echo "$1" | grep -oiE '[a-z]+-[0-9]+' | head -1 | tr '[:upper:]' '[:lower:]'
}

# Resolve a command's first word to an absolute path using the CURRENT shell's PATH,
# so the spawned tmux pane doesn't depend on nvm/rc having loaded yet.
_ticket_abs() {
  local cmd="$1" first rest bin
  [ -z "$cmd" ] && return 0
  first="${cmd%% *}"
  if [ "$first" = "$cmd" ]; then rest=""; else rest=" ${cmd#* }"; fi
  bin="$(command -v "$first" 2>/dev/null)" || { printf '%s' "$cmd"; return 0; }
  printf '%s%s' "$bin" "$rest"
}

ticket() {
  local main repo id num port slug wt sess base
  local agent_cmd editor_cmd dev_cmd cw claude_win claude_pane nvim_pane left right_top right_bot
  local resolved shift_n branch

  resolved="$(_ticket_resolve_repo "$1")" || {
    case "$1" in --fe|--be) return 1 ;; esac
    echo "ticket: not inside a git repo (try: ticket --fe <branch> or ticket --be <branch>)"
    return 1
  }
  main="${resolved% *}"; shift_n="${resolved##* }"
  [ "$shift_n" = "1" ] && shift

  branch="$1"
  if [ -z "$branch" ]; then
    echo "usage: ticket [--fe|--be] <linear-branch-name>   (paste from Linear's 'Copy git branch name')"
    return 1
  fi

  repo="$(basename "$main")"

  id="$(_ticket_id "$branch")"
  if [ -n "$id" ]; then
    num="$(echo "$id" | grep -oE '[0-9]+')"
    slug="$id"
  else
    slug="$(echo "$branch" | tr '/ ' '--' | tr -cd 'A-Za-z0-9-')"
    num="$(echo "$branch" | cksum | cut -d' ' -f1)"
  fi
  port=$(( TICKET_PORT_BASE + (num % 1000) ))
  sess="$slug"
  wt="$TICKET_WT_ROOT/$repo/$slug"

  if tmux has-session -t "=$sess" 2>/dev/null; then
    echo "ticket: switching to existing session $sess"
    if [ -n "$TMUX" ]; then tmux switch-client -t "=$sess"; else tmux attach -t "=$sess"; fi
    return 0
  fi

  if [ ! -d "$wt" ]; then
    mkdir -p "$(dirname "$wt")"
    if git -C "$main" show-ref --verify --quiet "refs/heads/$branch"; then
      git -C "$main" worktree add "$wt" "$branch" || return 1
    else
      # Fetch the base branch so we fork from the latest origin tip, not a
      # potentially stale local ref. Best-effort: offline / no-remote is OK.
      echo "ticket: fetching origin/$TICKET_BASE_BRANCH ..."
      git -C "$main" fetch --quiet origin "$TICKET_BASE_BRANCH" 2>/dev/null || true

      # Prefer origin/<base> (just-fetched) over the local ref, so the new
      # worktree is always based on the latest remote master.
      if git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$TICKET_BASE_BRANCH"; then
        base="origin/$TICKET_BASE_BRANCH"
      elif git -C "$main" show-ref --verify --quiet "refs/heads/$TICKET_BASE_BRANCH"; then
        base="$TICKET_BASE_BRANCH"
      else
        echo "ticket: base branch '$TICKET_BASE_BRANCH' not found locally or on origin"
        return 1
      fi
      # --no-track: don't inherit origin/<base> as the upstream. Otherwise the new
      # branch tracks origin/master, and `git push` (push.default=simple) refuses
      # because the local branch name doesn't match the upstream branch name.
      git -C "$main" worktree add "$wt" -b "$branch" --no-track "$base" || return 1
    fi
  fi

  if [ ! -d "$wt/node_modules" ]; then
    echo "ticket: installing deps in $wt"
    ( cd "$wt" && pnpm install )
  fi

  # Fetch Linear context (best-effort). Writes metadata to the worktree's gitdir
  # and a human-readable .ticket-context.md into the worktree itself.
  local ticket_title="" ticket_url="" ticket_state="" gitdir meta_json
  if [ -n "$id" ] && command -v ticket-linear-fetch >/dev/null 2>&1 \
       && [ -n "${LINEAR_API_KEY:-}" ]; then
    if meta_json="$(ticket-linear-fetch "$id" 2>/dev/null)"; then
      gitdir="$(git -C "$wt" rev-parse --git-dir)"
      ticket_title="$(printf '%s' "$meta_json" | jq -r '.title // ""')"
      ticket_url="$(printf '%s' "$meta_json" | jq -r '.url // ""')"
      ticket_state="$(printf '%s' "$meta_json" | jq -r '.state // ""')"
      printf '%s' "$meta_json" | jq \
        --arg branch "$branch" --arg repo "$repo" --argjson port "$port" \
        --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '. + {branch: $branch, repo: $repo, port: $port, created_at: $created}' \
        > "$gitdir/ticket.json"
      {
        printf '# %s — %s\n\n' "$(printf '%s' "$meta_json" | jq -r '.identifier')" "$ticket_title"
        printf '- **Branch:** `%s`\n' "$branch"
        printf '- **State:** %s\n' "$ticket_state"
        printf '- **URL:** %s\n' "$ticket_url"
        printf '- **Dev port:** %s\n\n' "$port"
        printf '## Description\n\n%s\n' "$(printf '%s' "$meta_json" | jq -r '.description // "(no description)"')"
      } > "$wt/.ticket-context.md"
      # Ensure .ticket-context.md is locally ignored (per repo, not committed).
      local common; common="$(git -C "$wt" rev-parse --git-common-dir)"
      if ! grep -qxF '/.ticket-context.md' "$common/info/exclude" 2>/dev/null; then
        echo '/.ticket-context.md' >> "$common/info/exclude"
      fi
    fi
  fi

  # Resolve commands to absolute paths now, while the current shell has full PATH.
  agent_cmd="$(_ticket_abs "$TICKET_AGENT_CMD")"
  editor_cmd="$(_ticket_abs "$TICKET_EDITOR_CMD")"
  dev_cmd="${TICKET_DEV_CMD//__PORT__/$port}"
  dev_cmd="$(_ticket_abs "$dev_cmd")"

  # Build the session, capturing window/pane IDs at creation (immune to renames/base-index).
  cw="$(tmux new-session -d -P -F '#{window_id} #{pane_id}' -s "$sess" -c "$wt" -n claude)"
  claude_win="${cw%% *}"; claude_pane="${cw##* }"
  if [ -n "$agent_cmd" ]; then
    # If we wrote a ticket-context file, launch claude with an initial prompt
    # that tells it (via its Read tool) to load that file and summarize.
    # Going through the Read tool sidesteps the @-mention quirks with dotfiles
    # and locally-gitignored paths.
    if [ -f "$wt/.ticket-context.md" ]; then
      tmux send-keys -t "$claude_pane" \
        "$agent_cmd 'Use your Read tool to open .ticket-context.md in the cwd, then summarize the ticket in one line and wait for instructions.'" C-m
    else
      tmux send-keys -t "$claude_pane" "$agent_cmd" C-m
    fi
  fi

  cw="$(tmux new-window -P -F '#{window_id} #{pane_id}' -t "$sess:" -n nvim -c "$wt")"
  nvim_pane="${cw##* }"
  [ -n "$editor_cmd" ] && tmux send-keys -t "$nvim_pane" "$editor_cmd" C-m

  cw="$(tmux new-window -P -F '#{window_id} #{pane_id}' -t "$sess:" -n cli -c "$wt")"
  left="${cw##* }"
  right_top="$(tmux split-window -h -P -F '#{pane_id}' -t "$left" -c "$wt")"
  right_bot="$(tmux split-window -v -P -F '#{pane_id}' -t "$right_top" -c "$wt")"
  [ -n "$dev_cmd" ] && tmux send-keys -t "$right_top" "$dev_cmd" C-m
  tmux select-pane -t "$left"

  # Stash Linear context on the session so tmux status-line can render it.
  [ -n "$ticket_title" ] && tmux set-option -t "$sess" -q "@ticket_title" "$ticket_title"
  [ -n "$ticket_url"   ] && tmux set-option -t "$sess" -q "@ticket_url"   "$ticket_url"

  tmux select-window -t "$claude_win"   # land on the claude window
  if [ -n "$ticket_title" ]; then
    echo "ticket: $branch — $ticket_title  ->  $wt   (dev on http://localhost:$port)"
  else
    echo "ticket: $branch  ->  $wt   (dev on http://localhost:$port)"
  fi
  if [ -n "$TMUX" ]; then tmux switch-client -t "=$sess"; else tmux attach -t "=$sess"; fi
}

tickets() {
  local main resolved shift_n
  resolved="$(_ticket_resolve_repo "$1")" || {
    case "$1" in --fe|--be) return 1 ;; esac
    echo "not in a git repo (try: tickets --fe / tickets --be)"
    return 1
  }
  main="${resolved% *}"
  git -C "$main" worktree list
}

unticket() {
  local main repo id slug wt sess arg resolved shift_n
  resolved="$(_ticket_resolve_repo "$1")" || {
    case "$1" in --fe|--be) return 1 ;; esac
    echo "not in a git repo (try: unticket --fe <id> or unticket --be <id>)"
    return 1
  }
  main="${resolved% *}"; shift_n="${resolved##* }"
  [ "$shift_n" = "1" ] && shift

  arg="$1"
  [ -z "$arg" ] && { echo "usage: unticket [--fe|--be] <ticket-id-or-branch>"; return 1; }
  repo="$(basename "$main")"
  id="$(_ticket_id "$arg")"
  slug="${id:-$(echo "$arg" | tr '/ ' '--' | tr -cd 'A-Za-z0-9-')}"
  sess="$slug"
  wt="$TICKET_WT_ROOT/$repo/$slug"

  tmux kill-session -t "=$sess" 2>/dev/null
  if git -C "$main" worktree remove "$wt" 2>/dev/null; then
    echo "unticket: removed session $sess and worktree $wt"
  else
    echo "unticket: killed session $sess; worktree has uncommitted/unpushed work."
    echo "          force with: git -C \"$main\" worktree remove --force \"$wt\""
  fi
  echo "          (branch kept — delete with: git -C \"$main\" branch -D <branch>)"
}
