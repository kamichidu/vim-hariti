{
    'bundles': [
        {
            'repository': 'https://github.com/kamichidu/vim-unite-javaimport',
            'local': 0,
            'options': {
                'aliases': ['unite-javaimport', 'javaimport'],
                'enable_if': '',
                'depends': [
                    'https://github.com/Shougo/unite.vim',
                    'https://github.com/vim-scripts/vim-javaclasspath',
                ],
                'build': {
                    'windows': [],
                    'mac': [],
                    'unix': [],
                },
            },
        },
        {
            'repository': 'https://github.com/kamichidu/vim-javaclasspath',
            'local': 0,
            'options': {
                'aliases': [],
                'enable_if': '',
                'depends': [
                ],
                'build': {
                    'windows': [],
                    'mac': [],
                    'unix': [],
                },
            },
        },
        {
            'repository': 'https://github.com/kamichidu/vim-javaclasspath',
            'local': 0,
            'options': {
                'aliases': [],
                'enable_if': '',
                'depends': [
                    'https://github.com/kamichidu/vim-javaclasspath',
                ],
                'build': {
                    'windows': [],
                    'mac': [],
                    'unix': [],
                },
            },
        },
        {
            'repository': 'https://github.com/kamichidu/vim-milqi',
            'local': 0,
            'options': {
                'aliases': ['milqi'],
                'enable_if': '',
                'depends': [
                ],
                'build': {
                    'windows': [],
                    'mac': [],
                    'unix': [],
                },
            },
        },
        {
            'repository': '/home/user/hoge/fuga/',
            'local': 1,
            'options': {
                'includes': [],
                'excludes': [],
            },
        },
        {
            'repository': '/home/user/hoge/fuga/',
            'local': 1,
            'options': {
                'includes': ['**/*/piyo/'],
                'excludes': [],
            },
        },
        {
            'repository': '/home/user/hoge/fuga/',
            'local': 1,
            'options': {
                'includes': [],
                'excludes': ['**/*/piyo/'],
            },
        },
        {
            'repository': '/home/user/hoge/fuga/',
            'local': 1,
            'options': {
                'includes': ['**/*/piyo/'],
                'excludes': ['**/*/piyo/'],
            },
        },
    ],
}
