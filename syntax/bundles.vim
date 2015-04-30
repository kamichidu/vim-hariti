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

" Quit when a syntax file was already loaded
if exists('b:current_syntax')
    finish
endif

let s:save_cpo= &cpo
set cpo&vim

syntax keyword bundlesKeyword use local as enable_if depends build on windows mac unix includes excludes

syntax match bundlesString "'\%([^']\|''\)*'"
syntax match bundlesString '"\%([^"]\|\\"\)*"'

syntax match bundlesLineComment '#[^\r\n]*'

syntax include @ShellScript syntax/sh.vim
syntax region bundlesShellScript start='^\s*-\s\+' end='\%(\r\?\n\)' contains=@ShellScript

highlight default link bundlesKeyword Keyword
highlight default link bundlesString String
highlight default link bundlesLineComment Comment

let b:current_syntax= 'bundles'

let &cpo= s:save_cpo
unlet s:save_cpo
