local BS = BarSteward

BS.widgets[BS.W_RECALL_COOLDOWN] = {
    -- v1.0.2
    name = "recallcooldown",
    update = function(widget)
        local cooldownTime = GetRecallCooldown() / 1000

        widget:SetValue(BS.SecondsToTime(cooldownTime, true, true))
        widget:SetColour(BS.GetColour(BS.W_RECALL_COOLDOWN, true))

        return cooldownTime
    end,
    timer = 1000,
    icon = "zonestories/completiontypeicon_wayshrine",
    tooltip = GetString(BARSTEWARD_RECALL),
    hideWhenEqual = 0
}

BS.widgets[BS.W_ZONE] = {
    -- v1.0.3
    name = "currentZone",
    update = function(widget)
        widget:SetValue(BS.LC.Format(GetUnitZone("player")))
        widget:SetColour(BS.GetColour(BS.W_ZONE, true))

        return widget:GetValue()
    end,
    event = { EVENT_PLAYER_ACTIVATED, EVENT_ZONE_CHANGED },
    icon = "tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map",
    tooltip = BS.LC.Format(SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY),
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_ZONE].PvPNever == true) then
            return BS.LC.IsInPvPZone()
        end

        return false
    end,
    onLeftClick = function()
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
        local playerName = BS.CHAR.name
        local this = BS.W_PLAYER_NAME

        widget:SetValue(ZO_FormatUserFacingDisplayName(playerName))
        widget:SetColour(BS.GetColour(this, true))

        if (BS.GetVar("ShowClassIcon", this)) then
            widget:SetIcon(BS.CHAR.classIcon)
        end

        return widget:GetValue()
    end,
    event = EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_faceicon_up",
    tooltip = BS.LC.Format(SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_CHARACTER)
        else
            SCENE_MANAGER:Show("LevelUpRewardsClaimGamepad")
        end
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_SHOW_CLASS_ICON),
            getFunc = function()
                return BS.Vars.Controls[BS.W_PLAYER_NAME].ShowClassIcon or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_PLAYER_NAME].ShowClassIcon = value
                BS.RegenerateBar(BS.Vars.Controls[BS.W_PLAYER_NAME].Bar)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_RACE] = {
    -- v1.0.3
    name = "playerRace",
    update = function(widget)
        widget:SetValue(BS.LC.Format(BS.CHAR.race))
        widget:SetColour(BS.GetColour(BS.W_RACE, true))

        return widget:GetValue()
    end,
    event = EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_raceicon_up",
    tooltip = BS.LC.Format(SI_COLLECTIBLERESTRICTIONTYPE1)
}

BS.widgets[BS.W_CLASS] = {
    -- v1.0.3
    name = "playerClass",
    update = function(widget)
        local this = BS.W_CLASS
        local icon = BS.CHAR.classIcon

        if (not BS.GetVar("NoValue", this)) then
            widget:SetValue(BS.LC.Format(BS.CHAR.class))
            widget:SetColour(BS.GetColour(this, true))
        end

        widget:SetIcon(icon)

        return widget:GetValue()
    end,
    event = EVENT_PLAYER_ACTIVATED,
    icon = "charactercreate/charactercreate_classicon_up",
    tooltip = BS.LC.Format(SI_COLLECTIBLERESTRICTIONTYPE3),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_HIDE_TEXT),
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
        local icon = BS.CHAR.allianceIcon
        local colour = BS.CHAR.allianceColour

        if (icon:find("daggerfall")) then
            icon = "scoredisplay/blueflag"
        elseif (icon:find("aldmeri")) then
            icon = "scoredisplay/yellowflag"
        else
            icon = "scoredisplay/redflag"
        end

        if (not BS.GetVar("NoValue", BS.W_ALLIANCE)) then
            widget:SetValue(" " .. BS.LC.Format(BS.CHAR.allianceName))
            widget:SetColour(colour)
        end

        widget:SetIcon(icon)
        widget:SetTextureCoords(0, 1, 0, 0.6)

        widget.icon:SetWidth(27)

        return widget:GetValue()
    end,
    event = EVENT_PLAYER_ACTIVATED,
    icon = "scoredisplay/blueflag",
    tooltip = BS.LC.Format(SI_COLLECTIBLERESTRICTIONTYPE2),
    onLeftClick = function()
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
                if (GetSkyshardDiscoveryStatus(skyShardId) == SKYSHARD_DISCOVERY_STATUS_ACQUIRED) then
                    discoveredInZone = discoveredInZone + 1
                end
            end
        end

        widget:SetValue(discoveredInZone .. "/" .. inZoneSkyshards)
        widget:SetColour(BS.GetColour(BS.W_SKYSHARDS, true))

        local ttt = BS.LC.Format(SI_MAPFILTER15) .. BS.LF
        local stext = zo_strformat(GetString(BARSTEWARD_SKYSHARDS_SKILL_POINTS), skillSkyShards)

        ttt = ttt .. BS.COLOURS.White:Colorize(stext)

        widget:SetTooltip(ttt)

        return discoveredInZone
    end,
    event = EVENT_SKYSHARDS_UPDATED,
    icon = "mappins/skyshard_complete",
    tooltip = BS.LC.Format(SI_MAPFILTER15)
}

-- based on Ye Olde Speed
-- estimate of units per meter based on some of the tiles in Alinor
local getUnitRawWorldPosition, getGameTimeMilliseconds = GetUnitRawWorldPosition, GetGameTimeMilliseconds

local function getCurrentPos()
    local _, posX, _, posY = getUnitRawWorldPosition("player")
    local timestamp = getGameTimeMilliseconds()

    return { posX, posY, timestamp }
end

local UNITS_PER_METER = 200
local DEFAULT_SPEED = 660
local currentPosition, lastPosition

local function getSpeed(widget)
    currentPosition = getCurrentPos()

    local x1, y1, t1 = unpack(currentPosition)
    local x2, y2, t2 = unpack(lastPosition or currentPosition)
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

    lastPosition = currentPosition

    return speed
end

local unitChoices = { GetString(BARSTEWARD_MPH), GetString(BARSTEWARD_KPH) }

BS.widgets[BS.W_SPEED] = {
    -- v1.2.16
    name = "speed",
    update = function(widget)
        return getSpeed(widget)
    end,
    timer = 300,
    icon = "icons/emotes/keyboard/emotecategoryicon_physical_up",
    tooltip = GetString(BARSTEWARD_SPEED),
    customSettings = {
        [1] = {
            type = "dropdown",
            name = GetString(BARSTEWARD_SPEED_UNITS),
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
            xpMax = GetNumExperiencePointsInLevel(level) --[[@as integer]]
            xpPc = BS.LC.ToPercent(xp, xpMax)
        end

        widget:SetValue(level .. " (" .. xpPc .. "%)")

        local ttt = BS.LC.Format(SI_CAMPAIGNLEVELREQUIREMENTTYPE1) .. BS.LF
        local ttext = BS.LC.Format(SI_STAT_GAMEPAD_EXPERIENCE_LABEL) .. "  "

        ttext = ttext .. xp .. " / " .. xpMax
        ttt = ttt .. BS.COLOURS.White:Colorize(ttext)

        widget:SetTooltip(ttt)

        return level
    end,
    event = { EVENT_EXPERIENCE_UPDATE, EVENT_LEVEL_UPDATE },
    icon = "icons/alchemy/crafting_alchemy_trait_heroism_match",
    tooltip = BS.LC.Format(SI_CAMPAIGNLEVELREQUIREMENTTYPE1),
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
        dpsWidget:SetColour(BS.GetColour(BS.W_DPS, true))
        dpsWidget:SetIcon(icon)

        local ttt = GetString(BARSTEWARD_DPS) .. BS.LF
        local gold = BS.COLOURS.ZOSGold

        ttt = ttt .. BS.COLOURS.White:Colorize(GetString(BARSTEWARD_PREVIOUS_ENCOUNTER)) .. BS.LF

        if (name) then
            ttt = ttt .. BS.COLOURS.ZOSPurple:Colorize(BS.LC.Format(name)) .. BS.LF
        end

        ttt =
            ttt .. GetString(BARSTEWARD_PREVIOUS_ENCOUNTER_AVERAGE) .. " " .. gold:Colorize(getAvarageDps()) .. BS.LF
        ttt = ttt .. GetString(BARSTEWARD_PREVIOUS_ENCOUNTER_MAXIMUM) .. " " .. gold:Colorize(maxDamage) .. BS.LF
        ttt = ttt .. GetString(BARSTEWARD_PREVIOUS_ENCOUNTER_DURATION) .. " " .. gold:Colorize(getCombatTime())

        dpsWidget:SetTooltip(ttt)
    end
end

local function combatRecapCallback(_, recapData)
    ZO_DeepTableCopy(recapData, combatInfo)

    updateWidget()
end

local function checkLibCombat()
    if (LibCombat) then
        if (not BS.LibCombat) then
            resetCombatInfo()
            BS.LibCombat = LibCombat
            BS.LibCombat:RegisterCallbackType(LIBCOMBAT_EVENT_UNITS, combatUnitsCallback, BS.Name .. "CombatMetrics")
            BS.LibCombat:RegisterCallbackType(
                LIBCOMBAT_EVENT_FIGHTRECAP,
                combatRecapCallback,
                BS.Name .. "CombatMetrics"
            )
        end

        return true
    end

    return false
end

BS.EventManager:RegisterForEvent(
    EVENT_PLAYER_COMBAT_STATE,
    function(_, inCombat)
        if (inCombat ~= BS.inCombat) then
            if (inCombat) then
                BS.inCombat = true
                maxDamage = 0
                BS.LC.Clear(damage)
            else
                BS.inCombat = false
            end

            BS.HideInCombat()
        end
    end
)

BS.EventManager:RegisterForEvent(EVENT_PLAYER_DEAD, BS.HideWhenDead)
BS.EventManager:RegisterForEvent(EVENT_PLAYER_ALIVE, BS.HideWhenDead)

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
    event = EVENT_PLAYER_ACTIVATED,
    icon = dpsIcon,
    tooltip = GetString(BARSTEWARD_DPS),
    hideWhenTrue = function()
        return not BS.LibCombat
    end
}

BS.widgets[BS.W_PLAYER_LOCATION] = {
    -- v1.4.22
    name = "currentLocation",
    update = function(widget, _, _, subZoneName)
        local area = subZoneName

        if ((area or "") == "") then
            area = GetPlayerLocationName()
        end

        widget:SetValue(BS.LC.Format(area))
        widget:SetColour(BS.GetColour(BS.W_PLAYER_LOCATION, true))

        return widget:GetValue()
    end,
    event = { EVENT_PLAYER_ACTIVATED, EVENT_ZONE_CHANGED },
    icon = "icons/mapkey/mapkey_player",
    tooltip = GetString(BARSTEWARD_PLAYER_LOCATION),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("worldMap")
        else
            SCENE_MANAGER:Show("gamepad_worldMap")
        end
    end,
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_PLAYER_LOCATION].PvPOnly == true) then
            local mapContentType = GetMapContentType()
            local isPvP = (mapContentType == MAP_CONTENT_AVA or mapContentType == MAP_CONTENT_BATTLEGROUND)

            return not isPvP
        end

        return false
    end
}

BS.widgets[BS.W_PLAYER_EXPERIENCE] = {
    --v1.4.23
    name = "playerExperience",
    update = function(widget)
        local earned = GetPlayerChampionPointsEarned()
        local xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(earned)
        local pc = BS.LC.ToPercent(xp, xplvl)
        local this = BS.W_PLAYER_EXPERIENCE
        local out

        if (GetUnitLevel("player") < BS.MAX_PLAYER_LEVEL) then
            xp, xplvl = GetUnitXP("player"), GetUnitXPMax("player")
            pc = BS.LC.ToPercent(xp / xplvl)
        end

        if (BS.GetVar("ShowPercent", this)) then
            out = pc .. "%"
        else
            if (BS.GetVar("UseSeparators", this) == true) then
                xp = BS.AddSeparators(xp)
                xplvl = BS.AddSeparators(xplvl)
            end

            out = xp .. " / " .. xplvl
        end

        widget:SetColour(BS.GetColour(this, true))
        widget:SetValue(out)

        local ttt = GetString(BARSTEWARD_PLAYER_EXPERIENCE) .. BS.LF
        local ttext = xp .. " / " .. xplvl .. BS.LF .. pc .. "%"

        ttt = ttt .. BS.COLOURS.White:Colorize(ttext)

        widget:SetTooltip(ttt)

        return xp
    end,
    event = EVENT_EXPERIENCE_UPDATE,
    icon = "icons/icon_experience",
    tooltip = GetString(BARSTEWARD_PLAYER_EXPERIENCE)
}

BS.widgets[BS.W_FOOD_BUFF] = {
    -- v2.0.17
    name = "foodBuff",
    update = function(widget)
        local this = BS.W_FOOD_BUFF
        local buffs = BS.ScanBuffs(BS.FOOD_BUFFS, this)

        if (#buffs > 0) then
            local buff = buffs[1]

            widget:SetValue(buff.formattedTime)
            widget:SetColour(BS.GetTimeColour(buff.remaining, this, 60, true, true))
            widget:SetTooltip(buff.ttt)

            if (BS.GetVar("Announce", this) and (BS.GetVar("WarningValue", this) * 60) == BS.LC.ToInt(buff.remaining)) then
                local buffMessage =
                    ZO_CachedStrFormat(GetString(BARSTEWARD_WARNING_EXPIRING), GetString(BARSTEWARD_FOOD_BUFF))
                BS.Announce(GetString(BARSTEWARD_WARNING), buffMessage, this)
            end

            return buff.remaining
        end

        local value = BS.SecondsToTime(0, true, false, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))

        widget:SetValue(value)
        widget:SetColour(BS.GetTimeColour(0, this, 60, true, true))
        return 0
    end,
    timer = 1000,
    hideWhenEqual = 0,
    icon = "icons/store_tricolor_food_01",
    tooltip = BS.LC.Format(BARSTEWARD_FOOD_BUFF)
}

BS.widgets[BS.W_XP_BUFF] = {
    -- v2.1.2
    name = "apBuff",
    update = function(widget)
        local this = BS.W_XP_BUFF
        local buffs = BS.ScanBuffs(BS.XP_BUFFS, this)
        local lowest = { remaining = 99999 }
        local ttt = BS.LC.Format(BARSTEWARD_XP_BUFF) .. BS.LF

        if (#buffs > 0) then
            for _, buff in ipairs(buffs) do
                ttt = ttt .. BS.LF

                if (#buffs > 1) then
                    ttt = ttt .. buff.buffName .. ": " .. buff.formattedTime
                else
                    ttt = ttt .. BS.LF .. buff.ttt
                end

                buff.ttt = ttt

                if (buff.remaining < lowest.remaining) then
                    lowest = buff
                end
            end

            widget:SetValue(lowest.formattedTime)
            widget:SetColour(BS.GetTimeColour(lowest.remaining, this, 60, true, true))
            widget:SetTooltip(lowest.ttt)

            if (BS.GetVar("Announce", this) and (BS.GetVar("WarningValue", this) * 60) == BS.LC.ToInt(lowest.remaining)) then
                local buffMessage =
                    ZO_CachedStrFormat(GetString(BARSTEWARD_WARNING_EXPIRING), BS.LC.Format(lowest.buffName))
                BS.Announce(GetString(BARSTEWARD_WARNING), buffMessage, this)
            end

            return lowest.remaining
        end

        local value = BS.SecondsToTime(0, true, false, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))

        widget:SetValue(value)
        widget:SetColour(BS.GetTimeColour(0, this, 60, true, true))

        return 0
    end,
    hideWhenEqual = 0,
    timer = 1000,
    icon = "icons/icon_experience",
    tooltip = BS.LC.Format(BARSTEWARD_XP_BUFF)
}

local function changeStatus()
    local status = GetPlayerStatus()

    if (status == PLAYER_STATUS_OFFLINE) then
        status = PLAYER_STATUS_ONLINE --[[@as PlayerStatus]]
    else
        status = status + 1
    end

    SelectPlayerStatus(status)
end

BS.widgets[BS.W_PLAYER_STATUS] = {
    -- v2.1.13
    name = "playerStatus",
    update = function(widget, _, _, newStatus)
        local status = newStatus or GetPlayerStatus()
        local icon = ZO_GetGamepadPlayerStatusIcon(status)
        local text = BS.LC.Format(_G["SI_PLAYERSTATUS" .. status])

        widget:SetIcon(icon)
        widget:SetValue(text)

        return 0
    end,
    hideWhenEqual = 0,
    event = EVENT_PLAYER_STATUS_CHANGED,
    icon = "contacts/gamepad/gp_social_status_online",
    onLeftClick = changeStatus,
    tooltip = BS.LC.Format(SI_FRIENDS_LIST_PANEL_TOOLTIP_STATUS),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return BS.Vars.Controls[BS.W_PLAYER_STATUS].NoValue or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_PLAYER_STATUS].NoValue = value
                BS.GetWidget(BS.W_PLAYER_STATUS):SetNoValue(value)
                BS.RegenerateBar(BS.Vars.Controls[BS.W_PLAYER_STATUS].Bar, BS.W_PLAYER_STATUS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_LFG_ROLE] = {
    -- v3.0.0
    name = "playerRole",
    update = function(widget)
        local role = GetSelectedLFGRole()
        local icon = GetRoleIcon(role)
        local text = BS.LC.Format(_G["SI_LFGROLE" .. role])

        widget:SetIcon(icon)
        widget:SetValue(text)

        return role
    end,
    hideWhenEqual = 0,
    callback = { [PREFERRED_ROLES] = { "LFGRoleChanged" } },
    event = EVENT_GROUP_MEMBER_ROLE_CHANGED,
    hook = { [GAMEPAD_GROUP_ROLES_BAR] = { "OnPressed" } },
    icon = "lfg/lfg_icon_dps",
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepad_groupList")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end,
    tooltip = BS.LC.Format(SI_GAMEPAD_GROUP_PREFERRED_ROLES_HEADER),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return BS.Vars.Controls[BS.W_LFG_ROLE].NoValue or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_LFG_ROLE].NoValue = value
                BS.GetWidget(BS.W_LFG_ROLE):SetNoValue(value)
                BS.RegenerateBar(BS.Vars.Controls[BS.W_LFG_ROLE].Bar, BS.W_LFG_ROLE)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_TITLE] = {
    -- v3.0.0
    name = "playerTitle",
    update = function(widget, event, unitTag)
        if (event == "initial" or unitTag == "player") then
            local title = BS.LC.Format(GetUnitTitle("player"))

            widget:SetValue((title == "") and BS.LC.Format(SI_STATS_NO_TITLE) or title)

            return title
        end
    end,
    hideWhenEqual = "",
    event = EVENT_TITLE_UPDATE,
    icon = "dye/dyes_tabicon_player_up",
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepad_stats_root")
        else
            SCENE_MANAGER:Show("stats")
        end
    end,
    tooltip = BS.LC.Format(SI_STATS_TITLE)
}

BS.widgets[BS.W_BOUNTY] = {
    -- v3.0.0
    name = "playerBounty",
    update = function(widget)
        local bounty = GetFullBountyPayoffAmount()
        local infamy = GetInfamyLevel(GetInfamy())
        local infamyText = BS.LC.Format(_G["SI_INFAMYTHRESHOLDSTYPE" .. infamy])
        local secondsTillClear = GetSecondsUntilBountyDecaysToZero()
        local this = BS.W_BOUNTY
        local colour = BS.COLOURS.DefaultColour
        local remaining = BS.SecondsToTime(secondsTillClear, true, false, BS.GetVar("HideSeconds", this))

        widget:SetColour(colour)
        widget:SetValue(remaining)

        local tt = BS.LC.Format(SI_STATS_BOUNTY_LABEL) .. BS.LF .. BS.LF
        local formatted = zo_strformat(SI_JUSTICE_INFAMY_LEVEL_CHANGED, infamyText)

        formatted = zo_strformat("<<zC:1>>", formatted)

        local ttext = zo_strformat(SI_JUSTICE_BOUNTY_SET, bounty):gsub("%.", "") .. BS.LF .. formatted

        tt = tt .. BS.COLOURS.White:Colorize(ttext)

        widget.tooltip = tt

        return secondsTillClear
    end,
    timer = 1000,
    hideWhenEqual = 0,
    icon = "stats/justice_bounty_icon-red",
    tooltip = BS.LC.Format(SI_STATS_BOUNTY_LABEL)
}

local function findAccount(account, server, allAccounts)
    for _, accountData in ipairs(allAccounts) do
        if (accountData.account == account and accountData.server == server) then
            return accountData.vars
        end
    end
end

BS.widgets[BS.W_DAILY_REWARD] = {
    -- v3.0.3
    name = "dailyReward",
    update = function(widget)
        local worldname = { "EU", "NA" }
        local rewardIndex = GetDailyLoginClaimableRewardIndex()
        local secondsTillReset = GetTimeUntilNextDailyLoginRewardClaimS()
        local claimed = BS.COLOURS.Green:Colorize(BS.LC.Format(SI_DAILY_LOGIN_REWARDS_CLAIMED_TILE_NARRATION))
        local unclaimed = BS.COLOURS.Red:Colorize(BS.LC.Format(SI_GIFT_INVENTORY_UNCLAIMED_GIFTS_HEADER))
        local dailyRewardClaimed

        if (rewardIndex == nil) then
            dailyRewardClaimed = true
        else
            local rewardId = GetDailyLoginRewardInfoForCurrentMonth(rewardIndex)
            dailyRewardClaimed = IsDailyLoginRewardInCurrentMonthClaimed(rewardId)
        end

        BS.Vars:SetCommon({ claimed = dailyRewardClaimed, resetTime = os.time() + secondsTillReset }, "DailyRewards")

        local allAccounts = BS.Vars:GetAllAccountCommon("DailyRewards")
        local accountCount, claimedAccountCount = 0, 0
        local accountList = ""

        for _, server in ipairs(worldname) do
            local servername = string.format("%s Megaserver", server)
            local accounts = BS.Vars:GetAccounts(servername)

            for _, account in ipairs(accounts) do
                accountCount = accountCount + 1

                local acc = findAccount(account, servername, allAccounts)
                local detail = BS.COLOURS.White:Colorize(string.format("%s (%s):", account, server))

                if (acc) then
                    if ((acc.resetTime or 0) <= os.time()) then
                        acc.claimed = false
                    end

                    accountList =
                        string.format("%s%s%s |r%s", accountList, BS.LF, detail, (acc.claimed and claimed or unclaimed))
                    claimedAccountCount = claimedAccountCount + (acc.claimed and 1 or 0)
                else
                    accountList = string.format("%s%s%s |r%s", accountList, BS.LF, detail, unclaimed)
                end
            end
        end

        widget:SetValue(accountCount .. "/" .. claimedAccountCount)
        widget:SetTooltip(BS.LC.Format(SI_DAILY_LOGIN_REWARDS_CLAIMED_ANNOUNCEMENT) .. accountList)

        return claimedAccountCount
    end,
    event = { EVENT_PLAYER_ACTIVATED, EVENT_DAILY_LOGIN_REWARDS_CLAIMED },
    icon = "icons/achievement_u27_loyalty_reward",
    tooltip = BS.LC.Format(SI_DAILY_LOGIN_REWARDS_CLAIMED_ANNOUNCEMENT)
}

local goldIcon = BS.Icon("currency/currency_gold_64")

BS.widgets[BS.W_BOUNTY_AMOUNT] = {
    -- v3.1.4
    name = "playerBountyAmount",
    update = function(widget)
        local bounty = GetFullBountyPayoffAmount()
        local infamy = GetInfamyLevel(GetInfamy())
        local infamyText = BS.LC.Format(_G["SI_INFAMYTHRESHOLDSTYPE" .. infamy])
        local colour = BS.GetColour(BS.W_BOUNTY_AMOUNT)

        widget:SetColour(colour)
        widget:SetValue(bounty .. goldIcon)

        local tt = BS.LC.Format(BARSTEWARD_BOUNTY_AMOUNT) .. BS.LF .. BS.LF
        local formatted = zo_strformat(SI_JUSTICE_INFAMY_LEVEL_CHANGED, infamyText)

        formatted = zo_strformat("<<zC:1>>", formatted)

        tt = tt .. BS.COLOURS.White:Colorize(formatted)

        widget.tooltip = tt

        return bounty
    end,
    timer = 1000,
    hideWhenEqual = 0,
    icon = "icons/store_bounty_expunger_medium",
    tooltip = BS.LC.Format(BARSTEWARD_BOUNTY_AMOUNT)
}

BS.widgets[BS.W_ARMOURY_BUILD] = {
    -- v3.1.7
    name = "currentArmouryBuild",
    update = function(widget, event, result, buildIndex)
        local this = BS.W_ARMOURY_BUILD
        local colour = BS.GetColour(this)
        local armouryInfo = BS.GetVar("armouryInfo", this) or {}

        if (event == EVENT_ARMORY_BUILD_UPDATED) then
            buildIndex = result
        end

        if (result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS or event == EVENT_ARMORY_BUILD_UPDATED) then
            local data = ZO_ARMORY_MANAGER:GetBuildDataByIndex(buildIndex)
            armouryInfo = {
                index = data:GetBuildIndex(),
                name = data:GetName(),
                icon = data:GetIcon(),
                outfit = data:GetEquippedOutfitName(),
                equipped = GetTimeStamp()
            }

            BS.Vars.Controls[this].armouryInfo = armouryInfo
        end

        widget:SetIcon(armouryInfo.icon or "icons/housing_gen_crf_armorycraftingbase001")
        widget:SetColour(colour)
        widget:SetValue(armouryInfo.name or "?")

        local tt = BS.LC.Format(SI_ARMORY_TITLE) .. BS.LF

        tt = tt .. BS.LF .. BS.LC.Format(BARSTEWARD_BUILD_INFO)

        if (armouryInfo.index) then
            local equipped = BS.COLOURS.White:Colorize(armouryInfo.name)

            tt = tt .. BS.LF .. BS.LF
            tt = tt .. equipped .. BS.LF

            if (armouryInfo.outfit ~= GetString(SI_NO_OUTFIT_EQUIP_ENTRY)) then
                local outfit =
                    BS.COLOURS.White:Colorize(ZO_CachedStrFormat(GetString(SI_ARMORY_OUTFIT_LABEL), armouryInfo.outfit))

                tt = tt .. outfit
            end

            local date = GetDateStringFromTimestamp(armouryInfo.equipped)
            local formatter = GetString(SI_GAMEPAD_SECTION_HEADER_EQUIPPED_ITEM)
            local text = ZO_CachedStrFormat(formatter, date)

            tt = tt .. BS.LF .. BS.LF .. BS.LC.Format(text)
        end

        widget.tooltip = tt

        return armouryInfo.buildIndex or 0
    end,
    event = { EVENT_ARMORY_BUILD_RESTORE_RESPONSE, EVENT_ARMORY_BUILD_UPDATED },
    callback = { [ZO_ARMORY_MANAGER] = { "BuildListUpdated" } },
    hideWhenEqual = 0,
    icon = "icons/housing_gen_crf_armorycraftingbase001",
    tooltip = BS.LC.Format(SI_ARMORY_TITLE),
    onLeftClick = function()
        for _, id in ipairs(BS.ARMOURY_ASSISTANTS) do
            if (IsCollectibleUsable(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                UseCollectible(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                return
            end
        end
    end
}

BS.widgets[BS.W_ENLIGHTENED] = {
    --v3.1.9
    name = "enlightened",
    update = function(widget)
        local available = IsEnlightenedAvailableForCharacter()
        local poolAmount = GetEnlightenedPool()
        local multiplier = GetEnlightenedMultiplier() + 1
        local this = BS.W_ENLIGHTENED
        local useSeparators = BS.GetVar("UseSeparators", this)

        if (available) then
            poolAmount = poolAmount * multiplier
        else
            poolAmount = 0
        end

        local amount = tostring(useSeparators and BS.AddSeparators(poolAmount) or poolAmount)

        widget:SetColour(BS.GetColour(this, true))
        widget:SetValue(amount)

        return poolAmount or 0
    end,
    hideWhenEqual = 0,
    event = { EVENT_ENLIGHTENED_STATE_LOST, EVENT_ENLIGHTENED_STATE_GAINED, EVENT_EXPERIENCE_UPDATE },
    icon = "icons/quest_elsweyr_evilcadwell_head",
    tooltip = GetString(BARSTEWARD_ENLIGHTENED)
}
