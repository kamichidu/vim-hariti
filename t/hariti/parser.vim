let s:suite= themis#suite('hariti#parser')
let s:assert= themis#helper('assert')

function! s:suite.before() abort
    let s:save_home= $HOME
    let $HOME= 't/dirs'
endfunction

function! s:suite.after() abort
    let $HOME= s:save_home
    unlet s:save_home
endfunction

function! s:suite.__parse__()
    let parse= themis#suite('parse')

    function! parse.normaly() abort
        let expect= eval(join(readfile('t/fixtures/bundles-output.vim'), ''))
        let data= hariti#parser#parse(readfile('t/fixtures/bundles'))

        call s:assert.equals(data, expect)
    endfunction

    function! parse.build_script() abort
        let expect= eval(join(readfile('t/fixtures/bundles-build-output.vim'), ''))
        let data= hariti#parser#parse(readfile('t/fixtures/bundles-build'))

        call s:assert.equals(data, expect)
    endfunction
endfunction

function! s:suite.apply_defaults()
    let incomplete= {}
    call s:assert.equals(hariti#parser#apply_default_container(incomplete), {
    \   'bundles': [],
    \})

    let incomplete= {'bundles': [{}, {'local': 1}]}
    call s:assert.equals(hariti#parser#apply_default_container(incomplete), {
    \   'bundles': [
    \       {
    \           'repository': '',
    \           'local': 0,
    \           'options': {
    \               'aliases': [],
    \               'enable_if': '',
    \               'depends': [],
    \               'build': {
    \                   'windows': [],
    \                   'mac': [],
    \                   'unix': [],
    \               },
    \           },
    \       },
    \       {
    \           'repository': '',
    \           'local': 1,
    \           'options': {
    \               'aliases': [],
    \               'enable_if': '',
    \               'depends': [],
    \               'build': {
    \                   'windows': [],
    \                   'mac': [],
    \                   'unix': [],
    \               },
    \           },
    \       },
    \   ],
    \})
endfunction
