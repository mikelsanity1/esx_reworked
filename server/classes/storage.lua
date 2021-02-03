local function CreateStorageClass(storageInfo)
    storageInfo = ESXR.Ensure(storageInfo, {})

    local xStorage = {
        id = ESXR.Ensure(storageInfo.id, 0),
        name = ESXR.Ensure(storageInfo.name, 'unknown'),
        label = ESXR.Ensure(storageInfo.label, 'Unknown')
    }

    if (ESXR.Storages ~= nil and ESXR.Storages[xStorage.id] ~= nil) then
        return ESXR.Ensure(ESXR.Storages[xStorage.id], {})
    end

    if (xStorage.id <= 0) then
        error('xStorage must have an valid `id` and must exsist in `storages` table')
        return
    end

    if (ESXR.Storages == nil) then ESXR.Storages = ESXR.Ensure(ESXR.Storages, {}) end
    if (ESXR.References == nil) then ESXR.References = ESXR.Ensure(ESXR.References, {}) end
    if (ESXR.References.Storages == nil) then ESXR.References.Storages = ESXR.Ensure(ESXR.References.Storages, {}) end

    ESXR.Storages[xStorage.id] = xStorage
    ESXR.References.Storages[xStorage.name] = xStorage.id

    return ESXR.Storages[xStorage.id]
end

--- Assign local as global variable
_G.CreateStorageClass = CreateStorageClass