local BS = _G.BarSteward

BS.widgets[BS.W_BAG_SPACE] = {
    name = "bagSpace",
    update = function(widget, _, _, _, newItem)
        local bagSize = GetBagSize(_G.BAG_BACKPACK)
        local bagUsed = GetNumBagUsedSlots(_G.BAG_BACKPACK)
        local value = bagUsed .. "/" .. bagSize
        local pcUsed = math.floor((bagUsed / bagSize) * 100)

        local colour = BS.Vars.Controls[BS.W_BAG_SPACE].OkColour or BS.Vars.DefaultOkColour

        if
            (pcUsed >= BS.Vars.Controls[BS.W_BAG_SPACE].WarningValue and
                pcUsed < BS.Vars.Controls[BS.W_BAG_SPACE].DangerValue)
         then
            colour = BS.Vars.Controls[BS.W_BAG_SPACE].WarningColour or BS.Vars.DefaultWarningColour

            if (BS.Vars.Controls[BS.W_BAG_SPACE].Announce and newItem) then
                local announce = true
                local previousTime = BS.Vars.PreviousAnnounceTime[BS.W_BAG_SPACE] or (os.time() - 100)
                local debounceTime = 30

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                BS.Vars.PreviousAnnounceTime[BS.W_BAG_SPACE] = os.time()

                if (announce == true) then
                    BS.Announce(GetString(_G.BARSTEWARD_WARNING), GetString(_G.BARSTEWARD_WARNING_BAGS), BS.W_BAG_SPACE)
                end
            end
        elseif (pcUsed >= BS.Vars.Controls[BS.W_BAG_SPACE].DangerValue) then
            colour = BS.Vars.Controls[BS.W_BAG_SPACE].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))

        if (BS.Vars.Controls[BS.W_BAG_SPACE].ShowPercent) then
            value = pcUsed .. "%"
        end

        widget:SetValue(value)

        return pcUsed
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_MAIL_INBOX_INVENTORY)):gsub(":", ""),
    icon = "/esoui/art/tooltips/icon_bag.dds",
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_BANK_SPACE] = {
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

        local colour = BS.Vars.Controls[BS.W_BANK_SPACE].OkColour or BS.Vars.DefaultOkColour

        if
            (pcUsed >= BS.Vars.Controls[BS.W_BANK_SPACE].WarningValue and
                pcUsed < BS.Vars.Controls[BS.W_BANK_SPACE].DangerValue)
         then
            colour = BS.Vars.Controls[BS.W_BANK_SPACE].WarningColour or BS.Vars.DefaultWarningColour
        elseif (pcUsed >= BS.Vars.Controls[BS.W_BANK_SPACE].DangerValue) then
            colour = BS.Vars.Controls[BS.W_BANK_SPACE].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))

        if (BS.Vars.Controls[BS.W_BANK_SPACE].ShowPercent) then
            value = pcUsed .. "%"
        end

        widget:SetValue(value)

        return pcUsed
    end,
    event = _G.EVENT_CLOSE_BANK,
    tooltip = GetString(_G.BARSTEWARD_BANK),
    icon = "/esoui/art/tooltips/icon_bank.dds"
}

BS.widgets[BS.W_REPAIR_COST] = {
    name = "itemRepairCost",
    update = function(widget, _, _, _, _, _, updateReason)
        if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
            local repairCost = GetRepairAllCost()

            if (BS.Vars.Controls[BS.W_REPAIR_COST].UseSeparators == true) then
                repairCost = BS.AddSeparators(repairCost)
            end

            widget:SetValue(repairCost)
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_REPAIR_COST].Colour or BS.Vars.DefaultColour))

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
}

BS.widgets[BS.W_DURABILITY] = {
    -- v1.0.1
    name = "durability",
    update = function(widget, _, _, _, _, _, updateReason)
        -- find item with lowest durability
        if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
            local lowest = 100
            local lowestType = _G.ITEMTYPE_ARMOR
            local items = {}

            for slot = 0, GetBagSize(_G.BAG_WORN) do
                local itemName = ZO_CachedStrFormat("<<C:1>>", GetItemName(_G.BAG_WORN, slot))
                local condition = GetItemCondition(_G.BAG_WORN, slot)
                local colour = BS.ARGBConvert(BS.Vars.Controls[BS.W_DURABILITY].OkColour or BS.Vars.DefaultOkColour)

                if (itemName ~= "") then
                    if
                        (condition <= BS.Vars.Controls[BS.W_DURABILITY].OkValue and
                            condition >= BS.Vars.Controls[BS.W_DURABILITY].DangerValue)
                     then
                        colour =
                            BS.ARGBConvert(
                            BS.Vars.Controls[BS.W_DURABILITY].WarningColour or BS.Vars.DefaultWarningColour
                        )
                    elseif (condition < BS.Vars.Controls[BS.W_DURABILITY].DangerValue) then
                        colour =
                            BS.ARGBConvert(
                            BS.Vars.Controls[BS.W_DURABILITY].DangerColour or BS.Vars.DefaultDangerColour
                        )
                    end

                    table.insert(items, colour .. itemName .. " - " .. condition .. "%|r")

                    if (lowest > condition) then
                        lowest = condition
                        lowestType = GetItemType(_G.BAG_WORN, slot)
                    end
                end
            end

            widget:SetValue(lowest .. "%")

            local colour

            if (lowest >= BS.Vars.Controls[BS.W_DURABILITY].OkValue) then
                colour = BS.Vars.Controls[BS.W_DURABILITY].OkColour or BS.Vars.DefaultOkColour
            elseif (BS.Vars.Controls[BS.W_DURABILITY].DangerValue) then
                colour = BS.Vars.Controls[BS.W_DURABILITY].WarningColour or BS.Vars.DefaultWarningColour
            else
                colour = BS.Vars.Controls[BS.W_DURABILITY].DangerColour or BS.Vars.DefaultDangerColour
            end

            widget:SetColour(unpack(colour))

            if (lowest <= BS.Vars.Controls[BS.W_DURABILITY].DangerValue) then
                if (lowestType == _G.ITEMTYPE_WEAPON) then
                    widget:SetIcon("/esoui/art/hud/broken_weapon.dds")
                else
                    widget:SetIcon("/esoui/art/hud/broken_armor.dds")
                end
            else
                widget:SetIcon("/esoui/art/inventory/inventory_tabicon_armor_up.dds")
            end

            if (#items > 0) then
                local tooltipText = ""

                for _, i in ipairs(items) do
                    if (tooltipText ~= "") then
                        tooltipText = tooltipText .. BS.LF
                    end

                    tooltipText = tooltipText .. i
                end

                widget.tooltip = tooltipText
            end

            return lowest
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
}

BS.widgets[BS.W_REPAIRS_KITS] = {
    -- v1.0.1
    name = "repairKitCount",
    update = function(widget)
        local count = 0

        for slot = 0, GetBagSize(_G.BAG_BACKPACK) do
            if (IsItemRepairKit(_G.BAG_BACKPACK, slot)) then
                count = count + GetSlotStackSize(_G.BAG_BACKPACK, slot)
            end
        end

        local colour = BS.Vars.Controls[BS.W_REPAIRS_KITS].OkColour or BS.Vars.DefaultOkColour

        if (count < BS.Vars.Controls[BS.W_REPAIRS_KITS].DangerValue) then
            colour = BS.Vars.Controls[BS.W_REPAIRS_KITS].DangerColour or BS.Vars.DefaultDangerColour
        elseif (count < BS.Vars.Controls[BS.W_REPAIRS_KITS].WarningValue) then
            colour = BS.Vars.Controls[BS.W_REPAIRS_KITS].WarningColour or BS.Vars.DefaultWarningColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(count)

        return count
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "/esoui/art/inventory/inventory_tabicon_repair_up.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER)):gsub(":", "")
}

BS.widgets[BS.W_STOLEN_ITEMS] = {
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
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_STOLEN_ITEMS].Colour or BS.Vars.DefaultColour))

        return count
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "/esoui/art/inventory/inventory_stolenitem_icon.dds",
    tooltip = GetString(_G.BARSTEWARD_STOLEN),
    hideWhenEqual = 0
}

BS.widgets[BS.W_FENCE_TRANSACTIONS] = {
    -- v1.0.2
    name = "fenceSlots",
    update = function(widget)
        local max, used = GetFenceLaunderTransactionInfo()
        local pcUsed = math.floor(used / max) * 100
        local colour = BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].OkColour or BS.Vars.DefaultOkColour

        if
            (pcUsed >= BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].WarningValue and
                pcUsed < BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].DangerValue)
         then
            colour = BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].WarningColour or BS.Vars.DefaultWarningColour
        elseif (pcUsed >= BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].DangerValue) then
            colour = BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(used .. "/" .. max)

        return used
    end,
    event = _G.EVENT_CLOSE_STORE,
    icon = "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
    tooltip = GetString(_G.BARSTEWARD_FENCE)
}

BS.widgets[BS.W_SOUL_GEMS] = {
    -- v1.2.0
    name = "soulGems",
    update = function(widget)
        local level = GetUnitEffectiveLevel("player")
        local _, filledIcon, filledCount = GetSoulGemInfo(_G.SOUL_GEM_TYPE_FILLED, level)
        local _, emptyIcon, emptyCount = GetSoulGemInfo(_G.SOUL_GEM_TYPE_EMPTY, level)

        if (BS.Vars.Controls[BS.W_SOUL_GEMS].UseSeparators == true) then
            filledCount = BS.AddSeparators(filledCount)
            emptyCount = BS.AddSeparators(emptyCount)
        end

        local displayValue = filledCount
        local displayIcon = filledIcon
        local both = filledCount .. "/" .. emptyCount

        if (BS.Vars.Controls[BS.W_SOUL_GEMS].GemType == GetString(_G.BARSTEWARD_EMPTY)) then
            displayValue = emptyCount
            displayIcon = emptyIcon
        elseif (BS.Vars.Controls[BS.W_SOUL_GEMS].GemType == GetString(_G.BARSTEWARD_BOTH)) then
            displayValue = both
        end

        widget:SetValue(displayValue)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_SOUL_GEMS].Colour or BS.Vars.DefaultColour))
        widget:SetIcon(displayIcon)

        -- update the tooltip
        local ttt = GetString(_G.BARSTEWARD_SOUL_GEMS) .. BS.LF
        ttt = ttt .. zo_iconFormat(filledIcon, 16, 16) .. " " .. filledCount .. BS.LF
        ttt = ttt .. zo_iconFormat(emptyIcon, 16, 16) .. " " .. emptyCount

        widget.tooltip = ttt

        return widget:GetValue()
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "/esoui/art/icons/soulgem_006_filled.dds",
    tooltip = GetString(_G.BARSTEWARD_SOUL_GEMS),
    customOptions = {
        name = GetString(_G.BARSTEWARD_SOUL_GEMS_TYPE),
        choices = {
            GetString(_G.BARSTEWARD_FILLED),
            GetString(_G.BARSTEWARD_EMPTY),
            GetString(_G.BARSTEWARD_BOTH)
        },
        varName = "GemType",
        refresh = true,
        default = GetString(_G.BARSTEWARD_FILLED)
    }
}

local function isSurveyReport(bag, slot)
    local _, specialisedItemType = GetItemType(bag, slot)
    local itemName = GetItemName(bag, slot)

    return specialisedItemType == _G.SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT or
        string.find(string.lower(itemName), string.lower(GetString(_G.SI_CONSTANT_SURVEY_MAP)))
end

local function isTreasureMap(bag, slot)
    local _, specialisedItemType = GetItemType(bag, slot)

    local itemName = GetItemName(bag, slot)
    return specialisedItemType == _G.SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP or
        string.find(string.lower(itemName), string.lower(GetString(_G.SI_CONSTANT_TREASURE_MAP)))
end

local function isMasterWrit(bag, slot)
    local _, specialisedItemType = GetItemType(bag, slot)
    return specialisedItemType == _G.SPECIALIZED_ITEMTYPE_MASTER_WRIT
end

local bagIcon = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds")
local bankIcon = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds")

local function getDetail(bag, slot)
    local wcount = GetSlotStackSize(bag, slot)
    local itemDisplayQuality = GetItemDisplayQuality(bag, slot)
    local colour = GetItemQualityColor(itemDisplayQuality)
    local name = colour:Colorize(GetItemName(bag, slot))

    if (bag == _G.BAG_BACKPACK) then
        name = bagIcon .. " " .. name
    else
        name = bankIcon .. " " .. name
    end

    return name .. ((wcount > 1) and (" (" .. wcount .. ")") or "")
end

local function getWritType(itemId)
    for key, itemIds in pairs(BS.WRITS) do
        for _, id in pairs(itemIds) do
            if (id == itemId) then
                return key
            end
        end
    end

    return 0
end

local function canCraft(know_list)
    for _, t in pairs(know_list) do
        if (t.is_known == false) then
            return "cannotCraft"
        end
    end

    return "canCraft"
end

BS.widgets[BS.W_WRITS_SURVEYS] = {
    -- v1.2.5
    name = "writs",
    update = function(widget, _, _, _, _, _, updateReason)
        if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DEFAULT) then
            local writs = 0
            local surveys = 0
            local maps = 0
            local detail = {}
            local bags = {_G.BAG_BACKPACK, _G.BAG_BANK}
            local writDetail = {}
            local canDo = {}

            if (IsESOPlusSubscriber()) then
                table.insert(bags, _G.BAG_SUBSCRIBER_BANK)
            end

            for _, bag in pairs(bags) do
                for slot = 0, GetBagSize(bag) do
                    if (isMasterWrit(bag, slot)) then
                        writs = writs + 1
                        local type = getWritType(GetItemId(bag, slot))

                        if (type ~= 0) then
                            if (writDetail[type] == nil) then
                                writDetail[type] = {bankCount = 0, bagCount = 0}
                            end

                            local btype = (bag == _G.BAG_BACKPACK) and "bagCount" or "bankCount"

                            writDetail[type][btype] = writDetail[type][btype] + 1

                            if (_G.WritWorthy ~= nil) then
                                if (canDo[type] == nil) then
                                    canDo[type] = {canCraft = 0, cannotCraft = 0}
                                end

                                local _, know_list = _G.WritWorthy.ToMatKnowList(GetItemLink(bag, slot))
                                local doable = canCraft(know_list)

                                canDo[type][doable] = canDo[type][doable] + 1
                            end
                        end
                    end

                    if (isSurveyReport(bag, slot)) then
                        surveys = surveys + GetSlotStackSize(bag, slot)
                        table.insert(detail, getDetail(bag, slot))
                    end

                    if (isTreasureMap(bag, slot)) then
                        maps = maps + GetSlotStackSize(bag, slot)
                        table.insert(detail, getDetail(bag, slot))
                    end
                end
            end

            widget:SetValue(writs .. "/" .. surveys .. "/" .. maps)
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_WRITS_SURVEYS].Colour or BS.Vars.DefaultColour))

            local ttt = GetString(_G.BARSTEWARD_WRITS) .. BS.LF .. "|cf9f9f9"
            ttt = ttt .. zo_strformat(GetString(_G.BARSTEWARD_WRITS_WRITS), writs) .. BS.LF
            ttt = ttt .. zo_strformat(GetString(_G.BARSTEWARD_WRITS_SURVEYS), surveys) .. BS.LF
            ttt = ttt .. zo_strformat(GetString(_G.BARSTEWARD_WRITS_MAPS), maps) .. "|r"

            local writText = {}

            for type, counts in pairs(writDetail) do
                local writType = ZO_CachedStrFormat("<<C:1>>", GetString(_G["SI_TRADESKILLTYPE" .. tostring(type)]))
                if (counts.bagCount > 0) then
                    writType = writType .. " " .. bagIcon .. " " .. counts.bagCount
                end

                if (counts.bankCount > 0) then
                    writType = writType .. " " .. bankIcon .. " " .. counts.bankCount
                end

                if (_G.WritWorthy ~= nil) then
                    local can = canDo[type].canCraft
                    local cant = canDo[type].cannotCraft
                    local canColour = BS.ARGBConvert((can > 0) and BS.Vars.DefaultOkColour or BS.Vars.DefaultColour)
                    local cantColour =
                        BS.ARGBConvert((cant > 0) and BS.Vars.DefaultDangerColour or BS.Vars.DefaultColour)

                    writType = writType .. "   (" .. canColour .. can .. "|r/"
                    writType = writType .. cantColour .. cant .. "|r)"
                end

                table.insert(writText, writType)
            end

            if (#writText > 0) then
                table.sort(writText)
                ttt = ttt .. BS.LF

                for _, d in pairs(writText) do
                    ttt = ttt .. BS.LF .. d
                end
            end

            if (#detail > 0) then
                table.sort(detail)
                ttt = ttt .. BS.LF

                for _, d in pairs(detail) do
                    ttt = ttt .. BS.LF .. d
                end
            end

            widget.tooltip = ttt

            return widget:GetValue()
        end
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "/esoui/art/journal/journal_tabicon_cadwell_up.dds",
    tooltip = GetString(_G.BARSTEWARD_WRITS)
}
