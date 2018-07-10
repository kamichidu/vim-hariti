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

let s:bundler= {
\   'name': 'go',
\}

function! s:custom_out_trans(msg) dict abort
    let eles = split(a:msg, "\t")
    if len(eles) < 2
        return {'tag': '', 'message': string(eles)}
    endif
    let [id, state] = eles[0:1]
    let id = self.id2name[str2nr(id)]
    if state ==# '<START>'
        return {'tag': id, 'label': 'start'}
    elseif state ==# '<FINISH>'
        return {'tag': id, 'label': 'finish'}
    elseif state ==# '<ERROR>'
        let errorlines = split(get(eles, 2, ''), '\\n')
        return map(errorlines, "{'tag': id, 'label': 'error', 'message': v:val}")
    else
        return {'tag': id, 'label': state}
    endif
endfunction

function! s:bundler__install(config, datalist) dict abort
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

    let cmdline = [s:go_backend]
    if get(a:config, 'bundler_concurrency', 0) > 0
        let cmdline += ['-c', a:config.bundler_concurrency]
    endif

    echomsg printf('hariti: Start %d bundles...', len(a:datalist))
    let com = hariti#communicator#new()
    let com.transformer = hariti#communicator#passthru_transformer()
    let com.transformer.id2name = id2name
    let com.transformer.out_trans = function('s:custom_out_trans')
    let com.emitter = hariti#communicator#preview_emitter()
    call com.start(cmdline, join(input, "\n"))
    call com.wait()
endfunction
let s:bundler.install = function('s:bundler__install')

function! s:bundler__update(config, datalist) dict abort
    call self.install(a:config, a:datalist)
endfunction
let s:bundler.update = function('s:bundler__update')

function! hariti#bundler#go#available() abort
    return executable(s:go_backend)
endfunction

function! hariti#bundler#go#get() abort
    return deepcopy(s:bundler)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
