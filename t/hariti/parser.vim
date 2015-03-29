let s:suite= themis#suite('hariti#parser')
let s:assert= themis#helper('assert')

function! s:suite.parse()
    let parser= hariti#parser#new(readfile('t/fixtures/bundles'))
    let data= parser.parse()

    call s:assert.equals(data, {
    \   'bundle': [
    \       {
    \           'repository': {'Identifier': ['kamichidu', 'vim-unite-javaimport']},
    \           'alias': [{'Identifier': 'unite-javaimport'}, {'Identifier': 'javaimport'}],
    \           'dependency': [
    \               {
    \                   'repository': {'Identifier': ['Shougo', 'unite.vim'],},
    \               },
    \               {
    \                   'repository': {'Identifier': ['vim-javaclasspath'],},
    \               },
    \           ],
    \       },
    \       {
    \           'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath']},
    \       },
    \       {
    \           'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath']},
    \           'dependency': [
    \               {
    \                   'repository': {'Identifier': ['kamichidu', 'vim-javaclasspath'],},
    \               },
    \           ],
    \       },
    \       {
    \           'repository': {'Identifier': ['kamichidu', 'vim-milqi']},
    \           'alias': [{'Identifier': 'milqi'}],
    \       },
    \   ],
    \})
endfunction
