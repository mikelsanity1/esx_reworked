Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            TriggerServerEvent('esxr:onPlayerJoined')
            return
        end

        Citizen.Wait(250)
    end
end)

RegisterNetEvent('esxr:playerInfo')
AddEventHandler('esxr:playerInfo', function(data)
    data = ESXR.Ensure(data, { })
    data.job = ESXR.Ensure(data.job, { })
    data.job2 = ESXR.Ensure(data.job2, { })
    data.job.grade = ESXR.Ensure(data.job.grade, { })
    data.job2.grade = ESXR.Ensure(data.job2.grade, { })

    ESXR.PlayerData = ESXR.Ensure(ESXR.PlayerData, { })
    ESXR.PlayerData.job = ESXR.Ensure(ESXR.PlayerData.job, { })
    ESXR.PlayerData.job2 = ESXR.Ensure(ESXR.PlayerData.job2, { })
    ESXR.PlayerData.job.grade = ESXR.Ensure(ESXR.PlayerData.job.grade, { })
    ESXR.PlayerData.job2.grade = ESXR.Ensure(ESXR.PlayerData.job2.grade, { })

    ESXR.PlayerData = {
        loaded = true,
        source = ESXR.Ensure(data.source, 0, true) or ESXR.Ensure(ESXR.PlayerData.source, 0),
        name = ESXR.Ensure(data.name, 'Unknown', true) or ESXR.Ensure(ESXR.PlayerData.name, 'Unknown'),
        group = ESXR.Ensure(data.name, 'user', true) or ESXR.Ensure(ESXR.PlayerData.group, 'user'),
        position = ESXR.Ensure(data.position, Configuration.DefaultSpawn, true) or ESXR.Ensure(ESXR.PlayerData.position, Configuration.DefaultSpawn),
        job = {
            id = ESXR.Ensure(data.job.id, 0, true) or ESXR.Ensure(ESXR.PlayerData.job.id, 0),
            name = ESXR.Ensure(data.job.name, 'unknown', true) or ESXR.Ensure(ESXR.PlayerData.job.name, 'unknown'),
            label = ESXR.Ensure(data.job.label, 'Unknown', true) or ESXR.Ensure(ESXR.PlayerData.job.label, 'Unknown'),
            whitelisted = ESXR.Ensure(data.job.whitelisted, false, true) or ESXR.Ensure(ESXR.PlayerData.job.whitelisted, false),
            grade = {
                grade = ESXR.Ensure(data.job.grade.grade, 0, true) or ESXR.Ensure(ESXR.PlayerData.job.grade.grade, 0),
                name = ESXR.Ensure(data.job.grade.name, 'unknown', true) or ESXR.Ensure(ESXR.PlayerData.job.grade.name, 'unknown'),
                label = ESXR.Ensure(data.job.grade.label, 'Unknown', true) or ESXR.Ensure(ESXR.PlayerData.job.grade.label, 'Unknown'),
                grade = ESXR.Ensure(data.job.grade.salary, 250, true) or ESXR.Ensure(ESXR.PlayerData.job.grade.salary, 250)
            }
        },
        job2 = {
            id = ESXR.Ensure(data.job2.id, 0, true) or ESXR.Ensure(ESXR.PlayerData.job2.id, 0),
            name = ESXR.Ensure(data.job2.name, 'unknown', true) or ESXR.Ensure(ESXR.PlayerData.job2.name, 'unknown'),
            label = ESXR.Ensure(data.job2.label, 'Unknown', true) or ESXR.Ensure(ESXR.PlayerData.job2.label, 'Unknown'),
            whitelisted = ESXR.Ensure(data.job2.whitelisted, false, true) or ESXR.Ensure(ESXR.PlayerData.job2.whitelisted, false),
            grade = {
                grade = ESXR.Ensure(data.job2.grade.grade, 0, true) or ESXR.Ensure(ESXR.PlayerData.job2.grade.grade, 0),
                name = ESXR.Ensure(data.job2.grade.name, 'unknown', true) or ESXR.Ensure(ESXR.PlayerData.job2.grade.name, 'unknown'),
                label = ESXR.Ensure(data.job2.grade.label, 'Unknown', true) or ESXR.Ensure(ESXR.PlayerData.job2.grade.label, 'Unknown'),
                grade = ESXR.Ensure(data.job2.grade.salary, 250, true) or ESXR.Ensure(ESXR.PlayerData.job2.grade.salary, 250)
            }
        }
    }

    while not ESXR.HudLoaded do
        Citizen.Wait(0)
    end

    SendNuiMessage(ESXR.Encode({
        action = 'LOADED',
        job_label = ESXR.PlayerData.job.label,
        job_grade = ESXR.PlayerData.job.grade.label,
        job2_label = ESXR.PlayerData.job2.label,
        job2_grade = ESXR.PlayerData.job2.grade.label
    }))
end)

RegisterNUICallback('loaded', function(_, cb)
    ESXR.HudLoaded = true

    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        if (ESXR.HudLoaded) then
            local playerPedId = PlayerPedId()
            local shouldBeHidden = false

            if (IsScreenFadedOut() or IsPauseMenuActive()) then
                shouldBeHidden = true
            end

            SendNUIMessage({
                action = 'HIDE_SHOW',
                status = not shouldBeHidden
            })

            SendNUIMessage({
                action = 'UPDATE_STATS',
                key = 'health',
                value = ESXR.Round(GetEntityHealth(playerPedId) - 100) + 0.0
            })

            SendNUIMessage({
                action = 'UPDATE_STATS',
                key = 'armor',
                value = ESXR.Round(GetPedArmour(playerPedId)) + 0.0
            })
        end

        Citizen.Wait(50)
    end
end)