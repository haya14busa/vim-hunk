"=============================================================================
" FILE: autoload/unite/kinds/hunk/line.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#hunk#line#define()
  return s:kind
endfunction

let s:kind = {
\   'name' : 'hunk/line',
\   'parents' : ['jump_list'],
\   'default_action' : 'open',
\   'action_table' : {},
\ }

let s:kind.action_table.preview = {
\   'description' : 'view the hunk context',
\   'is_quit' : 0,
\ }

function! s:kind.action_table.preview.func(candidate) abort
  call unite#view#_preview_file('==hunk:context==')
  wincmd P
  setlocal buftype=nowrite
  setlocal noswapfile
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nonumber
  setlocal nolist
  setlocal filetype=diff
  setlocal previewwindow
  put! =a:candidate.action__context
  :1
  wincmd p
endfunction

if expand('%:p') ==# expand('<sfile>:p')
  call unite#define_kind(s:kind)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
