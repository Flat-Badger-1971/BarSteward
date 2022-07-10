local BS = _G.BarSteward
local goldIcon = zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16) .. " "

BS.widgets[BS.W_STOLEN_ITEMS] = {
    -- v1.0.1
    name = "stolenItemCount",
    update = function(widget)
        local count = 0
        local bagCounts = {carrying = 0, banked = 0}
        local stolen = {}

        for _, bag in ipairs({_G.BAG_WORN, _G.BAG_BACKPACK, _G.BAG_BANK, _G.BAG_SUBSCRIBER_BANK}) do
            for slot = 0, GetBagSize(bag) do
                if (IsItemStolen(bag, slot)) then
                    local icon, itemCount = GetItemInfo(bag, slot)
                    --local itemCount = GetSlotStackSize(bag, slot)
                    count = count + itemCount
                    if (bag == _G.BAG_BANK or bag == _G.BAG_SUBSCRIBER_BANK) then
                        bagCounts.banked = bagCounts.banked + itemCount
                    else
                        bagCounts.carrying = bagCounts.carrying + itemCount
                    end

                    table.insert(
                        stolen,
                        {
                            name = GetItemName(bag, slot),
                            count = itemCount,
                            icon = zo_iconFormat(icon, 16, 16),
                            sellPrice = GetItemSellValueWithBonuses(bag, slot)
                        }
                    )
                end
            end
        end

        widget:SetValue(count)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_STOLEN_ITEMS].Colour or BS.Vars.DefaultColour))

        local ttt = GetString(_G.BARSTEWARD_STOLEN) .. BS.LF .. "|cf9f9f9"
        ttt = ttt .. BS.BAGICON .. " " .. bagCounts.carrying .. " " .. BS.BANKICON .. " " .. bagCounts.banked .. "|r"

        if (#stolen > 0) then
            ttt = ttt .. BS.LF

            for _, item in pairs(stolen) do
                ttt = ttt .. BS.LF .. item.icon .. " "
                ttt = ttt .. "|cf9f9f9" .. item.name

                if (item.count > 1) then
                    ttt = ttt .. " (" .. item.count .. ")"
                end

                ttt = ttt .. "   |cffff00" .. (item.sellPrice * item.count) .. "|r " .. goldIcon
            end
        end

        widget.tooltip = ttt

        return count
    end,
    event = _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    icon = "/esoui/art/inventory/inventory_stolenitem_icon.dds",
    tooltip = GetString(_G.BARSTEWARD_STOLEN),
    hideWhenEqual = 0,
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("inventory")
        else
            SCENE_MANAGER:Show("gamepad_inventory_root")
        end
    end
}

BS.widgets[BS.W_FENCE_TRANSACTIONS] = {
    -- v1.0.2
    name = "fenceSlots",
    update = function(widget)
        local max, used =
            FENCE_MANAGER:GetNumTotalTransactions(_G.ZO_MODE_STORE_SELL_STOLEN),
            FENCE_MANAGER:GetNumTransactionsUsed(_G.ZO_MODE_STORE_SELL_STOLEN)
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
    icon = "/esoui/art/vendor/vendor_tabicon_sell_up.dds",
    tooltip = GetString(_G.BARSTEWARD_FENCE)
}

BS.widgets[BS.W_LAUNDER_TRANSACTIONS] = {
    -- v1.2.15
    name = "launderlots",
    update = function(widget)
        local max, used =
            FENCE_MANAGER:GetNumTotalTransactions(_G.ZO_MODE_STORE_LAUNDER),
            FENCE_MANAGER:GetNumTransactionsUsed(_G.ZO_MODE_STORE_LAUNDER)
        local pcUsed = math.floor(used / max) * 100
        local colour = BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].OkColour or BS.Vars.DefaultOkColour

        if
            (pcUsed >= BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].WarningValue and
                pcUsed < BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].DangerValue)
         then
            colour = BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].WarningColour or BS.Vars.DefaultWarningColour
        elseif (pcUsed >= BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].DangerValue) then
            colour = BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(used .. "/" .. max)

        return used
    end,
    event = _G.EVENT_CLOSE_STORE,
    icon = "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
    tooltip = GetString(_G.BARSTEWARD_LAUNDER)
}

BS.widgets[BS.W_FENCE_RESET] = {
    -- v1.2.10
    name = "fenceReset",
    update = function(widget)
        local timeToReset = select(3, GetFenceLaunderTransactionInfo())
        local colour = BS.Vars.DefaultColour
        local remaining = BS.SecondsToTime(timeToReset, true, false, BS.Vars.Controls[BS.W_FENCE_RESET].HideSeconds)

        widget:SetColour(unpack(colour))
        widget:SetValue(remaining)

        return timeToReset
    end,
    timer = 1000,
    icon = "/esoui/art/vendor/vendor_tabicon_fence_over.dds",
    tooltip = GetString(_G.BARSTEWARD_FENCE_RESET)
}
