local BS = _G.BarSteward

local function getcrownStoreCurrencies(invert, widgetIndex)
    local crownStoreInfo = ""
    local useSeparators = BS.GetVar("UseSeparators", widgetIndex)

    for currencyType, info in pairs(BS.CURRENCIES) do
        if (currencyType ~= _G.CURT_MONEY) then
            if ((invert and (not info.crownStore)) or ((not invert) and info.crownStore)) then
                if (crownStoreInfo ~= "") then
                    crownStoreInfo = crownStoreInfo .. BS.LF
                end

                local amount = GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType))
                local icon = info.icon

                amount = tostring(useSeparators and BS.AddSeparators(amount) or amount)

                if (not icon:find(".dds")) then
                    icon = "/esoui/art/currency/" .. icon .. ".dds"
                end

                crownStoreInfo = crownStoreInfo .. BS.Icon(icon) .. " "
                crownStoreInfo = crownStoreInfo .. BS.COLOURS.White:Colorize(BS.Format(info.text))
                crownStoreInfo = crownStoreInfo .. " " .. amount
            end
        end
    end

    return crownStoreInfo
end

local function updateTooltip(
    text,
    currencyInBag,
    currencyInBank,
    combined,
    charactertt,
    allCharacters,
    currencyType,
    widgetIndex)
    local ttt = text.title .. BS.LF
    local gold = BS.COLOURS.ZOSGold

    ttt = ttt .. gold:Colorize(tostring(currencyInBag)) .. " " .. GetString(text.bag) .. BS.LF
    ttt = ttt .. gold:Colorize(tostring(currencyInBank)) .. " " .. GetString(text.bank) .. BS.LF
    ttt = ttt .. gold:Colorize(tostring(combined)) .. " " .. GetString(text.combined) .. BS.LF .. BS.LF
    ttt = ttt .. charactertt .. BS.LF
    ttt = ttt .. gold:Colorize(tostring(allCharacters)) .. " " .. GetString(text.everyWhere)

    if (currencyType ~= _G.CURT_MONEY) then
        ttt = ttt .. BS.LF .. BS.LF .. getcrownStoreCurrencies(true, widgetIndex)
    end

    return ttt
end

function BS.CurrencyWidget(currencyType, widgetIndex, text, eventList, hideWhenTrue)
    local name = "gold"

    if (currencyType == _G.CURT_ALLIANCE_POINTS) then
        name = "alliancePoints"
    elseif (currencyType == _G.CURT_TELVAR_STONES) then
        name = "telvarStones"
    elseif (currencyType == _G.CURT_WRIT_VOUCHERS) then
        name = "writVouchers"
    end

    local ctype = (currencyType == _G.CURT_MONEY) and "GoldType" or "CurrencyType"
    local icon = BS.CURRENCIES[currencyType].icon

    if (not icon:find(".dds")) then
        icon = "/esoui/art/currency/" .. icon .. ".dds"
    end

    local widgetCode = {
        name = name,
        update = function(widget)
            local currencyInBag = GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType))
            local currencyInBank = GetBankedCurrencyAmount(currencyType)
            local combined = currencyInBag + currencyInBank
            local allCharacters = combined
            local otherCharacterCurrency =
                ((currencyType == _G.CURT_MONEY) and BS.Vars:GetCommon("Gold") or
                BS.Vars:GetCommon("OtherCurrencies", currencyType)) or
                {}
            local thisCharacter = BS.CHAR.name
            local charactertt = ""
            local useSeparators = BS.GetVar("UseSeparators", widgetIndex)

            for character, amount in pairs(otherCharacterCurrency) do
                if (character ~= thisCharacter) then
                    allCharacters = allCharacters + amount
                    local num = tostring(useSeparators and BS.AddSeparators(amount) or amount)

                    charactertt =
                        string.format(
                        "%s%s %s%s",
                        charactertt,
                        BS.COLOURS.ZOSGold:Colorize(num),
                        ZO_FormatUserFacingDisplayName(character),
                        BS.LF
                    )
                end
            end

            if (useSeparators) then
                currencyInBag = BS.AddSeparators(currencyInBag)
                currencyInBank = BS.AddSeparators(currencyInBank)
                combined = BS.AddSeparators(combined)
                allCharacters = BS.AddSeparators(allCharacters)
            end

            local toDisplay = currencyInBag
            local separated = currencyInBag .. "/" .. currencyInBank
            local vcType = BS.GetVar(ctype, widgetIndex)

            if (vcType == GetString(text.bank)) then
                toDisplay = currencyInBank
            elseif (vcType == GetString(text.combined)) then
                toDisplay = combined
            elseif (vcType == GetString(text.separated)) then
                toDisplay = separated
            elseif (vcType == GetString(text.everyWhere)) then
                toDisplay = allCharacters
            end

            widget:SetValue(toDisplay)
            widget:SetColour(BS.GetColour(widgetIndex, true))

            -- update the tooltip
            local ttt =
                updateTooltip(
                text,
                currencyInBag,
                currencyInBank,
                combined,
                charactertt,
                allCharacters,
                currencyType,
                widgetIndex
            )

            widget:SetTooltip(ttt)

            return widget:GetValue()
        end,
        event = eventList,
        tooltip = text.title,
        icon = icon,
        customOptions = {
            name = GetString(text.display),
            choices = {
                GetString(text.bag),
                GetString(text.bank),
                GetString(text.combined),
                GetString(text.separated),
                GetString(text.everyWhere)
            },
            varName = ctype,
            refresh = true,
            default = GetString(text.bag)
        }
    }

    if (hideWhenTrue) then
        widgetCode.hideWhenTrue = hideWhenTrue
    end

    return widgetCode
end

BS.widgets[BS.W_CROWN_GEMS] = {
    name = "crownGems",
    update = function(widget)
        local this = BS.W_CROWN_GEMS
        local gems = GetCurrencyAmount(_G.CURT_CROWN_GEMS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.GetVar("UseSeparators", this) == true) then
            gems = BS.AddSeparators(gems)
        end

        widget:SetValue(gems)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_CROWN_GEMS) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CROWN_UPDATE, _G.EVENT_CROWN_GEM_UPDATE},
    tooltip = GetString(_G.BARSTEWARD_CROWN_GEMS),
    icon = "currency/currency_crown_gems",
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_CROWNS] = {
    name = "crowns",
    update = function(widget)
        local this = BS.W_CROWNS
        local crowns = GetCurrencyAmount(_G.CURT_CROWNS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[this].UseSeparators == true) then
            crowns = BS.AddSeparators(crowns)
        end

        widget:SetValue(crowns)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_CROWNS) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CROWN_UPDATE, _G.EVENT_CROWN_GEM_UPDATE},
    tooltip = GetString(_G.BARSTEWARD_CROWNS),
    icon = "currency/currency_crowns_32",
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_EVENT_TICKETS] = {
    name = "eventTickets",
    update = function(widget)
        local this = BS.W_EVENT_TICKETS
        local tickets = GetCurrencyAmount(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local maxTickets = GetMaxPossibleCurrency(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Yellow
        local value =
            tickets .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. tostring(maxTickets))))
        local widthValue = tickets .. (BS.GetVar("HideLimit", this) and "" or ("/" .. tostring(maxTickets)))
        local pc = BS.ToPercent(tickets, maxTickets)

        if (BS.GetVar("ShowPercent", this)) then
            value = pc .. "%"
        end

        local colour = BS.GetColour(this, true)

        if (tickets > BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)

            if (BS.GetVar("Announce", this)) then
                local announce = true
                local previousTime = BS.Vars:GetCommon("PreviousAnnounceTime", this) or (os.time() - 100)
                local debounceTime = (BS.GetVar("DebounceTime", this) or 5) * 60

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                -- if the number of tickets has changed then override the debounce
                if ((BS.previousEventTicketValue or 0) ~= tickets) then
                    announce = true
                    BS.previousEventTicketValue = tickets
                end

                if (announce) then
                    BS.Vars:SetCommon(os.time(), "PreviousAnnounceTime", this)
                    BS.Announce(GetString(_G.BARSTEWARD_WARNING), GetString(_G.BARSTEWARD_WARNING_EVENT_TICKETS), this)
                end
            end
        end

        if (BS.GetVar("MaxValue", this)) then
            if (tickets == maxTickets) then
                colour = BS.GetColour(this, "Max", true)
            end
        end

        widget:SetColour(colour)
        widget:SetValue(value, widthValue)

        local tt = getcrownStoreCurrencies(true, this)

        widget:SetTooltip(tt)

        return value
    end,
    event = _G.EVENT_CURRENCY_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_EVENT_TICKETS),
    icon = "currency/currency_eventticket",
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {0, 1, 5, 10, 15, 20, 30, 40, 50, 60},
        varName = "DebounceTime",
        refresh = false,
        default = 5
    }
}

BS.widgets[BS.W_GOLD] =
    BS.CurrencyWidget(
    _G.CURT_MONEY,
    BS.W_GOLD,
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = BS.Format(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS)
    },
    _G.EVENT_MONEY_UPDATE
)

BS.widgets[BS.W_SEALS_OF_ENDEAVOUR] = {
    name = "sealsOfEndeavour",
    update = function(widget)
        local this = BS.W_SEALS_OF_ENDEAVOUR
        local seals = GetCurrencyAmount(_G.CURT_ENDEAVOR_SEALS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.GetVar("UseSeparators", this) == true) then
            seals = BS.AddSeparators(seals)
        end

        widget:SetValue(seals)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.Format(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CURRENCY_UPDATE},
    tooltip = BS.Format(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL),
    icon = "currency/currency_seals_of_endeavor_64",
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
        ZO_ShowSealStore()
    end
}

BS.widgets[BS.W_TRANSMUTE_CRYSTALS] = {
    name = "transmuteCrystals",
    update = function(widget)
        local this = BS.W_TRANSMUTE_CRYSTALS
        local crystals = GetCurrencyAmount(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
        local maxCrystals = GetMaxPossibleCurrency(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
        local value = crystals .. (BS.GetVar("HideLimit", this) and "" or ("/" .. tostring(maxCrystals)))
        local pc = BS.ToPercent(crystals, 1000)
        local colour = BS.GetColour(this, true)
        local warningValue, dangerValue = BS.GetVar("WarningValue", this), BS.GetVar("DangerValue", this)

        if (BS.GetVar("Invert", this)) then
            if ((warningValue or 0) > 0) then
                if (crystals >= warningValue) then
                    colour = BS.GetColour(this, "Warning", true)
                end
            end
            if ((dangerValue or 0) > 0) then
                if (crystals >= dangerValue) then
                    colour = BS.GetColour(this, "Danger", true)
                end
            end
        else
            if ((warningValue or 0) > 0) then
                if (crystals <= warningValue) then
                    colour = BS.GetColour(this, "Warning", true)
                end
            end
            if ((dangerValue or 0) > 0) then
                if (crystals <= dangerValue) then
                    colour = BS.GetColour(this, "Danger", true)
                end
            end
        end

        if (BS.GetVar("MaxValue", this)) then
            if (crystals == maxCrystals) then
                colour = BS.GetColour(this, "Max", true)
            end
        end

        if (BS.GetVar("ShowPercent", this)) then
            value = pc .. "%"
        end

        widget:SetValue(value)
        widget:SetColour(colour)

        local tt = getcrownStoreCurrencies(true, this)

        widget:SetTooltip(tt)

        return value
    end,
    event = {_G.EVENT_CURRENCY_UPDATE, _G.EVENT_QUEST_COMPLETE_DIALOG},
    tooltip = GetString(_G.BARSTEWARD_TRANSMUTE_CRYSTALS),
    icon = "currency/currency_seedcrystal_64"
}

BS.widgets[BS.W_UNDAUNTED_KEYS] = {
    name = "undauntedKeys",
    update = function(widget)
        widget:SetValue(GetCurrencyAmount(_G.CURT_UNDAUNTED_KEYS, _G.CURRENCY_LOCATION_ACCOUNT))
        widget:SetColour(BS.GetColour(BS.W_UNDAUNTED_KEYS, true))

        local tt = getcrownStoreCurrencies(true, BS.W_UNDAUNTED_KEYS)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = {_G.EVENT_CURRENCY_UPDATE, _G.EVENT_QUEST_COMPLETE_DIALOG},
    tooltip = GetString(_G.BARSTEWARD_UNDAUNTED_KEYS),
    icon = "icons/quest_key_002"
}

BS.widgets[BS.W_WRIT_VOUCHERS] =
    BS.CurrencyWidget(
    _G.CURT_WRIT_VOUCHERS,
    BS.W_WRIT_VOUCHERS,
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = GetString(_G.BARSTEWARD_WRIT_VOUCHERS)
    },
    _G.EVENT_WRIT_VOUCHER_UPDATE
)

BS.widgets[BS.W_ARCHIVAL_FRAGMENTS] = {
    name = "archivalFragments",
    update = function(widget)
        local this = BS.W_ARCHIVAL_FRAGMENTS
        local qty =
            GetCurrencyAmount(
            (_G.CURT_ENDLESS_DUNGEON or _G.CURT_ARCHIVAL_FORTUNES),
            GetCurrencyPlayerStoredLocation(_G.CURT_ENDLESS_DUNGEON or _G.CURT_ARCHIVAL_FORTUNES)
        )

        if (BS.Vars.Controls[this].UseSeparators == true) then
            qty = BS.AddSeparators(qty)
        end

        widget:SetValue(qty)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_ARCHIVAL_FRAGMENTS) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = _G.EVENT_CURRENCY_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_ARCHIVAL_FRAGMENTS),
    icon = "currency/archivalfragments_mipmaps",
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}
