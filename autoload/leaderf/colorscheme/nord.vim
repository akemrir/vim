" ============================================================================
" File:        nord.vim
" Description:
" Author:      Akemrir <akemrir@gmail.com>
" Website:     https://github.com/akemrir
" Note:
" License:     Apache License, Version 2.0
" ============================================================================

let s:palette = {
            \   'stlName': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#6D9CBB',
            \       'cterm': 'bold',
            \       'ctermfg': '22',
            \       'ctermbg': '157'
            \   },
            \   'stlCategory': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#6F7F94',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '210'
            \   },
            \   'stlNameOnlyMode': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#a5c261',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '227'
            \   },
            \   'stlFullPathMode': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#b6b3eb',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '147'
            \   },
            \   'stlFuzzyMode': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#da4939',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '227'
            \   },
            \   'stlRegexMode': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#000000',
            \       'guibg': '#88C0D0',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '121'
            \   },
            \   'stlCwd': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#6F7F94',
            \       'cterm': 'bold',
            \       'ctermfg': '195',
            \       'ctermbg': '241'
            \   },
            \   'stlBlank': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': 'NONE',
            \       'guibg': '#2F343F',
            \       'cterm': 'bold',
            \       'ctermfg': 'NONE',
            \       'ctermbg': '237'
            \   },
            \   'stlLineInfo': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#a5c261',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '195'
            \   },
            \   'stlTotal': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#FCFDFF',
            \       'guibg': '#6D9CBB',
            \       'cterm': 'bold',
            \       'ctermfg': '16',
            \       'ctermbg': '149'
            \   }
            \ }

" highlight Lf_hl_match gui=bold guifg=#88C0D0 guibg=#2F343F cterm=bold ctermfg=21
" highlight Lf_hl_match0 gui=bold guifg=#88C0D0 guibg=#2F343F cterm=bold ctermfg=21
highlight Lf_hl_match gui=underline guifg=#EBCB8B guibg=#2F343F cterm=bold ctermfg=21
highlight Lf_hl_match0 gui=underline guifg=#EBCB8B guibg=#2F343F cterm=bold ctermfg=21
" highlight Lf_hl_match gui=underline guibg=#88C0D0 guifg=#2F343F cterm=bold ctermfg=21
" highlight Lf_hl_match0 gui=underline guibg=#88C0D0 guifg=#2F343F cterm=bold ctermfg=21
highlight Lf_hl_matchRefine  gui=bold guifg=#92C261 guibg=#2F343F cterm=bold ctermfg=201

let g:leaderf#colorscheme#nord = leaderf#colorscheme#mergePalette(s:palette)
