local BS = _G.BarSteward
local trainingActive = true

EVENT_MANAGER:RegisterForEvent(
    BS.Name,
    _G.EVENT_RIDING_SKILL_IMPROVEMENT,
    function()
        trainingActive = true
    end
)

BS.RegisterForEvent(
    _G.EVENT_PLAYER_ACTIVATED,
    function()
        trainingActive = true
    end
)

BS.widgets[BS.W_MOUNT_TRAINING] = {
    name = "mountTraining",
    update = function(widget)
        local remaining, total = 0, 0

        if (trainingActive) then
            remaining, total = GetTimeUntilCanBeTrained()
        end

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

            if (remaining == 0) then
                trainingActive = false
            end
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(time)

        local ttt = GetString(_G.BARSTEWARD_MOUNT_TRAINING) .. BS.LF .. BS.LF
        ttt = ttt .. GetString(_G.BARSTEWARD_TRAINING_PROGRESS)

        for trainingType, texture in pairs(_G.STABLE_TRAINING_TEXTURES) do
            local icon = BS.LF .. "|cf9f9f9" .. zo_iconFormat(texture, 16, 16) .. " "
            local ttype = ZO_CachedStrFormat("<<C:1>>", GetString(_G["SI_RIDINGTRAINTYPE" .. trainingType])) .. " "
            local val, maxVal = STABLE_MANAGER:GetStats(trainingType)
            local tcol = ((val == maxVal) and BS.Vars.DefaultOkColour or BS.Vars.DefaultWarningColour)
            local col = "|r" .. BS.ARGBConvert(tcol)

            ttt = ttt .. icon .. ttype .. col .. val .. "/" .. maxVal .. "|r"
        end

        widget.tooltip = ttt

        return remaining
    end,
    timer = 1000,
    icon = "/esoui/art/mounts/tabicon_mounts_up.dds",
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
