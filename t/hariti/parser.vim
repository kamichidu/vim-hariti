let s:suite= themis#suite('hariti#parser')
let s:assert= themis#helper('assert')

function! s:suite.__parse__()
    let parse= themis#suite('parse')

    function! parse.normaly() abort
        let parser= hariti#parser#new(readfile('t/fixtures/bundles'))
        let data= parser.parse()

        call s:assert.equals(data, {
        \   'bundle': [
        \       {
        \           'repository': {'Identifier': ['kamichidu', 'vim-unite-javaimport']},
        \           'options': [
        \               {'alias': [{'Identifier': 'unite-javaimport'}, {'Identifier': 'javaimport'}]},
        \               {'dependency': [
        \                   {
        \                       'repository': {'Identifier': ['Shougo', 'unite.vim'],},
        \                   },
        \                   {
        \                       'repository': {'Identifier': ['vim-javaclasspath'],},
        \                   },
        \               ]},
        \           ],
        \       },
        \       {
        \           'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath']},
        \           'options': [],
        \       },
        \       {
        \           'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath']},
        \           'options': [
        \               {'dependency': [
        \                   {
        \                       'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath'],},
        \                   },
        \               ]},
        \           ],
        \       },
        \       {
        \           'repository': {'Identifier': ['kamichidu', 'vim-milqi']},
        \           'options': [
        \               {'alias': [{'Identifier': 'milqi'}]},
        \           ],
        \       },
        \       {
        \           'filepath': {'Path': '~/hoge/fuga/'},
        \           'options': [],
        \       },
        \       {
        \           'filepath': {'Path': '~/hoge/fuga'},
        \           'options': [
        \               {'includes': [
        \                   {'GlobExpr': '**/*/piyo/'},
        \               ]},
        \           ],
        \       },
        \       {
        \           'filepath': {'Path': '~/hoge/fuga'},
        \           'options': [
        \               {'excludes': [
        \                   {'GlobExpr': '**/*/piyo/'},
        \               ]},
        \           ],
        \       },
        \       {
        \           'filepath': {'Path': '~/hoge/fuga'},
        \           'options': [
        \               {'includes': [
        \                   {'GlobExpr': '**/*/piyo/'},
        \               ]},
        \               {'excludes': [
        \                   {'GlobExpr': '**/*/piyo/'},
        \               ]},
        \           ],
        \       },
        \   ],
        \})
    endfunction

    function! parse.build_script() abort
        let parser= hariti#parser#new(readfile('t/fixtures/bundles-build'))
        let data= parser.parse()

        call s:assert.equals(data, {
        \   'bundle': [
        \       {
        \           'repository': {'Identifier': ['Shougo', 'neocomplete.vim']},
        \           'options': [
        \               {'alias': [{'Identifier': 'neco'}, {'Identifier': 'neocomplete'}]},
        \               {'enable_if': {'String': '"has(''lua'')"'}},
        \               {'build': {
        \                   'windows': [{'ShellScript': 'win first'}, {'ShellScript': 'win second'}, {'ShellScript': 'win third'}],
        \                   'mac': [{'ShellScript': 'mac first'}],
        \                   'unix': [{'ShellScript': 'unix first'}],
        \                   '*': [],
        \               }},
        \           ],
        \       },
        \   ],
        \})
    endfunction
endfunction
