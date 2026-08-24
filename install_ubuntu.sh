#!/bin/bash

sudo apt update

echo "Install neovim"
if [ ! -f /usr/bin/nvim ]; then
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    sudo apt install neovim --yes
fi

mkdir -p ~/.config
ln -sf `pwd`/nvim ~/.config/nvim
ln -sf `pwd`/terminator ~/.config/terminator

echo "installing dependencies"
sudo apt install python3-dev python3-pip python3-dev python3-pip ruby --yes
sudo apt install python3-neovim python3-neovim flake8 pylint python3-pylint-django clang-format silversearcher-ag clang--yes
sudo apt install build-essential tmux --yes
pip3 install neovim yapf isort mypy isort black

echo "Installing xsel to be able to use the X clipboard"
sudo apt-get install xsel --yes

echo "Installing powerline fonts"
git clone https://github.com/powerline/fonts.git
./fonts/install.sh
rm -rf fonts/

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

echo "Adding imgcat"
pip install imgcat

echo "Adding tqdm"
pip install tqdm

echo "Adding ccmake"
sudo apt install cmake-curses-gui

echo "Adding tmux.conf"
ln -sf `pwd`/tmux.conf ~/.tmux.conf

echo "Adding git config"
ln -sf `pwd`/gitconfig ~/.gitconfig

echo "Adding setup.cfg"
ln -sf `pwd`/isort.cfg ~/.isort.cfg

vim +UpdateRemotePlugins +PlugInstall +PlugStatus

echo "Adding claude config"
mkdir -p ~/.claude
ln -sf `pwd`/claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "Installing claude code"
if ! command -v claude >/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"

echo "Installing claude plugins"
if command -v claude >/dev/null; then
    claude plugin marketplace add tobi/qmd
    claude plugin marketplace add DietrichGebert/ponytail
    for p in github@claude-plugins-official \
             claude-md-management@claude-plugins-official \
             security-guidance@claude-plugins-official \
             superpowers@claude-plugins-official \
             code-review@claude-plugins-official \
             commit-commands@claude-plugins-official \
             clangd-lsp@claude-plugins-official \
             chrome-devtools-mcp@claude-plugins-official \
             qmd@qmd \
             ponytail@ponytail; do
        claude plugin install -y "$p"
    done
fi
