local function CreateWeaponClass(weaponInfo)
    weaponInfo = ESR.Ensure(weaponInfo, {})

    ---@class xWeapon
    local xWeapon = {
        __class = 'xWeapon',
        __type = 'xWeapon',
        id = ESR.Ensure(weaponInfo.id, 0),
        uuid = ESR.Ensure(weaponInfo.uuid, 'unknown'),
        playerId = ESR.Ensure(weaponInfo.player_id, -1),
        storageId = ESR.Ensure(weaponInfo.storage_id, -1),
        jobId = ESR.Ensure(weaponInfo.job_id, -1),
        model = ESR.Ensure(weaponInfo.model, 'unknown'),
        bullets = ESR.Ensure(weaponInfo.bullets, 120),
        components = ESR.Ensure(weaponInfo.components, {}),
        ownerType = ESR.Ensure(weaponInfo.player_id, -1) > 0 and 'player' or 'job'
    }

    if (ESR.Weapons ~= nil and ESR.Weapons[xWeapon.id] ~= nil) then
        return ESR.Ensure(ESR.Weapons[xWeapon.id], {})
    end

    if (xWeapon.jobId <= 0 and xWeapon.playerId <= 0) then
        error('xWeapon must have an owner `player_id` or `storage_id` must be set')
        return
    end

    function xWeapon:GetBullets()
        return self.bullets or 120
    end

    function xWeapon:AddBullets(amount)
        amount = ESR.Ensure(amount, 0)

        if (amount <= 0) then return end

        self.bullets = self.bullets + amount

        return self
    end

    function xWeapon:RemoveBullets(amount)
        amount = ESR.Ensure(amount, 0)

        if (amount <= 0) then return end

        self.bullets = self.bullets - amount
        self.bullets = self.bullets > 0 and self.bullets or 0

        return self
    end

    function xWeapon:GetOwner()
        if (self.playerId > 0) then
            return ESR.GetPlayerById(self.playerId), self.ownerType
        end

        return ESR.GetJobById(self.jobId), self.ownerType
    end

    function xWeapon:GetStorage()
        return ESR.GetStorageById(self.storageId)
    end

    function xWeapon:ChangeStorage(input)
        local inputType = ESR.TypeOf(input)
        local storageId = 0

        if (inputType == 'xStorage' or inputType == 'table') then
            storageId = ESR.Ensure(input.id, 0)
        else
            storageId = ESR.Ensure(input, 0)
        end

        if (storageId <= 0) then
            return self
        end

        self.storageId = storageId

        return self
    end

    function xWeapon:ChangeOwner(input)
        self.jobId, self.playerId, self.ownerType = GetNewWeaponOwners(input, self.jobId, self.playerId, self.ownerType)

        return self
    end

    function xWeapon:Save(callback)
        callback = ESR.Ensure(callback, function() end)

        MySQL.Async.execute('UPDATE `weapons` SET `playerId` = @playerId, `jobId` = @jobId, `bullets` = @bullets, `storageId` = @storageId, `components` = @components WHERE `id` = @id', {
            ['id'] = self.id or 0,
            ['playerId'] = self.playerId > 0 and self.playerId or nil,
            ['jobId'] = self.jobId > 0 and self.jobId or nil,
            ['bullets'] = self.bullets or 120,
            ['storageId'] = self.storageId > 0 and self.storageId or nil,
            ['components'] = ESR.Endode(self.components) or '[]'
        }, function() callback() end)
    end

    if (ESR.Weapons == nil) then ESR.Weapons = ESR.Ensure(ESR.Weapons, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Weapons == nil) then ESR.References.Weapons = ESR.Ensure(ESR.References.Weapons, {}) end

    ESR.Weapons[xWeapon.id] = xWeapon
    ESR.References.Weapons[xWeapon.uuid] = xWeapon.id

    return ESR.Weapons[xWeapon.id]
end

local function GenerateNewWeaponAsync(model, owner, storage, callback)
    model = ESR.Ensure(model, 'unknown')
    callback = ESR.Ensure(callback, function() end)

    local jobId, playerId, ownerType = GetNewWeaponOwners(owner, -1, -1, 'unknown')

    if ((jobId <= 0 and playerId <= 0) or ownerType == 'unknown') then
        error('Parameter `owner` must be a valid owner, unknown owner given')
        return
    end

    local storageId, storageType = 0, ESR.TypeOf(storage)

    if (storageType == 'xStorage' or storageType == 'table') then
        storageId = ESR.Ensure(storage.id, 0)
    else
        storageId = ESR.Ensure(storage, 0)
    end

    if (storageId <= 0) then
        error('Parameter `storage` must be a valid storage, unknown storage given')
        return
    end

    MySQL.Async.insert('INSERT INTO `weapons` (`uuid`, `player_id`, `job_id`, `model`, `storage_id`, `components`) VALUES (UUID_TO_BIN(UUID()), @playerId, @jobId, @model, @storageId, "[]")', {
        ['playerId'] = playerId > 0 and playerId or nil,
        ['jobId'] = jobId > 0 and jobId or nil,
        ['model'] = model,
        ['storageId'] = storageId
    }, function(result)
        result = ESR.Ensure(result, 0)

        if (result > 0) then
            MySQL.Async.fetchAll('SELECT BIN_TO_UUID(`uuid`) AS `uuid`, `player_id`, `job_id`, `model`, `bullets`, `storage_id`, `components` FROM `weapons` WHERE `id` = @id LIMIT 1', {
                ['id'] = result
            }, function(rows)
                rows = ESR.Ensure(rows, {})

                if (#rows <= 0) then
                    error(('Added weapon not found in `weapons` matching ID: %s'):format(result))
                    return
                end

                local weapon = ESR.Ensure(rows[1], {})

                callback(CreateWeaponClass(weapon))
            end)
        end
    end)
end

local function GetNewWeaponOwners(input, _jobId, _playerId, _ownerType)
    _jobId = ESR.Ensure(_jobId, -1)
    _playerId = ESR.Ensure(_playerId, -1)
    _ownerType = ESR.Ensure(_ownerType, 'unknown')

    local inputType = ESR.TypeOf(input)

    if (inputType == 'xPlayer') then
        local playerId = ESR.Ensure(input.id, 0)

        if (playerId <= 0) then
            return _jobId, _playerId, _ownerType
        end

        return -1, playerId, 'player'
    end

    if (inputType == 'xJob') then
        local jobId = ESR.Ensure(input.id, 0)

        if (jobId <= 0) then
            return _jobId, _playerId, _ownerType
        end

        return jobId, -1, 'job'
    end

    if (inputType == 'table') then
        local rawId = ESR.Ensure(input.id, 0)

        if (rawId <= 0) then
            return _jobId, _playerId, _ownerType
        end

        if (input.identifier == nil) then
            return rawId, -1, 'job'
        else
            return -1, rawId, 'player'
        end

        return _jobId, _playerId, _ownerType
    end

    if (inputType == 'string') then
        if (ESR.StartsWith(input, 'job')) then
            local jobId = ESR.Ensure(string.sub(input, 4), 0)

            if (jobId <= 0) then
                return _jobId, _playerId, _ownerType
            end

            return jobId, -1, 'job'
        end

        if (ESR.StartsWith(input, 'player')) then
            local playerId = ESR.Ensure(string.sub(input, 7), 0)

            if (playerId <= 0) then
                return _jobId, _playerId, _ownerType
            end

            return -1, playerId, 'player'
        end
    end

    return _jobId, _playerId, _ownerType
end

--- Assign local as global variable
_G.CreateWeaponClass = CreateWeaponClass
_G.GenerateNewWeaponAsync = GenerateNewWeaponAsync
_G.GetNewWeaponOwners = GetNewWeaponOwners