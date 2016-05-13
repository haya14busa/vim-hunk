"=============================================================================
" FILE: autoload/unite/sources/hunk/jump.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#hunk#jump#define() abort
  return s:source
endfunction

let s:source = {
\   'name': 'hunk/jump',
\   'description' : 'jump to hunk',
\   'default_kind' : 'hunk/line',
\   'syntax' : 'uniteSource__Hunk',
\   'action_table' : {},
\   'hooks': {},
\ }

function! s:source.gather_candidates(args, context) abort
  let commit = get(a:args, 0, '')
  let unified = get(a:args, 1, hunk#diff_context())

  let diff = hunk#diff(commit, unified)
  let root = hunk#root()
  let candidates = []
  let max_word_length = 0

  for diff_for_file in diff
    let path = root . '/' . diff_for_file.dest
    for hunk in diff_for_file.hunks
      let lnum = hunk.new_l
      let short_context_index = 0
      let changed_lines = hunk.new_s
      if lnum > unified
        let lnum += unified
        let short_context_index += unified
        let changed_lines -= unified
      endif
      let changed_lines = max([1, changed_lines - unified])

      let word = diff_for_file.dest . '|' . lnum . ',' . changed_lines . '|'
      let max_word_length = max([max_word_length, len(word)])
      call add(candidates, {
      \   'word': word,
      \   'action__path': path,
      \   'action__line' : lnum,
      \   'action__context' : hunk.context,
      \   'short_context_index': short_context_index,
      \ })
    endfor
  endfor

  for c in candidates
    let space = repeat(' ', max_word_length - len(c.word) + 1)
    let short_context = get(split(c.action__context, "\n"), c.short_context_index, '')
    let c.word = c.word . space . short_context
    call remove(c, 'short_context_index')
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
