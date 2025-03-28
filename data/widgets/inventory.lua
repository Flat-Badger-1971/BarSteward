local BS = _G.BarSteward

BS.widgets[BS.W_BAG_SPACE] = {
    name = "bagSpace",
    update = function(widget, _, _, _, newItem)
        local this = BS.W_BAG_SPACE
        local bagSize = GetBagSize(BAG_BACKPACK)
        local bagUsed = GetNumBagUsedSlots(BAG_BACKPACK)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Yellow
        local value = bagUsed .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. bagSize)))
        local widthValue = bagUsed .. (BS.GetVar("HideLimit", this) and "" or ("/" .. bagSize))
        local pcUsed = BS.LC.ToPercent(bagUsed, bagSize)
        local colour = BS.GetColour(this, "Ok", true)

        if (pcUsed >= BS.GetVar("WarningValue", this) and pcUsed < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)

            if (BS.GetVar("Announce", this) and newItem) then
                local announce = true
                local previousTime = BS.Vars:GetCommon("PreviousAnnounceTime", this) or (os.time() - 301)
                local debounceTime = (BS.GetVar("DebounceTime", this) or 5) * 60

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                if (announce == true) then
                    BS.Vars:SetCommon(os.time(), "PreviousAnnounceTime", this)
                    BS.Announce(GetString(_G.BARSTEWARD_WARNING), GetString(_G.BARSTEWARD_WARNING_BAGS), this)
                end
            end
        elseif (pcUsed >= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        if (BS.GetVar("MaxValue", this)) then
            if (pcUsed == 100) then
                colour = BS.GetColour(this, "Max", true)
            end
        end

        widget:SetColour(colour)

        if (BS.GetVar("ShowFreeSpace", this)) then
            value =
                (bagSize - bagUsed) .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. bagSize)))
            widthValue = (bagSize - bagUsed) .. (BS.GetVar("HideLimit", this) and "" or ("/" .. bagSize))
        end

        if (BS.GetVar("ShowPercent", this)) then
            value = pcUsed .. "%"
            widthValue = value
        end

        widget:SetValue(value, widthValue)

        return pcUsed
    end,
    event = {
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        EVENT_INVENTORY_BAG_CAPACITY_CHANGED,
        EVENT_INVENTORY_FULL_UPDATE
    },
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    tooltip = BS.LC.Format(SI_GAMEPAD_MAIL_INBOX_INVENTORY):gsub(":", ""),
    icon = "tooltips/icon_bag",
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = { 0, 1, 5, 10, 15, 20, 30, 40, 50, 60 },
        varName = "DebounceTime",
        refresh = false,
        default = 5
    }
}

BS.widgets[BS.W_BANK_SPACE] = {
    name = "bankSpace",
    update = function(widget, eventId, bagId)
        if (eventId == EVENT_INVENTORY_SINGLE_SLOT_UPDATE and bagId ~= BAG_BANK) then
            return
        end

        local this = BS.W_BANK_SPACE
        local bagSize = GetBagSize(BAG_BANK)
        local bagUsed = GetNumBagUsedSlots(BAG_BANK) + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Yellow

        if (IsESOPlusSubscriber()) then
            bagSize = bagSize + GetBagSize(BAG_SUBSCRIBER_BANK)
        end

        local value = bagUsed .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. bagSize)))
        local widthValue = bagUsed .. (BS.GetVar("HideLimit", this) and "" or ("/" .. bagSize))
        local pcUsed = BS.LC.ToPercent(bagUsed, bagSize)
        local colour = BS.GetColour(this, "Ok", true)

        if (pcUsed >= BS.GetVar("WarningValue", this) and pcUsed < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        elseif (pcUsed >= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        if (BS.GetVar("MaxValue", this)) then
            if (pcUsed == 100) then
                colour = BS.GetColour(this, "Max", true)
            end
        end

        widget:SetColour(colour)

        if (BS.GetVar("ShowFreeSpace", this)) then
            value =
                (bagSize - bagUsed) .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. bagSize)))
            widthValue = (bagSize - bagUsed) .. (BS.GetVar("HideLimit", this) and "" or ("/" .. bagSize))
        end

        if (BS.GetVar("ShowPercent", this)) then
            value = pcUsed .. "%"
            widthValue = value
        end

        widget:SetValue(value, widthValue)

        return pcUsed
    end,
    event = {
        EVENT_CLOSE_BANK,
        EVENT_INVENTORY_BAG_CAPACITY_CHANGED,
        EVENT_INVENTORY_BANK_CAPACITY_CHANGED
    },
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    tooltip = GetString(_G.BARSTEWARD_BANK),
    icon = "tooltips/icon_bank"
}

BS.widgets[BS.W_REPAIR_COST] = {
    name = "itemRepairCost",
    update = function(widget, _, _, _, _, _, updateReason)
        if (updateReason == nil or updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
            local this = BS.W_REPAIR_COST
            local repairCost = GetRepairAllCost()

            if (BS.Vars.Controls[this].UseSeparators == true) then
                repairCost = BS.AddSeparators(repairCost)
            end

            widget:SetValue(repairCost)
            widget:SetColour(BS.GetColour(this, true))

            return repairCost
        end

        return widget:GetValue()
    end,
    event = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "ava/ava_resourcestatus_tabicon_defense_inactive",
    tooltip = GetString(_G.BARSTEWARD_REPAIR_COST),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

local ignoreSlots = {
    [EQUIP_SLOT_NECK] = true,
    [EQUIP_SLOT_RING1] = true,
    [EQUIP_SLOT_RING2] = true,
    [EQUIP_SLOT_COSTUME] = true,
    [EQUIP_SLOT_POISON] = true,
    [EQUIP_SLOT_BACKUP_POISON] = true,
    [EQUIP_SLOT_MAIN_HAND] = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
    [EQUIP_SLOT_BACKUP_OFF] = true
}

BS.widgets[BS.W_DURABILITY] = {
    -- v1.0.1
    name = "durability",
    update = function(widget, bagId)
        if (bagId ~= BAG_WORN and bagId ~= "initial") then
            return
        end

        -- find item with lowest durability
        local lowest = 100
        local lowestType = ITEMTYPE_ARMOR
        local items = {}
        local this = BS.W_DURABILITY

        for slot = 0, GetBagSize(BAG_WORN) do
            if (not ignoreSlots[slot]) then
                local colour = BS.GetColour(this, "Ok", true)
                local itemName = ZO_CachedStrFormat("<<C:1>>", GetItemName(BAG_WORN, slot))
                local condition = GetItemCondition(BAG_WORN, slot)

                if (itemName ~= "") then
                    if (condition <= BS.GetVar("OkValue", this) and condition >= BS.GetVar("DangerValue", this)) then
                        colour = BS.GetColour(this, "Warning", true)
                    elseif (condition < BS.GetVar("DangerValue", this)) then
                        colour = BS.GetColour(this, "Danger", true)
                    end

                    table.insert(items, colour:Colorize(string.format("%s - %d%%", itemName, condition)))

                    if (lowest > condition) then
                        lowest = condition
                        lowestType = GetItemType(BAG_WORN, slot)
                    end
                end
            end
        end

        widget:SetValue(lowest .. "%")

        local colour

        if (lowest >= BS.GetVar("OkValue", this)) then
            colour = BS.GetColour(this, "Ok", true)
        elseif (BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        else
            colour = BS.GetColour(this, "Danger", true)
        end

        widget:SetColour(colour)

        if (lowest <= BS.GetVar("DangerValue", this)) then
            if (lowestType == ITEMTYPE_WEAPON) then
                widget:SetIcon("hud/broken_weapon")
            else
                widget:SetIcon("hud/broken_armor")
            end
        else
            widget:SetIcon("inventory/inventory_tabicon_armor_up")
        end

        if (#items > 0) then
            local tooltipText = GetString(_G.BARSTEWARD_DURABILITY)

            for _, i in ipairs(items) do
                tooltipText = tooltipText .. BS.LF .. i
            end

            widget:SetTooltip(tooltipText)
        end

        return lowest
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = "inventory/inventory_tabicon_armor_up",
    tooltip = GetString(_G.BARSTEWARD_DURABILITY),
    onLeftClick = function()
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
        local this = BS.W_REPAIRS_KITS

        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return IsItemRepairKit(itemdata.bagId, itemdata.slotIndex)
                end,
                BAG_BACKPACK
            )

        for _, item in ipairs(filteredItems) do
            count = count + item.stackCount
        end

        local colour = BS.GetColour(this, "Ok", true)

        if (count < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        elseif (count < BS.GetVar("WarningValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        end

        widget:SetColour(colour)
        widget:SetValue(count)

        return count
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = function()
        if (BS.GetVar("UseAlternate", BS.W_REPAIRS_KITS)) then
            return "lfg/lfg_bonus_crate"
        else
            return "vendor/vendor_tabicon_repair_up"
        end
    end,
    tooltip = BS.LC.Format(SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER):gsub(":", ""),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_ALTERNATE),
            getFunc = function()
                return BS.GetVar("UseAlternate", BS.W_REPAIR_KITS)
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_REPAIRS_KITS].UseAlternate = value
                BS.RefreshWidget(BS.W_REPAIRS_KITS, true)
            end,
            width = "full",
            default = false
        }
    }
}

local filledIcon = "icons/soulgem_006_filled"
local emptyIcon = "icons/soulgem_006_empty"

BS.widgets[BS.W_SOUL_GEMS] = {
    -- v1.2.0
    name = "soulGems",
    update = function(widget)
        local this = BS.W_SOUL_GEMS
        local level = GetUnitEffectiveLevel("player")
        local filledCount = select(3, GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, level, false))
        local emptyCount = select(3, GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, level, false))

        if (BS.GetVar("UseSeparators", this) == true) then
            filledCount = BS.AddSeparators(filledCount)
            emptyCount = BS.AddSeparators(emptyCount)
        end

        local displayValue = filledCount
        local widthValue = filledCount
        local displayIcon = filledIcon
        local both = BS.COLOURS.Green:Colorize(filledCount) .. "/" .. emptyCount

        if (BS.GetVar("GemType", this) == GetString(_G.BARSTEWARD_EMPTY)) then
            displayValue = emptyCount
            widthValue = emptyCount
            displayIcon = emptyIcon
        elseif (BS.GetVar("GemType", this) == GetString(_G.BARSTEWARD_BOTH)) then
            displayValue = both
            widthValue = filledCount .. "/" .. emptyCount
        end

        widget:SetColour(BS.GetColour(this, true))
        widget:SetValue(displayValue, widthValue)
        widget:SetIcon(displayIcon)

        -- update the tooltip
        local ttt = GetString(_G.BARSTEWARD_SOUL_GEMS) .. BS.LF
        ttt = ttt .. BS.Icon(filledIcon) .. " " .. filledCount .. BS.LF
        ttt = ttt .. BS.Icon(emptyIcon) .. " " .. emptyCount

        widget:SetTooltip(ttt)

        return widget:GetValue()
    end,
    event = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "icons/soulgem_006_filled",
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

local function getDetail(data)
    local wcount = data.stackCount
    local colour = GetItemQualityColor(data.displayQuality)
    local name = colour:Colorize(BS.LC.Format(data.name))

    if (data.bagId == BAG_BACKPACK) then
        name = BS.BAGICON .. " " .. name
    else
        name = BS.BANKICON .. " " .. name
    end

    return name .. ((wcount > 1) and (" (" .. wcount .. ")") or "")
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
    update = function(widget)
        local writs = 0
        local surveys = 0
        local maps = 0
        local detail = {}
        local bags = { BAG_BACKPACK, BAG_BANK }
        local writDetail = {}
        local canDo = {}
        local wwCache = {}
        local useWW = (_G.WritWorthy ~= nil) and (BS.Vars.UseWritWorthy == true)

        if (IsESOPlusSubscriber()) then
            table.insert(bags, BAG_SUBSCRIBER_BANK)
        end

        for _, bag in pairs(bags) do
            ---@diagnostic disable-next-line: undefined-field
            for _, data in pairs(_G.SHARED_INVENTORY.bagCache[bag]) do
                if (data.specializedItemType == SPECIALIZED_ITEMTYPE_MASTER_WRIT) then
                    writs = writs + 1
                    local itemId = GetItemId(bag, data.slotIndex)
                    local type = BS.GetWritType(itemId)

                    if (type ~= 0) then
                        if (writDetail[type] == nil) then
                            writDetail[type] = { bankCount = 0, bagCount = 0 }
                        end

                        local btype = (bag == BAG_BACKPACK) and "bagCount" or "bankCount"

                        writDetail[type][btype] = writDetail[type][btype] + 1

                        if (useWW) then
                            if (canDo[type] == nil) then
                                canDo[type] = { canCraft = 0, cannotCraft = 0 }
                            end

                            local know_list

                            if (wwCache[itemId]) then
                                know_list = wwCache[itemId]
                            else
                                local link = GetItemLink(bag, data.slotIndex, LINK_STYLE_DEFAULT)
                                _, know_list = _G.WritWorthy.ToMatKnowList(link)
                                wwCache[itemId] = know_list
                            end

                            local doable = canCraft(know_list)

                            canDo[type][doable] = canDo[type][doable] + 1
                        end
                    end
                end

                if (data.specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) then
                    surveys = surveys + data.stackCount
                    table.insert(detail, getDetail(data))
                end

                if (data.specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP) then
                    maps = maps + data.stackCount
                    table.insert(detail, getDetail(data))
                end
            end
        end

        widget:SetValue(writs .. "/" .. surveys .. "/" .. maps)
        widget:SetColour(BS.GetColour(BS.W_WRITS_SURVEYS, true))

        local wwText = ""

        if (useWW) then
            local can = 0
            local cant = 0
            for _, d in pairs(canDo) do
                can = can + d.canCraft
                cant = cant + d.cannotCraft
            end

            local canColour = (can > 0) and BS.COLOURS.DefaultOkColour or BS.COLOURS.DefaultColour
            local cantColour = (cant > 0) and BS.COLOURS.DefaultDangerColour or BS.COLOURS.DefaultColour

            wwText = "   (" .. canColour:Colorize(can) .. "/"
            wwText = wwText .. cantColour:Colorize(cant) .. ")"
        end

        local ttt = GetString(_G.BARSTEWARD_WRITS) .. BS.LF
        local ttext = zo_strformat(GetString(_G.BARSTEWARD_WRITS_WRITS), writs) .. wwText .. BS.LF

        ttext = ttext .. zo_strformat(GetString(_G.BARSTEWARD_WRITS_SURVEYS), surveys) .. BS.LF
        ttext = ttext .. zo_strformat(GetString(_G.BARSTEWARD_WRITS_MAPS), maps)

        ttt = ttt .. BS.COLOURS.White:Colorize(ttext)

        local writText = {}

        for type, counts in pairs(writDetail) do
            local writType = BS.LC.Format(GetString("SI_TRADESKILLTYPE", type))

            if (counts.bagCount > 0) then
                writType = string.format("%s %s %d", writType, BS.BAGICON, counts.bagCount)
            end

            if (counts.bankCount > 0) then
                writType = string.format("%s %s %d", writType, BS.BANKICON, counts.bankCount)
            end

            if (useWW) then
                local can = canDo[type].canCraft
                local cant = canDo[type].cannotCraft
                local canColour = (can > 0) and BS.COLOURS.DefaultOkColour or BS.COLOURS.DefaultColour
                local cantColour = (cant > 0) and BS.COLOURS.DefaultDangerColour or BS.COLOURS.DefaultColour

                writType = string.format("%s   (%s/", writType, canColour:Colorize(can))
                writType = string.format("%s%s)", writType, cantColour:Colorize(cant))
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
                ttt = string.format("%s%s%s", ttt, BS.LF, d)
            end
        end

        widget:SetTooltip(ttt)

        return widget:GetValue()
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = "journal/journal_tabicon_cadwell_up",
    tooltip = GetString(_G.BARSTEWARD_WRITS),
    customSettings = {
        [1] = {
            name = GetString(_G.BARSTEWARD_USE_WRITWORTHY),
            tooltip = GetString(_G.BARSTEWARD_USE_WRITWORTHY_TOOLTIP),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.UseWritWorthy or false
            end,
            setFunc = function(value)
                BS.Vars.UseWritWorthy = value
                BS.RefreshWidget(BS.W_WRITS_SURVEYS)
            end,
            disabled = function()
                return _G.WritWorthy == nil
            end
        }
    }
}

BS.widgets[BS.W_LOCKPICKS] = {
    -- v1.2.15
    name = "lockpicks",
    update = function(widget)
        local available = GetNumLockpicksLeft()
        local this = BS.W_LOCKPICKS
        local colour = BS.GetColour(this, "Ok", true)

        if (available <= BS.GetVar("WarningValue", this) and available > BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        elseif (available <= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        widget:SetColour(colour)
        widget:SetValue(available)

        return available
    end,
    event = { EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EVENT_LOCKPICK_BROKE },
    tooltip = BS.LC.Format(SI_GAMEPAD_LOCKPICK_PICKS_REMAINING),
    icon = "icons/lockpick"
}

local linkCache = {}
local previousCounts = {}
local DEBUG = false

BS.widgets[BS.W_WATCHED_ITEMS] = {
    -- v1.3.14
    name = "itemWatcher",
    update = function(widget)
        local this = BS.W_WATCHED_ITEMS
        local itemIds = BS.Vars:GetCommon("WatchedItems")

        for itemId, _ in pairs(itemIds) do
            if (not linkCache[itemId]) then
                local link = BS.LC.MakeItemLink(itemId)
                local name = GetItemLinkName(link)

                if (name ~= "") then
                    linkCache[itemId] = {
                        icon = GetItemLinkIcon(link),
                        name = BS.LC.Format(name)
                    }
                end
            end
        end

        local count = {}
        local bags = { BAG_BACKPACK, BAG_BANK }
        local keys = { bag = {}, bank = {} }

        if (IsESOPlusSubscriber()) then
            table.insert(bags, BAG_SUBSCRIBER_BANK)
        end

        if (HasCraftBagAccess()) then
            table.insert(bags, BAG_VIRTUAL)
        end

        for _, bag in pairs(bags) do
            for _, data in pairs(_G.SHARED_INVENTORY.bagCache[bag]) do
                if (data) then
                    local itemId = GetItemId(bag, data.slotIndex)

                    if (itemIds[itemId]) then
                        if (linkCache[itemId]) then
                            local cnt = data.stackCount

                            if (not count[itemId]) then
                                count[itemId] = 0
                            end

                            count[itemId] = count[itemId] + cnt

                            local location = bag == BAG_BANK and "bank" or "bag"

                            if (not keys[location][itemId]) then
                                local icon = linkCache[itemId].icon
                                local name = linkCache[itemId].name
                                local displayQuality = select(9, GetItemInfo(bag, data.slotIndex))
                                local colour = GetItemQualityColor(displayQuality)

                                keys[location][itemId] = {
                                    count = cnt,
                                    name = name,
                                    icon = icon,
                                    bag = bag,
                                    colour = colour
                                }
                            else
                                keys[location][itemId].count = keys[location][itemId].count + cnt
                            end
                        end
                    end
                end
            end
        end

        local ttt = GetString(_G.BARSTEWARD_WATCHED_ITEMS) .. BS.LF
        local countText = ""
        local plainCountText = ""
        local foundIds = {}

        for _, bagType in pairs({ "bag", "bank" }) do
            for itemId, key in pairs(keys[bagType]) do
                local zoIcon = BS.Icon(key.icon)

                foundIds[itemId] = true

                ttt = ttt .. BS.LF
                ttt = ttt .. (bagType == "bag" and BS.BAGICON or BS.BANKICON)
                ttt = ttt .. " " .. zoIcon .. " " .. (key.colour or BS.COLOURS.White):Colorize(key.name)
                ttt = ttt .. " (" .. key.count .. ")"
            end
        end

        if (not widget:HasNoValue()) then
            local barNumber = BS.GetVar("Bar", this)
            local iconSize =
                BS.Vars.Bars[barNumber].Override and (BS.Vars.Bars[barNumber].IconSize or BS.GetVar("IconSize")) or
                BS.GetVar("IconSize")
            local minSizeNumChars = math.ceil(iconSize / 8)
            local minSize = string.rep("_", minSizeNumChars)

            for itemId, data in pairs(linkCache) do
                if (itemIds[itemId]) then
                    local itemCount = count[itemId] or 0

                    if (DEBUG) then
                        itemCount = 100
                    end

                    local countItem = BS.Icon(data.icon, nil, iconSize, iconSize)

                    countText = countText .. countItem .. " " .. itemCount .. " "
                    plainCountText = plainCountText .. minSize .. " " .. itemCount .. " "

                    if (not foundIds[itemId]) then
                        local zoIcon = BS.Icon(data.icon)

                        ttt = ttt .. BS.LF .. BS.BAGICON .. " " .. zoIcon .. " "
                        ttt = ttt .. (data.colour or BS.COLOURS.White):Colorize(data.name) .. " (0)"
                    end
                end
            end

            widget:SetColour(BS.GetColour(this, true))
            widget:SetValue(BS.LC.Trim(countText), BS.LC.Trim(plainCountText))
        end

        widget:SetTooltip(ttt)

        BS.ResizeBar(BS.GetVar("Bar", this))

        if (BS.GetVar("Announce", this)) then
            for itemId, itemCount in pairs(count) do
                if (not previousCounts[itemId]) then
                    previousCounts[itemId] = itemCount
                end

                if (itemCount > previousCounts[itemId]) then
                    local announce = true
                    local previousTime = BS.Vars:GetCommon("PreviousAnnounceTime", this) or (os.time() - 301)
                    local debounceTime = (BS.GetVar("DebounceTime", this) or 5) * 60

                    if (os.time() - previousTime <= debounceTime) then
                        announce = false
                    end

                    if (announce == true) then
                        BS.Vars:SetCommon(os.time(), "PreviousAnnounceTime", this)

                        -- need a short delay so the announcement doesn't get quashed by any animations
                        if (itemId == BS.PERFECT_ROE) then
                            BS.delayedAnnouncement = {
                                message = zo_strformat(
                                    GetString(_G.BARSTEWARD_WATCHED_ITEM_MESSAGE),
                                    linkCache[itemId].name
                                ),
                                icon = linkCache[itemId].icon
                            }
                            zo_callLater(
                                function()
                                    BS.Announce(
                                        GetString(_G.BARSTEWARD_WATCHED_ITEM_ALERT),
                                        BS.delayedAnnouncement.message,
                                        this,
                                        nil,
                                        nil,
                                        BS.delayedAnnouncement.icon
                                    )
                                end,
                                2000
                            )
                        else
                            BS.Announce(
                                GetString(_G.BARSTEWARD_WATCHED_ITEM_ALERT),
                                zo_strformat(GetString(_G.BARSTEWARD_WATCHED_ITEM_MESSAGE), linkCache[itemId].name),
                                this,
                                nil,
                                nil,
                                linkCache[itemId].icon
                            )
                        end
                    end
                end

                previousCounts[itemId] = itemCount
            end
        end

        return count
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    tooltip = GetString(_G.BARSTEWARD_WATCHED_ITEMS),
    icon = "icons/crafting_critter_snake_eyes",
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = { 0, 1, 5, 10, 15, 20, 30, 40, 50, 60 },
        varName = "DebounceTime",
        refresh = false,
        default = 5
    },
    customSettings = function()
        local settings
        local this = BS.W_WATCHED_ITEMS
        local itemIds = BS.Vars:GetCommon("WatchedItems")
        local vars = BS.Vars.Controls[this]

        settings = {}

        for itemId, _ in pairs(itemIds) do
            if (not linkCache[itemId]) then
                local link = BS.LC.MakeItemLink(itemId)
                local name = GetItemLinkName(link)

                if (name ~= "") then
                    linkCache[itemId] = {
                        icon = GetItemLinkIcon(link),
                        name = BS.LC.Format(name)
                    }
                end
            end
        end

        for itemId, data in pairs(linkCache) do
            if (data.name ~= "") then
                settings[#settings + 1] = {
                    name = function()
                        local name = BS.Icon(data.icon) .. " " .. data.name

                        if (BS.CommonDefaults.WatchedItems[itemId] == nil) then
                            name = name .. " (" .. itemId .. ")"
                        end

                        return name
                    end,
                    type = "checkbox",
                    getFunc = function()
                        return BS.Vars:GetCommon("WatchedItems", itemId)
                    end,
                    setFunc = function(value)
                        BS.Vars:SetCommon(value, "WatchedItems", itemId)
                        BS.RefreshWidget(BS.W_WATCHED_ITEMS)
                        BS.ResizeBar(vars.Bar)
                    end,
                    default = true
                }
            end
        end

        settings[#settings + 1] = {
            type = "editbox",
            name = GetString(_G.BARSTEWARD_ITEM_ID),
            getFunc = function()
                return BS.Vars.NewItemId or ""
            end,
            setFunc = function(value)
                BS.Vars.NewItemId = value
            end,
            isMultiLine = false,
            width = "full"
        }

        settings[#settings + 1] = {
            type = "description",
            text = function()
                if (BS.Vars.NewItemId == "") then
                    return ""
                end

                local link = BS.LC.MakeItemLink(BS.Vars.NewItemId)
                local name = GetItemLinkName(link)

                if (name ~= "") then
                    local icon = GetItemLinkIcon(link)
                    name = BS.Icon(icon) .. " " .. BS.LC.Format(name)
                end

                return name
            end,
            width = "full"
        }

        settings[#settings + 1] = {
            type = "button",
            name = BS.LC.Format(SI_GAMEPAD_TRADE_ADD),
            func = function()
                if (BS.Vars:GetCommon("WatchedItems", tonumber(BS.Vars.NewItemId)) == nil) then
                    BS.Vars:SetCommon(true, "WatchedItems", tonumber(BS.Vars.NewItemId))
                    BS.Vars.NewItemId = nil

                    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
                else
                    ZO_Dialogs_ShowDialog(BS.Name .. "ItemExists")
                end
            end,
            disabled = function()
                if (BS.Vars.NewItemId == "") then
                    return true
                end

                local link = BS.LC.MakeItemLink(BS.Vars.NewItemId)
                local name = GetItemLinkName(link)

                return name == ""
            end,
            width = "half"
        }

        settings[#settings + 1] = {
            type = "button",
            name = BS.LC.Format(SI_DIALOG_REMOVE),
            func = function()
                BS.Vars:SetCommon(nil, "WatchedItems", tonumber(BS.Vars.NewItemId))
                BS.Vars.NewItemId = nil

                ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
            end,
            disabled = function()
                if (BS.Vars.NewItemId == "") then
                    return true
                end

                local link = BS.LC.MakeItemLink(BS.Vars.NewItemId)
                local name = GetItemLinkName(link)

                return name == ""
            end,
            width = "half"
        }

        return settings
    end
}

local mementos = {}
local pets = {}
local mounts = {}
local emotes = {}

-- based on code from RandomMount
local function scanCategoryData(categoryData, collectibleType, collectibleTable, toTable, includeAll)
    local numCollectibles = categoryData:GetNumCollectibles()

    for collectibleIndex = 1, numCollectibles do
        local collectibleData = categoryData:GetCollectibleDataByIndex(collectibleIndex)

        if (collectibleData:IsUnlocked() or includeAll) then
            local categoryType = collectibleData:GetCategoryType()

            if (categoryType == collectibleType) then
                local id = collectibleData:GetId()

                if (toTable) then
                    local combinationId = GetCollectibleReferenceId(id)
                    local combinedCollectibleId = GetCombinationUnlockedCollectible(combinationId)
                    local unlocked = select(5, GetCollectibleInfo(combinedCollectibleId))

                    table.insert(
                        collectibleTable,
                        {
                            id = id,
                            unlocked = collectibleData:IsUnlocked(),
                            name = BS.LC.Format(collectibleData:GetName()),
                            combinedId = combinedCollectibleId,
                            combinationUnlocked = unlocked
                        }
                    )
                else
                    table.insert(collectibleTable, id)
                end
            end
        end
    end
end

local function getCollectibles(collectibleType, collectibleTable, toTable, includeAll)
    ZO_ClearNumericallyIndexedTable(collectibleTable)

    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataByIndicies(categoryIndex)
        local numSubcategories = categoryData:GetNumSubcategories()

        if (numSubcategories == 0) then
            scanCategoryData(categoryData, collectibleType, collectibleTable, toTable, includeAll)
        else
            for subcategoryIndex = 1, numSubcategories do
                local subcategoryData = categoryData:GetSubcategoryData(subcategoryIndex)

                if (subcategoryData) then
                    scanCategoryData(subcategoryData, collectibleType, collectibleTable, toTable, includeAll)
                end
            end
        end
    end
end

local function getEmotes()
    ZO_ClearNumericallyIndexedTable(emotes)

    local categories = PLAYER_EMOTE_MANAGER:GetEmoteCategories()

    for _, category in ipairs(categories) do
        local emotesInCategory = PLAYER_EMOTE_MANAGER:GetEmoteListForType(category)

        for _, emote in ipairs(emotesInCategory) do
            table.insert(emotes, emote)
        end
    end
end

local function randomOnLeftClick(collectibleTable, widgetIndex)
    if (#collectibleTable == 0) then
        return
    end

    local usable
    local tryCount = 0
    local collectibleId

    repeat
        local collectibleIndex = math.random(1, #collectibleTable)

        collectibleId = collectibleTable[collectibleIndex]
        tryCount = tryCount + 1

        usable = IsCollectibleUsable(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    until (usable == true or tryCount == 10)

    if (usable) then
        local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[widgetIndex])
        local name = BS.LC.Format(GetCollectibleName(collectibleId))

        local tt = BS.widgets[widgetIndex].tooltip .. BS.LF

        tt = tt .. BS.COLOURS.White:Colorize(GetString(_G.BARSTEWARD_RANDOM_RECENT)) .. BS.LF
        tt = tt .. BS.COLOURS.ZOSGold:Colorize(name)

        widget:SetTooltip(tt)

        UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

        if (BS.GetVar("Print", widgetIndex)) then
            local output = BS.COLOURS.ZOSGold:Colorize("Bar Steward") .. ": " .. name

            CHAT_ROUTER:AddSystemMessage(output)
        end

        zo_callLater(
            function()
                local remaining, duration = GetCollectibleCooldownAndDuration(collectibleId)

                widget:StartCooldown(remaining, duration)
            end,
            200
        )
    end
end

BS.widgets[BS.W_RANDOM_MEMENTO] = {
    -- v1.4.7
    name = "randomMemento",
    update = function(widget, event)
        if (#mementos == 0 or event == EVENT_COLLECTION_UPDATED) then
            getCollectibles(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, mementos)
        end

        widget:SetValue(BS.Icon("buttons/pointsplus_highlight"), "___")

        return 0
    end,
    event = EVENT_COLLECTION_UPDATED,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_MEMENTO),
    icon = "icons/collectible_memento_blizzard",
    cooldown = true,
    onLeftClick = function()
        randomOnLeftClick(mementos, BS.W_RANDOM_MEMENTO)
    end
}

BS.widgets[BS.W_RANDOM_PET] = {
    -- v1.4.7
    name = "randomPet",
    update = function(widget, event)
        if (#pets == 0 or event == EVENT_COLLECTION_UPDATED) then
            getCollectibles(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, pets)
        end

        widget:SetValue(BS.Icon("buttons/pointsplus_highlight"), "___")

        return 0
    end,
    event = EVENT_COLLECTION_UPDATED,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_PET),
    icon = "icons/pet_sphynxlynx",
    cooldown = true,
    onLeftClick = function()
        randomOnLeftClick(pets, BS.W_RANDOM_PET)
    end
}

BS.widgets[BS.W_RANDOM_MOUNT] = {
    -- v1.4.7
    name = "randomMount",
    update = function(widget, event)
        if (#mounts == 0 or event == EVENT_COLLECTION_UPDATED) then
            getCollectibles(COLLECTIBLE_CATEGORY_TYPE_MOUNT, mounts)
        end

        widget:SetValue(BS.Icon("buttons/pointsplus_highlight"), "___")

        return 0
    end,
    event = EVENT_COLLECTION_UPDATED,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_MOUNT),
    icon = "collections/random_anymount",
    onLeftClick = function()
        randomOnLeftClick(mounts, BS.W_RANDOM_MOUNT)
    end
}

BS.widgets[BS.W_RANDOM_EMOTE] = {
    -- v1.4.7
    name = "randomEmote",
    update = function(widget, event)
        if (#emotes == 0 or event == EVENT_COLLECTION_UPDATED) then
            getEmotes()
        end

        widget:SetValue(BS.Icon("buttons/pointsplus_highlight"), "___")

        return 0
    end,
    event = EVENT_COLLECTION_UPDATED,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_EMOTE),
    icon = "icons/emotes/emotecategoryicon_fidget_personality",
    onLeftClick = function()
        if (#emotes == 0) then
            return
        end

        local tryCount = 0
        local displayName
        local emoteIndex

        repeat
            local emoteId = math.random(1, #emotes)
            emoteIndex = emotes[emoteId]

            displayName = select(4, GetEmoteInfo(emoteIndex))

            local collectibleId = GetEmoteCollectibleId(emoteIndex)

            if (not IsCollectibleUnlocked(collectibleId)) then
                displayName = ""
            end

            tryCount = tryCount + 1
        until (displayName ~= "" or tryCount == 30)

        if (displayName ~= "") then
            PlayEmoteByIndex(emoteIndex)

            local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[BS.W_RANDOM_EMOTE])
            local tt = BS.widgets[BS.W_RANDOM_EMOTE].tooltip .. BS.LF

            tt = tt .. BS.COLOURS.White:Colorize(GetString(_G.BARSTEWARD_RANDOM_RECENT)) .. BS.LF
            tt = tt .. BS.COLOURS.ZOSGold:Colorize(displayName)

            widget:SetTooltip(tt)

            if (BS.Vars.Controls[BS.W_RANDOM_EMOTE].Print) then
                local name = BS.LC.Format(displayName)
                local output = BS.COLOURS.ZOSGold:Colorize("Bar Steward") .. ": " .. name

                CHAT_ROUTER:AddSystemMessage(output)
            end
        end
    end
}

local function itemScan(widget, filteredItems, widgetIndex, name)
    local items = {}
    local count = 0

    for _, item in ipairs(filteredItems) do
        local colour = GetItemQualityColor(item.displayQuality)
        local filteredName = colour:Colorize(item.name)

        if (IsItemStolen(item.bagId, item.slotIndex)) then
            filteredName = BS.Icon("inventory/inventory_stolenitem_icon") .. " " .. filteredName
        end

        if (not items[filteredName]) then
            items[filteredName] = 0
        end

        items[filteredName] = items[filteredName] + item.stackCount
        count = count + item.stackCount
    end

    widget:SetColour(BS.GetColour(widgetIndex, true))
    widget:SetValue(count)

    local tt = name

    if (count > 0) then
        for itemName, qty in pairs(items) do
            local ttext = itemName

            if (qty > 1) then
                ttext = ttext .. " " .. "(" .. qty .. ")"
            end

            tt = tt .. BS.LF .. BS.COLOURS.White:Colorize(ttext)
        end
    end

    widget:SetTooltip(tt)

    return count
end

BS.widgets[BS.W_CONTAINERS] = {
    -- v1.4.12
    name = "containerCount",
    update = function(widget)
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return itemdata.itemType == ITEMTYPE_CONTAINER
                end,
                BAG_BACKPACK
            )

        return itemScan(widget, filteredItems, BS.W_CONTAINERS, BS.LC.Format(SI_ITEMTYPEDISPLAYCATEGORY26))
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = "icons/mail_armor_container",
    tooltip = BS.LC.Format(SI_ITEMTYPEDISPLAYCATEGORY26),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_TREASURE] = {
    -- v1.4.13
    name = "treasureCount",
    update = function(widget)
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return itemdata.itemType == ITEMTYPE_TREASURE
                end,
                BAG_BACKPACK
            )

        return itemScan(widget, filteredItems, BS.W_TREASURE, BS.LC.Format(SI_ITEMTYPE56))
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = "icons/quest_strosmkai_open_treasure_chest",
    tooltip = BS.LC.Format(SI_ITEMTYPE56),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_FURNISHINGS] = {
    -- v1.4.33
    name = "furnishingCount",
    update = function(widget)
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return IsItemPlaceableFurniture(itemdata.bagId, itemdata.slotIndex)
                end,
                BAG_BACKPACK
            )

        return itemScan(widget, filteredItems, BS.W_FURNISHINGS, BS.LC.Format(SI_ITEMFILTERTYPE21))
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate" } },
    icon = "icons/servicemappins/servicepin_furnishings",
    tooltip = BS.LC.Format(SI_ITEMFILTERTYPE21),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_COMPANION_GEAR] = {
    -- v1.4.33
    name = "companionGearCount",
    update = function(widget)
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    local filterTypes = { GetItemFilterTypeInfo(itemdata.bagId, itemdata.slotIndex) }

                    return ZO_IsElementInNumericallyIndexedTable(filterTypes, ITEMFILTERTYPE_COMPANION)
                end,
                BAG_BACKPACK
            )

        return itemScan(widget, filteredItems, BS.W_COMPANION_GEAR, BS.LC.Format(SI_ITEMFILTERTYPE27))
    end,
    event = EVENT_PLAYER_ACTIVATED,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate" } },
    icon = "inventory/inventory_trait_companionequipment_icon",
    tooltip = BS.LC.Format(SI_ITEMFILTERTYPE27),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_MUSEUM] = {
    -- v1.4.33
    name = "museumCount",
    update = function(widget)
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    local _, specialType = GetItemType(itemdata.bagId, itemdata.slotIndex)

                    return specialType == SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE
                end,
                BAG_BACKPACK
            )

        return itemScan(widget, filteredItems, BS.W_MUSEUM, BS.LC.Format(SI_SPECIALIZEDITEMTYPE103))
    end,
    event = EVENT_PLAYER_ACTIVATED,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate" } },
    icon = "icons/servicemappins/servicepin_museum",
    tooltip = BS.LC.Format(SI_SPECIALIZEDITEMTYPE103),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

local poisonBars = {
    [BS.MAIN_BAR] = GetString(_G.BARSTEWARD_MAIN_BAR),
    [BS.BACK_BAR] = GetString(_G.BARSTEWARD_BACK_BAR),
    [BS.BOTH] = GetString(_G.BARSTEWARD_BOTH),
    [BS.ACTIVE_BAR] = GetString(_G.BARSTEWARD_ACTIVE_BAR)
}

BS.widgets[BS.W_EQUIPPED_POISON] = {
    -- v1.4.35
    name = "equippedPoison",
    update = function(widget)
        local main = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
        local backup = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }
        local slots = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
        local poisons = {}
        local hasPoison, poisonCount, poisonName, icon, link
        local count = 0
        local this = BS.W_EQUIPPED_POISON
        local selected = BS.GetVar("PoisonBar", this) or BS.MAIN_BAR
        local activeWeaponPair = GetActiveWeaponPairInfo()

        if (selected == BS.BACK_BAR) then
            slots = backup
        elseif (selected == BS.BOTH) then
            slots = BS.LC.MergeTables(slots, backup)
        elseif (selected == BS.ACTIVE_BAR) then
            if (activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP) then
                slots = backup
            end
        end

        local foundMain, foundBack, add

        for _, slot in ipairs(slots) do
            hasPoison, poisonCount, poisonName, link = GetItemPairedPoisonInfo(slot)
            icon = GetItemLinkInfo(link)
            add = false

            if (hasPoison) then
                if (ZO_IsElementInNumericallyIndexedTable(main, slot)) then
                    if (not foundMain) then
                        add = true
                        foundMain = true
                    end
                elseif (ZO_IsElementInNumericallyIndexedTable(backup, slot)) then
                    if (not foundBack) then
                        add = true
                        foundBack = true
                    end
                end

                if (add) then
                    table.insert(poisons, { name = poisonName, count = poisonCount, slot = slot, icon = icon })
                    count = count + poisonCount
                end
            end
        end

        local colour = BS.GetColour(this, "Ok", true)

        if (count <= BS.GetVar("WarningValue", this) and count > BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        elseif (count <= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        widget:SetColour(colour)
        widget:SetValue(count)

        local tt = GetString(_G.BARSTEWARD_EQUIPPED_POISON)

        if (#poisons > 0) then
            for _, poison in ipairs(poisons) do
                local slotName =
                    ZO_IsElementInNumericallyIndexedTable(backup, poison.slot) and GetString(_G.BARSTEWARD_BACK_BAR) or
                    GetString(_G.BARSTEWARD_MAIN_BAR)

                tt = string.format("%s%s%s ", tt, BS.LF, BS.Icon(poison.icon))
                tt = string.format("%s%s %s (%d)", tt, BS.COLOURS.White:Colorize(poison.name), slotName, poison.count)

                if (selected == BS.ACTIVE_BAR) then
                    if
                        ((ZO_IsElementInNumericallyIndexedTable(backup, poison.slot) and
                                activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP) or
                            (ZO_IsElementInNumericallyIndexedTable(slots, poison.slot) and
                                (activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN)))
                    then
                        widget:SetIcon(poison.icon)
                    end
                elseif (selected == BS.BACK_BAR) then
                    if (ZO_IsElementInNumericallyIndexedTable(backup, poison.slot)) then
                        widget:SetIcon(poison.icon)
                    end
                else
                    if (ZO_IsElementInNumericallyIndexedTable(slots, poison.slot)) then
                        widget:SetIcon(poison.icon)
                    end
                end
            end
        end

        widget:SetTooltip(tt)

        return count
    end,
    callback = { [CALLBACK_MANAGER] = { "WornSlotUpdate" } },
    event = EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
    tooltip = GetString(_G.BARSTEWARD_EQUIPPED_POISON),
    icon = "icons/crafting_poison_001_cyan_003",
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end,
    customSettings = {
        [1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_DISPLAY),
            choices = poisonBars,
            getFunc = function()
                return poisonBars[BS.Vars.Controls[BS.W_EQUIPPED_POISON].PoisonBar or BS.MAIN_BAR]
            end,
            setFunc = function(value)
                local index = BS.LC.GetByValue(poisonBars, value)
                BS.Vars.Controls[BS.W_EQUIPPED_POISON].PoisonBar = index

                BS.RefreshWidget(BS.W_EQUIPPED_POISON)
            end,
            width = "full",
            default = BS.MAIN_BAR
        }
    }
}

BS.widgets[BS.W_FRAGMENTS] = {
    -- v1.4.49
    name = "fragments",
    update = function(widget)
        local this = BS.W_FRAGMENTS
        local collected, uncollected = 0, 0
        local unnecessary = 0
        local fragmentInfo = {}
        local frags = {}

        getCollectibles(COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT, frags, true, true)

        for _, fragmentData in ipairs(frags) do
            BS.CollectibleId = fragmentData.id
            if (not fragmentInfo[fragmentData.combinedId]) then
                fragmentInfo[fragmentData.combinedId] = { collected = 0, uncollected = 0, unnecessary = 0 }
            end

            if (not fragmentData.combinationUnlocked) then
                if (fragmentData.unlocked) then
                    fragmentInfo[fragmentData.combinedId].collected =
                        fragmentInfo[fragmentData.combinedId].collected + 1
                    collected = collected + 1
                else
                    fragmentInfo[fragmentData.combinedId].uncollected =
                        fragmentInfo[fragmentData.combinedId].uncollected + 1
                    uncollected = uncollected + 1
                end
            elseif (fragmentData.unlocked) then
                fragmentInfo[fragmentData.combinedId].unnecessary =
                    fragmentInfo[fragmentData.combinedId].unnecessary + 1
                unnecessary = unnecessary + 1
            else
                fragmentInfo[fragmentData.combinedId].uncollected =
                    fragmentInfo[fragmentData.combinedId].uncollected + 1
                uncollected = uncollected + 1
            end
        end

        local text = collected .. "/" .. (collected + uncollected)
        local plainText = text

        if (unnecessary > 0) then
            plainText = text .. "/" .. unnecessary
            text = text .. "/" .. BS.COLOURS.Yellow:Colorize(unnecessary)
        end

        widget:SetValue(text, plainText)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_COLLECTIBLE_FRAGMENTS)
        local collectedtt = ""
        local unnecessarytt = ""
        local uncollectedtt = ""
        local fragmentsForDisplay = {}

        for id, info in pairs(fragmentInfo) do
            local data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id)

            if ((not data:IsUnlocked()) or info.unnecessary > 0) then
                table.insert(
                    fragmentsForDisplay,
                    {
                        name = data:GetName(),
                        collected = info.collected,
                        uncollected = info.uncollected,
                        unnecessary = info.unnecessary,
                        icon = data:GetIcon()
                    }
                )
            end
        end

        table.sort(
            fragmentsForDisplay,
            function(a, b)
                return a.name < b.name
            end
        )

        for _, info in ipairs(fragmentsForDisplay) do
            local collectibleName = BS.LC.Format(info.name)

            if (info.collected + info.uncollected + info.unnecessary > 0) then
                if (info.collected and (info.unnecessary == 0) and info.collected > 0) then
                    collectedtt = string.format("%s%s ", collectedtt, BS.Icon(info.icon))
                    collectedtt = string.format("%s%s ", collectedtt, BS.COLOURS.White:Colorize(collectibleName))
                    collectedtt =
                        string.format("%s%s", collectedtt, BS.COLOURS.Green:Colorize(tostring(info.collected)))
                    collectedtt =
                        string.format(
                            "%s / %s%s",
                            collectedtt,
                            BS.COLOURS.Green:Colorize(tostring(info.collected + info.uncollected)),
                            BS.LF
                        )
                end

                if (info.unnecessary > 0) then
                    unnecessarytt = string.format("%s%s ", unnecessarytt, BS.Icon(info.icon))
                    unnecessarytt = string.format("%s%s %d", unnecessarytt, collectibleName, info.unnecessary)
                    unnecessarytt =
                        string.format("%s / %d%s", unnecessarytt, info.unnecessary + info.uncollected, BS.LF)
                    unnecessarytt = BS.COLOURS.Yellow:Colorize(unnecessarytt)
                end

                if (info.collected and (info.unnecessary == 0) and info.collected == 0) then
                    uncollectedtt = string.format("%s%s ", uncollectedtt, BS.Icon(info.icon))
                    uncollectedtt = string.format("%s%s 0/", uncollectedtt, collectibleName)
                    uncollectedtt = string.format("%s%d%s", uncollectedtt, info.collected + info.uncollected, BS.LF)
                end
            end
        end

        tt = tt .. BS.LF .. collectedtt .. BS.LF

        if (unnecessarytt:len() > 0) then
            tt = tt .. GetString(_G.BARSTEWARD_ALREADY_COLLECTED) .. BS.LF .. unnecessarytt .. "|r" .. BS.LF
        end

        if (uncollectedtt:len() > 0) then
            uncollectedtt = BS.COLOURS.Grey:Colorize(uncollectedtt)
            tt = tt .. GetString(_G.BARSTEWARD_NOT_COLLECTED) .. BS.LF .. BS.LC.Trim(uncollectedtt) .. "|r"
        end

        widget:SetTooltip(tt)

        return collected
    end,
    onLeftClick = function()
        COLLECTIONS_BOOK:BrowseToCollectible(BS.CollectibleId)
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    tooltip = GetString(_G.BARSTEWARD_COLLECTIBLE_FRAGMENTS),
    icon = "icons/antiquities_u30_museum_fragment07"
}

BS.widgets[BS.W_RUNEBOXES] = {
    -- v1.4.49
    name = "runeboxFragments",
    update = function(widget)
        local this = BS.W_FRAGMENTS
        local collected, required = 0, 0
        local unnecessary = 0
        local fragmentInfo = {}

        local bags = { BAG_BACKPACK, BAG_BANK }

        if (IsESOPlusSubscriber()) then
            table.insert(bags, BAG_SUBSCRIBER_BANK)
        end

        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return ZO_IsElementInNumericallyIndexedTable(BS.FRAGMENT_TYPES, itemdata.specializedItemType)
                end,
                unpack(bags) -- lol :-)
            )

        for _, item in ipairs(filteredItems) do
            local collectibleId, fragments = BS.GetCollectibleId(item.bagId, item.slotIndex)
            local unlocked

            if (type(collectibleId) == "string") then
                unlocked = false
                collectibleId = tonumber(collectibleId) + 1000000
            elseif (collectibleId > 0) then
                unlocked = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId):IsUnlocked()
            end

            if (unlocked ~= nil) then
                if (not fragmentInfo[collectibleId]) then
                    fragmentInfo[collectibleId] = {
                        name = item.name,
                        collected = 0,
                        uncollected = 0,
                        unnecessary = 0,
                        required = 0
                    }
                end

                fragmentInfo[collectibleId].required = fragments

                if (not unlocked) then
                    fragmentInfo[collectibleId].collected = fragmentInfo[collectibleId].collected + item.stackCount
                    collected = collected + item.stackCount
                    required = required + fragments
                else
                    fragmentInfo[collectibleId].unnecessary = fragmentInfo[collectibleId].unnecessary + item.stackCount
                    unnecessary = unnecessary + item.stackCount
                end
            end
        end

        local text = collected .. "/" .. required
        local plainText = text

        if (unnecessary > 0) then
            plainText = text .. "/" .. unnecessary
            text = text .. "/" .. BS.COLOURS.Yellow:Colorize(unnecessary)
        end

        widget:SetValue(text, plainText)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_RUNEBOX_FRAGMENTS)
        local collectedtt = ""
        local unnecessarytt = ""
        local icon
        local tttable = {}

        for id, info in pairs(fragmentInfo) do
            if (id > 1000000) then
                icon = GetItemLinkIcon(BS.LC.MakeItemLink(tonumber(id - 1000000)))
            else
                icon = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id):GetIcon()
            end

            table.insert(
                tttable,
                {
                    name = info.name,
                    icon = icon,
                    collected = info.collected,
                    unnecessary = info.unnecessary,
                    required = info.required
                }
            )
        end

        table.sort(
            tttable,
            function(a, b)
                return a.name < b.name
            end
        )

        for _, info in ipairs(tttable) do
            if (info.collected + info.required + info.unnecessary > 0) then
                if (info.collected and (info.unnecessary == 0)) then
                    collectedtt = string.format("%s%s ", collectedtt, BS.Icon(info.icon))
                    collectedtt = string.format("%s%s ", collectedtt, BS.COLOURS.White:Colorize(info.name))
                    collectedtt =
                        string.format("%s%s", collectedtt, BS.COLOURS.Green:Colorize(tostring(info.collected)))
                    collectedtt =
                        string.format("%s / %s%s", collectedtt, BS.COLOURS.Green:Colorize(info.required), BS.LF)
                end

                if (info.unnecessary > 0) then
                    unnecessarytt = string.format("%s%s ", unnecessarytt, BS.Icon(info.icon))
                    unnecessarytt = string.format("%s%s %d", unnecessarytt, info.name, info.unnecessary)
                    unnecessarytt = string.format("%s / %d%s", unnecessarytt, info.required, BS.LF)
                    unnecessarytt = BS.COLOURS.Yellow:Colorize(unnecessarytt)
                end
            end
        end

        tt = tt .. BS.LF .. collectedtt .. "|r" .. BS.LF

        if (unnecessarytt:len() > 0) then
            tt = tt .. GetString(_G.BARSTEWARD_ALREADY_COLLECTED) .. BS.LF .. unnecessarytt .. "|r"
        end

        local uncollected = BS.GetNoneCollected(fragmentInfo)

        tt = tt .. BS.LF .. GetString(_G.BARSTEWARD_NOT_COLLECTED)

        local ttext = ""

        for _, info in ipairs(uncollected) do
            ttext = string.format("%s%s%s ", ttext, BS.LF, BS.Icon(info.icon))
            ttext = string.format("%s%s 0/%d", ttext, BS.LC.Format(info.name), info.quantity)
        end

        widget:SetTooltip(tt .. BS.COLOURS.Grey:Colorize(ttext))

        return collected
    end,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    tooltip = GetString(_G.BARSTEWARD_RUNEBOX_FRAGMENTS),
    icon = "tradinghouse/tradinghouse_trophy_runebox_fragment_up"
}

local function getFoundRecipesTooltip()
    local tt = GetString(_G.BARSTEWARD_RECIPES)
    local tttable = {}

    for _, info in pairs(BS.Vars.FoundRecipes) do
        table.insert(tttable, info)
    end

    table.sort(
        tttable,
        function(a, b)
            return a.name < b.name
        end
    )

    for _, info in ipairs(tttable) do
        local colour = GetItemQualityColor(info.displayQuality)
        local name = colour:Colorize(BS.LC.Format(info.name))

        tt = tt .. BS.LF .. name .. "|r" .. ((info.qty > 1) and (" (" .. info.qty .. ")") or "")

        if (info.known) then
            tt = tt .. " " .. BS.Icon("miscellaneous/check")
        end
    end

    return tt
end

BS.widgets[BS.W_RECIPE_WATCH] = {
    -- v1.4.50
    name = "recipeWatch",
    update = function(widget, event, receivedBy, itemName, quantity, _, _, _, _, _, itemId)
        local this = BS.W_RECIPE_WATCH
        local link = BS.LC.MakeItemLink(itemId, itemName)
        local itemType = GetItemLinkItemType(link)
        local lootedBy = ZO_CachedStrFormat("<<C:1>>", receivedBy)
        local player = BS.CHAR.name

        if (player ~= lootedBy) then
            return 0
        end

        if (not BS.Vars.FoundRecipes) then
            BS.Vars.FoundRecipes = {}
            BS.Vars.FoundCount = 0
        end

        if ((event or "initial") == "initial") then
            widget:SetValue(BS.Vars.FoundCount or 0)
            widget:SetTooltip(getFoundRecipesTooltip())
            widget:SetColour(BS.GetColour(this, true))
        end

        if (itemType ~= ITEMTYPE_RECIPE) then
            return
        end

        local displayQuality = GetItemLinkDisplayQuality(link)

        if (not BS.Vars.FoundRecipes[itemId]) then
            BS.Vars.FoundRecipes[itemId] = { name = itemName, qty = 0, displayQuality = displayQuality, known = false }
        end

        BS.Vars.FoundRecipes[itemId].qty = BS.Vars.FoundRecipes[itemId].qty + quantity
        BS.Vars.FoundRecipes[itemId].known = IsItemLinkRecipeKnown(link)
        BS.Vars.FoundCount = BS.Vars.FoundCount + quantity

        if (BS.GetVar("Announce", this)) then
            local icolour = GetItemQualityColor(displayQuality)
            local iname = icolour:Colorize(BS.LC.Format(itemName))

            BS.Vars:SetCommon(os.time(), "PreviousAnnounceTime", this)
            BS.Announce(
                GetString(_G.BARSTEWARD_RECIPES),
                zo_strformat(GetString(_G.BARSTEWARD_WATCHED_ITEM_MESSAGE), iname),
                this
            )
        end

        widget:SetValue(BS.Vars.FoundCount)
        widget:SetColour(BS.GetColour(this, true))
        widget:SetTooltip(getFoundRecipesTooltip())

        return BS.Vars.FoundCount
    end,
    event = EVENT_LOOT_RECEIVED,
    icon = "icons/event_newlifefestival_2016_recipe",
    tooltip = GetString(_G.BARSTEWARD_RECIPES),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (BS.Vars.FoundRecipes) then
            BS.LC.Clear(BS.Vars.FoundRecipes)
            BS.Vars.FoundCount = 0
            ZO_Tooltips_HideTextTooltip()
            BS.RefreshWidget(BS.W_RECIPE_WATCH)
        end
    end
}

local function getCharges(slot)
    local link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)

    if (link and IsItemChargeable(BAG_WORN, slot)) then
        return GetItemLinkNumEnchantCharges(link), GetItemLinkMaxEnchantCharges(link)
    else
        return -1, -1
    end
end

local function getMin(charges, slots, equipped)
    local min = 101
    local minWeapon = {}

    equipped =
        equipped or
        { pc = GetString(_G.BARSTEWARD_NOT_APPLICABLE), name = BS.LC.Format(SI_GAMEPAD_INVENTORY_EMPTY_TOOLTIP) }

    for slot, info in pairs(charges) do
        if (ZO_IsElementInNumericallyIndexedTable(slots, slot)) then
            if (type(info.pc) == "number") then
                if (info.pc < min) then
                    min = info.pc
                    minWeapon = info
                end
            end
        end
    end

    if (minWeapon.pc == nil) then
        minWeapon = equipped
    end

    return minWeapon
end

local function getColour(value)
    local this = BS.W_WEAPON_CHARGE
    local colour = BS.GetColour(this, "Ok", true)

    if (value <= BS.GetVar("WarningValue", this) and value > BS.GetVar("DangerValue", this)) then
        colour = BS.GetColour(this, "Warning", true)
    elseif (value <= BS.GetVar("DangerValue", this)) then
        colour = BS.GetColour(this, "Danger", true)
    end

    return colour
end

BS.widgets[BS.W_WEAPON_CHARGE] = {
    -- v1.5.8
    name = "weaponCharge",
    update = function(widget)
        local slots = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
        local backup = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }
        local activeWeaponPair = GetActiveWeaponPairInfo()
        local weapons = BS.LC.MergeTables(slots, backup)
        local weaponCharges = {}
        -- luacheck: push ignore 311
        local min = {}
        -- luacheck: pop

        for _, slot in ipairs(weapons) do
            local charges, maxCharges = getCharges(slot)
            local pc = GetString(_G.BARSTEWARD_NOT_APPLICABLE)
            local raw = 101

            if (charges > -1) then
                raw = BS.LC.ToPercent(charges, maxCharges)
                pc = string.format("%d%%", raw or 0)
            end

            local name = BS.LC.Format(GetItemName(BAG_WORN, slot))

            if (name ~= "") then
                weaponCharges[slot] = { pc = pc, name = name, raw = raw }
            end
        end

        if (activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP) then
            min =
                getMin(
                    weaponCharges,
                    backup,
                    weaponCharges[EQUIP_SLOT_BACKUP_MAIN] or weaponCharges[EQUIP_SLOT_BACKUP_OFF]
                )
        else
            min =
                getMin(weaponCharges, slots, weaponCharges[EQUIP_SLOT_MAIN_HAND] or weaponCharges[EQUIP_SLOT_OFF_HAND])
        end

        local colour = getColour(min.raw or 0)

        widget:SetValue(min.pc)
        widget:SetColour(colour)

        local tt = GetString(_G.BARSTEWARD_WEAPON_CHARGE)

        for _, info in pairs(weaponCharges) do
            local slotColour = getColour(info.raw)

            tt = string.format("%s%s%s - %s", tt, BS.LF, slotColour:Colorize(info.name), info.pc)
        end

        widget:SetTooltip(tt)

        return min.raw
    end,
    event = { EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EVENT_ACTIVE_WEAPON_PAIR_CHANGED },
    icon = "icons/alchemy/crafting_alchemy_trait_weaponcrit_match",
    tooltip = GetString(_G.BARSTEWARD_WEAPON_CHARGE),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_SCRIBING_INK] = {
    -- v3.0.0
    name = "scribingInkCount",
    update = function(widget)
        local this = BS.W_SCRIBING_INK
        local inkLink = GetScribingInkItemLink(LINK_STYLE_DEFAULT)
        local inkCount = GetItemLinkInventoryCount(inkLink, INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG)

        local colour = BS.GetColour(this, "Ok", true)

        if (inkCount < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        elseif (inkCount < BS.GetVar("WarningValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        end

        widget:SetColour(colour)
        widget:SetValue(inkCount)

        return inkCount
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate", "FullInventoryUpdate" } },
    icon = "/icons/item_grimoire_ink",
    ---@diagnostic disable-next-line: undefined-field
    tooltip = _G.ZO_Scribing_Manager.GetFormattedScribingInkName()
}

BS.widgets[BS.W_MYTHIC] = {
    -- v3.2.13
    name = "equippedMythic",
    update = function(widget)
        local mythic = BS.LC.Format(SI_ANTIALIASINGTYPE0)
        local colour = BS.LC.White
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    local quality = GetItemDisplayQuality(itemdata.bagId, itemdata.slotIndex)

                    return quality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE
                end,
                BAG_WORN
            )

        if (#filteredItems > 0) then
            local item = filteredItems[1]

            mythic = BS.LC.Format(item.name)
            colour = BS.LC.ZOSOrange
            widget:SetIcon(item.iconFile)
        else
            widget:SetIcon("icons/u42_mythic_meta")
        end

        widget:SetValue(mythic)
        widget:SetColour(colour)

        return mythic
    end,
    event = EVENT_PLAYER_ACTIVATED,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate" } },
    icon = "icons/u42_mythic_meta",
    tooltip = BS.LC.Format(SI_ITEMDISPLAYQUALITY6),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}
