ESXR.ParseCommandInput = function(command, index, input, source)
    command = ESXR.Ensure(command, 'unknown')
    index = ESXR.Ensure(index, 0)
    source = ESXR.Ensure(source, 0)

    if (command == 'unknown' or index == 0) then
        return nil
    end

    local cmd = ESXR.Commands[command]

    if (cmd == nil) then return nil end

    local arguments = ESXR.Ensure(cmd.arguments, {})
    local argument = arguments ~= nil and arguments[index] or nil

    if (argument == nil) then return nil end

    local argumentType = ESXR.Ensure(argument.type, 'unknown')
    argumentType = string.lower(argumentType)

    if (argumentType == 'unknown') then return nil end
    if (argumentType == 'any') then return input end

    if (argumentType == 'number') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, 0))
    elseif (argumentType == 'string') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, ''))
    elseif (argumentType == 'boolean') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, false))
    elseif (argumentType == 'table') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, { }))
    elseif (argumentType == 'vector2') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, vector2(0, 0)))
    elseif (argumentType == 'vector3') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, vector3(0, 0, 0)))
    elseif (argumentType == 'vector4') then
        return ESXR.Ensure(input, ESXR.Ensure(argument.default, vector4(0, 0, 0, 0)))
    elseif (argumentType == 'me') then
        return GetPlayerBySource(source)
    elseif (argumentType == 'player') then
        return GetPlayerBySource(ESXR.Ensure(input, 0))
    elseif (argumentType == 'job') then
        local name = ESXR.Ensure(input, 'unknown')
        local jobId = ESXR.Ensure(ESXR.References.Jobs[name], 0)

        return ESXR.Jobs[jobId] or nil
    end

    return nil
end

ESXR.ExecuteCommand = function(command, playerId, args)
    local cmd = ESXR.Commands[command]

    if (cmd == nil) then return end

    playerId = ESXR.Ensure(playerId, 0)
    args = ESXR.Ensure(args, {})

    if (playerId <= 0 and not cmd.consoleAllowed) then
        ESXR.PrintError(_('commanderror_console'))
        return
    end

    local xPlayer = playerId > 0 and GetPlayerBySource(playerId) or nil
    local arguments = {}

    for k, v in pairs(cmd.arguments) do
        local argumentName = ESXR.Ensure(v.name, 'unknown')

        arguments[argumentName] = ESXR.ParseCommandInput(command, k, args[k] or nil, playerId)
    end

    local allowed = playerId <= 0 and true or (xPlayer ~= nil and xPlayer:HasPermission(('command.%s'):format(cmd.name)))

    if (not allowed) then
        return
    end

    ESXR.TryCatch(cmd.callback, ESXR.PrintError, xPlayer, arguments)
end

ESXR.RegisterCommand = function(command, inputs, callback, consoleAllowed)
    if (ESXR.TypeOf(command) == 'table') then
        for k, v in pairs(command) do
            ESXR.RegisterCommand(v, callback, consoleAllowed, inputs)
        end
        return
    end

    command = ESXR.Ensure(command, 'unknown')
    callback = ESXR.Ensure(callback, function() end)
    inputs = ESXR.Ensure(inputs, {})
    consoleAllowed = ESXR.Ensure(consoleAllowed, true)

    if (command == 'unknown') then
        return
    end

    ---@class command
    local _cmd = {
        name = command,
        arguments = {},
        callback = callback,
        consoleAllowed = consoleAllowed,
        trigger = function(playerId, args)
            ESXR.ExecuteCommand(command, playerId, args)
        end
    }

    local index = 0

    for k, v in pairs(inputs) do
        index = index + 1
        v = ESXR.Ensure(v, {})

        local argument = {
            type = ESXR.Ensure(v.type, 'any'),
            default = v.default or nil,
            index = index,
            name = ESXR.Ensure(v.name, _(('%s_%s'):format(command, index))),
            description = ESXR.Ensure(v.description, _(('%s_%s_description'):format(command, index)))
        }

        _cmd.arguments[index] = argument
    end

    ESXR.Commands[command] = _cmd

    RegisterCommand(command, ESXR.Commands[command].trigger)
end