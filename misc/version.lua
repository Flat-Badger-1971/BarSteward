local BS = _G.BarSteward

local function needsUpdate(version)
    if (not BS.Vars.Updates[version]) then
        return true
    end

    return false
end

function BS.VersionCheck()
    if (needsUpdate(112)) then
        -- update timer value from seconds to hours
        local value = BS.Vars.Controls[BS.W_LEADS].DangerValue
        local newValue = math.floor(value / 3.6) / 1000

        if (newValue < 1) then
            newValue = 1
        end

        BS.Vars.Controls[BS.W_LEADS].DangerValue = newValue
        BS.Vars.Controls[BS.W_LEADS].Units = GetString(_G.BARSTEWARD_HOURS)
        BS.Vars.Controls[BS.W_LEADS].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_BLACKSMITHING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_CLOTHING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_JEWELCRAFTING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_WOODWORKING].ColourValues = "okc,wv,wc,dv,dc"

        BS.Vars.Controls[BS.W_BLACKSMITHING].DangerValue = 24
        BS.Vars.Controls[BS.W_CLOTHING].DangerValue = 24
        BS.Vars.Controls[BS.W_JEWELCRAFTING].DangerValue = 24
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].DangerValue = 3
        BS.Vars.Controls[BS.W_WOODWORKING].DangerValue = 24
        BS.Vars.Controls[BS.W_BLACKSMITHING].WarningValue = 72
        BS.Vars.Controls[BS.W_CLOTHING].WarningValue = 72
        BS.Vars.Controls[BS.W_JEWELCRAFTING].WarningValue = 72
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].WarningValue = 6
        BS.Vars.Controls[BS.W_WOODWORKING].WarningValue = 72

        -- remove autohide from timers
        BS.Vars.Controls[BS.W_BLACKSMITHING].Autohide = nil
        BS.Vars.Controls[BS.W_CLOTHING].Autohide = nil
        BS.Vars.Controls[BS.W_JEWELCRAFTING].Autohide = nil
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].Autohide = nil
        BS.Vars.Controls[BS.W_WOODWORKING].Autohide = nil

        BS.Vars.Updates[112] = true
    end

    if (needsUpdate(113)) then
        BS.Vars.Movable = false
    end
end