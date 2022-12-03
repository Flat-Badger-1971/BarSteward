local BS = _G.BarSteward

BS.widgets[BS.W_MUNDUS_STONE] = {
    -- v1.0.1
    name = "mundusstone",
    update = function(widget)
        local mundusId = nil

        for buffNum = 1, GetNumBuffs("player") do
            local id = select(11, GetUnitBuffInfo("player", buffNum))

            if (BS.MUNDUS_STONES[id]) then
                mundusId = id
                break
            end
        end

        if (mundusId ~= nil) then
            local icon = GetAbilityIcon(mundusId)
            local name = ZO_CachedStrFormat("<<C:1>>", GetAbilityName(mundusId))

            widget:SetIcon(icon)
            widget:SetValue(name)
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_MUNDUS_STONE].Colour or BS.Vars.DefaultColour))

            return name
        else
            widget:SetValue(ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CRAFTING_INVALID_ITEM_STYLE)))
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_MUNDUS_STONE].DangerColour or BS.Vars.DefaultDangerColour))
        end

        return ""
    end,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "/esoui/art/icons/ability_mundusstones_002.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CONFIRM_MUNDUS_STONE_TITLE)),
    hideWhenEqual = ""
}

BS.widgets[BS.W_RECALL_COOLDOWN] = {
    -- v1.0.2
    name = "recallcooldown",
    update = function(widget)
        local cooldownTime = GetRecallCooldown() / 1000

        widget:SetValue(BS.SecondsToTime(cooldownTime, true, true))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_RECALL_COOLDOWN].Colour or BS.Vars.DefaultColour))

        return cooldownTime
    end,
    timer = 1000,
    icon = "/esoui/art/zonestories/completiontypeicon_wayshrine.dds",
    tooltip = GetString(_G.BARSTEWARD_RECALL),
    hideWhenEqual = 0
}

BS.widgets[BS.W_ZONE] = {
    -- v1.0.3
    name = "currentZone",
    update = function(widget)
        widget:SetValue(ZO_CachedStrFormat("<<C:1>>", GetUnitZone("player")))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_ZONE].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ZONE_CHANGED},
    icon = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY)),
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
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_PLAYER_NAME].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME)),
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
        widget:SetValue(ZO_CachedStrFormat("<<C:1>>", GetUnitRace("player")))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_RACE].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE1))
}

BS.widgets[BS.W_CLASS] = {
    -- v1.0.3
    name = "playerClass",
    update = function(widget)
        local classId = GetUnitClassId("player")
        local icon = GetClassIcon(classId)

        widget:SetValue(ZO_CachedStrFormat("<<C:1>>", GetUnitClass("player")))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_CLASS].Colour or BS.Vars.DefaultColour))
        widget:SetIcon(icon)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_classicon_up.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE3))
}

BS.widgets[BS.W_ALLIANCE] = {
    -- v1.0.3
    name = "playerAlliance",
    update = function(widget)
        local alliance = GetUnitAlliance("player")
        local icon = ZO_GetAllianceIcon(alliance)
        local colour = GetAllianceColor(alliance)

        if (string.find(icon, "daggerfall")) then
            icon = "/esoui/art/scoredisplay/blueflag.dds"
        elseif (string.find(icon, "aldmeri")) then
            icon = "/esoui/art/scoredisplay/yellowflag.dds"
        else
            icon = "/esoui/art/scoredisplay/redflag.dds"
        end

        widget:SetValue(" " .. ZO_CachedStrFormat("<<C:1>>", GetAllianceName(alliance)))
        widget:SetColour(colour.r, colour.g, colour.b, colour.a)
        widget:SetIcon(icon)
        widget:SetTextureCoords(0, 1, 0, 0.6)
        widget.icon:SetWidth(27)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/scoredisplay/blueflag.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE2)),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("campaignOverview")
        else
            SCENE_MANAGER:Show("gamepad_campaign_root")
        end
    end
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
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_SKYSHARDS].Colour or BS.Vars.DefaultColour))

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_MAPFILTER15)) .. BS.LF
        ttt = ttt .. "|cffffff" .. zo_strformat(GetString(_G.BARSTEWARD_SKYSHARDS_SKILL_POINTS), skillSkyShards) .. "|r"

        widget.tooltip = ttt
        return discoveredInZone
    end,
    event = _G.EVENT_SKYSHARDS_UPDATED,
    icon = "/esoui/art/mappins/skyshard_complete.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_MAPFILTER15))
}

BS.widgets[BS.W_SKILL_POINTS] = {
    -- v1.2.2
    name = "skillPoints",
    update = function(widget)
        local unspent = GetAvailableSkillPoints()

        widget:SetValue(unspent)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_SKILL_POINTS].Colour or BS.Vars.DefaultOkColour))

        return unspent
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_SKILL_POINTS_CHANGED},
    icon = "/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds",
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
    local speed, speedText

    if (BS.Vars.Controls[BS.W_SPEED].ShowPercent) then
        local rawSpeed = 0

        if (timeDelta > 0) then
            rawSpeed = distance / timeDelta
        end

        local pSpeed = math.floor((rawSpeed * 100 / DEFAULT_SPEED) + 0.5)
        pSpeed = pSpeed - (pSpeed % 5)

        if (pSpeed < 1) then
            pSpeed = 0
        end

        speedText = ((string.match(pSpeed, "%d")) and pSpeed or 0) .. "%"
    else
        local distanceInMeters = distance / UNITS_PER_METER
        local speedInMS = 0

        if (timeDelta > 0) then
            speedInMS = distanceInMeters / timeDelta
        end

        local units = BS.Vars.Controls[BS.W_SPEED].Units

        if (units == "mph") then
            speed = speedInMS * 2.23694
        else
            speed = speedInMS * 3.6
        end

        speed = math.floor(speed)

        local unitText = GetString(_G["BARSTEWARD_" .. string.upper(units)])

        speedText = ((type(speed) == "number") and speed or 0) .. " " .. unitText
    end

    widget:SetValue(speedText)

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
    icon = "/esoui/art/icons/emotes/keyboard/emotecategoryicon_physical_up.dds",
    tooltip = GetString(_G.BARSTEWARD_SPEED),
    customSettings = {
        [1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_SPEED_UNITS),
            choices = unitChoices,
            getFunc = function()
                local units = BS.Vars.Controls[BS.W_SPEED].Units
                return GetString(_G["BARSTEWARD_" .. string.upper(units)])
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

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CAMPAIGNLEVELREQUIREMENTTYPE1)) .. BS.LF
        ttt = ttt .. "|cf9f9f9"
        ttt = ttt .. ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_STAT_GAMEPAD_EXPERIENCE_LABEL)) .. "  "
        ttt = ttt .. xp .. " / " .. xpMax .. "|r"

        widget.tooltip = ttt

        return level
    end,
    event = {_G.EVENT_EXPERIENCE_UPDATE, _G.EVENT_LEVEL_UPDATE},
    icon = "/esoui/art/icons/alchemy/crafting_alchemy_trait_heroism_match.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_CAMPAIGNLEVELREQUIREMENTTYPE1)),
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
    if not combatInfo.bossfight then
        return 0, 0, nil, 0
    end

    local totalBossDamage, bossDamage = 0, 0
    local totalBossGroupDamage = 0
    local starttime
    local endtime

    for _, unit in pairs(combatInfo.units) do
        local totalUnitDamage = unit.damageOutTotal
        local totalUnitGroupDamage = unit.groupDamageOut

        if (unit.bossId ~= nil and totalUnitDamage > 0) then
            totalBossDamage = totalBossDamage + totalUnitDamage
            totalBossGroupDamage = totalBossGroupDamage + totalUnitGroupDamage

            starttime = math.min(starttime or unit.dpsstart or 0, unit.dpsstart or 0)
            endtime = math.max(endtime or unit.dpsend or 0, unit.dpsend or 0)

            if totalUnitDamage > bossDamage then
                bossDamage = totalUnitDamage
            end
        end
    end

    local bossTime = (endtime - starttime) / 1000
    bossTime = bossTime > 0 and bossTime or combatInfo.dpstime

    return totalBossDamage, totalBossGroupDamage, bossTime
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

local function updateWidget()
    if ((combatInfo.DPSOut + combatInfo.HPSOut) == 0) then
        return
    end

    if (not dpsWidget) then
        return
    end

    if (BS.LibCombat) then
        local singleTargetDamage, singleTargetDamageGroup, damageTime = 0, 0, 1

        if combatInfo.bossfight then
            singleTargetDamage, singleTargetDamageGroup, damageTime = getBossTargetDamage()
        end

        if ((singleTargetDamage or 0) == 0) and ((singleTargetDamageGroup or 0) == 0) then
            -- luacheck: push ignore 311
            singleTargetDamage, singleTargetDamageGroup, damageTime = getSingleTargetDamage()
        -- luacheck: pop
        end

        damageTime = math.max(damageTime or 1, 1)

        local dps = zo_round((singleTargetDamage or 0) / damageTime)
        local useSeparators = BS.Vars.Controls[BS.W_DPS].UseSeparators

        if (dps > maxDamage) then
            maxDamage = dps
        end

        table.insert(damage, dps)
        local value = tostring(useSeparators and BS.AddSeparators(dps) or dps)

        dpsWidget:SetValue(value)
        dpsWidget:SetColour(unpack(BS.Vars.Controls[BS.W_DPS].Colour or BS.Vars.DefaultColour))

        local ttt = GetString(_G.BARSTEWARD_DPS) .. BS.LF
        local gold = " |cffd700"

        ttt = ttt .. "|cf9f9f9" .. GetString(_G.BARSTEWARD_PREVIOUS_ENCOUNTER) .. "|r" .. BS.LF
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

function BS.CheckLibCombat()
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
        if (inCombat == nil) then
            inCombat = IsUnitInCombat("player")
        end

        if (inCombat) then
            BS.inCombat = true
            maxDamage = 0
            damage = {}
        else
            BS.inCombat = false
        end
    end
)

BS.widgets[BS.W_DPS] = {
    name = "dps",
    update = function(widget)
        dpsWidget = widget
        BS.CheckLibCombat()
        widget:SetValue(0)

        return 0
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/compass/ava_daggerfallvaldmeri.dds",
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
        local vars = BS.Vars.Controls[BS.W_CHAMPION_POINTS]
        local cp = {}

        if (vars.UseSeparators == true) then
            earned = BS.AddSeparators(earned)
        end

        widget:SetColour(unpack(vars.Colour or BS.Vars.DefaultColour))
        widget:SetValue(earned .. " " .. "(" .. pc .. "%)")
        widget:SetIcon(cpicon)

        local icons = {}
        for disciplineIndex = 1, GetNumChampionDisciplines() do
            local id = GetChampionDisciplineId(disciplineIndex)

            disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataById(id)
            local icon = zo_iconFormat(disciplineData:GetHUDIcon(), 16, 16)
            local disciplineName = GetChampionDisciplineName(id)
            icons[disciplineName] = icon

            local name = ZO_CachedStrFormat("<<C:1>>", disciplineName)
            local toSpend = disciplineData:GetNumSavedUnspentPoints()

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
                    ttt =
                        ttt ..
                        BS.LF .. icons[discipline] .. " " .. ZO_CachedStrFormat("<<C:1>>", discipline) .. " - " .. empty
                    unslotted = unslotted + empty
                end
            end

            widget.tooltip = ttt
        end

        local value = earned .. " " .. "(" .. pc .. "%)"
        local plainValue = value

        if (vars.ShowUnslottedCount and unslotted > 0) then
            plainValue = value .. " - " .. unslotted
            value = value .. " - |cff0000" .. unslotted .. "|r"
        end

        widget:SetColour(unpack(vars.Colour or BS.Vars.DefaultColour))
        widget:SetValue(value, plainValue)
        widget:SetIcon(cpicon)

        return earned
    end,
    event = {_G.EVENT_EXPERIENCE_UPDATE, _G.EVENT_UNSPENT_CHAMPION_POINTS_CHANGED},
    icon = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL)),
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
        }
    }
}
