group 'user' {
    priority = 1,
    permissions = {
        'command.user'
    },
    denies = {
        '**.superadmin',
        '**.admin'
    }
}

group 'admin' {
    priority = 700,
    permissions = {
        'command.admin'
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