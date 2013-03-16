if exists('g:loaded_erlmode') || &cp || version < 700 | finish | endif
let g:loaded_erlmode = 1

if !exists("g:erlmode_tags_file") | let g:erlmode_tags_file = "erl_tags" | endif
if !exists("g:erlmode_use_mappings") | let g:erlmode_use_mappings = 1 | endif

" api calls
command! -nargs=0 ErlModeCreateTags call s:CreateTags()
command! -nargs=0 ErlModeOpenShell call s:OpenErlangShell()
command! -nargs=0 ErlModeCompileFile call s:CompileFileInErlangShell()

function! s:CreateTags()
    let tags = []
    " TODO add support for project root
    for fname in split(globpath(".", "**/*.erl"), "\n")
        echomsg "Scanning" fname
        let fname = fnamemodify(fname, ':p')
        let lines = readfile(fname)
        " find the module name
        let modpat = '-module(\zs[^)]\+\ze)'
        let i = match(lines, modpat)
        let module = i >= 0 ? matchstr(lines[i], modpat) : ''
        " now scan for function definitions
        "let funpat = '\<\w\+\ze([^)]*)\s*->'
        let funpat = '^\w\+\ze('
        let lnum = 1
        for line in lines
            let name = matchstr(line, funpat)
            if name != ''
                if module != ''
                    let name = module . ':' . name
                endif
                call add(tags, name . "\t" . fname . "\t/" . escape(line, '/') . "/")
            endif
            let lnum += 1
        endfor
    endfor
    redraw | echomsg "Done creating" g:erlmode_tags_file "file"
    call sort(tags)
    call writefile(tags, g:erlmode_tags_file)
endfunction

function! s:ErlangShellArgs()
    if !expand("%:t") == "null.erl" | return "" | endif

    let sname = ''
    let config = ''
    cd %:p:h

    if filereadable("nodename")
        let sname = ' -sname ' . readfile("nodename")[0]
    endif

    let confs = split(globpath(".", "**/*.config"), "\n")
    if len(confs) > 0
        if len(confs) == 1
            let config = ' -config ' . confs[0]
        else
            let dconfig = "system.config"
            let ccomp = "customlist,s:ConfigFileCompletionList" " file
            if index(confs, dconfig) == -1 | let dconfig = "" | endif
            let selection = input("Please select config: ", dconfig,ccomp)
            if fnamemodify(selection, ":e") == 'config' && filereadable(selection)
                let config = ' -config ' . selection
            else
                echomsg 'Not a config file' | return
            endif
        endif
    else

    return sname . config
endfunction

function! s:ConfigFileCompletionList(A,L,P)
    return split(globpath(".", "**/*.config"), "\n")
endfunction

function! s:OpenErlangShell()
    if exists("g:erlmode_shell")
        if g:erlmode_shell.active
            call g:erlmode_shell.focus()
        else
            unlet g:erlmode_shell
            call s:OpenErlangShell()
        endif
    else
        let cmd = 'erl -newshell' . s:ErlangShellArgs()
        let g:erlmode_shell = conque_term#open(cmd, ['vsplit']) " belowright vsplit
    endif
endfunction

function s:CompileFileInErlangShell()
    if !exists("g:erlmode_shell") | echomsg "The shell is not open" | return | endif
    if !expand("%:e") == "erl" | echomsg "Not an erlang file" | endif
    update
    let fn = expand("%:p")
    let dir = expand("%:h")
    " TODO: do includes properly
    " TODO: change type of string to ''
    let cmd = "c(\"". fn ."\", [{outdir,\"" . dir . "\"}, {i,os:getenv(\"HOME\")++\"/svn/modules/\"}, debug_info, null])."
    call g:erlmode_shell.writeln(cmd)
    call g:erlmode_shell.focus()
endfunction
