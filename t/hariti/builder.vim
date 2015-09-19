let s:suite= themis#suite('hariti#builder')
let s:assert= themis#helper('assert')

function! s:suite.test()
    call hariti#builder#build(g:hariti_config)
endfunction
