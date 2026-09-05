# Ubuntu-style one-line prompt: user@host:directory$
autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Enable file-type colors for the macOS BSD ls command. The first pair is the
# directory color and the second is the symlink one; they were both bold cyan,
# which made the two indistinguishable. Bold blue and bold cyan match what GNU
# ls does on Ubuntu (di=01;34, ln=01;36).
export CLICOLOR=1
export LSCOLORS="ExGxCxDxCxegedabagaced"
alias ls='ls -G'
alias l='ls -lahG'
alias ll='ls -alG'

# Use Neovim for the traditional vi and vim commands.
alias vi='nvim'
alias vim='nvim'

# Enable the completion system (git, brew, etc. ship their own completions).
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
eval "$(hdayctl completion zsh)"
export PATH="/Users/jihoonl/.devcontainers/bin:$PATH"

# Attach to a remote herdr in a standalone Ghostty window. cmux cannot host it:
# it owns every Cmd chord and leaves herdr on legacy key encoding, so the Cmd
# bindings in herdr/config.toml only work here. ghostty/herdr.conf releases the
# Cmd chords Ghostty binds itself. Detach with Ctrl-B q; Cmd-Q quits Ghostty.
# Extra arguments go to herdr, so --session works.
herdr-remote() {
  open -na Ghostty.app --args \
    --config-file="${HOME}/.config/ghostty/herdr.conf" \
    -e herdr --remote "$@"
}

herdr-holiday-desktop() {
  herdr-remote holiday-desktop "$@"
}

# Node via nvm. install.sh also symlinks node/npm/npx into ~/.local/bin so that
# non-interactive consumers (Claude Code plugin hooks, MCP servers) find them
# without sourcing this file; loading nvm here is for `nvm install` and friends.
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"
