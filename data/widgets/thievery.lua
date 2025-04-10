local BS = _G.BarSteward
local goldIcon = BS.Icon("currency/currency_gold") .. " "

BS.widgets[BS.W_STOLEN_ITEMS] = {
    -- v1.0.1
    name = "stolenItemCount",
    update = function(widget)
        local this = BS.W_STOLEN_ITEMS
        local count = 0
        local bagCounts = { carrying = 0, banked = 0 }
        local stolen = {}
        local slotCount = 0
        local filteredItems =
            SHARED_INVENTORY:GenerateFullSlotData(
                function(itemdata)
                    return IsItemStolen(itemdata.bagId, itemdata.slotIndex)
                end,
                BAG_WORN,
                BAG_BACKPACK
            )

        for _, item in ipairs(filteredItems) do
            local icon = GetItemInfo(item.bagId, item.slotIndex)
            count = count + item.stackCount

            if (item.bagId == BAG_BANK or item.bagId == BAG_SUBSCRIBER_BANK) then
                bagCounts.banked = bagCounts.banked + item.stackCount
            else
                bagCounts.carrying = bagCounts.carrying + item.stackCount
            end

            table.insert(
                stolen,
                {
                    name = BS.LC.Format(GetItemName(item.bagId, item.slotIndex)),
                    count = item.stackCount,
                    icon = BS.Icon(icon),
                    sellPrice = GetItemSellValueWithBonuses(item.bagId, item.slotIndex)
                }
            )

            slotCount = slotCount + 1
        end

        local value = count

        if (BS.Vars.Controls[this].ShowSlots) then
            value = value .. "/" .. slotCount
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(this, true))

        local ttt = GetString(_G.BARSTEWARD_STOLEN) .. BS.LF

        ttt = ttt .. BS.COLOURS.White:Colorize(BS.BAGICON .. " " .. bagCounts.carrying)

        if (#stolen > 0) then
            local total = 0

            local stt = BS.LF

            for _, item in pairs(stolen) do
                stt = string.format("%s%s%s ", stt, BS.LF, item.icon)
                stt = string.format("%s%s", stt, item.name)

                if (item.count > 1) then
                    stt = string.format("%s (%d)", stt, item.count)
                end

                stt =
                    string.format(
                        "%s   %s%s",
                        stt,
                        BS.COLOURS.Yellow:Colorize(tostring(item.sellPrice * item.count)),
                        goldIcon
                    )
                total = total + (item.sellPrice * item.count)
            end

            ttt = ttt .. BS.LF .. BS.LF
            ttt =
                ttt ..
                zo_strformat(
                    GetString(_G.BARSTEWARD_TOTAL_VALUE),
                    BS.COLOURS.Yellow:Colorize(tostring(total)) .. goldIcon
                )

            ttt = ttt .. BS.COLOURS.White:Colorize(stt)
        end

        widget:SetTooltip(ttt)

        return count
    end,
    callback = { [SHARED_INVENTORY] = { "SingleSlotInventoryUpdate" } },
    icon = "inventory/inventory_stolenitem_icon",
    tooltip = GetString(_G.BARSTEWARD_STOLEN),
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
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_STOLEN_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_STOLEN_ITEMS].ShowSlots or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_STOLEN_ITEMS].ShowSlots = value
                BS.RefreshWidget(BS.W_STOLEN_ITEMS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_FENCE_TRANSACTIONS] = {
    -- v1.0.2
    name = "fenceSlots",
    update = function(widget)
        local this = BS.W_FENCE_TRANSACTIONS
        local max = FENCE_MANAGER:GetNumTotalTransactions(ZO_MODE_STORE_SELL_STOLEN)
        local used = FENCE_MANAGER:GetNumTransactionsUsed(ZO_MODE_STORE_SELL_STOLEN)
        local pcUsed = BS.LC.ToPercent(used, max)
        local colour = BS.GetColour(this, "Ok", true)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Green
        local value = used .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. max)))
        local widthValue = used .. (BS.GetVar("HideLimit", this) and "" or ("/" .. max))

        if (pcUsed >= BS.GetVar("WarningValue", this) and pcUsed < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        elseif (pcUsed >= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        widget:SetColour(colour)
        widget:SetValue(value, widthValue)

        return used
    end,
    event = EVENT_CLOSE_STORE,
    hideWhenEqual = 0,
    icon = "vendor/vendor_tabicon_sell_up",
    tooltip = GetString(_G.BARSTEWARD_FENCE)
}

BS.widgets[BS.W_LAUNDER_TRANSACTIONS] = {
    -- v1.2.15
    name = "launderSlots",
    update = function(widget)
        local this = BS.W_LAUNDER_TRANSACTIONS
        local max = FENCE_MANAGER:GetNumTotalTransactions(ZO_MODE_STORE_LAUNDER)
        local used = FENCE_MANAGER:GetNumTransactionsUsed(ZO_MODE_STORE_LAUNDER)
        local pcUsed = BS.LC.ToPercent(used, max)
        local colour = BS.GetColour(this, "Ok", true)
        local noLimitColour = BS.GetVar("NoLimitColour", this) and BS.COLOURS.White or BS.COLOURS.Yellow
        local value = used .. (BS.GetVar("HideLimit", this) and "" or (noLimitColour:Colorize("/" .. max)))
        local widthValue = used .. (BS.GetVar("HideLimit", this) and "" or ("/" .. max))

        if (pcUsed >= BS.GetVar("WarningValue", this) and pcUsed < BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Warning", true)
        elseif (pcUsed >= BS.GetVar("DangerValue", this)) then
            colour = BS.GetColour(this, "Danger", true)
        end

        widget:SetColour(colour)
        widget:SetValue(value, widthValue)

        return used
    end,
    event = EVENT_CLOSE_STORE,
    hideWhenEqual = 0,
    icon = "vendor/vendor_tabicon_fence_up",
    tooltip = GetString(_G.BARSTEWARD_LAUNDER)
}

BS.widgets[BS.W_FENCE_RESET] = {
    -- v1.2.10
    name = "fenceReset",
    update = function(widget)
        local _, used, timeToReset = GetFenceLaunderTransactionInfo()
        local this = BS.W_FENCE_RESET
        local colour = BS.COLOURS.DefaultColour
        local remaining = BS.SecondsToTime(timeToReset, true, false, BS.GetVar("HideSeconds", this))

        widget:SetColour(colour)
        widget:SetValue(remaining)

        return used
    end,
    timer = 1000,
    hideWhenEqual = 0,
    icon = "vendor/vendor_tabicon_fence_over",
    tooltip = GetString(_G.BARSTEWARD_FENCE_RESET)
}
