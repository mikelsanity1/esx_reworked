local function CreateStorageClass(storageInfo)
    storageInfo = ESR.Ensure(storageInfo, {})

    ---@class xStorage
    local xStorage = {
        __class = 'xItem',
        __type = 'xItem',
        id = ESR.Ensure(storageInfo.id, 0),
        name = ESR.Ensure(storageInfo.name, 'unknown'),
        label = ESR.Ensure(storageInfo.label, 'Unknown')
    }

    if (ESR.Storages ~= nil and ESR.Storages[xStorage.id] ~= nil) then
        return ESR.Ensure(ESR.Storages[xStorage.id], {})
    end

    if (xStorage.id <= 0) then
        error('xStorage must have an valid `id` and must exsist in `storages` table')
        return
    end

    if (ESR.Storages == nil) then ESR.Storages = ESR.Ensure(ESR.Storages, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Storages == nil) then ESR.References.Storages = ESR.Ensure(ESR.References.Storages, {}) end

    ESR.Storages[xStorage.id] = xStorage
    ESR.References.Storages[xStorage.name] = xStorage.id

    return ESR.Storages[xStorage.id]
end

--- Assign local as global variable
_G.CreateStorageClass = CreateStorageClass