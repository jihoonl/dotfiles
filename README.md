# dotfiles

Personal terminal and development configuration for macOS and Ubuntu.

## Setup

One installer covers both platforms and picks apt or Homebrew from `uname`. It
installs Neovim, tmux, Git, the command-line utilities used by the editor
configuration, Claude Code with its plugins, herdr with its Claude
integration, and on macOS also Homebrew, cmux, Ghostty, and colima.

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
SKIP_NODE=1 ~/.dotfiles/install.sh
SKIP_BREW_INSTALL=1 ~/.dotfiles/install.sh   # macOS only
SKIP_COLIMA=1 ~/.dotfiles/install.sh         # macOS only
COLIMA_CPU_PERCENT=25 ~/.dotfiles/install.sh     # macOS only
COLIMA_MEMORY_PERCENT=25 ~/.dotfiles/install.sh  # macOS only
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

## Docker on macOS

Docker runs in two colima VMs, created by the installer if they are missing:
`default` builds arm64 images and `x86` builds amd64 ones through Rosetta.
Both get a percentage of the host's cores and memory, 50 by default;
`COLIMA_CPU_PERCENT` and `COLIMA_MEMORY_PERCENT` change it.

```sh
docker context use colima          # arm64
docker context use colima-x86      # amd64
```

Creating an instance boots it, which takes minutes, so `SKIP_COLIMA=1` skips
this step; an instance that already exists is never touched. Only `default` is
left running -- `x86` is stopped after it is created, since amd64 builds are
occasional and at 50 percent each the two together would commit the whole
host. Start it when needed with `colima start x86`. Rosetta 2 is installed
first if it is missing, which asks for a password.

`colima/template.yaml` supplies defaults that have no start flag -- currently
the robot's insecure registry. A template is read only when an instance is
created, so changing it does not affect the two that exist; edit
`~/.colima/<profile>/colima.yaml` and restart that instance instead.

## herdr on macOS

cmux is the local workspace manager; herdr is used for the remote session on
the Ubuntu box. They cannot share a window: cmux owns every Cmd chord and
presents `TERM=xterm-256color`, which drops herdr to legacy key encoding where
no Cmd chord can be delivered at all. Under a standalone Ghostty window herdr
gets `TERM=xterm-ghostty` and the Kitty keyboard protocol, so the Cmd
bindings in `herdr/config.toml` work the same as they do on Ubuntu.

Open that window with the zsh functions:

```sh
herdr-remote <host>          # any host
herdr-holiday-desktop        # the Ubuntu box
```

`herdr-remote` holds the Ghostty invocation; the per-host function only fills
in `--remote`. Both pass extra arguments through to herdr.

It launches Ghostty with `ghostty/herdr.conf` layered on top of the shared
Ghostty config. That file only releases the Cmd chords Ghostty binds itself,
so herdr can receive them; cmux never loads it and keeps its own shortcuts.

Detach from herdr with `Ctrl-B q`. `Cmd-Q` still quits Ghostty.

The host needs a matching `~/.ssh/config` entry; ssh configuration is not
managed here. A named session beside the default one:

```sh
herdr-holiday-desktop --session <name>
```

Attach this way rather than running `herdr` over a plain `ssh` session.
`--remote-keybindings` defaults to `local`, so the keys come from this Mac's
`herdr/config.toml` even though the panes run on the remote host; over plain
ssh the server's own config applies instead. The keys are a snapshot taken
when the client attaches, so detach and reattach after editing them.

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
| `ghostty/herdr.conf` | `~/.config/ghostty/herdr.conf` (macOS only) |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` (macOS only) |
| `colima/template.yaml` | `~/.colima/_templates/default.yaml` (macOS only) |
| `zprofile` | `~/.zprofile` (macOS only) |
| `zshrc` | `~/.zshrc` (macOS only) |
