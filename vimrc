" # VIMRC #

" XDG support {{{1

if empty($MYVIMRC) | let $MYVIMRC = expand('%:p') | endif

if empty($XDG_CACHE_HOME)  | let $XDG_CACHE_HOME  = $HOME."/.cache"       | endif
if empty($XDG_CONFIG_HOME) | let $XDG_CONFIG_HOME = $HOME."/.config"      | endif
if empty($XDG_DATA_HOME)   | let $XDG_DATA_HOME   = $HOME."/.local/share" | endif

set runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath+=$XDG_CONFIG_HOME/vim/after
set runtimepath+=$XDG_DATA_HOME/vim
set packpath^=$XDG_DATA_HOME/vim

set backupdir=$XDG_CACHE_HOME/vim/backup | call mkdir(&backupdir, 'p', 0700)
set directory=$XDG_CACHE_HOME/vim/swap   | call mkdir(&directory, 'p', 0700)
set undodir=$XDG_CACHE_HOME/vim/undo     | call mkdir(&undodir,   'p', 0700)
set viewdir=$XDG_CACHE_HOME/vim/view     | call mkdir(&viewdir,   'p', 0700)

call mkdir($XDG_DATA_HOME."/vim/spell", 'p', 0700)

" BASICS {{{1

if &compatible
  set nocompatible
endif

filetype plugin indent on
set backspace=indent,eol,start
syntax enable
let mapleader = "\<Space>"
if &shell =~# 'fish$'
  set shell=sh
endif

" "Force" Python3 (helpful for plugins)
if has('python3')
  " python3 #
endif

silent! helptags ALL " genereate help tags

" COLORSCHEME {{{1

" augroup colors
"   au!
"   au ColorScheme darkness hi cmakeCommand  cterm=bold
"   au ColorScheme darkness hi Dimmer        cterm=italic ctermfg=245
" augroup END

try
  set background=dark
  " colorscheme darkness
  colorscheme Vimer
catch
  set bg=dark
  hi! ColorColumn ctermbg=233
  hi! Comment     ctermfg=240
  hi! link Folded Comment
  hi! link LineNr Comment
endtry

hi Normal guibg=NONE ctermbg=NONE
hi NonText guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE
hi SignColumn guibg=NONE ctermbg=NONE
hi VertSplit guibg=NONE ctermbg=NONE

hi TabLine      ctermfg=Black  ctermbg=Green     cterm=NONE
hi TabLineFill  ctermfg=Black  ctermbg=Green     cterm=NONE
hi TabLineSel   ctermfg=White  ctermbg=DarkBlue  cterm=NONE

" COMMANDS {{{1

command! -nargs=* GrepRename call <SID>GrepRename(<f-args>)
command! -nargs=* TermDebug normal! :Termdebug <args><CR><C-w>K<C-w>j<C-w>L
command! -nargs=+ FillLine call <SID>FillLine(<f-args>)
command! -nargs=+ Grep execute "lvimgrep /".<q-args>."/j **"
command! -nargs=? -bang Spelling setlocal spell<bang> spelllang=<args>
command! -range -nargs=+ Align <line1>,<line2>!column -Lts'<args>' -o'<args>'
command! -range -nargs=0 -bang VisSort sil! keepj <line1>,<line2>call <SID>VisSort(<bang>0)
command! -range=% Sort normal :<line1>,<line2>sort i<CR>
" command! Book setlocal nonumber wrap columns=90 colorcolumn= laststatus=0
command! ExecCurrentLine normal :.w !sh<CR>
command! GB call setbufvar(winbufnr(popup_atcursor(systemlist("cd " . shellescape(fnamemodify(resolve(expand('%:p')), ":h")) . " && git log --no-merges -n 1 -L " . shellescape(line("v") . "," . line(".") . ":" . resolve(expand("%:p")))), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")
command! SortBlock :normal! vip:sort i<CR>
command! SudoW execute 'silent! write !sudo tee % >/dev/null' | edit!
command! Term vertical terminal ++noclose
command! Todo lvimgrep "\<TODO\>" %

" FORMATTING {{{1

augroup FORMATOPTIONS
  autocmd!
  autocmd FileType * set fo-=c fo-=r fo-=o " Disable continuation of comments to the next line
  autocmd FileType * set formatoptions+=j  " Remove a comment leader when joining lines
  autocmd FileType * set formatoptions+=l  " Don't break a line after a one-letter word
  autocmd FileType * set formatoptions+=n  " Recognize numbered lists
  autocmd FileType * set formatoptions-=q  " Don't format comments
  autocmd FileType * set formatoptions-=t  " Don't autowrap text using 'textwidth'
augroup END

set cindent
set smarttab
set expandtab
set shiftround
set shiftwidth=0   " If 0, then uses value of 'tabstop'
set softtabstop=2
set shiftwidth=2
set shiftround
set tabstop=2
set textwidth=80
set tabline=%!Tabline()

" For thise filetypes set 'tabstop' to 2
execute "autocmd FileType ".
      \   "arduino"           .",".
      \   "html,xhtml,xml"    .",".
      \   "*css"              .",".
      \   "javascript,json"   .",".
      \   "cmake"             .",".
      \   "lua"               .",".
      \   "markdown"          .",".
      \   "vim"               .",".
      \ " setlocal tabstop=2"

" For thise filetypes set 'tabstop' to 3
execute "autocmd FileType ".
      \   "ada"                .",".
      \   "plaintex,tex"       .",".
      \ " setlocal tabstop=3"

let s:formatprg_for_filetype = {
      \ "arduino"     : "uncrustify --l CPP base kr mb stroustrup 1tbs 2sw",
      \ "c"           : "uncrustify --l C base kr mb",
      \ "cpp"         : "uncrustify --l CPP base kr mb stroustrup",
      \ "cmake"       : "cmake-format --command-case lower -",
      \ "css"         : "css-beautify -s 2 --space-around-combinator",
      \ "go"          : "gofmt",
      \ "html"        : "tidy -q -w -i --show-warnings 0 --show-errors 0 --tidy-mark no",
      \ "java"        : "uncrustify --l JAVA base kr mb java",
      \ "javascript"  : "js-beautify -s 2",
      \ "json"        : "js-beautify -s 2",
      \ "python"      : "autopep8 -",
      \ "sql"         : "sqlformat -k upper -r -",
      \ "xhtml"       : "tidy -asxhtml -q -m -w -i --show-warnings 0 --show-errors 0 --tidy-mark no --doctype loose",
      \ "xml"         : "tidy -xml -q -m -w -i --show-warnings 0 --show-errors 0 --tidy-mark no",
      \}

for [ft, fp] in items(s:formatprg_for_filetype)
  execute "autocmd FileType ".ft." let &l:formatprg=\"".fp."\" | setlocal formatexpr="
endfor

" FUNCTIONS {{{1
" command! -nargs=+ -bang CtrlPGrep silent! grep! <args> | redraw! | CtrlPQuickfix

function! Tabline()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, "&mod")

    let s .= '%' . tab . 'T'
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . tab .':'
    let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . '] ' : '[No Name] ')

    if bufmodified
      let s .= '[+] '
    endif
  endfor

  let s .= '%#TabLineFill#'
  if (exists("g:tablineclosebutton"))
    let s .= '%=%999XX'
  endif
  return s
endfunction
function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

function! s:source_file(path)
  execute 'source' fnameescape(expand('~/.vim/rt/' . a:path))
endfunction

function! s:expand_commit_template() abort
    let context = {
        \ 'MY_BRANCH': matchstr(system('git rev-parse --abbrev-ref HEAD'), '\p\+'),
        \ }

    let lnum = nextnonblank(1)
    while lnum && lnum < line('$')
      call setline(lnum, substitute(getline(lnum), '\${\(\w\+\)}',
            \ '\=get(context, submatch(1), submatch(0))', 'g'))
      let lnum = nextnonblank(lnum + 1)
    endwhile
endfunction

command! Todo Grepper -tool git -query -E '(TODO|FIXME|XXX)'
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()

command! -bang -nargs=* MemoSearch
\ call fzf#vim#grep(
\   'rg --column --line-number --no-heading --color=always --smart-case -- . ~/memos', 1,
\   fzf#vim#with_preview(), <bang>0)

function! ExtSearch()
    let searchterm = expand("<cword>")
    let my_filetype = &ft
    let command = "a-lang-search \"".my_filetype."\" \"".searchterm."\""
    call job_start(command)
endfunction

function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

function! s:init_fern() abort
  " Use 'select' instead of 'edit' for default 'open' action
  " nmap <buffer> <right> <Plug>(fern-action-open:select)
  nmap <buffer> l <Plug>(fern-action-expand)
  " nmap <buffer> <left> <Plug>(fern-action-collapse)
endfunction

" vim-tbone sends keys to pane to execute query
function! ColsTest(target)
  if empty(a:target)
    throw 'Wymagany cel w postaci panelu'
  endif

  let f=expand('<cfile>')

  try
    let pane_id=tbone#send_keys(a:target, "\\o cols.out.txt\;\rselect text from cols_tests where schema_table = '".f."'\;\rselect text from col_tests where schema_table = '".f."'\;\r\\o\r")
    echo 'Zapytanie uruchomione w '.a:target
    return ''
  catch /.*/
    return 'echoerr '.string(v:exception)
  endtry

  redraw!
endfunc

command! -bar -bang -nargs=* -range -complete=custom,tbone#complete_panes ColsTest
  \ execute ColsTest(<f-args>)

function! PrivTest(target)
  if empty(a:target)
    throw 'Wymagany cel w postaci panelu'
  endif

  let f=expand('<cfile>')

  try
    let pane_id=tbone#send_keys(a:target, "\\o privs.out.txt\;\rselect txt from a_privs_test where grantee = '".f."'\;\r\\o\r")
    echo 'Zapytanie uruchomione w '.a:target
    return ''
  catch /.*/
    return 'echoerr '.string(v:exception)
  endtry

  redraw!
endfunc

command! -bar -bang -nargs=* -range -complete=custom,tbone#complete_panes PrivTest
  \ execute PrivTest(<f-args>)

function! Dplus(target)
  if empty(a:target)
    throw 'Wymagany cel w postaci panelu'
  endif

  let f=expand('<cfile>')

  try
    let pane_id=tbone#send_keys(a:target, "\\d+ ".f."\;\r")
    echo 'Zapytanie uruchomione w '.a:target
    return ''
  catch /.*/
    return 'echoerr '.string(v:exception)
  endtry

  redraw!
endfunc

function! ToggleConcealLevel()
    if &conceallevel == 0
        setlocal conceallevel=2
    else
        setlocal conceallevel=0
    endif
endfunction

command! -bar -bang -nargs=* -range -complete=custom,tbone#complete_panes Dplus
  \ execute Dplus(<f-args>)

function! s:toggle_quickfix_window()
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    copen
    setlocal nowrap
    setlocal whichwrap=b,s
  endif
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=NONE
  highlight fzf2 ctermfg=23 ctermbg=NONE
  highlight fzf3 ctermfg=237 ctermbg=NONE
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! CtrlPWithSearchText(search_text, ctrlp_command_end)
    execute ':CtrlP' . a:ctrlp_command_end
    call feedkeys(a:search_text)
endfunction

function! NewFileInCurrentDir()
  let name = input('Utwórz plik w aktualnym katalogu: ', expand('%'), 'file')
  exec ':e ' . name
  redraw!
endfunction

function! s:GrepRename(expr1, expr2) abort " replace through whole project
  execute 'tabe | lvimgrep /\C\<' . a:expr1 . '\>/j ** | ldo s/\C\<' . a:expr1 . '\>/' . a:expr2 . '/gc | update'
  quit
endfunction

function! s:FillLine(str, ...) abort " fill line with characters to given column
  let to_column = get(a:, 1, &tw)
  let reps = (to_column - col("$")) / len(a:str)
  if reps > 0
    .s/$/\=(' '.repeat(a:str, reps))/
  endif
endfunction

function! MyFoldText() abort
  let text = getline(v:foldstart)
  let text = substitute(text, '^\s*', '', '')
  let text = substitute(text, split(&l:fmr, ',')[0] . '\d\=', '', 'g')
  return "+-" . v:folddashes . " "
        \ . printf("%3d", v:foldend - v:foldstart + 1) . " lines: "
        \ . text
endfunction

function! RenameVar(old, ...) abort
  let newName = input( a:old . " -> ", get(a:, 1, a:old))
  if !empty(newName)
    execute "%s/\\C\\<" . a:old . "\\>/" . newName . "/g"
  endif
endfunction

function! s:VisSort(isnmbr) range abort " sorts based on visual-block selected portion of the lines
  if visualmode() != "\<c-v>"
    execute "silent! ".a:firstline.",".a:lastline."sort i"
    return
  endif
  let firstline = line("'<")
  let lastline  = line("'>")
  let keeprega  = @a
  silent normal! gv"ay
  '<,'>s/^/@@@/
  silent! keepjumps normal! '<0"aP
  if a:isnmbr
    silent! '<,'>s/^\s\+/\=substitute(submatch(0),' ','0','g')/
  endif
  execute "sil! keepj '<,'>sort i"
  execute "sil! keepj ".firstline.",".lastline.'s/^.\{-}@@@//'
  let @a = keeprega
endfun

function! s:VSetSearch(cmdtype) abort " search for selected text, forwards or backwards
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" FOR STATUS LINE {{{

function! FileEncoding() abort
  return (&fenc == "" ? &enc : &fenc).((exists("+bomb") && &bomb) ? " BOM" : "")
endfunction

function! FileSize() abort
  let bytes = getfsize(expand(@%))
  if (bytes >= 1024*1024)
    return printf('~%.1f MiB', bytes/(1024*1024.0))
  elseif (bytes >= 1024)
    return printf('~%.1f KiB', bytes/1024.0)
  elseif (bytes <= 0)
    return '0 B'
  else
    return bytes . ' B'
  endif
endfunction

function! IssuesCount() abort
  if get(g:, 'ale_enabled', 0)
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors
    return "*".all_errors."E ".all_non_errors."w*"
  else
    return "*".len(filter(getqflist(), 'v:val.valid'))." issues*"
  endif
endfunction

function! ModifBufs() abort
  let cnt = len(filter(getbufinfo(), 'v:val.changed'))
  return cnt == 0 ? "" : ( &mod ? "[+". (cnt>1?cnt:"") ."]" : "[".cnt."]" )
endfunction

function! NumOfBufs() abort
  let num = len(getbufinfo({'buflisted':1}))
  let hid = len(filter(getbufinfo({'buflisted':1}), 'empty(v:val.windows)'))
  return hid ? num-hid."+".hid : num
endfunction

" }}}

" MAPPINGS {{{1
" Normal mode {{{2
" nnoremap ' `
" nnoremap '' ``
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l
" nnoremap <expr> <F4> &virtualedit == "all" ? ":set virtualedit=\<CR>" : ":set virtualedit=all\<CR>"
" nnoremap <F3> :set cursorline! cursorcolumn!<CR>
" nnoremap <Leader><F5> :syntax sync fromstart<CR>
" nnoremap <Leader>= gg=G``
" nnoremap <Leader>b :bnext<CR>
" nnoremap <Leader>h :nohlsearch<CR>
" nnoremap <Leader>q m"gggqG`"
" nnoremap <Leader>R :call RenameVar(expand('<cword>'))<CR>
" nnoremap <Leader>r :call RenameVar(expand('<cword>'), "")<CR>
" nnoremap <M-S-a> :copen<CR>
" nnoremap <silent> <expr> <F5> g:colors_name == "darkness" ? ":syntax reset <bar> let g:colors_name=''\<CR>" : ":colo darkness\<CR>"
" nnoremap gx :call job_start('xdg-open '.expand("<cfile>"))<CR>
" nnoremap j gj
" nnoremap k gk

" Toggle hlsearch with <leader>hs
nmap <leader>hs :set hlsearch! hlsearch?<CR>

" use :w!! to write to a file using sudo if you forgot to 'sudo vim file'
" (it will prompt for sudo password when writing)
cmap w!! %!sudo tee > /dev/null %

" Toggle paste mode
nmap <silent> <F2> :set invpaste<CR>:set paste?<CR>
imap <silent> <F2> <ESC>:set invpaste<CR>:set paste?<CR>

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" coffescript compile
" vmap <leader>c <esc>:'<,'>:CoffeeCompile<CR>
" map <leader>c :CoffeeCompile<CR>
" command -nargs=1 C CoffeeCompile | :<args>

" Insert mode {{{2
inoremap <expr> <C-o> pumvisible() ? "\<C-n>" : "\<C-o>"

" Terminal mode {{{2
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
tnoremap <silent> <C-\><C-\> <C-\><C-n>
tnoremap <silent> <C-\><C-m> <C-\><C-n>:let b:auto_insert = 1 - b:auto_insert<CR>

" Visual mode {{{2
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-r>=@/<CR><CR>
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-r>=@/<CR><CR>
vnoremap <Leader>s y:%s//g<Left><Left><C-r>"/

" ### DISABLE {{{2
map <Esc>[29~ <nop>
map gh <nop>
nmap s <nop>
vmap s <nop>

" # custom {{{2
" MAPPINGS
nmap <M-a> <Plug>(ale_detail)
nmap <silent> <leader>at :ALEToggle<cr>
nmap <silent> <leader>aj :ALENext<cr>
nmap <silent> <leader>ak :ALEPrevious<cr>
nmap <leader>nn :set nu!<CR>
nmap <leader>nr :set relativenumber<CR>
nmap <leader>ns :set norelativenumber<CR>
nmap gu :silent exec "!open <cWORD>"<cr>
nnoremap <Leader>t :Tagbar<CR>

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>F :Files %:p:h<CR>
nnoremap <F1> :FZF -q <cfile><CR>
nnoremap <F3> :JsFileImport<CR>
nnoremap <F4> :Prettier<CR>
nnoremap <F5> :Fern %:h -drawer -toggle<CR>
nnoremap <silent> <leader>M :History<CR>
nnoremap <silent> <leader>t :Tags<CR>
nnoremap <silent> <leader>T :Tags <c-r><c-w><CR>
nnoremap <silent> <c-]> :Tags <c-r><c-w><CR>
nnoremap <silent> <leader>o :BTags<CR><tab>
nnoremap <silent> <leader>O :BTags <c-r><c-w><CR>
nnoremap K :GrepperRg <C-R><C-W><CR>
nnoremap <silent> <leader>b :Buffer<cr>
nmap <leader>x :call <SID>SynStack()<CR>

nnoremap <C-N> :tabn<cr>
nnoremap <C-P> :tabp<cr>

" a'ka zoom
nmap <leader>zi <C-w>\|<c-w>_
nmap <leader>zo <C-w>=
nmap <leader>zd <C-w>T

nmap <leader>zz <Plug>Zeavim
vmap <leader>zz <Plug>ZVVisSelection
nmap <leader>gz <Plug>ZVKeyDocset
nmap gZ <Plug>ZVKeyDocset<CR>
nmap gz <Plug>ZVOperator

" map <silent> <leader>c :ColorToggle<CR>
nmap <silent> <leader>ct :HexokinaseToggle<CR>
nmap <silent> <leader>gt :GitGutterSignsToggle<CR>
nmap <silent> <leader>gj <Plug>(GitGutterNextHunk)
nmap <silent> <leader>gk <Plug>(GitGutterPrevHunk)
" map <Leader>rc :call RunCurrentSpecFile()<CR>
map <Leader>rn :call RunNearestSpec()<CR>
map <Leader>rl :call RunLastSpec()<CR>
map <Leader>ra :call RunAllSpecs()<CR>
map <silent> <leader>ss :cexpr [] \| :cg rspec_quickfix.out <CR><cr>
map <leader>N :call NewFileInCurrentDir()<cr>
" Disable Ex mode
map Q <Nop>
" Disable K looking stuff up
map K <Nop>
" addon to browse buffers
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bpnext<CR>
nnoremap <silent> [B :bpfirst<CR>
nnoremap <silent> ]B :bplast<CR>
" Useful save mappings.
nnoremap <silent> <Leader><Leader> :<C-u>update<CR>
" Delete windows ^M codes.
nnoremap <silent> [Space]<C-m> mmHmt:<C-u>%s/\r$//ge<CR>'tzt'm
" Delete spaces before newline.
nnoremap <silent> [Space]ss mmHmt:<C-u>%s/<Space>$//ge<CR>`tzt`m
" Insert blank line.
nnoremap <silent> [Alt]o o<Space><BS><ESC>
nnoremap <silent> [Alt] <Space><BS><ESC>
" Yank to end line.
nnoremap [Alt]y y$
nnoremap Y y$
nnoremap x "_x

" OPTIONS {{{1

set backup
set colorcolumn=+1,+21
"set complete+=kspell
set foldtext=MyFoldText()
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set linebreak
set showbreak=>\
set breakat=\ \ ;:,!?
set list
set listchars=tab:▸\ ,trail:-,extends:»,precedes:«,nbsp:%
set modeline
set mouse=n
set nomodelineexpr
set nowrap
set number
set scrolloff=5
set sessionoptions=blank,buffers,folds,tabpages,winsize
set shortmess+=I
" m use "[+]" instead of "[Modified]"
set shortmess+=m
" Display search counts
set shortmess-=S
set showcmd
set showmatch
set smartcase
set splitbelow
set splitright
set switchbuf=usetab
set title
set titlelen=95
" set titlestring=%{hostname()}\ \ %F\ \ %{strftime('%Y-%m-%d\ %H:%M',getftime(expand('%')))}
set titlestring=%F
set suffixesadd=.css,.sass,.rb,.haml,.html,.js,.jsx,.json
set undofile
set wildmenu
set wildmode=list:longest,full
set whichwrap+=h,l,<,>,[,],b,s,~
set wildignore+=*/tmp/*,*.hg*,*.so,*.zip,*.class,*.pyc,*.rar
set wildignore+=*.png,*.jpg,*.otf,*.woff,*.jpeg,*.orig,*.gif,*.ico,*.bmp
set wildignore+=*.git
set wildignore+=*~,*.swp,*.tmp
set wildignore+=*node_modules/**
set iskeyword+=-
set cmdheight=1
" Don't create backup.
set nowritebackup
set nobackup
set noswapfile
" Searches wrap around the end of the file.
set wrapscan
" Disable bell.
set t_vb=
set novisualbell
" Increase history amount.
set history=1000
" Display all the information of the tag by the supplement of the Insert mode.
set showfulltag
" Can supplement a tag in a command-line.
set wildoptions=tagfile
set pumheight=10
" Report changes.
set report=0
" Maintain a current line at the time of movement as much as possible.
set nostartofline
" Splitting a window will put the new window below the current one.
set splitbelow
" Splitting a window will put the new window right the current one.
set splitright
" Set minimal width for current window.
set winwidth=79
" Set minimal height for current window.
" set winheight=20
set winheight=1
" Set maximam maximam command line window.
set cmdwinheight=5
" No equal window size.
set noequalalways
" Adjust window size of preview and help.
set previewheight=8
set helpheight=12
" Don't redraw while macro executing.
set lazyredraw
set ttyfast
" When a line is long, do not omit it in @.
set display=lastline
set errorformat+=%f:%l
" Enable smart indent.
set autoindent smartindent
set timeoutlen=300
" fix for slow gitgutter
set updatetime=100

set t_Co=256
set termguicolors

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://sunaku.github.io/vim-256color-bce.html
  set t_ut=
endif

if has('unnamedplus')
  set clipboard& clipboard+=unnamedplus
else
  set clipboard& clipboard+=unnamed
endif

" set viminfo=%,<800,'10,/50,:100,h,f100,n~/.vim/cache/viminfo
"           | |    |   |   |    | |  + viminfo file path
"           | |    |   |   |    | + file marks 0-9,A-Z 0=NOT stored
"           | |    |   |   |    + disable 'hlsearch' loading viminfo
"           | |    |   |   + command-line history saved
"           | |    |   + search history saved
"           | |    + files marks saved
"           | + lines saved each register (old name for <, vi6.2)
"           + save/restore buffer list
set viminfo=<800,'10,/50,:100,h,f100,n~/.vim/cache/viminfo
"           |    |   |   |    | |  + viminfo file path
"           |    |   |   |    | + file marks 0-9,A-Z 0=NOT stored
"           |    |   |   |    + disable 'hlsearch' loading viminfo
"           |    |   |   + command-line history saved
"           |    |   + search history saved
"           |    + files marks saved
"           + lines saved each register (old name for <, vi6.2)

set completeopt=noinsert,menuone,noselect,preview,popup
set completepopup=height:10,width:60,highlight:InfoPopup
set omnifunc=syntaxcomplete#Complete
set pumheight=20

" Set default encoding to UTF-8
set encoding=utf-8
set termencoding=utf-8
set fileencodings^=utf-8

let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

set foldmethod=indent
set nofoldenable

" set dictionary+=/usr/share/dict/polish
" set dictionary+=/usr/share/dict/words
set dictionary+=./dict.txt
set dictionary+=./tach.dict.txt
au FileType * execute 'setlocal dict+=~/.vimjapet/'.&filetype.'.dict.txt'

set path=**,./
set tags+=.git/tags;
set tags+=./tags;


" PLUGINS AND PACKAGES {{{1
" specjalnie, wymaga tego polyglot
let g:polyglot_disabled = ['markdown'] " for vim-polyglot users, it loads Plasticboy's markdown
                                       " plugin which unfortunately interferes with mkdx list indentation.

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'Jorengarenar/fauxClip'
Plug 'Jorengarenar/miniSnip'
Plug 'Jorengarenar/vim-sBnR'
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree'
Plug 'prabirshrestha/vim-lsp'
Plug 'puremourning/vimspector'

Plug 'Jorengarenar/vim-darkness'
Plug 'Konfekt/FastFold'
Plug 'Jorengarenar/vim-MvVis'
" Plug 'Jorengarenar/vim-SQL-UPPER'
Plug 'Jorengarenar/vim-syntaxMarkerFold'

Plug 'junegunn/vim-easy-align'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'

" Like snippets
Plug 'mattn/emmet-vim'
" Prertty and validated
Plug 'dense-analysis/ale'
Plug 'prettier/vim-prettier'

Plug 'Jorengarenar/miniSnip'
Plug 'lifepillar/vim-mucomplete'
Plug '~/.vim/plugins/vim-mucomplete-minisnip'
Plug 'lifepillar/vim-gruvbox8'

" file type
Plug 'elzr/vim-json'
Plug 'leafgarland/typescript-vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ruby-formatter/rufo-vim'

" użytkowe
Plug 'tpope/vim-characterize'
" Plug 'tpope/vim-commentary'
Plug 'tyru/caw.vim'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-git'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-tbone'
Plug 'godlygeek/tabular'
" Plug 'vim-latex/vim-latex'
Plug 'lervag/vimtex'
Plug 'romainl/vim-qf'

Plug 'adelarsq/vim-matchit'

Plug 'sheerun/vim-polyglot'
Plug 'kristijanhusak/vim-js-file-import', {'do': 'npm install'}

Plug 'lifepillar/pgsql.vim'
Plug 'shushcat/vim-minimd'

Plug 'vim-scripts/dbext.vim'

Plug 'dag/vim-fish'
Plug 'terryma/vim-expand-region'

Plug 'wincent/pinnacle'

" Plug 'tpope/vim-rails'
" Plug 'tpope/vim-rake'
" Plug 'tpope/vim-rbenv'
" Plug 'tpope/rbenv-ctags'
Plug 'tpope/vim-dispatch'
Plug 'ecomba/vim-ruby-refactoring'
" Plug 'chrisbra/Colorizer'
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-line'
Plug 'rbonvall/vim-textobj-latex'
Plug 'tek/vim-textobj-ruby'
Plug 'justinj/vim-textobj-reactprop'
Plug 'kana/vim-textobj-function'
Plug 'thinca/vim-textobj-function-javascript'
Plug 'glidenote/memolist.vim'
Plug 'ramele/agrep'
Plug 'mhinz/vim-grepper'
Plug 'nightsense/carbonized'
Plug 'morhetz/gruvbox'
Plug 'junegunn/goyo.vim'

Plug 'cakebaker/scss-syntax.vim'
Plug 'vim-scripts/nginx.vim'
" Plug 'tpope/vim-cucumber'
" Plug 'tpope/vim-haml'
Plug 'thoughtbot/vim-rspec'
Plug 'rlue/vim-fold-rspec'
" Plug 'tpope/vim-rvm'
Plug 'vim-ruby/vim-ruby'
Plug 'sunaku/vim-ruby-minitest'
" Plug 'tpope/vim-bundler'
Plug 'tpope/vim-endwise'

Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-mapping-project-top.vim'
Plug 'lambdalisue/fern-bookmark.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'ryanoasis/vim-devicons'

Plug 'pearofducks/ansible-vim'
Plug 'stephpy/vim-yaml'
Plug 'ekalinin/Dockerfile.vim'
Plug 'sakshamgupta05/vim-todo-highlight'

" Plug 'dhruvasagar/vim-zoom'

Plug 'kristijanhusak/vim-js-file-import'
Plug 'https://gitlab.com/neonunux/vim-open-or-create-path-and-file.git'

Plug 'KabbAmine/zeavim.vim'
Plug 'kkoomen/vim-doge'
Plug 'algotech/ultisnips-php'

Plug 'kristijanhusak/vim-simple-notifications'
Plug 'triglav/vim-visual-increment'

call plug#end()

packadd cfilter
packadd matchit
packadd termdebug
runtime ftplugin/man.vim
source  $VIMRUNTIME/ftplugin/man.vim

" q: Quickfix  "{{{
" The prefix key.
nnoremap [Quickfix]   <Nop>
" Toggle quickfix window.
nnoremap <silent> [Quickfix]<Space>
      \ :<C-u>call <SID>toggle_quickfix_window()<CR>
" Disable ZZ.
nnoremap ZZ  <Nop>
" copy line to * register
" map <leader>y "*y
vmap <F2> "+y
vmap <leader>y "+y
vmap <leader>d "+d
nmap <leader>p "+p
nmap <leader>P "+P
vmap <leader>p "+p
vmap <leader>P "+P
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>
imap <c-b> binding.pry
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
" ARROW KEYS ARE UNACCEPTABLE
map <left> <nop>
map <right> <nop>
map <up> <nop>
map <down> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
" Insert a UUID with Ruby
nnoremap ruid :read !ruby -e "require 'securerandom'; print SecureRandom.uuid"<cr>
nnoremap <silent> <C-c><C-y> :call ToggleConcealLevel()<CR>

nmap <silent>sa <Plug>(operator-surround-append)
nmap <silent>sd <Plug>(operator-surround-delete)
nmap <silent>sr <Plug>(operator-surround-replace)
map <leader>th <C-w>t<C-w>H
map <leader>tk <C-w>t<C-w>K

nnoremap <C-h> :TmuxNavigateLeft<cr>
nnoremap <C-j> :TmuxNavigateDown<cr>
nnoremap <C-k> :TmuxNavigateUp<cr>
nnoremap <C-l> :TmuxNavigateRight<cr>
nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

" noremap <silent> <C-Left> :vertical resize +3<cr>
" noremap <silent> <C-Right> :vertical resize -3<cr>
" noremap <silent> <C-Up> :resize +3<cr>
" noremap <silent> <C-Down> :resize -3<cr>

map <leader>q :call ExtSearch()<cr><cr>
nnoremap <leader>hr :HighlightRepeats<cr>
nnoremap <leader>hc :exe 'syn clear Repeat'<cr>
nnoremap <silent> <Leader>mn  :MemoNew<CR>
" nnoremap <Leader>ml  :MemoList<CR>
" nnoremap <Leader>ml  :CtrlPMemolist<CR>
nnoremap <silent> <leader>ml :Files ~/memos<cr>
nnoremap <silent> <Leader>mg :MemoGrep<CR>

" OPTIONS
let $PAGER=''
let g:ale_disable_lsp                = 1
let g:ale_echo_msg_format            = '[%linter%]: %s'
let g:ale_enabled                    = 0
let g:ale_set_loclist                = 0
let g:ale_set_quickfix               = 1
let g:ale_set_signs                  = 0
let g:ale_sign_warning = ''
let g:ale_sign_error = ''
let g:ale_sql_sqlint_command = 'bundle exec sqlint'
let g:ale_sql_sqlint_use_global = 1
let g:ctrlp_brief_prompt             = 1
let g:ctrlp_clear_cache_on_exit      = 0
let g:ctrlp_extensions               = [ 'buffertag', 'quickfix' ]
let g:ctrlp_prompt_mappings          = { 'PrtExit()': [ '<C-[>', '<Esc>', '<C-c>' ] }
let g:ctrlp_types                    = [ 'fil' ]
let g:ctrlp_cache_dir                = $XDG_CACHE_DIR . "/vim/ctrlp"
let g:fastfold_fold_command_suffixes = [ 'C', 'm', 'M', 'N', 'x', 'X' ]
let g:fastfold_minlines              = 0
let g:fastfold_savehook              = 0
let g:tagbar_compact                 = 1
let g:tagbar_sort                    = 0
let g:undotree_SetFocusWhenToggle    = 1
let g:vimspector_base_dir            = expand('$XDG_CONFIG_HOME/vimspector')
let g:vimspector_install_gadgets     = [ 'debugpy', 'vscode-cpptools' ]
let g:gitgutter_sign_added = '▍'
let g:gitgutter_sign_modified = '▍'
let g:gitgutter_sign_removed = '▍'
let g:gitgutter_sign_removed_first_line = '▍'
let g:gitgutter_sign_modified_removed = '▍'
let g:gitgutter_signs = 0
let g:Hexokinase_ftEnabled = []
let g:Hexokinase_highlighters = ['backgroundfull']
let g:Hexokinase_refreshEvents = ['TextChanged', 'InsertLeave']
let g:user_emmet_settings = {
      \  'javascript.jsx' : {
      \      'extends': 'jsx',
      \      'quote_char': "'",
      \  },
      \}
let g:user_emmet_leader_key=','

let g:miniSnip_trigger = '<c-s>'
let g:miniSnip_extends = {
      \ "arduino"  : [ "cpp", "c" ],
      \ "cpp"      : [ "c" ],
      \ "markdown" : [ "html" ],
      \ "tex"      : [ "plaintex" ],
      \ }
let g:fzf_commits_log_options = '--color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'qtags'
let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_preview_window = ''
let g:Lf_StlColorscheme = 'gruvbox'
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
let g:Lf_NoChdir = 1
" snippets
let g:mucomplete#enable_auto_at_startup = 1
" let g:miniSnip_dirs = ['~/.vimjapet/other_addons/miniSnip']
let mucomplete#user_mappings = {'minisnips': "\<C-r>=mucomplete#minisnips#complete()\<CR>"}
let g:mucomplete#chains = { 'default': ['minisnips', 'tags', 'dict', 'omni', 'keyn'], 'vim': ['path', 'cmd', 'keyn'] }
let g:mucomplete#no_mappings = 1
let g:no_plugin_maps = 1
let g:mucomplete#minimum_prefix_length = 1
let g:mucomplete#ultisnips#match_at_start = 0
let g:miniSnip_trigger = '<c-s>'
call mucomplete#msg#set_notifications(3)
let g:zv_keep_focus = 0
let g:zv_file_types = {
\   'scss': 'Sass',
\   'sh'  : 'bash',
\   'tex' : 'latex',
\   'yaml.ansible' : 'ansible',
\    '.htaccess'                : 'apache_http_server',
\    '\v^(G|g)runt\.'           : 'gulpvascriptodejs',
\    '\v^(G|g)ulpfile\.'        : 'grunt',
\    '\v^(md|mdown|mkd|mkdn)$'  : 'markdown',
\ }
let g:zv_zeal_args = '--style=gtk+'
" let g:fold_rspec_foldenable = 0          " disables folding (toggle with `zi`)
let g:fold_rspec_foldlevel = 2           " sets initial open/closed state of all folds (open unless nested more than two levels deep)
" let g:fold_rspec_default_foldcolumn = 4  " shows a 4-character column on the lefthand side of the window displaying the document's fold structure
" let g:fold_rspec_foldclose = 'all'       " closes folds automatically when the cursor is moved out of them (only applies to folds deeper than 'foldlevel')
let g:fold_rspec_foldminlines = 3        " disables closing of folds containing two lines or fewer
let g:js_file_import_use_fzf = 1
let g:js_file_import_string_quote = '"'
let g:fern#renderer = "devicons"
let g:memolist_path = expand('~/memos')
let g:memolist_memo_suffix = "md"
let g:mkdx#settings     = { 'highlight': { 'enable': 1 },
                        \ 'enter': { 'shift': 1 },
                        \ 'links': { 'external': { 'enable': 1 } },
                        \ 'toc': { 'text': 'Table of Contents', 'update_on_write': 1 },
                        \ 'fold': { 'enable': 0 },
                        \ 'checkbox': { 'update_tree': 2, 'toggles': [' ', '-', 'x'] }
                        \ }
" let g:vim_markdown_folding_disabled = 1
" let g:vim_markdown_conceal_code_blocks = 0
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_fenced_languages = ['coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'sql', 'pgsql', 'sh', 'html', 'diff', 'fstab', 'nginx', 'crontab', 'fish']
let g:sql_type_default = 'pgsql'
let g:pgsql_pl = ['python']
let g:dbext_default_profile_postgres_local = 'type=PGSQL:user=postgres:passwd='':dbname=postgres:bin_path=/usr/bin/'
let g:ansible_unindent_after_newline = 1
let g:ansible_yamlKeyName = 'yamlKey'
" Ansible modules use a key=value format for specifying module-attributes in playbooks. This highlights those as specified. This highlight option is also used when highlighting key/value pairs in hosts files.
" Available flags (bold are defaults):

" a: highlight all instances of key=
" o: highlight only instances of key= found on newlines
" d: dim the instances of key= found
" b: brighten the instances of key= found
" n: turn this highlight off completely
let g:ansible_attribute_highlight = "ob"
let g:ansible_name_highlight = 'ob'
let g:ansible_extra_keywords_highlight = 1
" let g:ansible_normal_keywords_highlight = 'Comment'
" let g:ansible_with_keywords_highlight = 'Constant'
let g:ansible_template_syntaxes = {
      \ '*.rb.j2': 'ruby',
      \ '*.sh.j2': 'bash'
      \ }
let g:todo_highlight_config = {
      \   'REVIEW': {
      \     'gui_fg_color': '#000000',
      \     'gui_bg_color': '#ffbd2f',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   },
      \   'TODO': {
      \     'gui_fg_color': '#000000',
      \     'gui_bg_color': '#a3be8c',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   },
      \   'INFO': {
      \     'gui_fg_color': '#ffffff',
      \     'gui_bg_color': '#20639B',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   },
      \   'WARNING': {
      \     'gui_fg_color': '#000000',
      \     'gui_bg_color': '#bf616a',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   },
      \   'FIXME': {
      \     'gui_fg_color': '#000000',
      \     'gui_bg_color': '#bf616a',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   },
      \   'NOTE': {
      \     'gui_fg_color': '#000000',
      \     'gui_bg_color': '#99d1ce',
      \     'cterm_fg_color': 'white',
      \     'cterm_bg_color': '214'
      \   }
      \ }

let g:lightline = {
    \ 'colorscheme': 'gruvbox',
    \ 'component_function': {
    \   'gitbranch': 'fugitive#head',
    \ }
    \}

    " \   'left': [ [ 'mode', 'paste' ],
let g:lightline.active = {
    \   'left': [ [ 'mode', 'paste'],
    \             [ 'readonly', 'filename', 'modified', 'helloworld' ] ],
    \   'right': [ [ 'lineinfo' ],
    \              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
    \              [ 'percent' ],
    \              [ 'fileformat', 'fileencoding', 'filetype', 'gitbranch' ] ]
    \ }
" \              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]

let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }

let g:lightline.component_type = {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }

" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" textobjects
call textobj#user#plugin('goose', {
\   'code': {
\     'pattern': ['-- +goose StatementBegin\n', '\n-- +goose StatementEnd'],
\     'select-a': 'ag',
\     'select-i': 'ig',
\   },
\ })
let g:indentLine_char = '¦'
let g:indentLine_first_char = '¦'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 1
" https://www.nerdfonts.com/cheat-sheet
" wybieraj hex
let g:lightline#ale#indicator_checking = "\uf252 "
let g:lightline#ale#indicator_warnings = "\uf071 "
let g:lightline#ale#indicator_errors = "\uf05e "
let g:lightline#ale#indicator_ok = "\uf00c "
let g:rspec_command = "!bundle exec rspec {spec}"
let g:loaded_tabline_vim = 1
let g:tablineclosebutton=1

" create or replace view dmx.device_activity as
" create view dmx.device_activity as
" create or replace view device_activity as
" create view device_activity as

call textobj#user#plugin('pgview', {
\   'code': {
\     'pattern': ['create\( or replace\)* view \w*\.*\w* as', ';$'],
\     'select-a': 'av',
\     'select-i': 'iv',
\   },
\ })

call textobj#user#plugin('pgselect', {
\   'code': {
\     'pattern': ['select', ';$'],
\     'select-a': 'ad',
\     'select-i': 'id',
\   },
\ })

hi! link TagbarNestedKind Comment
hi! link TagbarType Comment
hi! ALEError ctermbg=none cterm=underline
hi! ALEWarning ctermbg=none cterm=underline

" STATUS LINE {{{1

set statusline=
set statusline+={%{NumOfBufs()}}       " Number of buffers
set statusline+=\ \                    " Separator
set statusline+=%f                     " Relative path to the file
set statusline+=\ \                    " Separator
set statusline+=%y                     " Filetype
set statusline+=[%{&ff}]               " File format
set statusline+=[%{FileEncoding()}]    " File encoding
set statusline+=\ \                    " Separator
set statusline+=[%{&fo}]               " Format options
set statusline+=\ \                    " Separator
set statusline+=[%{FileSize()}]        " File size
set statusline+=\ \                    " Separator
set statusline+=%r                     " Readonly flag
set statusline+=%{&ma\|\|&ro?'':'[-]'} " No modifiable flag
set statusline+=%w                     " Preview flag
set statusline+=\ \                    " Separator
set statusline+=%{ModifBufs()}         " Modified flag (extended)
set statusline+=%=                     " Switch to the right side
set statusline+=%{IssuesCount()}       " Count of errors, warnings
set statusline+=\ \                    " Separator
set statusline+=<0x%02B>               " Current char hex code
set statusline+=\ \                    " Separator
set statusline+=%l/                    " Current line
set statusline+=%L                     " Total lines
set statusline+=\ \:\ %c\              " Current column

" ### OTHER {{{1

" Trim trailing whitespace
" autocmd BufWritePre * silent! undojoin | %s/\s\+$//e | %s/\(\n\r\?\)\+\%$//e
" from line endings
autocmd BufWritePre * :%s/ \+$//e
" centrowanie przy wejściu w insert
autocmd InsertEnter * norm zz
" Set 'foldmethod' to 'syntax'
autocmd FileType css,json,typescript,scss setlocal foldmethod=syntax
" Automatically open QuickFix
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
" spell
au BufReadPost,BufNewFile *.tex setlocal spell spelllang=pl
" au BufReadPost,BufNewFile *.md setlocal spell spelllang=pl
au FileType gitcommit setlocal spell spelllang=en
au FileType mail setlocal spell spelllang=pl

autocmd! User FzfStatusLine call <SID>fzf_statusline()

autocmd BufNewFile,BufRead *.todo :set filetype=todo

autocmd BufRead */.git/COMMIT_EDITMSG call s:expand_commit_template()

autocmd FileType sql setlocal ft=pgsql
" komentarz do sql używany w tpope commentary
autocmd FileType pgsql setlocal commentstring=--\ %s
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

"" css folding
"autocmd BufNewFile,BufRead *.css set fdm=marker fmr={,}

" augroup OTHER
"   autocmd!
"   " Open file at the last known position
"   " autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exec "norm! g`\"" | endif
"
"   " " clear spaces from line endings
"   " autocmd BufWritePre * :%s/\s\+$//e
"
"   " Undo if filter shell command returned an error
"   " autocmd ShellFilterPost * if v:shell_error | undo | endif
"
"   " If file has more lines than window height, then fold it
"   " autocmd BufReadPost * if line('$') > winheight(0) | setlocal fen | endif
"
"   "" associate *.cls with tex filetype
"   "au BufRead,BufNewFile *.cls set filetype=tex
" augroup END

" augroup TERMINAL_OPTIONS
"   autocmd!
"
"   execute 'autocmd '.(has("nvim") ? "TermOpen" : "TerminalOpen").' *
"         \ let b:auto_insert = 1 | setlocal nonu stl=%f |
"         \ au WinEnter <buffer> if b:auto_insert | sil! norm! i | endif'
" augroup END

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END

runtime! vimrc.d/*.vim

if filereadable("_vimrc")
  source _vimrc
endif

" call s:source_file('statusline.vim')

set secure exrc
