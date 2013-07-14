▁ ▂ ▄ ▅ ▆ ▇  ERLMODE ▇ ▆ ▅ ▄ ▂ ▁
=================================

I dont know much about emacs, or erlang-mode, but this is an attempt to
reproduce the environment.

Installation
------------

If you don't have a preferred installation method, I recommend installing
[pathogen.vim](https://github.com/tpope/vim-pathogen), and then simply copy and
paste:

    cd ~/.vim/bundle
    wget http://conque.googlecode.com/files/conque_2.3.tar.gz
    tar zxvf conque_2.3.tar.gz && mv conque_2.3 ConqueShell
    rm conque_2.3.tar.gz
    git clone git://github.com/expelledboy/vim-erl-mode.git

Plans
-----
I wish to eventually have a complete erlang development environment, using vim
as the core component.

TODO:

    Complete script to create vim compatible tags
    Add ultisnip snippets
    Add rebar file templates
    Add generic Makefile for erlang projects
    Possible move away from ConqueShell (slime?)

License
-------

Copyright (C) 2013 Anthony Jackson (https://github.com/expelledboy)
