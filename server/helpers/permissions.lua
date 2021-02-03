local function LoadPermissions(name, groupInfo)
    name = string.lower(ESXR.Ensure(name, 'unknown'))
    groupInfo = ESXR.Ensure(groupInfo, {})

    local parentOf = ESXR.Ensure(groupInfo.parentOf, 'unknown')

    ---@class group
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

local function LoadJobPermissions(name, jobInfo)
    name = string.lower(ESXR.Ensure(name, 'unknown'))
    jobInfo = ESXR.Ensure(jobInfo, {})

    local parentOf = ESXR.Ensure(jobInfo.parentOf, 'unknown')

    ---@class job
    local job = {
        name = name,
        permissions = {},
        denies = {},
        parentOf = parentOf ~= 'unknown' and parentOf or nil
    }

    if (job.parentOf ~= nil and ESXR.JobPermissions[job.parentOf] == nil) then
        error(("Job '%s' is loaded before '%s', make sure that job '%s' is loaded after '%'"):format(job.name, job.parentOf, job.parentOf, job.name))
        return
    end

    for k, v in pairs(ESXR.Ensure(jobInfo.permissions, {})) do
        v = ESXR.Ensure(v, 'unknown')

        if (v ~= 'unknown') then
            table.insert(job.permissions, v)
        end
    end

    for k, v in pairs(ESXR.Ensure(jobInfo.denies, {})) do
        v = ESXR.Ensure(v, 'unknown')

        if (v ~= 'unknown') then
            table.insert(job.denies, v)
        end
    end

    if (job.parentOf ~= nil and ESXR.JobPermissions[job.parentOf] ~= nil) then
        for k, v in pairs(ESXR.Ensure(ESXR.JobPermissions[job.parentOf].permissions, {})) do
            table.insert(job.permissions, v)
        end
    end

    ESXR.PrintSuccess(_('job_loaded', job.name))
    ESXR.JobPermissions[job.name] = job
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

ESXR.Permissions.JobHasPermission = function(job, permission)
    job = ESXR.Ensure(job, 'unknown')
    permission = ESXR.Ensure(permission, 'unknown')

    if (job == 'unknown' or permission == 'unknown' or ESXR.JobPermissions[job] == nil) then
        return false
    end

    local allows = ESXR.Ensure(ESXR.JobPermissions[job].permissions, {})
    local denies = ESXR.Ensure(ESXR.JobPermissions[job].denies, {})
    local isAllowed, isDenied = ListHasPerm(allows, permission), ListHasPerm(denies, permission)

    return isAllowed and not isDenied
end

_G.group = function(name)
    name = string.lower(ESXR.Ensure(name, 'unknown'))

    local group = { name = name }

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

_G.job = function(name)
    name = string.lower(ESXR.Ensure(name, 'unknown'))

    local job = { name = name }

    if (ESXR.JobPermissions == nil) then ESXR.JobPermissions = {} end

    if (ESXR.JobPermissions[name] ~= nil) then
        error("Job '%s' already exists, you can't override that job.")
        return
    end

    return setmetatable(job, {
        __call = function(t, v)
            local n = ESXR.Ensure(ESXR.Ensure(t, {}).name, 'unknown')

            if (ESXR.JobPermissions[n] ~= nil) then
                error(("Job '%s' already exists, you can't override that job."):format(n))
                return
            end

            if (n ~= 'unknown') then
                LoadJobPermissions(n, ESXR.Ensure(v, {}))
            end
        end
    })
end