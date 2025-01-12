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
    [ZONE_DISPLAY_TYPE_NONE] = true,
    [ZONE_DISPLAY_TYPE_HOUSING] = true,
    [ZONE_DISPLAY_TYPE_ZONE_STORY] = true
}

BS.widgets[BS.W_ACTIVE_BAR] = {
    -- v1.3.18
    name = "activeBar",
    update = function(widget, event, _, _, _, instanceDisplayType)
        local this = BS.W_ACTIVE_BAR
        local activeWeaponPair = GetActiveWeaponPairInfo()
        local mainIcon = BS.GetVar("MainIcon", this) or BS.Defaults.MainBarIcon
        local backIcon = BS.GetVar("BackIcon", this) or BS.Defaults.BackBarIcon
        local icon = activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP and backIcon or mainIcon
        local text =
            activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP and GetString(_G.BARSTEWARD_BACK_BAR) or
            GetString(_G.BARSTEWARD_MAIN_BAR)

        if (event == EVENT_PREPARE_FOR_JUMP and BS.GetVar("Warn", this)) then
            if (not ignoreTypes[instanceDisplayType]) then
                if
                    (activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP or
                        (activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN and not BS.GetVar("WarnOnBackOnly", this)))
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

            if (activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP) then
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
    event = {EVENT_ACTIVE_WEAPON_PAIR_CHANGED, EVENT_PREPARE_FOR_JUMP},
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

            if (not ZO_IsScryingUnlocked()) then
                if (useProgress) then
                    widget:SetProgress(0, 0, 1)
                else
                    widget:SetValue("0")
                end
            else
                local lineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(lineId)
                local name = BS.LC.Format(lineData:GetName())
                local rank = lineData:GetCurrentRank()
                local lastXP, nextXP, currentXP = lineData:GetRankXPValues()
                local currentProgress, maxProgress = (currentXP - lastXP), (nextXP - lastXP)

                if (useProgress) then
                    widget:SetProgress(currentProgress, 0, maxProgress, rank)
                else
                    widget:SetValue(string.format("%s (%s/%s)", rank, currentProgress, maxProgress))
                    widget:SetColour(BS.GetColour(this, true))
                end

                local tt = name .. BS.LF
                local ttt = BS.LC.Format(SI_STAT_TRADESKILL_RANK) .. " " .. rank .. BS.LF

                ttt = ttt .. ZO_CachedStrFormat(SI_EXPERIENCE_CURRENT_MAX, currentProgress, maxProgress)

                tt = tt .. BS.LC.White:Colorize(ttt)

                widget:SetTooltip(tt)

                return rank
            end
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_SCRYING].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_SCRYING].GradientEnd or endg

        return s, e
    end,
    event = EVENT_SKILL_XP_UPDATE,
    callback = {
        [SKILLS_DATA_MANAGER] = {event = "FullSystemUpdated", label = "initial"}
    },
    icon = "icons/ability_scrying_05b",
    tooltip = function()
        local lineId = GetAntiquityScryingSkillLineId()
        local lineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(lineId)

        return BS.LC.Format(lineData:GetName())
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_SCRYING].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_SCRYING].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        }
    }
}

BS.widgets[BS.W_VAMPIRISM] = {
    -- v1.4.37
    name = "vampirismStage",
    update = function(widget)
        local this = BS.W_VAMPIRISM
        local name, icon, stage
        local isVampire = false
        local started, ending

        for buffNum = 1, GetNumBuffs("player") do
            local buffName, buffStarted, buffEnding, _, _, buffIcon, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.VAMPIRE_STAGES[id]) then
                ending = buffEnding
                icon = buffIcon
                isVampire = true
                name = buffName
                stage = BS.VAMPIRE_STAGES[id]
                started = buffStarted
                break
            end
        end

        local displayText
        local text = GetString(_G.BARSTEWARD_NOT_VAMPIRE)

        if (isVampire) then
            text = BS.LC.Format(name)

            if (ending - started > 0) then
                widget:StartCooldown(ending - GetGameTimeSeconds(), ending - started, true)
            end
        end

        if (BS.GetVar("Numeric", this)) then
            displayText = ZO_CachedStrFormat("<<R:1>>", stage)
        else
            displayText = text
        end

        widget:SetValue(displayText)
        widget:SetColour(BS.GetColour(this, true))

        local tt = BS.LC.Format(SI_CURSETYPE1)
        tt = tt .. BS.LF .. BS.COLOURS.White:Colorize(text)

        widget:SetTooltip(tt)

        if (icon) then
            widget:SetIcon(icon)
        end

        return isVampire and "vampire" or ""
    end,
    event = EVENT_EFFECT_CHANGED,
    filter = {[EVENT_EFFECT_CHANGED] = {REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_u26_vampire_infection_stage4",
    tooltip = BS.LC.Format(SI_CURSETYPE1),
    cooldown = true,
    hideWhenEqual = "",
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_VAMPIRE_STAGE_NUMERIC),
            getFunc = function()
                return BS.Vars.Controls[BS.W_VAMPIRISM].Numeric
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_VAMPIRISM].Numeric = value
                BS.RefreshWidget(BS.W_VAMPIRISM)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_VAMPIRISM_TIMER] = {
    -- v1.4.37
    name = "vampirismTimer",
    update = function(widget)
        local name, plainValue, value
        local isVampire = false
        local ending, stage
        local this = BS.W_VAMPIRISM_TIMER

        for buffNum = 1, GetNumBuffs("player") do
            local buffName, _, buffEnding, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.VAMPIRE_STAGES[id]) then
                ending = buffEnding
                isVampire = true
                name = buffName
                stage = BS.VAMPIRE_STAGES[id]
                break
            end
        end

        local remaining = 0
        local time = ""
        local colour = BS.COLOURS.DefaultOkColour

        if (isVampire) then
            remaining = ending - GetGameTimeSeconds()

            if (remaining < 0) then
                remaining = 0
            end

            time = BS.SecondsToTime(remaining, true, false, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))
            colour = BS.GetTimeColour(remaining, this, 60, true, true)
        end

        widget:SetColour(colour)

        if (BS.GetVar("ShowStage", this)) then
            if (BS.GetVar("Numeric", this)) then
                local s = ZO_CachedStrFormat("<<R:1>>", stage)

                plainValue = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE_NUMERALS), time, "", s, "xxxx")
                value = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE_NUMERALS), time, "|cf9f9f9", s, "|r")
            else
                plainValue = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE), time, "", stage, "xxxx")
                value = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE), time, "|cf9f9f9", stage, "|r")
            end
        else
            plainValue = time
            value = time
        end

        widget:SetValue(value, plainValue)

        local tt = GetString(_G.BARSTEWARD_VAMPIRE_STAGE_TIMER)

        if (isVampire) then
            tt = tt .. BS.LF .. BS.COLOURS.White:Colorize(BS.LC.Format(name))
        end

        widget:SetTooltip(tt)

        return remaining
    end,
    timer = 1000,
    event = EVENT_EFFECT_CHANGED,
    filter = {[EVENT_EFFECT_CHANGED] = {REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/store_vampirebite_01",
    tooltip = GetString(_G.BARSTEWARD_VAMPIRE_STAGE_TIMER),
    hideWhenEqual = 0,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_VAMPIRE_SHOW_STAGE),
            getFunc = function()
                return BS.Vars.Controls[BS.W_VAMPIRISM_TIMER].ShowStage or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_VAMPIRISM_TIMER].ShowStage = value
                BS.RefreshWidget(BS.W_VAMPIRISM_TIMER)
            end,
            width = "full",
            default = false
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_VAMPIRE_STAGE_NUMERIC),
            getFunc = function()
                return BS.Vars.Controls[BS.W_VAMPIRISM_TIMER].Numeric
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_VAMPIRISM_TIMER].Numeric = value
                BS.RefreshWidget(BS.W_VAMPIRISM_TIMER)
            end,
            disabled = function()
                return not BS.Vars.Controls[BS.W_VAMPIRISM_TIMER].ShowStage
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_VAMPIRISM_FEED_TIMER] = {
    -- v1.4.37
    name = "vampirismFeedTimer",
    update = function(widget)
        local name, icon
        local isVampireWithFeed = false
        local ending
        local this = BS.W_VAMPIRISM_FEED_TIMER

        for buffNum = 1, GetNumBuffs("player") do
            local buffName, _, buffEnding, _, _, buffIcon, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.VAMPIRE_FEED[id]) then
                isVampireWithFeed = true
                name = buffName
                ending = buffEnding
                icon = buffIcon
                break
            end
        end

        local remaining = 0
        local time = ""
        local colour = BS.COLOURS.DefaultOkColour

        if (isVampireWithFeed) then
            remaining = ending - GetGameTimeSeconds()

            if (remaining > 0) then
                time =
                    BS.SecondsToTime(
                    remaining,
                    false,
                    false,
                    BS.GetVar("HideSeconds", this),
                    BS.GetVar("Format", this),
                    BS.GetVar("HideDaysWhenZero", this)
                )

                colour = BS.GetTimeColour(remaining, this, 60, true, true)
            end
        end

        widget:SetColour(colour)
        widget:SetValue(time)

        local tt = GetString(_G.BARSTEWARD_VAMPIRE_FEED_TIMER)

        if (isVampireWithFeed) then
            tt = tt .. BS.LF .. BS.COLOURS.White:Colorize(BS.LC.Format(name))
        end

        widget:SetTooltip(tt)

        if (icon) then
            widget:SetIcon(icon)
        end

        return remaining
    end,
    timer = 1000,
    event = EVENT_EFFECT_CHANGED,
    filter = {[EVENT_EFFECT_CHANGED] = {REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_u26_vampire_synergy_feed",
    tooltip = GetString(_G.BARSTEWARD_VAMPIRE_FEED_TIMER),
    hideWhenEqual = 0
}

local function getEmptySlotCount()
    local emptySlots = {}
    local championBar = CHAMPION_PERKS:GetChampionBar()
    local foundEmpty = false

    if (championBar) then
        for slot = 1, championBar:GetNumSlots() do
            if (championBar:GetSlot(slot):GetSavedChampionSkillData() == nil) then
                local disciplineId = GetRequiredChampionDisciplineIdForSlot(slot, HOTBAR_CATEGORY_CHAMPION)
                local disciplineName = GetChampionDisciplineName(disciplineId)

                emptySlots[disciplineName] = (emptySlots[disciplineName] or 0) + 1
                foundEmpty = true
            end
        end
    end

    return emptySlots, foundEmpty
end

BS.widgets[BS.W_CHAMPION_POINTS] = {
    name = "championPoints",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = BS.LC.ToPercent(xp, xplvl)
        local disciplineType = GetChampionPointPoolForRank(earned + 1)
        local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(disciplineType)
        local cpicon = disciplineData:GetHUDIcon()
        local this = BS.W_CHAMPION_POINTS
        local cp = {}

        if (BS.GetVar("UseSeparators", this) == true) then
            earned = BS.AddSeparators(earned)
        end

        local icons = {}
        local unspent = 0

        for disciplineIndex = 1, GetNumChampionDisciplines() do
            local id = GetChampionDisciplineId(disciplineIndex)

            disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataById(id)

            local icon = BS.Icon(disciplineData:GetHUDIcon())
            local disciplineName = GetChampionDisciplineName(id)

            icons[disciplineName] = icon

            local name = BS.LC.Format(disciplineName)
            local toSpend = disciplineData:GetNumSavedUnspentPoints()

            unspent = unspent + toSpend

            table.insert(cp, icon .. " " .. name .. " - " .. toSpend)
        end

        local unslotted = 0

        if (#cp > 0) then
            local ttt = GetString(_G.BARSTEWARD_UNSPENT)

            for _, c in ipairs(cp) do
                if (ttt ~= "") then
                    ttt = ttt .. BS.LF
                end

                ttt = ttt .. c
            end

            local emptySlots, foundEmpty = getEmptySlotCount()

            if (foundEmpty) then
                ttt = ttt .. BS.LF .. BS.LF .. GetString(_G.BARSTEWARD_UNSLOTTED)
                for discipline, empty in pairs(emptySlots) do
                    ttt = ttt .. BS.LF
                    ttt = ttt .. icons[discipline] .. " " .. BS.LC.Format(discipline) .. " - " .. empty
                    unslotted = unslotted + empty
                end
            end

            local ttext = ZO_CommaDelimitNumber(xp) .. " / " .. ZO_CommaDelimitNumber(xplvl)

            ttt = ttt .. BS.LF .. BS.LF
            ttt = ttt .. BS.LC.Format(SI_STAT_GAMEPAD_EXPERIENCE_LABEL) .. BS.LF
            ttt = ttt .. BS.COLOURS.White:Colorize(ttext)

            widget:SetTooltip(ttt)
        end

        local value = earned .. " (" .. pc .. "%)"
        local plainValue = value

        if (BS.GetVar("ShowUnspent", this)) then
            if (unspent == 0) then
                value = earned
                plainValue = earned
            else
                value = earned .. " (" .. BS.COLOURS.Yellow:Colorize(unspent) .. ")"
                plainValue = earned .. " (" .. unspent .. ")"
            end
        end

        if (BS.GetVar("ShowUnslottedCount", this) and unslotted > 0) then
            plainValue = plainValue .. " - " .. unslotted
            value = value .. " - " .. BS.COLOURS.Red:Colorize(unslotted)
        end

        widget:SetColour(BS.GetColour(this, true))
        widget:SetValue(value, plainValue)
        widget:SetIcon(cpicon)

        return earned
    end,
    event = {EVENT_EXPERIENCE_UPDATE, EVENT_UNSPENT_CHAMPION_POINTS_CHANGED},
    icon = "champion/champion_points_magicka_icon-hud",
    tooltip = BS.LC.Format(SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            MAIN_MENU_KEYBOARD:ShowScene("championPerks")
        else
            MAIN_MENU_GAMEPAD:ShowScene("gamepad_championPerks_root")
        end
    end,
    customSettings = {
        [1] = {
            name = GetString(_G.BARSTEWARD_UNSLOTTED_OPTION),
            tooltip = GetString(_G.BARSTEWARD_UNSLOTTED_TOOLTIP),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnslottedCount
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnslottedCount = value
                BS.RefreshWidget(BS.W_CHAMPION_POINTS)
            end,
            width = "full",
            default = false
        },
        [2] = {
            name = GetString(_G.BARSTEWARD_SHOW_UNSPENT),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnspent
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CHAMPION_POINTS].ShowUnspent = value
                BS.RefreshWidget(BS.W_CHAMPION_POINTS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_SKILL_POINTS] = {
    -- v1.2.2
    name = "skillPoints",
    update = function(widget)
        local unspent = GetAvailableSkillPoints()

        widget:SetValue(unspent)
        widget:SetColour(BS.GetColour(BS.W_SKILL_POINTS, nil, "DefaultOkColour", true))

        return unspent
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_SKILL_POINTS_CHANGED},
    icon = "campaign/campaignbrowser_indexicon_normal_up",
    tooltip = GetString(_G.BARSTEWARD_SKILL_POINTS),
    hideWhenEqual = 0,
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("skills")
        else
            SCENE_MANAGER:Show("gamepad_skills_root")
        end
    end
}

BS.widgets[BS.W_MUNDUS_STONE] = {
    -- v1.0.1
    name = "mundusstone",
    update = function(widget)
        local this = BS.W_MUNDUS_STONE
        local mundusId, mundusName, mundusIcon

        for buffNum = 1, GetNumBuffs("player") do
            local name, _, _, _, _, icon, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.MUNDUS_STONES[id]) then
                mundusIcon = icon
                mundusId = id
                mundusName = BS.LC.Format(name)

                if (BS.GetVar("Shorten", this)) then
                    local colonPosition = mundusName:find(":")

                    mundusName = mundusName:gsub(mundusName:sub(1, colonPosition + 1), "")
                end

                break
            end
        end

        if (mundusId ~= nil) then
            widget:SetIcon(mundusIcon)
            widget:SetValue(mundusName)
            widget:SetColour(BS.GetColour(this, true))

            local tt = BS.LC.Format(SI_CONFIRM_MUNDUS_STONE_TITLE) .. BS.LF
            local desc = BS.LC.Format(GetAbilityDescription(mundusId))

            tt = tt .. BS.COLOURS.White:Colorize(desc)

            widget:SetTooltip(tt)

            return mundusName
        else
            widget:SetValue(BS.LC.Format(SI_CRAFTING_INVALID_ITEM_STYLE))
            widget:SetColour(BS.GetColour(this, "Danger", true))
        end

        return ""
    end,
    event = EVENT_EFFECT_CHANGED,
    filter = {[EVENT_EFFECT_CHANGED] = {REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_mundusstones_002",
    tooltip = BS.LC.Format(SI_CONFIRM_MUNDUS_STONE_TITLE),
    hideWhenEqual = "",
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHORTEN),
            getFunc = function()
                return BS.Vars.Controls[BS.W_MUNDUS_STONE].Shorten or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_MUNDUS_STONE].Shorten = value
                BS.RefreshWidget(BS.W_MUNDUS_STONE)
            end,
            width = "full",
            default = false
        }
    }
}
