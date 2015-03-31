hariti
========================================================================================================================
This is a minimal plug-in manager for vim.
hariti is inspired by [neobundle.vim](https://github.com/Shougo/neobundle.vim), and this has lesser features.

hariti has some concepts:

1. Start-up time is most important
1. Minimal feature
1. Clean `&runtimepath`

*hariti is just an alpha version.*


Installation
------------------------------------------------------------------------------------------------------------------------
1. Make a directory and clone this.

    ```sh
    $ mkdir -p ~/.hariti/bundle/
    $ cd ~/.hariti/bundle/
    $ git clone https://github.com/kamichidu/vim-hariti
    ```

1. Edit your `$MYVIMRC`

    ```vim
    if has('vim_starting')
        " For hariti work
        set runtimepath+=$HOME/.hariti/bundle/vim-hariti/
        runtime plugin/hariti.vim
    endif

    " Apply plug-ins to your &runtimepath
    HaritiSetup
    ```

Usage
------------------------------------------------------------------------------------------------------------------------
* HaritiSetup, HaritiApply

    It applies your plug-ins to your &runtimepath.
    HaritiSetup is equivalent to:

    ```vim
    filetype off
    HaritiApply
    filetype plugin indent on
    ```

* HaritiBuild

    It builds your &runtimepath without applying.
    You can execute this command when you edit [bundles file](#bundles-file-grammar).

* hariti#tap({name})

    It returns 1 if a plug-in it has a {name} is installed.
    Otherwise, 0.


Example
------------------------------------------------------------------------------------------------------------------------
bundles file:

```txt
use kamichidu/vim-hariti
    as hariti

use kamichidu/vim-unite-javaimport
    as unite-javaimport
    depends (
        Shougo/unite.vim
        kamichidu/vim-javaclasspath
    )

use Shougo/neocomplete.vim
    as neco, neocomplete
    enable_if "has('lua')"

use Shougo/neocomplcache.vim
    as neco, neocomplcache
    enable_if "!has('lua')"

use eagletmt/neco-ghc
    depends (
        neco
    )
```
