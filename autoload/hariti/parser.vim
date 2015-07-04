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

let s:util= hariti#util#get()

" utility function for internal/external use
function! hariti#parser#apply_defaults(bundles) abort
    if type(a:bundles) != type({})
        throw printf("hariti: Argument must be a Dictionary.")
    endif

    let output= {'bundles': []}
    if !has_key(a:bundles, 'bundles')
        return output
    endif
    for bundle in a:bundles.bundles
        let b= {}
        let b.repository= get(bundle, 'repository', '')
        let b.local= get(bundle, 'local', 0)
        let b.options= get(bundle, 'options', {})
        if !b.local
            let b.options.aliases= get(b.options, 'aliases', [])
            let b.options.enable_if= get(b.options, 'enable_if', '')
            let b.options.depends= get(b.options, 'depends', [])
            let b.options.build= get(b.options, 'build', {})
            let b.options.build.windows= get(b.options.build, 'windows', []) + get(b.options.build, '*', [])
            let b.options.build.mac= get(b.options.build, 'mac', []) + get(b.options.build, '*', [])
            let b.options.build.unix= get(b.options.build, 'unix', []) + get(b.options.build, '*', [])
        else
            let b.options.includes= map(get(b.options, 'includes', []), 'v:val.GlobExpr')
            let b.options.excludes= map(get(b.options, 'excludes', []), 'v:val.GlobExpr')
        endif
        let output.bundles+= [b]
    endfor
    return output
endfunction

function! hariti#parser#parse(input, ...) abort
    let input= type(a:input) == type([]) ? join(a:input, "\n") : a:input
    let ctx= s:parse({
    \   'text': input,
    \   'pos': 0,
    \   'length': strlen(input),
    \})
    " transform raw to parser output
    let bundles= {'bundles': []}
    for bundle in ctx.bundle
        let b= {}
        let b.local= has_key(bundle, 'filepath')
        if b.local
            let b.repository= s:util.unify_separator(expand(bundle.filepath.Path) . '/')
        else
            let b.repository= s:make_url(bundle.repository)
        endif
        let b.options= {}
        for option in get(bundle, 'options', [])
            if has_key(option, 'alias')
                let b.options.aliases= map(copy(option.alias), 'v:val.Identifier')
            elseif has_key(option, 'enable_if')
                " remove ' or "
                let b.options.enable_if= option.enable_if.String[1 : -2]
            elseif has_key(option, 'dependency')
                let b.options.depends= map(option.dependency, 's:make_url(v:val.repository)')
            elseif has_key(option, 'build')
                let b.options.build= {}
                if has_key(option.build, 'windows')
                    let b.options.build.windows= map(option.build.windows, 'v:val.ShellScript')
                endif
                if has_key(option.build, 'mac')
                    let b.options.build.mac= map(option.build.mac, 'v:val.ShellScript')
                endif
                if has_key(option.build, 'unix')
                    let b.options.build.unix= map(option.build.unix, 'v:val.ShellScript')
                endif
                if has_key(option.build, '*')
                    let b.options.build.windows= get(b.options.build, 'windows', []) + []
                    let b.options.build.mac= get(b.options.build, 'mac', []) + []
                    let b.options.build.unix= get(b.options.build, 'unix', []) + []
                endif
            elseif has_key(option, 'includes')
                let b.options.includes= option.includes
            elseif has_key(option, 'excludes')
                let b.options.excludes= option.excludes
            endif
        endfor
        let bundles.bundles+= [b]
    endfor
    return hariti#parser#apply_defaults(bundles)
endfunction

function! s:make_url(repository)
    let size= len(a:repository.Identifier)
    if size == 2
        return 'https://github.com/' . join(a:repository.Identifier, '/')
    elseif size == 1
        return 'https://github.com/vim-scripts/' . join(a:repository.Identifier, '/')
    else
        throw "hariti: Couldn't make url."
    endif
endfunction

"
" parsing functions
"

function! s:parse(in) abort
    let context= s:file(a:in)
    if a:in.pos < a:in.length
        let [lnum, col]= s:where_is(a:in)
        throw printf("hariti: Couldn't consume whole file. (line %d, column %d)", lnum, col)
    endif
    return context
endfunction

function! s:where_is(in) abort
    let lines= split(a:in.text[ : a:in.pos], '\%(\r\n\|\r\|\n\)')
    let lnum= len(lines)
    let col= strlen(lines[-1])

    return [lnum, col]
endfunction

function! s:match(in, pat) abort
    call s:skip(a:in)
    let end= matchend(a:in.text, '^' . a:pat, a:in.pos)
    if end == -1
        let [lnum, col]= s:where_is(a:in)
        throw printf('hariti: Expects %s. (line %d, column %d)', a:pat, lnum, col)
    endif

    let start= a:in.pos
    let a:in.pos= end

    return strpart(a:in.text, start, end - start)
endfunction

function! s:expect(in, pat) abort
    call s:skip(a:in)
    let end= matchend(a:in.text, '^' . a:pat, a:in.pos)
    if end == -1
        let [lnum, col]= s:where_is(a:in)
        throw printf('hariti: Expects %s. (line %d, column %d)', a:pat, lnum, col)
    endif

    let a:in.pos= end
endfunction

function! s:lookahead(in, pat) abort
    call s:skip(a:in)
    return match(a:in.text, '^' . a:pat, a:in.pos) != -1
endfunction

function! s:skip(in) abort
    while match(a:in.text, '^\%(\_s\|#\)', a:in.pos) != -1
        let a:in.pos= matchend(a:in.text, '^\%(\_s\+\|#[^\r\n]*\)', a:in.pos)
    endwhile
endfunction

function! s:file(in) abort
    let context= {}
    let context.bundle= []
    while s:lookahead(a:in, 'use')
        let context.bundle+= [s:bundle(a:in)]
    endwhile
    return context
endfunction

function! s:bundle(in) abort
    let context= {}
    call s:expect(a:in, 'use')
    if s:lookahead(a:in, 'local')
        call s:expect(a:in, 'local')
        let context.filepath= s:filepath(a:in)
        let context.options= []
        while s:lookahead(a:in, '[ie]')
            let context.options+= [s:local_bundle_option(a:in)]
        endwhile
    else
        let context.repository= s:repository(a:in)
        let context.options= []
        while s:lookahead(a:in, '[aedb]')
            let context.options+= [s:bundle_option(a:in)]
        endwhile
    endif
    return context
endfunction

function! s:bundle_option(in) abort
    let context= {}
    if s:lookahead(a:in, 'as')
        call s:expect(a:in, 'as')
        let context.alias= []
        let context.alias+= [s:alias(a:in)]
        while s:lookahead(a:in, ',')
            call s:expect(a:in, ',')
            let context.alias+= [s:alias(a:in)]
        endwhile
    elseif s:lookahead(a:in, 'enable_if')
        call s:expect(a:in, 'enable_if')
        let context.enable_if= {'String': s:String(a:in)}
    elseif s:lookahead(a:in, 'depends')
        call s:expect(a:in, 'depends')
        call s:expect(a:in, '(')
        let context.dependency= []
        while s:lookahead(a:in, '[^)]')
            let context.dependency+= [s:dependency(a:in)]
        endwhile
        call s:expect(a:in, ')')
    elseif s:lookahead(a:in, 'build')
        call s:expect(a:in, 'build')
        call s:expect(a:in, '{')
        let context.build= {}
        while s:lookahead(a:in, '[o]')
            let child_context= s:build_script(a:in)
            let context.build[child_context.platform]= get(context.build, child_context.platform, []) + child_context.script
        endwhile
        call s:expect(a:in, '}')
    else
        let [lnum, col]= s:where_is(a:in)
        throw printf('hariti: Expects \%(as\|enable_if\|depends\). (line %d, column %d)', lnum, col)
    endif
    return context
endfunction

function! s:build_script(in) abort
    let context= {}
    call s:expect(a:in, 'on')
    let context.platform= s:match(a:in, '\%(windows\|mac\|unix\|\*\)')
    let context.script= []
    while s:lookahead(a:in, '-')
        call s:expect(a:in, '-')
        let context.script+= [{'ShellScript': s:ShellScript(a:in)}]
    endwhile
    return context
endfunction

function! s:local_bundle_option(in) abort
    let context= {}
    if s:lookahead(a:in, 'includes')
        call s:expect(a:in, 'includes')
        call s:expect(a:in, '(')
        let context.includes= []
        while s:lookahead(a:in, '\%(\*\{1,2}\|\f\)')
            let context.includes+= [s:globexpr(a:in)]
        endwhile
        call s:expect(a:in, ')')
    elseif s:lookahead(a:in, 'excludes')
        call s:expect(a:in, 'excludes')
        call s:expect(a:in, '(')
        let context.excludes= []
        while s:lookahead(a:in, '\%(\*\{1,2}\|\f\)')
            let context.excludes+= [s:globexpr(a:in)]
        endwhile
        call s:expect(a:in, ')')
    else
        let [lnum, col]= s:where_is(a:in)
        throw printf('hariti: Expects \%(includes\|excludes\). (line %d, column %d)', lnum, col)
    endif
    return context
endfunction

function! s:repository(in) abort
    let context= {}
    let context.Identifier= []
    let context.Identifier+= [s:Identifier(a:in)]
    if s:lookahead(a:in, '/')
        call s:expect(a:in, '/')
        let context.Identifier+= [s:Identifier(a:in)]
    endif

    return context
endfunction

function! s:alias(in) abort
    let context= {}
    let context.Identifier= s:Identifier(a:in)
    return context
endfunction

function! s:dependency(in) abort
    let context= {}
    let context.repository= s:repository(a:in)
    return context
endfunction

function! s:filepath(in) abort
    let context= {}
    let context.Path= s:Path(a:in)
    return context
endfunction

function! s:globexpr(in) abort
    let context= {}
    let context.GlobExpr= s:GlobExpr(a:in)
    return context
endfunction

function! s:Identifier(in) abort
    return s:match(a:in, '[a-zA-Z0-9.$_-]\+')
endfunction

function! s:String(in) abort
    return s:match(a:in, '\%(''\%([^'']\|\\''\)*''\|"\%([^"]\|\\"\)*"\)')
endfunction

function! s:GlobExpr(in) abort
    return s:match(a:in, '\%(\*\{1,2}\|\f\)\+')
endfunction

function! s:Path(in) abort
    return s:match(a:in, '\f\+')
endfunction

function! s:ShellScript(in) abort
    return s:match(a:in, '[^\r\n]*')
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
