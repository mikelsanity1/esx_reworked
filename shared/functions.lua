local err = error

ESR.GetConfig = function()
    return Configuration
end

ESR.Endode = function(input)
	local innerTable = ''
	local isList = true

	input = ESR.Ensure(input, {})

	for k, v in pairs(input) do
		local keyType = ESR.TypeOf(k) or 'nil'
		local valueType = ESR.TypeOf(v) or 'nil'
		local finalValue = ''

		if (valueType ~= 'function') then
			local hasIndex = keyType == 'number'

			if (hasIndex) then
				isList = false
			else
				k = ESR.Ensure(k, 'unknown')
			end

			if (valueType == 'table') then
				finalValue = hasIndex and ESR.Ensure(v) or ('"%s": %s'):format(k, ESR.Ensure(v))
			elseif (valueType == 'number') then
				finalValue = hasIndex and v or ('"%s": %s'):format(k, v)
			elseif (valueType == 'string') then
				finalValue = hasIndex and ('"%s"'):format(v) or ('"%s": "%s"'):format(k, v)
			elseif (valueType == 'boolean') then
				finalValue = hasIndex and ('%s'):format(v and 'true' or 'false') or ('"%s": %s'):format(k, v and 'true' or 'false')
			elseif (valueType == 'vector2') then
				finalValue = hasIndex and ('[%.2f,%.2f]'):format(v.x, v.y) or ('"%s": [%.2f,%.2f]'):format(k, v.x, v.y)
			elseif (valueType == 'vector3') then
				finalValue = hasIndex and ('[%.2f,%.2f,%.2f]'):format(v.x, v.y, v.z) or ('"%s": [%.2f,%.2f,%.2f]'):format(k, v.x, v.y, v.z)
			elseif (valueType == 'vector4') then
				finalValue = hasIndex and ('[%.2f,%.2f,%.2f,%.2f]'):format(v.x, v.y, v.z, v.w) or ('"%s": [%.2f,%.2f,%.2f,%.2f]'):format(k, v.x, v.y, v.z, v.w)
			end
		end

		if (innerTable == nil or string.len(innerTable) == 0) then
			innerTable = finalValue
		else
			innerTable = ('%s,%s'):format(innerTable, finalValue)
		end
	end

	return isList and ('[%s]'):format(innerTable) or ('{%s}'):format(innerTable)
end

ESR.StartsWith = function(str, word)
    str = ESR.Ensure(str, 'unknown')
    word = ESR.Ensure(word, 'unknown')

    return str:sub(1, #word) == word
end

ESR.EndsWith = function(str, word)
    str = ESR.Ensure(str, 'unknown')
    word = ESR.Ensure(word, 'unknown')

    return str:sub(-#word) == word
end

ESR.TypeOf = function(input)
	if (input == nil) then return 'nil' end

	local t = type(input)

	if (t ~= 'table') then return t end

	if (rawget(input, '__cfx_functionReference') ~= nil or
		rawget(input, '__cfx_async_retval') ~= nil) then
		return 'function'
	end

	if (rawget(input, '__cfx_functionSource') ~= nil) then
		return 'number'
	end

	local __class = rawget(input, '__class')

	if (__class ~= nil) then
		return type(__class) == 'string' and __class or 'class'
	end

	local __type = rawget(input, '__type')

	if (__type ~= nil) then
		return type(__type) == 'string' and __type or '__type'
	end

	return t
end

ESR.Ensure = function(input, default, ignoreDefault)
	if (ignoreDefault == nil) then
		ignoreDefault = false
	else
		ignoreDefault = ESR.Ensure(ignoreDefault, false)
	end

	if (default == nil) then return nil end
	if (input == nil) then return (not ignoreDefault and default or nil) end

	local input_type = ESR.TypeOf(input)
	local output_type = ESR.TypeOf(default)

	if (input_type == output_type) then return input end

	if (output_type == 'number') then
		if (input_type == 'string') then return tonumber(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'boolean') then return input and 1 or 0 end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'string') then
		if (input_type == 'number') then return tostring(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'boolean') then return input and 'yes' or 'no' end
		if (input_type == 'table') then return json.encode(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'vector3') then return json.encode({ input.x, input.y, input.z }) or (not ignoreDefault and default or nil) end
		if (input_type == 'vector2') then return json.encode({ input.x, input.y }) or (not ignoreDefault and default or nil) end

		return tostring(input) or (not ignoreDefault and default or nil)
	end

	if (output_type == 'boolean') then
		if (input_type == 'string') then
			input = string.lower(input)

			if (input == 'true' or input == '1' or input == 'yes' or input == 'y') then return true end
			if (input == 'false' or input == '0' or input == 'no' or input == 'n') then return false end

			return (not ignoreDefault and default or nil)
		end

		if (input_type == 'number') then
			if (input == 1) then return true end
			if (input == 0) then return false end

			return (not ignoreDefault and default or nil)
		end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'vector2') then
		if (input_type == 'table') then
			local x = ESR.Ensure(input.x, default.x)
			local y = ESR.Ensure(input.y, default.y)

			return vector2(x, y)
		end

		if (input_type == 'vector3') then
			return input.xy
		end

		if (input_type == 'number') then
			return vector2(input, input)
		end

		if (input_type == 'string' and ESR.StartsWith(input, '{') and ESR.EndsWith(input, '}')) then
			local decodedInput = ESR.Ensure(json.decode(input), {})

			local x = ESR.Ensure(decodedInput.x, default.x)
			local y = ESR.Ensure(decodedInput.y, default.y)

			return vector2(x, y)
		end

		if (input_type == 'string' and ESR.StartsWith(input, '[') and ESR.EndsWith(input, ']')) then
			local decodedInput = ESR.Ensure(json.decode(input), {})

			local x = ESR.Ensure(decodedInput[1], default.x)
			local y = ESR.Ensure(decodedInput[2], default.y)

			return vector2(x, y)
		end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'vector3') then
		if (input_type == 'table' or input_type == 'vector2') then
			local x = ESR.Ensure(input.x, default.x)
			local y = ESR.Ensure(input.y, default.y)
			local z = ESR.Ensure(input.z, input_type == 'vector2' and 0 or default.z)

			return vector3(x, y, z)
		end

		if (input_type == 'number') then
			return vector3(input, input, input)
		end

		if (input_type == 'string' and ESR.StartsWith(input, '{') and ESR.EndsWith(input, '}')) then
			local decodedInput = ESR.Ensure(json.decode(input), {})

			local x = ESR.Ensure(decodedInput.x, default.x)
			local y = ESR.Ensure(decodedInput.y, default.y)
			local z = ESR.Ensure(decodedInput.z, default.z)

			return vector3(x, y, z)
		end

		if (input_type == 'string' and ESR.StartsWith(input, '[') and ESR.EndsWith(input, ']')) then
			local decodedInput = ESR.Ensure(json.decode(input), {})

			local x = ESR.Ensure(decodedInput[1], default.x)
			local y = ESR.Ensure(decodedInput[2], default.y)
			local z = ESR.Ensure(decodedInput[3], default.z)

			return vector3(x, y, z)
		end

		return (not ignoreDefault and default or nil)
	end

	return (not ignoreDefault and default or nil)
end

ESR.ArgumentsToString = function(...)
	local str, args = '', { ... }

	for i = 1, #args, 1 do
        str = ('%s %s'):format(str, ESR.Ensure(args[i], ''))
	end

	return str
end

ESR.Print = function(...)
	local str = ESR.ArgumentsToString(...)

    print(('\n^7[INFO] ^7ES_REWORKED^7 >^7%s\n'):format(str))
end

ESR.PrintSuccess = function(...)
	local str = ESR.ArgumentsToString(...)

    print(('\n^7[^2SUCCESS^7] ^7ES_REWORKED^7 >^2%s\n'):format(str))
end

ESR.PrintError = function(msg)
	msg = ESR.Ensure(msg, 'UNKNOWN ERROR')

	local fst = Citizen.InvokeNative(-0x28F3C436 & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())
	local error_message = nil
	local start_index, end_index = msg:find(':%d+:')

	if (start_index and end_index) then
		msg = ('%s^7 line^1:^7%s^7\n\n^1%s\n'):format(
			msg:sub(1, start_index - 1),
			msg:sub(start_index + 1, end_index - 1),
			msg:sub(end_index + 1)
		)
	end

	if (not fst) then
		error_message = ('\n^7[^1ERROR^7] ^7ES_REWORKED^7 >^1%s^7\n'):format(msg)
	else
		error_message = ('\n^7[^1ERROR^7] ^7ES_REWORKED^7 >^1%s\n^7%s^7\n'):format(msg, fst)
	end

	print(error_message)
end

_G.error = function(...)
	ESR.PrintError(...)
end