if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

if exists('s:did_function_definitions')
    finish
endif

let s:did_function_definitions = 1

" ctag file

execute 'set tags+=./'.g:erlmode_tags_file.';'.$HOME
setlocal iskeyword+=:

" local mappings

if g:erlmode_use_mappings
    nnoremap <buffer> <leader>re :ErlModeOpenShell<cr>
    nnoremap <buffer> <leader>rr :ErlModeCompileFile<cr>
endif

" folding

setlocal foldmethod=expr
setlocal foldexpr=ErlModeErlangFold(v:lnum)

setlocal comments=:%%%,:%%,:%
setlocal commentstring=%%s
setlocal formatoptions+=ro

setlocal suffixesadd=.erl

let s:erl_fun_begin = '^\(\a\w*\|[''][^'']*['']\)(.*$'
let s:erl_fun_end   = '^[^%]*\.\s*\(%.*\)\?$'

function ErlModeErlangFold(lnum)
    let lnum = a:lnum
    let line = getline(lnum)
    if line =~ s:erl_fun_end | return '<1' | endif
    if line =~ s:erl_fun_begin && foldlevel(lnum - 1) == 1 | return '1' | endif
    if line =~ s:erl_fun_begin | return '>1' | endif
    return '='
endfunction
