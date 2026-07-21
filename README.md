# dotfiles

Personal dotfiles for macOS — zsh, tmux, and a Linear-ticket-driven development
workflow built on git worktrees.

## What's here

| File | What it is |
|------|------------|
| `ticket.sh` | The centerpiece: one git worktree + tmux session + Claude agent per Linear ticket, with a floating dashboard. **See [docs/ticket.md](docs/ticket.md).** |
| `.zshrc` | zsh config; sources `ticket.sh` at the bottom |
| `.tmux.conf` | tmux binds, status line, and the `prefix + s` dashboard popup |
| `bin/` | the `ticket-*` helper scripts the dashboard and status line call |

## ticket.sh

Paste a Linear branch name and get a ready-to-work environment — an isolated
worktree, a dedicated tmux session, a Claude agent primed with the ticket's
context, and a dev server on its own port — then jump between all your in-flight
tickets from one floating dashboard (`prefix + s`).

[![The ticket dashboard](docs/ticket-dashboard.png)](docs/ticket.md)

**→ Full guide: [docs/ticket.md](docs/ticket.md)** — features, setup, the
dashboard key reference, file layout, and troubleshooting.

```sh
ticket kad/de-20-fix-login   # create/switch to a ticket's worktree + session
tickets                      # list active worktrees
unticket de-20               # remove the worktree + kill the session (branch kept)
```

## Setup

Add to `~/.zshrc` (config vars go **above** this line — see the guide):

```sh
source ~/dotfiles/ticket.sh
```

Dependencies: `tmux`, `fzf`, `jq`, `gh`, `pnpm`, `nvim`, and the `claude` CLI.
Keep `LINEAR_API_KEY` in `~/.zshenv` (not the tracked `.zshrc`). Full details in
[docs/ticket.md](docs/ticket.md#setup).
