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
1. Make a directory and clone this

    ```sh
    $ mkdir -p ~/.hariti/bundle/
    $ cd ~/.hariti/bundle/
    $ git clone https://github.com/kamichidu/vim-hariti
    ```

1. Edit your [bundles file](#bundles-file-grammar)

    bundles file is placed at `~/.hariti/bundles` or `g:hariti_config.source_filename`.
    See [example](#example).

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


Bundles file grammar
------------------------------------------------------------------------------------------------------------------------
Complete grammar description [here](note/config.ebnf).

* Simple usage

    `use {github username}/{github repository}` or `use {plug-in name}`.

* Make plug-in's alias

    `as {alias}`

    {alias} can be used for `hariti#tap()` and in depends section.

* Conditional enabling/disabling plug-in

    `enable_if "{vim expr}"` or `enable_if '{vim expr}'`

    {vim expr} is simply placed in if condition.

* Use other plug-ins are required by

    `depends ({dependant plug-in})`


Example <a name="example">
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
