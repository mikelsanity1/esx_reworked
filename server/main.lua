AddEventHandler('playerConnecting', function(playerName, _, deferrals)
    local src = ESXR.Ensure(source, 0)

    deferrals.defer()

    if (src <= 0) then
        deferrals.done(_('connecting_error'))
        return
    end

    local name = ESXR.Ensure(playerName, 'Unknown')
    local events = ESXR.Events.GetAllRegisterdEvents('playerConnecting')
    local primaryIdentifier = ESXR.GetIdentifierType()

    if (#events <= 0) then
        deferrals.done()
        return
    end

    local presentCard = CreateNewPresentCard(deferrals)
    local identifiers = GetPlayerIdentifiersAsKeyValueTable(src)
    local tokens = GetPlayerTokens(src)

    local player = {
        source = src,
        name = name,
        identifier = ESXR.Ensure(identifiers[primaryIdentifier], 'unknown'),
        identifiers = identifiers,
        tokens = tokens
    }

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
            deferrals.done(rejectMessage)
            return
        end
    end

    local playerObjects = MySQL.Sync.fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['identifier'] = player.identifier
    })

    local playerObject = ESXR.Ensure(ESXR.Ensure(playerObjects, {})[1], {})

    CreatePlayerClass(playerObject, player.source)

    deferrals.done()
end)

RegisterNetEvent('playerJoining')
AddEventHandler('playerJoining', function()
    local player_src = ESXR.Ensure(source, 0)
    local identifiers = GetPlayerIdentifiersAsKeyValueTable(player_src)
    local primaryIdentifier = ESXR.GetIdentifierType()
    local playerObjects = MySQL.Sync.fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['identifier'] = ESXR.Ensure(identifiers[primaryIdentifier], 'unknown')
    })
    local playerObject = ESXR.Ensure(ESXR.Ensure(playerObjects, {})[1], {})
    local xPlayer = CreatePlayerClass(playerObject, player_src)

    repeat Citizen.Wait(0) until xPlayer ~= nil and xPlayer:IsLoaded() == true

    ESXR.Events.TriggerOnEvent('playerJoining', xPlayer.identifier, xPlayer)
end)