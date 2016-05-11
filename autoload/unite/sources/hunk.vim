"=============================================================================
" FILE: autoload/unite/sources/hunk.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:source = {
\   'name': 'hunk',
\   'description' : 'jump to hunk (supported git)',
\   'default_kind' : 'jump_list',
\   'syntax' : 'uniteSource__Hunk',
\   'action_table' : {},
\   'hooks': {},
\ }

function! s:source.gather_candidates(args, context) abort
  let commit = get(a:args, 0, '')
  let diff = hunk#diff(commit)
  let root = hunk#root()
  let diff_context = hunk#diff_context()
  let candidates = []
  for diff_for_file in diff
    let path = root . '/' . diff_for_file.dest
    for hunk in diff_for_file.hunks
      let lnum = hunk.new_l
      if lnum > diff_context
        let lnum += diff_context
      endif
      call add(candidates, {
      \   'word': diff_for_file.dest . '|' . lnum . '| ' . hunk.heading,
      \   'action__path': path,
      \   'action__line' : lnum,
      \   'action__context' : hunk.context,
      \ })
    endfor
  endfor
  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  syn match uniteSource__HunkFileName "^[^|]*" nextgroup=uniteSource__HunkSeparator containedin=uniteSource__Hunk
  syn match uniteSource__HunkSeparator "|" nextgroup=uniteSource__HunkLineNr contained containedin=uniteSource__Hunk
  syn match uniteSource__HunkLineNr "[^|]*" contained contains=uniteSource__HunkError containedin=uniteSource__Hunk
  hi def link uniteSource__HunkFileName Directory
  hi def link uniteSource__HunkLineNr LineNr
endfunction

let s:source.action_table.preview = {
\   'description' : 'view the hunk context',
\   'is_quit' : 0,
\ }

function! s:source.action_table.preview.func(candidate) abort
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

function! unite#sources#hunk#define() abort
  return s:source
endfunction

function! unite#sources#hunk#is_available() abort
  return executable('git') && hunk#is_in_git_repo()
endfunction

" echo s:source.gather_candidates([], {})
call unite#define_source(s:source)

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
