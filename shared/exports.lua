exports('GetConfiguration', function()
    return ESR.Ensure(Configuration, {})
end)

exports('GetSharedObject', function()
    return ESR
end)

exports('IsLoaded', function()
    return ESR.Ensure(ESR.IsLoaded, false)
end)

exports('GetTranslations', LoadTranslations)