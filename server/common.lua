ESR.UsableItemsCallbacks = {}
ESR.Items = {}
ESR.ServerCallbacks = {}
ESR.TimeoutCount = -1
ESR.CancelledTimeouts = {}
ESR.Pickups = {}
ESR.PickupId = 0
ESR.RegisteredCommands = {}

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[es_reworked] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESR.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
