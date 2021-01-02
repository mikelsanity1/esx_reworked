ESXR.Events:On('playerConnecting', function(player, doneCallback, presentCard)
    local identifiers = ESXR.Ensure(player.identifiers, {})
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