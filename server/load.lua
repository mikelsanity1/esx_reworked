local sqlLoaded = false

MySQL.ready(function()
    sqlLoaded = true
end)

Citizen.CreateThread(function()
    repeat Citizen.Wait(0) until sqlLoaded == true

    local items = ESR.Ensure(MySQL.Sync.fetchAll('SELECT * FROM `items`', {}), {})
    local jobs = ESR.Ensure(MySQL.Sync.fetchAll('SELECT * FROM `jobs`', {}), {})
    local wallets = ESR.Ensure(MySQL.Sync.fetchAll('SELECT * FROM `wallets`', {}), {})
    local storages = ESR.Ensure(MySQL.Sync.fetchAll('SELECT * FROM `storages`', {}), {})

    for k, v in pairs(items) do
        CreateItemClass(v)
    end

    for k, v in pairs(jobs) do
        local job = ESR.Ensure(v, {})

        job.grades = MySQL.Sync.fetchAll('SELECT * FROM `job_grades` WHERE `job_id` = @jobid', {
            ['jobId'] = ESR.Ensure(v.id, 0)
        })

        CreateJobClass(job)
    end

    for k, v in pairs(ESR.Ensure(Configuration.Wallets, {})) do
        local exists, name = false, ESR.Ensure(k, 'unknown')

        for k2, v2 in pairs(wallets) do
            if (ESR.Ensure(v2.name, 'unknown') == name) then
                exists = true
            end
        end

        if (not exists) then
            local id = MySQL.Sync.insert('INSERT INTO `wallets` (`name`, `label`) VALUES (@name, @label)', {
                ['name'] = name,
                ['label'] = ESR.Ensure(_(('wallet_%s'):format(name)), 'Unknown')
            })

            table.insert(wallets, {
                id = ESR.Ensure(id, 0),
                name = name,
                label = ESR.Ensure(_(('wallet_%s'):format(name)), 'Unknown')
            })
        end
    end

    for k, v in pairs(wallets) do
        local name = ESR.Ensure(v.name, 'unknown')
        local label = ESR.Ensure(v.label, 'Unknown')
        local transLabel = _(('wallet_%s'):format(name))

        if (label ~= transLabel) then
            v.label = transLabel

            MySQL.Sync.execute('UPDATE `wallets` SET `label` = @label WHERE `id` = @id', {
                ['label'] = transLabel,
                ['id'] = v.id
            })
        end

        CreateWalletClass(v)
    end

    for k, v in pairs(ESR.Ensure(Configuration.Storages, {})) do
        local exists, name = false, ESR.Ensure(v, 'unknown')

        for k2, v2 in pairs(storages) do
            if (ESR.Ensure(v2.name, 'unknown') == name) then
                exists = true
            end
        end

        if (not exists) then
            local id = MySQL.Sync.insert('INSERT INTO `storages` (`name`, `label`) VALUES (@name, @label)', {
                ['name'] = name,
                ['label'] = _(('storage_%s'):format(name))
            })

            table.insert(storages, {
                id = ESR.Ensure(id, 0),
                name = name
            })
        end
    end

    for k, v in pairs(storages) do
        local name = ESR.Ensure(v.name, 'unknown')
        local label = ESR.Ensure(v.label, 'Unknown')
        local transLabel = _(('storage_%s'):format(name))

        if (label ~= transLabel) then
            v.label = transLabel

            MySQL.Sync.execute('UPDATE `storages` SET `label` = @label WHERE `id` = @id', {
                ['label'] = transLabel,
                ['id'] = v.id
            })
        end

        CreateStorageClass(v)
    end

    ESR.IsLoaded = true
    ESR.PrintSuccess(_('loaded'))
end)