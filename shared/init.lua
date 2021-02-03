_G.Configuration = {}

_G.ESXR = {
    HudLoaded = false,
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
    JobPermissions = {},
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
    },
    PlayerData = {
        loaded = false
    }
}