local cached_events = {}

---@class Events
local events = { __class = 'Events', __type = 'Events' }

local function onEvent(resource, event, names, func)
    resource = ESXR.Ensure(resource, 'unknown')
    resource = resource ~= 'unknown' and resource or ESXR.Ensure(GetInvokingResource(), 'esx_reworked')
    event = string.lower(ESXR.Ensure(event, 'unknown'))
    names = ESXR.Ensure(names, { 'unknown' })
    func = ESXR.Ensure(func, function() end)

    for k, v in pairs(names) do
        local name = string.lower(ESXR.Ensure(v, 'unknown'))

        if (cached_events == nil) then cached_events = {} end
        if (cached_events[resource] == nil) then cached_events[resource] = {} end
        if (cached_events[resource][event] == nil) then cached_events[resource][event] = { params = {}, always = {} } end

        if (name == 'unknown') then
            if (cached_events[resource][event].always == nil) then cached_events[resource][event].always = {} end

            table.insert(cached_events[resource][event].always, func)
        else
            if (cached_events[resource][event].params == nil) then cached_events[resource][event].params = {} end
            if (cached_events[resource][event].params[name] == nil) then cached_events[resource][event].params[name] = {} end

            table.insert(cached_events[resource][event].params[name], func)
        end
    end
end

local function filterArguments(...)
    local name, names, callback = nil, nil, nil
    local iName, iNames, index = 999, 999, 0
    local arguments = { ... }

    for k, v in pairs(arguments) do
        index = index + 1

        local argumentType = ESXR.TypeOf(v)

        if (argumentType == 'function' and callback == nil) then
            callback = v
        elseif (argumentType == 'table' and names == nil) then
            for nk, nv in pairs(v) do
                local n = ESXR.Ensure(nv, 'unknown')

                if (n ~= 'unknown') then
                    if (names == nil) then
                        names = {}
                        iNames = index
                    end

                    table.insert(names, n)
                end
            end
        elseif (name == nil) then
            local n = ESXR.Ensure(v, 'unknown')

            if (n ~= 'unknown') then
                name = n
                iName = index
            end
        end
    end

    if (name ~= nil and callback ~= nil and iName < iNames) then
        return callback, name
    elseif (names ~= nil and callback ~= nil and iNames < iName) then
        return callback, names
    elseif (callback ~= nil) then
        return callback, nil
    else
        return nil, nil
    end
end

function events.On(event, ...)
    event = ESXR.Ensure(event, 'unknown')

    local resource = ESXR.Ensure(GetInvokingResource(), 'esx_reworked')
    local callback, name = filterArguments(...)

    if (callback == nil) then return end

    onEvent(resource, event, name, callback)
end

function events.AnyEventRegistered(event, resource)
    event = ESXR.Ensure(event, 'unknown')
    resource = ESXR.Ensure(resource, ESXR.Ensure(GetInvokingResource(), 'esx_reworked'))

    return ESXR.Ensure(cached_events[resource], {})[event] ~= nil
end

function events.GetAllRegisterdEvents(event, params)
    event = string.lower(ESXR.Ensure(event, 'unknown'))
    params = ESXR.Ensure(params, {})

    local hasParemeters = #params > 0
    local functions = {}

    for k, v in pairs(ESXR.Ensure(cached_events, {})) do
        for ek, ev in pairs(ESXR.Ensure(v, {})) do
            ev = ESXR.Ensure(ev, {})
            ek = ESXR.Ensure(ek, 'unknown')

            if (ek == event) then
                for fk, fv in pairs(ESXR.Ensure(ev.always, {})) do
                    table.insert(functions, ESXR.Ensure(fv, function() end))
                end

                if (hasParemeters) then
                    local eventParameters = ESXR.Ensure(ev.params, {})

                    for pk, pv in pairs(params) do
                        pv = string.lower(ESXR.Ensure(pv, 'unknown'))

                        for fk, fv in pairs(ESXR.Ensure(eventParameters[pv], {})) do
                            table.insert(functions, ESXR.Ensure(fv, function() end))
                        end
                    end
                end
            end
        end
    end

    return functions
end

function events.TriggerOnEvent(event, name, ...)
    local allEvents = ESXR.Events.GetAllRegisterdEvents(event, ESXR.Ensure(name, {}))
    local arguments = { ... }

    for k, v in pairs(allEvents) do
        Citizen.CreateThread(function()
            v = ESXR.Ensure(v, function() end)

            ESXR.TryCatch(function()
                v(table.unpack(arguments))
            end, ESXR.PrintError)
        end)
    end
end

ESXR.Events = events