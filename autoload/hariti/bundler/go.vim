" The MIT License (MIT)
"
" Copyright (c) 2018 kamichidu
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
let s:save_cpo= &cpo
set cpo&vim

let s:plugin_dir= expand('<sfile>:h:h:h:h')
let s:go_backend= s:plugin_dir . '/bin/hariti'
" detect suffix
if has('win64')
    let s:go_backend.= '.win64.exe'
elseif has('win16') || has('win32') || has('win95')
    let s:go_backend.= '.win32.exe'
elseif has('mac')
    let s:go_backend.= '.mac32'
else
    " this is a vimproc's way
    if glob('/lib*/ld-linux*64.so.2', 1) !=# ''
        let s:go_backend.= '.x64'
    else
        let s:go_backend.= '.x86'
    endif
endif
echomsg 'backend' . s:go_backend

let s:bundler= {
\   'name': 'go',
\}

function! s:install(config, datalist) abort
    let input= []
    let id= 0
    let id2name= {}
    for data in a:datalist
        let id2name[id]= matchstr(data.url, '/\zs[^/]\+$')
        let input+= [join([id, 'git', data.url, data.path], "\t")]
        let id+= 1
    endfor
    if empty(input)
        echomsg 'hariti: Skipping install'
        return
    endif

    echomsg printf('hariti: Start %d bundles...', len(a:datalist))
    let output= system(s:go_backend, join(input, "\n"))
    for line in split(output, "\n")
        let notice= split(line, "\t")
        let [id, state]= [notice[0], notice[1]]
        if state ==# '<START>'
            " no message
        elseif state ==# '<FINISH>'
            echomsg printf('hariti: %s - finish', id2name[id])
        elseif state ==# '<ERROR>'
            echomsg printf('hariti: %s - error - %s', id2name[id], substitute(notice[2], '\\n', "\n", 'g'))
        else
            echomsg printf('hariti: %s - ???', id2name[id])
        endif
    endfor
endfunction
let s:bundler.install = function('s:install')

function! s:update(config, datalist) abort
    call s:install_go(a:config, a:datalist)
endfunction
let s:bundler.update = function('s:update')

function! hariti#bundler#go#available() abort
    return executable(s:go_backend)
endfunction

function! hariti#bundler#go#get() abort
    return s:bundler
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
