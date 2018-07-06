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

let s:bundler= {
\   'name': 'vim',
\}

function! s:install(config, datalist) abort
    let total= len(a:datalist)
    let done= 0

    for data in a:datalist
        let done+= 1
        let output= system(printf('git clone %s %s', data.url, data.path))
        echomsg printf('(%d/%d) %s', done, total, output)
    endfor
endfunction
let s:bundler.install = function('s:install')

function! s:update(config, datalist) abort
    let total= len(a:datalist)
    let done= 0

    for data in a:datalist
        let done+= 1
        let cwd= getcwd()
        try
            execute 'lcd' data.path

            let command= 'git pull --ff --ff-only'
            let output= system(command)
            echomsg printf('(%d/%d) %s', done, total, output)
        finally
            execute 'lcd' cwd
        endtry
    endfor
endfunction
let s:bundler.update = function('s:update')

function! hariti#bundler#vim#get() abort
    return s:bundler
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
