_G.Configuration = {}

---@class ESX_REWORKED
---@field Players table<number, xPlayer>
---@field Jobs table<number, xJob>
---@field Wallets table<number, xWallet>
---@field Weapons table<number, xWeapon>
---@field Items table<number, xItem>
---@field Storages table<number, xStorage>
---@field Cache table<any, any>
---@field Groups table<string, group>
---@field JobPermissions table<string, job>
---@field Commands table<string, command>
_G.ESXR = {
    IsServer = IsDuplicityVersion(),
    ---@type table<number, xPlayer>
    Players = {},
    ---@type table<number, xJob>
    Jobs = {},
    ---@type table<number, xWallet>
    Wallets = {},
    ---@type table<number, xWeapon>
    Weapons = {},
    ---@type table<number, xItem>
    Items = {},
    ---@type table<number, xStorage>
    Storages = {},
    ---@type table<any, any>
    Cache = {},
    ---@type table<string, group>
    Groups = {},
    Permissions = {},
    ---@type table<string, job>
    JobPermissions = {},
    ---@type table<string, command>
    Commands = {},
    RateLimits = {},
    References = {
        Players = {},
        Jobs = {},
        Wallets = {},
        Weapons = {},
        Items = {},
        Storages = {},
        SourceToIds = {},
        SourceToIdentifier = {}
    },
    IsLoaded = false,
    Clock = {
        LastTime = nil,
        CurrentTick = 0
    }
}