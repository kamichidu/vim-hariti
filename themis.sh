#!/usr/bin/sh

if ! [ -d .deps ]; then
    git clone https://github.com/thinca/vim-themis .deps/themis/
fi

./.deps/themis/bin/themis --runtimepath $HOME/.bundle/vim-prettyprint/ --recursive --exclude '-output.vim' $*
