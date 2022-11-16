if exists('g:cwd_finder_loaded')
	finish
endif
let g:cwd_finder_loaded = 1

function! s:get_cwd_finder_file_name() abort
	let f = get(g:, 'cwd_finder_file', '~/.local/share/vim/cwd_finder.json')
	call mkdir(fnamemodify(f, ":p:h"), 'p')
	return expand(f)
endfunction

function! s:load_cwd_finder_history_from_file() abort
	let f = s:get_cwd_finder_file_name()
	if !filereadable(f)
		return []
	endif
	let content = readfile(f, '', 2)
	if len(content)<1 || content[0][0] != '['
		return []
	endif
	return json_decode(content[0])
endfunction

function! s:save_cwd_finder_history_to_file() abort
	let g:cwd_finder_history = get(g:, 'cwd_finder_history', [])
	call writefile([json_encode(g:cwd_finder_history)], s:get_cwd_finder_file_name(), 's')
endfunction

function! s:on_dir_changed() abort
	let g:cwd_finder_history = s:load_cwd_finder_history_from_file()
	let p = getcwd()
	let i = 0
	let acount = 0
	while i < len(g:cwd_finder_history)
		if g:cwd_finder_history[i]['path'] == p
			let acount = get(g:cwd_finder_history[i], 'count', 1)
			call remove(g:cwd_finder_history, i)
			break
		endif
		let i += 1
	endwhile
	call insert(g:cwd_finder_history, {'path': p, 'atime': localtime(), 'count': acount+1}, 0)
	if len(g:cwd_finder_history) > g:cwd_finder_history_length
		let g:cwd_finder_history = g:cwd_finder_history[0: g:cwd_finder_history_length-1]
	endif
	call s:save_cwd_finder_history_to_file()
endfunction

autocmd DirChanged * call <SID>on_dir_changed()

function! s:lf_cwd_finder_history_source(...) abort
	let g:cwd_finder_history = get(g:, 'cwd_finder_history', [])
	let items = []
	for row in g:cwd_finder_history
		call add(items, row['path'])
	endfor
	return items
endfunction

function! s:lf_cwd_finder_accept(line, arg) abort
	exec 'cd ' . a:line
	pwd
endfunction

let g:Lf_Extensions = get(g:, 'Lf_Extensions', {})
let g:Lf_Extensions.cwd_history = {
			\ 'source': string(function('s:lf_cwd_finder_history_source'))[10:-3],
			\ 'accept': string(function('s:lf_cwd_finder_accept'))[10:-3],
			\ }

function! s:lf_cwd_finder_sub_dirs_source(...) abort
	let items = []
	for row in readdir(getcwd())
		if getftype(row) != 'dir'
			continue
		endif
		call add(items, fnamemodify(row, ':p'))
	endfor
	return items
endfunction

let g:Lf_Extensions.cwd_sub_dirs = {
			\ 'source': string(function('s:lf_cwd_finder_sub_dirs_source'))[10:-3],
			\ 'accept': string(function('s:lf_cwd_finder_accept'))[10:-3],
			\ }

let g:cwd_finder_history_length = get(g:, 'cwd_finder_history_length', 20)
let g:cwd_finder_history = s:load_cwd_finder_history_from_file()

