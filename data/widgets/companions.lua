local BS = _G.BarSteward

BS.widgets[BS.W_RAPPORT] = {
    name = "rapport",
    update = function(widget)
        local rapportValue = GetActiveCompanionRapport()
        local rapportMax = GetMaximumRapport()
        local rapportMin = GetMinimumRapport()
        local rdr, rdg, rdb = 0, 153 / 255, 102 / 255 -- dislike
        local rmr, rmg, rmb = 157 / 255, 132 / 255, 13 / 255 -- moderate
        local rlr, rlg, rlb = 114 / 255, 35 / 255, 35 / 255 -- like
        local rapportPcValue = rapportValue - rapportMin
        local rapportPcMax = rapportMax - rapportMin
        local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
        local r, g, b = BS.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

        widget:SetColour(r, g, b, 1)
        widget:SetValue(rapportValue)

        local level = GetActiveCompanionRapportLevel()
        local desc = GetActiveCompanionRapportLevelDescription(level)

        widget.tooltip = GetString(_G.BARSTEWARD_RAPPORT) .. BS.LF .. "|cffffff" .. desc .. "|r"

        return rapportValue
    end,
    event = {_G.EVENT_COMPANION_RAPPORT_UPDATE, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED},
    icon = "/esoui/art/hud/lootHistory_icon_rapportincrease_generic.dds",
    tooltip = GetString(_G.BARSTEWARD_RAPPORT),
    hideWhenEqual = function()
        if (HasActiveCompanion()) then
            return GetMaximumRapport()
        else
            return 0
        end
    end
}

BS.widgets[BS.W_COMPANION_LEVEL] = {
    -- v1.2.19
    name = "companionLevel",
    update = function(widget)
        local companionLevel, currentXPInLevel = GetActiveCompanionLevelInfo()
        local totalXPInLevel = GetNumExperiencePointsInCompanionLevel(companionLevel + 1) or 0
        local isMaxLevel = totalXPInLevel == 0
        local percent = 0

        if (not isMaxLevel) then
            percent = math.max(zo_roundToNearest((currentXPInLevel or 0) / totalXPInLevel, 0.01), 0) * 100
        end

        local text = companionLevel

        if (BS.Vars.Controls[BS.W_COMPANION_LEVEL].ShowXPPC) then
            text = text .. " (" .. percent .. "%)"
        end

        local companionDefId = GetActiveCompanionDefId()
        local collectibleId = GetCompanionCollectibleId(companionDefId)
        local _, _, icon = GetCollectibleInfo(collectibleId)

        widget:SetIcon(icon)
        widget:SetValue(text)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_COMPANION_LEVEL].Colour or BS.Vars.DefaultColour))

        local ttt = GetString(_G.BARSTEWARD_COMPANION_LEVEL) .. BS.LF
        ttt = ttt .. "|cf9f9f9" .. (currentXPInLevel or 0) .. " / " .. totalXPInLevel .. "|r"

        widget.tooltip = ttt

        return widget:GetValue()
    end,
    event = {_G.EVENT_ACTIVE_COMPANION_STATE_CHANGED, _G.EVENT_COMPANION_EXPERIENCE_GAIN},
    icon = "/esoui/art/companion/keyboard/category_u30_companions_up.dds",
    tooltip = GetString(_G.BARSTEWARD_COMPANION_LEVEL),
    hideWhenEqual = "0 (0%)",
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_XP_PC),
            getFunc = function()
                return BS.Vars.Controls[BS.W_COMPANION_LEVEL].ShowXPPC or true
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_COMPANION_LEVEL].ShowXPPC = value
                BS.RefreshWidget(BS.W_COMPANION_LEVEL)
            end,
            width = "full",
            default = true
        }
    }
}
