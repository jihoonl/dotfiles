#!/usr/bin/env bash

set -Eeuo pipefail

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly NVIM_VENV="${HOME}/.local/share/nvim/venv"

log() {
  printf '\n==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

backup_and_link() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname -- "${target_path}")"

  if [[ -L "${target_path}" && "$(readlink "${target_path}")" == "${source_path}" ]]; then
    printf 'already linked: %s\n' "${target_path}"
    return
  fi

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    mkdir -p "${BACKUP_DIR}$(dirname -- "${target_path}")"
    mv -- "${target_path}" "${BACKUP_DIR}${target_path}"
    printf 'backed up: %s -> %s\n' "${target_path}" "${BACKUP_DIR}${target_path}"
  fi

  ln -s "${source_path}" "${target_path}"
  printf 'linked: %s -> %s\n' "${target_path}" "${source_path}"
}

[[ "$(uname -s)" == "Darwin" ]] || die "this installer only supports macOS"

# Homebrew is not always on PATH in a fresh GUI terminal such as cmux.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "${SKIP_BREW_INSTALL:-0}" == "1" ]]; then
    die "Homebrew is required (SKIP_BREW_INSTALL=1 was set)"
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if [[ "${SKIP_PACKAGES:-0}" != "1" ]]; then
  log "Installing command-line tools"
  brew update
  brew install \
    clang-format \
    cmake \
    git \
    neovim \
    python \
    the_silver_searcher \
    tmux

  log "Installing a Nerd Font"
  brew install --cask font-meslo-lg-nerd-font

  if [[ ! -d /Applications/cmux.app && ! -d "${HOME}/Applications/cmux.app" ]]; then
    log "Installing cmux"
    brew tap manaflow-ai/cmux
    brew install --cask cmux
  else
    printf 'already installed: cmux\n'
  fi
fi

log "Linking dotfiles"
backup_and_link "${DOTFILES_DIR}/nvim" "${HOME}/.config/nvim"
backup_and_link "${DOTFILES_DIR}/tmux.conf" "${HOME}/.tmux.conf"
backup_and_link "${DOTFILES_DIR}/gitconfig" "${HOME}/.gitconfig"
backup_and_link "${DOTFILES_DIR}/isort.cfg" "${HOME}/.isort.cfg"
backup_and_link "${DOTFILES_DIR}/mypy/config" "${HOME}/.config/mypy/config"
backup_and_link "${DOTFILES_DIR}/ghostty/config" "${HOME}/.config/ghostty/config"
backup_and_link "${DOTFILES_DIR}/cmux/cmux.json" "${HOME}/.config/cmux/cmux.json"
backup_and_link "${DOTFILES_DIR}/zshrc" "${HOME}/.zshrc"
backup_and_link "${DOTFILES_DIR}/zprofile" "${HOME}/.zprofile"

if [[ "${SKIP_PYTHON_TOOLS:-0}" != "1" ]]; then
  log "Installing Python tools in an isolated Neovim environment"
  python3 -m venv "${NVIM_VENV}"
  "${NVIM_VENV}/bin/python" -m pip install --upgrade pip
  "${NVIM_VENV}/bin/python" -m pip install \
    black \
    flake8 \
    imgcat \
    isort \
    mypy \
    pynvim \
    pylint \
    tqdm \
    yapf

  mkdir -p "${HOME}/.local/bin"
  for tool in black blackd flake8 imgcat isort mypy mypyc pylint pyreverse symilar tqdm yapf yapf-diff; do
    if [[ -x "${NVIM_VENV}/bin/${tool}" ]]; then
      ln -sfn "${NVIM_VENV}/bin/${tool}" "${HOME}/.local/bin/${tool}"
    fi
  done

  printf '\nAdd this line to your shell profile if ~/.local/bin is not on PATH:\n'
  printf '  export PATH="$HOME/.local/bin:$PATH"\n'
fi

if [[ "${SKIP_PLUGINS:-0}" != "1" ]]; then
  log "Installing Neovim plugins"
  nvim --headless "+PlugInstall --sync" "+UpdateRemotePlugins" +qa
fi

log "Done"
printf 'Dotfiles directory: %s\n' "${DOTFILES_DIR}"
if [[ -d "${BACKUP_DIR}" ]]; then
  printf 'Backups: %s\n' "${BACKUP_DIR}"
fi
