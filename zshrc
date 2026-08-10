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
