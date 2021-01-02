exports('GetConfiguration', function()
    return ESXR.Ensure(Configuration, {})
end)

exports('GetSharedObject', function()
    return ESXR
end)

exports('IsLoaded', function()
    return ESXR.Ensure(ESXR.IsLoaded, false)
end)

exports('GetTranslations', LoadTranslations)