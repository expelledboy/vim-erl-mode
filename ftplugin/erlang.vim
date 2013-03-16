if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

execute 'set tags+=./'.g:erlmode_tags_file.';'.$HOME
setlocal iskeyword+=:

if g:erlmode_use_mappings
    nnoremap <buffer> <leader>re :ErlModeOpenShell<cr>
    nnoremap <buffer> <leader>rr :ErlModeCompileFile<cr>
endif
