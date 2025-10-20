# ============================================================================
# ZSH Configuration
# ============================================================================
# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_VERIFY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Auto completion
autoload -U compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ============================================================================
# Aliases
# ============================================================================
# Git
alias g="git"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gbd="git branch -D"
alias gm="git merge"
alias gps="git push"
alias gpl="git pull"
alias gs="git status"
alias ga="git add"
alias gcm="git commit -m"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias q="exit"
alias gocode="cd /Users/kad/Desktop/code"
alias golan="cd /Users/kad/Desktop/code/cord-landing-page"

# tmux
alias t="tmux"
alias ta="tmux attach -t" # Attach to a session by name
alias tls="tmux list-sessions" # List all tmux sessions
alias tk="tmux kill-session -t" # Kill a session by name

# Get week number
alias week="date +%V"

alias zsh="source ~/.zshrc"

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# ============================================================================
# Environment
# ============================================================================
# Make sure Homebrew is in PATH (redundant with .zprofile but good to have)
export PATH=/opt/homebrew/bin:$PATH

# Editor
export EDITOR=nvim
export VISUAL=nvim

# ============================================================================
# Plugins
# ============================================================================
# Syntax highlighting (must be at the end)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bind arrow keys for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

. "$HOME/.local/bin/env"

source ~/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script
export PATH="/Users/kad/.nvm/versions/node/v22.17.0/bin:$PATH"
