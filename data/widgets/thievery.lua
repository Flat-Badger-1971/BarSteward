local BS = _G.BarSteward

BS.widgets[BS.W_STOLEN_ITEMS] = {
    -- v1.0.1
    name = "stolenItemCount",
    update = function(widget)
        local count = 0
        local bagCounts = {carrying = 0, banked = 0}

        for _, bag in ipairs({_G.BAG_WORN, _G.BAG_BACKPACK, _G.BAG_BANK, _G.BAG_SUBSCRIBER_BANK}) do
            for slot = 0, GetBagSize(bag) do
                if (IsItemStolen(bag, slot)) then
                    local itemCount = GetSlotStackSize(bag, slot)
                    count = count + itemCount
                    if (bag == _G.BAG_BANK or bag == _G.BAG_SUBSCRIBER_BANK) then
                        bagCounts.banked = bagCounts.banked + itemCount
                    else
                        bagCounts.carrying = bagCounts.carrying + itemCount
                    end
                end
            end
        end

        widget:SetValue(count)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_STOLEN_ITEMS].Colour or BS.Vars.DefaultColour))

        local ttt = GetString(_G.BARSTEWARD_STOLEN) .. BS.LF .. "|cf9f9f9"
        ttt = ttt .. BS.BAGICON .. " " .. bagCounts.carrying .. " " .. BS.BANKICON .. " " .. bagCounts.banked .. "|r"

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

BS.widgets[BS.W_FENCE_RESET] = {
    -- v1.2.10
    name = "fenceReset",
    update = function(widget)
        -- from Thief Tools
        local start = 10800 -- 3am UTC
        local oneDay = 24 * 60 * 60
        local timeToReset = oneDay - ((GetTimeStamp() - start) % oneDay)
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
