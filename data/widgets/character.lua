local BS = _G.BarSteward

local mundusstones = {
    [13940] = true,
    [13943] = true,
    [13974] = true,
    [13975] = true,
    [13976] = true,
    [13977] = true,
    [13978] = true,
    [13979] = true,
    [13980] = true,
    [13981] = true,
    [13982] = true,
    [13984] = true,
    [13985] = true
}

BS.widgets[BS.W_MUNDUS_STONE] = {
    -- v1.0.1
    name = "mundusstone",
    update = function(widget)
        local mundusId = nil

        for buffNum = 1, GetNumBuffs("player") do
            local id = select(11, GetUnitBuffInfo("player", buffNum))

            if (mundusstones[id]) then
                mundusId = id
                break
            end
        end

        if (mundusId ~= nil) then
            local icon = GetAbilityIcon(mundusId)
            local name = GetAbilityName(mundusId)

            widget:SetIcon(icon)
            widget:SetValue(name)
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_MUNDUS_STONE].Colour or BS.Vars.DefaultColour))

            return name
        else
            widget:SetValue(GetString(_G.SI_CRAFTING_INVALID_ITEM_STYLE))
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_MUNDUS_STONE].DangerColour or BS.Vars.DefaultDangerColour))
        end

        return ""
    end,
    event = _G.EVENT_EFFECT_CHANGED,
    filter = {[_G.EVENT_EFFECT_CHANGED] = {_G.REGISTER_FILTER_UNIT_TAG, "player"}},
    icon = "/esoui/art/icons/ability_mundusstones_002.dds",
    tooltip = GetString(_G.SI_CONFIRM_MUNDUS_STONE_TITLE),
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
        widget:SetValue(GetUnitZone("player"))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_ZONE].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_ZONE_CHANGED},
    icon = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map.dds",
    tooltip = GetString(_G.SI_ANTIQUITY_SCRYABLE_CURRENT_ZONE_SUBCATEGORY),
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
        widget:SetValue(GetUnitName("player"))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_PLAYER_NAME].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
    tooltip = GetString(_G.SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME)
}

BS.widgets[BS.W_RACE] = {
    -- v1.0.3
    name = "playerRace",
    update = function(widget)
        widget:SetValue(GetUnitRace("player"))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_RACE].Colour or BS.Vars.DefaultColour))

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
    tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE1)
}

BS.widgets[BS.W_CLASS] = {
    -- v1.0.3
    name = "playerClass",
    update = function(widget)
        local classId = GetUnitClassId("player")
        local icon = GetClassIcon(classId)

        widget:SetValue(GetUnitClass("player"))
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_CLASS].Colour or BS.Vars.DefaultColour))
        widget:SetIcon(icon)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "/esoui/art/charactercreate/charactercreate_classicon_up.dds",
    tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE3)
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

        widget:SetValue(" " .. GetAllianceName(alliance))
        widget:SetColour(colour.r, colour.g, colour.b, colour.a)
        widget:SetIcon(icon)
        widget:SetTextureCoords(0, 1, 0, 0.6)
        widget.icon:SetWidth(27)

        return widget:GetValue()
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "",
    tooltip = GetString(_G.SI_COLLECTIBLERESTRICTIONTYPE2),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("campaignOverview")
        else
            SCENE_MANAGER:Show("gamepad_campaign_root")
        end
    end
}
