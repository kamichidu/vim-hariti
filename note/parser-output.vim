{
\   "bundles": [
\       {
\           "repository": "https://github.com/kamichidu/vim-hariti",
\           "local": 0,
\           "options": {
\               "aliases": ["alias", "alias"],
\               "enable_if": "vim expr",
\               "depends": ["https://github.com/kamichidu/vim-hariti"],
\               "build": {
\                   "windows": ["batch script"],
\                   "mac": ["shell script"],
\                   "unix": ["shell script"]
\               }
\           }
\       },
\       {
\           "repository": "absolute/path/to/repository",
\           "local": 1,
\           "options": {
\               "includes": ["globexpr"],
\               "excludes": ["globexpr"]
\           }
\       }
\   ]
\}
