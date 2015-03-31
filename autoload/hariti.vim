" The MIT License (MIT)
"
" Copyright (c) 2014 kamichidu
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

let s:modtime= 0
let s:names= []

function! hariti#tap(name) abort
    if !filereadable(g:hariti_config.tap_filename)
        return 0
    elseif s:modtime < getftime(g:hariti_config.tap_filename)
        let s:names= readfile(g:hariti_config.tap_filename)
    endif

    return index(s:names, a:name) != -1
endfunction

" function! s:download(prefix, plugins)
"     let git_protocols= filter(copy(a:plugins), 'v:val.protocol ==# "git"')
"     let hg_protocols= filter(copy(a:plugins), 'v:val.protocol ==# "hg"')
"
"     let save_cwd= getcwd()
"     try
"         execute 'lcd' a:prefix
"
"         lua << ...
"         local urls= vim.eval('urls')
"
"         local gits= {}
"         for url in urls() do
"             table.insert(gits, io.popen('GIT_ASKPASS=/usr/bin/false git clone ' .. url))
"         end
"
"         for git in ipairs(gits) do
"             local ok, msg= git:close()
"             if not ok then
"                 vim.command('hariti: Something wrong `' .. msg .. "'.")
"             end
"         end
"
"     finally
"         execute 'lcd' save_cwd
"     endtry
" endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
