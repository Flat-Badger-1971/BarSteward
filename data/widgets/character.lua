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

        widget:SetValue(ZO_FormatUserFacingCharacterName(playerName))
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
    local distanceInMeters = distance / UNITS_PER_METER
    local speedInMS = distanceInMeters / timeDelta
    local units = BS.Vars.Controls[BS.W_SPEED].Units
    local speed

    if (units == "mph") then
        speed = speedInMS * 2.23694
    else
        speed = speedInMS * 3.6
    end

    speed = math.floor(speed)

    local unitText = GetString(_G["BARSTEWARD_" .. string.upper(units)])
    widget:SetValue(speed .. " " .. unitText)

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
    icon = "/esoui/art/treeicons/gamepad/gp_emoteicon_physical.dds",
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

                if (BS.Vars.Controls[BS.W_SPEED].Bar ~= 0) then
                    BS.widgets[BS.W_SPEED].update(_G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_SPEED].name].ref)
                end
            end,
            default = BS.Defaults.Controls[BS.W_SPEED].Units
        }
    }
}
