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
let s:bundler= hariti#bundler#get()
let s:plugin_base= s:util.unify_separator(expand('<sfile>:p:h:h:h') . '/')

function! hariti#builder#build(config) abort
    try
        let orig_container= hariti#builder#original_runtimepath(a:config)
        let ext_container= s:parse(a:config)
        let container= hariti#builder#merge_runtimepath(orig_container, ext_container)
        let container= hariti#builder#append_after_directory(container)

        " call hariti#builder#write_tapfile(a:config, bundles)
        " call hariti#builder#download(a:config, bundles)
        " call hariti#builder#run_script(a:config, bundles)
        " call hariti#builder#helptags(a:config, bundles)

        call hariti#builder#write_script(a:config, container)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! hariti#builder#write_tapfile(config, bundles) abort
    if !isdirectory(fnamemodify(a:config.tap_filename, ':h'))
        call mkdir(fnamemodify(a:config.tap_filename, ':h'), 'p')
    endif

    let script= []
    for key in keys(a:aliases)
        let expr= []
        for data in a:aliases[key]
            let condition= []
            if has_key(data, 'enable_if')
                let condition+= [data.enable_if]
            endif
            let condition+= [printf('isdirectory(%s)', string(data.path))]
            let expr+= ['(' . join(condition, ' && ') . ')']
        endfor
        let script+= [key . "\t" . join(expr, ' || ')]
    endfor

    call writefile(script, a:config.tap_filename)
endfunction

function! hariti#builder#download(config, rtp) abort
    " only downloadables
    let items= filter(copy(a:rtp), 'has_key(v:val, "url")')
    " not yet downloaded
    let items= filter(copy(items), '!isdirectory(v:val.path)')

    call s:bundler.install(a:config, items)
endfunction

function! hariti#builder#original_runtimepath(config) abort
    let container= {'bundles': [], 'aliases': {}}

    " {backup_directory}/rtp always has original runtimepath
    " if has('vim_starting') is 1, getting rtp from &runtimepath is faster than reading file
    let backup_filename= s:util.unify_separator(a:config.backup_directory . '/rtp')

    if has('vim_starting') || !filereadable(backup_filename)
        let paths= split(&runtimepath, ',')
    else
        let paths= readfile(backup_filename)
    endif

    for path in paths
        let container.bundles+= [{
        \   'repository': s:util.unify_separator(path . '/'),
        \   'local': 1,
        \}]
    endfor
    let container= hariti#parser#apply_default_container(container)
    let container.aliases= {}

    return container
endfunction

function! hariti#builder#append_after_directory(bundles) abort
    let bundles= filter(copy(a:bundles.bundles), 'v:val.local')
    let after_bundles= []
    for bundle in bundles
        let after_path= s:util.unify_separator(bundle.repository . '/after/')
        if isdirectory(after_path)
            let after_bundle= deepcopy(bundle)
            let after_bundle.repository= after_path

            let after_bundles+= [after_bundle]
        endif
    endfor

    let out= deepcopy(a:bundles)
    let out.bundles+= after_bundles
    return out
endfunction

function! hariti#builder#write_script(config, container) abort
    " force enable hariti
    let script= ['set runtimepath=' . s:plugin_base]
    for bundle in a:container.bundles
        if !bundle.local && bundle.options.enable_if !=# ''
            let script+= ['if ' . bundle.options.enable_if]
        endif
        let script+= ['set runtimepath+=' . s:get_path(a:config, bundle)]
        if !bundle.local && bundle.options.enable_if !=# ''
            let script+= ['endif']
        endif
    endfor

    if !isdirectory(fnamemodify(a:config.output_filename, ':h'))
        call mkdir(fnamemodify(a:config.output_filename, ':h'))
    endif
    call writefile(script, a:config.output_filename)
endfunction

function! s:get_path(config, bundle) abort
    if a:bundle.local
        return a:bundle.repository
    endif

    let name= fnamemodify(a:bundle.repository, ':t')
    if name ==# ''
        throw printf("hariti: Internal error, got empty dirname from `%s'", a:bundle.repository)
    endif
    let path= join([a:config.bundle_directory, name], '/')
    return s:util.unify_separator(path . '/')
endfunction

function! hariti#builder#merge_runtimepath(orig_container, ext_container) abort
    " find appendable pos
    let container= deepcopy(a:orig_container)
    for [alias, bundles] in items(a:ext_container.aliases)
        let container.aliases[alias]= get(container.aliases, alias, []) + bundles
    endfor

    let paths= map(filter(copy(container.bundles), 'v:val.local'), 'v:val.repository')
    let pos= index(paths, s:util.unify_separator($VIMRUNTIME . '/'))

    let container.bundles= container.bundles[ : max([pos - 1, 0])] + a:ext_container.bundles + container.bundles[pos : ]
    return container
endfunction

function! hariti#builder#run_script(config, rtp) abort
    let bundles= filter(copy(a:rtp), 'has_key(v:val, "build")')

    for bundle in bundles
        let script= []
        if has('win16') || has('win32') || has('win64') || has('win95')
            let script+= get(bundle.build, 'windows', [])
        elseif has('mac')
            let script+= get(bundle.build, 'mac', [])
        else
            let script+= get(bundle.build, 'unix', [])
        endif
        let script+= get(bundle.build, '*', [])

        let cwd= getcwd()
        try
            execute 'lcd' bundle.path

            echomsg printf('hariti: Executing user build script for %s', matchstr(bundle.path, '/\zs[^/]\+$'))
            for cmd in script
                for output in split(system(cmd), "\n")
                    echomsg output
                endfor
            endfor
        finally
            execute 'lcd' cwd
        endtry
    endfor
endfunction

function! hariti#builder#docs(config) abort
    try
        let [ext_rtp, _]= s:parse(a:config)

        call hariti#builder#helptags(a:config, ext_rtp)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! hariti#builder#helptags(config, rtp) abort
    echomsg 'hariti: Generating helptags...'
    let bundles= filter(copy(a:rtp), 'isdirectory(v:val.path . "/doc/") && globpath(v:val.path . "/doc/", "**") !=# ""')

    for bundle in bundles
        let doc_path= s:util.unify_separator(bundle.path . '/doc/')
        if globpath(doc_path, 'tags*') ==# ''
            execute 'helptags' doc_path
        endif
    endfor
endfunction

function! hariti#builder#bundle_install(config) abort
    echomsg 'hariti: Installing bundles...'
    try
        let [ext_rtp, _]= s:parse(a:config)
        let bundles= filter(copy(ext_rtp), 'has_key(v:val, "url") && !isdirectory(v:val.path)')

        call hariti#builder#download(a:config, bundles)
        call hariti#builder#run_script(a:config, bundles)
        call hariti#builder#helptags(a:config, bundles)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! hariti#builder#bundle_update(config) abort
    echomsg 'hariti: Updating bundles...'
    try
        let [ext_rtp, _]= s:parse(a:config)
        let bundles= filter(copy(ext_rtp), 'has_key(v:val, "url") && isdirectory(v:val.path)')

        call s:bundler.update(a:config, bundles)
        call hariti#builder#run_script(a:config, bundles)
        call hariti#builder#helptags(a:config, bundles)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! hariti#builder#bundle_clean(config) abort
    echomsg 'hariti: Cleaning bundles...'
    try
        let [ext_rtp, _]= s:parse(a:config)
        let bundles= filter(copy(ext_rtp), 'has_key(v:val, "url")')
        let targets= []

        for dir in filter(split(globpath(a:config.bundle_directory, '*'), "\n"), 'isdirectory(v:val)')
            let dir= s:util.unify_separator(dir . '/')
            let expr= printf('v:val.path ==# ''%s''', dir)
            if !s:util.has(bundles, expr)
                let targets+= [{
                \   'path': dir,
                \}]
            endif
        endfor

        call s:bundler.uninstall(a:config, targets)
    catch
        echohl Error
        echomsg v:throwpoint
        echomsg v:exception
        echohl None
    endtry
endfunction

function! s:parse(config) abort
    if filereadable(a:config.source_filename)
        let input= iconv(join(readfile(a:config.source_filename), "\n"), a:config.source_encoding, &encoding)
    else
        let input= ''
    endif

    let container= hariti#parser#parse(input)
    let container= s:rebuild_with_deps(container)
    let container.bundles= s:util.uniq(container.bundles)
    let container.aliases= s:make_aliases(a:config, container)
    return container
endfunction

function! s:rebuild_with_deps(container) abort
    let container= {'bundles': [], 'aliases': []}
    for bundle in a:container.bundles
        if !bundle.local
            for depend in bundle.options.depends
                let container.bundles+= [s:find_or_create_bundle(a:container, depend)]
            endfor
        endif
        let container.bundles+= [bundle]
    endfor
    return container
endfunction

function! s:find_or_create_bundle(container, query) abort
    for bundle in a:container.bundles
        " as is?
        if bundle.repository ==# a:query
            return bundle
        endif
        " name?
        if matchstr(bundle.repository, '[^/]\+\ze/\?$') ==# a:query
            return bundle
        endif
        " gh-username and repo?
        if matchstr(bundle.repository, '[^/]\+/[^/]\+$') ==# a:query
            return bundle
        endif
        if !bundle.local
            " in alias?
            if !empty(filter(copy(bundle.options.aliases), 'a:query ==# v:val'))
                return bundle
            endif
        endif
    endfor

    " url?
    if a:query =~# '^https\?://'
        let url= a:query
    else
        " assum github repo
        let elements= split(a:query, '/')
        if len(elements) == 2
            let url= join(['https://github.com'] + elements, '/')
        elseif len(elements) == 1
            let url= join(['https://github.com/vim-scripts'] + elements, '/')
        else
            throw printf("hariti: Couldn't resolve `%s'", a:query)
        endif
    endif
    return hariti#parser#apply_default_bundle({'repository': url, 'local': 0})
endfunction

function! s:make_aliases(config, bundles) abort
    let bundles= filter(copy(a:bundles.bundles), '!v:val.local')
    let aliases= {}
    " url, name, alias => [bundle]
    for bundle in bundles
        " url => data
        let url= bundle.repository
        let aliases[url]= get(aliases, url, []) + [bundle]
        " name => data
        let name= fnamemodify(bundle.repository, ':t')
        let aliases[name]= get(aliases, name, []) + [bundle]
        " alias => data
        for alias in bundle.options.aliases
            let aliases[alias]= get(aliases, alias, []) + [bundle]
        endfor
    endfor
    return aliases
endfunction

function! s:make_path(config, repository) abort
    let tail= a:repository.Identifier[-1]

    return s:util.unify_separator(join([a:config.bundle_directory, tail . '/'], '/'))
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
