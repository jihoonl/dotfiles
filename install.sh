#!/usr/bin/env bash

set -Eeuo pipefail

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly NVIM_VENV="${HOME}/.local/share/nvim/venv"
readonly OS="$(uname -s)"

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

setup_homebrew() {
  # Homebrew is not always on PATH in a fresh GUI terminal such as cmux.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 && return 0

  [[ "${SKIP_BREW_INSTALL:-0}" != "1" ]] || die "Homebrew is required (SKIP_BREW_INSTALL=1 was set)"

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_packages_macos() {
  log "Installing command-line tools"
  brew update
  brew install \
    clang-format \
    cmake \
    git \
    jq \
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
}

install_packages_linux() {
  if ! command -v nvim >/dev/null 2>&1; then
    log "Adding the Neovim PPA"
    sudo add-apt-repository ppa:neovim-ppa/stable -y
  fi

  log "Installing command-line tools"
  sudo apt update
  sudo apt install --yes \
    build-essential \
    clang-format \
    cmake \
    cmake-curses-gui \
    fonts-powerline \
    jq \
    neovim \
    python3-dev \
    python3-venv \
    silversearcher-ag \
    tmux \
    xsel
}

set_default_editor_linux() {
  log "Making Neovim the default editor"
  sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
}

link_dotfiles() {
  log "Linking dotfiles"
  backup_and_link "${DOTFILES_DIR}/nvim" "${HOME}/.config/nvim"
  backup_and_link "${DOTFILES_DIR}/tmux.conf" "${HOME}/.tmux.conf"
  backup_and_link "${DOTFILES_DIR}/gitconfig" "${HOME}/.gitconfig"
  backup_and_link "${DOTFILES_DIR}/agents/AGENTS.md" "${HOME}/.claude/CLAUDE.md"
  backup_and_link "${DOTFILES_DIR}/agents/CPP.md" "${HOME}/.claude/CPP.md"
  backup_and_link "${DOTFILES_DIR}/agents/AGENTS.md" "${HOME}/.codex/AGENTS.md"
  backup_and_link "${DOTFILES_DIR}/agents/CPP.md" "${HOME}/.codex/CPP.md"
  backup_and_link "${DOTFILES_DIR}/herdr/config.toml" "${HOME}/.config/herdr/config.toml"

  if [[ "${OS}" == "Darwin" ]]; then
    backup_and_link "${DOTFILES_DIR}/ghostty/config" "${HOME}/.config/ghostty/config"
    backup_and_link "${DOTFILES_DIR}/cmux/cmux.json" "${HOME}/.config/cmux/cmux.json"
    backup_and_link "${DOTFILES_DIR}/zshrc" "${HOME}/.zshrc"
    backup_and_link "${DOTFILES_DIR}/zprofile" "${HOME}/.zprofile"
  else
    backup_and_link "${DOTFILES_DIR}/terminator" "${HOME}/.config/terminator"
  fi
}

# Hook configs live inside larger machine-local files (~/.claude/settings.json,
# ~/.codex/hooks.json), so they are merged with jq instead of symlinked.
merge_hook_entry() {
  local target="$1"
  local fragment="$2"

  mkdir -p "$(dirname -- "${target}")"
  [[ -f "${target}" ]] || printf '{}\n' > "${target}"
  jq --slurpfile entry "${fragment}" \
    '.hooks.PreToolUse = ((.hooks.PreToolUse // []) | map(select(.matcher != $entry[0].matcher))) + [$entry[0]]' \
    "${target}" > "${target}.tmp"
  mv "${target}.tmp" "${target}"
  printf 'hook merged: %s\n' "${target}"
}

merge_agent_hooks() {
  log "Merging C++ guide hooks"
  merge_hook_entry "${HOME}/.claude/settings.json" "${DOTFILES_DIR}/agents/hooks/claude-cpp-guide.json"
  merge_hook_entry "${HOME}/.codex/hooks.json" "${DOTFILES_DIR}/agents/hooks/codex-cpp-guide.json"

  # Claude auto-memory lives in the llm-wiki repo so it follows the user across
  # machines (git) and projects (one shared directory).
  [[ -d "${HOME}/.wiki/personal-wiki" ]] || git clone git@github.com:jihoonl/llm-wiki.git "${HOME}/.wiki/personal-wiki"

  # Personal Claude skills are their own repo, checked out as ~/.claude/skills.
  [[ -d "${HOME}/.claude/skills" ]] || git clone git@github.com:jihoonl/personal-skills.git "${HOME}/.claude/skills"
  jq '.autoMemoryDirectory = "~/.wiki/personal-wiki/memory"' "${HOME}/.claude/settings.json" \
    > "${HOME}/.claude/settings.json.tmp"
  mv "${HOME}/.claude/settings.json.tmp" "${HOME}/.claude/settings.json"
}

install_claude() {
  if ! command -v claude >/dev/null 2>&1; then
    log "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  export PATH="${HOME}/.local/bin:${PATH}"
  command -v claude >/dev/null 2>&1 || die "claude is not on PATH after install"

  log "Installing Claude Code plugins"
  claude plugin marketplace add tobi/qmd
  claude plugin marketplace add DietrichGebert/ponytail
  local plugin
  for plugin in github@claude-plugins-official \
                claude-md-management@claude-plugins-official \
                security-guidance@claude-plugins-official \
                superpowers@claude-plugins-official \
                code-review@claude-plugins-official \
                commit-commands@claude-plugins-official \
                clangd-lsp@claude-plugins-official \
                chrome-devtools-mcp@claude-plugins-official \
                qmd@qmd \
                ponytail@ponytail; do
    claude plugin install -y "${plugin}"
  done
}

install_herdr() {
  if ! command -v herdr >/dev/null 2>&1; then
    log "Installing herdr"
    curl -fsSL https://herdr.dev/install.sh | sh
  fi
  export PATH="${HOME}/.local/bin:${PATH}"
  command -v herdr >/dev/null 2>&1 || die "herdr is not on PATH after install"

  # Lifecycle state detection for Claude panes, beyond screen scraping.
  log "Installing the herdr Claude Code integration"
  herdr integration install claude
}

# A venv keeps these off the system python, which Ubuntu refuses to touch
# (PEP 668) and Homebrew python only tolerates.
install_python_tools() {
  log "Installing Python tools in an isolated Neovim environment"
  python3 -m venv "${NVIM_VENV}"
  "${NVIM_VENV}/bin/python" -m pip install --upgrade pip
  "${NVIM_VENV}/bin/python" -m pip install \
    imgcat \
    pynvim \
    ruff \
    tqdm

  mkdir -p "${HOME}/.local/bin"
  local tool
  for tool in imgcat ruff tqdm; do
    if [[ -x "${NVIM_VENV}/bin/${tool}" ]]; then
      ln -sfn "${NVIM_VENV}/bin/${tool}" "${HOME}/.local/bin/${tool}"
    fi
  done

  printf '\nAdd this line to your shell profile if ~/.local/bin is not on PATH:\n'
  printf '  export PATH="$HOME/.local/bin:$PATH"\n'
}

install_nvim_plugins() {
  log "Installing Neovim plugins"
  # Local-checkout plugins such as ~/work/tandem are absent on a fresh machine,
  # which makes PlugInstall exit nonzero. That is not fatal here.
  nvim --headless "+PlugInstall --sync" +qa || log "PlugInstall reported errors, continuing"
}

case "${OS}" in
  Darwin)
    setup_homebrew
    [[ "${SKIP_PACKAGES:-0}" == "1" ]] || install_packages_macos
    ;;
  Linux)
    [[ "${SKIP_PACKAGES:-0}" == "1" ]] || install_packages_linux
    set_default_editor_linux
    ;;
  *)
    die "unsupported operating system: ${OS}"
    ;;
esac

link_dotfiles
merge_agent_hooks
install_claude
install_herdr
[[ "${SKIP_PYTHON_TOOLS:-0}" == "1" ]] || install_python_tools
[[ "${SKIP_PLUGINS:-0}" == "1" ]] || install_nvim_plugins

log "Done"
printf 'Dotfiles directory: %s\n' "${DOTFILES_DIR}"
if [[ -d "${BACKUP_DIR}" ]]; then
  printf 'Backups: %s\n' "${BACKUP_DIR}"
fi
