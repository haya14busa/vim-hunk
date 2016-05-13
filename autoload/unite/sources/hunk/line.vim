"=============================================================================
" FILE: autoload/unite/sources/hunk/line.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#hunk#line#define() abort
  return s:source
endfunction

let s:source = {
\   'name': 'hunk/line',
\   'description' : 'search line in hunk',
\   'default_kind' : 'hunk/line',
\   'syntax' : 'uniteSource__Hunk',
\   'hooks': {},
\   'sorters' : 'sorter_nothing',
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

if expand('%:p') ==# expand('<sfile>:p')
  " echo s:source.gather_candidates([], {})
  call unite#define_source(s:source)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
