if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

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
