# dotfiles

Personal terminal and development configuration for macOS and Ubuntu.

## Setup

One installer covers both platforms and picks apt or Homebrew from `uname`. It
installs Neovim, tmux, Git, the command-line utilities used by the editor
configuration, Claude Code with its plugins, herdr with its Claude
integration, and on macOS also Homebrew and cmux.

```sh
git clone git@github.com:jihoonl/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

Existing configuration files are moved to a timestamped directory under
`~/.dotfiles-backup/` before symbolic links are created, and re-running the
installer is safe.

Optional environment variables:

```sh
SKIP_PACKAGES=1 ~/.dotfiles/install.sh
SKIP_PYTHON_TOOLS=1 ~/.dotfiles/install.sh
SKIP_PLUGINS=1 ~/.dotfiles/install.sh
SKIP_BREW_INSTALL=1 ~/.dotfiles/install.sh   # macOS only
```

## macOS configuration

- zsh uses an Ubuntu-style `user@host:directory$` prompt.
- Homebrew is initialized from `/opt/homebrew` or `/usr/local`.
- `ls` uses macOS file-type colors; `l` and `ll` provide detailed views.
- `vi` and `vim` launch Neovim.
- Neovim uses the Gruvbox colorscheme.
- `:Autoformat` uses Ruff for Python and clang-format for C, C++, and Objective-C.
- clang-format respects a project's `.clang-format` and falls back to Google style.
- cmux uses the Molokai terminal palette at 15 pt with an opaque background.
- cmux uses a dark frame, a blue active-pane border, and a sidebar matching the
  terminal background.

After changing cmux or Ghostty settings, reload them with `Command-Shift-,`.
Existing shells can reload zsh settings with:

```sh
source ~/.zprofile
source ~/.zshrc
```

## Managed paths

| Repository path | Installed path |
| --- | --- |
| `nvim/` | `~/.config/nvim` |
| `tmux.conf` | `~/.tmux.conf` |
| `gitconfig` | `~/.gitconfig` |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `agents/CPP.md` | `~/.claude/CPP.md`, `~/.codex/CPP.md` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `terminator/` | `~/.config/terminator` (Ubuntu only) |
| `ghostty/config` | `~/.config/ghostty/config` (macOS only) |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` (macOS only) |
| `zprofile` | `~/.zprofile` (macOS only) |
| `zshrc` | `~/.zshrc` (macOS only) |
