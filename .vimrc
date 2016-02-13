set number
set laststatus=2
set title
set showmode
set nowrap
set ff=unix

"------------------Set Search Options-------
set hlsearch
set incsearch
set ignorecase

"------------------Layout Setting-----------
set statusline=%<%f\ %h%m%r%=0x%B\ %c\ %l\/%L(%p%%) " %-10.(%c\ %l\/%L%)  
set history=50

"-----------------Indent Setting------------
"set autoindent
"set cindent
"set smartindent
set backspace=indent,eol,start
set tabstop    =2
set softtabstop=2
set shiftwidth =2
set expandtab
set smarttab

"--------------- Spell Checking
"set spell


"------------------Backup Setting-----------
set nobackup
set nowritebackup
set backupdir=~/.vim/tmp
set backupskip=*.back
set backupext=._Vim_.back

color torte
color desert

syntax on

au Filetype python setl et ts=4 sw=4 
au BufNewFile,BufRead *.launch set filetype=xml
au BufNewFile,BufRead *.job set filetype=yaml
au BufNewFile,BufRead *.service set filetype=yaml
au BufNewFile,BufRead *.software set filetype=yaml
au BufNewFile,BufRead *.rapps set filetype=yaml
au BufNewFile,BufRead *.rapp set filetype=yaml
au BufRead,BufNewFile *.ino set filetype=arduino
