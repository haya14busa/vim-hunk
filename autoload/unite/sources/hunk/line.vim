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
\   'description' : 'jump to line in hunk',
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
  let max_word_length = 0

  for diff_for_file in diff
    let path = root . '/' . diff_for_file.dest
    for hunk in diff_for_file.hunks
      let lnum = hunk.new_l

      for line in split(hunk.context, "\n")
        let word = diff_for_file.dest . '|' . lnum . '|'
        let max_word_length = max([max_word_length, len(word)])
        call add(candidates, {
        \   'word': word,
        \   'action__path': path,
        \   'action__line' : lnum,
        \   'action__context' : hunk.context,
        \   'line' : line,
        \ })

        if line[0] is# '+'
          let lnum += 1
        endif
      endfor
    endfor
  endfor

  for c in candidates
    let space = repeat(' ', max_word_length - len(c.word) + 1)
    let c.word .= space . c.line
    call remove(c, 'line')
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
