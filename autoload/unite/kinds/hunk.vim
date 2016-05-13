"=============================================================================
" FILE: autoload/unite/kinds/hunk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#hunk#define()
  return s:kinds()
endfunction

let s:basedir = fnamemodify(expand('<sfile>'), ':r')

function! s:kinds() abort
  let kind_pathes = split(globpath(s:basedir, '*.vim', 1), "\n")
  let kind_names = map(kind_pathes, "fnamemodify(v:val, ':t:r')")
  return map(kind_names, 'unite#kinds#hunk#{v:val}#define()')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
