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
        time = [number] [optional] the time interval in ms before the update function is called again,
        event = [string/table] [optional] the event or array of events that will trigger the update function,
        tooltip = [string] [optional] the tooltip text that will display when the user hovers over the value,
        icon = [string/function] path to the eso texture file
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
            widget:SetValue(GetCurrencyAmount(_G.CURT_ALLIANCE_POINTS, _G.CURRENCY_LOCATION_CHARACTER))
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
            widget:SetValue(GetCurrencyAmount(_G.CURT_CROWN_GEMS, _G.CURRENCY_LOCATION_ACCOUNT))
            return widget:GetValue()
        end,
        event = _G.EVENT_CROWN_GEM_UPDATE,
        tooltip = GetString(_G.BARSTEWARD_CROWN_GEMS),
        icon = "/esoui/art/currency/currency_crown_gems.dds"
    },
    [4] = {
        name = "crowns",
        update = function(widget)
            widget:SetValue(GetCurrencyAmount(_G.CURT_CROWNS, _G.CURRENCY_LOCATION_ACCOUNT))
            return widget:GetValue()
        end,
        event = _G.EVENT_CROWN_UPDATE,
        tooltip = GetString(_G.BARSTEWARD_CROWNS),
        icon = "/esoui/art/currency/currency_crowns_32.dds"
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
            widget:SetValue(GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER))
            return widget:GetValue()
        end,
        event = _G.EVENT_MONEY_UPDATE,
        tooltip = GetString(_G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
        icon = "/esoui/art/currency/currency_gold_64.dds"
    },
    [7] = {
        name = "sealsOfEndeavour",
        update = function(widget)
            widget:SetValue(GetCurrencyAmount(_G.CURT_ENDEAVOR_SEALS, _G.CURRENCY_LOCATION_ACCOUNT))
            return widget:GetValue()
        end,
        event = _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
        tooltip = GetString(_G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL),
        icon = "/esoui/art/market/keyboard/tabicon_sealsstore_up.dds"
    },
    [8] = {
        name = "telVarStones",
        update = function(widget)
            widget:SetValue(GetCurrencyAmount(_G.CURT_TELVAR_STONES, _G.CURRENCY_LOCATION_CHARACTER))
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
        icon = "/esoui/art/tooltips/icon_bag.dds"
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
        tooltip = GetString(_G.BARSTEWARD_FPS)
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
        tooltip = GetString(_G.BARSTEWARD_LATENCY)
    },
    [16] = {
        name = "blacksmithing",
        update = function(widget)
            local timeRemaining = BS.GetResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)
            widget:SetValue(BS.SecondsToTime(timeRemaining))
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
            widget:SetValue(BS.SecondsToTime(timeRemaining))
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
            widget:SetValue(BS.SecondsToTime(timeRemaining))
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
            widget:SetValue(BS.SecondsToTime(timeRemaining))
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
                widget:SetValue(repairCost)
                return repairCost
            end

            return widget:GetValue()
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/ava/ava_resourcestatus_tabicon_defense_inactive.dds",
        tooltip = GetString(_G.BARSTEWARD_REPAIR_COST),
        hideWhenEqual = 0
    },
    [21] = {
        name = "mountTraining",
        update = function(widget)
            local remaining, total = GetTimeUntilCanBeTrained()

            local time = "X"

            if (remaining ~= nil and total ~= nil) then
                time = BS.SecondsToTime(remaining / 1000, true)
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

            widget:SetValue(earned .. " " .. "(" .. pc .. "%)")

            return earned
        end,
        event = _G.EVENT_EXPERIENCE_UPDATE,
        icon = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
        tooltip = GetString(_G.SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
        hideWhenEqual = 0
    },
    [24] = {
        -- v1.0.1
        name = "mundusstone",
        update = function(widget, ...)
            local mundusId = nil

            if (... == "initial") then
                d("init")
                for buffNum = 1, GetNumBuffs("player") do
                    local id = select(11, GetUnitBuffInfo("player", buffNum))

                    if (BS.mundusstones[id]) then
                        mundusId = id
                        break
                    end
                end
            else
                local changeType = select(1, ...)
                local abilityId = select(15, ...)

                if (changeType == _G.EFFECT_RESULT_GAINED and BS.mundusstones[abilityId]) then
                    mundusId = abilityId
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
                local lowest = 100
                local lowestType = _G.ITEMTYPE_ARMOR

                for slot = 0, GetBagSize(_G.BAG_WORN) do
                    local itemName = GetItemName(_G.BAG_WORN, slot)
                    local condition = GetItemCondition(_G.BAG_WORN, slot)

                    if (lowest > condition and itemName ~= "") then
                        lowest = condition
                        lowestType = GetItemType(_G.BAG_WORN, slot)
                    end
                end

                widget:SetValue(lowest .. "%")

                if (lowest >= 75) then
                    widget:SetColour(0, 1, 0, 1)
                elseif (lowest >= 15) then
                    widget:SetColour(1, 1, 0, 1)
                else
                    widget:SetColour(1, 0, 0, 1)
                end

                if (lowest <= 15) then
                    if (lowestType == _G.ITEMTYPE_WEAPON) then
                        widget:SetIcon("/esoui/art/hud/broken_weapon.dds")
                    else
                        widget:SetIcon("/esoui/art/hud/broken_armor.dds")
                    end
                else
                    widget:SetIcon("/esoui/art/inventory/inventory_tabicon_armor_up.dds")
                end

                return lowest
            end
        end,
        event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        icon = "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
        tooltip = GetString(_G.BARSTEWARD_DURABILITY)
    },
    [26] = {
        -- v1.0.1
        name = "dailyEndeavourProgress",
        update = function(widget)
            return BS.GetTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_DAILY, widget)
        end,
        event = _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
        icon = "/esoui/art/journal/u26_progress_digsite_checked_incomplete.dds",
        tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS)
    },
    [27] = {
        -- v1.0.1
        name = "weekyEndeavourProgress",
        update = function(widget)
            return BS.GetTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, widget)
        end,
        event = _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
        icon = "/esoui/art/journal/u26_progress_digsite_checked_complete.dds",
        tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS)
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
    }
}
