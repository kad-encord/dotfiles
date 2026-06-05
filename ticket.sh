# ticket.sh — Linear-ticket-driven git worktrees + a tmux SESSION per ticket
#
# Install: save this file, then add to ~/.zshrc:   source ~/dotfiles/ticket.sh
#          open a new shell (or: source ~/.zshrc)
#
# Usage (run from anywhere inside your repo):
#   ticket <linear-branch-name>   # e.g. ticket kad/eng-123-fix-login  (Linear's "Copy git branch name")
#   tickets                       # list active worktrees
#   unticket eng-123              # kill the session + remove the worktree (branch is kept)
#
# Each `ticket` creates a git worktree and a dedicated tmux SESSION named after the
# ticket, with three windows:
#   claude : the agent, running in the worktree
#   nvim   : your editor, opened in the worktree
#   cli    : scratch shell (left) + dev server (top-right) + scratch shell (bottom-right)
# Switch windows with prefix n/p; switch tickets (sessions) with prefix s, sesh, or tms.

# ----------------------------- config (edit these) -----------------------------
: "${TICKET_WT_ROOT:=$HOME/worktrees}"   # worktrees live here, grouped per repo
: "${TICKET_PORT_BASE:=5000}"            # dev port = base + (issue number mod 1000)
: "${TICKET_AGENT_CMD:=claude}"          # command for the claude window
: "${TICKET_EDITOR_CMD:=nvim}"           # command for the nvim window (leave blank for a plain shell)
: "${TICKET_BASE_BRANCH:=master}"        # new branches are forked from this branch
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
  local branch="$1"
  if [ -z "$branch" ]; then
    echo "usage: ticket <linear-branch-name>   (paste from Linear's 'Copy git branch name')"
    return 1
  fi

  local main repo id num port slug wt sess base
  local agent_cmd editor_cmd dev_cmd cw claude_win claude_pane nvim_pane left right_top right_bot
  main="$(_ticket_main_repo)" || { echo "ticket: not inside a git repo"; return 1; }
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
      # Pick the best available base ref: local TICKET_BASE_BRANCH, then origin/<base>.
      if git -C "$main" show-ref --verify --quiet "refs/heads/$TICKET_BASE_BRANCH"; then
        base="$TICKET_BASE_BRANCH"
      elif git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$TICKET_BASE_BRANCH"; then
        base="origin/$TICKET_BASE_BRANCH"
      else
        echo "ticket: base branch '$TICKET_BASE_BRANCH' not found locally or on origin"
        return 1
      fi
      git -C "$main" worktree add "$wt" -b "$branch" "$base" || return 1
    fi
  fi

  if [ ! -d "$wt/node_modules" ]; then
    echo "ticket: installing deps in $wt"
    ( cd "$wt" && pnpm install )
  fi

  # Resolve commands to absolute paths now, while the current shell has full PATH.
  agent_cmd="$(_ticket_abs "$TICKET_AGENT_CMD")"
  editor_cmd="$(_ticket_abs "$TICKET_EDITOR_CMD")"
  dev_cmd="${TICKET_DEV_CMD//__PORT__/$port}"
  dev_cmd="$(_ticket_abs "$dev_cmd")"

  # Build the session, capturing window/pane IDs at creation (immune to renames/base-index).
  cw="$(tmux new-session -d -P -F '#{window_id} #{pane_id}' -s "$sess" -c "$wt" -n claude)"
  claude_win="${cw%% *}"; claude_pane="${cw##* }"
  [ -n "$agent_cmd" ] && tmux send-keys -t "$claude_pane" "$agent_cmd" C-m

  cw="$(tmux new-window -P -F '#{window_id} #{pane_id}' -t "$sess:" -n nvim -c "$wt")"
  nvim_pane="${cw##* }"
  [ -n "$editor_cmd" ] && tmux send-keys -t "$nvim_pane" "$editor_cmd" C-m

  cw="$(tmux new-window -P -F '#{window_id} #{pane_id}' -t "$sess:" -n cli -c "$wt")"
  left="${cw##* }"
  right_top="$(tmux split-window -h -P -F '#{pane_id}' -t "$left" -c "$wt")"
  right_bot="$(tmux split-window -v -P -F '#{pane_id}' -t "$right_top" -c "$wt")"
  [ -n "$dev_cmd" ] && tmux send-keys -t "$right_top" "$dev_cmd" C-m
  tmux select-pane -t "$left"

  tmux select-window -t "$claude_win"   # land on the claude window
  echo "ticket: $branch  ->  $wt   (dev on http://localhost:$port)"
  if [ -n "$TMUX" ]; then tmux switch-client -t "=$sess"; else tmux attach -t "=$sess"; fi
}

tickets() {
  local main; main="$(_ticket_main_repo)" || { echo "not in a git repo"; return 1; }
  git -C "$main" worktree list
}

unticket() {
  local arg="$1" main repo id slug wt sess
  [ -z "$arg" ] && { echo "usage: unticket <ticket-id-or-branch>"; return 1; }
  main="$(_ticket_main_repo)" || { echo "not in a git repo"; return 1; }
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
