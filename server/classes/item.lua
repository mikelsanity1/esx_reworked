local function CreateItemClass(itemInfo)
    itemInfo = ESR.Ensure(itemInfo, {})

    ---@class xItem
    local xItem = {
        __class = 'xItem',
        __type = 'xItem',
        id = ESR.Ensure(itemInfo.id, 0),
        name = ESR.Ensure(itemInfo.name, 'unknown'),
        label = ESR.Ensure(itemInfo.label, 'Unknown'),
        weight = ESR.Ensure(itemInfo.weight, 0.25)
    }

    if (ESR.Items ~= nil and ESR.Items[xItem.id] ~= nil) then
        return ESR.Ensure(ESR.Items[xItem.id], {})
    end

    if (xItem.id <= 0) then
        error('xItem must have an valid `id` and must exsist in `items` table')
        return
    end

    if (ESR.Items == nil) then ESR.Items = ESR.Ensure(ESR.Items, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Items == nil) then ESR.References.Items = ESR.Ensure(ESR.References.Items, {}) end

    ESR.Items[xItem.id] = xItem
    ESR.References.Items[xItem.name] = xItem.id

    return ESR.Items[xItem.id]
end

--- Assign local as global variable
_G.CreateItemClass = CreateItemClass