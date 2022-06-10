local BS = _G.BarSteward

BS.widgets[BS.W_MOUNT_TRAINING] = {
    name = "mountTraining",
    update = function(widget)
        local remaining, total = GetTimeUntilCanBeTrained()

        local time = "X"

        if (remaining ~= nil and total ~= nil) then
            time = BS.SecondsToTime(remaining / 1000, true, false, BS.Vars.Controls[BS.W_MOUNT_TRAINING].HideSeconds)
        end

        local colour = BS.Vars.Controls[BS.W_MOUNT_TRAINING].Colour or BS.Vars.DefaultColour

        if (remaining == 0) then
            colour = BS.Vars.Controls[BS.W_MOUNT_TRAINING].DangerColour or BS.Vars.DefaultDangerColour
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
