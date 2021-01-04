local timer = GetGameTimer
local cached = {}

ESXR.GetCurrentTick = function()
    return ESXR.Ensure(ESXR.Clock.CurrentTick, 0)
end

if (ESXR.IsServer) then
    ESXR.RegisterServerEvent = function (name, callback, rateLimit, max)
        name = ESXR.Ensure(name, 'unknown')
        callback = ESXR.Ensure(callback, function() end)
        rateLimit = ESXR.Ensure(rateLimit, 0)
        max = ESXR.Ensure(max, 0)

        cached[name] = {
            name = name,
            callback = callback,
            rateLimit = rateLimit,
            max = max
        }

        RegisterServerEvent(name)
        AddEventHandler(name, function(...)
            local src = ESXR.Ensure(source, 0)
            local event = ESXR.Ensure(name, 'unknown')
            local rateInfo = cached[event] or nil

            if (rateInfo == nil) then return end

            local cb = ESXR.Ensure(rateInfo.callback, function() end)
            local limit = ESXR.Ensure(rateInfo.rateLimit, 0)
            local maxCalls = ESXR.Ensure(rateInfo.max, 0)

            if (ESXR.RateLimits == nil) then ESXR.RateLimits = {} end
            if (ESXR.RateLimits[src] == nil) then ESXR.RateLimits[src] = {} end
            if (ESXR.RateLimits[src][event] == nil) then ESXR.RateLimits[src][event] = { LastTrigger = 0, Triggered = 0 } end

            local numTriggered = ESXR.Ensure(ESXR.RateLimits[src][event].Triggered, 0)

            if (maxCalls > 0 and numTriggered >= maxCalls) then
                local xPlayer = GetPlayerBySource(src)

                ESXR.PrintWarn(_('rate_limit_exceeded', event, xPlayer ~= nil and xPlayer.name or GetPlayerName(src)))
                return
            end

            local prevCall = ESXR.Ensure(ESXR.RateLimits[src][event].LastTrigger, 0)
            local currentCall = ESXR.GetCurrentTick()

            ESXR.RateLimits[src][event].LastTrigger = currentCall
            ESXR.RateLimits[src][event].Triggered = (numTriggered + 1)

            if ((prevCall - currentCall) < limit) then
                cb(src, ...)
            else
                local xPlayer = GetPlayerBySource(src)

                ESXR.PrintWarn(_('rate_limit_exceeded', event, xPlayer ~= nil and xPlayer.name or GetPlayerName(src)))
            end
        end)
    end
else
    ESXR.RegisterClientEvent = function (name, callback, rateLimit, max)
        name = ESXR.Ensure(name, 'unknown')
        callback = ESXR.Ensure(callback, function() end)
        rateLimit = ESXR.Ensure(rateLimit, 0)
        max = ESXR.Ensure(max, 0)

        cached[name] = {
            name = name,
            callback = callback,
            rateLimit = rateLimit,
            max = max
        }

        RegisterNetEvent(name)
        AddEventHandler(name, function(...)
            local event = ESXR.Ensure(name, 'unknown')
            local rateInfo = cached[event] or nil

            if (rateInfo == nil) then return end

            local cb = ESXR.Ensure(rateInfo.callback, function() end)
            local limit = ESXR.Ensure(rateInfo.rateLimit, 0)
            local maxCalls = ESXR.Ensure(rateInfo.max, 0)

            if (ESXR.RateLimits == nil) then ESXR.RateLimits = {} end
            if (ESXR.RateLimits[event] == nil) then ESXR.RateLimits[event] = { LastTrigger = 0, Triggered = 0 } end

            local numTriggered = ESXR.Ensure(ESXR.RateLimits[event].Triggered, 0)

            if (maxCalls > 0 and numTriggered >= maxCalls) then
                return
            end

            local prevCall = ESXR.Ensure(ESXR.RateLimits[event].LastTrigger, 0)
            local currentCall = ESXR.GetCurrentTick()

            ESXR.RateLimits[event].LastTrigger = currentCall
            ESXR.RateLimits[event].Triggered = (numTriggered + 1)

            if ((prevCall - currentCall) < limit) then
                cb(...)
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        if (ESXR.Clock.LastTime == nil) then
            ESXR.Clock.LastTime = timer()
        else
            local currentTime = ESXR.Ensure(ESXR.Clock.CurrentTick, 0)
            local addTime = ESXR.Round((timer() - currentTime) / 100, 0)

            ESXR.Clock.CurrentTick = ESXR.Round(currentTime + addTime, 0)
        end

        Citizen.Wait(10)
    end
end)