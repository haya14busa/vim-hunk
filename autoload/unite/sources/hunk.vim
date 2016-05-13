"=============================================================================
" FILE: autoload/unite/sources/hunk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#hunk#define() abort
  return [s:source] + s:sources()
endfunction

function! unite#sources#hunk#is_available() abort
  return executable('git') && hunk#is_in_git_repo()
endfunction

let s:basedir = fnamemodify(expand('<sfile>'), ':r')

function! s:sources() abort
  let source_pathes = split(globpath(s:basedir, '*.vim', 1), "\n")
  let source_names = map(source_pathes, "fnamemodify(v:val, ':t:r')")
  return map(source_names, 'unite#sources#hunk#{v:val}#define()')
endfunction

let s:source = {
\   'name': 'hunk',
\   'description' : 'hunk sources',
\ }
call extend(s:source, unite#sources#source#define(), 'keep')

function! s:source.gather_candidates(args, context) abort
  return map(s:sources(), "{
  \   'word': v:val.name,
  \   'abbr': unite#util#truncate(v:val.name, 25) .
  \         (has_key(v:val, 'description') ? ' -- ' . v:val.description : ''),
  \   'source': s:source.name,
  \   'action__source_name' : v:val.name,
  \   'action__source_args' : a:args,
  \ }")
endfunction

function! unite#sources#hunk#syntax() abort
  " From quickfix
  syn match uniteSource__HunkFileName "^[^|]*" nextgroup=uniteSource__HunkSeparator containedin=uniteSource__Hunk
  syn match uniteSource__HunkSeparator "|" nextgroup=uniteSource__HunkLineNr contained containedin=uniteSource__Hunk
  syn match uniteSource__HunkLineNr "[^|]*" contained contains=uniteSource__HunkError containedin=uniteSource__Hunk
  hi def link uniteSource__HunkFileName Directory
  hi def link uniteSource__HunkLineNr LineNr

  " From diff
  syn match uniteSource__diffRemoved "|\s\+\zs-.*"
  syn match uniteSource__diffAdded "|\s\+\zs+.*"
  syn match uniteSource__diffChanged "|\s\+\zs! .*"
  hi def link uniteSource__diffRemoved Special
  hi def link uniteSource__diffChanged PreProc
  hi def link uniteSource__diffAdded Identifier
endfunction

if expand('%:p') ==# expand('<sfile>:p')
  " echo s:source.gather_candidates([], {})
  call unite#define_source(s:source)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
