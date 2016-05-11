"=============================================================================
" FILE: autoload/hunk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:DiffParser = vital#hunk#import('Diff.Parser')
let s:DiffUtils = vital#hunk#import('Diff.Utils')

function! hunk#loclist(winnr) abort
  echo 'TODO'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
