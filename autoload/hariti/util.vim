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

function! hariti#util#uniq(list) abort
    let list= []
    let seen= {}
    for X in a:list
        let key= string(X)
        if !has_key(seen, key)
            let list+= [X]
            let seen[key]= 1
        endif
    endfor
    return list
endfunction

function! hariti#util#unify_separator(path) abort
    return substitute(a:path, '[\\/]\+', '/', 'g')
endfunction

function! hariti#util#has(list, expr) abort
    for X in a:list
        if eval(substitute(a:expr, '\<v:val\>', string(X), 'g'))
            return 1
        endif
    endfor
    return 0
endfunction

function! hariti#util#get() abort
    return {
    \   'uniq': function('hariti#util#uniq'),
    \   'unify_separator': function('hariti#util#unify_separator'),
    \   'has': function('hariti#util#has'),
    \}
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
