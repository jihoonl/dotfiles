let g:is_nvim = has('nvim')
let g:is_vim8 = v:version >= 800 ? 1 : 0

" Reuse nvim's runtimepath and packpath in vim
if !g:is_nvim && g:is_vim8
  set runtimepath-=~/.vim
    \ runtimepath^=~/.local/share/nvim/site runtimepath^=~/.vim
    \ runtimepath-=~/.vim/after
    \ runtimepath+=~/.local/share/nvim/site/after runtimepath+=~/.vim/after
  let &packpath = &runtimepath
endif

if g:is_nvim
  call plug#begin('~/.config/nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif


" autocompletion
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
" Plug 'tweekmonster/deoplete-clang2'
" Plug 'zchee/deoplete-clang'  " does not work at the moment, tim will fix it
"
" tools
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all --no-update-rc --no-completion' } "FZF command line tool
"Plug 'junegunn/fzf.vim' "corresponding vim plugin to fzf
"Plug 'tpope/vim-dispatch' "Add more text objects for parens (eg: ci) or da,)
"Plug 'radenling/vim-dispatch-neovim' "Add more text objects for parens (eg: ci) or da,)
Plug 'nvie/vim-togglemouse' "allows mouse toggleing with F12
Plug 'tpope/vim-fugitive' " GIT
"Plug 'scrooloose/nerdtree' "file tree
"Plug 'jistr/vim-nerdtree-tabs' "Tab support for nerdtree

Plug 'beautify-web/js-beautify'


" linting
Plug 'psf/black', { 'branch': 'stable' }
Plug 'Chiel92/vim-autoformat'  "Autoformatting
Plug 'w0rp/ale' " Syntastic for neovim (works on buffers, not files, suck it neomake)
"Plug 'davidhalter/jedi-vim'  "python features for vim like jump to definition
Plug 'ntpeters/vim-better-whitespace' "delete whitespaces
Plug 'hynek/vim-python-pep8-indent' "Better intentat for .py files
Plug 'stsewd/isort.nvim', { 'do': ':UpdateRemotePlugins' }

" Colorschemes
Plug 'morhetz/gruvbox' "
Plug 'lifepillar/vim-solarized8' "
Plug 'mhartington/oceanic-next' "
Plug 'sjl/badwolf' "
Plug 'tomasr/molokai'

" visualization
Plug 'machakann/vim-highlightedyank' " Nice highlighing for yanks
Plug 'luochen1990/rainbow' "Rainbow coloring for parens
Plug 'itchyny/lightline.vim' " Vim airline alternative without the crap
" Plug 'itchyny/vim-cursorword' " underline word under cursor

" text objects and motion
Plug 'tpope/vim-unimpaired' "Keymappings for common commands
Plug 'easymotion/vim-easymotion' "Vim motion on speed
"Plug 'tomtom/tcomment_vim' "Easier commenting
Plug 'tpope/vim-surround' "Surround your code easily
"Plug 'wellle/targets.vim' "Add more text objects for parens (eg: ci) or da,)
Plug 'kana/vim-textobj-user' "easy new text objects
Plug 'kana/vim-textobj-function' "function text object > f
Plug 'kana/vim-textobj-indent' "Text objects base on intent > i
Plug 'lucapette/vim-textobj-underscore' " underscore text object > _
Plug 'Julian/vim-textobj-brace' " []{}() text obj > j
Plug 'saihoooooooo/vim-textobj-space' " empty space with > S
Plug 'whatyouhide/vim-textobj-xmlattr' " xml/html tags with > x
Plug 'bps/vim-textobj-python' " python function /class with > f > c

" Github copilot
Plug 'github/copilot.vim'
call plug#end()


"Settings
filetype plugin indent on    " required
syntax enable "syntax highlighing
if (has("termguicolors"))
 set termguicolors
endif

try
    colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
    " This has do be done for automatic installation
endtry

if exists('&inccommand')
   set inccommand=nosplit
endif

set background=dark
set tabstop=4 "Tabsettings
set expandtab
set shiftwidth=4
set softtabstop=4
set number "show line numbers
set wildignore+=*.o,*.obj,.git,*.pyc "Ignore stupid files
set listchars=tab:>-,trail:-,precedes:<,extends:>
set splitbelow "More useful splits below and right
set splitright
set colorcolumn=88 "Add a colored line after at 80 characters
set nf=octal,hex,alpha "Increment letters witch C-a, decrement with C-x
set ignorecase
set mouse=
"set undodir=~/.config/nvim/undodir "persistent undos!
"set undofile

"Keymappings
let loaded_matchparen = 1
let mapleader = ","
map q: <Nop>
nnoremap Q <nop>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
map <leader>p "+p
map <leader>y "+y
map <leader>P "+gP
map <leader>Y "+yy
map <leader>rd :mode<cr>
noremap <M-Left> :bprev<CR>
noremap <M-Right> :bnext<CR>
map <Leader>n <plug>NERDTreeTabsToggle<CR>
tnoremap <ESC> <C-\><C-n>
nnoremap <leader>o :vsplit term://$SHELL<cr>i
nnoremap <leader>pk :execute ':silent !pkill -f ' .expand('%:t')<cr>
nnoremap <leader>h :History<cr>
nnoremap <leader>f :Files<cr>
nnoremap <leader>l :let b:ale_linters = {'python': ['flake8', 'pylint']}<cr>:ALELint<cr>
nnoremap <leader>g :Ag
nnoremap <leader>pa :set paste<cr>
nnoremap <F3> :noh<cr>
nnoremap <leader>tp :execute ':!tagproject'<cr>
nnoremap <leader>; m`A;<Esc>``<cr>
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
cnoremap <expr> <Up>    pumvisible() ? "\<Left>"  : "\<Up>"
cnoremap <expr> <Down>  pumvisible() ? "\<Right>" : "\<Down>"
cnoremap <expr> <Left>  pumvisible() ? "\<Up>"    : "\<Left>"
cnoremap <expr> <Right> pumvisible() ? "\<Down>"  : "\<Right>"

"Plugin settings
let g:isort_command = 'isort'

let g:fzf_layout = {'down': '~20%'}
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
autocmd BufEnter * call CheckLeftBuffers()
let g:nerdtree_tabs_open_on_gui_startup = !$NVIM_TUI_ENABLE_TRUE_COLOR
let NERDTreeIgnore = ['\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$', '\.egg-info$[[dir]]'] "Ignore files in tree
let g:highlightedyank_highlight_duration = 200
let g:deoplete#enable_at_startup = 1
let g:chapa_default_mappings = 1
let g:chapa_no_repeat_mappings = 1
"let g:jedi#goto_assignments_command = ""
"let g:jedi#usages_command = ""
"let g:jedi#use_tabs_not_buffers = 1
"let g:jedi#completions_enabled = 0
"let g:jedi#show_call_signatures = "0"
let g:ale_lint_delay = 1000
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_python_flake8_options="--max-line-length=88"
let g:ale_python_pylint_options="--max-line-length=88"
let g:ale_linters = {'python': ['flake8']}
highlight ALEErrorSign ctermfg=red ctermbg=235
highlight ALEWArningSign ctermfg=yellow ctermbg=235
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightlineFugitive',
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"\ue0a2":""}',
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
      \ }
"Custom filetypes
au BufRead,BufNewFile *.launch		    set filetype=xml
au BufRead,BufNewFile *.pddl            set filetype lisp
au BufRead,BufNewFile *.ino,*.pde       set filetype=cpp
au BufRead,BufNewFile *.html            set filetype=htmlm4
au BufRead,BufNewFile *.cpp             let g:ale_lint_on_text_changed = 'never'

autocmd BufReadPost * if &ft != 'gitcommit' |
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal g`\"" |
            \ endif






function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! CheckLeftBuffers()
  if tabpagenr('$') == 1
    let i = 1
    while i <= winnr('$')
      if getbufvar(winbufnr(i), '&buftype') == 'help' ||
          \ getbufvar(winbufnr(i), '&buftype') == 'quickfix' ||
          \ exists('t:NERDTreeBufName') &&
          \   bufname(winbufnr(i)) == t:NERDTreeBufName ||
          \ bufname(winbufnr(i)) == '__Tag_List__'
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
      qall
    endif
    unlet i
  endif
endfunction

function! SetShell()
    let l:active_shell = system("echo $SHELL")
    if (l:active_shell=~'bash')
        set shell=bash\ --login
    else
        set shell=zsh\ -i
    endif
endfunction

function! LightlineFugitive()
  if exists("*fugitive#head")
    let branch = fugitive#head()
    return branch !=# '' ? "\ue0a0 ".branch : ''
  endif
  return ''
endfunction

noremap <silent> gC :set opfunc=ToggleComment<CR>g@
vnoremap <silent> gC :<C-U>call ToggleComment(visualmode())<CR>

function! ToggleComment(type)
    " motion
    if a:type == "line" || a:type == "char" || a:type == "block"
        silent '[,'] norm gcc
    " visual
    else
        silent '<,'> norm gcc
    endif
endfunction


set tabstop=2 "Tabsettings
set expandtab
set shiftwidth=2
set softtabstop=2
set ignorecase
set incsearch
set hlsearch

let g:formatters_python = ['yapf']
let g:formatdef_yapf='"yapf  --style google"'
let g:formatdef_clangformat= "'clang-format -style=file'"
