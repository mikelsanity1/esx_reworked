_G.Configuration = {}

---@class ESX_REWORKED
_G.ESXR = {
    IsServer = IsDuplicityVersion(),
    Players = {},
    Jobs = {},
    Wallets = {},
    Weapons = {},
    Items = {},
    Storages = {},
    Cache = {},
    Groups = {},
    Permissions = {},
    Commands = {},
    RateLimits = {},
    References = {
        Players = {},
        Jobs = {},
        Wallets = {},
        Weapons = {},
        Items = {},
        Storages = {}
    },
    IsLoaded = false,
    Clock = {
        LastTime = nil,
        CurrentTick = 0
    }
}