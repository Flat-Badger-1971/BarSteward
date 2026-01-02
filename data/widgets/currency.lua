local BS = BarSteward

local function getcrownStoreCurrencies(invert, widgetIndex)
    local crownStoreInfo = ""
    local useSeparators = BS.GetVar("UseSeparators", widgetIndex)

    for currencyType, info in pairs(BS.CURRENCIES) do
        if (currencyType ~= CURT_MONEY) then
            if ((invert and (not info.crownStore)) or ((not invert) and info.crownStore)) then
                if (crownStoreInfo ~= "") then
                    crownStoreInfo = crownStoreInfo .. BS.LF
                end

                local amount = tostring(GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType)))
                local icon = GetCurrencyKeyboardIcon(currencyType)
                local name = BS.LC.Format(GetCurrencyName(currencyType, true, true))

                amount = tostring(useSeparators and BS.AddSeparators(amount) or amount)
                crownStoreInfo = crownStoreInfo .. BS.Icon(icon) .. " "
                crownStoreInfo = crownStoreInfo .. BS.COLOURS.White:Colorize(name)
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
    local ttt = BS.LC.Format(GetCurrencyName(currencyType, true, true)) .. BS.LF
    local gold = BS.COLOURS.ZOSGold

    ttt = ttt .. gold:Colorize(tostring(currencyInBag)) .. " " .. GetString(text.bag) .. BS.LF
    ttt = ttt .. gold:Colorize(tostring(currencyInBank)) .. " " .. GetString(text.bank) .. BS.LF
    ttt = ttt .. gold:Colorize(tostring(combined)) .. " " .. GetString(text.combined) .. BS.LF .. BS.LF
    ttt = ttt .. charactertt
    ttt = ttt .. gold:Colorize(tostring(allCharacters)) .. " " .. GetString(text.everyWhere)

    if (currencyType ~= CURT_MONEY) then
        ttt = ttt .. BS.LF .. BS.LF .. getcrownStoreCurrencies(true, widgetIndex)
    end

    return ttt
end

function BS.CurrencyWidget(currencyType, widgetIndex, text, eventList, hideWhenTrue)
    local name = "gold"

    if (currencyType == CURT_ALLIANCE_POINTS) then
        name = "alliancePoints"
    elseif (currencyType == CURT_TELVAR_STONES) then
        name = "telvarStones"
    elseif (currencyType == CURT_WRIT_VOUCHERS) then
        name = "writVouchers"
    elseif (currencyType == CURT_IMPERIAL_FRAGMENTS) then
        name = "imperialFragments"
    end

    local ctype = (currencyType == CURT_MONEY) and "GoldType" or "CurrencyType"
    local icon = GetCurrencyKeyboardIcon(currencyType)
    local widgetCode = {
        name = name,
        update = function(widget)
            local currencyInBag = GetCurrencyAmount(currencyType, GetCurrencyPlayerStoredLocation(currencyType))
            local currencyInBank = GetBankedCurrencyAmount(currencyType)
            local combined = currencyInBag + currencyInBank
            local allCharacters = combined
            local otherCharacterCurrency =
                ((currencyType == CURT_MONEY) and BS.Vars:GetCommon("Gold") or
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
        tooltip = BS.LC.Format(GetCurrencyName(currencyType, true, true), true, true),
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
        local gems = GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)

        if (BS.GetVar("UseSeparators", this) == true) then
            gems = BS.AddSeparators(gems)
        end

        widget:SetValue(gems)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.LC.Format(GetCurrencyName(CURT_CROWN_GEMS, true, true)) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = { EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, EVENT_CROWN_UPDATE, EVENT_CROWN_GEM_UPDATE },
    tooltip = function()
        return BS.LC.Format(GetCurrencyName(CURT_CROWN_GEMS, true, true))
    end,
    icon = GetCurrencyKeyboardIcon(CURT_CROWN_GEMS),
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_CROWNS] = {
    name = "crowns",
    update = function(widget)
        local this = BS.W_CROWNS
        local crowns = GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[this].UseSeparators == true) then
            crowns = BS.AddSeparators(crowns)
        end

        widget:SetValue(crowns)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.LC.Format(GetCurrencyName(CURT_CROWNS, true, true)) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = { EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, EVENT_CROWN_UPDATE, EVENT_CROWN_GEM_UPDATE },
    tooltip = function()
        return BS.LC.Format(GetCurrencyName(CURT_CROWNS, true, true))
    end,
    icon = GetCurrencyKeyboardIcon(CURT_CROWNS),
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_EVENT_TICKETS] = {
    name = "eventTickets",
    update = function(widget)
        local this = BS.W_EVENT_TICKETS
        local tickets = GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
        local maxTickets = GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Yellow
        local value =
            tickets .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. tostring(maxTickets))))
        local widthValue = tickets .. (BS.GetVar("HideLimit", this) and "" or ("/" .. tostring(maxTickets)))
        local pc = BS.LC.ToPercent(tickets, maxTickets)

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
                    BS.Announce(GetString(BARSTEWARD_WARNING), GetString(BARSTEWARD_WARNING_EVENT_TICKETS), this)
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

        local tt = BS.LC.Format(GetCurrencyName(CURT_EVENT_TICKETS, true, true)) ..
            BS.LF .. getcrownStoreCurrencies(true, this)

        widget:SetTooltip(tt)

        return value
    end,
    event = EVENT_CURRENCY_UPDATE,
    tooltip = function()
        return BS.LC.Format(GetCurrencyName(CURT_EVENT_TICKETS, true, true))
    end,
    icon = GetCurrencyKeyboardIcon(CURT_EVENT_TICKETS),
    customOptions = {
        name = GetString(BARSTEWARD_DEBOUNCE),
        tooltip = GetString(BARSTEWARD_DEBOUNCE_DESC),
        choices = { 0, 1, 5, 10, 15, 20, 30, 40, 50, 60 },
        varName = "DebounceTime",
        refresh = false,
        default = 5
    }
}

BS.widgets[BS.W_GOLD] =
    BS.CurrencyWidget(
        CURT_MONEY,
        BS.W_GOLD,
        {
            bag = BARSTEWARD_GOLD_BAG,
            bank = BARSTEWARD_GOLD_BANK,
            combined = BARSTEWARD_GOLD_COMBINED,
            display = BARSTEWARD_GOLD_DISPLAY,
            everyWhere = BARSTEWARD_GOLD_EVERYWHERE,
            separated = BARSTEWARD_GOLD_SEPARATED
        },
        EVENT_MONEY_UPDATE
    )

BS.widgets[BS.W_SEALS_OF_ENDEAVOUR] = {
    name = "sealsOfEndeavour",
    update = function(widget)
        local this = BS.W_SEALS_OF_ENDEAVOUR
        local seals = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)

        if (BS.GetVar("UseSeparators", this) == true) then
            seals = BS.AddSeparators(seals)
        end

        widget:SetValue(seals)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.LC.Format(GetCurrencyName(CURT_ENDEAVOR_SEALS, true, true)) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = { EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, EVENT_CURRENCY_UPDATE },
    tooltip = BS.LC.Format(GetCurrencyName(CURT_ENDEAVOR_SEALS, true, true)),
    icon = GetCurrencyKeyboardIcon(CURT_ENDEAVOR_SEALS),
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
        ZO_ShowSealStore()
    end
}

BS.widgets[BS.W_TRANSMUTE_CRYSTALS] = {
    name = "transmuteCrystals",
    update = function(widget)
        local this = BS.W_TRANSMUTE_CRYSTALS
        local crystals = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
        local maxCrystals = GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
        local value = crystals .. (BS.GetVar("HideLimit", this) and "" or ("/" .. tostring(maxCrystals)))
        local pc = BS.LC.ToPercent(crystals, 1000)
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

        local tt = BS.LC.Format(GetCurrencyName(CURT_CHAOTIC_CREATIA, true, true)) ..
            BS.LF .. getcrownStoreCurrencies(true, this)

        widget:SetTooltip(tt)

        return value
    end,
    event = { EVENT_CURRENCY_UPDATE, EVENT_QUEST_COMPLETE_DIALOG },
    tooltip = BS.LC.Format(GetCurrencyName(CURT_CHAOTIC_CREATIA, true, true)),
    icon = "currency/currency_seedcrystals_multi_mipmap"
}

BS.widgets[BS.W_UNDAUNTED_KEYS] = {
    name = "undauntedKeys",
    update = function(widget)
        widget:SetValue(GetCurrencyAmount(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT))
        widget:SetColour(BS.GetColour(BS.W_UNDAUNTED_KEYS, true))

        local tt =
            BS.LC.Format(GetCurrencyName(CURT_UNDAUNTED_KEYS, true, true)) ..
            BS.LF .. getcrownStoreCurrencies(true, BS.W_UNDAUNTED_KEYS)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = { EVENT_CURRENCY_UPDATE, EVENT_QUEST_COMPLETE_DIALOG },
    tooltip = BS.LC.Format(GetCurrencyName(CURT_UNDAUNTED_KEYS, true, true)),
    icon = GetCurrencyKeyboardIcon(CURT_UNDAUNTED_KEYS)
}

BS.widgets[BS.W_WRIT_VOUCHERS] =
    BS.CurrencyWidget(
        CURT_WRIT_VOUCHERS,
        BS.W_WRIT_VOUCHERS,
        {
            bag = BARSTEWARD_GOLD_BAG,
            bank = BARSTEWARD_GOLD_BANK,
            combined = BARSTEWARD_GOLD_COMBINED,
            display = BARSTEWARD_GOLD_DISPLAY,
            everyWhere = BARSTEWARD_GOLD_EVERYWHERE,
            separated = BARSTEWARD_GOLD_SEPARATED
        },
        EVENT_WRIT_VOUCHER_UPDATE
    )

BS.widgets[BS.W_ARCHIVAL_FRAGMENTS] = {
    name = "archivalFragments",
    update = function(widget)
        local this = BS.W_ARCHIVAL_FRAGMENTS
        local qty =
            GetCurrencyAmount(
                (CURT_ENDLESS_DUNGEON or CURT_ARCHIVAL_FORTUNES),
                GetCurrencyPlayerStoredLocation(CURT_ENDLESS_DUNGEON or CURT_ARCHIVAL_FORTUNES)
            )

        if (BS.Vars.Controls[this].UseSeparators == true) then
            qty = BS.AddSeparators(qty)
        end

        widget:SetValue(qty)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.LC.Format(GetCurrencyName(CURT_ARCHIVAL_FORTUNES, true, true)) .. BS.LF

        tt = tt .. getcrownStoreCurrencies(false, this)

        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = EVENT_CURRENCY_UPDATE,
    tooltip = BS.LC.Format(GetCurrencyName(CURT_ARCHIVAL_FORTUNES, true, true)),
    icon = GetCurrencyKeyboardIcon(CURT_ARCHIVAL_FORTUNES),
    onLeftClick = function()
        SCENE_MANAGER:Show("show_market")
    end
}

BS.widgets[BS.W_IMPERIAL_FRAGMENTS] = {
    name = "imperialFragments",
    update = function(widget, event, ...)
        local update = event == "initial"

        if (event ~= "initial") then
            local lootType = select(6, ...)

            if (lootType == LOOT_TYPE_IMPERIAL_FRAGMENTS) then
                update = true
            end
        end

        if (update) then
            widget:SetValue(GetCurrencyAmount(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT))
            widget:SetColour(BS.GetColour(BS.W_IMPERIAL_FRAGMENTS, true))

            local tt =
                BS.LC.Format(GetCurrencyName(CURT_IMPERIAL_FRAGMENTS, true, true)) ..
                BS.LF .. getcrownStoreCurrencies(true, BS.W_IMPERIAL_FRAGMENTS)

            widget:SetTooltip(tt)

            return widget:GetValue()
        end
    end,
    event = EVENT_LOOT_RECEIVED,
    tooltip = BS.LC.Format(GetCurrencyName(CURT_IMPERIAL_FRAGMENTS, true, true)),
    icon = GetCurrencyKeyboardIcon(CURT_IMPERIAL_FRAGMENTS)
}
