local BS = _G.BarSteward
local iconPaths = {
    "/esoui/art/lfg/lfg_dps_up_64.dds",
    "/esoui/art/icons/ability_templar_ripping_spear.dds",
    "/esoui/art/lfg/lfg_healer_up_64.dds",
    "/esoui/art/icons/ability_companion_templar_cleansing_ritual.dds",
    "/esoui/art/lfg/lfg_tank_up_64.dds",
    "/esoui/art/icons/ability_1handed_004_a.dds",
    "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    "/esoui/art/tradinghouse/tradinghouse_weapons_1h_sword_up.dds"
}

local ignoreTypes = {
    [_G.ZONE_DISPLAY_TYPE_NONE] = true,
    [_G.ZONE_DISPLAY_TYPE_HOUSING] = true,
    [_G.ZONE_DISPLAY_TYPE_ZONE_STORY] = true
}

BS.widgets[BS.W_ACTIVE_BAR] = {
    -- v1.3.18
    name = "activeBar",
    update = function(widget, event, _, _, _, instanceDisplayType)
        local this = BS.W_ACTIVE_BAR
        local activeWeaponPair = GetActiveWeaponPairInfo()
        local mainIcon = BS.GetVar("MainIcon", this) or BS.Defaults.MainBarIcon
        local backIcon = BS.GetVar("BackIcon", this) or BS.Defaults.BackBarIcon
        local icon = activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP and backIcon or mainIcon
        local text =
            activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP and GetString(_G.BARSTEWARD_BACK_BAR) or
            GetString(_G.BARSTEWARD_MAIN_BAR)

        if (event == _G.EVENT_PREPARE_FOR_JUMP and BS.GetVar("Warn", this)) then
            if (not ignoreTypes[instanceDisplayType]) then
                if
                    (activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP or
                        (activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_MAIN and not BS.GetVar("WarnOnBackOnly", this)))
                 then
                    zo_callLater(
                        function()
                            BS.Announce(
                                GetString(_G.BARSTEWARD_WARNING),
                                zo_strformat(GetString(_G.BARSTEWARD_WARN_INSTANCE_MESSAGE), text),
                                this,
                                nil,
                                nil,
                                icon
                            )
                        end,
                        2000
                    )
                end
            end
        else
            local colour

            if (activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP) then
                colour = BS.GetColour(this, "Back", "DefaultColour", true)
            else
                colour = BS.GetColour(this, "Main", "DefaultColour", true)
            end

            widget:SetColour(colour)
            widget:SetValue(text)
            widget:SetIcon(icon)
        end

        return activeWeaponPair
    end,
    event = {_G.EVENT_ACTIVE_WEAPON_PAIR_CHANGED, _G.EVENT_PREPARE_FOR_JUMP},
    icon = "tradinghouse/category_u30_equipment_up",
    tooltip = GetString(_G.BARSTEWARD_ACTIVE_BAR),
    customSettings = {
        [1] = {
            type = "iconpicker",
            name = GetString(_G.BARSTEWARD_MAIN_BAR_ICON),
            choices = iconPaths,
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].MainIcon or BS.Defaults.MainBarIcon
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].MainIcon = value
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            iconSize = 48,
            width = "full",
            default = BS.Defaults.MainBarIcon
        },
        [2] = {
            type = "iconpicker",
            name = GetString(_G.BARSTEWARD_BACK_BAR_ICON),
            choices = iconPaths,
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].BackIcon or BS.Defaults.MainBarIcon
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].BackIcon = value
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            iconSize = 48,
            width = "full",
            default = BS.Defaults.BackBarIcon
        },
        [3] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_MAIN_BAR_TEXT),
            getFunc = function()
                return unpack(BS.Vars.Controls[BS.W_ACTIVE_BAR].MainColour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].MainColour = {r, g, b, a}
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            width = "full",
            default = unpack(BS.Defaults.DefaultColour)
        },
        [4] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_BACK_BAR_TEXT),
            getFunc = function()
                return unpack(BS.Vars.Controls[BS.W_ACTIVE_BAR].BackColour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].BackColour = {r, g, b, a}
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            width = "full",
            default = unpack(BS.Defaults.DefaultColour)
        },
        [5] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_WARN_INSTANCE),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn = value
            end,
            width = "full",
            default = false
        },
        [6] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_WARN_INSTANCE_BACK_BAR),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].WarnOnBackOnly or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].WarnOnBackOnly = value
            end,
            disable = function()
                return not BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_SCRYING] = {
    -- v3.2.6
    name = "scrying",
    update = function(widget, event, skillType, skillLineIndex)
        local lineId = GetAntiquityScryingSkillLineId()
        local scryType, scryIndex = GetSkillLineIndicesFromSkillLineId(lineId)

        if (event == "initial" or (skillType == scryType and skillLineIndex == scryIndex)) then
            local this = BS.W_SCRYING
            local useProgress = BS.GetVar("Progress", this)

            if (ZO_IsScryingUnlocked()) then
                if (useProgress) then
                    widget:SetProgress(0, 0, 1)
                else
                    widget:SetValue("0")
                end
            else
                local lineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(lineId)
                local name = BS.Format(lineData:GetName())
                local rank = lineData:GetCurrentRank()
                local lastXP, nextXP, currentXP = lineData:GetRankXPValues()
                local currentProgress, maxProgress = (currentXP - lastXP), (nextXP - lastXP)

                if (useProgress) then
                    widget:SetProgress(currentProgress, 0, maxProgress, rank)
                else
                    widget:SetValue(string.format("%s (%s/%s)", rank, currentProgress, maxProgress))
                    widget:SetColour(BS.GetColour(this, true))
                end

                local ttt = name .. BS.LF

                ttt = ttt .. BS.Format(_G.SI_STAT_TRADESKILL_RANK) .. " " .. rank .. BS.LF
                ttt = ttt .. BS.Format(_G.SI_EXPERIENCE_CURRENT_MAX, currentProgress, maxProgress)

                widget:SetTooltip(ttt)

                return rank
            end
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_SCRYING].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_SCRYING].GradientEnd or endg

        return s, e
    end,
    event = _G.EVENT_SKILL_XP_UPDATE,
    icon = "icons/ability_scrying_05b",
    tooltip = function()
        local lineId = GetAntiquityScryingSkillLineId()
        local lineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(lineId)

        return BS.Format(lineData:GetName())
    end
}
