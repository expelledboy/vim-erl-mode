if exists('g:loaded_erlmode') || &cp || version < 700 | finish | endif
let g:loaded_erlmode = 1

if !exists("g:erlmode_tags_file") | let g:erlmode_tags_file = "erl_tags" | endif
if !exists("g:erlmode_use_mappings") | let g:erlmode_use_mappings = 1 | endif

" api calls
command! -nargs=0 ErlModeCreateTags call s:CreateTags()
command! -nargs=0 ErlModeOpenShell call s:OpenErlangShell()
command! -nargs=0 ErlModeCompileFile call s:CompileFileInErlangShell()
command! -nargs=0 ErlModeRunTestSuite call s:RunTestInErlangShell()
command! -nargs=0 ErlModeExecLine call s:RunLineInErlangShell()

function! s:CreateTags()
    let tags = []
    " TODO add support for project root
    for fname in split(globpath(".", "**/*.erl"), "\n")
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
    if !(expand("%:t") == "null.erl") | return "" | endif

    let sname = ''
    let config = ''
    cd %:p:h

    if filereadable("nodename")
        let sname = ' -sname ' . readfile("nodename")[0]
    endif

    let confs = split(globpath(expand("%:p:h"), "**/*.config"), "\n")
    call map(confs, 'fnamemodify(v:val, ":t")')

    if len(confs) > 0
        if len(confs) == 1
            let config = ' -config ' . confs[0]
        else
            let dconfig = "system.config"
            if index(confs, dconfig) == -1 | let dconfig = "" | endif
            let ccomp = "file" " TODO see #1
            let selection = input("Please select config: ", dconfig, ccomp)
            if fnamemodify(selection, ":e") == 'config' && filereadable(selection)
                let config = ' -config ' . selection
            else
                echomsg 'Not a config file' | return
            endif
        endif
    endif

    return sname . config
endfunction

" TODO #1 tab completion
function! ErlMode_ConfigFileCompletionList(A,L,P)
    let configs = []
    for fname in split(globpath(".", "*.config"), "\n")
        call add(configs, fnamemodify(fname, ':t'))
    endfor
    return configs
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
        let args = s:ErlangShellArgs()
        if strlen(args) > 3
            let cmd = 'erl -newshell' . args
        else
            let cmd = 'erl -newshell'
        endif
        let g:erlmode_shell = conque_term#open(cmd, ['belowright vsplit'])
    endif
endfunction

function! s:ErlangShellOpen()
    if exists("g:erlmode_shell") && g:erlmode_shell.active
        return 1
    endif
endfunction

function s:CompileFileInErlangShell()
    if !s:ErlangShellOpen() | echomsg "The shell is not open" | return | endif
    if !expand("%:e") == "erl" | echomsg "Not an erlang file" | endif
    update
    let fn = expand("%:p")
    " TODO check for ebin dir
    let dir = expand("%:p:h")
    " TODO: look for Emakefile for includes and output dir
    let cmd = 'c("'. fn .'", [{outdir,"' . dir . '"}, {i,os:getenv("HOME")++"/svn/modules/"}, debug_info, null]).'
    call g:erlmode_shell.writeln(cmd)
    call g:erlmode_shell.focus()
    normal! $zt
endfunction

function s:RunLineInErlangShell()
    " TODO add support for multiline selection
    if !s:ErlangShellOpen() | echomsg "The shell is not open" | return | endif
    if !expand("%:e") == "erl" | echomsg "Not an erlang file" | endif
    let line = substitute(getline("."), '^\s\+', "", "")
    call g:erlmode_shell.writeln(substitute(line, ",$", ".", ""))
    call g:erlmode_shell.focus()
endfunction

function s:RunTestInErlangShell()
    " TODO option of using testhelper
    if !s:ErlangShellOpen() | echomsg "The shell is not open" | return | endif
    if !expand("%:t") =~ '.*_SUITE\.erl$' | echomsg "Not an test suite file" | endif
    update
    let suite = expand("%:p")
    let logdir = "/tmp/ct_tests"
    if !isdirectory(logdir) | call mkdir(logdir, "p") | endif
    " TODO look for spec for includes and dirs
    let cmd = 'ct:run_test([{suite,"'.suite.'"},{logdir,"'.logdir.'"},{include,os:getenv("HOME")++"/svn/modules/"}]).'
    let cmd_open = 'os:cmd("open '.logdir.'/index.html").'
    call g:erlmode_shell.writeln(cmd)
    call g:erlmode_shell.writeln(cmd_open)
    call g:erlmode_shell.focus()
    normal! $zt
endfunction
