local function LoadPermissions(name, groupInfo)
    name = string.lower(ESXR.Ensure(name, 'unknown'))
    groupInfo = ESXR.Ensure(groupInfo, {})

    local parentOf = ESXR.Ensure(groupInfo.parentOf, 'unknown')
    local group = {
        name = name,
        priority = 1,
        permissions = {},
        denies = {},
        parentOf = parentOf ~= 'unknown' and parentOf or nil
    }

    if (group.parentOf ~= nil and ESXR.Groups[group.parentOf] == nil) then
        error(("Group '%s' is loaded before '%s', make sure that group '%s' is loaded after '%'"):format(group.name, group.parentOf, group.parentOf, group.name))
        return
    end

    group.priority = ESXR.Ensure(groupInfo.priority, group.priority)

    for k, v in pairs(ESXR.Ensure(groupInfo.permissions, {})) do
        v = ESXR.Ensure(v, 'unknown')

        if (v ~= 'unknown') then
            table.insert(group.permissions, v)
        end
    end

    for k, v in pairs(ESXR.Ensure(groupInfo.denies, {})) do
        v = ESXR.Ensure(v, 'unknown')

        if (v ~= 'unknown') then
            table.insert(group.denies, v)
        end
    end

    if (group.parentOf ~= nil and ESXR.Groups[group.parentOf] ~= nil) then
        for k, v in pairs(ESXR.Ensure(ESXR.Groups[group.parentOf].permissions, {})) do
            table.insert(group.permissions, v)
        end
    end

    ESXR.PrintSuccess(_('group_loaded', group.name))
    ESXR.Groups[group.name] = group
end

local function ListHasPerm(list, perm)
    list = ESXR.Ensure(list, {})
    perm = ESXR.Ensure(perm, 'unknown')

    if (perm == 'unknown') then return false end

    for k, v in pairs(list) do
        v = ESXR.Ensure(v, 'unknown')
        v = ESXR.Parse(v)

        if (perm == perm:match(v)) then
            return true
        end
    end

    return false
end

ESXR.Permissions.GroupHasPermission = function(group, permission)
    group = ESXR.Ensure(group, 'unknown')
    permission = ESXR.Ensure(permission, 'unknown')

    if (group == 'unknown' or permission == 'unknown' or ESXR.Groups[group] == nil) then
        return false
    end

    local allows = ESXR.Ensure(ESXR.Groups[group].permissions, {})
    local denies = ESXR.Ensure(ESXR.Groups[group].denies, {})
    local isAllowed, isDenied = ListHasPerm(allows, permission), ListHasPerm(denies, permission)

    return isAllowed and not isDenied
end

_G.group = function(name)
    local group = { name = string.lower(ESXR.Ensure(name, 'unknown')) }

    if (ESXR.Groups == nil) then ESXR.Groups = {} end

    if (ESXR.Groups[name] ~= nil) then
        error("Group '%s' already exists, you can't override that group.")
        return
    end

    return setmetatable(group, {
        __call = function(t, v)
            local n = ESXR.Ensure(ESXR.Ensure(t, {}).name, 'unknown')

            if (ESXR.Groups[n] ~= nil) then
                error(("Group '%s' already exists, you can't override that group."):format(n))
                return
            end

            if (n ~= 'unknown') then
                LoadPermissions(n, ESXR.Ensure(v, {}))
            end
        end
    })
end