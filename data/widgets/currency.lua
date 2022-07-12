local BS = _G.BarSteward

BS.widgets[BS.W_ALLIANCE_POINTS] = {
    name = "alliancePoints",
    update = function(widget)
        local points = GetCurrencyAmount(_G.CURT_ALLIANCE_POINTS, _G.CURRENCY_LOCATION_CHARACTER)

        if (BS.Vars.Controls[BS.W_ALLIANCE_POINTS].UseSeparators == true) then
            points = BS.AddSeparators(points)
        end

        widget:SetValue(points)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_ALLIANCE_POINTS].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ALLIANCE_POINT_UPDATE},
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS)),
    icon = "/esoui/art/currency/alliancepoints_64.dds",
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_ALLIANCE_POINTS].PvPOnly == true) then
            local mapContentType = GetMapContentType()
            local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

            return not isPvP
        end

        return false
    end
}

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
    icon = "/esoui/art/currency/currency_crown_gems.dds",
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
    icon = "/esoui/art/currency/currency_crowns_32.dds",
    -- onClick = function()
    --     if (not IsInGamepadPreferredMode()) then
    --         SCENE_MANAGER:Show("market")
    --     end
    -- end
}

BS.widgets[BS.W_EVENT_TICKETS] = {
    name = "eventTickets",
    update = function(widget)
        local tickets = GetCurrencyAmount(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
        local value = tickets .. "/12"
        local pc = BS.ToPercent(tickets, 12)

        if (BS.Vars.Controls[BS.W_EVENT_TICKETS].ShowPercent) then
            value = pc .. "%"
        end

        widget:SetValue(value)

        local colour = BS.Vars.Controls[BS.W_EVENT_TICKETS].Colour or BS.Vars.DefaultColour

        if (tickets > BS.Vars.Controls[BS.W_EVENT_TICKETS].DangerValue) then
            colour = BS.Vars.Controls[BS.W_EVENT_TICKETS].DangerColour or BS.Vars.DefaultDangerColour

            if (BS.Vars.Controls[BS.W_EVENT_TICKETS].Announce) then
                local announce = true
                local previousTime = BS.Vars.PreviousAnnounceTime[BS.W_EVENT_TICKETS] or (os.time() - 100)
                local debounceTime = (BS.Vars.Controls[BS.W_EVENT_TICKETS].DebounceTime or 5) * 60

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

BS.widgets[BS.W_GOLD] = {
    name = "gold",
    update = function(widget)
        local goldInBag = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER)
        local goldInBank = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_BANK)
        local combined = goldInBag + goldInBank
        local allCharacters = combined
        local otherCharacterGold = BS.Vars.Gold
        local thisCharacter = GetUnitName("player")
        local charactertt = ""
        local useSeparators = BS.Vars.Controls[BS.W_GOLD].UseSeparators

        for character, gold in pairs(otherCharacterGold) do
            if (character ~= thisCharacter) then
                allCharacters = allCharacters + gold
                charactertt =
                    charactertt ..
                    "|cffd700" ..
                        tostring(useSeparators and BS.AddSeparators(gold) or gold) ..
                            "|r " .. ZO_FormatUserFacingCharacterName(character) .. BS.LF
            end
        end

        if (useSeparators) then
            goldInBag = BS.AddSeparators(goldInBag)
            goldInBank = BS.AddSeparators(goldInBank)
            combined = BS.AddSeparators(combined)
            allCharacters = BS.AddSeparators(allCharacters)
        end

        local toDisplay = goldInBag
        local separated = goldInBag .. "/" .. goldInBank

        if (BS.Vars.Controls[BS.W_GOLD].GoldType == GetString(_G.BARSTEWARD_GOLD_BANK)) then
            toDisplay = goldInBank
        elseif (BS.Vars.Controls[BS.W_GOLD].GoldType == GetString(_G.BARSTEWARD_GOLD_COMBINED)) then
            toDisplay = combined
        elseif (BS.Vars.Controls[BS.W_GOLD].GoldType == GetString(_G.BARSTEWARD_GOLD_SEPARATED)) then
            toDisplay = separated
        elseif (BS.Vars.Controls[BS.W_GOLD].GoldType == GetString(_G.BARSTEWARD_GOLD_EVERYWHERE)) then
            toDisplay = allCharacters
        end

        widget:SetValue(toDisplay)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_GOLD].Colour or BS.Vars.DefaultColour))

        -- update the tooltip
        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS)) .. BS.LF
        ttt = ttt .. "|cffd700" .. tostring(goldInBag) .. "|r " .. GetString(_G.BARSTEWARD_GOLD_BAG) .. BS.LF
        ttt = ttt .. "|cffd700" .. tostring(goldInBank) .. "|r " .. GetString(_G.BARSTEWARD_GOLD_BANK) .. BS.LF
        ttt = ttt .. "|cffd700" .. tostring(combined) .. "|r " .. GetString(_G.BARSTEWARD_GOLD_COMBINED) .. BS.LF .. BS.LF
        ttt = ttt .. charactertt .. BS.LF
        ttt = ttt .. "|cffd700" .. tostring(allCharacters) .. "|r " .. GetString(_G.BARSTEWARD_GOLD_EVERYWHERE)

        widget.tooltip = ttt

        return widget:GetValue()
    end,
    event = _G.EVENT_MONEY_UPDATE,
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS)),
    icon = "/esoui/art/currency/currency_gold_64.dds",
    customOptions = {
        name = GetString(_G.BARSTEWARD_GOLD_DISPLAY),
        choices = {
            GetString(_G.BARSTEWARD_GOLD_BAG),
            GetString(_G.BARSTEWARD_GOLD_BANK),
            GetString(_G.BARSTEWARD_GOLD_COMBINED),
            GetString(_G.BARSTEWARD_GOLD_SEPARATED),
            GetString(_G.BARSTEWARD_GOLD_EVERYWHERE)
        },
        varName = "GoldType",
        refresh = true,
        default = GetString(_G.BARSTEWARD_GOLD_BAG)
    }
}

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
    icon = "/esoui/art/currency/currency_seals_of_endeavor_64.dds",
    -- onClick = function()
    --     if (not IsInGamepadPreferredMode()) then
    --         SYSTEMS:GetObject("mainMenu"):ShowSceneGroup("marketSceneGroup") --, "endeavorSealStoreSceneKeyboard")
    --     else
    --         SYSTEMS:GetObject("mainMenu"):SelectMenuEntryAndSubEntry(
    --             _G.ZO_MENU_MAIN_ENTRIES.CROWN_STORE,
    --             _G.ZO_MENU_CROWN_STORE_ENTRIES.ENDEAVOR_SEAL_STORE,
    --             "gamepad_endeavor_seal_market_pre_scene"
    --         )
    --     end
    -- end
}

BS.widgets[BS.W_TAL_VAR_STONES] = {
    name = "telVarStones",
    update = function(widget)
        local stones = GetCurrencyAmount(_G.CURT_TELVAR_STONES, _G.CURRENCY_LOCATION_CHARACTER)

        if (BS.Vars.Controls[BS.W_TAL_VAR_STONES].UseSeparators == true) then
            stones = BS.AddSeparators(stones)
        end

        widget:SetValue(stones)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_TAL_VAR_STONES].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TELVAR_STONE_UPDATE},
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_INVENTORY_TELVAR_STONES)),
    icon = "/esoui/art/currency/currency_telvar_64.dds",
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_TAL_VAR_STONES].PvPOnly == true) then
            local mapContentType = GetMapContentType()
            local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

            return not isPvP
        end

        return false
    end
}

BS.widgets[BS.W_TRANSMUTE_CRYSTALS] = {
    name = "transmuteCrystals",
    update = function(widget)
        local crystals = GetCurrencyAmount(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
        local value = crystals .. "/1000"
        local pc = BS.ToPercent(crystals, 1000)

        if (BS.Vars.Controls[BS.W_TRANSMUTE_CRYSTALS].ShowPercent) then
            value = pc .. "%"
        end

        widget:SetValue(value)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_TRANSMUTE_CRYSTALS].Colour or BS.Vars.DefaultColour))

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

BS.widgets[BS.W_WRIT_VOUCHERS] = {
    name = "writVouchers",
    update = function(widget)
        widget:SetValue(GetCurrencyAmount(_G.CURT_WRIT_VOUCHERS, _G.CURRENCY_LOCATION_CHARACTER))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_WRIT_VOUCHERS].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_WRIT_VOUCHER_UPDATE,
    tooltip = GetString(_G.BARSTEWARD_WRIT_VOUCHERS),
    icon = "/esoui/art/currency/currency_writvoucher.dds"
}

BS.widgets[BS.W_CHAMPION_POINTS] = {
    name = "championPoints",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = math.floor((xp / xplvl) * 100)
        local disciplineType = GetChampionPointPoolForRank(earned + 1)
        local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(disciplineType)
        local icon = disciplineData:GetHUDIcon()
        local cp = {}

        if (BS.Vars.Controls[BS.W_CHAMPION_POINTS].UseSeparators == true) then
            earned = BS.AddSeparators(earned)
        end

        widget:SetValue(earned .. " " .. "(" .. pc .. "%)")
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_CHAMPION_POINTS].Colour or BS.Vars.DefaultColour))
        widget:SetIcon(icon)

        for disciplineIndex = 1, GetNumChampionDisciplines() do
            local id = GetChampionDisciplineId(disciplineIndex)
            disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataById(id)
            icon = zo_iconFormat(disciplineData:GetHUDIcon(), 16, 16)
            local name = GetChampionDisciplineName(id)
            local toSpend = disciplineData:GetNumSavedUnspentPoints()
            table.insert(cp, icon .. " " .. name .. " - " .. toSpend)
        end

        if (#cp > 0) then
            local tooltipText = GetString(_G.BARSTEWARD_UNSPENT)

            for _, c in ipairs(cp) do
                if (tooltipText ~= "") then
                    tooltipText = tooltipText .. BS.LF
                end

                tooltipText = tooltipText .. c
            end

            widget.tooltip = tooltipText
        end

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
    end
}
