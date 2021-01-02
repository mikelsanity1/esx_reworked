local function CreatePlayerClass(playerInfo, source)
    playerInfo = ESR.Ensure(playerInfo, {})

    local identifierType = ESR.Ensure(Configuration.PrimaryIdentifier, 'license')
    local pos = ESR.Ensure(playerInfo.position, {})

    ---@class xPlayer
    local xPlayer = {
        __class = 'xPlayer',
        __type = 'xPlayer',
        loaded = false,
        source = ESR.Ensure(source, -1),
        id = ESR.Ensure(playerInfo.id, 0),
        identifier = ESR.Ensure(playerInfo.identifier, 'none'),
        name = ESR.Ensure(playerInfo.name, 'Unknown'),
        group = ESR.Ensure(playerInfo.group, 'user'),
        job = CreateJobObject(playerInfo.job, playerInfo.grade),
        position = vector3(
            ESR.Ensure(pos[1], -206.79),
            ESR.Ensure(pos[2], -1015.12),
            ESR.Ensure(pos[3], 29.14)
        ),
        wallets = {},
        inventory = {},
        variables = {}
    }

    if (ESR.Players ~= nil and ESR.Players[xPlayer.id] ~= nil) then
        ESR.Players[xPlayer.id].source = ESR.Ensure(source, ESR.Players[xPlayer.id].source)

        return ESR.Ensure(ESR.Players[xPlayer.id], {})
    end

    if (xPlayer.id <= 0) then
        error('xPlayer must have an valid `id` and must exsist in `players` table')
        return
    end

    ExecuteCommand(('add_principal identifier.%s:%s group.%s'):format(identifierType, xPlayer.identifier, xPlayer.group))

    function xPlayer:IsOnline()
        return ESR.Ensure(self.source, 0) > 0
    end

    function xPlayer:IsLoaded()
        return ESR.Ensure(self.loaded, false)
    end

    function xPlayer:TriggerEvent(name, ...)
        name = ESR.Ensure(name, 'unknown')

        if (self:IsOnline()) then
            TriggerClientEvent(name, self.source, ...)
        end

        return self
    end

    function xPlayer:Kick(reason)
        reason = ESR.Ensure(reason, _('no_reason_specified'))

        if (self:IsOnline()) then
            DropPlayer(self.source, reason)
        end

        return self
    end

    function xPlayer:GetIdentifier()
        return ESR.Ensure(self.identifier, 'none')
    end

    function xPlayer:GetGroup()
        return ESR.Ensure(self.group, 'user')
    end

    function xPlayer:SetGroup(group)
        ExecuteCommand(('remove_principal identifier.%s:%s group.%s'):format(identifierType, self:GetIdentifier(), self:GetGroup()))

        self.group = ESR.Ensure(group, 'user')

        ExecuteCommand(('add_principal identifier.%s:%s group.%s'):format(identifierType, self:GetIdentifier(), self:GetGroup()))

        return self
    end

    function xPlayer:Set(values)
        self.variables = ESR.Table.Concat(
            ESR.Ensure(self.variables, {}),
            ESR.Ensure(values, {}))

        return self
    end

    function xPlayer:Get(key)
        key = ESR.Ensure(key, 'unknown')

        for k, v in pairs(ESR.Ensure(self.variables, {})) do
            if (ESR.Ensure(k) == key) then
                return v
            end
        end

        return nil
    end

    function xPlayer:GetMoney()
        local wallet = self:GetWallet('money')

        if (wallet) then
            return ESR.Ensure(wallet.saldo, 0)
        end

        return 0
    end

    function xPlayer:SetMoney(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        return xPlayer:SetWallet('money', money)
    end

    function xPlayer:AddMoney(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        if (money > 0) then
            return xPlayer:AddWallet('money', money)
        end

        return self
    end

    function xPlayer:RemoveMoney(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        if (money > 0) then
            return xPlayer:RemoveWallet('money', money)
        end

        return self
    end

    function xPlayer:GetBank()
        local wallet = self:GetWallet('bank')

        if (wallet) then
            return ESR.Ensure(wallet.saldo, 0)
        end

        return 0
    end

    function xPlayer:SetBank(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        return xPlayer:SetWallet('bank', money)
    end

    function xPlayer:AddBank(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        if (money > 0) then
            return xPlayer:AddWallet('bank', money)
        end

        return self
    end

    function xPlayer:RemoveBank(money)
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        if (money > 0) then
            return xPlayer:RemoveWallet('bank', money)
        end

        return self
    end

    function xPlayer:GetWallet(name)
        name = ESR.Ensure(name, 'unknown')

        return ESR.Ensure(self.wallets, {})[name] or nil
    end

    function xPlayer:SetWallet(name, money)
        name = ESR.Ensure(name, 'unknown')
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet) then
            wallet.saldo = money
        end

        return self
    end

    function xPlayer:AddWallet(name, money)
        name = ESR.Ensure(name, 'unknown')
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet and money > 0) then
            wallet.saldo = wallet.saldo + money
        end

        return self
    end

    function xPlayer:RemoveWallet(name, money)
        name = ESR.Ensure(name, 'unknown')
        money = ESR.Ensure(money, 0)
        money = ESR.Math.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet and money > 0) then
            wallet.saldo = wallet.saldo - money
        end

        return self
    end

    function xPlayer:GetWallets(minimal)
        minimal = ESR.Ensure(minimal, false)

        if (minimal) then
            local accounts = {}

            for k, v in pairs(ESR.Ensure(self.wallets, {})) do
                local name = ESR.Ensure(v.name, 'unknown')
                local saldo = ESR.Ensure(v.saldo, 0)

                accounts[name] = saldo
            end

            return accounts
        end

        return ESR.Ensure(self.wallets, {})
    end

    function xPlayer:GetWeapons(storage)
        local weapons = {}

        if (ESR.TypeOf(storage) == 'nil') then
            for k, v in pairs(ESR.Ensure(ESR.Weapons, {})) do
                table.insert(weapons, ESR.Ensure(v, {}))
            end

            return weapons
        end

        local storageName = ESR.Ensure(storage, 'unknown')
        local storageId = ESR.Ensure(storage, 0)

        storageId = storageId > 0 and storageId or
            ESR.Ensure(ESR.Ensure((ESR.References or {}).Storages, {})[storageName], 0)

        if (storageId > 0) then
            for k, v in pairs(ESR.Ensure(ESR.Weapons, {})) do
                local xWeapon = ESR.Ensure(v, {})

                if (xWeapon.storageId == storageId) then
                    table.insert(weapons, xWeapon)
                end
            end

            return weapons
        end

        return weapons
    end

    if (ESR.Players == nil) then ESR.Players = ESR.Ensure(ESR.Players, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Players == nil) then ESR.References.Players = ESR.Ensure(ESR.References.Players, {}) end

    ESR.Players[xPlayer.id] = xPlayer
    ESR.References.Players[xPlayer.identifier] = xPlayer.id

    LoadPlayerDataAsync(xPlayer.id)

    return ESR.Players[xPlayer.id]
end

local function LoadPlayerDataAsync(pId)
    Citizen.CreateThread(function()
        local playerId = ESR.Ensure(pId, 0)
        local loaded = { wallets = false, inventory = false }
        local xPlayer = ESR.Ensure(ESR.Ensure(ESR.Players, {})[playerId], {})

        if (pId <= 0 or xPlayer == nil or xPlayer.loaded == true) then return end

        MySQL.Async.fetchAll('SELECT * FROM `player_wallets` WHERE `player_id` = @playerId', {
            ['playerId'] = playerId
        }, function(playerWallets)
            for k, v in pairs(ESR.Ensure(playerWallets, {})) do
                v = ESR.Ensure(v, {})

                local walletId = ESR.Ensure(v.wallet_id, 0)
                local wallet = ESR.Ensure(ESR.Ensure(ESR.Wallets, {})[walletId], {})
                local name = ESR.Ensure(wallet.name, 'unknown')
                local wallets = ESR.Ensure(Configuration.Wallets, {})
                local defaultSaldo = ESR.Ensure(wallets[name], 0)

                ---@class xPlayerWallet
                local xPlayerWallet = {
                    __class = 'xPlayerWallet',
                    __item = 'xPlayerWallet',
                    id = ESR.Ensure(wallet.id, 0),
                    playerId = playerId,
                    name = ESR.Ensure(wallet.name, 'unknown'),
                    label = ESR.Ensure(wallet.label, 'Unknown'),
                    saldo = ESR.Ensure(v.saldo, defaultSaldo)
                }

                function xPlayerWallet:Save(callback)
                    callback = ESR.Ensure(callback, function() end)

                    MySQL.Async.execute('UPDATE `player_wallets` SET `saldo` = @saldo WHERE `wallet_id` = @wallet AND `player_id` = @player', {
                        ['saldo'] = ESR.Ensure(self.saldo, 0),
                        ['wallet'] = ESR.Ensure(self.id, 0),
                        ['player'] = ESR.Ensure(self.playerId, 0)
                    }, function()
                        callback()
                    end)
                end

                if (ESR.Players[playerId].wallets == nil) then
                    ESR.Players[playerId].wallets = ESR.Ensure(ESR.Players[playerId].wallets, {})
                end

                ESR.Players[playerId].wallets[xPlayerWallet.name] = xPlayerWallet
            end

            loaded.wallets = true
        end)

        MySQL.Async.fetchAll('SELECT * FROM `inventory` WHERE `player_id` = @playerId', {
            ['playerId'] = playerId
        }, function(playerInventory)
            for k, v in pairs(ESR.Ensure(playerInventory, {})) do
                v = ESR.Ensure(v, {})

                local itemId = ESR.Ensure(v.item_id, 0)
                local item = ESR.Ensure(ESR.Ensure(ESR.Items, {})[itemId], {})

                ---@class xPlayerInventory
                local xPlayerInventory = {
                    __class = 'xPlayerInventory',
                    __item = 'xPlayerInventory',
                    id = ESR.Ensure(item.id, 0),
                    playerId = playerId,
                    name = ESR.Ensure(item.name, 'unknown'),
                    label = ESR.Ensure(item.label, 'unknown'),
                    weight = ESR.Ensure(item.weight, 0.25),
                    amount = ESR.Ensure(v.amount, 0)
                }

                function xPlayerInventory:Save(callback)
                    callback = ESR.Ensure(callback, function() end)

                    MySQL.Async.execute('UPDATE `inventory` SET `amount` = @amount WHERE `player_id` = @playerId AND `item_id` = @itemId', {
                        ['amount'] = ESR.Ensure(self.amount, 0),
                        ['playerId'] = ESR.Ensure(self.playerId, 0),
                        ['itemId'] = ESR.Ensure(self.id, 0)
                    }, function()
                        callback()
                    end)
                end

                if (ESR.Players[playerId].inventory == nil) then
                    ESR.Players[playerId].inventory = ESR.Ensure(ESR.Players[playerId].inventory, {})
                end

                ESR.Players[playerId].inventory[xPlayerInventory.name] = xPlayerInventory
            end

            loaded.inventory = true
        end)

        repeat Citizen.Wait(0) until
            loaded.wallets == true and
            loaded.inventory == true

        ESR.Players[playerId].loaded = true
    end)
end

--- Assign local as global variable
_G.CreatePlayerClass = CreatePlayerClass
_G.LoadPlayerDataAsync = LoadPlayerDataAsync