local BS = _G.BarSteward
local trainingActive = true

EVENT_MANAGER:RegisterForEvent(
    BS.Name,
    _G.EVENT_RIDING_SKILL_IMPROVEMENT,
    function()
        trainingActive = true
    end
)

BS.EventManager:RegisterForEvent(
    _G.EVENT_PLAYER_ACTIVATED,
    function()
        trainingActive = true
    end
)

BS.widgets[BS.W_MOUNT_TRAINING] = {
    name = "mountTraining",
    update = function(widget)
        local remaining, total = 0, 0
        local this = BS.W_MOUNT_TRAINING

        if (trainingActive) then
            remaining, total = GetTimeUntilCanBeTrained()
        end

        local colour = BS.GetColour(this, "Ok", true)
        local time = "X"

        if (remaining ~= nil and total ~= nil) then
            remaining = remaining / 1000
            time = BS.SecondsToTime(remaining, true, false, BS.GetVar("HideSeconds", this))
            colour = BS.GetTimeColour(remaining, this, nil, true, true)

            if (remaining == 0) then
                trainingActive = false
            end
        end

        widget:SetColour(colour)
        widget:SetValue(time)

        local tt = GetString(_G.BARSTEWARD_MOUNT_TRAINING) .. BS.LF .. BS.LF
        local ttt = GetString(_G.BARSTEWARD_TRAINING_PROGRESS)

        for trainingType, texture in pairs(_G.STABLE_TRAINING_TEXTURES) do
            local icon = string.format("%s%s ", BS.LF, BS.Icon(texture))
            local ttype = string.format("%s ", BS.LC.Format(GetString("SI_RIDINGTRAINTYPE", trainingType)))
            local val, maxVal = STABLE_MANAGER:GetStats(trainingType)
            local tcol = (val == maxVal) and BS.COLOURS.DefaultOkColour or BS.COLOURS.DefaultWarningColour

            ttt = string.format("%s%s%s%s/%s", ttt, icon, ttype, tcol:Colorize(val), maxVal)
            ttt = BS.COLOURS.White:Colorize(ttt)
        end

        widget:SetTooltip(tt .. ttt)

        return remaining
    end,
    timer = 1000,
    icon = "mounts/tabicon_mounts_up",
    tooltip = GetString(_G.BARSTEWARD_MOUNT_TRAINING),
    hideWhenEqual = 0,
    fullyUsed = function()
        return trainingActive
    end,
    complete = function()
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus =
            GetRidingStats()
        local maxed =
            inventoryBonus == maxInventoryBonus and staminaBonus == maxStaminaBonus and speedBonus == maxSpeedBonus

        return maxed
    end
}
