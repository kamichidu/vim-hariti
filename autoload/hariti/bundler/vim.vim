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

let s:util = hariti#util#get()

let s:group_transformer = {
\   'name': 'group',
\}

function! s:group_transformer__out_trans(msg) dict abort
    " be quiet
    return []
endfunction
let s:group_transformer.out_trans = function('s:group_transformer__out_trans')

function! s:group_transformer__err_trans(msg) dict abort
    let errorlines = split(a:msg, "\n")
    return [printf('%s - error:', self.group_name)] + map(errorlines, '"\t" . v:val')
endfunction
let s:group_transformer.err_trans = function('s:group_transformer__err_trans')

let s:bundler= {
\   'name': 'vim',
\}

function! s:bundler__install(config, datalist) dict abort
    let coms = []
    for data in a:datalist
        call self.semaphore(a:config, coms)

        let name = matchstr(data.url, '/\zs[^/]\+$')
        let com = hariti#communicator#new()
        let com.transformer = deepcopy(s:group_transformer)
        let com.transformer.group_name = name
        let com.emitter = hariti#communicator#preview_emitter()
        if isdirectory(s:util.unify_separator(data.path . '/.git/'))
            call com.emitter.out_emit(printf('%s - skip', name))
        else
            call com.emitter.out_emit(printf('%s - start', name))
            call com.start(['git', 'clone', data.url, data.path])
            let coms += [com]
        endif
    endfor
    for com in coms
        let exitval = com.wait()
        call com.emitter.out_emit(printf('%s - %s', com.transformer.group_name, exitval == 0 ? 'finish' : 'error'))
    endfor
endfunction
let s:bundler.install = function('s:bundler__install')

function! s:bundler__update(config, datalist) dict abort
    let concurrency = get(a:config, 'bundler_concurrency', 4)
    let coms = []
    for data in a:datalist
        call self.semaphore(a:config, coms)

        let name = matchstr(data.url, '/\zs[^/]\+$')
        let com = hariti#communicator#new()
        let com.transformer = deepcopy(s:group_transformer)
        let com.transformer.group_name = name
        let com.emitter = hariti#communicator#preview_emitter()
        call com.emitter.out_emit(printf('%s - start', name))
        if isdirectory(s:util.unify_separator(data.path . '/.git/'))
            let com.dir = data.path
            call com.start(['git', 'pull', '--ff', '--ff-only'])
        else
            call com.start(['git', 'clone', data.url, data.path])
        endif
        let coms += [com]
    endfor
    for com in coms
        let exitval = com.wait()
        call com.emitter.out_emit(printf('%s - %s', com.transformer.group_name, exitval == 0 ? 'finish' : 'error'))
    endfor
endfunction
let s:bundler.update = function('s:bundler__update')

function! s:bundler__semaphore(config, coms) dict abort
    let concurrency = get(a:config, 'bundler_concurrency', 4)
    if len(a:coms) < concurrency
        return
    endif
    while 1
        let n = 0
        for com in a:coms
            if com.status() ==# 'run'
                let n += 1
            endif
        endfor
        if n < concurrency
            return
        endif
    endwhile
endfunction
let s:bundler.semaphore = function('s:bundler__semaphore')

function! hariti#bundler#vim#get() abort
    return deepcopy(s:bundler)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
