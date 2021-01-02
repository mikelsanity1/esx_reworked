ESR.Trace = function(msg)
	if Config.EnableDebug then
		print(('[es_reworked] [^2TRACE^7] %s^7'):format(msg))
	end
end

ESR.SetTimeout = function(msec, cb)
	local id = ESR.TimeoutCount + 1

	SetTimeout(msec, function()
		if ESR.CancelledTimeouts[id] then
			ESR.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	ESR.TimeoutCount = id

	return id
end

ESR.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			ESR.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if ESR.RegisteredCommands[name] then
		print(('[es_reworked] [^3WARNING^7] An command "%s" is already registered, overriding command'):format(name))

		if ESR.RegisteredCommands[name].suggestion then
			TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
		end
	end

	if suggestion then
		if not suggestion.arguments then suggestion.arguments = {} end
		if not suggestion.help then suggestion.help = '' end

		TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
	end

	ESR.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

	RegisterCommand(name, function(playerId, args, rawCommand)
		local command = ESR.RegisteredCommands[name]

		if not command.allowConsole and playerId == 0 then
			print(('[es_reworked] [^3WARNING^7] %s'):format(_U('commanderror_console')))
		else
			local xPlayer, error = ESR.GetPlayerFromId(playerId), nil

			if command.suggestion then
				if command.suggestion.validate then
					if #args ~= #command.suggestion.arguments then
						error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
					end
				end

				if not error and command.suggestion.arguments then
					local newArgs = {}

					for k,v in ipairs(command.suggestion.arguments) do
						if v.type then
							if v.type == 'number' then
								local newArg = tonumber(args[k])

								if newArg then
									newArgs[v.name] = newArg
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'player' or v.type == 'playerId' then
								local targetPlayer = tonumber(args[k])

								if args[k] == 'me' then targetPlayer = playerId end

								if targetPlayer then
									local xTargetPlayer = ESR.GetPlayerFromId(targetPlayer)

									if xTargetPlayer then
										if v.type == 'player' then
											newArgs[v.name] = xTargetPlayer
										else
											newArgs[v.name] = targetPlayer
										end
									else
										error = _U('commanderror_invalidplayerid')
									end
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'string' then
								newArgs[v.name] = args[k]
							elseif v.type == 'item' then
								if ESR.Items[args[k]] then
									newArgs[v.name] = args[k]
								else
									error = _U('commanderror_invaliditem')
								end
							elseif v.type == 'weapon' then
								if ESR.GetWeapon(args[k]) then
									newArgs[v.name] = string.upper(args[k])
								else
									error = _U('commanderror_invalidweapon')
								end
							elseif v.type == 'any' then
								newArgs[v.name] = args[k]
							end
						end

						if error then break end
					end

					args = newArgs
				end
			end

			if error then
				if playerId == 0 then
					print(('[es_reworked] [^3WARNING^7] %s^7'):format(error))
				else
					xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
				end
			else
				cb(xPlayer or false, args, function(msg)
					if playerId == 0 then
						print(('[es_reworked] [^3WARNING^7] %s^7'):format(msg))
					else
						xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
					end
				end)
			end
		end
	end, true)

	if type(group) == 'table' then
		for k,v in ipairs(group) do
			ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
		end
	else
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

ESR.ClearTimeout = function(id)
	ESR.CancelledTimeouts[id] = true
end

ESR.RegisterServerCallback = function(name, cb)
	ESR.ServerCallbacks[name] = cb
end

ESR.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if ESR.ServerCallbacks[name] then
		ESR.ServerCallbacks[name](source, cb, ...)
	else
		print(('[es_reworked] [^3WARNING^7] Server callback "%s" does not exist. Make sure that the server sided file really is loading, an error in that file might cause it to not load.'):format(name))
	end
end

ESR.SavePlayer = function(xPlayer, cb)
	local asyncTasks = {}

	table.insert(asyncTasks, function(cb2)
		MySQL.Async.execute('UPDATE users SET accounts = @accounts, job = @job, job_grade = @job_grade, `group` = @group, loadout = @loadout, position = @position, inventory = @inventory WHERE identifier = @identifier', {
			['@accounts'] = json.encode(xPlayer.getAccounts(true)),
			['@job'] = xPlayer.job.name,
			['@job_grade'] = xPlayer.job.grade,
			['@group'] = xPlayer.getGroup(),
			['@loadout'] = json.encode(xPlayer.getLoadout(true)),
			['@position'] = json.encode(xPlayer.getCoords()),
			['@identifier'] = xPlayer.getIdentifier(),
			['@inventory'] = json.encode(xPlayer.getInventory(true))
		}, function(rowsChanged)
			cb2()
		end)
	end)

	Async.parallel(asyncTasks, function(results)
		print(('[es_reworked] [^2INFO^7] Saved player "%s^7"'):format(xPlayer.getName()))

		if cb then
			cb()
		end
	end)
end

ESR.SavePlayers = function(cb)
	local xPlayers, asyncTasks = ESR.GetPlayers(), {}

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb2)
			local xPlayer = ESR.GetPlayerFromId(xPlayers[i])
			ESR.SavePlayer(xPlayer, cb2)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		print(('[es_reworked] [^2INFO^7] Saved %s player(s)'):format(#xPlayers))
		if cb then
			cb()
		end
	end)
end

ESR.StartDBSync = function()
	function saveData()
		ESR.SavePlayers()
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

ESR.GetPlayers = function()
	local sources = {}

	for k,v in pairs(ESR.Players) do
		table.insert(sources, k)
	end

	return sources
end

ESR.GetPlayerById = function(playerId)
	playerId = ESR.Ensure(playerId, 0)

	if (playerId <= 0) then return end
end

ESR.GetJobById = function(jobId)
	jobId = ESR.Ensure(jobId, 0)

	if (jobId <= 0) then return end
end

ESR.GetStorageById = function(storageId)
	storageId = ESR.Ensure(storageId, 0)

	if (storageId <= 0) then return end
end

ESR.GetPlayerFromId = function(source)
	return ESR.Players[tonumber(source)]
end

ESR.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(ESR.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

ESR.RegisterUsableItem = function(item, cb)
	ESR.UsableItemsCallbacks[item] = cb
end

ESR.UseItem = function(source, item)
	ESR.UsableItemsCallbacks[item](source, item)
end

ESR.GetItemLabel = function(item)
	if ESR.Items[item] then
		return ESR.Items[item].label
	end
end

ESR.CreatePickup = function(type, name, count, label, playerId, components, tintIndex)
	local pickupId = (ESR.PickupId == 65635 and 0 or ESR.PickupId + 1)
	local xPlayer = ESR.GetPlayerFromId(playerId)
	local coords = xPlayer.getCoords()

	ESR.Pickups[pickupId] = {
		type = type, name = name,
		count = count, label = label,
		coords = coords
	}

	if type == 'item_weapon' then
		ESR.Pickups[pickupId].components = components
		ESR.Pickups[pickupId].tintIndex = tintIndex
	end

	TriggerClientEvent('esx:createPickup', -1, pickupId, label, coords, type, name, components, tintIndex)
	ESR.PickupId = pickupId
end

ESR.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESR.Jobs[job] and ESR.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end
