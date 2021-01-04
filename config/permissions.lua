group 'user' {
    priority = 1,
    permissions = {
        'command.news'
    },
    denies = {
        '**.superadmin',
        '**.admin'
    }
}

group 'admin' {
    priority = 700,
    permissions = {
        'command.news'
    },
    denies = {
        '**.superadmin'
    },
    parentOf = 'user'
}

group 'superadmin' {
    priority = 999,
    permissions = { '**' },
    denies = { },
    parentOf = 'admin'
}

job 'unemployed' {
    permissions = {
    },
    denies = {
    }
}