let container= {
\   "bundles": [
\       {
\           "repository": "https://github.com/kamichidu/vim-hariti",
\           "local": 0,
\           "options": {
\               "aliases": ["alias", "alias"],
\               "enable_if": "vim expr",
\               "depends": ["alias", "url", "name"],
\               "build": {
\                   "windows": ["batch script"],
\                   "mac": ["shell script"],
\                   "unix": ["shell script"]
\               }
\           }
\       },
\       {
\           "repository": "/absolute/path/to/repository/",
\           "local": 1,
\           "options": {
\           }
\       }
\   ]
\}
