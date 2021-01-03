group 'user' {
    priority = 1,
    permissions = {
    },
    denies = {
        '**.superadmin',
        '**.admin'
    }
}

group 'admin' {
    priority = 700,
    permissions = {
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