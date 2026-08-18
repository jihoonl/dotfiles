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
