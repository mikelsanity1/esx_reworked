AddEventHandler('playerConnecting', function(playerName, _, deferrals)
    local src = ESXR.Ensure(source, 0)

    deferrals.defer()

    if (src <= 0) then
        deferrals.done(_('connecting_error'))
        return
    end

    local name = ESXR.Ensure(playerName, 'Unknown')
    local events = ESXR.Events.GetAllRegisterdEvents('playerConnecting')

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
        identifier = GetPrimaryIdentifier(src),
        identifiers = identifiers,
        tokens = tokens
    }

    repeat Citizen.Wait(0) until ESXR.IsLoaded == true

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

    UpdatePlayerSource(player.source)

    deferrals.done()
end)

RegisterNetEvent('playerJoining')
AddEventHandler('playerJoining', function()
    repeat Citizen.Wait(0) until ESXR.IsLoaded == true

    local player_src = ESXR.Ensure(source, 0)
    local xPlayer = UpdatePlayerSource(player_src)

    repeat Citizen.Wait(0) until xPlayer ~= nil and xPlayer:IsLoaded() == true

    ESXR.Events.TriggerOnEvent('playerJoining', xPlayer.identifier, xPlayer)
    ESXR.Events.TriggerOnEvent('groupJoining', xPlayer.group, xPlayer)
end)

AddEventHandler('playerDropped', function(reason)
    local player_src = ESXR.Ensure(source, 0)
    local xPlayer = GetPlayerBySource(player_src)

    ESXR.Events.TriggerOnEvent('playerDropped', xPlayer.identifier, xPlayer, reason)
    ESXR.Events.TriggerOnEvent('groupDropped', xPlayer.group, xPlayer, reason)
end)

ESXR.RegisterServerEvent('esxr:onPlayerJoined', function(source)
    repeat Citizen.Wait(0) until ESXR.IsLoaded == true

    local xPlayer = UpdatePlayerSource(source)

    repeat Citizen.Wait(0) until xPlayer ~= nil and xPlayer:IsLoaded() == true

    ESXR.Print(_('player_connected', GetPlayerName(source), source))

    if (xPlayer == nil) then return end

    xPlayer:TriggerEvent('esxr:playerInfo', {
        source = xPlayer.source,
        name = xPlayer.name,
        group = xPlayer.group,
        job = xPlayer.job,
        job2 = xPlayer.job2,
        position = xPlayer.position
    })
end, 0, 1)