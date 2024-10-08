let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin Section
call plug#begin()

Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'jiangmiao/auto-pairs'
Plug 'numirias/semshi'
Plug 'dense-analysis/ale'
Plug 'davidhalter/jedi-vim'
Plug 'junegunn/vim-emoji'
Plug 'elzr/vim-json'
Plug 'ervandew/supertab'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'honza/vim-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
" Plugins - Python
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }
" PLugins - Tmux
Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-tmux-runner'
Plug 'kien/ctrlp.vim'
" Plugins - Flutter
Plug 'dart-lang/dart-vim-plugin'
Plug 'natebosch/dartlang-snippets'
Plug 'thosakwe/vim-flutter'
Plug 'natebosch/vim-lsc'
Plug 'natebosch/vim-lsc-dart'

call plug#end()

" Config Section

colorscheme catppuccin-latte

set number
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

set nocompatible
set smartindent
filetype plugin on
syntax on
set expandtab
set tabstop=4
set shiftwidth=4

" Security Section
set noswapfile
set nobackup
set nowritebackup
set viminfo=

au BufNewFile,BufRead *.py \
  set foldmethod=indent

au BufNewFile,BufRead Jenkinsfile setf groovy

let g:ale_linters = {
      \   'python': ['flake8', 'pylint'],
      \   'ruby': ['standardrb', 'rubocop'],
      \   'javascript': ['eslint'],
      \   'sql': ['sqlfluff', 'sqlint', 'sqllint'],
      \}
let g:ale_fixers = {
      \    'python': ['black'],
      \}
let g:ale_fix_on_save = 1

let g:nv_search_paths = ['~/workspace/perso/notes','~/workspace/perso/wiki', './notes.md', './doc', './notes']
let g:nv_main_directory = '~/workspace/perso/notes'
let g:vimwiki_list = [{
			\'path':'~/workspace/perso/wiki/wiki', 
			\'syntax': 'markdown', 'ext': '.md',
			\'custom_wiki2html': '~/workspace/perso/wiki/wk2html.sh',
			\'path_html':'~/workspace/perso/wiki/docs', 
			\'template_path': '~/workspace/perso/wiki/templates',
			\'template_default':'default',
			\'template_ext':'.html'}]
let g:vimwiki_global_ext = 0

au FileType vimwiki setlocal shiftwidth=6 tabstop=6 noexpandtab
autocmd FileType sql setlocal shiftwidth=4 tabstop=4



" Keybindings Section
nnoremap <SPACE> <Nop>
let mapleader = " "
nnoremap <tab> za
nnoremap <silent> <leader>e :NERDTreeToggle<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
nmap <leader>rn <Plug>(coc-rename)
nmap <buffer> <silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
let g:mdip_imgdir = 'img'
nmap <silent> <c-s> :NV<CR>
nmap <silent> <leader>ts i<C-R>=strftime("%a %d %b %Y %I:%M:%S %p %Z")<CR><Esc>
nnoremap <silent> <leader>em :%s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>


" Custom Functions Section

"" Displays the number of Warnings and Errors in Status Line
function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✨ all good ✨' : printf(
        \   '😞 %dW %dE',
        \   all_non_errors,
        \   all_errors
        \)
endfunction

set statusline=
set statusline+=%m
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %{LinterStatus()}

" Shows documentation
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Emoji Autocompletion
set completefunc=emoji#complete

" Coc & Jedi config
let g:jedi#use_splits_not_buffers = "bottom"
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-flutter',
  \ ]

" Automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Zoom a vim pane, <C-w>= to rebalance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" Tune VTR to not mess up Python syntaxic whitespace
let g:VtrStripLeadingWhitespace = 0
let g:VtrClearEmptyLines = 0
let g:VtrAppendNewline = 1

" Update all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 1

" Open a script runner attached to the current vim session
nnoremap <leader>osr :VtrOpenRunner {'orientation': 'h', 'percentage': 50}<cr>
nnoremap <leader>irb :VtrOpenRunner {'orientation': 'h', 'percentage': 50, 'cmd': 'irb'}<cr>
nnoremap <leader>ipy :VtrOpenRunner {'orientation': 'h', 'percentage': 50, 'cmd': 'ipython'}<cr>


" other VTR shortcuts
nnoremap <leader>sl :VtrSendLinesToRunner<cr>
nnoremap <leader>sd :VtrSendCtrlD<cr>
nnoremap <leader>sc :VtrSendCommandToRunner<cr>
