" File:        setool.vim
" Description: Setool syntax settings
" Author:      Yedvilun Prior
" Licence:     Vim licence
" Version:     1.0.0

scriptencoding utf-8

if exists("b:current_syntax")
  finish
endif

" TODO put this elsewhere
let g:setool_iconchars = ['▶','▼']

let s:ic = g:setool_iconchars[0]
if s:ic =~ '[]^\\-]'
    let s:ic = '\' . s:ic
endif
let s:io = g:setool_iconchars[1]
if s:io =~ '[]^\\-]'
    let s:io = '\' . s:io
endif

let s:pattern = '\([' . s:ic . s:io . '] \?\)\@<=[^-+: ]\+[^:]\+$'
execute "syntax match SetoolKind '" . s:pattern . "'"

let s:pattern = '\([' . s:ic . s:io . '][-+# ]\?\)\@<=[^*(]\+\(\*\?\(([^)]\+)\)\? :\)\@='
execute "syntax match SetoolScope '" . s:pattern . "'"

let s:pattern = '[' . s:ic . s:io . ']\([-+# ]\?\)\@='
execute "syntax match SetoolFoldIcon '" . s:pattern . "'"

let s:pattern = '\([' . s:ic . s:io . ' ]\)\@<=+\([^-+# ]\)\@='
execute "syntax match SetoolVisibilityPublic '" . s:pattern . "'"
let s:pattern = '\([' . s:ic . s:io . ' ]\)\@<=#\([^-+# ]\)\@='
execute "syntax match SetoolVisibilityProtected '" . s:pattern . "'"
let s:pattern = '\([' . s:ic . s:io . ' ]\)\@<=-\([^-+# ]\)\@='
execute "syntax match SetoolVisibilityPrivate '" . s:pattern . "'"

unlet s:pattern

syntax match SetoolNestedKind '^\s\+\[[^]]\+\]$'
syntax match SetoolComment    '^".*'
syntax match SetoolType       ' : \zs.*'
syntax match SetoolSignature  '(.*)'
syntax match SetoolPseudoID   '\*\ze :'
syntax match SetoolSummary    ': \zs.*'
syntax match SetoolInterface  '^\s\+\zs\<[^(]\+\>\ze('
syntax match SetoolMacroFile  '^\s\+\zs\<.\+\.spt\ze'

highlight default link SetoolSummary    Comment
highlight default link SetoolComment    Comment
highlight default link SetoolInterface  Type
highlight default link SetoolKind       Identifier
highlight default link SetoolNestedKind SetoolKind
highlight default link SetoolScope      Title
highlight default link SetoolType       Type
highlight default link SetoolSignature  Statement
highlight default link SetoolMacroFile  Statement
highlight default link SetoolPseudoID   NonText
highlight default link SetoolFoldIcon   Statement
highlight default link SetoolHighlight  Search

highlight default SetoolAccessPublic    guifg=Green ctermfg=Green
highlight default SetoolAccessProtected guifg=Blue  ctermfg=Blue
highlight default SetoolAccessPrivate   guifg=Red   ctermfg=Red
highlight default link SetoolVisibilityPublic    SetoolAccessPublic
highlight default link SetoolVisibilityProtected SetoolAccessProtected
highlight default link SetoolVisibilityPrivate   SetoolAccessPrivate

let b:current_syntax = "setool"

" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
