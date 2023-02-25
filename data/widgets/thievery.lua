local BS = _G.BarSteward
local goldIcon = zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16) .. " "

BS.widgets[BS.W_STOLEN_ITEMS] = {
    -- v1.0.1
    name = "stolenItemCount",
    update = function(widget)
        local count = 0
        local bagCounts = {carrying = 0, banked = 0}
        local stolen = {}

        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
            function(itemdata)
                return IsItemStolen(itemdata.bagId, itemdata.slotIndex)
            end,
            _G.BAG_WORN,
            _G.BAG_BACKPACK,
            _G.BAG_BANK,
            _G.BAG_SUBSCRIBER_BANK
        )

        for _, item in ipairs(filteredItems) do
            local icon = GetItemInfo(item.bagId, item.slotIndex)
            count = count + item.stackCount

            if (item.bagId == _G.BAG_BANK or item.bagId == _G.BAG_SUBSCRIBER_BANK) then
                bagCounts.banked = bagCounts.banked + item.stackCount
            else
                bagCounts.carrying = bagCounts.carrying + item.stackCount
            end

            table.insert(
                stolen,
                {
                    name = BS.Format(GetItemName(item.bagId, item.slotIndex)),
                    count = item.stackCount,
                    icon = zo_iconFormat(icon, 16, 16),
                    sellPrice = GetItemSellValueWithBonuses(item.bagId, item.slotIndex)
                }
            )
        end

        widget:SetValue(count)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_STOLEN_ITEMS].Colour or BS.Vars.DefaultColour))

        local ttt = GetString(_G.BARSTEWARD_STOLEN) .. BS.LF .. "|cf9f9f9"
        ttt = ttt .. BS.BAGICON .. " " .. bagCounts.carrying .. " " .. BS.BANKICON .. " " .. bagCounts.banked .. "|r"

        if (#stolen > 0) then
            local total = 0

            local stt = BS.LF

            for _, item in pairs(stolen) do
                stt = string.format("%s%s%s ", stt, BS.LF, item.icon)
                stt = string.format("%s|cf9f9f9%s", stt, item.name)

                if (item.count > 1) then
                    stt = string.format("%s (%d)", stt, item.count)
                end

                stt = string.format("%s   |cffff00%d|r%s", stt, item.sellPrice * item.count, goldIcon)
                total = total + (item.sellPrice * item.count)
            end

            ttt = ttt .. BS.LF .. BS.LF
            ttt = ttt .. zo_strformat(GetString(_G.BARSTEWARD_TOTAL_VALUE), "|cffff00" .. total .. "|r " .. goldIcon)

            ttt = ttt .. stt
        end

        widget.tooltip = ttt

        return count
    end,
    callback = {[SHARED_INVENTORY] = {"SingleSlotInventoryUpdate"}},
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
        local vars = BS.Vars.Controls[BS.W_FENCE_TRANSACTIONS]
        local max = FENCE_MANAGER:GetNumTotalTransactions(_G.ZO_MODE_STORE_SELL_STOLEN)
        local used = FENCE_MANAGER:GetNumTransactionsUsed(_G.ZO_MODE_STORE_SELL_STOLEN)
        local pcUsed = math.floor(used / max) * 100
        local colour = vars.OkColour or BS.Vars.DefaultOkColour
        local noLimitColour = vars.NoLimitColour and "|cf9f9f9" or ""
        local noLimitTerminator = vars.NoLimitColour and "|r" or ""
        local value = used .. (vars.HideLimit and "" or (noLimitColour .. "/" .. max .. noLimitTerminator))
        local widthValue = used .. (vars.HideLimit and "" or ("/" .. max))

        if (pcUsed >= vars.WarningValue and pcUsed < vars.DangerValue) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        elseif (pcUsed >= vars.DangerValue) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(value, widthValue)

        return used
    end,
    event = _G.EVENT_CLOSE_STORE,
    hideWhenEqual = 0,
    icon = "/esoui/art/vendor/vendor_tabicon_sell_up.dds",
    tooltip = GetString(_G.BARSTEWARD_FENCE)
}

BS.widgets[BS.W_LAUNDER_TRANSACTIONS] = {
    -- v1.2.15
    name = "launderlots",
    update = function(widget)
        local vars = BS.Vars.Controls[BS.W_LAUNDER_TRANSACTIONS]
        local max = FENCE_MANAGER:GetNumTotalTransactions(_G.ZO_MODE_STORE_LAUNDER)
        local used = FENCE_MANAGER:GetNumTransactionsUsed(_G.ZO_MODE_STORE_LAUNDER)
        local pcUsed = math.floor(used / max) * 100
        local colour = vars.OkColour or BS.Vars.DefaultOkColour
        local noLimitColour = vars.NoLimitColour and "|cf9f9f9" or ""
        local noLimitTerminator = vars.NoLimitColour and "|r" or ""
        local value = used .. (vars.HideLimit and "" or (noLimitColour .. "/" .. max .. noLimitTerminator))
        local widthValue = used .. (vars.HideLimit and "" or ("/" .. max))

        if (pcUsed >= vars.WarningValue and pcUsed < vars.DangerValue) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        elseif (pcUsed >= vars.DangerValue) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(value, widthValue)

        return used
    end,
    event = _G.EVENT_CLOSE_STORE,
    hideWhenEqual = 0,
    icon = "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
    tooltip = GetString(_G.BARSTEWARD_LAUNDER)
}

BS.widgets[BS.W_FENCE_RESET] = {
    -- v1.2.10
    name = "fenceReset",
    update = function(widget)
        local _, used, timeToReset = GetFenceLaunderTransactionInfo()
        local colour = BS.Vars.DefaultColour
        local remaining = BS.SecondsToTime(timeToReset, true, false, BS.Vars.Controls[BS.W_FENCE_RESET].HideSeconds)

        widget:SetColour(unpack(colour))
        widget:SetValue(remaining)

        return used
    end,
    timer = 1000,
    hideWhenEqual = 0,
    icon = "/esoui/art/vendor/vendor_tabicon_fence_over.dds",
    tooltip = GetString(_G.BARSTEWARD_FENCE_RESET)
}
