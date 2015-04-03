let s:suite= themis#suite('hariti#util')
let s:assert= themis#helper('assert')

function! s:suite.before_each() abort
    let s:util= hariti#util#get()
endfunction

function! s:suite.after_each() abort
    unlet s:util
endfunction

function! s:suite.__unify_separator__() abort
    let unify_separator= themis#suite('unify_separator')

    function! unify_separator.for_winpath() abort
        call s:assert.same(s:util.unify_separator('/hoge\\fuga\piyo\\'), '/hoge/fuga/piyo/')
    endfunction

    function! unify_separator.for_unixpath() abort
        call s:assert.same(s:util.unify_separator('/hoge//fuga/piyo//'), '/hoge/fuga/piyo/')
    endfunction
endfunction

function! s:suite.uniq() abort
    call s:assert.equals(s:util.uniq([1, 2, 3, 1, 2, 3]), [1, 2, 3])
    call s:assert.equals(s:util.uniq([1, 2, 3, 1, 4, 3]), [1, 2, 3, 4])
    call s:assert.equals(s:util.uniq([{}, {}, {}]), [{}])
    call s:assert.equals(s:util.uniq([{'a': 1}, {'a': 2}, {'a': 1}]), [{'a': 1}, {'a': 2}])
endfunction
