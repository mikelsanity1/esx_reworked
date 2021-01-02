ESXR.UsableItemsCallbacks = {}
ESXR.Items = {}
ESXR.ServerCallbacks = {}
ESXR.TimeoutCount = -1
ESXR.CancelledTimeouts = {}
ESXR.Pickups = {}
ESXR.PickupId = 0
ESXR.RegisteredCommands = {}

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[esx_reworked] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESXR.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
