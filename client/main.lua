Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            TriggerServerEvent('esxr:onPlayerJoined')
            return
        end

        Citizen.Wait(250)
    end
end)