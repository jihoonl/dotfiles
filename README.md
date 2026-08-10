# dotfiles

Personal terminal and development configuration for macOS and Ubuntu.

## macOS setup

The installer supports both Apple Silicon and Intel Macs. It installs Homebrew,
cmux, Neovim, tmux, Git, Python tooling, and the command-line utilities used by
the editor configuration.

```sh
git clone git@github.com:jihoonl/dotfiles.git ~/.dotfiles
~/.dotfiles/install_macos.sh
```

Existing configuration files are moved to a timestamped directory under
`~/.dotfiles-backup/` before symbolic links are created.

Optional environment variables:

```sh
SKIP_BREW_INSTALL=1 ~/.dotfiles/install_macos.sh
SKIP_PACKAGES=1 ~/.dotfiles/install_macos.sh
SKIP_PYTHON_TOOLS=1 ~/.dotfiles/install_macos.sh
SKIP_PLUGINS=1 ~/.dotfiles/install_macos.sh
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
| `isort.cfg` | `~/.isort.cfg` |
| `mypy/config` | `~/.config/mypy/config` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` |
| `zprofile` | `~/.zprofile` |
| `zshrc` | `~/.zshrc` |

## Ubuntu

The existing Ubuntu configuration can be installed with:

```sh
~/.dotfiles/install_ubuntu.sh
```
