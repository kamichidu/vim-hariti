let s:suite= themis#suite('hariti')
let s:assert= themis#helper('assert')

" function! s:parse(filename)
"     return hariti#parser#new(readfile(a:filename)).parse()
" endfunction
"
" function! s:suite.merge_runtimepath()
"     call s:assert.equals(
"     \   hariti#merge_runtimepath(['/home/piyo/fuga', '/home/piyo/.vim', '/home/piyo/vimfiles', '/home/piyo/.vim/after'], ['hoge', 'fuga']),
"     \   ['/home/piyo/fuga', '/home/piyo/.vim', '/home/piyo/vimfiles', 'hoge', 'fuga', '/home/piyo/.vim/after']
"     \)
" endfunction
"
" function! s:suite.make_dependency_tree()
"     let ctx= s:parse('t/fixtures/bundles')
"
"     call themis#log(PP(ctx))
"
"     let dep_tree= hariti#make_dependency_tree(ctx)
"     call themis#log(PP(dep_tree))
" endfunction
