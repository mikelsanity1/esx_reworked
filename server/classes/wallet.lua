local function CreateWalletClass(walletInfo)
    walletInfo = ESXR.Ensure(walletInfo, {})

    local wallets = ESXR.Ensure(ESXR.GetConfig().Wallets, {})
    local name = ESXR.Ensure(walletInfo.name, 'unknown')

    local xWallet = {
        id = ESXR.Ensure(walletInfo.id, 0),
        name = name,
        label = ESXR.Ensure(walletInfo.label, 'Unknown'),
        default = ESXR.Ensure(wallets[name], 0)
    }

    if (ESXR.Wallets ~= nil and ESXR.Wallets[xWallet.id] ~= nil) then
        return ESXR.Ensure(ESXR.Wallets[xWallet.id], {})
    end

    if (xWallet.id <= 0) then
        error('xWallet must have an valid `id` and must exsist in `wallets` table')
        return
    end

    if (ESXR.Wallets == nil) then ESXR.Wallets = ESXR.Ensure(ESXR.Wallets, {}) end
    if (ESXR.References == nil) then ESXR.References = ESXR.Ensure(ESXR.References, {}) end
    if (ESXR.References.Wallets == nil) then ESXR.References.Wallets = ESXR.Ensure(ESXR.References.Wallets, {}) end

    ESXR.Wallets[xWallet.id] = xWallet
    ESXR.References.Wallets[xWallet.name] = xWallet.id

    return ESXR.Wallets[xWallet.id]
end

_G.CreateWalletClass = CreateWalletClass