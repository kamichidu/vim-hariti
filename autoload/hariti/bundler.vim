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

function! s:get_backend(config) abort
    let prefer = a:config.prefer_bundler_backend
    let prefer = 'vim'
    if prefer ==# ''
        if hariti#bundler#go#available()
            let prefer = 'go'
        else
            let prefer = 'vim'
        endif
    endif
    return hariti#bundler#{prefer}#get()
endfunction

function! hariti#bundler#install(config, datalist) abort
    let backend = s:get_backend(a:config)
    echomsg printf('hariti: install by %s', backend.name)
    call backend.install(a:config, a:datalist)
endfunction

function! hariti#bundler#update(config, datalist) abort
    let backend = s:get_backend(a:config)
    echomsg printf('hariti: update by %s', backend.name)
    call backend.update(a:config, a:datalist)
endfunction

function! hariti#bundler#uninstall(config, datalist) abort
    if has('win16') || has('win32') || has('win95') || has('win64')
        let cmd= 'RMDIR /S /Q "%s"'
    else
        let cmd= 'rm -rf "%s"'
    endif

    echomsg printf('hariti: Start %d bundles...', len(a:datalist))
    for data in a:datalist
        echomsg printf('hariti: Uninstall %s', matchstr(data.path, '[^/]\+\ze/$'))
        let output= system(printf(cmd, data.path))
        if v:shell_error != 0
            echohl Error
            echomsg printf('hariti: Error, cannot uninstall "%s"', data.path)
            echomsg output
            echohl None
        endif
    endfor
endfunction

function! hariti#bundler#get() abort
    return {
    \   'install': function('hariti#bundler#install'),
    \   'update': function('hariti#bundler#update'),
    \   'uninstall': function('hariti#bundler#uninstall'),
    \}
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
