local BS = _G.BarSteward

BS.widgets[BS.W_BAG_SPACE] = {
    name = "bagSpace",
    update = function(widget)
        local bagSize = GetBagSize(_G.BAG_BACKPACK)
        local bagUsed = GetNumBagUsedSlots(_G.BAG_BACKPACK)
        local value = bagUsed .. "/" .. bagSize
        local pcUsed = math.floor((bagUsed / bagSize) * 100)

        local colour = BS.Vars.Controls[BS.W_BAG_SPACE].OkColour or BS.Vars.DefaultOkColour

        if (pcUsed >= BS.Vars.Controls[BS.W_BAG_SPACE].WarningValue and pcUsed < BS.Vars.Controls[BS.W_BAG_SPACE].DangerValue) then
            colour = BS.Vars.Controls[BS.W_BAG_SPACE].WarningColour or BS.Vars.DefaultWarningColour
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
    tooltip = GetString(_G.SI_GAMEPAD_MAIL_INBOX_INVENTORY),
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

        if (pcUsed >= BS.Vars.Controls[BS.W_BANK_SPACE].WarningValue and pcUsed < BS.Vars.Controls[BS.W_BANK_SPACE].DangerValue) then
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
    tooltip = GetString(_G.SI_INTERACT_OPTION_BANK),
    icon = "/esoui/art/tooltips/icon_bank.dds"
}

BS.widgets[BS.W_REPAIR_COST] = {
    name = "itemRepairCost",
    update = function(widget, _, _, _, _, updateReason)
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
    update = function(widget, _, _, _, _, updateReason)
        -- find item with lowest durability
        if (updateReason == nil or updateReason == _G.INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
            local lowest = 100
            local lowestType = _G.ITEMTYPE_ARMOR
            local items = {}

            for slot = 0, GetBagSize(_G.BAG_WORN) do
                local itemName = GetItemName(_G.BAG_WORN, slot)
                local condition = GetItemCondition(_G.BAG_WORN, slot)
                local colour = BS.ARGBConvert(BS.Vars.Controls[BS.W_DURABILITY].OkColour or BS.Vars.DefaultOkColour)

                if (itemName ~= "") then
                    if (condition <= BS.Vars.Controls[BS.W_DURABILITY].OkValue and condition >= BS.Vars.Controls[BS.W_DURABILITY].DangerValue) then
                        colour = BS.ARGBConvert(BS.Vars.Controls[BS.W_DURABILITY].WarningColour or BS.Vars.DefaultWarningColour)
                    elseif (condition < BS.Vars.Controls[BS.W_DURABILITY].DangerValue) then
                        colour = BS.ARGBConvert(BS.Vars.Controls[BS.W_DURABILITY].DangerColour or BS.Vars.DefaultDangerColour)
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
    tooltip = GetString(_G.SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER):gsub(":", "")
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

        if (pcUsed >= BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].WarningValue and pcUsed < BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS].DangerValue) then
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