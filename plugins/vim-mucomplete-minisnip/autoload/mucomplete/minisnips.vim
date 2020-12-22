let s:save_cpo = &cpo
set cpo&vim

let s:cmp = 'stridx(v:val, l:pat) >= 0'
" let s:cmp = 'stridx(v:val, l:pat)' . (get(g:, 'mucomplete#ultisnips#match_at_start', 1) ? '==0' : '>=0')

function! mucomplete#minisnips#candidates() abort
  let l:global_snippets = []
  let l:filetype_snippets = []

  for l:dir in g:miniSnip_dirs
    let l:global_snippets = l:global_snippets + map(glob(l:dir . '/all/[^_]*', v:false, v:true),
          \ {key, val -> substitute(fnamemodify(val, ':t'), '.snip$', '', '')})
    " call notifications#info(l:global_snippets)

    let l:filetype_snippets = l:filetype_snippets + map(glob(l:dir . '/' . &filetype . '/*', v:false, v:true),
          \ {key, val -> substitute(substitute(fnamemodify(val, ':t'), '^_' . &filetype . '_', '', ''), '.snip$', '', '')})
    " call notifications#info([l:dir . '/' . &filetype . '/*'])
  endfor

  return l:global_snippets + l:filetype_snippets
endfunction

function! mucomplete#minisnips#complete() abort
  let l:pat = matchstr(getline('.'), '\S\+\%' . col('.') . 'c')
  if len(l:pat) < 1
    return ''
  endif
  if !exists('b:snippet_candidates')
    let b:snippet_candidates = mucomplete#minisnips#candidates()
  endif
  let l:candidates = map(filter(copy(b:snippet_candidates), s:cmp),
        \ '{
        \      "word": v:val,
        \      "menu": "[minis] " . v:val,
        \      "dup": 1
        \ }')
  if !empty(l:candidates)
    call complete(col('.') - len(l:pat), l:candidates)
  endif
  return ''
endfunction

" fun! mucomplete#minisnips#do_expand(keys)
"   call notifications#info([v:completed_item])
"   if get(v:completed_item, 'menu', '') =~# '[minis]'
"     return miniSnip#trigger()
"   endif
"   return a:keys
" endf
"
" fun! mucomplete#minisnips#expand_snippet(keys)
"   return pumvisible()
"        \ ? "\<c-y>\<c-r>=mucomplete#minisnips#do_expand('')\<cr>"
"        \ : a:keys
" endf

let &cpo = s:save_cpo
unlet s:save_cpo
