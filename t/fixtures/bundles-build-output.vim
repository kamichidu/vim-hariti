{
    'bundles': [
        {
            'repository': 'https://github.com/Shougo/neocomplete.vim',
            'local': 0,
            'options': {
                'aliases': ['neco', 'neocomplete'],
                'enable_if': "has('lua')",
                'depends': [
                ],
                'build': {
                    'windows': ['win first', 'win second', 'win third'],
                    'mac': ['mac first'],
                    'unix': ['unix first'],
                },
            },
        },
    ],
}
