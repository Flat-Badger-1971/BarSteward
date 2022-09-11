local BS = _G.BarSteward

local function currencyWidget(currencyType, widgetIndex, icon, text, eventList, hideWhenTrue)
    local name = "gold"

    if (currencyType == _G.CURT_ALLIANCE_POINTS) then
        name = "alliancePoints"
    elseif (currencyType == _G.CURT_TELVAR_STONES) then
        name = "telvarStones"
    elseif (currencyType == _G.CURT_WRIT_VOUCHERS) then
        name = "writVouchers"
    end

    local ctype = (currencyType == _G.CURT_MONEY) and "GoldType" or "CurrencyType"

    local widgetCode = {
        name = name,
        update = function(widget)
            local currencyInBag = GetCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_CHARACTER)
            local currencyInBank = GetCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_BANK)
            local combined = currencyInBag + currencyInBank
            local allCharacters = combined
            local otherCharacterCurrency =
                (currencyType == _G.CURT_MONEY) and BS.Vars.Gold or BS.Vars.OtherCurrencies[currencyType]
            local thisCharacter = GetUnitName("player")
            local charactertt = ""
            local useSeparators = BS.Vars.Controls[widgetIndex].UseSeparators

            for character, amount in pairs(otherCharacterCurrency) do
                if (character ~= thisCharacter) then
                    allCharacters = allCharacters + amount
                    charactertt =
                        charactertt ..
                        "|cffd700" ..
                            tostring(useSeparators and BS.AddSeparators(amount) or amount) ..
                                "|r " .. ZO_FormatUserFacingDisplayName(character) .. BS.LF
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
            local ttt = text.title .. BS.LF
            ttt = ttt .. "|cffd700" .. tostring(currencyInBag) .. "|r " .. GetString(text.bag) .. BS.LF
            ttt = ttt .. "|cffd700" .. tostring(currencyInBank) .. "|r " .. GetString(text.bank) .. BS.LF
            ttt = ttt .. "|cffd700" .. tostring(combined) .. "|r " .. GetString(text.combined) .. BS.LF .. BS.LF
            ttt = ttt .. charactertt .. BS.LF
            ttt = ttt .. "|cffd700" .. tostring(allCharacters) .. "|r " .. GetString(text.everyWhere)

            widget.tooltip = ttt

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
    "/esoui/art/currency/alliancepoints_64.dds",
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS))
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
        local gems = GetCurrencyAmount(_G.CURT_CROWN_GEMS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[BS.W_CROWN_GEMS].UseSeparators == true) then
            gems = BS.AddSeparators(gems)
        end

        widget:SetValue(gems)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_CROWN_GEMS].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_CROWN_GEM_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_CROWN_GEMS),
    icon = "/esoui/art/currency/currency_crown_gems.dds"
    -- onClick = function()
    --     if (not IsInGamepadPreferredMode()) then
    --         SCENE_MANAGER:Show("market")
    --     else
    --         SCENE_MANAGER:Show("gamepad_market")
    --     end
    -- end
}

BS.widgets[BS.W_CROWNS] = {
    name = "crowns",
    update = function(widget)
        local crowns = GetCurrencyAmount(_G.CURT_CROWNS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[BS.W_CROWNS].UseSeparators == true) then
            crowns = BS.AddSeparators(crowns)
        end

        widget:SetValue(crowns)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_CROWNS].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_CROWN_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_CROWNS),
    icon = "/esoui/art/currency/currency_crowns_32.dds"
    -- onClick = function()
    --     if (not IsInGamepadPreferredMode()) then
    --         SCENE_MANAGER:Show("market")
    --     end
    -- end
}

BS.widgets[BS.W_EVENT_TICKETS] = {
    name = "eventTickets",
    update = function(widget)
        local vars = BS.Vars.Controls[BS.W_EVENT_TICKETS]
        local tickets = GetCurrencyAmount(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local noLimitColour = vars.NoLimitColour and "|cf9f9f9" or ""
        local noLimitTerminator = vars.NoLimitColour and "|r" or ""
        local value = tickets .. (vars.HideLimit and "" or (noLimitColour .. "/12" .. noLimitTerminator))
        local widthValue = tickets .. (vars.HideLimit and "" or "/12")
        local pc = BS.ToPercent(tickets, 12)

        if (vars.ShowPercent) then
            value = pc .. "%"
        end

        local colour = vars.Colour or BS.Vars.DefaultColour

        if (tickets > vars.DangerValue) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour

            if (vars.Announce) then
                local announce = true
                local previousTime = BS.Vars.PreviousAnnounceTime[BS.W_EVENT_TICKETS] or (os.time() - 100)
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
                    BS.Vars.PreviousAnnounceTime[BS.W_EVENT_TICKETS] = os.time()
                    BS.Announce(
                        GetString(_G.BARSTEWARD_WARNING),
                        GetString(_G.BARSTEWARD_WARNING_EVENT_TICKETS),
                        BS.W_EVENT_TICKETS
                    )
                end
            end
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(value, widthValue)

        return value
    end,
    event = _G.EVENT_CURRENCY_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_EVENT_TICKETS),
    icon = "/esoui/art/currency/currency_eventticket.dds",
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {
            0,
            1,
            5,
            10,
            15,
            20,
            30,
            40,
            50,
            60
        },
        varName = "DebounceTime",
        refresh = false,
        default = 5
    }
}

BS.widgets[BS.W_GOLD] =
    currencyWidget(
    _G.CURT_MONEY,
    BS.W_GOLD,
    "/esoui/art/currency/currency_gold_64.dds",
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS))
    },
    _G.EVENT_MONEY_UPDATE
)

BS.widgets[BS.W_SEALS_OF_ENDEAVOUR] = {
    name = "sealsOfEndeavour",
    update = function(widget)
        local seals = GetCurrencyAmount(_G.CURT_ENDEAVOR_SEALS, _G.CURRENCY_LOCATION_ACCOUNT)

        if (BS.Vars.Controls[BS.W_SEALS_OF_ENDEAVOUR].UseSeparators == true) then
            seals = BS.AddSeparators(seals)
        end

        widget:SetValue(seals)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_SEALS_OF_ENDEAVOUR].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL)),
    icon = "/esoui/art/currency/currency_seals_of_endeavor_64.dds"
    -- onClick = function()
    --     ZO_ShowSealStore()
    -- end
}

BS.widgets[BS.W_TELVAR_STONES] =
    currencyWidget(
    _G.CURT_TELVAR_STONES,
    BS.W_TELVAR_STONES,
    "/esoui/art/currency/currency_telvar_64.dds",
    {
        bag = _G.BARSTEWARD_GOLD_BAG,
        bank = _G.BARSTEWARD_GOLD_BANK,
        combined = _G.BARSTEWARD_GOLD_COMBINED,
        display = _G.BARSTEWARD_GOLD_DISPLAY,
        everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
        separated = _G.BARSTEWARD_GOLD_SEPARATED,
        title = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_TELVAR_STONES))
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
        local value = crystals .. (vars.HideLimit and "" or "/1000")
        local pc = BS.ToPercent(crystals, 1000)
        local colour = vars.Colour or BS.Vars.DefaultColour

        if ((vars.WarningValue or 0) > 0) then
            if (crystals < (vars.WarningValue or 0)) then
                colour = vars.WarningColour or BS.Vars.DefaultWarningColour
            end
        end

        if ((vars.DangerValue or 0) > 0) then
            if (crystals < (vars.DangerValue or 0)) then
                colour = vars.DangerColour or BS.Vars.DefaultDangerColour
            end
        end

        if (vars.ShowPercent) then
            value = pc .. "%"
        end

        widget:SetValue(value)
        widget:SetColour(unpack(colour))

        return value
    end,
    event = {_G.EVENT_CURRENCY_UPDATE, _G.EVENT_QUEST_COMPLETE_DIALOG},
    tooltip = GetString(_G.BARSTEWARD_TRANSMUTE_CRYSTALS),
    icon = "/esoui/art/currency/icon_seedcrystal.dds"
}

BS.widgets[BS.W_UNDAUNTED_KEYS] = {
    name = "undauntedKeys",
    update = function(widget)
        widget:SetValue(GetCurrencyAmount(_G.CURT_UNDAUNTED_KEYS, _G.CURRENCY_LOCATION_ACCOUNT))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_UNDAUNTED_KEYS].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_QUEST_COMPLETE_DIALOG,
    tooltip = GetString(_G.BARSTEWARD_UNDAUNTED_KEYS),
    icon = "/esoui/art/icons/quest_key_002.dds"
}

BS.widgets[BS.W_WRIT_VOUCHERS] =
    currencyWidget(
    _G.CURT_WRIT_VOUCHERS,
    BS.W_WRIT_VOUCHERS,
    "/esoui/art/currency/currency_writvoucher.dds",
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

local function getEmptySlotCount()
    local emptySlots = {}
    local championBar = CHAMPION_PERKS:GetChampionBar()
    local foundEmpty = false

    for slot = 1, championBar:GetNumSlots() do
        if (championBar:GetSlot(slot):GetSavedChampionSkillData() == nil) then
            local disciplineId = GetRequiredChampionDisciplineIdForSlot(slot, _G.HOTBAR_CATEGORY_CHAMPION)
            local disciplineName = GetChampionDisciplineName(disciplineId)

            emptySlots[disciplineName] = (emptySlots[disciplineName] or 0) + 1
            foundEmpty = true
        end
    end

    return emptySlots, foundEmpty
end

BS.widgets[BS.W_CHAMPION_POINTS] = {
    name = "championPoints",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = math.floor((xp / xplvl) * 100)
        local disciplineType = GetChampionPointPoolForRank(earned + 1)
        local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(disciplineType)
        local cpicon = disciplineData:GetHUDIcon()
        local vars = BS.Vars.Controls[BS.W_CHAMPION_POINTS]
        local cp = {}

        if (vars.UseSeparators == true) then
            earned = BS.AddSeparators(earned)
        end

        widget:SetColour(unpack(vars.Colour or BS.Vars.DefaultColour))
        widget:SetValue(earned .. " " .. "(" .. pc .. "%)")
        widget:SetIcon(cpicon)

        local icons = {}
        for disciplineIndex = 1, GetNumChampionDisciplines() do
            local id = GetChampionDisciplineId(disciplineIndex)

            disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataById(id)
            local icon = zo_iconFormat(disciplineData:GetHUDIcon(), 16, 16)
            local disciplineName = GetChampionDisciplineName(id)
            icons[disciplineName] = icon

            local name = ZO_CachedStrFormat("<<C:1>>", disciplineName)
            local toSpend = disciplineData:GetNumSavedUnspentPoints()

            table.insert(cp, icon .. " " .. name .. " - " .. toSpend)
        end

        local unslotted = 0

        if (#cp > 0) then
            local ttt = GetString(_G.BARSTEWARD_UNSPENT)

            for _, c in ipairs(cp) do
                if (ttt ~= "") then
                    ttt = ttt .. BS.LF
                end

                ttt = ttt .. c
            end

            local emptySlots, foundEmpty = getEmptySlotCount()

            if (foundEmpty) then
                ttt = ttt .. BS.LF .. BS.LF .. GetString(_G.BARSTEWARD_UNSLOTTED)
                for discipline, empty in pairs(emptySlots) do
                    ttt =
                        ttt ..
                        BS.LF .. icons[discipline] .. " " .. ZO_CachedStrFormat("<<C:1>>", discipline) .. " - " .. empty
                    unslotted = unslotted + empty
                end
            end

            widget.tooltip = ttt
        end

        local value = earned .. " " .. "(" .. pc .. "%)"
        local plainValue = value

        if (vars.ShowUnslottedCount and unslotted > 0) then
            plainValue = value .. " - " .. unslotted
            value = value .. " - |cff0000" .. unslotted .. "|r"
        end

        widget:SetColour(unpack(vars.Colour or BS.Vars.DefaultColour))
        widget:SetValue(value, plainValue)
        widget:SetIcon(cpicon)

        return earned
    end,
    event = {_G.EVENT_EXPERIENCE_UPDATE, _G.EVENT_UNSPENT_CHAMPION_POINTS_CHANGED},
    icon = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL)),
    hideWhenEqual = 0,
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            MAIN_MENU_KEYBOARD:ShowScene("championPerks")
        else
            MAIN_MENU_GAMEPAD:ShowScene("gamepad_championPerks_root")
        end
    end,
    customSettings = {
        [1] = {
            name = GetString(_G.BARSTEWARD_UNSLOTTED_OPTION),
            tooltip = GetString(_G.BARSTEWARD_UNSLOTTED_TOOLTIP),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnslottedCount
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnslottedCount = value
                BS.RefreshWidget(BS.W_CHAMPION_POINTS)
            end,
            width = "full",
            default = false
        }
    }
}
