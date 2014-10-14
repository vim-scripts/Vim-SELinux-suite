" Vim syntax file
" Language:			SELinux file context
" Maintainer: 		Yedvilun Prior
" Latest Revision:	2014 Oct 09

if exists("b:current_syntax")
  finish
endif

syn keyword fcPathNameKey	HOME_ROOT HOME_DIR ROLE USER contained
syn match	fcRegExp		'[()|\[\]?.*\-+^]' contained
syn match	fcRegExpEsc		'\\.' contained
syn match   fcPathName		'[H/]\(\S\+\)\?' contains=fcPathNameKey,fcRegExp,fcRegExpEsc nextgroup=fcFileType skipwhite
syn match   fcFileType		'-[bcdpls-]' nextgroup=fcOptSecKey skipwhite
syn keyword fcOptSecKey		gen_context
syn match   fcOptSec		'(\zs\S\+:\S\+:\S\+,\S\+\ze)'

let b:current_syntax = "fc"

hi def link fcOptSec		Statement
hi def link fcOptSecKey		Type
hi def link fcFileType		Preproc
hi def link fcPathName		String
hi def link fcPathNameKey	PreProc
hi def link fcRegExp		PreProc
hi def link fcRegExpEsc		String

