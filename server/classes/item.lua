local function CreateItemClass(itemInfo)
    itemInfo = ESXR.Ensure(itemInfo, {})

    local xItem = {
        id = ESXR.Ensure(itemInfo.id, 0),
        name = ESXR.Ensure(itemInfo.name, 'unknown'),
        label = ESXR.Ensure(itemInfo.label, 'Unknown'),
        weight = ESXR.Ensure(itemInfo.weight, 0.25)
    }

    if (ESXR.Items ~= nil and ESXR.Items[xItem.id] ~= nil) then
        return ESXR.Ensure(ESXR.Items[xItem.id], {})
    end

    if (xItem.id <= 0) then
        error('xItem must have an valid `id` and must exsist in `items` table')
        return
    end

    if (ESXR.Items == nil) then ESXR.Items = ESXR.Ensure(ESXR.Items, {}) end
    if (ESXR.References == nil) then ESXR.References = ESXR.Ensure(ESXR.References, {}) end
    if (ESXR.References.Items == nil) then ESXR.References.Items = ESXR.Ensure(ESXR.References.Items, {}) end

    ESXR.Items[xItem.id] = xItem
    ESXR.References.Items[xItem.name] = xItem.id

    return ESXR.Items[xItem.id]
end

_G.CreateItemClass = CreateItemClass