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
let s:save_cpo = &cpo
set cpo&vim

let s:communicator = {
\   'name': 'system',
\}

if has('job') && has('channel') && get(g:, 'hariti_communicator_prefer', 'job') ==# 'job'
    function! s:communicator__start(cmdline, ...) dict abort
        let input = get(a:000, 0, '')
        let dir = get(self, 'dir', getcwd())
        let self._job = job_start(a:cmdline, {
        \   'cwd': dir,
        \   'out_cb': self.out_cb,
        \   'err_cb': self.err_cb})

        if input !=# ''
            call ch_sendraw(self._job, input)
        endif
        call ch_close_in(self._job)
    endfunction

    function! s:communicator__status() dict abort
        if !has_key(self, '_job')
            throw 'hariti#communicator: not started job yet'
        endif

        return job_status(self._job)
    endfunction

    function! s:communicator__wait() dict abort
        while self.status() ==# 'run'
            sleep 100m
        endwhile

        let info = job_info(self._job)
        if info.status ==# 'dead'
            return info.exitval
        else
            return 1
        endif
    endfunction
else
    function! s:communicator__start(cmdline, ...) dict abort
        try
            if get(self, 'dir', '') !=# ''
                let _cwd = getcwd()
                execute 'lcd' self.dir
            endif

            let input = get(a:000, 0, '')
            let output = system(join(a:cmdline, ' '), input)
            let self._exitval = v:shell_error
            if self._exitval == 0
                let callback = 'out_cb'
            else
                let callback = 'err_cb'
            endif
            for line in split(output, "\n")
                call self[callback](0, line)
            endfor
        finally
            if exists('_cwd') && _cwd !=# ''
                execute 'lcd' _cwd
            endif
        endtry
    endfunction

    function! s:communicator__status() dict abort
        " system() blocks always
        return 'dead'
    endfunction

    function! s:communicator__wait() dict abort
        if !has_key(self, '_exitval')
            throw 'hariti#communicator: not invoked system() yet'
        endif

        return self._exitval
    endfunction
endif
let s:communicator.start = function('s:communicator__start')
let s:communicator.status = function('s:communicator__status')
let s:communicator.wait = function('s:communicator__wait')

function! s:communicator__out_cb(ch, msg) dict abort
    if !has_key(self, 'transformer')
        let self.transformer = hariti#communicator#passthru_transformer()
    endif
    if !has_key(self, 'emitter')
        let self.emitter = hariti#communicator#echo_emitter()
    endif
    let trans = self.transformer
    let emit = self.emitter

    let msgs = trans.out_trans(a:msg)
    if type(msgs) ==# type([])
        for msg in msgs
            call emit.out_emit(msg)
        endfor
    else
        call emit.out_emit(msgs)
    endif
endfunction
let s:communicator.out_cb = function('s:communicator__out_cb')

function! s:communicator__err_cb(ch, msg) dict abort
    if !has_key(self, 'transformer')
        let self.transformer = hariti#communicator#passthru_transformer()
    endif
    if !has_key(self, 'emitter')
        let self.emitter = hariti#communicator#echo_emitter()
    endif
    let trans = self.transformer
    let emit = self.emitter

    let msgs = trans.err_trans(a:msg)
    if type(msgs) ==# type([])
        for msg in msgs
            call emit.err_emit(msg)
        endfor
    else
        call emit.err_emit(msgs)
    endif
endfunction
let s:communicator.err_cb = function('s:communicator__err_cb')

let s:passthru_transformer = {
\   'name': 'passthru',
\}

function! s:passthru_transformer__out_trans(msg) dict abort
    return a:msg
endfunction
let s:passthru_transformer.out_trans = function('s:passthru_transformer__out_trans')

function! s:passthru_transformer__err_trans(msg) dict abort
    return a:msg
endfunction
let s:passthru_transformer.err_trans = function('s:passthru_transformer__err_trans')

let s:communicator.transformer = deepcopy(s:passthru_transformer)

let s:echo_emitter = {
\   'name': 'echo',
\}

function! s:echo_emitter__out_emit(...) dict abort
    let msg = join(a:000, ' ')
    if msg !=# ''
        echomsg msg
    endif
endfunction
let s:echo_emitter.out_emit = function('s:echo_emitter__out_emit')

function! s:echo_emitter__err_emit(...) dict abort
    let msg = join(a:000, ' ')
    if msg !=# ''
        echoerr msg
    endif
endfunction
let s:echo_emitter.err_emit = function('s:echo_emitter__err_emit')

let s:preview_emitter = {
\   'name': 'preview',
\}

function! s:preview_emitter__open_preview() dict abort
    windo if &previewwindow | let bid = bufnr('%') | endif
    if !exists('bid')
        silent pedit +setlocal\ hidden\ buftype=nofile hariti-progress
        windo if &previewwindow | let bid = bufnr('%') | endif
    endif
    if !exists('bid')
        return [-1, -1]
    endif
    return [bid, bufwinnr(bid)]
endfunction
let s:preview_emitter.open_preview = function('s:preview_emitter__open_preview')

function! s:preview_emitter__out_emit(...) dict abort
    let msg = join(a:000, ' ')
    if msg ==# ''
        return
    endif

    let [bnr, wnr] = self.open_preview()
    if bnr < 0
        echomsg msg
        return
    endif

    call appendbufline(bnr, '$', msg)
    if wnr > 0
        execute wnr . 'windo' 'normal' 'G'
    endif
    redraw
endfunction
let s:preview_emitter.out_emit = function('s:preview_emitter__out_emit')

function! s:preview_emitter__err_emit(...) dict abort
    let msg = join(a:000, ' ')
    if msg ==# ''
        return
    endif

    let [bnr, wnr] = self.open_preview()
    if bnr < 0
        echoerr msg
        return
    endif

    call appendbufline(bnr, '$', msg)
    if wnr > 0
        execute wnr . 'windo' 'normal' 'G'
    endif
    redraw
endfunction
let s:preview_emitter.err_emit = function('s:preview_emitter__err_emit')

function! hariti#communicator#passthru_transformer() abort
    return deepcopy(s:passthru_transformer)
endfunction

function! hariti#communicator#echo_emitter() abort
    return deepcopy(s:echo_emitter)
endfunction

function! hariti#communicator#preview_emitter() abort
    return deepcopy(s:preview_emitter)
endfunction

function! hariti#communicator#new() abort
    return deepcopy(s:communicator)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo