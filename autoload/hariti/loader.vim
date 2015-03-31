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

function! hariti#loader#load(config)
    if !filereadable(a:config.output_filename) || getftime(a:config.output_filename) < getftime(a:config.source_filename)
        echo 'Building ...'
        call hariti#builder#build(a:config)
    endif

    if !isdirectory(a:config.backup_directory)
        call mkdir(a:config.backup_directory, 'p')
    endif
    call writefile(split(&runtimepath, ','), a:config.backup_directory . '/rtp')

    execute 'source' a:config.output_filename
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
