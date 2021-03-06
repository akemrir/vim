scriptencoding utf-8
let s:cache = {'branch': ''}

 let g:currentmode={
     \ 'tags' : 'TAG',
     \ 'buffer keywords' : 'BUF·K',
     \ 'dictionary' : 'DICT·F'
     \}

fun! MU()
  return get(g:,'mucomplete_current_method','')
endf

augroup custom_statusline
  autocmd!
  autocmd VimEnter * silent! call fugitive#detect(expand('<afile>'))
  autocmd BufEnter,WinEnter * setlocal statusline=%!Statusline()
  autocmd BufLeave,WinLeave * setlocal statusline=%f\ %y\ %m
  autocmd VimEnter,BufEnter * if exists('*fugitive#head') | let s:cache.branch = fugitive#head() | endif
  autocmd User FugitiveChanged let s:cache.branch = fugitive#head()
  autocmd VimEnter,ColorScheme * call s:set_statusline_colors()
augroup END

function! s:set_statusline_colors() abort
  let s:normal_bg = synIDattr(hlID('Normal'), 'bg')
  let s:normal_fg = synIDattr(hlID('Normal'), 'fg')
  let s:warning_fg = synIDattr(hlID('WarningMsg'), 'fg')
  let s:error_fg = synIDattr(hlID('ErrorMsg'), 'fg')

  silent! exe 'hi StItem guibg='.s:normal_bg.' guifg='.s:normal_fg.' gui=NONE'
  silent! exe 'hi StSep guifg='.s:normal_fg.' guibg=NONE gui=NONE'
  silent! exe 'hi StErr guibg='.s:error_bg.' guifg='.s:normal_fg.' gui=bold'
  silent! exe 'hi StErrSep guifg='.s:error_fg.' guibg=NONE gui=NONE'
  silent! exe 'hi StWarn guibg='.s:warning_fg.' guifg='.s:normal_fg.' gui=bold'
  silent! exe 'hi StWarnSep guifg='.s:warning_fg.' guibg=NONE gui=NONE'

  silent! exe 'hi Statusline guifg='.s:normal_fg.' guibg=NONE gui=NONE cterm=NONE'
  silent! exe 'hi StatuslineNC guifg='.s:normal_fg.' guibg=NONE gui=NONE cterm=NONE'
endfunction

function! s:sep(item, ...) abort
  let l:opts = get(a:, '1', {})
  let l:before = get(l:opts, 'before', '')
  let l:sep_color = get(l:opts, 'sep_color', '%#StSep#')
  let l:color = get(l:opts, 'color', '%#StItem#')

  " return l:before.l:sep_color.''.l:color.a:item.l:sep_color.'%*'
  return l:before.l:sep_color.''.l:color.' '.a:item.' '.l:sep_color.'%*'
endfunction

function! s:sep_if(item, condition, ...) abort
  if !a:condition
    return ''
  endif
  let l:opts = get(a:, '1', {})
  return s:sep(a:item, l:opts)
endfunction

let s:st_err = {'color': '%#StErr#', 'sep_color': '%#StErrSep#'}
let s:st_warn = {'color': '%#StWarn#', 'sep_color': '%#StWarnSep#'}
let s:st_mode = {'color': '%#StMode#', 'sep_color': '%#StModeSep#'}

function! Statusline() abort
  let l:mode = s:mode_statusline()
  let l:statusline = s:sep(l:mode, extend({'before': ''}, s:st_mode))
  let l:git_status = s:git_statusline()
  let l:statusline .= s:sep_if(l:git_status, !empty(l:git_status))
  " let l:statusline .= s:sep(expand('%:~:.'), &modified ? s:st_err : {})         "File path
  let l:statusline .= s:sep(expand('%:p:t'), &modified ? s:st_err : {})         "File path
  let l:statusline .= s:sep_if('+', &modified, s:st_err)                      "Modified indicator
  let l:statusline .= s:sep('µ' . toupper(get(g:currentmode, MU(), MU())), s:st_mode)
  let l:statusline .= s:sep_if('%w', &previewwindow)                            "Preview indicator
  let l:statusline .= s:sep_if('%r', &readonly)                                 "Read only indicator
  let l:statusline .= s:sep_if('%q', &buftype ==? 'quickfix')                   "Quickfix list indicator
  let l:statusline .= '%='                                                      "Start right side layout
  let l:anzu = exists('*anzu#search_status') ? anzu#search_status() : ''
  let l:statusline .= s:sep_if(l:anzu, !empty(l:anzu))                          "Search status
  let l:ft = &filetype
  let l:statusline .= s:sep_if(l:ft, !empty(l:ft))                              "Filetype
  let l:statusline .= s:sep('%{&expandtab?"spaces":"tabs"}:%{&sw}')            "Are spaces or tabs used for indentation and how much spaces is single indent
  " let l:statusline .= s:sep('col:%c', s:st_mode)                               "Column number
  " let l:statusline .= s:sep('%c/%l/%L:%p%%', s:st_mode)                             "Current line number/Total line numbers
  let l:statusline .= s:sep('%c:%l:%L', s:st_mode)                             "Current line number/Total line numbers
  " let l:statusline .= s:sep('%p%%', s:st_mode)                                  "Percentage
  let l:err = s:ale_status('error')
  let l:warn = s:ale_status('warning')
  let l:statusline .= s:sep_if(l:err, !empty(l:err), s:st_err)
  let l:statusline .= s:sep_if(l:warn, !empty(l:warn), s:st_warn)
  " let l:statusline .= s:sep(zoom#statusline())
  return l:statusline
endfunction


function! s:ale_status(type) abort
  if !exists('g:loaded_ale')
    return ''
  endif

  let l:count = ale#statusline#Count(bufnr(''))
  let l:errors = l:count.error + l:count.style_error
  let l:warnings = l:count.warning + l:count.style_warning

  if a:type ==? 'error' && l:errors
    return printf('%d E', l:errors)
  endif

  if a:type ==? 'warning' && l:warnings
    return printf('%d W', l:warnings)
  endif

  return ''
endfunction

function! s:git_statusline() abort
  if !exists('b:gitgutter')
    return s:cache.branch
  endif
  let [l:added, l:modified, l:removed] = get(b:gitgutter, 'summary', [0, 0, 0])
  let l:result = l:added == 0 ? '' : ' +'.l:added
  let l:result .= l:modified == 0 ? '' : ' ~'.l:modified
  let l:result .= l:removed == 0 ? '' : ' -'.l:removed
  let l:result = join(filter([s:cache.branch, l:result], {-> !empty(v:val) }), '')
  return l:result
endfunction

function! s:mode_statusline() abort
  let l:mode = mode()
  call s:mode_highlight(l:mode)
  let l:modeMap = {
  \ 'n'  : 'N',
  \ 'i'  : 'I',
  \ 'R'  : 'R',
  \ 'v'  : 'V',
  \ 'V'  : 'V-L',
  \ 'c'  : 'C',
  \ '' : 'V-B',
  \ 's'  : 'S',
  \ 'S'  : 'S-L',
  \ '' : 'S-B',
  \ 't'  : 'T',
  \ }

  return get(l:modeMap, l:mode, 'UNKNOWN')
endfunction

function! s:mode_highlight(mode) abort
  if a:mode ==? 'i'
    hi StMode guibg=#83a598 guifg=#3c3836
    hi StModeSep guifg=#83a598 guibg=NONE
  elseif a:mode =~? '\(v\|V\|\)'
    hi StMode guibg=#fe8019 guifg=#3c3836
    hi StModeSep guifg=#fe8019 guibg=NONE
  elseif a:mode ==? 'R'
    hi StMode guibg=#8ec07c guifg=#3c3836
    hi StModeSep guifg=#8ec07c guibg=NONE
  elseif a:mode =~? 'S'
    hi StMode guibg=#D34939 guifg=#3c3836
    hi StModeSep guifg=#D34939 guibg=NONE
  else
    silent! exe 'hi StMode guibg=NONE guifg=#ebdbb2 gui=NONE'
    silent! exe 'hi StModeSep guifg='.s:normal_fg.' guibg=NONE gui=NONE'
  endif
endfunction
