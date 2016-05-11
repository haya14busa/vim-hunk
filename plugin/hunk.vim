"=============================================================================
" FILE: plugin/hunk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_hunk
endif
if exists('g:loaded_hunk')
  finish
endif
let g:loaded_hunk = 1
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -complete=customlist,hunk#loclist_complete HunkLoclist call hunk#loclist(winnr(), <q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
