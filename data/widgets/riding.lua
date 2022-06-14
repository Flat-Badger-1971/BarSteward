local BS = _G.BarSteward

BS.widgets[BS.W_MOUNT_TRAINING] = {
    name = "mountTraining",
    update = function(widget)
        local remaining, total = GetTimeUntilCanBeTrained()
        local colour = BS.Vars.Controls[BS.W_MOUNT_TRAINING].OkColour or BS.Vars.DefaultOkColour
        local time = "X"

        if (remaining ~= nil and total ~= nil) then
            remaining = remaining / 1000
            time = BS.SecondsToTime(remaining, true, false, BS.Vars.Controls[BS.W_MOUNT_TRAINING].HideSeconds)

            if (remaining < (BS.Vars.Controls[BS.W_MOUNT_TRAINING].DangerValue * 3600)) then
                colour = BS.Vars.Controls[BS.W_MOUNT_TRAINING].DangerColour or BS.Vars.DefaultDangerColour
            elseif (remaining < (BS.Vars.Controls[BS.W_MOUNT_TRAINING].WarningValue * 3600)) then
                colour = BS.Vars.Controls[BS.W_MOUNT_TRAINING].WarningColour or BS.Vars.DefaultWarningColour
            end
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(time)
        return remaining
    end,
    timer = 1000,
    icon = "/esoui/art/mounts/tabicon_mounts_up.dds",
    tooltip = GetString(_G.BARSTEWARD_MOUNT_TRAINING),
    hideWhenEqual = 0,
    complete = function()
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus =
            GetRidingStats()
        local maxed =
            inventoryBonus == maxInventoryBonus and staminaBonus == maxStaminaBonus and speedBonus == maxSpeedBonus

        return maxed
    end
}
