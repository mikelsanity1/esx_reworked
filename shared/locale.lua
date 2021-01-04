local function TypeOf(input)
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

local function Ensure(input, default, ignoreDefault)
	if (ignoreDefault == nil) then
		ignoreDefault = false
	else
		ignoreDefault = Ensure(ignoreDefault, false)
	end

	if (default == nil) then return nil end
	if (input == nil) then return (not ignoreDefault and default or nil) end

	local input_type = TypeOf(input)
	local output_type = TypeOf(default)

	if (input_type == output_type) then return input end

	if (output_type == 'string') then
		if (input_type == 'number') then return tostring(input) or (not ignoreDefault and default or nil) end
		if (input_type == 'boolean') then return input and 'yes' or 'no' end
		if (input_type == 'table') then return ESXR.Encode(input) or (not ignoreDefault and default or nil) end

		return tostring(input) or (not ignoreDefault and default or nil)
	end

	return (not ignoreDefault and default or nil)
end

_G.Locale = {
    Translations = {},
    Loaded = false,
	ResourceName = GetCurrentResourceName()
}

_G.LoadTranslations = function()
	if (Locale.Loaded) then
		return Ensure(Locale.Translations, {})
	end

	local configuration = Ensure(Configuration, {})
	local language = Ensure(configuration.DefaultLanguage, 'en')
	local trans = Locale.ResourceName == 'esx_reworked' and {} or exports['esx_reworked']:GetTranslations()

	trans = Ensure(trans, {})

	local rawTranslations = LoadResourceFile(Locale.ResourceName, ('locales/%s.json'):format(language))

	if (rawTranslations) then
		for k, v in pairs(Ensure(json.decode(rawTranslations), {})) do
			if (TypeOf(k) == 'string' and TypeOf(v) == 'string') then
				trans[k] = v
			end
		end
	end

	Locale.Loaded = true
	Locale.Translations = trans

	return Ensure(Locale.Translations, {})
end

_G._ = function(key, ...)
    key = Ensure(key, 'unknown')

    if (not Locale.Loaded) then
        LoadTranslations()

        return _(key, ...)
    end

    local fallbackString = ("Translation ['%s'] does not exist"):format(key)

    return Ensure(Locale.Translations[key], fallbackString):format(...)
end

_G._U = function(key, ...)
    return _(key):gsub('^%l', string.upper)
end

Citizen.CreateThread(function()
	LoadTranslations()
end)