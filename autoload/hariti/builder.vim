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

let s:plugin_base= expand('<sfile>:p:h:h:h')
let s:util= hariti#util#get()

function! hariti#builder#build(config)
    try
        let orig_rtp= hariti#builder#original_runtimepath()
        let [ext_rtp, aliases]= s:parse(a:config)
        let new_rtp= hariti#builder#merge_runtimepath(orig_rtp, ext_rtp)
        let rtp= hariti#builder#append_after_directory(new_rtp)

        call hariti#builder#write_tapfile(a:config, aliases)
        call hariti#builder#download(ext_rtp)

        call hariti#builder#write_script(a:config, rtp)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! hariti#builder#write_tapfile(config, aliases)
    if !isdirectory(fnamemodify(a:config.tap_filename, ':h'))
        call mkdir(fnamemodify(a:config.tap_filename, ':h'), 'p')
    endif

    call writefile(keys(a:aliases), a:config.tap_filename)
endfunction

function! hariti#builder#download(items)
    let items= filter(copy(a:items), 'has_key(v:val, "url")')

    for item in items
        if !isdirectory(item.path)
            echo "Clone" item.url "to" item.path
            echo system(printf('git clone "%s" "%s"', item.url, item.path))
        endif
    endfor
endfunction

function! hariti#builder#original_runtimepath()
    let paths= split(&runtimepath, ',')
    for pos in range(0, len(paths) - 1)
        if paths[pos] ==# $VIMRUNTIME
            let ret= paths[ : pos]
        endif
    endfor
    " can't detect
    if !exists('ret')
        let ret= paths
    endif
    return map(copy(ret), "{'path': v:val}")
endfunction

function! hariti#builder#append_after_directory(rtp)
    let dirs= []
    for info in a:rtp
        if isdirectory(info.path . '/after/')
            let dirs+= [{'path': info.path . '/after/'}]
        endif
    endfor
    return a:rtp + dirs
endfunction

function! hariti#builder#write_script(config, items)
    let script= ['set runtimepath=']
    for item in a:items
        if has_key(item, 'enable_if')
            let script+= ['if ' . item.enable_if]
        endif
        let script+= ['set runtimepath+=' . item.path]
        if has_key(item, 'enable_if')
            let script+= ['endif']
        endif
    endfor

    " force enable hariti
    if empty(filter(copy(a:items), 'v:val.path ==# s:plugin_base'))
        let script+= ['set runtimepath+=' . s:plugin_base]
    endif

    if !isdirectory(fnamemodify(a:config.output_filename, ':h'))
        call mkdir(fnamemodify(a:config.output_filename, ':h'))
    endif

    call writefile(script, a:config.output_filename)
endfunction

function! hariti#builder#merge_runtimepath(origin, ext)
    " find appendable pos
    for pos in reverse(range(0, len(a:origin) - 1))
        if a:origin[pos].path !~? '[/\\]after[/\\]\?$'
            break
        endif
    endfor

    return a:origin[ : max([pos, 0])] + a:ext + a:origin[pos + 1 : ]
endfunction

function! s:parse(config)
    if !filereadable(a:config.source_filename)
        throw printf("hariti: No such file `%s'", a:config.source_filename)
    endif

    let input= iconv(join(readfile(a:config.source_filename), "\n"), a:config.source_encoding, &encoding)
    let parser= hariti#parser#new(input)
    return s:build_internal(a:config, parser.parse())
endfunction

function! s:build_internal(config, context)
    let aliases= s:make_aliases(a:config, a:context)
    let bundles= []
    for bundle in a:context.bundle
        if s:is_bundle(bundle)
            let bundles+= s:make_bundles(a:config, aliases, bundle)
        else
            let bundles+= s:make_local_bundles(a:config, aliases, bundle)
        endif
    endfor
    let bundles= s:util.uniq(bundles)

    return [bundles, aliases]
endfunction

function! s:is_bundle(bundle) abort
    return has_key(a:bundle, 'repository')
endfunction

function! s:is_local_bundle(bundle) abort
    return has_key(a:bundle, 'filepath')
endfunction

function! s:make_bundles(config, aliases, bundle) abort
    let bundles= []
    if has_key(a:bundle, 'dependency')
        for dependency in a:bundle.dependency
            if has_key(a:aliases, join(dependency.repository.Identifier, '/'))
                let info= a:aliases[join(dependency.repository.Identifier, '/')]
            else
                let info= [{
                \   'url': s:make_url(dependency.repository),
                \   'path': s:make_path(a:config, dependency.repository),
                \}]
                if has_key(a:bundle, 'enable_if')
                    for i in info
                        let i.enable_if= a:bundle.enable_if
                    endfor
                    unlet! i
                endif
            endif
            let bundles+= info
        endfor
    endif

    unlet! info
    let info= {
    \   'url': s:make_url(a:bundle.repository),
    \   'path': s:make_path(a:config, a:bundle.repository),
    \}
    if has_key(a:bundle, 'enable_if')
        let info.enable_if= a:bundle.enable_if.String[1 : -2]
    endif
    return bundles
endfunction

function! s:make_local_bundles(config, aliases, bundle) abort
    let path= expand(a:bundle.filepath.Path)
    if !isdirectory(path)
        return []
    endif

    let dirs= split(globpath(path, '*'), "\n")
    call filter(dirs, 'isdirectory(v:val)')
    call map(dirs, 's:util.unify_separator(v:val . "/")')
    if has_key(a:bundle, 'includes')
        for expr in a:bundle.includes
            let pat= '^' . substitute(expr.GlobExpr, '\*', '.*', 'g') . '$'
            call filter(dirs, 'fnamemodify(v:val, ":t") =~# pat')
        endfor
    endif
    if has_key(a:bundle, 'excludes')
        for expr in a:bundle.excludes
            let pat= '^' . substitute(expr.GlobExpr, '\*', '.*', 'g') . '$'
            call filter(dirs, 'fnamemodify(v:val, ":t") !~# pat')
        endfor
    endif

    return map(dirs, "{'path': v:val}")
endfunction

function! s:make_aliases(config, context) abort
    let bundles= filter(copy(a:context.bundle), 's:is_bundle(v:val)')
    let aliases= {}
    " url, name, alias => data
    for bundle in bundles
        let data= {
        \   'url': s:make_url(bundle.repository),
        \   'path': s:make_path(a:config, bundle.repository),
        \}
        if has_key(bundle, 'enable_if')
            let data.enable_if= bundle.enable_if.String[1 : -2]
        endif

        " url => data
        let url= s:make_url(bundle.repository)
        let aliases[url]= get(aliases, url, []) + [data]
        " name => data
        let name= bundle.repository.Identifier[-1]
        let aliases[name]= get(aliases, name, []) + [data]
        " alias => data
        if has_key(bundle, 'alias')
            for alias in bundle.alias
                let aliases[alias.Identifier]= get(aliases, alias.Identifier, []) + [data]
            endfor
        endif
    endfor
    return aliases
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

function! s:make_path(config, repository)
    let tail= a:repository.Identifier[-1]

    return s:util.unify_separator(join([a:config.bundle_directory, tail], '/'))
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
