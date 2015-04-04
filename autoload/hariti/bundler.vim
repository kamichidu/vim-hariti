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
let s:save_cpo= &cpo
set cpo&vim

function! hariti#bundler#install(config, datalist) abort
    let backend= 'vim'

    call s:install_{backend}(a:config, a:datalist)
endfunction

function! hariti#bundler#update(config, datalist) abort
    throw "Not yet implemented."
    let rev= get(a:data, 'rev', 'HEAD')
endfunction

function! hariti#bundler#uninstall(config, datalist) abort
    throw "Not yet implemented."
endfunction

function! hariti#bundler#get() abort
    return {
    \   'install': function('hariti#bundler#install'),
    \   'update': function('hariti#bundler#update'),
    \   'uninstall': function('hariti#bundler#uninstall'),
    \}
endfunction

function! s:install_vim(config, datalist) abort
    let total= len(a:datalist)
    let done= 0

    for data in a:datalist
        let done+= 1
        let output= system(printf('git clone %s %s', data.url, data.path))
        echomsg printf('(%d/%d) %s', done, total, output)
    endfor
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
