" The MIT License (MIT)
"
" Copyright (c) 2015 kamichidu
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
if exists('g:loaded_hariti') && g:loaded_hariti
    finish
endif
let g:loaded_hariti= 1

let s:save_cpo= &cpo
set cpo&vim

let g:hariti_config= get(g:, 'hariti_config', {})

let g:hariti_config.output_filename= get(g:hariti_config, 'output_filename', expand('~/.hariti/setup.vim'))
let g:hariti_config.source_encoding= get(g:hariti_config, 'source_encoding', 'utf8')
let g:hariti_config.source_filename= get(g:hariti_config, 'source_filename', expand('~/.hariti/bundles'))
let g:hariti_config.tap_filename= get(g:hariti_config, 'tap_filename', expand('~/.hariti/tap'))
let g:hariti_config.bundle_directory= get(g:hariti_config, 'bundle_directory', expand('~/.hariti/bundle/'))
let g:hariti_config.backup_directory= get(g:hariti_config, 'backup_directory', expand('~/.hariti/backup/'))

command!
\   HaritiBuild
\   call hariti#builder#build(g:hariti_config)

command!
\   HaritiApply
\   call hariti#loader#load(g:hariti_config)

command!
\   HaritiSetup
\   filetype off | call hariti#loader#load(g:hariti_config) | filetype plugin indent on

command!
\   HaritiDocs
\   call hariti#builder#docs(g:hariti_config)

command!
\   HaritiUpdate
\   call hariti#builder#bundle_update(g:hariti_config)

let &cpo= s:save_cpo
unlet s:save_cpo
