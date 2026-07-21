# dotfiles

Personal dotfiles. The centerpiece is **`ticket.sh`** — a Linear-ticket-driven
workflow that pairs a git worktree, a tmux session, and a Claude agent per
ticket, with a floating dashboard for navigating between them.

---

## `ticket.sh` — one ticket → one worktree → one tmux session

Drop a Linear-style branch name (`kad/de-20-fix-login`) and you get:

- a git worktree at `~/worktrees/<repo>/<slug>` on that branch (forked from
  `TICKET_BASE_BRANCH` if the branch is new)
- a tmux **session** named after the slug, with three windows:
  - **claude** — agent running in the worktree
  - **nvim** — editor in the worktree
  - **cli** — scratch shell (left) + dev server on a per-ticket port
    (top-right) + scratch shell (bottom-right)
- the Linear issue's **title + description** auto-fetched and saved to
  `<worktree>/.ticket-context.md` (so Claude has it in-context)
- the title stashed onto the tmux session so the **status bar** shows it next
  to the session name
- a **PR badge** in the status bar that watches `gh pr view` for the branch

### Quick start

```sh
ticket kad/de-20-fix-login        # uses the repo you're currently in
ticket --fe kad/de-20-fix-login   # forces TICKET_FE_REPO (works from anywhere)
ticket --be kad/de-20-fix-login   # forces TICKET_BE_REPO (works from anywhere)
tickets                           # list active worktrees in current repo
tickets --fe                      # ...or in fe / be
unticket de-20                    # kill the session, remove the worktree (branch kept)
unticket --fe de-20               # works from anywhere
```

---

## Setup

### Dependencies

| Tool   | Why                                            | Install                |
|--------|------------------------------------------------|------------------------|
| tmux   | sessions + popups                              | `brew install tmux`    |
| fzf    | dashboard + picker UI                          | `brew install fzf`     |
| jq     | parsing Linear + gh JSON                       | `brew install jq`      |
| gh     | PR-status badge                                | `brew install gh && gh auth login` |
| pnpm   | auto-`pnpm install` in fresh worktrees         | `brew install pnpm`    |
| nvim   | the editor window                              | `brew install neovim`  |
| claude | the agent window (Anthropic CLI)               | https://claude.com/code |
| curl   | Linear API requests                            | (built in)             |

### Config — set in `~/.zshrc` **before** `source ~/dotfiles/ticket.sh`

```sh
# repo paths so `ticket --fe` / `ticket --be` work from anywhere
export TICKET_FE_REPO="$HOME/Desktop/code/cord-frontend"   # default already correct
export TICKET_BE_REPO="$HOME/Desktop/code/cord-backend"    # default already correct

# optional overrides
export TICKET_WT_ROOT="$HOME/worktrees"                    # where worktrees live
export TICKET_PORT_BASE=5000                               # dev port = base + (issue # mod 1000)
export TICKET_BASE_BRANCH="master"                         # branches forked from this
export TICKET_AGENT_CMD="claude"                           # command for the claude window
export TICKET_EDITOR_CMD="nvim"                            # command for the nvim window
export TICKET_DEV_CMD="pnpm dev --port __PORT__"           # __PORT__ gets substituted
```

### Linear API key — keep it out of the dotfiles repo

The Linear context-fetch needs `LINEAR_API_KEY`. **Do not** put this in
`~/dotfiles/.zshrc` — that file is tracked in git. Put it in `~/.zshenv`
instead (auto-sourced by zsh, lives outside the repo):

```sh
# in ~/.zshenv  (create the file if it doesn't exist)
export LINEAR_API_KEY="lin_api_xxxxxxxx"
```

Get a key from **Linear → Settings → API → Personal API keys**. If
`LINEAR_API_KEY` is unset, ticket creation still works — the Linear fetch is
just silently skipped and the status bar / dashboard show `—` instead of a
title.

### Optional: GitHub PR badge

The status bar shows a PR badge per session if you have `gh` installed and
authenticated:

```sh
gh auth login
```

Without `gh`, the badge stays empty.

---

## Tmux integration

### Hotkey (with `C-a` prefix)

| Chord        | Action |
|--------------|--------|
| `prefix + s` | **Ticket dashboard** — floating popup with every worktree, its dev/git/PR status, and Linear title. Switches sessions, opens PRs, unticks worktrees, all from one place. |

Inside the dashboard, **navigation** (vim-style — search is off until you press `/`):

| Key            | Action |
|----------------|--------|
| `j` / `k`      | Down / up |
| `g` / `G`      | First / last row |
| `Ctrl-D` / `Ctrl-U` | Half-page down / up |
| `/`            | Enter search mode (typing filters; prompt changes to `/`) |
| `Esc`          | Exit search mode back to vim nav |
| `Ctrl-C` / `Ctrl-G` | Close popup |
| `Enter`        | Switch to the session (or create one if dormant) |

**Actions** (work in either mode):

| Key      | Action |
|----------|--------|
| `Ctrl-X` | `ticket-rm`: kill session + remove worktree |
| `Ctrl-O` | Open the Linear URL in your browser |
| `Ctrl-P` | Open the PR in your browser (`gh pr view --web`) |
| `Ctrl-E` | Open the worktree in `$EDITOR` |
| `Ctrl-B` | Copy the branch name to clipboard |
| `Ctrl-F` | Backfill Linear context for this worktree (if missing) |
| `Ctrl-R` | Force-refresh all PR badges |

The right pane shows the Linear title, state, description, recent commits, and
working-tree changes for whichever row is highlighted.

### Status line

- **left**: `<session-name> — <Linear title>` (title shown when
  `@ticket_title` is set on the session, which `ticket()` does automatically)
- **right**: PR badge for the current session + clock
  - `● #123 ✓` — open, all checks passing
  - `● #123 ✗` — open, a check failing
  - `● #123 …` — open, checks pending
  - `◆ #123`   — merged
  - `○ #123`   — closed (unmerged)
  - blank      — no PR / not a ticket session / `gh` failed

PR data is cached in `~/.cache/ticket/pr-<slug>.txt` for 60s. The status bar
refreshes every 10s but only hits `gh` when the cache is stale.

---

## File layout

```
~/dotfiles/
  ticket.sh                    sourced from .zshrc — defines ticket / tickets / unticket
  .tmux.conf                   binds + status-line wiring
  .zshrc                       sources ticket.sh at the bottom
  bin/
    ticket-linear-fetch        GraphQL fetch of one Linear issue
    ticket-dashboard           prefix+s popup (fzf-based)
    ticket-preview             right-pane renderer for the dashboard
    ticket-backfill            populate ticket.json/.ticket-context.md for an existing worktree
    ticket-open-linear         Ctrl-O helper: opens URL only if one is cached
    ticket-pr-badge            status-line PR badge w/ disk cache
    ticket-rm                  helper: kill session + remove worktree

~/worktrees/<repo>/<slug>/     the worktree itself
  .ticket-context.md           Linear title + description (gitignored locally)

<worktree>/.git/worktrees/<slug>/ticket.json
  per-ticket metadata: identifier, title, description, state, url,
  branch, repo, port, created_at

~/.cache/ticket/pr-<slug>.txt  cached PR badge per session
```

---

## Troubleshooting

**Dashboard shows `—` for titles even after I created a ticket.**
The Linear fetch needs `LINEAR_API_KEY`. The dashboard auto-sources
`~/.zshenv` on startup, so once the key is in that file the next popup will
have it. For existing worktrees, hit `Ctrl-F` on a row (or run
`ticket-backfill --all` from a shell) to populate `ticket.json` for all of
them.

**Ctrl-F in the dashboard says "no linear context cached" or just flashes.**
The backfill failed — probably because Linear couldn't be reached or your
key is invalid. Run `ticket-backfill <slug>` from a shell to see the actual
error. The dashboard auto-sources `~/.zshenv`, but if the tmux server was
started before you added the key, you can also push it into the running
server with `tmux setenv -g LINEAR_API_KEY "$LINEAR_API_KEY"`.

**Ctrl-O does nothing.**
The row has no cached Linear URL (yet). Press `Ctrl-F` first to backfill,
then `Ctrl-O` will open the issue in your browser.

**Two repos with the same ticket id collide.**
Sessions are named purely by slug. If you `ticket --fe kad/de-20` *and*
`ticket --be kad/de-20`, the second call just switches to the first session
because both want to be named `de-20`. Workarounds: only have one active at
a time, or hand-edit `ticket.sh` to use `sess="<repo_label>-$slug"` (will
orphan existing sessions).

**`ticket: base branch 'master' not found locally or on origin`.**
Your `TICKET_BASE_BRANCH` doesn't exist in the repo. Set it (e.g.
`export TICKET_BASE_BRANCH=main`) and re-run.

**Dev server pane shows `command not found`.**
The dev command resolves via `command -v` *at ticket creation time* — make
sure your shell has the right PATH when you call `ticket` (nvm, pnpm, bun
all need to be on PATH).

**PR badge always blank.**
Run `gh auth status` — if not logged in, run `gh auth login`. If you're on
a private repo, make sure the auth has access. The badge script swallows
errors silently so the status bar never breaks.

**I want the dashboard to pick up a new repo.**
The dashboard iterates `~/worktrees/*/*`. Any worktree there shows up.
Repo-label rendering (`fe`/`be`/`lp`/…) is keyed off the parent dir name —
edit `repo_label()` in `bin/ticket-dashboard` to add new short labels.
