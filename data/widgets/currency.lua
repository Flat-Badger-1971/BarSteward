local BS = _G.BarSteward

local function getcrownStoreCurrencies(invert)
    local crownStoreInfo = ""

    for currencyType, info in pairs(BS.CURRENCIES) do
        if (currencyType ~= _G.CURT_MONEY) then
            if ((invert and (not info.crownStore)) or ((not invert) and info.crownStore)) then
                if (crownStoreInfo ~= "") then
                    crownStoreInfo = crownStoreInfo .. BS.LF
                end

                local amount = GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType))
                local icon = info.icon

                if (not icon:find(".dds")) then
                    icon = "/esoui/art/currency/" .. icon .. ".dds"
                end

                crownStoreInfo = crownStoreInfo .. zo_iconFormat(icon, 16, 16) .. " "
                crownStoreInfo = crownStoreInfo .. "|cf9f9f9" .. BS.Format(info.text) .. " |r"
                crownStoreInfo = crownStoreInfo .. amount
            end
        end
    end

    return crownStoreInfo
end

local function updateTooltip(text, currencyInBag, currencyInBank, combined, charactertt, allCharacters, currencyType)
    local ttt = text.title .. BS.LF

    ttt = ttt .. "|cffd700" .. tostring(currencyInBag) .. "|r " .. GetString(text.bag) .. BS.LF
    ttt = ttt .. "|cffd700" .. tostring(currencyInBank) .. "|r " .. GetString(text.bank) .. BS.LF
    ttt = ttt .. "|cffd700" .. tostring(combined) .. "|r " .. GetString(text.combined) .. BS.LF .. BS.LF
    ttt = ttt .. charactertt .. BS.LF
    ttt = ttt .. "|cffd700" .. tostring(allCharacters) .. "|r " .. GetString(text.everyWhere)

    if (currencyType ~= _G.CURT_MONEY) then
        ttt = ttt .. BS.LF .. BS.LF .. getcrownStoreCurrencies(true)
    end

    return ttt
end

local function currencyWidget(currencyType, widgetIndex, text, eventList, hideWhenTrue)
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
            local currencyInBag = GetCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_CHARACTER)
            local currencyInBank = GetCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_BANK)
            local combined = currencyInBag + currencyInBank
            local allCharacters = combined
            local otherCharacterCurrency =
                ((currencyType == _G.CURT_MONEY) and BS.Vars.Gold or BS.Vars.OtherCurrencies[currencyType]) or {}
            local thisCharacter = GetUnitName("player")
            local charactertt = ""
            local useSeparators = BS.Vars.Controls[widgetIndex].UseSeparators

            for character, amount in pairs(otherCharacterCurrency) do
                if (character ~= thisCharacter) then
                    allCharacters = allCharacters + amount
                    charactertt =
                        string.format(
                        "%s|cffd700%s|r %s%s",
                        charactertt,
                        tostring(useSeparators and BS.AddSeparators(amount) or amount),
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

            if (BS.Vars.Controls[widgetIndex][ctype] == GetString(text.bank)) then
                toDisplay = currencyInBank
            elseif (BS.Vars.Controls[widgetIndex][ctype] == GetString(text.combined)) then
                toDisplay = combined
            elseif (BS.Vars.Controls[widgetIndex][ctype] == GetString(text.separated)) then
                toDisplay = separated
            elseif (BS.Vars.Controls[widgetIndex][ctype] == GetString(text.everyWhere)) then
                toDisplay = allCharacters
            end

            widget:SetValue(toDisplay)
            widget:SetColour(unpack(BS.Vars.Controls[widgetIndex].Colour or BS.Vars.DefaultColour))

            -- update the tooltip
            local ttt =
                updateTooltip(text, currencyInBag, currencyInBank, combined, charactertt, allCharacters, currencyType)
            widget.tooltip = ttt
            widget.tooltipFunc = function()
                updateTooltip(text, currencyInBag, currencyInBank, combined, charactertt, allCharacters, currencyType)
            end

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

BS.widgets[BS.W_ALLIANCE_POINTS] =
    currencyWidget(
    _G.CURT_ALLIANCE_POINTS,
    BS.W_ALLIANCE_POINTS,
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = BS.Format(_G.SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS)
    },
    {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ALLIANCE_POINT_UPDATE},
    function()
        if (BS.Vars.Controls[BS.W_ALLIANCE_POINTS].PvPOnly == true) then
            local mapContentType = GetMapContentType()
            local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

            return not isPvP
        end

        return false
    end
)

BS.widgets[BS.W_CROWN_GEMS] = {
    name = "crownGems",
    update = function(widget)
        local this = BS.W_CROWN_GEMS
        local gems = GetCurrencyAmount(_G.CURT_CROWN_GEMS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[this].UseSeparators == true) then
            gems = BS.AddSeparators(gems)
        end

        widget:SetValue(gems)
        widget:SetColour(unpack(BS.Vars.Controls[this].Colour or BS.Vars.DefaultColour))

        local tt = GetString(_G.BARSTEWARD_CROWN_GEMS) .. BS.LF

        tt = tt .. getcrownStoreCurrencies()

        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CROWN_UPDATE, _G.EVENT_CROWN_GEM_UPDATE},
    tooltip = GetString(_G.BARSTEWARD_CROWN_GEMS),
    icon = "/esoui/art/currency/currency_crown_gems.dds",
    onClick = function()
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
        widget:SetColour(unpack(BS.Vars.Controls[this].Colour or BS.Vars.DefaultColour))

        local tt = GetString(_G.BARSTEWARD_CROWNS) .. BS.LF

        tt = tt .. getcrownStoreCurrencies()

        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CROWN_UPDATE, _G.EVENT_CROWN_GEM_UPDATE},
    tooltip = GetString(_G.BARSTEWARD_CROWNS),
    icon = "/esoui/art/currency/currency_crowns_32.dds",
    onClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_EVENT_TICKETS] = {
    name = "eventTickets",
    update = function(widget)
        local this = BS.W_EVENT_TICKETS
        local vars = BS.Vars.Controls[this]
        local tickets = GetCurrencyAmount(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local maxTickets = GetMaxPossibleCurrency(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local noLimitColour = vars.NoLimitColour and "|cf9f9f9" or ""
        local noLimitTerminator = vars.NoLimitColour and "|r" or ""
        local value =
            tickets .. (vars.HideLimit and "" or (noLimitColour .. "/" .. tostring(maxTickets) .. noLimitTerminator))
        local widthValue = tickets .. (vars.HideLimit and "" or ("/" .. tostring(maxTickets)))
        local pc = BS.ToPercent(tickets, maxTickets)

        if (vars.ShowPercent) then
            value = pc .. "%"
        end

        local colour = vars.Colour or BS.Vars.DefaultColour

        if (tickets > vars.DangerValue) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour

            if (vars.Announce) then
                local announce = true
                local previousTime = BS.Vars.PreviousAnnounceTime[this] or (os.time() - 100)
                local debounceTime = (vars.DebounceTime or 5) * 60

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                -- if the number of tickets has changed then override the debounce
                if ((BS.previousEventTicketValue or 0) ~= tickets) then
                    announce = true
                    BS.previousEventTicketValue = tickets
                end

                if (announce) then
                    BS.Vars.PreviousAnnounceTime[this] = os.time()
                    BS.Announce(GetString(_G.BARSTEWARD_WARNING), GetString(_G.BARSTEWARD_WARNING_EVENT_TICKETS), this)
                end
            end
        end

        if (vars.MaxValue) then
            if (tickets == maxTickets) then
                colour = vars.MaxColour or BS.Vars.DefaultMaxColour
            end
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(value, widthValue)

        local tt = getcrownStoreCurrencies(true)

        widget.tooltip = tt

        return value
    end,
    event = _G.EVENT_CURRENCY_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_EVENT_TICKETS),
    icon = "/esoui/art/currency/currency_eventticket.dds",
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
    currencyWidget(
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

        if (BS.Vars.Controls[this].UseSeparators == true) then
            seals = BS.AddSeparators(seals)
        end

        widget:SetValue(seals)
        widget:SetColour(unpack(BS.Vars.Controls[this].Colour or BS.Vars.DefaultColour))

        local tt = BS.Format(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL) .. BS.LF

        tt = tt .. getcrownStoreCurrencies()

        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, _G.EVENT_CURRENCY_UPDATE},
    tooltip = BS.Format(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL),
    icon = "/esoui/art/currency/currency_seals_of_endeavor_64.dds",
    onClick = function()
        SCENE_MANAGER:Show("show_market")
        ZO_ShowSealStore()
    end
}

BS.widgets[BS.W_TELVAR_STONES] =
    currencyWidget(
    _G.CURT_TELVAR_STONES,
    BS.W_TELVAR_STONES,
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = BS.Format(_G.SI_GAMEPAD_INVENTORY_TELVAR_STONES)
    },
    _G.EVENT_TELVAR_STONE_UPDATE,
    function()
        if (BS.Vars.Controls[BS.W_TELVAR_STONES].PvPOnly == true) then
            local mapContentType = GetMapContentType()
            local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

            return not isPvP
        end

        return false
    end
)

BS.widgets[BS.W_TRANSMUTE_CRYSTALS] = {
    name = "transmuteCrystals",
    update = function(widget)
        local vars = BS.Vars.Controls[BS.W_TRANSMUTE_CRYSTALS]
        local crystals = GetCurrencyAmount(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
        local maxCrystals = GetMaxPossibleCurrency(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
        local value = crystals .. (vars.HideLimit and "" or ("/" .. tostring(maxCrystals)))
        local pc = BS.ToPercent(crystals, 1000)
        local colour = vars.Colour or BS.Vars.DefaultColour

        if (vars.Invert) then
            if ((vars.WarningValue or 0) > 0) then
                if (crystals >= vars.WarningValue) then
                    colour = vars.WarningColour or BS.Vars.DefaultWarningColour
                end
            end
            if ((vars.DangerValue or 0) > 0) then
                if (crystals >= vars.DangerValue) then
                    colour = vars.DangerColour or BS.Vars.DefaultDangerColour
                end
            end
        else
            if ((vars.WarningValue or 0) > 0) then
                if (crystals <= vars.WarningValue) then
                    colour = vars.WarningColour or BS.Vars.DefaultWarningColour
                end
            end
            if ((vars.DangerValue or 0) > 0) then
                if (crystals <= vars.DangerValue) then
                    colour = vars.DangerColour or BS.Vars.DefaultDangerColour
                end
            end
        end

        if (vars.MaxValue) then
            if (crystals == maxCrystals) then
                colour = vars.MaxColour or BS.Vars.DefaultMaxColour
            end
        end

        if (vars.ShowPercent) then
            value = pc .. "%"
        end

        widget:SetValue(value)
        widget:SetColour(unpack(colour))

        local tt = getcrownStoreCurrencies(true)

        widget.tooltip = tt

        return value
    end,
    event = {_G.EVENT_CURRENCY_UPDATE, _G.EVENT_QUEST_COMPLETE_DIALOG},
    tooltip = GetString(_G.BARSTEWARD_TRANSMUTE_CRYSTALS),
    icon = "/esoui/art/currency/currency_seedcrystal_64.dds"
}

BS.widgets[BS.W_UNDAUNTED_KEYS] = {
    name = "undauntedKeys",
    update = function(widget)
        widget:SetValue(GetCurrencyAmount(_G.CURT_UNDAUNTED_KEYS, _G.CURRENCY_LOCATION_ACCOUNT))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_UNDAUNTED_KEYS].Colour or BS.Vars.DefaultColour))

        local tt = getcrownStoreCurrencies(true)

        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_CURRENCY_UPDATE, _G.EVENT_QUEST_COMPLETE_DIALOG},
    tooltip = GetString(_G.BARSTEWARD_UNDAUNTED_KEYS),
    icon = "/esoui/art/icons/quest_key_002.dds"
}

BS.widgets[BS.W_WRIT_VOUCHERS] =
    currencyWidget(
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

BS.widgets[BS.W_ARCHIVAL_FRAGMENTS] =
    currencyWidget(
    _G.CURT_ENDLESS_DUNGEON,
    BS.W_ARCHIVAL_FRAGMENTS,
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_ARCHIVAL_FRAGMENTS,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = BS.Format(_G.BARSTEWARD_ARCHIVAL_FRAGMENTS)
    }
)
