" vim: set ts=4 sw=4 tw=78 noet fdm=marker :
" Vim filetype plugin file
" Language:	SELinux (.te, .if, .spt)
" Version:	1.0.4
" Author:	Yedvilun Prior
" Licence:	Vim licence
" Last Change:	2014 Oct 10
"
" Note:		A part of the code is borrowed from the tagbar plugin (v2.4.1)
"      		by Jan Larres (http://majutsushi.github.com/tagbar/)
"

if exists("g:setool_ftplugin")
	" Just do the buffer mapping
	call s:BufferMapKeys()
	finish
endif
let g:setool_ftplugin = 1
let s:save_cpo = &cpo

" Parameters {{{1
" Base directory of the interfaces on fedora/redhat
let s:SEToolIfBaseDir = "/usr/share/selinux/devel/include/"
" Interfaces directories
let s:SEToolIfDirs = ["admin", "apps", "contrib", "kernel", "roles", "services", "system"]
" Definitions directories
let s:SEToolDefDirs = ["support"]
" Interfaces dictionary
let s:SEToolDicIfFiles = {} | " keys: directory, values: list of .if files
let s:SEToolDicIf = {}		| " keys: .if file, values: list of dict. named by interfaces, with keys: Line, Summary, Parameters
let s:SEToolDicDefFiles = {} | " keys: directory, values: list of macro files
" sort
let s:sortlist = 1

let s:icon_closed = '▶'
let s:icon_open   = '▼'
let s:padding     = ' '
let s:indent      = '   ' | " Do not change the indent without updating the fold column

" Checking {{{1
" Check existence
if !isdirectory(s:SEToolIfBaseDir)
	echoerr "File not found!"
	echo "Cannot find the directory ".s:SEToolIfBaseDir
	echo "Is 'selinux-policy-devel' installed?"
	finish
endif
" Secondary check
for d in s:SEToolIfDirs+s:SEToolDefDirs
	if !isdirectory(s:SEToolIfBaseDir.d)
		echo "Cannot find the directory '"s:SEToolIfBaseDir.d."'"
		echo "Continuing without it."
	endif
endfor

" Basic functions {{{1
" List the interfaces from a directory {{{2
function! s:SEToolListIf(ifdir)
	let s:ifdir = a:ifdir
	let l:list = system("ls -1 ".s:ifdir)
	let s:SEToolDicIfFiles[s:ifdir] = split(l:list)
endfunction
" List the macros from a directory {{{2
function! s:SEToolListDef(defdir)
	let s:defdir = a:defdir
	let l:list = system("cd ".s:defdir." && ls -1 *.spt")
	let s:SEToolDicDefFiles[s:defdir] = split(l:list)
endfunction
" List all the interfaces found on the system {{{2
function! s:SEToolListAllIf()
	for l:d in s:SEToolIfDirs
		call s:SEToolListIf(s:SEToolIfBaseDir.l:d)
	endfor
endfunction

" Get interfaces from an .if file {{{2
function! s:SEToolGetAllIf(iffile)
	let l:iffile = a:iffile
	let l:key = matchstr(l:iffile, '/\zs[^/]\+$')
	" grep interfaces names & lines
	let l:tmp0 = system("grep -n -e ^interface\\( -e ^template\\( ".l:iffile
		\ .'|sed -e "s/:interface(\`/ /g" -e "s/:template(\`/ /g" -e "s/'',\s\?\`$//g"')

	" add as a dictionary for the key value {{{3
	let l:tmp1 = split(l:tmp0, '\n')
	let l:num = 2
	let l:ifdic = {}
	let s:SEToolDicIf[l:key] = {}
	for li in l:tmp1
		" line & name
		let l:tmp2 = split(li)
		let l:ifdic['Line'] = l:tmp2[0]
		" get summary (cannot it be simpler?)
		let l:tmp3 = system("sed -n '".l:num.",".l:tmp2[0]
			\ ."s/\\(^##\\).*$/\\0/p' ".l:iffile
			\ ."|sed 's/^##\\( \\|\t\\)//g'")
			" the join&split remove the trailing newlines 
		let l:ifdic['Summary'] =
			\ join(split(
			\ substitute(matchstr(l:tmp3, '<summary>[^<]\+'), 
			\ '<summary>\n', '', "")
			\ ))
		" get parameters (it could certainly be simpler!)
		let l:tmp3 = system("sed -n '".l:num.",".l:tmp2[0]
			\ ."s/\\(^##\\).*$/\\0/p' ".l:iffile
			\ ."|sed 's/^##\\( \\|\t\\)//g'"
			\ ."|grep 'param name='"
			\ ."|sed -e 's/<param name=\"//g' -e 's/\">//g'")
		let l:ifdic['Parameters'] =
			\ join(split(l:tmp3), ',')

		" Store the dictionary
		call extend(s:SEToolDicIf[l:key], {l:tmp2[1]:deepcopy(l:ifdic)})
		let l:num = l:tmp2[0]
	endfor
endfunction
"}}}
"}}}
"}}}

" Display {{{1
" s:RenderContent() {{{2
function! s:RenderContent(...) abort
    let s:new_window = 0

    let setoolwinnr = bufwinnr('__SETool__')

    if &filetype == 'setool'
        let in_setool = 1
    else
        let in_setool = 0
        let prevwinnr = winnr()
        call s:winexec(setoolwinnr . 'wincmd w')
    endif

	let saveline = line('.')
	let savecol  = col('.')
	let topline  = line('w0')

    let lazyredraw_save = &lazyredraw
    set lazyredraw
    let eventignore_save = &eventignore
    set eventignore=all

    setlocal modifiable

    silent %delete _

    call s:PrintHelp()

	" Pring macros
	call s:PrintMacros()

    " Print tags
    call s:PrintKinds()

    " Delete empty lines at the end of the buffer
    for linenr in range(line('$'), 1, -1)
        if getline(linenr) =~ '^$'
            execute 'silent ' . linenr . 'delete _'
        else
            break
        endif
    endfor

    setlocal nomodifiable

	" Make sure as much of the SETool content as possible is shown in the
	" window by jumping to the top after drawing
	execute 1
	call winline()

	" Invalidate highlight cache from old file
	let s:last_highlight_tline = 0

    let &lazyredraw  = lazyredraw_save
    let &eventignore = eventignore_save

    if !in_setool
        call s:winexec(prevwinnr . 'wincmd w')
    endif
endfunction

" s:PrintHelp() {{{2
function! s:PrintHelp() abort
	silent 0put = '\"SELinux policy interfaces\"'
    if s:short_help
        silent  put ='\" Press <F1> for help'
        silent  put _
    elseif !s:short_help
        silent  put ='\"'
        silent  put ='\"        Keybindings:'
        silent  put ='\"'
        silent  put ='\" ======= in SETool =========='
        silent  put ='\" --------- General ---------'
        silent  put ='\" <Enter> : Open the interface'
        silent  put ='\" q       : Close window'
        silent  put ='\" <F1>    : Remove help'
        silent  put ='\"'
        silent  put ='\" ---------- Folds ----------'
        silent  put ='\" +, zo   : Open fold'
        silent  put ='\" -, zc   : Close fold'
        silent  put ='\" o, za   : Toggle fold'
        silent  put ='\"'
        silent  put ='\" ======== in Buffer ========='
        silent  put ='\" gd      : call SEToolSearch()'
        silent  put ='\" gf      : call SEToolFindAsk()'
        silent  put ='\" <C-T>   : call SEToolToggle()'
        silent  put _
    endif
endfunction

" s:PrintMacros() {{{2
function! s:PrintMacros() abort
	let l:str = s:icon_closed . s:padding . "Macros files:"
	silent put = l:str
	silent put _
endfunction

" s:PrintKinds() {{{2
function! s:PrintKinds() abort
	for l:i in keys(s:SEToolDicIfFiles)
		let l:str = "[" . matchstr(l:i, '/\zs[^/]\+\ze$') . "]"
		silent put = s:icon_closed . s:padding . l:str
	endfor
endfunction
"}}}

" Window management {{{1
" Parameters {{{2
let s:new_window      = 1
let s:is_maximized    = 0
let s:short_help      = 1
let s:window_expanded = 0
" FIXME handle the global variables
let g:setool_expand   = 0
let g:setool_left     = 0
let g:setool_sort     = 0
let g:setool_autoclose     = 0
let g:setool_autofocus     = 1
let g:setool_width    = 30

" s:ToggleWindow() {{{2
function! s:ToggleWindow() abort
    let setoolwinnr = bufwinnr("__SETool__")
    if setoolwinnr != -1
        call s:CloseWindow()
        return
    endif

    call s:OpenWindow('')
endfunction

" s:OpenWindow() {{{2
function! s:OpenWindow(flags) abort
	let s:curwin = bufwinnr(@%)
    let autofocus = a:flags =~# 'f'
    let jump      = a:flags =~# 'j'
    let autoclose = a:flags =~# 'c'

    let curfile = fnamemodify(bufname('%'), ':p')
    let curline = line('.')

    " If the setool window is already open check jump flag
    " Also set the autoclose flag if requested
    let setoolwinnr = bufwinnr('__SETool__')
    if setoolwinnr != -1
        if winnr() != setoolwinnr && jump
            call s:winexec(setoolwinnr . 'wincmd w')
            call s:HighlightTag(1, 1, curline)
        endif
        return
    endif

    " This is only needed for the CorrectFocusOnStartup() function
    let s:last_autofocus = autofocus

    " Expand the Vim window to accomodate for the SETool window if requested
    if g:setool_expand && !s:window_expanded && has('gui_running')
        let &columns += g:setool_width + 1
        let s:window_expanded = 1
    endif

    let eventignore_save = &eventignore
    set eventignore=all

    let openpos = g:setool_left ? 'topleft vertical ' : 'botright vertical '
    exe 'silent keepalt ' . openpos . g:setool_width . 'split ' . '__SETool__'

    let &eventignore = eventignore_save

    call s:InitWindow(autoclose)

	call s:RenderContent()

    if !(g:setool_autoclose || autofocus || g:setool_autofocus)
        call s:winexec('wincmd p')
    endif
endfunction

" s:InitWindow() {{{2
function! s:InitWindow(autoclose) abort
    setlocal filetype=setool

    setlocal noreadonly " in case the "view" mode is used
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal nolist
    setlocal nonumber
    setlocal nowrap
    setlocal winfixwidth
    setlocal textwidth=0
    setlocal nospell

    if exists('+relativenumber')
        setlocal norelativenumber
    endif

    setlocal nofoldenable
    setlocal foldcolumn=0
    " Reset fold settings in case a plugin set them globally to something
    " expensive. Apparently 'foldexpr' gets executed even if 'foldenable' is
    " off, and then for every appended line (like with :put).
    setlocal foldmethod&
    setlocal foldexpr&

	setlocal statusline=SELinux\ Tool
	setlocal cursorline

    let s:new_window = 1

    let w:autoclose = a:autoclose
    if has('balloon_eval')
        setlocal balloonexpr=SEToolBalloonExpr()
        set ballooneval
    endif

    let cpoptions_save = &cpoptions
    set cpoptions&vim

    if !hasmapto('JumpToTag', 'n')
        call s:MapKeys()
    endif

    let &cpoptions = cpoptions_save
endfunction

" s:CloseWindow() {{{2
function! s:CloseWindow() abort
    let setoolwinnr = bufwinnr('__SETool__')
    if setoolwinnr == -1
        return
    endif

    let setoolbufnr = winbufnr(setoolwinnr)

    if winnr() == setoolwinnr
        if winbufnr(2) != -1
            " Other windows are open, only close the setool one

            call s:winexec('close')

            " Try to jump to the correct window after closing
            call s:winexec('wincmd p')
        endif
    else
        " Go to the setool window, close it and then come back to the
        " original window
        let curbufnr = bufnr('%')
        call s:winexec(setoolwinnr . 'wincmd w')
        close
        " Need to jump back to the original window only if we are not
        " already in that window
        let winnum = bufwinnr(curbufnr)
        if winnr() != winnum
            call s:winexec(winnum . 'wincmd w')
        endif
    endif

    " If the Vim window has been expanded, and SETool is not open in any other
    " tabpages, shrink the window again
    if s:window_expanded
        let tablist = []
        for i in range(tabpagenr('$'))
            call extend(tablist, tabpagebuflist(i + 1))
        endfor

        if index(tablist, setoolbufnr) == -1
            let &columns -= g:setool_width + 1
            let s:window_expanded = 0
        endif
    endif
endfunction

" s:winexec() {{{2
function! s:winexec(cmd) abort
    let eventignore_save = &eventignore
    set eventignore=BufEnter

    execute a:cmd

    let &eventignore = eventignore_save
endfunction

" SEToolBalloonExpr() {{{2
function! SEToolBalloonExpr() abort
    let taginfo = s:GetTagInfo(v:beval_lnum, 1)

    if empty(taginfo)
        return ''
    endif

    return taginfo.getPrototype(0)
endfunction

" s:CheckMouseClick() {{{2
function! s:CheckMouseClick() abort
    let line   = getline('.')
    let curcol = col('.')

    if (match(line, s:icon_open . '[-+ ]') + 1) == curcol
        call s:CloseFold()
    elseif (match(line, s:icon_closed . '[-+ ]') + 1) == curcol
        call s:OpenFold()
    endif
endfunction

" s:ToggleHelp() {{{2
function! s:ToggleHelp() abort
	let s:short_help = !s:short_help

	" Prevent highlighting from being off after adding/removing the help text
	match none

	call s:RenderContent()

	execute 1
	redraw
endfunction
"}}}

" Folding {{{1
" s:OpenFold() {{{2
function! s:OpenFold() abort
	"echo "Open Fold"

    let curline = line('.')
    let l:line = getbufline(bufnr('__SETool__'), curline)[0]

	let l:col = match(l:line, s:icon_closed)
	if l:col == -1
		return
	endif
	let l:col += 1

	setlocal modifiable
	" Macros {{{3
	if l:col == 1 && match(l:line[4:-1], 'Macros') != -1 " SEToolDicDefFiles
		silent exe ':s/' . s:icon_closed . '/' . s:icon_open .'/'
		for l:key in s:SEToolDefDirs
			let l:dir = s:SEToolIfBaseDir.l:key
			if !has_key(s:SEToolDicDefFiles, l:dir)
				if !empty(l:dir)
					echo "Making cache, please wait..."
					setlocal statusline=Making\ cache
					call s:SEToolListDef(l:dir)
					echo "Done"
					setlocal statusline=SELinux\ Tool
				endif
			endif
			let s:num_macros = 0
			for l:k in s:SEToolDicDefFiles[l:dir]
				silent put = s:indent.l:k
				let s:num_macros += 1
			endfor
		endfor
	" Interfaces lvl 1 {{{3
	elseif l:col == 1 " SEToolDicIfFiles
		silent exe ':s/' . s:icon_closed . '/' . s:icon_open .'/'
		let l:key = l:line[5:-2]
		if s:sortlist == 0
			for l:k in s:SEToolDicIfFiles[s:SEToolIfBaseDir.l:key]
				silent put = s:indent.s:icon_closed.s:padding.l:k
			endfor
		else
			for l:k in sort(deepcopy(s:SEToolDicIfFiles[s:SEToolIfBaseDir.l:key]))
				silent put = s:indent.s:icon_closed.s:padding.l:k
			endfor
		endif
	" Interfaces lvl 2 {{{3
	elseif l:col == 4 " SEToolDicIf
		silent exe ':s/' . s:icon_closed . '/' . s:icon_open .'/'
		let l:key = l:line[7:-1]

		if !has_key(s:SEToolDicIf, l:key)
			let l:dir = ""
			for l:k in keys(s:SEToolDicIfFiles)
				if index(s:SEToolDicIfFiles[l:k], l:key) != -1
					let l:dir = l:k.'/'
					break
				endif
			endfor

			if !empty(l:dir)
				echo "Making cache, please wait..."
				setlocal statusline=Making\ cache
				call s:SEToolGetAllIf(l:dir.l:key)
				echo "Done"
				setlocal statusline=SELinux\ Tool
			endif
		endif

		if s:sortlist == 0
			for l:k in keys(s:SEToolDicIf[l:key])
				let l:str = "(".s:SEToolDicIf[l:key][l:k]['Parameters'].")"
					\ .": ".s:SEToolDicIf[l:key][l:k]['Summary']
				silent put = s:indent.s:indent.l:k.l:str
			endfor
		else
			for l:k in sort(deepcopy(keys(s:SEToolDicIf[l:key])))
				let l:str = "(".s:SEToolDicIf[l:key][l:k]['Parameters'].")"
					\ .": ".s:SEToolDicIf[l:key][l:k]['Summary']
				silent put = s:indent.s:indent.l:k.l:str
			endfor
		endif
	endif
	"}}}
	setlocal nomodifiable

endfunction

" s:CloseFold() {{{2
function! s:CloseFold() abort
	"echo "Close Fold"

    let curline = line('.')
    let l:line = getbufline(bufnr('__SETool__'), curline)[0]

	let l:col = match(l:line, s:icon_open)
	if l:col == -1
		while match(l:line, s:icon_open) == -1
			let curline -= 1
			if curline == 0
				return
			endif
			let l:line = getbufline(bufnr('__SETool__'), curline)[0]
		endwhile
		let l:col = match(l:line, s:icon_open)
		call cursor(curline, col('.'))
	endif
	let l:col += 1

	setlocal modifiable
	" Interfaces lvl 1 {{{3
	if l:col == 1 " SEToolDicIfFiles
		silent exe ':s/' . s:icon_open . '/' . s:icon_closed .'/'
		let l:key = l:line[5:-2]
		let curline += 1
		let l:line = getbufline(bufnr('__SETool__'), curline)[0]
		while l:line[l:col] == ' '
			silent exe curline . 'delete'
			if len(getbufline(bufnr('__SETool__'), curline)) == 0
				break
			else
				let l:line = getbufline(bufnr('__SETool__'), curline)[0]
			endif
		endwhile
	" Interfaces lvl 2 {{{3
	elseif l:col == 4 " SEToolDicIf
		silent exe ':s/' . s:icon_open . '/' . s:icon_closed .'/'
		let l:key = l:line[7:-1]
		let curline += 1
		let l:line = getbufline(bufnr('__SETool__'), curline)[0]
		while l:line[l:col] == ' '
			silent exe curline . 'delete'
			if len(getbufline(bufnr('__SETool__'), curline)) == 0
				break
			else
				let l:line = getbufline(bufnr('__SETool__'), curline)[0]
			endif
		endwhile
	endif
	"}}}
	setlocal nomodifiable
	call cursor(line('.')-1, col('.'))
endfunction

" s:JumpToTag() {{{2
function! s:JumpToTag(stay_in_setool) abort
    let curline = line('.')
    let curcol = col('.')
    let l:line = getbufline(bufnr('__SETool__'), curline)[0]

	" Check if macro {{{3
	if match(l:line, '.\+\.spt') != -1
		let l:name = l:line[3:-1]
		let l:filename = ""
		for l:key in keys(s:SEToolDicDefFiles)
			if index(s:SEToolDicDefFiles[l:key], l:name) != -1
				let l:filename = l:key.'/'.l:name
				break
			endif
		endfor
		call s:SEToolOpen(l:filename, 1)
		return
	endif

	" Check if interface file {{{3
	if match(l:line, '.\+\.if') != -1
		let l:name = l:line[7:-1]
		let l:filename = ""
		for l:key in keys(s:SEToolDicIfFiles)
			if index(s:SEToolDicIfFiles[l:key], l:name) != -1
				let l:filename = l:key.'/'.l:name
				break
			endif
		endfor
		call s:SEToolOpen(l:filename, 1)
		return
	endif

	" Get interface name {{{3
	let l:str = substitute(matchstr(l:line, '[^(]\+('), '^\s\+', '', '')
	if strlen(str) == 0
		return
	endif

	let l:iface = l:str[0:-2]
	let l:n = curline
	" get interface file
	let l:n -=1
    let l:line = getbufline(bufnr('__SETool__'), l:n)[0]
	while l:line[4] == ' '
		let l:n -=1
		let l:line = getbufline(bufnr('__SETool__'), l:n)[0]
	endwhile
	let l:iffile = l:line[7:-1]
	" get directory
	let l:n -=1
    let l:line = getbufline(bufnr('__SETool__'), l:n)[0]
	while l:line[1] == ' '
		let l:n -=1
		let l:line = getbufline(bufnr('__SETool__'), l:n)[0]
	endwhile
	let l:ifdir = l:line[5:-2]
	" filename
	let l:filename = s:SEToolIfBaseDir.'/'.l:ifdir.'/'.l:iffile
	" line number
	let l:n = s:SEToolDicIf[l:iffile][l:iface]['Line']
	" open in editor
	call s:SEToolOpen(l:filename, l:n)
endfunction

" s:SEToolOpen {{{2
function! s:SEToolOpen(file, line) abort
	let l:setoolwin = bufwinnr('__SETool__')
	let l:mbewin = bufwinnr('-MiniBufExplorer-')
	let l:winnum = bufwinnr(@%)
	" Select the window opened before setool
	while bufwinnr(@%) != s:curwin
		call s:winexec('wincmd w')
	endwhile
	" Be sure it is neither MBE nor SETool
	while  bufwinnr(@%) == l:mbewin || bufwinnr(@%) == l:setoolwin
		call s:winexec('wincmd w')
	endwhile

	" open the file
	silent exe ":view +".a:line." ".a:file
	setlocal filetype=te
endfunction

" s:ToggleFold() {{{2
function! s:ToggleFold() abort
	echo "ToggleFold"
	let curline = line('.')
	let curcol = col('.')

	let l:line = getbufline(bufnr('__SETool__'), curline)[0]
	while match(l:line, '\('.s:icon_closed.'\|'.s:icon_open.'\)') == -1
		let curline -= 1
		if curline == 0
			return
		endif
		let l:line = getbufline(bufnr('__SETool__'), curline)[0]
	endwhile

	if match(l:line, s:icon_closed) != -1
		call s:OpenFold()
	elseif match(l:line, s:icon_open) != -1
		call s:CloseFold()
	endif
endfunction

" s:MapKeys() {{{1
function! s:MapKeys() abort
    nnoremap <script> <silent> <buffer> <2-LeftMouse>
                                              \ :call <SID>JumpToTag(0)<CR>
    nnoremap <script> <silent> <buffer> <LeftRelease>
                                 \ <LeftRelease>:call <SID>CheckMouseClick()<CR>

    inoremap <script> <silent> <buffer> <2-LeftMouse>
                                              \ <C-o>:call <SID>JumpToTag(0)<CR>
    inoremap <script> <silent> <buffer> <LeftRelease>
                            \ <LeftRelease><C-o>:call <SID>CheckMouseClick()<CR>

    nnoremap <script> <silent> <buffer> <CR>    :call <SID>JumpToTag(0)<CR>
    nnoremap <script> <silent> <buffer> p       :call <SID>JumpToTag(1)<CR>

    nnoremap <script> <silent> <buffer> +        :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> <kPlus>  :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> zo       :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> -        :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> <kMinus> :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> zc       :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> o        :call <SID>ToggleFold()<CR>
    nnoremap <script> <silent> <buffer> za       :call <SID>ToggleFold()<CR>

    nnoremap <script> <silent> <buffer> *    :call <SID>SetFoldLevel(99, 1)<CR>
    nnoremap <script> <silent> <buffer> <kMultiply>
                                           \ :call <SID>SetFoldLevel(99, 1)<CR>
    nnoremap <script> <silent> <buffer> zR   :call <SID>SetFoldLevel(99, 1)<CR>
    nnoremap <script> <silent> <buffer> =    :call <SID>SetFoldLevel(0, 1)<CR>
    nnoremap <script> <silent> <buffer> zM   :call <SID>SetFoldLevel(0, 1)<CR>

    nnoremap <script> <silent> <buffer> <C-N>
                                        \ :call <SID>GotoNextToplevelTag(1)<CR>
    nnoremap <script> <silent> <buffer> <C-P>
                                        \ :call <SID>GotoNextToplevelTag(-1)<CR>

    nnoremap <script> <silent> <buffer> q    :call <SID>CloseWindow()<CR>
	nnoremap <script> <silent> <buffer> <F1> :call <SID>ToggleHelp()<CR>
	nnoremap <script> <silent> <buffer> <C-t>	:call g:SEToolToggle()<CR>
endfunction
"}}}

" Interactive functions {{{1
" g:SEToolSearch() {{{2
function! g:SEToolSearch() abort
    let curline = line('.')
    let curcol = col('.')

	" select word under the cursor
	let l:word = expand("<cword>")
	call s:SEToolFind(l:word)
endfunction

" s:SEToolFind() {{{2
function! s:SEToolFind(word) abort
	echo "Looking for '".a:word."' definition..."
	let l:str = system("grep -nR -e interface\\(\\`".a:word."\\'"
		\ ." -e template\\(\\`".a:word."\\' "
		\ ." -e define\\(\\`".a:word."\\' ". s:SEToolIfBaseDir)
	if empty(l:str)
		echo a:word.": pattern not found"
		return
	else
		echo "Done"
	endif
	let l:list = split(l:str, ':')
	let l:file = list[0]
	let l:line = list[1]

	" .spt files {{{3
	if match(l:file, '.\+\.spt') != -1
		" Get name
		let l:name = matchstr(l:file, '/\zs[^/]\+$')
		" Focus window
		call s:OpenWindow('f')
		while @% != '__SETool__'
			call s:winexec('wincmd w')
		endwhile
		silent exe "buffer __SETool__"
		" Unfold & select the line
		call cursor(1, 1)
		call search('\<'.l:name.'\>', 'c')
		if line('.') == 1
			call search('\<Macros\>')
			call cursor(line('.'), 1)
			call s:OpenFold()
			call search('\<'.l:name.'\>', 'bc')
		endif

	" .if files {{{3
	elseif match(l:file, '.\+\.if') != -1
		" Get name
		let l:name = matchstr(l:file, '/\zs[^/]\+$')
		let l:dir =matchstr(l:file, '/\zs[^/]\+\ze/[^/]\+$')
		" Focus window
		call s:OpenWindow('f')
		while @% != '__SETool__'
			call s:winexec('wincmd w')
		endwhile
		silent exe "buffer __SETool__"
		" Unfold & select the line
		call cursor(1, 1)
		call search('\<'.a:word.'\>', 'c')
		if line('.') == 1
			call search('\<'.l:name.'\>')
			if line('.') == 1
				call search('\['.l:dir.'\]')
				call cursor(line('.'), 1)
				call s:OpenFold()
				call search('\<'.l:name.'\>', 'bc')
			endif
			call cursor(line('.'), 4)
			call s:OpenFold()
			call search('\<'.a:word.'\>', 'bc')
		endif
	endif

	" Open {{{3
	call s:SEToolOpen(l:file, l:line)
endfunction

" s:SEToolFindAsk() {{{2
function! g:SEToolFindAsk() abort
	let l:word = input("SETool: enter the expression to search: ")
	if !empty(l:word)
		call s:SEToolFind(l:word)
	endif
endfunction

" g:SEToolToggle() {{{2
function! g:SEToolToggle() abort
	call s:ToggleWindow()
endfunction

" Commands {{{1
command -nargs=0 SEToolToggle call g:SEToolToggle()
command -nargs=0 SEToolSearch call g:SEToolSearch()
command -nargs=1 SEToolFind   call s:SEToolFind(<args>)

" Maps {{{1
function! s:BufferMapKeys() abort
	nnoremap <silent> <buffer> gd		:call g:SEToolSearch()<CR>
	nnoremap <silent> <buffer> gf		:call g:SEToolFindAsk()<CR>
	nnoremap <silent> <buffer> <C-t>	:call g:SEToolToggle()<CR>
endfunction
" }}}

" Init {{{1
call s:SEToolListAllIf()
call s:BufferMapKeys()
" Make
set efm=%ACompiling\ %.%#,%C%f%.:%l:%tRROR\ %m\ on\ line\ %*\\d:,%C%s,%Z
set mp=make\ -f\ /usr/share/selinux/devel/Makefile

augroup fold
" It take to much time to open the buffer, so we just set fde
" set fdm=expr manually to enable the folding
"au BufReadPre *.if set fdm=expr 
au BufReadPre *.if set fde=(getline(v:lnum)=~'^interface('\|\|getline(v:lnum)=~'^###')?0:1
augroup END

let &cpo = s:save_cpo


" Testing {{{1
" Some tests
"call s:SEToolFind("manage_files_pattern")
"call s:SEToolFind("application_type")
"call s:SEToolFind("domain_type")
"call s:SEToolFind("init_ranged_domain")
"call s:SEToolFind("create_stream_socket_perms")
