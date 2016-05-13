"=============================================================================
" FILE: autoload/unite/sources/hunk/line.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#hunk#line#define() abort
  return [s:source, s:source_added, s:source_deleted]
endfunction

let s:source = {
\   'name': 'hunk/line',
\   'description' : 'search line in hunk',
\   'default_kind' : 'hunk/line',
\   'syntax' : 'uniteSource__Hunk',
\   'hooks': {},
\   'sorters' : 'sorter_nothing',
\ }

let s:source_added = {
\   'name': 'hunk/line_added',
\   'description' : 'search added line in hunk',
\ }

let s:source_deleted = {
\   'name': 'hunk/line_deleted',
\   'description' : 'search deleted line in hunk',
\ }

function! s:source.gather_candidates(args, context) abort
  let commit = get(a:args, 0, '')
  let unified = 0
  let diff = hunk#diff(commit, unified)
  let root = hunk#root()
  let candidates = []
  let max_abbr_length = 0

  for diff_for_file in diff
    let path = root . '/' . diff_for_file.dest
    for hunk in diff_for_file.hunks
      let lnum = hunk.new_l

      for line in split(hunk.context, "\n")
        let abbr = diff_for_file.dest . '|' . lnum . '|'
        let max_abbr_length = max([max_abbr_length, len(abbr)])
        call add(candidates, {
        \   'word': line,
        \   'abbr': abbr,
        \   'action__path': path,
        \   'action__line' : lnum,
        \   'action__context' : hunk.context,
        \ })

        if line[0] is# '+'
          let lnum += 1
        endif
      endfor
    endfor
  endfor

  for c in candidates
    let space = repeat(' ', max_abbr_length - len(c.abbr) + 1)
    let c.abbr .= space . c.word
  endfor

  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  call unite#sources#hunk#syntax()
endfunction

call extend(s:source_added, s:source, 'keep')
call extend(s:source_deleted, s:source, 'keep')

function! s:source_added.gather_candidates(...) abort
  let candidates = call(s:source.gather_candidates, a:000, self)
  return filter(candidates, "v:val.word[0] is# '+'")
endfunction

function! s:source_deleted.gather_candidates(...) abort
  let candidates = call(s:source.gather_candidates, a:000, self)
  return filter(candidates, "v:val.word[0] is# '-'")
endfunction

if expand('%:p') ==# expand('<sfile>:p')
  " echo s:source.gather_candidates([], {})
  call map(unite#sources#hunk#line#define(), 'unite#define_source(v:val)')
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
