local function CreateWalletClass(walletInfo)
    walletInfo = ESR.Ensure(walletInfo, {})

    ---@class xWallet
    local xWallet = {
        __class = 'xWallet',
        __type = 'xWallet',
        id = ESR.Ensure(walletInfo.id, 0),
        name = ESR.Ensure(walletInfo.name, 'unknown'),
        label = ESR.Ensure(walletInfo.label, 'Unknown')
    }

    if (ESR.Wallets ~= nil and ESR.Wallets[xWallet.id] ~= nil) then
        return ESR.Ensure(ESR.Wallets[xWallet.id], {})
    end

    if (xWallet.id <= 0) then
        error('xWallet must have an valid `id` and must exsist in `wallets` table')
        return
    end

    if (ESR.Wallets == nil) then ESR.Wallets = ESR.Ensure(ESR.Wallets, {}) end
    if (ESR.References == nil) then ESR.References = ESR.Ensure(ESR.References, {}) end
    if (ESR.References.Wallets == nil) then ESR.References.Wallets = ESR.Ensure(ESR.References.Wallets, {}) end

    ESR.Wallets[xWallet.id] = xWallet
    ESR.References.Wallets[xWallet.name] = xWallet.id

    return ESR.Wallets[xWallet.id]
end

--- Assign local as global variable
_G.CreateWalletClass = CreateWalletClass