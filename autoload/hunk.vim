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
let s:Process = vital#hunk#import('System.Process')
let s:String = vital#hunk#import('Data.String')

function! hunk#loclist(winnr, commit) abort
  if !hunk#is_in_git_repo()
    echom 'Not in git repository'
    return
  endif
  let diff = hunk#diff(a:commit, 0)
  let loclist = s:DiffUtils.loclist(diff)
  for loc in loclist
    let loc.filename = s:cdup() . loc.filename
  endfor
  call setloclist(a:winnr, loclist, 'r')
endfunction

function! hunk#diff(commit, unified) abort
  return s:DiffParser.parse(s:gitdiff(a:commit, a:unified))
endfunction

function! hunk#is_in_git_repo() abort
  let result = s:Process.execute(['git', 'rev-parse', '--is-inside-work-tree'])
  return s:String.chomp(result.output) is# 'true'
endfunction

function! hunk#root() abort
  let result = s:Process.execute(['git', 'rev-parse', '--show-toplevel'])
  return s:String.chomp(result.output)
endfunction

function! hunk#diff_context() abort
  let result = s:Process.execute(['git', 'config', 'diff.context'])
  let context = s:String.chomp(result.output)
  return context is# '' ? 3 : str2nr(context)
endfunction

" show path of top-level directory relative to current directory
function! s:cdup() abort
  let result = s:Process.execute(['git', 'rev-parse', '--show-cdup'])
  return s:String.chomp(result.output)
endfunction

function! s:gitdiff(commit, unified) abort
  let result = s:Process.execute([
  \   'git',
  \   'diff',
  \   '--no-color',
  \   '--no-ext-diff',
  \   '--no-prefix',
  \   '-U' . a:unified,
  \ ] + (a:commit is# '' ? [] : [a:commit]))
  return result.output
endfunction

" maybe we can use `git show-ref` instead?
function! hunk#loclist_complete(arglead, cmdline, cursorpos) abort
  let candidates = s:branches() + s:alias_refs()
  return filter(copy(candidates), 'v:val =~# ''^'' . a:arglead')
endfunction

function! s:branches() abort
  let result = s:Process.execute([
  \   'git',
  \   'branch',
  \   '--list',
  \   '--all',
  \   '--no-color',
  \ ])
  return map(split(result.output, "\n"), 'v:val[2:]')
endfunction

" https://git-scm.com/docs/gitrevisions
function! s:alias_refs() abort
  return ['HEAD', 'ORIG_HEAD']
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
