set nocompatible

let mapleader = ' '
let maplocalleader = ' '
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 28
let g:netrw_localcopydircmd = 'cp -r'

syntax enable
filetype plugin indent on

if has('termguicolors')
  set termguicolors
endif

set background=dark
silent! colorscheme sway-rice

set encoding=utf-8
set fileencoding=utf-8
set backspace=indent,eol,start
set number
set norelativenumber
set cursorline
set signcolumn=yes
set colorcolumn=100
set nowrap
set linebreak
set scrolloff=8
set sidescrolloff=8
set showcmd
set noshowmode
set laststatus=2
set ruler
set wildmenu
set wildmode=longest:full,full
set splitbelow
set splitright
set fillchars=eob:\ ,fold:\ ,foldopen:,foldclose:,foldsep:\ ,vert:│,diff:╱

set expandtab
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2

set ignorecase
set smartcase
set incsearch
set hlsearch

set hidden
set nobackup
set nowritebackup
set noswapfile
set updatetime=250
set timeoutlen=400

if has('clipboard')
  set clipboard=unnamedplus
endif

if has('persistent_undo')
  call mkdir(expand('~/.vim/undo'), 'p')
  set undofile
  set undodir=~/.vim/undo//
endif

if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

set statusline=%#SwayRiceStatusAccent#\ \ VIM\ 
set statusline+=%#SwayRiceStatusIcon#\ \ 
set statusline+=%#SwayRiceStatusFile#%<%f\ 
set statusline+=%#SwayRiceStatusMuted#%m%r%h%w
set statusline+=%=
set statusline+=%#SwayRiceStatusMuted#\ 󰈙\ %y\ 
set statusline+=%#SwayRiceStatusFile#\ \ %l\ \ %c\ 
set statusline+=%#SwayRiceStatusMuted#%p%%\ 

function! SwayRiceSave() abort
  if expand('%') ==# ''
    let l:path = input('Save as: ', '', 'file')

    if l:path ==# ''
      return
    endif

    execute 'write ' . fnameescape(expand(l:path))
  else
    silent write
  endif

  echo 'Saved'
endfunction

function! SwayRiceQuit() abort
  confirm quit
endfunction

function! SwayRiceOpenFile() abort
  let l:path = input('Open file: ', '', 'file')

  if l:path !=# ''
    execute 'confirm edit ' . fnameescape(expand(l:path))
  endif
endfunction

function! SwayRiceFind() abort
  let l:pattern = input('Find: ')

  if l:pattern !=# ''
    let @/ = l:pattern
    set hlsearch
    call search(l:pattern, 'W')
  endif
endfunction

function! SwayRiceReplace() abort
  let l:find = input('Find: ')

  if l:find ==# ''
    return
  endif

  let l:replacement = input('Replace with: ')
  let l:escaped_find = '\V' . escape(l:find, '\/')
  let l:escaped_replacement = escape(l:replacement, '\&/')
  execute '%s/' . l:escaped_find . '/' . l:escaped_replacement . '/gc'
endfunction

function! SwayRiceDiagnostics() abort
  if empty(getqflist())
    echo 'No diagnostics list yet'
  else
    copen
  endif
endfunction

function! SwayRiceHelp() abort
  botright 22new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  call setline(1, [
        \ 'Normal editor keys',
        \ '',
        \ 'Ctrl-S        save',
        \ 'Ctrl-Q        quit, asking about unsaved changes',
        \ 'Ctrl-O/Ctrl-P open file prompt',
        \ 'Ctrl-E        file explorer',
        \ 'Ctrl-F        find in this file',
        \ 'Ctrl-H        find and replace',
        \ 'Ctrl-A        select all',
        \ 'Ctrl-C        copy selection, or current line if nothing selected',
        \ 'Ctrl-X        cut selection, or current line if nothing selected',
        \ 'Ctrl-V        paste',
        \ 'Ctrl-Z        undo',
        \ 'Ctrl-Y        redo',
        \ 'Ctrl-/        this help',
        \ '',
        \ 'You can mostly type like a normal editor. Press Esc only if you want Vim commands.',
        \ 'Press q to close this help.'
        \ ])
  nnoremap <silent> <buffer> q :bd!<CR>
endfunction

nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <silent> <leader>w :call SwayRiceSave()<CR>
nnoremap <silent> <leader>q :call SwayRiceQuit()<CR>
nnoremap <silent> <leader>Q :quitall<CR>
nnoremap <silent> <leader>e :Explore<CR>
nnoremap <silent> <leader>f :call SwayRiceOpenFile()<CR>
nnoremap <silent> <leader>v :vsplit<CR>
nnoremap <silent> <leader>s :split<CR>
nnoremap <silent> <leader>n :set number! relativenumber!<CR>
nnoremap <silent> <leader>h <C-w>h
nnoremap <silent> <leader>j <C-w>j
nnoremap <silent> <leader>k <C-w>k
nnoremap <silent> <leader>l <C-w>l
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+p

nnoremap <silent> <C-s> :call SwayRiceSave()<CR>
inoremap <silent> <C-s> <C-o>:call SwayRiceSave()<CR>
vnoremap <silent> <C-s> :<C-u>call SwayRiceSave()<CR>gv
nnoremap <silent> <C-q> :call SwayRiceQuit()<CR>
inoremap <silent> <C-q> <Esc>:call SwayRiceQuit()<CR>
vnoremap <silent> <C-q> :<C-u>call SwayRiceQuit()<CR>
nnoremap <silent> <C-o> :call SwayRiceOpenFile()<CR>
inoremap <silent> <C-o> <Esc>:call SwayRiceOpenFile()<CR>
vnoremap <silent> <C-o> :<C-u>call SwayRiceOpenFile()<CR>
nnoremap <silent> <C-p> :call SwayRiceOpenFile()<CR>
inoremap <silent> <C-p> <Esc>:call SwayRiceOpenFile()<CR>
vnoremap <silent> <C-p> :<C-u>call SwayRiceOpenFile()<CR>
nnoremap <silent> <C-e> :Explore<CR>
inoremap <silent> <C-e> <Esc>:Explore<CR>
vnoremap <silent> <C-e> :<C-u>Explore<CR>
nnoremap <silent> <C-f> :call SwayRiceFind()<CR>
inoremap <silent> <C-f> <Esc>:call SwayRiceFind()<CR>i
vnoremap <silent> <C-f> :<C-u>call SwayRiceFind()<CR>
nnoremap <silent> <C-h> :call SwayRiceReplace()<CR>
inoremap <silent> <C-h> <Esc>:call SwayRiceReplace()<CR>i
vnoremap <silent> <C-h> :<C-u>call SwayRiceReplace()<CR>
nnoremap <silent> <C-a> ggVG
inoremap <silent> <C-a> <Esc>ggVG
vnoremap <silent> <C-a> <Esc>ggVG
nnoremap <silent> <C-c> "+yy
vnoremap <silent> <C-c> "+y
nnoremap <silent> <C-x> "+dd
inoremap <silent> <C-x> <Esc>"+ddi
vnoremap <silent> <C-x> "+d
nnoremap <silent> <C-v> "+p
inoremap <silent> <C-v> <C-r>+
vnoremap <silent> <C-v> "+p
nnoremap <silent> <C-z> u
inoremap <silent> <C-z> <C-o>u
vnoremap <silent> <C-z> <Esc>u
nnoremap <silent> <C-y> <C-r>
inoremap <silent> <C-y> <C-o><C-r>
nnoremap <silent> <C-d> :call SwayRiceDiagnostics()<CR>
inoremap <silent> <C-d> <Esc>:call SwayRiceDiagnostics()<CR>i
nnoremap <silent> <C-_> :call SwayRiceHelp()<CR>
inoremap <silent> <C-_> <Esc>:call SwayRiceHelp()<CR>
vnoremap <silent> <C-_> :<C-u>call SwayRiceHelp()<CR>

augroup sway_rice
  autocmd!
  autocmd VimEnter * if &buftype ==# '' | startinsert | endif
  autocmd VimResized * tabdo wincmd =
  autocmd FileType gitcommit,markdown,text setlocal wrap colorcolumn=
augroup END
