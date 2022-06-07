local BS = _G.BarSteward

BS.mundusstones = {
    [13940] = true,
    [13943] = true,
    [13974] = true,
    [13975] = true,
    [13976] = true,
    [13977] = true,
    [13978] = true,
    [13979] = true,
    [13980] = true,
    [13981] = true,
    [13982] = true,
    [13984] = true,
    [13985] = true
}

--[[
    {
        name = [string] "widget name",
        update = [function] function that takes widget as an argument and sets the widget value / colour. Must return the raw value,
        timer = [number] [optional] the time interval in ms before the update function is called again,
        event = [string/table] [optional] the event or array of events that will trigger the update function,
        filter = [table] table of filters to apply to an event. Key is the event, value is another table indicating the filter and value
        tooltip = [string] [optional] the tooltip text that will display when the user hovers over the value,
        icon = [string/function] path to the eso texture file,
        hideWhenTrue = [function] this boolean result of this functions determines if the widget should be hidden or not,
        minWidthChars = [string] string to use to set the minimum width of the widget value,
        onClick = [function] function to call when the widget is clicked
    }
]]
BS.widgets = {
    [1] = {
        name = "time",
        update = function(widget)
            local format = BS.Vars.TimeFormat24

            if (BS.Vars.TimeType == GetString(_G.BARSTEWARD_12)) then
                format = BS.Vars.TimeFormat12
            end

            local time = BS.FormatTime(format)

            widget:SetValue(time)
            return widget:GetValue()
        end,
        timer = 1000,
        tooltip = GetString(_G.SI_TRADINGHOUSELISTINGSORTTYPE0),
        icon = "/esoui/art/lfg/lfg_indexicon_timedactivities_up.dds"
    },
    [2] = {
        name = "alliancePoints",
        update = function(widget)
            local points = GetCurrencyAmount(_G.CURT_ALLIANCE_POINTS, _G.CURRENCY_LOCATION_CHARACTER)

            if (BS.Vars.Controls[2].UseSeparators == true) then
                points = BS.AddSeparators(points)
            end

            widget:SetValue(points)
            return widget:GetValue()
        end,
        event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ALLIANCE_POINT_UPDATE},
        tooltip = GetString(_G.SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS),
        icon = "/esoui/art/currency/alliancepoints_64.dds",
        hideWhenTrue = function()
            if (BS.Vars.Controls[2].PvPOnly == true) then
                local mapContentType = GetMapContentType()
                local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

                return not isPvP
            end

            return false
        end
    },
    [3] = {
        name = "crownGems",
        update = function(widget)
            local gems = GetCurrencyAmount(_G.CURT_CROWN_GEMS, _G.CURRENCY_LOCATION_ACCOUNT)

            if (BS.Vars.Controls[3].UseSeparators == true) then
                gems = BS.AddSeparators(gems)
            end

            widget:SetValue(gems)
            return widget:GetValue()
        end,
        event = _G.EVENT_CROWN_GEM_UPDATE,
        tooltip = GetString(_G.BARSTEWARD_CROWN_GEMS),
        icon = "/esoui/art/currency/currency_crown_gems.dds",
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("market")
            else
                SCENE_MANAGER:Show("gamepad_market")
            end
        end
    },
    [4] = {
        name = "crowns",
        update = function(widget)
            local crowns = GetCurrencyAmount(_G.CURT_CROWNS, _G.CURRENCY_LOCATION_ACCOUNT)

            if (BS.Vars.Controls[4].UseSeparators == true) then
                crowns = BS.AddSeparators(crowns)
            end
            widget:SetValue(crowns)
            return widget:GetValue()
        end,
        event = _G.EVENT_CROWN_UPDATE,
        tooltip = GetString(_G.BARSTEWARD_CROWNS),
        icon = "/esoui/art/currency/currency_crowns_32.dds",
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("market")
            end
        end
    },
    [5] = {
        name = "eventTickets",
        update = function(widget)
            local tickets = GetCurrencyAmount(_G.CURT_EVENT_TICKETS, _G.CURRENCY_LOCATION_ACCOUNT)
            local value = tickets .. "/12"
            local pc = BS.ToPercent(tickets, 12)

            if (BS.Vars.Controls[5].ShowPercent) then
                value = pc .. "%"
            end

            widget:SetValue(value)

            if (tickets > 8) then
                widget:SetColour(0.8, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            return value
        end,
        event = _G.EVENT_QUEST_COMPLETE_DIALOG,
        tooltip = GetString(_G.BARSTEWARD_EVENT_TICKETS),
        icon = "/esoui/art/currency/currency_eventticket.dds"
    },
    [6] = {
        name = "gold",
        update = function(widget)
            local gold = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER)

            if (BS.Vars.Controls[6].UseSeparators == true) then
                gold = BS.AddSeparators(gold)
            end

            widget:SetValue(gold)
            return widget:GetValue()
        end,
        event = _G.EVENT_MONEY_UPDATE,
        tooltip = GetString(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
        icon = "/esoui/art/currency/currency_gold_64.dds"
    },
    [7] = {
        name = "sealsOfEndeavour",
        update = function(widget)
            local seals = GetCurrencyAmount(_G.CURT_ENDEAVOR_SEALS, _G.CURRENCY_LOCATION_ACCOUNT)

            if (BS.Vars.Controls[7].UseSeparators == true) then
                seals = BS.AddSeparators(seals)
            end
            widget:SetValue(seals)
            return widget:GetValue()
        end,
        event = _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
        tooltip = GetString(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL),
        icon = "/esoui/art/market/keyboard/tabicon_sealsstore_up.dds",
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("endeavorSealStoreSceneKeyboard")
            else
                SCENE_MANAGER:Show("gamepad_endeavor_seal_market_pre_scene")
            end
        end
    },
    [8] = {
        name = "telVarStones",
        update = function(widget)
            local stones = GetCurrencyAmount(_G.CURT_TELVAR_STONES, _G.CURRENCY_LOCATION_CHARACTER)

            if (BS.Vars.Controls[8].UseSeparators == true) then
                stones = BS.AddSeparators(stones)
            end
            widget:SetValue(stones)
            return widget:GetValue()
        end,
        event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TELVAR_STONE_UPDATE},
        tooltip = GetString(_G.SI_GAMEPAD_INVENTORY_TELVAR_STONES),
        icon = "/esoui/art/currency/currency_telvar_64.dds",
        hideWhenTrue = function()
            if (BS.Vars.Controls[8].PvPOnly == true) then
                local mapContentType = GetMapContentType()
                local isPvP = (mapContentType == _G.MAP_CONTENT_AVA or mapContentType == _G.MAP_CONTENT_BATTLEGROUND)

                return not isPvP
            end

            return false
        end
    },
    [9] = {
        name = "transmuteCrystals",
        update = function(widget, _, currencyType)
            if (currencyType == nil or currencyType == _G.CURT_CHAOTIC_CREATIA) then
                local crystals = GetCurrencyAmount(_G.CURT_CHAOTIC_CREATIA, _G.CURRENCY_LOCATION_ACCOUNT)
                local value = crystals .. "/1000"
                local pc = BS.ToPercent(crystals, 1000)

                if (BS.Vars.Controls[9].ShowPercent) then
                    value = pc .. "%"
                end

                widget:SetValue(value)
                return value
            end
        end,
        event = _G.EVENT_QUEST_COMPLETE_DIALOG,
        tooltip = GetString(_G.BARSTEWARD_TRANSMUTE_CRYSTALS),
        icon = "/esoui/art/currency/icon_seedcrystal.dds"
    },
    [10] = {
        name = "undauntedKeys",
        update = function(widget, _, currencyType)
            if (currencyType == nil or currencyType == _G.CURT_UNDAUNTED_KEYS) then
                widget:SetValue(GetCurrencyAmount(_G.CURT_UNDAUNTED_KEYS, _G.CURRENCY_LOCATION_ACCOUNT))
                return widget:GetValue()
            end
        end,
        event = _G.EVENT_QUEST_COMPLETE_DIALOG,
        tooltip = GetString(_G.BARSTEWARD_UNDAUNTED_KEYS),
        icon = "/esoui/art/icons/quest_key_002.dds"
    },
    [11] = {
        name = "writVouchers",
        update = function(widget)
            widget:SetValue(GetCurrencyAmount(_G.CURT_WRIT_VOUCHERS, _G.CURRENCY_LOCATION_CHARACTER))
            return widget:GetValue()
        end,
        event = _G.EVENT_WRIT_VOUCHER_UPDATE,
        tooltip = GetString(_G.BARSTEWARD_WRIT_VOUCHERS),
        icon = "/esoui/art/currency/currency_writvoucher.dds"
    },
    [12] = {
        name = "bagSpace",
        update = function(widget)
            local bagSize = GetBagSize(_G.BAG_BACKPACK)
            local bagUsed = GetNumBagUsedSlots(_G.BAG_BACKPACK)
            local value = bagUsed .. "/" .. bagSize
            local pcUsed = math.floor((bagUsed / bagSize) * 100)

            if (pcUsed >= 85 and pcUsed < 95) then
                widget:SetColour(1, 1, 0, 1)
            elseif (pcUsed >= 95) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0, 1, 0, 1)
            end

            if (BS.Vars.Controls[12].ShowPercent) then
                value = pcUsed .. "%"
            end

            widget:SetValue(value)

            return pcUsed
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        tooltip = GetString(_G.SI_GAMEPAD_MAIL_INBOX_INVENTORY),
        icon = "/esoui/art/tooltips/icon_bag.dds",
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("inventory")
            else
                SCENE_MANAGER:Show("gamepad_inventory_root")
            end
        end
    },
    [13] = {
        name = "bankSpace",
        update = function(widget)
            local bagSize = GetBagSize(_G.BAG_BANK)
            local bagUsed = GetNumBagUsedSlots(_G.BAG_BANK)

            if (IsESOPlusSubscriber()) then
                bagSize = bagSize + GetBagSize(_G.BAG_SUBSCRIBER_BANK)
                bagUsed = bagUsed + GetNumBagUsedSlots(_G.BAG_SUBSCRIBER_BANK)
            end

            local value = bagUsed .. "/" .. bagSize
            local pcUsed = math.floor((bagUsed / bagSize) * 100)

            if (pcUsed >= 85 and pcUsed < 95) then
                widget:SetColour(1, 1, 0, 1)
            elseif (pcUsed >= 95) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0, 1, 0, 1)
            end

            if (BS.Vars.Controls[13].ShowPercent) then
                value = pcUsed .. "%"
            end

            widget:SetValue(value)

            return pcUsed
        end,
        event = _G.EVENT_CLOSE_BANK,
        tooltip = GetString(_G.SI_INTERACT_OPTION_BANK),
        icon = "/esoui/art/tooltips/icon_bank.dds"
    },
    [14] = {
        name = "fps",
        update = function(widget)
            local framerate = GetFramerate()
            widget:SetValue(math.floor(framerate))
            return widget:GetValue()
        end,
        timer = 1000,
        icon = "/esoui/art/champion/actionbar/champion_bar_combat_selection.dds",
        tooltip = GetString(_G.BARSTEWARD_FPS),
        minWidthChars = "888"
    },
    [15] = {
        name = "latency",
        update = function(widget)
            local latency = GetLatency()
            widget:SetValue(math.floor(latency))
            return widget:GetValue()
        end,
        timer = 1000,
        icon = "/esoui/art/ava/overview_icon_underdog_score.dds",
        tooltip = GetString(_G.BARSTEWARD_LATENCY),
        minWidthChars = "8888"
    },
    [16] = {
        name = "blacksmithing",
        update = function(widget)
            local timeRemaining = BS.GetResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)

            if (timeRemaining == 0) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[16].HideSeconds))
            return timeRemaining
        end,
        timer = 1000,
        icon = "/esoui/art/icons/servicemappins/servicepin_smithy.dds",
        tooltip = GetString(_G.SI_TRADESKILLTYPE1),
        hideWhenEqual = 0
    },
    [17] = {
        name = "woodworking",
        update = function(widget)
            local timeRemaining = BS.GetResearchTimer(_G.CRAFTING_TYPE_WOODWORKING)

            if (timeRemaining == 0) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[17].HideSeconds))
            return timeRemaining
        end,
        timer = 1000,
        icon = "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",
        tooltip = GetString(_G.SI_TRADESKILLTYPE6),
        hideWhenEqual = 0
    },
    [18] = {
        name = "clothing",
        update = function(widget)
            local timeRemaining = BS.GetResearchTimer(_G.CRAFTING_TYPE_CLOTHIER)

            if (timeRemaining == 0) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[18].HideSeconds))
            return timeRemaining
        end,
        timer = 1000,
        icon = "/esoui/art/icons/servicemappins/servicepin_outfitter.dds",
        tooltip = GetString(_G.SI_TRADESKILLTYPE2),
        hideWhenEqual = 0
    },
    [19] = {
        name = "jewelcrafting",
        update = function(widget)
            local timeRemaining = BS.GetResearchTimer(_G.CRAFTING_TYPE_JEWELRYCRAFTING)

            if (timeRemaining == 0) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[19].HideSeconds))
            return timeRemaining
        end,
        timer = 1000,
        icon = "/esoui/art/icons/icon_jewelrycrafting_symbol.dds",
        tooltip = GetString(_G.SI_TRADESKILLTYPE7),
        hideWhenEqual = 0
    },
    [20] = {
        name = "itemRepairCost",
        update = function(widget, _, _, _, _, updateReason)
            if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
                local repairCost = GetRepairAllCost()

                if (BS.Vars.Controls[20].UseSeparators == true) then
                    repairCost = BS.AddSeparators(repairCost)
                end

                widget:SetValue(repairCost)
                return repairCost
            end

            return widget:GetValue()
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/ava/ava_resourcestatus_tabicon_defense_inactive.dds",
        tooltip = GetString(_G.BARSTEWARD_REPAIR_COST),
        hideWhenEqual = 0,
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("inventory")
            else
                SCENE_MANAGER:Show("gamepad_inventory_root")
            end
        end
    },
    [21] = {
        name = "mountTraining",
        update = function(widget)
            local remaining, total = GetTimeUntilCanBeTrained()

            local time = "X"

            if (remaining ~= nil and total ~= nil) then
                time = BS.SecondsToTime(remaining / 1000, true, false, BS.Vars.Controls[21].HideSeconds)
            end

            if (remaining == 0) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0.9, 0.9, 0.9, 1)
            end

            widget:SetValue(time)
            return remaining
        end,
        timer = 1000,
        icon = "/esoui/art/mounts/tabicon_mounts_up.dds",
        tooltip = GetString(_G.BARSTEWARD_MOUNT_TRAINING),
        hideWhenEqual = 0
    },
    [22] = {
        name = "rapport",
        update = function(widget)
            local rapportValue = GetActiveCompanionRapport()
            local rapportMax = GetMaximumRapport()
            local rapportMin = GetMinimumRapport()
            local rdr, rdg, rdb = 0, 153 / 255, 102 / 255 -- dislike
            local rmr, rmg, rmb = 157 / 255, 132 / 255, 13 / 255 -- moderate
            local rlr, rlg, rlb = 114 / 255, 35 / 255, 35 / 255 -- like
            local rapportPcValue = rapportValue - rapportMin
            local rapportPcMax = rapportMax - rapportMin
            local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
            local r, g, b = BS.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

            widget:SetColour(r, g, b, 1)
            widget:SetValue(rapportValue)

            return rapportValue
        end,
        event = {_G.EVENT_COMPANION_RAPPORT_UPDATE, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED},
        icon = "/esoui/art/hud/loothistory_icon_rapportincrease.dds",
        tooltip = GetString(_G.BARSTEWARD_RAPPORT),
        hideWhenEqual = function()
            if (HasActiveCompanion()) then
                return GetMaximumRapport()
            else
                return 0
            end
        end
    },
    [23] = {
        name = "championPoints",
        update = function(widget)
            local earned = GetPlayerChampionPointsEarned()
            local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
            local pc = math.floor((xp / xplvl) * 100)
            local disciplineType = GetChampionPointPoolForRank(earned)
            local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(disciplineType)
            local icon = disciplineData:GetHUDIcon()

            if (BS.Vars.Controls[23].UseSeparators == true) then
                earned = BS.AddSeparators(earned)
            end

            widget:SetValue(earned .. " " .. "(" .. pc .. "%)")
            widget:SetIcon(icon)

            return earned
        end,
        event = _G.EVENT_EXPERIENCE_UPDATE,
        icon = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
        tooltip = GetString(_G.SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
        hideWhenEqual = 0,
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("championPerks")
            else
                SCENE_MANAGER:Show("gamepad_championPerks_root")
            end
        end
    },
    [24] = {
        -- v1.0.1
        name = "mundusstone",
        update = function(widget)
            local mundusId = nil

            for buffNum = 1, GetNumBuffs("player") do
                local id = select(11, GetUnitBuffInfo("player", buffNum))

                if (BS.mundusstones[id]) then
                    mundusId = id
                    break
                end
            end

            if (mundusId ~= nil) then
                local icon = GetAbilityIcon(mundusId)
                local name = GetAbilityName(mundusId)

                widget:SetIcon(icon)
                widget:SetValue(name)

                return name
            end

            return ""
        end,
        event = _G.EVENT_EFFECT_CHANGED,
        filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
        icon = "/esoui/art/icons/ability_mundusstones_002.dds",
        tooltip = GetString(_G.SI_CONFIRM_MUNDUS_STONE_TITLE),
        hideWhenEqual = ""
    },
    [25] = {
        -- v1.0.1
        name = "durability",
        update = function(widget, _, _, _, _, updateReason)
            -- find item with lowest durability
            if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
                return BS.GetDurability(widget)
            end
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
        tooltip = GetString(_G.BARSTEWARD_DURABILITY),
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("inventory")
            else
                SCENE_MANAGER:Show("gamepad_inventory_root")
            end
        end
    },
    [26] = {
        -- v1.0.1
        name = "dailyEndeavourProgress",
        update = function(widget)
            return BS.GetTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_DAILY, widget)
        end,
        event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
        icon = "/esoui/art/journal/u26_progress_digsite_checked_incomplete.dds",
        tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS),
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("groupMenuKeyboard")
            else
                SCENE_MANAGER:Show("gamepad_groupList")
            end
        end
    },
    [27] = {
        -- v1.0.1
        name = "weekyEndeavourProgress",
        update = function(widget)
            return BS.GetTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, widget)
        end,
        event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
        icon = "/esoui/art/journal/u26_progress_digsite_checked_complete.dds",
        tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS),
        onClick = function()
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    },
    [28] = {
        -- v1.0.1
        name = "repairKitCount",
        update = function(widget)
            local count = 0

            for slot = 0, GetBagSize(_G.BAG_BACKPACK) do
                if (IsItemRepairKit(_G.BAG_BACKPACK, slot)) then
                    count = count + GetSlotStackSize(_G.BAG_BACKPACK, slot)
                end
            end

            if (count < 6) then
                widget:SetColour(1, 0, 0, 1)
            elseif (count < 11) then
                widget:SetColour(1, 1, 0, 1)
            else
                widget:SetColour(0, 1, 0, 1)
            end

            widget:SetValue(count)

            return count
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/inventory/inventory_tabicon_repair_up.dds",
        tooltip = GetString(_G.SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER):gsub(":", "")
    },
    [29] = {
        -- v1.0.1
        name = "stolenItemCount",
        update = function(widget)
            local count = 0

            for _, bag in ipairs({_G.BAG_WORN, _G.BAG_BACKPACK, _G.BAG_BANK, _G.BAG_SUBSCRIBER_BANK}) do
                for slot = 0, GetBagSize(bag) do
                    if (IsItemStolen(bag, slot)) then
                        count = count + GetSlotStackSize(bag, slot)
                    end
                end
            end

            widget:SetValue(count)

            return count
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/inventory/inventory_stolenitem_icon.dds",
        tooltip = GetString(_G.BARSTEWARD_STOLEN),
        hideWhenEqual = 0
    },
    [30] = {
        -- v1.0.2
        name = "recallcooldown",
        update = function(widget)
            local cooldownTime = GetRecallCooldown() / 1000
            widget:SetValue(BS.SecondsToTime(cooldownTime, true, true))
            return cooldownTime
        end,
        timer = 1000,
        icon = "/esoui/art/zonestories/completiontypeicon_wayshrine.dds",
        tooltip = GetString(_G.BARSTEWARD_RECALL),
        hideWhenEqual = 0
    },
    [31] = {
        -- v1.0.2
        name = "fenceSlots",
        update = function(widget)
            local max, used = GetFenceLaunderTransactionInfo()
            local pcUsed = math.floor(used / max) * 100

            if (pcUsed >= 85 and pcUsed < 95) then
                widget:SetColour(1, 1, 0, 1)
            elseif (pcUsed >= 95) then
                widget:SetColour(1, 0, 0, 1)
            else
                widget:SetColour(0, 1, 0, 1)
            end

            widget:SetValue(used .. "/" .. max)

            return used
        end,
        event = _G.EVENT_CLOSE_STORE,
        icon = "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
        tooltip = GetString(_G.BARSTEWARD_FENCE)
    },
    [32] = {
        -- v1.0.3
        name = "currentZone",
        update = function(widget)
            widget:SetValue(GetUnitZone("player"))
            return widget:GetValue()
        end,
        event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ZONE_CHANGED},
        icon = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map.dds",
        tooltip = GetString(_G.SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY),
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("worldMap")
            else
                SCENE_MANAGER:Show("gamepad_worldMap")
            end
        end
    },
    [33] = {
        -- v1.0.3
        name = "playerName",
        update = function(widget)
            widget:SetValue(GetUnitName("player"))
            return widget:GetValue()
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        icon = "/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
        tooltip = GetString(_G.SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME)
    },
    [34] = {
        -- v1.0.3
        name = "playerRace",
        update = function(widget)
            widget:SetValue(GetUnitRace("player"))
            return widget:GetValue()
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        icon = "/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
        tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE1)
    },
    [35] = {
        -- v1.0.3
        name = "playerClass",
        update = function(widget)
            local classId = GetUnitClassId("player")
            local icon = GetClassIcon(classId)

            widget:SetValue(GetUnitClass("player"))
            widget:SetIcon(icon)

            return widget:GetValue()
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        icon = "/esoui/art/charactercreate/charactercreate_classicon_up.dds",
        tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE3)
    },
    [36] = {
        -- v1.0.3
        name = "playerAlliance",
        update = function(widget)
            local alliance = GetUnitAlliance("player")
            local icon = ZO_GetAllianceIcon(alliance)
            local colour = GetAllianceColor(alliance)

            if (string.find(icon, "daggerfall")) then
                icon = "/esoui/art/scoredisplay/blueflag.dds"
            elseif (string.find(icon, "aldmeri")) then
                icon = "/esoui/art/scoredisplay/yellowflag.dds"
            else
                icon = "/esoui/art/scoredisplay/redflag.dds"
            end

            widget:SetValue(" " .. GetAllianceName(alliance))
            widget:SetColour(colour.r, colour.g, colour.b, colour.a)
            widget:SetIcon(icon)
            widget:SetTextureCoords(0, 1, 0, 0.6)
            widget.icon:SetWidth(27)

            return widget:GetValue()
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        icon = "",
        tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE2),
        onClick = function()
            if (not IsInGamepadPreferredMode()) then
                SCENE_MANAGER:Show("campaignOverview")
            else
                SCENE_MANAGER:Show("gamepad_campaign_root")
            end
        end
    }
}
