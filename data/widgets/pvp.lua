local BS = _G.BarSteward

BS.widgets[BS.W_RANDOM_BATTLEGROUND] = {
    -- v1.4.23
    name = "randomBattleground",
    update = function(widget)
        local activities = { LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL, LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION }
        local bgInfo = BS.GetActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = BS.LC.Format(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT)
        }
        local ll = bgInfo[LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL]    -- Random Battleground
        --local cp = bgInfo[LFG_ACTIVITY_BATTLE_GROUND_CHAMPION]
        local np = bgInfo[LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] -- Group Battleground
        local battleground = ll
        local icon = BS.BATTLEGROUND_ICON[LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL]

        if (np) then
            if (np.meetsRequirements) then
                battleground = np
                icon = BS.BATTLEGROUND_ICON[LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION]
            end
        end

        data.activityData = battleground
        data.label = ""
        data.icon = icon

        if (battleground) then
            data = BS.GetActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = EVENT_PLAYER_ACTIVATED,
    icon = "icons/store_battleground",
    hideWhenEqual = 0,
    tooltip = BS.LC.Format(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepadDungeonFinder")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end
}

BS.widgets[BS.W_ALLIANCE_POINTS] =
    BS.CurrencyWidget(
        CURT_ALLIANCE_POINTS,
        BS.W_ALLIANCE_POINTS,
        {
            bag = _G.BARSTEWARD_GOLD_BAG,
            bank = _G.BARSTEWARD_GOLD_BANK,
            combined = _G.BARSTEWARD_GOLD_COMBINED,
            display = _G.BARSTEWARD_GOLD_DISPLAY,
            everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
            separated = _G.BARSTEWARD_GOLD_SEPARATED,
            title = BS.LC.Format(SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS)
        },
        { EVENT_PLAYER_ACTIVATED, EVENT_ALLIANCE_POINT_UPDATE },
        function()
            if (BS.Vars.Controls[BS.W_ALLIANCE_POINTS].PvPOnly == true) then
                return not BS.LC.IsInPvPZone()
            end

            return false
        end
    )

BS.widgets[BS.W_TELVAR_STONES] =
    BS.CurrencyWidget(
        CURT_TELVAR_STONES,
        BS.W_TELVAR_STONES,
        {
            bag = _G.BARSTEWARD_GOLD_BAG,
            bank = _G.BARSTEWARD_GOLD_BANK,
            combined = _G.BARSTEWARD_GOLD_COMBINED,
            display = _G.BARSTEWARD_GOLD_DISPLAY,
            everyWhere = _G.BARSTEWARD_GOLD_EVERYWHERE,
            separated = _G.BARSTEWARD_GOLD_SEPARATED,
            title = BS.LC.Format(SI_GAMEPAD_INVENTORY_TELVAR_STONES)
        },
        EVENT_TELVAR_STONE_UPDATE,
        function()
            if (BS.Vars.Controls[BS.W_TELVAR_STONES].PvPOnly == true) then
                return not BS.LC.IsInPvPZone()
            end

            return false
        end
    )

BS.widgets[BS.W_AP_BUFF] = {
    -- v2.1.2
    name = "apBuff",
    update = function(widget)
        local this = BS.W_AP_BUFF
        local buffs = BS.ScanBuffs(BS.AP_BUFFS, this)
        local lowest = { remaining = 99999 }
        local ttt = BS.LC.Format(_G.BARSTEWARD_AP_BUFF) .. BS.LF

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
                    ZO_CachedStrFormat(GetString(_G.BARSTEWARD_WARNING_EXPIRING), BS.LC.Format(lowest.buffName))
                BS.Announce(GetString(_G.BARSTEWARD_WARNING), buffMessage, this)
            end

            return lowest.remaining
        end

        local value = BS.SecondsToTime(0, true, false, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))

        widget:SetValue(value)
        widget:SetColour(BS.GetTimeColour(0, this, 60, true, true))

        return 0
    end,
    timer = 1000,
    hideWhenEqual = 0,
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_AP_BUFF].PvPOnly == true) then
            return not BS.LC.IsInPvPZone()
        end

        return false
    end,
    icon = "icons/crownstore_skillline_alliancewar_assault",
    tooltip = BS.LC.Format(_G.BARSTEWARD_AP_BUFF)
}

-- some code for this based is based on and reliant on
-- RewardsTracker by Zelenin
zo_callLater(
    function()
        if (_G.RewardsTracker) then
            SecurePostHook(
                _G.RewardsTracker.campaign,
                "refresh",
                function()
                    BS.FireCallbacks("RewardsTrackerRefresh")
                end
            )
        end
    end,
    2000
)

local function makeRow(data, character)
    local classColour = GetClassColor(character.classId)
    local allianceColour = GetAllianceColor(character.alliance)
    local allianceIcon = ZO_GetAllianceIcon(character.alliance)
    local name =
        string.format(
            "%s %s %s",
            allianceColour:Colorize(string.format("|t16:24:%s:inheritcolor|t", allianceIcon)),
            classColour:Colorize(string.format("|t24:24:%s:inheritcolor|t", GetClassIcon(character.classId))),
            allianceColour:Colorize(character.name)
        )
    local rank = string.format("%s", GetAvARankName(character.gender, character.avaRank))

    return string.format("%s %s %s/%s", name, rank, data.tier, data.points)
end

BS.widgets[BS.W_CAMPAIGN_TIER] = {
    -- v3.1.9
    name = "campaignTier",
    update = function(widget)
        local this = BS.W_CAMPAIGN_TIER
        local campaign = _G.RewardsTracker.campaign
        local id = GetCurrentCampaignId()
        local data, tier, progress, maxProgress = nil, GetPlayerCampaignRewardTierInfo(id)

        if (campaign and campaign.data and campaign.data.characters[BS.CHAR.id]) then
            data = campaign.data.characters[BS.CHAR.id]
        end

        if (BS.GetVar("Progress", this)) then
            widget:SetProgress(progress, 0, maxProgress)
        else
            widget:SetValue(progress .. "/" .. maxProgress)
            widget:SetColour(BS.GetColour(this, true))
        end

        local tt = BS.LC.Format(SI_CAMPAIGN_SCORING_END_OF_CAMPAIGN_REWARD_TIER) .. BS.LF .. BS.LF

        if (data) then
            local info = GetAvARankName(BS.CHAR.gender, GetUnitAvARank("player")) .. BS.LF

            info = info .. GetCampaignName(id) .. BS.LF
            info = info .. ZO_CachedStrFormat(_G.BARSTEWARD_TIER_POINTS, tier, data.points) .. BS.LF

            tt = tt .. BS.COLOURS.White:Colorize(info)

            for _, char in ipairs(_G.LibCharacter:GetCharacters(nil, _G.LibCharacter.SORT_NAME)) do
                if (campaign.owner.settings.data.characters[char.id]) then
                    local charData = campaign.data.characters[char.id]
                    local row = makeRow(charData, char)

                    tt = tt .. BS.LF .. row
                end
            end
        end

        widget:SetTooltip(BS.LC.Trim(tt))

        return progress == maxProgress
    end,
    gradient = function()
        local startg = { GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_START) }
        local endg = { GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_END) }
        local s = BS.Vars.Controls[BS.W_CAMPAIGN_TIER].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_CAMPAIGN_TIER].GradientEnd or endg

        return s, e
    end,
    events = {
        EVENT_ASSIGNED_CAMPAIGN_CHANGED,
        EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED
    },
    callback = { [BS] = { "RewardsTrackerRefresh" } },
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_CAMPAIGN_TIER].PvPOnly == true) then
            return not BS.LC.IsInPvPZone()
        end

        return false
    end,
    icon = "campaign/campaign_tabicon_summary_up",
    tooltip = BS.LC.Format(SI_CAMPAIGN_SCORING_END_OF_CAMPAIGN_REWARD_TIER),
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_CAMPAIGN_TIER].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CAMPAIGN_TIER].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        }
    }
}

local ca = BS.LC.Format(GetAbilityName(45617, "player"))

BS.widgets[BS.W_CONT_ATT] = {
    -- v3.1.9
    name = "contAtt",
    update = function(widget)
        local this = BS.W_CONT_ATT
        local buffs = BS.ScanBuffs(BS.CONTINUOUS_ATTACK, this)

        if (#buffs > 0) then
            local buff = buffs[1]

            widget:SetValue(buff.formattedTime)
            widget:SetColour(BS.GetTimeColour(buff.remaining, this, 60, true, true))
            widget:SetTooltip(buff.ttt)

            if (BS.GetVar("Announce", this) and (BS.GetVar("WarningValue", this) * 60) == BS.LC.ToInt(buff.remaining)) then
                local buffMessage = ZO_CachedStrFormat(GetString(_G.BARSTEWARD_WARNING_EXPIRING), ca)
                BS.Announce(GetString(_G.BARSTEWARD_WARNING), buffMessage, this)
            end

            return buff.remaining
        end

        local value = BS.SecondsToTime(0, true, true, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))

        widget:SetValue(value)
        widget:SetColour(BS.GetTimeColour(0, this, 60, true, true))

        return 0
    end,
    timer = 1000,
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_CONT_ATT].PvPOnly == true) then
            return not BS.LC.IsInPvPZone()
        end

        return false
    end,
    icon = "icons/ability_weapon_028",
    tooltip = ca
}

local ah = BS.LC.Format(GetAbilityName(21263, "player"))

BS.widgets[BS.W_AYLEID_HEALTH] = {
    -- v3.1.9
    name = "ayleidHealth",
    update = function(widget)
        local this = BS.W_AYLEID_HEALTH
        local buffs = BS.ScanBuffs(BS.AYLEID_HEALTH, this)

        if (#buffs > 0) then
            local buff = buffs[1]

            widget:SetValue(buff.formattedTime)
            widget:SetColour(BS.GetTimeColour(buff.remaining, this, 60, true, true))
            widget:SetTooltip(buff.ttt)

            if (BS.GetVar("Announce", this) and (BS.GetVar("WarningValue", this) * 60) == BS.LC.ToInt(buff.remaining)) then
                local buffMessage = ZO_CachedStrFormat(GetString(_G.BARSTEWARD_WARNING_EXPIRING), ah)
                BS.Announce(GetString(_G.BARSTEWARD_WARNING), buffMessage, this)
            end

            return buff.remaining
        end

        local value = BS.SecondsToTime(0, true, true, BS.GetVar("HideSeconds", this), BS.GetVar("Format", this))

        widget:SetValue(value)
        widget:SetColour(BS.GetTimeColour(0, this, 60, true, true))
        return 0
    end,
    timer = 1000,
    hideWhenTrue = function()
        if (BS.Vars.Controls[BS.W_AYLEID_HEALTH].PvPOnly == true) then
            return not BS.LC.IsInPvPZone()
        end

        return false
    end,
    icon = "icons/quest_spirit_001",
    tooltip = ah
}
