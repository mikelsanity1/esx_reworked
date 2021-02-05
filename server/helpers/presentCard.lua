local function GenerateCard(title, description, banner)
    local config = ESXR.Ensure(Configuration, {})
    local cfgBanner = ESXR.Ensure(config.BannerURL, 'https://i.imgur.com/JHJt60T.png')
    local serverName = ESXR.Ensure(config.ServerName, 'ESX Reworked Framework')

    local _tit = _('connecting_title', serverName)
    local _desc = _('connecting_description', serverName)

    title = ESXR.Ensure(title, _tit)
    description = ESXR.Ensure(description, _desc)
    banner = ESXR.Ensure(banner, cfgBanner)

    local card = {
        ['type'] = 'AdaptiveCard',
        ['body'] = {
            { type = "Image", url = banner },
            { type = "TextBlock", size = "Medium", weight = "Bolder", text = title, horizontalAlignment = "Center" },
            { type = "TextBlock", text = description, wrap = true, horizontalAlignment = "Center" }
        },
        ['$schema'] = "http://adaptivecards.io/schemas/adaptive-card.json",
        ['version'] = "1.3"
    }

    return ESXR.Encode(card)
end

local function CreateNewPresentCard(deferrals)
    local presentCard = setmetatable({
        title = nil,
        description = nil,
        banner = nil,
        deferrals = deferrals
    }, {})

    function presentCard:update()
        local cardJson = GenerateCard(self.title, self.description, self.banner)

        self.deferrals.presentCard(cardJson)
    end

    function presentCard:setTitle(title, update)
        title = ESXR.Ensure(title, 'unknown')
        update = ESXR.Ensure(update, true)

        if (title == 'unknown') then title = nil end

        self.title = title

        if (update) then self:update() end
    end

    function presentCard:setDescription(description, update)
        description = ESXR.Ensure(description, 'unknown')
        update = ESXR.Ensure(update, true)

        if (description == 'unknown') then description = nil end

        self.description = description

        if (update) then self:update() end
    end

    function presentCard:setBanner(banner, update)
        banner = ESXR.Ensure(banner, 'unknown')
        update = ESXR.Ensure(update, true)

        if (banner == 'unknown') then banner = nil end

        self.banner = banner

        if (update) then self:update() end
    end

    function presentCard:reset(update)
        update = ESXR.Ensure(update, true)

        self.title = nil
        self.description = nil
        self.banner = nil

        if (update) then self:update() end
    end

    function presentCard:override(card, ...)
        self.deferrals.presentCard(card, ...)
    end

    presentCard:update()

    return presentCard
end

_G.GenerateCard = GenerateCard
_G.CreateNewPresentCard = CreateNewPresentCard