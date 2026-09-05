# Ubuntu-style one-line prompt: user@host:directory$
autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Enable file-type colors for the macOS BSD ls command.
export CLICOLOR=1
export LSCOLORS="GxGxCxDxCxegedabagaced"
alias ls='ls -G'
alias l='ls -lahG'
alias ll='ls -lhG'

# Use Neovim for the traditional vi and vim commands.
alias vi='nvim'
alias vim='nvim'

# Enable the completion system (git, brew, etc. ship their own completions).
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
eval "$(hdayctl completion zsh)"
export PATH="/Users/jihoonl/.devcontainers/bin:$PATH"

# herdr in a standalone Ghostty window. cmux keeps ⌘ for itself, so herdr only
# gets it here: ghostty/herdr.conf translates each ⌘ chord into herdr's prefix
# sequence. ⌘Q still quits Ghostty; detach with ⌃B q.
herdr-holiday-desktop() {
  open -na Ghostty.app --args \
    --config-file="${HOME}/.config/ghostty/herdr.conf" \
    -e herdr --remote holiday-desktop
}

# Node via nvm. install.sh also symlinks node/npm/npx into ~/.local/bin so that
# non-interactive consumers (Claude Code plugin hooks, MCP servers) find them
# without sourcing this file; loading nvm here is for `nvm install` and friends.
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"
