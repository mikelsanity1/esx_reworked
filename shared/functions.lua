local err = error

ESXR.GetConfig = function()
    return ESXR.Ensure(Configuration, {})
end

ESXR.Any = function(input, inputs, checkType)
	if (input == nil or inputs == nil) then return false end

    inputs = ESXR.Ensure(inputs, {})
    checkType = ESXR.Ensure(checkType, 'value')

    local checkMethod = 1

    if (checkType == 'value' or checkType == 'v') then
        checkMethod = 1
    elseif (checkType == 'key' or checkType == 'k') then
        checkMethod = -1
    elseif (checkType == 'both' or checkType == 'b') then
        checkMethod = 0
    end

    for k, v in pairs(inputs) do
        if (checkMethod == 0 or checkMethod == -1) then
            local checkK = ESXR.Ensure(input, k, true)

            if (checkK ~= nil and checkK == k) then return true end
        end

        if (checkMethod == 0 or checkMethod == 1) then
            local checkV = ESXR.Ensure(input, v, true)

            if (checkV ~= nil and checkV == v) then return true end
        end
    end

    return false
end

ESXR.GetIdentifierType = function()
	if (ESXR.Ensure(ESXR.Cache, {}).IdentifierType) then
		return ESXR.Ensure(ESXR.Ensure(ESXR.Cache, {}).IdentifierType, 'license')
	end

	local identifierType = string.lower(ESXR.Ensure(ESXR.GetConfig().PrimaryIdentifier, 'license'))

	if (not ESXR.Any(identifierType, { 'license', 'steam', 'license2', 'xbl', 'live', 'discord', 'fivem', 'ip' }, 'value')) then
		return 'license'
	end

	if (ESXR.Cache == nil) then ESXR.Cache = {} end

	ESXR.Cache.IdentifierType = identifierType

	return identifierType
end

ESXR.Encode = function(input)
	local innerTable = ''
	local hasKey = false

	input = ESXR.Ensure(input, {})

	for k, v in pairs(input) do
		local keyType = ESXR.TypeOf(k) or 'nil'
		local valueType = ESXR.TypeOf(v) or 'nil'
		local finalValue = ''

		if (valueType ~= 'function') then
			local hasIndex = keyType == 'number'

			if (not hasIndex) then
				hasKey = true
				k = ESXR.Ensure(k, 'unknown')
			end

			if (valueType == 'table') then
				finalValue = hasIndex and ESXR.Encode(v) or ('"%s": %s'):format(k, ESXR.Encode(v))
			elseif (valueType == 'number') then
				finalValue = hasIndex and ('%.2f'):format(v) or ('"%s": %.2f'):format(k, v)
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

	return hasKey and ('{%s}'):format(innerTable) or ('[%s]'):format(innerTable)
end

ESXR.Tabs = function(tabs)
	tabs = ESXR.Ensure(tabs, 0)

	local s = ''

	for i = 0, tabs, 1 do
		s = ('%s    '):format(s)
	end

	return s
end

ESXR.DumpFunction = function(func, nb)
	func = ESXR.Ensure(func, function() end)
	nb = ESXR.Ensure(nb, 0)

	local info = ESXR.Ensure(debug.getinfo(func), {})
	local numberOfParameters = ESXR.Ensure(info.nparams, 0)
	local source = ESXR.Ensure(info.short_src, 'unknown')
	local line_start = ESXR.Ensure(info.linedefined, 0)
	local line_end = ESXR.Ensure(info.lastlinedefined, 0)
	local params = {}

	for i = 1, numberOfParameters, 1 do
		table.insert(params, ESXR.Ensure(debug.getlocal(func, i), 'unknown'))
	end

	local tab = ESXR.Tabs(nb)
	local str = ('^7function (\n%s^6parameters: ^7{\n%s\n%s^7},\n%s^6source: ^3"%s"^7,\n%s^6line: ^5%s^7:^5%s'):format(tab, ESXR.DumpColoredTable(params, nb + 1, false), tab, tab, source, tab, line_start, line_end)

	return ('%s\n%s^7)'):format(str, ESXR.Tabs(nb - 1))
end

ESXR.DumpColoredTable = function(input, nb, wrap)
	local innerTable = ''

	input = ESXR.Ensure(input, {})
	nb = ESXR.Ensure(nb, 0)
	wrap = ESXR.Ensure(wrap, true)

	for k, v in pairs(input) do
		local keyType = ESXR.TypeOf(k) or 'nil'
		local valueType = ESXR.TypeOf(v) or 'nil'
		local finalValue = ''
		local keyValue = ESXR.Ensure(k, "^9?")
		local hasIndex = keyType == 'number'

		if (not hasIndex) then
			k = ESXR.Ensure(k, 'unknown')
		end

		if (valueType == 'table') then
			finalValue = hasIndex and ('^7[^5%s^7] = ^5%s'):format(keyValue, ESXR.DumpColoredTable(v, nb + 1)) or ('^7[^3"%s"^7] = ^5%s'):format(keyValue, ESXR.DumpColoredTable(v, nb + 1))
		elseif (valueType == 'number') then
			finalValue = hasIndex and ('^7[^5%s^7] = ^4%.2f'):format(keyValue, v) or ('^7[^3"%s"^7] = ^4%.2f'):format(keyValue, v)
		elseif (valueType == 'string') then
			finalValue = hasIndex and ('^7[^5%s^7] = ^3"%s"'):format(keyValue, v) or ('^7[^3"%s"^7] = ^3"%s"'):format(keyValue, v)
		elseif (valueType == 'boolean') then
			finalValue = hasIndex and ('^7[^5%s^7] = %s'):format(keyValue, v and '^2true' or '^1false') or ('^7[^3"%s"^7] = %s'):format(keyValue, v and '^2true' or '^1false')
		elseif (valueType == 'vector2') then
			finalValue = hasIndex and ('^7[^5%s^7] = [^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y) or ('^7[^3"%s"^7] = [^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y)
		elseif (valueType == 'vector3') then
			finalValue = hasIndex and ('^7[^5%s^7] = [^4%.2f^7,^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y, v.z) or ('^7[^3"%s"^7] = [^4%.2f^7,^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y, v.z)
		elseif (valueType == 'vector4') then
			finalValue = hasIndex and ('^7[^5%s^7] = [^4%.2f^7,^4%.2f^7,^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y, v.z, v.w) or ('^7[^3"%s"^7] = [^4%.2f^7,^4%.2f^7,^4%.2f^7,^4%.2f^7]'):format(keyValue, v.x, v.y, v.z, v.w)
		elseif (valueType == 'function') then
			finalValue = hasIndex and ('^7[^5%s^7] = %s'):format(keyValue, ESXR.DumpFunction(v, nb + 1)) or ('^7[^3"%s"^7] = %s'):format(keyValue, ESXR.DumpFunction(v, nb + 1))
		end

		if (innerTable == nil or string.len(innerTable) == 0) then
			innerTable = ('%s%s'):format(ESXR.Tabs(nb), finalValue)
		else
			innerTable = ('%s^7,\n%s%s'):format(innerTable, ESXR.Tabs(nb), finalValue)
		end
	end

	return wrap and ('^7{\n%s\n%s^7}'):format(innerTable, ESXR.Tabs(nb - 1)) or innerTable
end

ESXR.StartsWith = function(str, word)
    str = ESXR.Ensure(str, 'unknown')
    word = ESXR.Ensure(word, 'unknown')

    return str:sub(1, #word) == word
end

ESXR.EndsWith = function(str, word)
    str = ESXR.Ensure(str, 'unknown')
    word = ESXR.Ensure(word, 'unknown')

    return str:sub(-#word) == word
end

ESXR.TypeOf = function(input)
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

ESXR.Ensure = function(input, default, ignoreDefault)
	if (ignoreDefault == nil) then
		ignoreDefault = false
	else
		ignoreDefault = ESXR.Ensure(ignoreDefault, false)
	end

	if (default == nil) then return nil end
	if (input == nil) then return (not ignoreDefault and default or nil) end

	local input_type = ESXR.TypeOf(input)
	local output_type = ESXR.TypeOf(default)

	if (input_type == output_type) then return input end

	if (output_type == 'number') then
		if (input_type == 'string') then return tonumber(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'boolean') then return input and 1 or 0 end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'string') then
		if (input_type == 'number') then return tostring(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'boolean') then return input and 'yes' or 'no' end
		if (input_type == 'table') then return ESXR.Encode(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'vector3') then return ESXR.Encode({ input.x, input.y, input.z }) or (not ignoreDefault and default or nil) end
		if (input_type == 'vector2') then return ESXR.Encode({ input.x, input.y }) or (not ignoreDefault and default or nil) end

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
			local x = ESXR.Ensure(input.x, default.x)
			local y = ESXR.Ensure(input.y, default.y)

			return vector2(x, y)
		end

		if (input_type == 'vector3') then
			return input.xy
		end

		if (input_type == 'number') then
			return vector2(input, input)
		end

		if (input_type == 'string' and ESXR.StartsWith(input, '{') and ESXR.EndsWith(input, '}')) then
			local decodedInput = ESXR.Ensure(json.decode(input), {})

			local x = ESXR.Ensure(decodedInput.x, default.x)
			local y = ESXR.Ensure(decodedInput.y, default.y)

			return vector2(x, y)
		end

		if (input_type == 'string' and ESXR.StartsWith(input, '[') and ESXR.EndsWith(input, ']')) then
			local decodedInput = ESXR.Ensure(json.decode(input), {})

			local x = ESXR.Ensure(decodedInput[1], default.x)
			local y = ESXR.Ensure(decodedInput[2], default.y)

			return vector2(x, y)
		end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'vector3') then
		if (input_type == 'table' or input_type == 'vector2') then
			local x = ESXR.Ensure(input.x, default.x)
			local y = ESXR.Ensure(input.y, default.y)
			local z = ESXR.Ensure(input.z, input_type == 'vector2' and 0 or default.z)

			return vector3(x, y, z)
		end

		if (input_type == 'number') then
			return vector3(input, input, input)
		end

		if (input_type == 'string' and ESXR.StartsWith(input, '{') and ESXR.EndsWith(input, '}')) then
			local decodedInput = ESXR.Ensure(json.decode(input), {})

			local x = ESXR.Ensure(decodedInput.x, default.x)
			local y = ESXR.Ensure(decodedInput.y, default.y)
			local z = ESXR.Ensure(decodedInput.z, default.z)

			return vector3(x, y, z)
		end

		if (input_type == 'string' and ESXR.StartsWith(input, '[') and ESXR.EndsWith(input, ']')) then
			local decodedInput = ESXR.Ensure(json.decode(input), {})

			local x = ESXR.Ensure(decodedInput[1], default.x)
			local y = ESXR.Ensure(decodedInput[2], default.y)
			local z = ESXR.Ensure(decodedInput[3], default.z)

			return vector3(x, y, z)
		end

		return (not ignoreDefault and default or nil)
	end

	if (output_type == 'table') then
		if (input_type == 'string') then
			if ((ESXR.StartsWith('{') and ESXR.EndsWith('}')) or (ESXR.StartsWith('[') and ESXR.EndsWith(']'))) then
				return json.decode(input) or (not ignoreDefault and default or nil)
			end

			return { input } or (not ignoreDefault and default or nil)
		end

		if (input_type == 'vector2') then
			return { ESXR.Ensure(input.x, 0), ESXR.Ensure(input.y, 0) } or (not ignoreDefault and default or nil)
		end

		if (input_type == 'vector3') then
			return { ESXR.Ensure(input.x, 0), ESXR.Ensure(input.y, 0), ESXR.Ensure(input.z, 0) } or (not ignoreDefault and default or nil)
		end

		if (input_type == 'vector4') then
			return { ESXR.Ensure(input.x, 0), ESXR.Ensure(input.y, 0), ESXR.Ensure(input.z, 0), ESXR.Ensure(input.w, 0) } or (not ignoreDefault and default or nil)
		end

		if (input_type == 'boolean' or input_type == 'number') then
			return { input } or (not ignoreDefault and default or nil)
		end
	end

	return (not ignoreDefault and default or nil)
end

ESXR.ArgumentsToString = function(...)
	local str, args = '', { ... }

	for i = 1, #args, 1 do
        str = ('%s %s'):format(str, ESXR.Ensure(args[i], ''))
	end

	return str
end

ESXR.Print = function(...)
	local str = ESXR.ArgumentsToString(...)

    print(('^7[INFO] ^7ESX_REWORKED^7 >^7%s^7'):format(str))
end

ESXR.PrintWarn = function(...)
	local str = ESXR.ArgumentsToString(...)

    print(('^7[^3WARN^7] ^7ESX_REWORKED^7 >^3%s^7'):format(str))
end

ESXR.PrintSuccess = function(...)
	local str = ESXR.ArgumentsToString(...)

    print(('^7[^2SUCCESS^7] ^7ESX_REWORKED^7 >^2%s^7'):format(str))
end

ESXR.PrintError = function(msg)
	msg = ESXR.Ensure(msg, 'UNKNOWN ERROR')

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
		error_message = ('^7[^1ERROR^7] ^7ESX_REWORKED^7 > ^1%s^7'):format(msg)
	else
		error_message = ('^7[^1ERROR^7] ^7ESX_REWORKED^7 > ^1%s\n^7%s^7'):format(msg, fst)
	end

	print(error_message)
end

ESXR.TryCatch = function(func, catch, ...)
	func = ESXR.Ensure(func, function() end)
	catch = ESXR.Ensure(catch, function() end)

	local ok = xpcall(func, function(...)
		catch(...)
	end, ...)
end

ESXR.Round = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

ESXR.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

ESXR.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

ESXR.SizeOf = function(t)
	local count = 0

	for _,_ in pairs(t) do
		count = count + 1
	end

	return count
end

ESXR.Set = function(t)
	local set = {}
	for k,v in ipairs(t) do set[v] = true end
	return set
end

ESXR.IndexOf = function(t, value)
	for i=1, #t, 1 do
		if t[i] == value then
			return i
		end
	end

	return -1
end

ESXR.LastIndexOf = function(t, value)
	for i=#t, 1, -1 do
		if t[i] == value then
			return i
		end
	end

	return -1
end

ESXR.Find = function(t, cb)
	for i=1, #t, 1 do
		if cb(t[i]) then
			return t[i]
		end
	end

	return nil
end

ESXR.FindIndex = function(t, cb)
	for i=1, #t, 1 do
		if cb(t[i]) then
			return i
		end
	end

	return -1
end

ESXR.Filter = function(t, cb)
	local newTable = {}

	for i=1, #t, 1 do
		if cb(t[i]) then
			table.insert(newTable, t[i])
		end
	end

	return newTable
end

ESXR.Map = function(t, cb)
	local newTable = {}

	for i=1, #t, 1 do
		newTable[i] = cb(t[i], i)
	end

	return newTable
end

ESXR.Reverse = function(t)
	local newTable = {}

	for i=#t, 1, -1 do
		table.insert(newTable, t[i])
	end

	return newTable
end

ESXR.Clone = function(t)
	if type(t) ~= 'table' then return t end

	local meta = getmetatable(t)
	local target = {}

	for k,v in pairs(t) do
		if type(v) == 'table' then
			target[k] = ESXR.Clone(v)
		else
			target[k] = v
		end
	end

	setmetatable(target, meta)

	return target
end

ESXR.Concat = function(t1, t2)
	local t3 = ESXR.Clone(t1)

	for i=1, #t2, 1 do
		table.insert(t3, t2[i])
	end

	return t3
end

ESXR.Join = function(t, sep)
	local sep = sep or ','
	local str = ''

	for i=1, #t, 1 do
		if i > 1 then
			str = str .. sep
		end

		str = str .. t[i]
	end

	return str
end

ESXR.Sort = function(t, order)
	local keys = {}

	for k,_ in pairs(t) do
		keys[#keys + 1] = k
	end

	if order then
		table.sort(keys, function(a,b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	local i = 0

	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

ESXR.Split = function(str, sep)
	str = ESXR.Ensure(str, '')
	sep = ESXR.Ensure(sep, ',')

	local fields = {}
	local pattern = ('([^%s]+)'):format(sep)

	str:gsub(pattern, function(c)
		table.insert(fields, ESXR.Trim(ESXR.Ensure(c, '')))
	end)

	return fields
end

ESXR.Replace = function(str, this, that, plain)
	str = ESXR.Ensure(str, '')
	this = ESXR.Ensure(this, '')
	that = ESXR.Ensure(that, '')
	plain = ESXR.Ensure(plain, false)

	local b, e = str:find(this, 1, plain)

	if (b == nil) then
		return str
	else
		return str:sub(1, b - 1) .. that .. ESXR.Replace(str:sub(e + 1), this, that, plain)
	end
end

ESXR.EscapePattern = function(str)
	return ESXR.Ensure(str, ''):gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
end

ESXR.Parse = function(str)
	str = ESXR.Ensure(str, '')

	local tokenized = str
    	:gsub("%*%*", "__DOUBLE_WILDCARD__")
    	:gsub("%*", "__WILDCARD__")
		:gsub("%?", "__ANY_CHAR__")
	local escaped = ESXR.EscapePattern(tokenized)
	local pattern = escaped
		:gsub("__DOUBLE_WILDCARD__", ".+")
    	:gsub("__WILDCARD__", "[^/]+")
		:gsub("__ANY_CHAR__", ".")

	return "^" .. pattern
end

_G.error = function(...)
	ESXR.PrintError(...)
	err(...)
end