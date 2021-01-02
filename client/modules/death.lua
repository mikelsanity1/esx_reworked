Citizen.CreateThread(function()
	local isDead = false

	while true do
		Citizen.Wait(0)
		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()

			if IsPedFatallyInjured(playerPed) and not isDead then
				isDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					PlayerKilled(deathCause)
				end

			elseif not IsPedFatallyInjured(playerPed) then
				isDead = false
			end
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = ESXR.Round(victimCoords.x, 1), y = ESXR.Round(victimCoords.y, 1), z = ESXR.Round(victimCoords.z, 1)},
		killerCoords = {x = ESXR.Round(killerCoords.x, 1), y = ESXR.Round(killerCoords.y, 1), z = ESXR.Round(killerCoords.z, 1)},

		killedByPlayer = true,
		deathCause = deathCause,
		distance = ESXR.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

function PlayerKilled(deathCause)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = {x = ESXR.Round(victimCoords.x, 1), y = ESXR.Round(victimCoords.y, 1), z = ESXR.Round(victimCoords.z, 1)},

		killedByPlayer = false,
		deathCause = deathCause
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end
