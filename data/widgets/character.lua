local BS = _G.BarSteward

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
                mundusName = BS.Format(name)

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
            widget:SetColour(unpack(BS.GetColour(this)))

            local tt = BS.Format(_G.SI_CONFIRM_MUNDUS_STONE_TITLE) .. BS.LF
            local desc = BS.Format(GetAbilityDescription(mundusId))

            tt = tt .. "|cf9f9f9" .. desc .. "|r"

            widget.tooltip = tt

            return mundusName
        else
            widget:SetValue(BS.Format(_G.SI_CRAFTING_INVALID_ITEM_STYLE))
            widget:SetColour(unpack(BS.GetColour(this, "Danger")))
        end

        return ""
    end,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_mundusstones_002",
    tooltip = BS.Format(_G.SI_CONFIRM_MUNDUS_STONE_TITLE),
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

BS.widgets[BS.W_RECALL_COOLDOWN] = {
    -- v1.0.2
    name = "recallcooldown",
    update = function(widget)
        local cooldownTime = GetRecallCooldown() / 1000

        widget:SetValue(BS.SecondsToTime(cooldownTime, true, true))
        widget:SetColour(unpack(BS.GetColour(BS.W_RECALL_COOLDOWN)))

        return cooldownTime
    end,
    timer = 1000,
    icon = "zonestories/completiontypeicon_wayshrine",
    tooltip = GetString(_G.BARSTEWARD_RECALL),
    hideWhenEqual = 0
}

BS.widgets[BS.W_ZONE] = {
    -- v1.0.3
    name = "currentZone",
    update = function(widget)
        widget:SetValue(BS.Format(GetUnitZone("player")))
        widget:SetColour(unpack(BS.GetColour(BS.W_ZONE)))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ZONE_CHANGED},
    icon = "tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map",
    tooltip = BS.Format(_G.SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("worldMap")
        else
            SCENE_MANAGER:Show("gamepad_worldMap")
        end
    end
}

BS.widgets[BS.W_PLAYER_NAME] = {
    -- v1.0.3
    name = "playerName",
    update = function(widget)
        local playerName = GetUnitName("player")

        widget:SetValue(ZO_FormatUserFacingDisplayName(playerName))
        widget:SetColour(unpack(BS.GetColour(BS.W_PLAYER_NAME)))

        local classId = GetUnitClassId("player")
        local icon = GetClassIcon(classId)

        widget:SetIcon(icon)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_faceicon_up",
    tooltip = BS.Format(_G.SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(_G.MENU_CATEGORY_CHARACTER)
        else
            SCENE_MANAGER:Show("LevelUpRewardsClaimGamepad")
        end
    end
}

BS.widgets[BS.W_RACE] = {
    -- v1.0.3
    name = "playerRace",
    update = function(widget)
        widget:SetValue(BS.Format(GetUnitRace("player")))
        widget:SetColour(unpack(BS.GetColour(BS.W_RACE)))

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_raceicon_up",
    tooltip = BS.Format(_G.SI_COLLECTIBLERESTRICTIONTYPE1)
}

BS.widgets[BS.W_CLASS] = {
    -- v1.0.3
    name = "playerClass",
    update = function(widget)
        local this = BS.W_CLASS
        local classId = GetUnitClassId("player")
        local icon = GetClassIcon(classId)

        if (not BS.GetVar("NoValue", this)) then
            widget:SetValue(BS.Format(GetUnitClass("player")))
            widget:SetColour(unpack(BS.GetColour(this)))
        end

        widget:SetIcon(icon)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_classicon_up",
    tooltip = BS.Format(_G.SI_COLLECTIBLERESTRICTIONTYPE3),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return BS.Vars.Controls[BS.W_CLASS].NoValue or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CLASS].NoValue = value
                BS.RegenerateBar(BS.Vars.Controls[BS.W_CLASS].Bar)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_ALLIANCE] = {
    -- v1.0.3
    name = "playerAlliance",
    update = function(widget)
        local alliance = GetUnitAlliance("player")
        local icon = ZO_GetAllianceIcon(alliance)
        local colour = GetAllianceColor(alliance)

        if (icon:find("daggerfall")) then
            icon = "scoredisplay/blueflag"
        elseif (icon:find("aldmeri")) then
            icon = "scoredisplay/yellowflag"
        else
            icon = "scoredisplay/redflag"
        end

        if (not BS.GetVar("NoValue", BS.W_ALLIANCE)) then
            widget:SetValue(" " .. BS.Format(GetAllianceName(alliance)))
            widget:SetColour(colour.r, colour.g, colour.b, colour.a)
        end

        widget:SetIcon(icon)
        widget:SetTextureCoords(0, 1, 0, 0.6)

        widget.icon:SetWidth(27)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "scoredisplay/blueflag",
    tooltip = BS.Format(_G.SI_COLLECTIBLERESTRICTIONTYPE2),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("campaignOverview")
        else
            SCENE_MANAGER:Show("gamepad_campaign_root")
        end
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ALLIANCE].NoValue or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ALLIANCE].NoValue = value
                BS.RegenerateBar(BS.Vars.Controls[BS.W_ALLIANCE].Bar)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_SKYSHARDS] = {
    -- v1.2.2
    name = "skyshards",
    update = function(widget)
        local zoneIndex = GetUnitZoneIndex("player")
        local zoneId = GetZoneId(zoneIndex)
        local inZoneSkyshards = GetNumSkyshardsInZone(zoneId)
        local skillSkyShards = GetNumSkyShards()

        if (inZoneSkyshards == 0) then
            zoneId = GetParentZoneId(zoneId)
            inZoneSkyshards = GetNumSkyshardsInZone(zoneId)
        end

        local discoveredInZone = 0

        for skyshard = 1, inZoneSkyshards do
            local skyShardId = GetZoneSkyshardId(zoneId, skyshard)
            if (skyShardId ~= 0) then
                if (GetSkyshardDiscoveryStatus(skyShardId) == _G.SKYSHARD_DISCOVERY_STATUS_ACQUIRED) then
                    discoveredInZone = discoveredInZone + 1
                end
            end
        end

        widget:SetValue(discoveredInZone .. "/" .. inZoneSkyshards)
        widget:SetColour(unpack(BS.GetColour(BS.W_SKYSHARDS)))

        local ttt = BS.Format(_G.SI_MAPFILTER15) .. BS.LF

        ttt = ttt .. "|cffffff" .. zo_strformat(GetString(_G.BARSTEWARD_SKYSHARDS_SKILL_POINTS), skillSkyShards) .. "|r"

        widget.tooltip = ttt
        return discoveredInZone
    end,
    event = _G.EVENT_SKYSHARDS_UPDATED,
    icon = "mappins/skyshard_complete",
    tooltip = BS.Format(_G.SI_MAPFILTER15)
}

BS.widgets[BS.W_SKILL_POINTS] = {
    -- v1.2.2
    name = "skillPoints",
    update = function(widget)
        local unspent = GetAvailableSkillPoints()

        widget:SetValue(unspent)
        widget:SetColour(unpack(BS.GetColour(BS.W_SKILL_POINTS, nil, "DefaultOkColour")))

        return unspent
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_SKILL_POINTS_CHANGED},
    icon = "campaign/campaignbrowser_indexicon_normal_up",
    tooltip = GetString(_G.BARSTEWARD_SKILL_POINTS),
    hideWhenEqual = 0,
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("skills")
        else
            SCENE_MANAGER:Show("gamepad_skills_root")
        end
    end
}

-- based on Ye Olde Speed
-- estimate of units per meter based on some of the tiles in Alinor
local UNITS_PER_METER = 200
local DEFAULT_SPEED = 660

local function GetCurrentPos()
    local _, posX, _, posY = GetUnitRawWorldPosition("player")
    local timestamp = GetGameTimeMilliseconds()

    return {posX, posY, timestamp}
end

local function getSpeed(widget)
    BS.currentPosition = GetCurrentPos()

    local x1, y1, t1 = unpack(BS.currentPosition)
    local x2, y2, t2 = unpack(BS.lastPosition or BS.currentPosition)
    local distance = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
    local timeDelta = (t1 - t2) / 1000
    local speed, speedText, fixWidth
    local this = BS.W_SPEED

    if (BS.GetVar("ShowPercent", this)) then
        local rawSpeed = 0

        if (timeDelta > 0) then
            rawSpeed = distance / timeDelta
        end

        local pSpeed = math.floor((rawSpeed * 100 / DEFAULT_SPEED) + 0.5)

        pSpeed = pSpeed - (pSpeed % 5)

        if (pSpeed < 1) then
            pSpeed = 0
        end

        speedText = ((type(pSpeed) == "number") and pSpeed or 0) .. "%"
        fixWidth = "200%"
    else
        local distanceInMeters = distance / UNITS_PER_METER
        local speedInMS = 0

        if (timeDelta > 0) then
            speedInMS = distanceInMeters / timeDelta
        end

        local units = BS.GetVar("Units", this)

        if (units == "mph") then
            speed = speedInMS * 2.23694
        else
            speed = speedInMS * 3.6
        end

        speed = math.floor(speed)

        local unitText = GetString(_G["BARSTEWARD_" .. units:upper()])

        speedText = ((type(speed) == "number") and speed or 0) .. " " .. unitText
        fixWidth = "88 mph"
    end

    widget:SetValue(speedText, fixWidth)

    BS.lastPosition = BS.currentPosition

    return speed
end

local unitChoices = {GetString(_G.BARSTEWARD_MPH), GetString(_G.BARSTEWARD_KPH)}

BS.widgets[BS.W_SPEED] = {
    -- v1.2.16
    name = "speed",
    update = function(widget)
        return getSpeed(widget)
    end,
    timer = 300,
    icon = "icons/emotes/keyboard/emotecategoryicon_physical_up",
    tooltip = GetString(_G.BARSTEWARD_SPEED),
    customSettings = {
        [1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_SPEED_UNITS),
            choices = unitChoices,
            getFunc = function()
                local units = BS.Vars.Controls[BS.W_SPEED].Units
                return GetString(_G["BARSTEWARD_" .. units:upper()])
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_SPEED].Units = value
                BS.RefreshWidget(BS.W_SPEED)
            end,
            default = BS.Defaults.Controls[BS.W_SPEED].Units
        }
    }
}

BS.widgets[BS.W_PLAYER_LEVEL] = {
    name = "playerLevel",
    update = function(widget)
        local level = GetUnitLevel("player")
        local xp, xpMax, xpPc = 0, 0, 0

        if (level ~= GetMaxLevel()) then
            xp = GetUnitXP("player")
            xpMax = GetNumExperiencePointsInLevel(level)
            xpPc = math.floor((xp / xpMax) * 100)
        end

        widget:SetValue(level .. " (" .. xpPc .. "%)")

        local ttt = BS.Format(_G.SI_CAMPAIGNLEVELREQUIREMENTTYPE1) .. BS.LF
        ttt = ttt .. "|cf9f9f9"
        ttt = ttt .. BS.Format(_G.SI_STAT_GAMEPAD_EXPERIENCE_LABEL) .. "  "
        ttt = ttt .. xp .. " / " .. xpMax .. "|r"

        widget.tooltip = ttt

        return level
    end,
    event = {_G.EVENT_EXPERIENCE_UPDATE, _G.EVENT_LEVEL_UPDATE},
    icon = "icons/alchemy/crafting_alchemy_trait_heroism_match",
    tooltip = BS.Format(_G.SI_CAMPAIGNLEVELREQUIREMENTTYPE1),
    hideWhenEqual = GetMaxLevel()
}

local combatInfo = {}

local function resetCombatInfo()
    combatInfo = {
        DPSOut = 0,
        DPSIn = 0,
        HPSOut = 0,
        HPSAOut = 0,
        HPSIn = 0,
        dpstime = 0,
        hpstime = 0,
        groupDPSOut = 0,
        groupDPSIn = 0,
        groupHPSOut = 0,
        groupHPS = 0
    }
end

-- some elements based on CombatMetrics
local function combatUnitsCallback(_, units)
    combatInfo.units = units
end

local function getSingleTargetDamage()
    local damage, groupDamage, unittime = 0, 0, 0

    for _, unit in pairs(combatInfo.units) do
        local totalUnitDamage = unit.damageOutTotal

        if (totalUnitDamage > 0 and not unit.isFriendly) then
            if totalUnitDamage > damage then
                damage = totalUnitDamage
                groupDamage = unit.groupDamageOut
                unittime = (unit.dpsend or 0) - (unit.dpsstart or 0)
            end
        end
    end

    unittime = unittime > 0 and unittime / 1000 or combatInfo.dpstime

    return damage, groupDamage, unittime
end

local function getBossTargetDamage()
    if (not combatInfo.bossfight) then
        return 0, 0, 0, nil, 0
    end

    local totalBossDamage, bossDamage, bossUnits = 0, 0, 0
    local totalBossGroupDamage = 0
    local bossname
    local starttime
    local endtime

    for _, unit in pairs(combatInfo.units) do
        local totalUnitDamage = unit.damageOutTotal
        local totalUnitGroupDamage = unit.groupDamageOut

        if (unit.bossId ~= nil and totalUnitDamage > 0) then
            totalBossDamage = totalBossDamage + totalUnitDamage
            totalBossGroupDamage = totalBossGroupDamage + totalUnitGroupDamage
            bossUnits = bossUnits + 1

            starttime = math.min(starttime or unit.dpsstart or 0, unit.dpsstart or 0)
            endtime = math.max(endtime or unit.dpsend or 0, unit.dpsend or 0)

            if totalUnitDamage > bossDamage then
                bossname = unit.name
                bossDamage = totalUnitDamage
            end
        end
    end

    if bossUnits == 0 then
        return 0, 0, 0, nil, 0
    end

    local bossTime = (endtime - starttime) / 1000
    bossTime = bossTime > 0 and bossTime or combatInfo.dpstime

    return totalBossDamage, totalBossGroupDamage, bossTime, bossname
end

local dpsWidget
local maxDamage = 0
local damage = {}

local function getAvarageDps()
    local entries = 0
    local total = 0

    for _, dmg in ipairs(damage) do
        entries = entries + 1
        total = total + dmg
    end

    if (entries == 0) then
        return 0
    end

    return zo_floor(total / entries)
end

local function getCombatTime()
    local maxTime = zo_roundToNearest(zo_max(combatInfo.dpstime, combatInfo.hpstime), 0.1)

    return string.format("%d:%04.1f", maxTime / 60, maxTime % 60)
end

local bossIcon = "actionbar/stateoverlay_disease"
local dpsIcon = "compass/ava_daggerfallvaldmeri"

local function updateWidget()
    if ((combatInfo.DPSOut + combatInfo.HPSOut) == 0) then
        return
    end

    if (not dpsWidget) then
        return
    end

    if (BS.LibCombat) then
        local singleTargetDamage, singleTargetDamageGroup, damageTime = 0, 0, 1
        local icon = dpsIcon
        local name

        if combatInfo.bossfight then
            singleTargetDamage, singleTargetDamageGroup, damageTime, name = getBossTargetDamage()
            icon = bossIcon
        end

        if ((singleTargetDamage or 0) == 0) and ((singleTargetDamageGroup or 0) == 0) then
            -- luacheck: push ignore 311
            singleTargetDamage, singleTargetDamageGroup, damageTime = getSingleTargetDamage()
            icon = dpsIcon
        -- luacheck: pop
        end

        damageTime = math.max(damageTime or 1, 1)

        local dps = zo_round((singleTargetDamage or 0) / damageTime)
        local useSeparators = BS.GetVar("UseSeparators", BS.W_DPS)

        if (dps > maxDamage) then
            maxDamage = dps
        end

        table.insert(damage, dps)
        local value = tostring(useSeparators and BS.AddSeparators(dps) or dps)

        dpsWidget:SetValue(value)
        dpsWidget:SetColour(unpack(BS.GetColour(BS.W_DPS)))
        dpsWidget:SetIcon(icon)

        local ttt = GetString(_G.BARSTEWARD_DPS) .. BS.LF
        local gold = " |cffd700"

        ttt = ttt .. "|cf9f9f9" .. GetString(_G.BARSTEWARD_PREVIOUS_ENCOUNTER) .. "|r" .. BS.LF

        if (name) then
            ttt = ttt .. "|c8a2be2w" .. BS.Format(name) .. "|r" .. BS.LF
        end

        ttt = ttt .. GetString(_G.BARSTEWARD_PREVIOUS_ENCOUNTER_AVERAGE) .. gold .. getAvarageDps() .. "|r" .. BS.LF
        ttt = ttt .. GetString(_G.BARSTEWARD_PREVIOUS_ENCOUNTER_MAXIMUM) .. gold .. maxDamage .. "|r" .. BS.LF
        ttt = ttt .. GetString(_G.BARSTEWARD_PREVIOUS_ENCOUNTER_DURATION) .. gold .. getCombatTime() .. "|r"

        dpsWidget.tooltip = ttt
    end
end

local function combatRecapCallback(_, recapData)
    ZO_DeepTableCopy(recapData, combatInfo)

    updateWidget()
end

local function checkLibCombat()
    if (_G.LibCombat) then
        if (not BS.LibCombat) then
            resetCombatInfo()
            BS.LibCombat = _G.LibCombat
            BS.LibCombat:RegisterCallbackType(_G.LIBCOMBAT_EVENT_UNITS, combatUnitsCallback, BS.Name .. "CombatMetrics")
            BS.LibCombat:RegisterCallbackType(
                _G.LIBCOMBAT_EVENT_FIGHTRECAP,
                combatRecapCallback,
                BS.Name .. "CombatMetrics"
            )
        end

        return true
    end

    return false
end

BS.RegisterForEvent(
    _G.EVENT_PLAYER_COMBAT_STATE,
    function(_, inCombat)
        if (inCombat ~= BS.inCombat) then
            if (inCombat) then
                BS.inCombat = true
                maxDamage = 0
                damage = {}
            else
                BS.inCombat = false
            end
        end
    end
)

BS.widgets[BS.W_DPS] = {
    name = "dps",
    update = function(widget)
        dpsWidget = widget
        checkLibCombat()

        if ((widget:GetValue() or "") == "") then
            widget:SetValue(0)
        end

        return 0
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = dpsIcon,
    tooltip = GetString(_G.BARSTEWARD_DPS),
    hideWhenTrue = function()
        return not BS.LibCombat
    end
}

local function getEmptySlotCount()
    local emptySlots = {}
    local championBar = CHAMPION_PERKS:GetChampionBar()
    local foundEmpty = false

    for slot = 1, championBar:GetNumSlots() do
        if (championBar:GetSlot(slot):GetSavedChampionSkillData() == nil) then
            local disciplineId = GetRequiredChampionDisciplineIdForSlot(slot, _G.HOTBAR_CATEGORY_CHAMPION)
            local disciplineName = GetChampionDisciplineName(disciplineId)

            emptySlots[disciplineName] = (emptySlots[disciplineName] or 0) + 1
            foundEmpty = true
        end
    end

    return emptySlots, foundEmpty
end

BS.widgets[BS.W_CHAMPION_POINTS] = {
    name = "championPoints",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = math.floor((xp / xplvl) * 100)
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

            local name = BS.Format(disciplineName)
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
                    ttt = ttt .. icons[discipline] .. " " .. BS.Format(discipline) .. " - " .. empty
                    unslotted = unslotted + empty
                end
            end

            ttt = ttt .. BS.LF .. BS.LF
            ttt = ttt .. BS.Format(_G.SI_STAT_GAMEPAD_EXPERIENCE_LABEL) .. BS.LF
            ttt = ttt .. "|cf9f9f9" .. ZO_CommaDelimitNumber(xp) .. " / " .. ZO_CommaDelimitNumber(xplvl) .. "|r"

            widget.tooltip = ttt
        end

        local value = earned .. " (" .. pc .. "%)"
        local plainValue = value

        if (BS.GetVar("ShowUnspent", this)) then
            if (unspent == 0) then
                value = earned
                plainValue = earned
            else
                value = earned .. " (|cffff00" .. unspent .. "|r)"
                plainValue = earned .. " (" .. unspent .. ")"
            end
        end

        if (BS.GetVar("ShowUnslottedCount", this) and unslotted > 0) then
            plainValue = plainValue .. " - " .. unslotted
            value = value .. " - |cff0000" .. unslotted .. "|r"
        end

        widget:SetColour(unpack(BS.GetColour(this)))
        widget:SetValue(value, plainValue)
        widget:SetIcon(cpicon)

        return earned
    end,
    event = {_G.EVENT_EXPERIENCE_UPDATE, _G.EVENT_UNSPENT_CHAMPION_POINTS_CHANGED},
    icon = "champion/champion_points_magicka_icon-hud",
    tooltip = BS.Format(_G.SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
    hideWhenEqual = 0,
    onClick = function()
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

BS.widgets[BS.W_PLAYER_LOCATION] = {
    -- v1.4.22
    name = "currentLocation",
    update = function(widget, _, _, subZoneName)
        local area = subZoneName

        if ((area or "") == "") then
            area = GetPlayerLocationName()
        end

        widget:SetValue(BS.Format(area))
        widget:SetColour(unpack(BS.GetColour(BS.W_PLAYER_LOCATION)))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ZONE_CHANGED},
    icon = "icons/mapkey/mapkey_player",
    tooltip = GetString(_G.BARSTEWARD_PLAYER_LOCATION),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("worldMap")
        else
            SCENE_MANAGER:Show("gamepad_worldMap")
        end
    end
}

BS.widgets[BS.W_PLAYER_EXPERIENCE] = {
    --v1.4.23
    name = "playerExperience",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = math.floor((xp / xplvl) * 100)
        local this = BS.W_PLAYER_EXPERIENCE
        local out

        if (BS.GetVar("ShowPercent", this)) then
            out = pc .. "%"
        else
            if (BS.GetVar("UseSeparators", this) == true) then
                xp = BS.AddSeparators(xp)
                xplvl = BS.AddSeparators(xplvl)
            end

            out = xp .. " / " .. xplvl
        end

        widget:SetColour(unpack(BS.GetColour(this)))
        widget:SetValue(out)

        return xp
    end,
    event = _G.EVENT_EXPERIENCE_UPDATE,
    icon = "icons/icon_experience",
    tooltip = GetString(_G.BARSTEWARD_PLAYER_EXPERIENCE)
}

BS.widgets[BS.W_VAMPIRISM] = {
    -- v1.4.37
    name = "vampirismStage",
    update = function(widget)
        local name, icon
        local isVampire = false
        local started, ending

        for buffNum = 1, GetNumBuffs("player") do
            local buffName, buffStarted, buffEnding, _, _, buffIcon, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.VAMPIRE_STAGES[id]) then
                isVampire = true
                name = buffName
                started = buffStarted
                ending = buffEnding
                icon = buffIcon
                break
            end
        end

        local text = GetString(_G.BARSTEWARD_NOT_VAMPIRE)

        if (isVampire) then
            text = BS.Format(name)

            if (ending - started > 0) then
                widget:StartCooldown(ending - GetGameTimeSeconds(), ending - started, true)
            end
        end

        widget:SetValue(text)
        widget:SetColour(unpack(BS.GetColour(BS.W_VAMPIRISM)))

        local tt = BS.Format(_G.SI_CURSETYPE1)
        tt = tt .. BS.LF .. "|cf9f9f9" .. text .. "|r"

        widget.tooltip = tt

        if (icon) then
            widget:SetIcon(icon)
        end

        return isVampire and "vampire" or ""
    end,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_u26_vampire_infection_stage4",
    tooltip = BS.Format(_G.SI_CURSETYPE1),
    cooldown = true,
    hideWhenEqual = ""
}

BS.widgets[BS.W_VAMPIRISM_TIMER] = {
    -- v1.4.37
    name = "vampirismTimer",
    update = function(widget)
        local name, icon, plainValue, value
        local isVampire = false
        local ending, stage
        local this = BS.W_VAMPIRISM_TIMER

        for buffNum = 1, GetNumBuffs("player") do
            local buffName, _, buffEnding, _, _, buffIcon, _, _, _, _, id = GetUnitBuffInfo("player", buffNum)

            if (BS.VAMPIRE_STAGES[id]) then
                isVampire = true
                stage = BS.VAMPIRE_STAGES[id]
                name = buffName
                ending = buffEnding
                icon = buffIcon
                break
            end
        end

        local remaining = 0
        local time = ""
        local colour = BS.GetColour(this, "Ok")

        if (isVampire) then
            remaining = ending - GetGameTimeSeconds()

            if (remaining < 0) then
                remaining = 0
            end

            time = BS.SecondsToTime(remaining, true, false, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))
            colour = BS.GetTimeColour(remaining, this, 60) or colour
        end

        widget:SetColour(unpack(colour))

        if (BS.GetVar("ShowStage", this)) then
            plainValue = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE), time, "", stage, "|r")
            value = zo_strformat(GetString(_G.BARSTEWARD_VAMPIRE_STAGE), time, "|cf9f9f9", stage, "|r")
        else
            plainValue = time
            value = time
        end

        widget:SetValue(value, plainValue)

        local tt = BS.Format(_G.SI_CURSETYPE1)

        if (isVampire) then
            tt = tt .. BS.LF .. "|cf9f9f9" .. BS.Format(name) .. "|r"
        end

        widget.tooltip = tt

        if (icon) then
            widget:SetIcon(icon)
        end

        return remaining
    end,
    timer = 1000,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
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
        local colour = BS.GetColour(this, "Ok")

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

                colour = BS.GetTimeColour(remaining, this, 60) or colour
            end
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(time)

        local tt = GetString(_G.BARSTEWARD_VAMPIRE_FEED_TIMER)

        if (isVampireWithFeed) then
            tt = tt .. BS.LF .. "|cf9f9f9" .. BS.Format(name) .. "|r"
        end

        widget.tooltip = tt

        if (icon) then
            widget:SetIcon(icon)
        end

        return remaining
    end,
    timer = 1000,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "icons/ability_u26_vampire_synergy_feed",
    tooltip = GetString(_G.BARSTEWARD_VAMPIRE_FEED_TIMER),
    hideWhenEqual = 0
}
