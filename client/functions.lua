ESR.PlayerData                = {}
ESR.PlayerLoaded              = false
ESR.CurrentRequestId          = 0
ESR.ServerCallbacks           = {}
ESR.TimeoutCallbacks          = {}

ESR.UI                        = {}
ESR.UI.HUD                    = {}
ESR.UI.HUD.RegisteredElements = {}
ESR.UI.Menu                   = {}
ESR.UI.Menu.RegisteredTypes   = {}
ESR.UI.Menu.Opened            = {}

ESR.Game                      = {}
ESR.Game.Utils                = {}

ESR.Scaleform                 = {}
ESR.Scaleform.Utils           = {}

ESR.Streaming                 = {}

ESR.SetTimeout = function(msec, cb)
	table.insert(ESR.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
	return #ESR.TimeoutCallbacks
end

ESR.ClearTimeout = function(i)
	ESR.TimeoutCallbacks[i] = nil
end

ESR.IsPlayerLoaded = function()
	return ESR.PlayerLoaded
end

ESR.GetPlayerData = function()
	return ESR.PlayerData
end

ESR.SetPlayerData = function(key, val)
	ESR.PlayerData[key] = val
end

ESR.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

ESR.ShowAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('esxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('esxAdvancedNotification')
	if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

ESR.ShowHelpNotification = function(msg, thisFrame, beep, duration)
	AddTextEntry('esxHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('esxHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('esxHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

ESR.ShowFloatingHelpNotification = function(msg, coords)
	AddTextEntry('esxFloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('esxFloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

ESR.TriggerServerCallback = function(name, cb, ...)
	ESR.ServerCallbacks[ESR.CurrentRequestId] = cb

	TriggerServerEvent('esx:triggerServerCallback', name, ESR.CurrentRequestId, ...)

	if ESR.CurrentRequestId < 65535 then
		ESR.CurrentRequestId = ESR.CurrentRequestId + 1
	else
		ESR.CurrentRequestId = 0
	end
end

ESR.UI.HUD.SetDisplay = function(opacity)
	SendNUIMessage({
		action  = 'setHUDDisplay',
		opacity = opacity
	})
end

ESR.UI.HUD.RegisterElement = function(name, index, priority, html, data)
	local found = false

	for i=1, #ESR.UI.HUD.RegisteredElements, 1 do
		if ESR.UI.HUD.RegisteredElements[i] == name then
			found = true
			break
		end
	end

	if found then
		return
	end

	table.insert(ESR.UI.HUD.RegisteredElements, name)

	SendNUIMessage({
		action    = 'insertHUDElement',
		name      = name,
		index     = index,
		priority  = priority,
		html      = html,
		data      = data
	})

	ESR.UI.HUD.UpdateElement(name, data)
end

ESR.UI.HUD.RemoveElement = function(name)
	for i=1, #ESR.UI.HUD.RegisteredElements, 1 do
		if ESR.UI.HUD.RegisteredElements[i] == name then
			table.remove(ESR.UI.HUD.RegisteredElements, i)
			break
		end
	end

	SendNUIMessage({
		action    = 'deleteHUDElement',
		name      = name
	})
end

ESR.UI.HUD.UpdateElement = function(name, data)
	SendNUIMessage({
		action = 'updateHUDElement',
		name   = name,
		data   = data
	})
end

ESR.UI.Menu.RegisterType = function(type, open, close)
	ESR.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

ESR.UI.Menu.Open = function(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		ESR.UI.Menu.RegisteredTypes[type].close(namespace, name)

		for i=1, #ESR.UI.Menu.Opened, 1 do
			if ESR.UI.Menu.Opened[i] then
				if ESR.UI.Menu.Opened[i].type == type and ESR.UI.Menu.Opened[i].namespace == namespace and ESR.UI.Menu.Opened[i].name == name then
					ESR.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		ESR.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	menu.setElements = function(newElements)
		menu.data.elements = newElements
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	table.insert(ESR.UI.Menu.Opened, menu)
	ESR.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

ESR.UI.Menu.Close = function(type, namespace, name)
	for i=1, #ESR.UI.Menu.Opened, 1 do
		if ESR.UI.Menu.Opened[i] then
			if ESR.UI.Menu.Opened[i].type == type and ESR.UI.Menu.Opened[i].namespace == namespace and ESR.UI.Menu.Opened[i].name == name then
				ESR.UI.Menu.Opened[i].close()
				ESR.UI.Menu.Opened[i] = nil
			end
		end
	end
end

ESR.UI.Menu.CloseAll = function()
	for i=1, #ESR.UI.Menu.Opened, 1 do
		if ESR.UI.Menu.Opened[i] then
			ESR.UI.Menu.Opened[i].close()
			ESR.UI.Menu.Opened[i] = nil
		end
	end
end

ESR.UI.Menu.GetOpened = function(type, namespace, name)
	for i=1, #ESR.UI.Menu.Opened, 1 do
		if ESR.UI.Menu.Opened[i] then
			if ESR.UI.Menu.Opened[i].type == type and ESR.UI.Menu.Opened[i].namespace == namespace and ESR.UI.Menu.Opened[i].name == name then
				return ESR.UI.Menu.Opened[i]
			end
		end
	end
end

ESR.UI.Menu.GetOpenedMenus = function()
	return ESR.UI.Menu.Opened
end

ESR.UI.Menu.IsOpen = function(type, namespace, name)
	return ESR.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

ESR.UI.ShowInventoryItemNotification = function(add, item, count)
	SendNUIMessage({
		action = 'inventoryNotification',
		add    = add,
		item   = item,
		count  = count
	})
end

ESR.Game.GetPedMugshot = function(ped, transparent)
	if DoesEntityExist(ped) then
		local mugshot

		if transparent then
			mugshot = RegisterPedheadshotTransparent(ped)
		else
			mugshot = RegisterPedheadshot(ped)
		end

		while not IsPedheadshotReady(mugshot) do
			Citizen.Wait(0)
		end

		return mugshot, GetPedheadshotTxdString(mugshot)
	else
		return
	end
end

ESR.Game.Teleport = function(entity, coords, cb)
	if DoesEntityExist(entity) then
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		local timeout = 0

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(entity) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)

		if type(coords) == 'table' and coords.heading then
			SetEntityHeading(entity, coords.heading)
		end
	end

	if cb then
		cb()
	end
end

ESR.Game.SpawnObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		ESR.Streaming.RequestModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
		SetModelAsNoLongerNeeded(model)

		if cb then
			cb(obj)
		end
	end)
end

ESR.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		ESR.Streaming.RequestModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
		SetModelAsNoLongerNeeded(model)

		if cb then
			cb(obj)
		end
	end)
end

ESR.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

ESR.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

ESR.Game.SpawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		ESR.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local networkId = NetworkGetNetworkIdFromEntity(vehicle)
		local timeout = 0

		SetNetworkIdCanMigrate(networkId, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

ESR.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		ESR.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
		local timeout = 0

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		-- we can get stuck here if any of the axies are "invalid"
		while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
			Citizen.Wait(0)
			timeout = timeout + 1
		end

		if cb then
			cb(vehicle)
		end
	end)
end

ESR.Game.IsVehicleEmpty = function(vehicle)
	local passengers = GetVehicleNumberOfPassengers(vehicle)
	local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

	return passengers == 0 and driverSeatFree
end

ESR.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

ESR.Game.GetPeds = function(onlyOtherPeds)
	local peds, myPed = {}, PlayerPedId()

	for ped in EnumeratePeds() do
		if ((onlyOtherPeds and ped ~= myPed) or not onlyOtherPeds) then
			table.insert(peds, ped)
		end
	end

	return peds
end

ESR.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

ESR.Game.GetPlayers = function(onlyOtherPlayers, returnKeyValue, returnPeds)
	local players, myPlayer = {}, PlayerId()

	for k,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
			if returnKeyValue then
				players[player] = ped
			else
				table.insert(players, returnPeds and ped or player)
			end
		end
	end

	return players
end

ESR.Game.GetClosestObject = function(coords, modelFilter) return ESR.Game.GetClosestEntity(ESR.Game.GetObjects(), false, coords, modelFilter) end
ESR.Game.GetClosestPed = function(coords, modelFilter) return ESR.Game.GetClosestEntity(ESR.Game.GetPeds(true), false, coords, modelFilter) end
ESR.Game.GetClosestPlayer = function(coords) return ESR.Game.GetClosestEntity(ESR.Game.GetPlayers(true, true), true, coords, nil) end
ESR.Game.GetClosestVehicle = function(coords, modelFilter) return ESR.Game.GetClosestEntity(ESR.Game.GetVehicles(), false, coords, modelFilter) end
ESR.Game.GetPlayersInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(ESR.Game.GetPlayers(true, true), true, coords, maxDistance) end
ESR.Game.GetVehiclesInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(ESR.Game.GetVehicles(), false, coords, maxDistance) end
ESR.Game.IsSpawnPointClear = function(coords, maxDistance) return #ESR.Game.GetVehiclesInArea(coords, maxDistance) == 0 end

ESR.Game.GetClosestEntity = function(entities, isPlayerEntities, coords, modelFilter)
	local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	if modelFilter then
		filteredEntities = {}

		for k,entity in pairs(entities) do
			if modelFilter[GetEntityModel(entity)] then
				table.insert(filteredEntities, entity)
			end
		end
	end

	for k,entity in pairs(filteredEntities or entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if closestEntityDistance == -1 or distance < closestEntityDistance then
			closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
		end
	end

	return closestEntity, closestEntityDistance
end

ESR.Game.GetVehicleInDirection = function()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

ESR.Game.GetVehicleProperties = function(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		for extraId=0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = ESR.Math.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = ESR.Math.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = ESR.Math.Round(GetVehicleEngineHealth(vehicle), 1),
			tankHealth        = ESR.Math.Round(GetVehiclePetrolTankHealth(vehicle), 1),

			fuelLevel         = ESR.Math.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = ESR.Math.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColour(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end

ESR.Game.SetVehicleProperties = function(vehicle, props)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleModKit(vehicle, 0)

		if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
		if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
		if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
		if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
		if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
		if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
		if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
		if props.color1 then SetVehicleColours(vehicle, props.color1, colorSecondary) end
		if props.color2 then SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2) end
		if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor) end
		if props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor) end
		if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
		if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end

		if props.extras then
			for extraId,enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(extraId), 0)
				else
					SetVehicleExtra(vehicle, tonumber(extraId), 1)
				end
			end
		end

		if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
		if props.xenonColor then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
		if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
		if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
		if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
		if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
		if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
		if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
		if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
		if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
		if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
		if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
		if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
		if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
		if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
		if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
		if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
		if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
		if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
		if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
		if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
		if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
		if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
		if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
		if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
		if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
		if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
		if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
		if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
		if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
		if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
		if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
		if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
		if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
		if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
		if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
		if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
		if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
		if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
		if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
		if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
		if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
		if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
		if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
		if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
		if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
		if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

		if props.modLivery then
			SetVehicleMod(vehicle, 48, props.modLivery, false)
			SetVehicleLivery(vehicle, props.modLivery)
		end
	end
end

ESR.Game.Utils.DrawText3D = function(coords, text, size, font)
	coords = vector3(coords.x, coords.y, coords.z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not size then size = 1 end
	if not font then font = 0 end

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

ESR.ShowInventory = function()
	local playerPed = PlayerPedId()
	local elements, currentWeight = {}, 0

	for k,v in pairs(ESR.PlayerData.accounts) do
		if v.money > 0 then
			local formattedMoney = _U('locale_currency', ESR.Math.GroupDigits(v.money))
			local canDrop = v.name ~= 'bank'

			table.insert(elements, {
				label = ('%s: <span style="color:green;">%s</span>'):format(v.label, formattedMoney),
				count = v.money,
				type = 'item_account',
				value = v.name,
				usable = false,
				rare = false,
				canRemove = canDrop
			})
		end
	end

	for k,v in ipairs(ESR.PlayerData.inventory) do
		if v.count > 0 then
			currentWeight = currentWeight + (v.weight * v.count)

			table.insert(elements, {
				label = ('%s x%s'):format(v.label, v.count),
				count = v.count,
				type = 'item_standard',
				value = v.name,
				usable = v.usable,
				rare = v.rare,
				canRemove = v.canRemove
			})
		end
	end

	for k,v in ipairs(Config.Weapons) do
		local weaponHash = GetHashKey(v.name)

		if HasPedGotWeapon(playerPed, weaponHash, false) then
			local ammo, label = GetAmmoInPedWeapon(playerPed, weaponHash)

			if v.ammo then
				label = ('%s - %s %s'):format(v.label, ammo, v.ammo.label)
			else
				label = v.label
			end

			table.insert(elements, {
				label = label,
				count = 1,
				type = 'item_weapon',
				value = v.name,
				usable = false,
				rare = false,
				ammo = ammo,
				canGiveAmmo = (v.ammo ~= nil),
				canRemove = true
			})
		end
	end

	ESR.UI.Menu.CloseAll()

	ESR.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory', {
		title    = _U('inventory', currentWeight, ESR.PlayerData.maxWeight),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		menu.close()
		local player, distance = ESR.Game.GetClosestPlayer()
		elements = {}

		if data.current.usable then
			table.insert(elements, {label = _U('use'), action = 'use', type = data.current.type, value = data.current.value})
		end

		if data.current.canRemove then
			if player ~= -1 and distance <= 3.0 then
				table.insert(elements, {label = _U('give'), action = 'give', type = data.current.type, value = data.current.value})
			end

			table.insert(elements, {label = _U('remove'), action = 'remove', type = data.current.type, value = data.current.value})
		end

		if data.current.type == 'item_weapon' and data.current.canGiveAmmo and data.current.ammo > 0 and player ~= -1 and distance <= 3.0 then
			table.insert(elements, {label = _U('giveammo'), action = 'give_ammo', type = data.current.type, value = data.current.value})
		end

		table.insert(elements, {label = _U('return'), action = 'return'})

		ESR.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory_item', {
			title    = data.current.label,
			align    = 'bottom-right',
			elements = elements,
		}, function(data1, menu1)
			local item, type = data1.current.value, data1.current.type

			if data1.current.action == 'give' then
				local playersNearby = ESR.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

				if #playersNearby > 0 then
					local players = {}
					elements = {}

					for k,playerNearby in ipairs(playersNearby) do
						players[GetPlayerServerId(playerNearby)] = true
					end

					ESR.TriggerServerCallback('esx:getPlayerNames', function(returnedPlayers)
						for playerId,playerName in pairs(returnedPlayers) do
							table.insert(elements, {
								label = playerName,
								playerId = playerId
							})
						end

						ESR.UI.Menu.Open('default', GetCurrentResourceName(), 'give_item_to', {
							title    = _U('give_to'),
							align    = 'bottom-right',
							elements = elements
						}, function(data2, menu2)
							local selectedPlayer, selectedPlayerId = GetPlayerFromServerId(data2.current.playerId), data2.current.playerId
							playersNearby = ESR.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
							playersNearby = ESR.Table.Set(playersNearby)

							if playersNearby[selectedPlayer] then
								local selectedPlayerPed = GetPlayerPed(selectedPlayer)

								if IsPedOnFoot(selectedPlayerPed) and not IsPedFalling(selectedPlayerPed) then
									if type == 'item_weapon' then
										TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, type, item, nil)
										menu2.close()
										menu1.close()
									else
										ESR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
											title = _U('amount')
										}, function(data3, menu3)
											local quantity = tonumber(data3.value)

											if quantity and quantity > 0 and data.current.count >= quantity then
												TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, type, item, quantity)
												menu3.close()
												menu2.close()
												menu1.close()
											else
												ESR.ShowNotification(_U('amount_invalid'))
											end
										end, function(data3, menu3)
											menu3.close()
										end)
									end
								else
									ESR.ShowNotification(_U('in_vehicle'))
								end
							else
								ESR.ShowNotification(_U('players_nearby'))
								menu2.close()
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end, players)
				else
					ESR.ShowNotification(_U('players_nearby'))
				end
			elseif data1.current.action == 'remove' then
				if IsPedOnFoot(playerPed) and not IsPedFalling(playerPed) then
					local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
					ESR.Streaming.RequestAnimDict(dict)

					if type == 'item_weapon' then
						menu1.close()
						TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
						Citizen.Wait(1000)
						TriggerServerEvent('esx:removeInventoryItem', type, item)
					else
						ESR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_remove', {
							title = _U('amount')
						}, function(data2, menu2)
							local quantity = tonumber(data2.value)

							if quantity and quantity > 0 and data.current.count >= quantity then
								menu2.close()
								menu1.close()
								TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
								Citizen.Wait(1000)
								TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)
							else
								ESR.ShowNotification(_U('amount_invalid'))
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end
				end
			elseif data1.current.action == 'use' then
				TriggerServerEvent('esx:useItem', item)
			elseif data1.current.action == 'return' then
				ESR.UI.Menu.CloseAll()
				ESR.ShowInventory()
			elseif data1.current.action == 'give_ammo' then
				local closestPlayer, closestDistance = ESR.Game.GetClosestPlayer()
				local closestPed = GetPlayerPed(closestPlayer)
				local pedAmmo = GetAmmoInPedWeapon(playerPed, GetHashKey(item))

				if IsPedOnFoot(closestPed) and not IsPedFalling(closestPed) then
					if closestPlayer ~= -1 and closestDistance < 3.0 then
						if pedAmmo > 0 then
							ESR.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
								title = _U('amountammo')
							}, function(data2, menu2)
								local quantity = tonumber(data2.value)

								if quantity and quantity > 0 then
									if pedAmmo >= quantity then
										TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_ammo', item, quantity)
										menu2.close()
										menu1.close()
									else
										ESR.ShowNotification(_U('noammo'))
									end
								else
									ESR.ShowNotification(_U('amount_invalid'))
								end
							end, function(data2, menu2)
								menu2.close()
							end)
						else
							ESR.ShowNotification(_U('noammo'))
						end
					else
						ESR.ShowNotification(_U('players_nearby'))
					end
				else
					ESR.ShowNotification(_U('in_vehicle'))
				end
			end
		end, function(data1, menu1)
			ESR.UI.Menu.CloseAll()
			ESR.ShowInventory()
		end)
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('esx:serverCallback')
AddEventHandler('esx:serverCallback', function(requestId, ...)
	ESR.ServerCallbacks[requestId](...)
	ESR.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg)
	ESR.ShowNotification(msg)
end)

RegisterNetEvent('esx:showAdvancedNotification')
AddEventHandler('esx:showAdvancedNotification', function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	ESR.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
end)

RegisterNetEvent('esx:showHelpNotification')
AddEventHandler('esx:showHelpNotification', function(msg, thisFrame, beep, duration)
	ESR.ShowHelpNotification(msg, thisFrame, beep, duration)
end)

-- SetTimeout
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local currTime = GetGameTimer()

		for i=1, #ESR.TimeoutCallbacks, 1 do
			if ESR.TimeoutCallbacks[i] then
				if currTime >= ESR.TimeoutCallbacks[i].time then
					ESR.TimeoutCallbacks[i].cb()
					ESR.TimeoutCallbacks[i] = nil
				end
			end
		end
	end
end)
