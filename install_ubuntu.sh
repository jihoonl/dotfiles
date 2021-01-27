#!/bin/bash

sudo apt update

echo "Install neovim"
if [ ! -f /usr/bin/nvim ]; then
    sudo apt install python-software-properties software-properties-common --yes
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt update
    sudo apt install neovim --yes
fi

mkdir -p ~/.config
ln -sf `pwd`/nvim ~/.config/nvim

echo "installing dependencies"
sudo apt install python-dev python-pip python3-dev python3-pip ruby --yes
sudo apt install python-neovim python3-neovim flake8 pylint python-pylint-django clang-format silversearcher-ag --yes
sudo apt install build-essential tmux --yes
pip install neovim yapf isort mypy isort black

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
