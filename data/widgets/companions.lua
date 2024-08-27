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

        if (rapportPcMax <= 0) then
            rapportPcMax = 1
        end

        local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
        local r, g, b = BS.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

        widget:SetColour(r, g, b, 1)
        widget:SetValue(rapportValue)

        local level = GetActiveCompanionRapportLevel()
        local desc = GetActiveCompanionRapportLevelDescription(level)

        widget:SetTooltip(GetString(_G.BARSTEWARD_RAPPORT) .. BS.LF .. BS.COLOURS.OffWhite:Colorize(desc))

        return rapportValue
    end,
    event = {_G.EVENT_COMPANION_RAPPORT_UPDATE, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED},
    icon = "hud/lootHistory_icon_rapportincrease_generic",
    tooltip = GetString(_G.BARSTEWARD_RAPPORT),
    hideWhenEqual = function()
        if (HasActiveCompanion()) then
            return GetMaximumRapport()
        else
            return 0
        end
    end
}

local isMaxLevel
local companionCurrentLevel = -1

BS.widgets[BS.W_COMPANION_LEVEL] = {
    -- v1.2.19
    name = "companionLevel",
    update = function(widget)
        local this = BS.W_COMPANION_LEVEL
        local companionLevel, currentXPInLevel = GetActiveCompanionLevelInfo()
        local totalXPInLevel = GetNumExperiencePointsInCompanionLevel(companionLevel + 1) or 0
        local percent = 0

        isMaxLevel = totalXPInLevel == 0
        companionCurrentLevel = companionLevel

        if (not isMaxLevel) then
            percent = math.max(zo_roundToNearest((currentXPInLevel or 0) / totalXPInLevel, 0.01), 0) * 100
        elseif (BS.GetVar("HideWhenMaxLevel", this)) then
            return companionLevel
        end

        local text = companionLevel

        if (BS.GetVar("ShowXPPC", this) and not isMaxLevel) then
            text = text .. " (" .. percent .. "%)"
        end

        local companionDefId = GetActiveCompanionDefId()
        local collectibleId = GetCompanionCollectibleId(companionDefId)
        local _, _, icon = GetCollectibleInfo(collectibleId)

        widget:SetIcon(icon)
        widget:SetValue(text)
        widget:SetColour(BS.GetColour(this, true))

        local ttt = GetString(_G.BARSTEWARD_COMPANION_LEVEL) .. BS.LF
        local progress = (currentXPInLevel or 0) .. " / " .. totalXPInLevel

        if (progress == "0 / 0") then
            progress = BS.Format(_G.SI_EXPERIENCE_LIMIT_REACHED)
        end

        ttt = ttt .. BS.COLOURS.OffWhite:Colorize(progress)

        widget:SetTooltip(ttt)

        return companionLevel
    end,
    event = {_G.EVENT_ACTIVE_COMPANION_STATE_CHANGED, _G.EVENT_COMPANION_EXPERIENCE_GAIN},
    icon = "companion/keyboard/category_u30_companions_up",
    tooltip = GetString(_G.BARSTEWARD_COMPANION_LEVEL),
    hideWhenEqual = 0,
    hideWhenMaxLevel = function()
        if (not BS.Vars.Controls[BS.W_COMPANION_LEVEL].HideWhenMaxLevel) then
            return -1
        end

        if (isMaxLevel) then
            return companionCurrentLevel
        else
            return -1
        end
    end,
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

local companionIcons = {}

for k, v in pairs(BS.COMPANION_DEFIDS) do
    companionIcons[k] = select(3, GetCollectibleInfo(GetCompanionCollectibleId(v)))

    BS.widgets[k] = {
        --v1.7.0
        name = string.format("companion%d", k),
        update = function(widget)
            local this = k
            local name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(v)))

            widget:SetValue(name)
            widget:SetColour(BS.GetColour(this, true))

            return name
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        tooltip = zo_strformat(
            GetString(_G.BARSTEWARD_COMPANION_WIDGET),
            ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(GetCompanionCollectibleId(v)))
        ),
        icon = companionIcons[k],
        onLeftClick = function()
            UseCollectible(GetCompanionCollectibleId(v))
        end,
        customSettings = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_HIDE_TEXT),
                getFunc = function()
                    return BS.Vars.Controls[k].NoValue or false
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].NoValue = value
                    BS.GetWidget(k):SetNoValue(value)
                    BS.RegenerateBar(BS.Vars.Controls[k].Bar, k)
                end,
                width = "full",
                default = false
            }
        }
    }
end
