ESXR.Events.On('playerConnecting', function(player, doneCallback, presentCard)
    local identifier = ESXR.Ensure(player.identifier, 'unknown')
    local identifiers = ESXR.Ensure(player.identifiers, {})

    if (identifier == 'unknown' or identifier == 'none') then
        doneCallback(_(('missing_%s'):format(ESXR.GetIdentifierType())))
        return
    end

    if (not ESXR.IsLoaded) then
        doneCallback(_('not_loaded'))
        return
    end

    ESXR.Print(_('player_connecting', ESXR.Ensure(player.name, 'Unknown')))

    identifiers.name = ESXR.Ensure(player.name, 'Unknown')

    local id = MySQL.Sync.insert('INSERT INTO `player_identifiers` (`name`, `steam`, `license`, `license2`, `xbl`, `live`, `discord`, `fivem`, `ip`) VALUES (@name, @steam, @license, @license2, @xbl, @live, @discord, @fivem, @ip)', identifiers)

    id = ESXR.Ensure(id, 0)

    if (id <= 0) then
        doneCallback()
        return
    end

    for k, v in pairs(ESXR.Ensure(player.tokens, {})) do
        k = ESXR.Ensure(k, 0)

        for tk, tv in pairs(ESXR.Ensure(v, {})) do
            MySQL.Sync.insert('INSERT INTO `player_tokens` (`identifier_id`, `prefix`, `value`) VALUES (@id, @prefix, @value)', {
                ['id'] = id,
                ['prefix'] = k,
                ['value'] = ESXR.Ensure(tv, 'unknown')
            })
        end
    end

    doneCallback()
end)

ESXR.Events.On('playerConnecting', function(player, doneCallback, presentCard)
    local identifier = ESXR.Ensure(player.identifier, 'unknown')

    if (identifier == 'unknown' or identifier == 'none') then
        doneCallback(_(('missing_%s'):format(ESXR.GetIdentifierType())))
        return
    end

    MySQL.Async.fetchScalar('SELECT COUNT(*) AS `count` FROM `players` WHERE `identifier` = @identifier', {
        ['identifier'] = identifier
    }, function(count)
        count = ESXR.Ensure(count, 0)

        if (count > 0) then
            MySQL.Async.execute('UPDATE `players` SET `name` = @name WHERE `identifier` = @identifier', {
                ['name'] = ESXR.Ensure(player.name, 'Unknown'),
                ['identifier'] = identifier
            }, function()
                doneCallback()
            end)
            return
        end

        local events = ESXR.Events.GetAllRegisterdEvents('newPlayerConnecting')

        for k, v in pairs(events) do
            local continue, canConnect, rejectMessage = false, false, nil

            presentCard:reset()

            local func = ESXR.Ensure(v, function(_, done, _) done() end)
            local ok = xpcall(func, ESXR.PrintError, player, function(msg)
                msg = ESXR.Ensure(msg, '')
                canConnect = ESXR.Ensure(msg == '', false)

                if (not canConnect) then
                    rejectMessage = msg
                end

                continue = true
            end, presentCard)

            repeat Citizen.Wait(0) until continue == true

            if (not ok) then
                canConnect = false
                rejectMessage = _('connecting_error')
            end

            if (not canConnect) then
                doneCallback(rejectMessage)
                return
            end
        end

        doneCallback()
    end)
end)

ESXR.Events.On('newPlayerConnecting', function(player, doneCallback, presentCard)
    local defaultJob = ESXR.Ensure(ESXR.Ensure(ESXR.GetConfig(), {}).DefaultJob, 'unemployed')
    local jobId = ESXR.Ensure(ESXR.Ensure(ESXR.References.Jobs, {})[defaultJob], 0)

    if (jobId <= 0) then
        doneCallback(_('player_create_failed'))
        return
    end

    local playerId = MySQL.Sync.insert('INSERT INTO `players` (`identifier`, `name`, `job`, `grade`) VALUES (@identifier, @name, @job, @grade)', {
        ['identifier'] = player.identifier,
        ['name'] = player.name,
        ['job'] = jobId,
        ['grade'] = 0
    })

    playerId = ESXR.Ensure(playerId, 0)

    if (playerId <= 0) then
        doneCallback(_('player_create_failed'))
        return
    end

    for k, v in pairs(ESXR.Ensure(ESXR.Wallets, {})) do
        MySQL.Sync.insert('INSERT INTO `player_wallets` (`wallet_id`, `player_id`, `saldo`) VALUES (@walletId, @playerId, @saldo)', {
            ['walletId'] = v.id,
            ['playerId'] = playerId,
            ['saldo'] = ESXR.Ensure(v.default, 0)
        })
    end

    ESXR.Events.TriggerOnEvent('newPlayerCreated', nil, player, playerId)

    doneCallback()
end)

ESXR.Events.On('newPlayerCreated', function(player, playerId)
    ESXR.PrintSuccess(_('player_create', player.name, playerId))
end)

ESXR.Events.On('playerJoining', function(xPlayer)
    ESXR.Print(_('player_loaded', xPlayer.name, xPlayer.source))
end)