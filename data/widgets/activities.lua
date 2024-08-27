local BS = _G.BarSteward
local completed = {
    [_G.TIMED_ACTIVITY_TYPE_DAILY] = false,
    [_G.TIMED_ACTIVITY_TYPE_WEEKLY] = false
}

local star = BS.Icon("targetmarkers/target_gold_star_64")

local function configureWidget(widget, complete, maxComplete, activityType, tasks, hideLimit, defaultTooltip)
    local widgetIndex = activityType == _G.TIMED_ACTIVITY_TYPE_DAILY and BS.W_DAILY_ENDEAVOURS or BS.W_WEEKLY_ENDEAVOURS
    local colour = BS.GetColour(widgetIndex, true)

    if (BS.GetVar("UseRag", widgetIndex)) then
        if (complete > 0 and complete < maxComplete) then
            colour = BS.COLOURS.DefaultWarningColour
        elseif (complete == maxComplete) then
            colour = BS.COLOURS.DefaultOkColour
        else
            colour = BS.COLOURS.DefaultDangerColour
        end
    end

    widget:SetValue(complete .. (hideLimit and "" or ("/" .. maxComplete)))
    widget:SetColour(colour)

    if (#tasks > 0) then
        local tooltipText = defaultTooltip or ""
        local maxValue, maxIndex, allEqual = 0, 0, true

        if (activityType == _G.TIMED_ACTIVITY_TYPE_DAILY) then
            for _, t in ipairs(tasks) do
                if (t.value > maxValue) then
                    if (maxValue > 0) then
                        allEqual = false
                    end
                    maxValue = t.value
                    maxIndex = t.index
                end
            end
        end

        for _, t in ipairs(tasks) do
            if (activityType == _G.TIMED_ACTIVITY_TYPE_DAILY) then
                if (not allEqual) then
                    if (t.index == maxIndex) then
                        t.text = string.format("%s%s %s %s%s", star, star, t.text, star, star)
                    end
                end
            end
            tooltipText = tooltipText .. BS.LF .. t.text
        end

        widget:SetTooltip(tooltipText)
    end
end

local function getTimedActivityProgress(activityType, widget, hideLimit, defaultTooltip, ignoreComplete)
    local complete = 0
    local maxComplete = GetTimedActivityTypeLimit(activityType)
    local tasks = {}
    local maxPcProgress = -1
    local maxTask = {}

    for idx = 1, 30 do
        local name = GetTimedActivityName(idx)

        if (name == "") then
            break
        end

        if (GetTimedActivityType(idx) == activityType) then
            local max = GetTimedActivityMaxProgress(idx)
            local progress = GetTimedActivityProgress(idx)
            local pcProgress = progress / max
            local ttext = name .. "  (" .. progress .. "/" .. max .. ")"
            local colour = BS.COLOURS.Grey

            completed[activityType] = false

            if (progress > 0 and progress < max and complete ~= maxComplete) then
                colour = BS.COLOURS.Yellow
            elseif (complete == maxComplete and max ~= progress) then
                colour = BS.COLOURS.Grey
            elseif (max == progress) then
                complete = complete + 1
                colour = BS.COLOURS.Green
            end

            -- get reward info
            local numRewards = GetNumTimedActivityRewards(idx)
            local reward = ""
            local rewardValue = 0

            for rewardIndex = 1, numRewards do
                local rewardId, quantity = GetTimedActivityRewardInfo(idx, rewardIndex)
                local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, quantity)

                if (reward ~= "") then
                    reward = reward .. ", "
                end

                reward = reward .. BS.Icon(rewardData.lootIcon or rewardData.icon) .. quantity
                rewardValue = rewardValue + quantity
            end

            ttext = colour:Colorize(ttext) .. " " .. reward

            table.insert(tasks, {text = ttext, value = rewardValue, index = idx})

            local add = pcProgress > maxPcProgress

            if (ignoreComplete and (progress == max)) then
                add = false
            end

            if (add) then
                maxTask = {
                    name = name,
                    description = GetTimedActivityDescription(idx),
                    progress = progress,
                    maxProgress = max
                }

                maxPcProgress = pcProgress
            end
        end
    end

    if (complete == maxComplete) then
        completed[activityType] = true
    end

    if (widget ~= nil) then
        configureWidget(widget, complete, maxComplete, activityType, tasks, hideLimit, defaultTooltip)
    end

    return complete, maxTask
end

BS.widgets[BS.W_DAILY_ENDEAVOURS] = {
    -- v1.0.1
    name = "dailyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(
            _G.TIMED_ACTIVITY_TYPE_DAILY,
            widget,
            BS.GetVar("HideLimit", BS.W_DAILY_ENDEAVOURS),
            GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS)
        )
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_checked_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
            TIMED_ACTIVITIES_KEYBOARD:SetCurrentActivityType(_G.TIMED_ACTIVITY_TYPE_DAILY)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return completed[_G.TIMED_ACTIVITY_TYPE_DAILY]
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_RAG),
            getFunc = function()
                return BS.Vars.Controls[BS.W_DAILY_ENDEAVOURS].UseRag
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_DAILY_ENDEAVOURS].UseRag = value
                BS.RefreshWidget(BS.W_DAILY_ENDEAVOURS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_WEEKLY_ENDEAVOURS] = {
    -- v1.0.1
    name = "weeklyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(
            _G.TIMED_ACTIVITY_TYPE_WEEKLY,
            widget,
            BS.GetVar("HideLimit", BS.W_WEEKLY_ENDEAVOURS),
            GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS)
        )
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_checked_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
            TIMED_ACTIVITIES_KEYBOARD:SetCurrentActivityType(_G.TIMED_ACTIVITY_TYPE_WEEKLY)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return completed[_G.TIMED_ACTIVITY_TYPE_WEEKLY]
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_RAG),
            getFunc = function()
                return BS.Vars.Controls[BS.W_WEEKLY_ENDEAVOURS].UseRag
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_WEEKLY_ENDEAVOURS].UseRag = value
                BS.RefreshWidget(BS.W_WEEKLY_ENDEAVOURS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_ENDEAVOUR_PROGRESS] = {
    -- v1.2.14
    name = "weeklyEndeavourBar",
    update = function(widget)
        local this = BS.W_ENDEAVOUR_PROGRESS
        local _, maxTask = getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, nil)

        if (maxTask.name and maxTask.maxProgress) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(maxTask.progress, 0, maxTask.maxProgress)
            else
                widget:SetValue(maxTask.progress .. "/" .. maxTask.maxProgress)
                widget:SetColour(BS.GetColour(this, true))
            end

            local ttt = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST) .. BS.LF
            local taskInfo = maxTask.name .. BS.LF .. BS.LF .. maxTask.description

            ttt = ttt .. BS.COLOURS.OffWhite:Colorize(taskInfo)

            widget:SetTooltip(ttt)

            return maxTask.progress == maxTask.maxProgress
        else
            return 0
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientEnd or endg

        return s, e
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_marked_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return completed[_G.TIMED_ACTIVITY_TYPE_WEEKLY]
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        }
    }
}

local function getLeadColour(lead)
    local difficultyColours = {
        [_G.ANTIQUITY_DIFFICULTY_TRIVIAL] = BS.COLOURS.ZOSGrey,
        [_G.ANTIQUITY_DIFFICULTY_SIMPLE] = BS.COLOURS.ZOSGreen,
        [_G.ANTIQUITY_DIFFICULTY_INTERMEDIATE] = BS.COLOURS.ZOSBlue,
        [_G.ANTIQUITY_DIFFICULTY_ADVANCED] = BS.COLOURS.ZOSPurple,
        [_G.ANTIQUITY_DIFFICULTY_MASTER] = BS.COLOURS.ZOSGold,
        [_G.ANTIQUITY_DIFFICULTY_ULTIMATE] = BS.COLOURS.ZOSOrange
    }

    if ((lead.quality or 0) == 0) then
        return BS.GetColour(BS.W_LEADS, true)
    end

    return difficultyColours[lead.quality]
end

BS.isScryingUnlocked = false

BS.RegisterForEvent(
    _G.EVENT_PLAYER_ACTIVATED,
    function()
        BS.isScryingUnlocked = ZO_IsScryingUnlocked()
    end
)

BS.RegisterForEvent(
    _G.EVENT_SKILL_LINE_ADDED,
    function()
        BS.isScryingUnlocked = ZO_IsScryingUnlocked()
    end
)

BS.widgets[BS.W_LEADS] = {
    -- v1.1.0
    name = "leads",
    update = function(widget)
        local minTime = 99999999
        local leads = {}
        local antiquityId = GetNextAntiquityId()
        local this = BS.W_LEADS

        while antiquityId do
            if (DoesAntiquityHaveLead(antiquityId)) then
                local leadInfo = ANTIQUITY_DATA_MANAGER:GetOrCreateAntiquityData(antiquityId)
                local lead = {
                    name = BS.Format(leadInfo:GetName()),
                    colourName = leadInfo:GetColorizedFormattedName(),
                    remaining = leadInfo:GetLeadTimeRemainingS(),
                    quality = leadInfo:GetQuality(),
                    zone = BS.Format(GetZoneNameById(leadInfo:GetZoneId())),
                    id = antiquityId,
                    inProgress = GetNumAntiquityDigSites(antiquityId) > 0,
                    recovered = leadInfo:GetNumRecovered()
                }

                table.insert(leads, lead)

                if (not lead.inProgress) then
                    if (lead.remaining < minTime) then
                        minTime = lead.remaining
                    end
                end
            end

            antiquityId = GetNextAntiquityId(antiquityId)
        end

        if (#leads > 0) then
            local timeColour = BS.GetTimeColour(minTime, this, nil, true, true)
            local value

            if (#leads == 1 and leads[1].inProgress) then
                value = GetString(_G.BARSTEWARD_IN_PROGRESS)
                timeColour = BS.COLOURS.ZOSOrange
                minTime = 0
            else
                value =
                    BS.SecondsToTime(
                    minTime,
                    false,
                    false,
                    true,
                    BS.GetVar("Format", this),
                    BS.GetVar("HideDaysWhenZero", this)
                )
            end

            if (BS.GetVar("ShowCount", this)) then
                value = "(" .. #leads .. ")  " .. value
            end

            if (BS.GetVar("HideTimer", this)) then
                value = tostring(#leads)
            end

            widget:SetColour(timeColour)
            widget:SetValue(value)

            local ttt = BS.Format(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS)

            -- sort by time remaining
            table.sort(
                leads,
                function(a, b)
                    return a.remaining < b.remaining
                end
            )

            for _, lead in ipairs(leads) do
                local nameAndZone = lead.name .. " - " .. lead.zone
                local ttlColour = getLeadColour(lead)
                local time =
                    BS.SecondsToTime(
                    lead.remaining,
                    false,
                    false,
                    true,
                    BS.GetVar("Format", this),
                    BS.GetVar("HideDaysWhenZero", this)
                )

                if (lead.inProgress) then
                    time = GetString(_G.BARSTEWARD_IN_PROGRESS)
                    timeColour = BS.COLOURS.ZOSOrange
                else
                    timeColour = BS.GetTimeColour(lead.remaining, this, nil, true, true)
                end

                ttt = ttt .. BS.LF .. " "
                ttt = ttt .. ttlColour:Colorize(nameAndZone .. "- ")
                ttt = ttt .. timeColour:Colorize(time)

                if (BS.GetVar("ShowFound", this)) then
                    local found = zo_strformat(_G.SI_ANTIQUITY_TIMES_ACQUIRED, lead.recovered)
                    ttt = ttt .. " - " .. found
                end
            end

            widget:SetTooltip(ttt)
        end

        return minTime
    end,
    timer = 1000,
    icon = GetAntiquityLeadIcon(),
    tooltip = BS.Format(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS),
    hideWhenEqual = 99999999,
    hideWhenTrue = function()
        return not BS.isScryingUnlocked
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_LEAD_COUNT),
            getFunc = function()
                return BS.Vars.Controls[BS.W_LEADS].ShowCount or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_LEADS].ShowCount = value
                BS.RefreshWidget(BS.W_LEADS)
            end,
            disabled = function()
                return BS.Vars.Controls[BS.W_LEADS].HideTimer
            end,
            default = false
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_TIMER),
            getFunc = function()
                return BS.Vars.Controls[BS.W_LEADS].HideTimer or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_LEADS].HideTimer = value
                BS.RefreshWidget(BS.W_LEADS)
                BS.ResizeBar(BS.Vars.Controls[BS.W_LEADS].Bar)
            end,
            default = false
        },
        [3] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_FOUND),
            getFunc = function()
                return BS.Vars.Controls[BS.W_LEADS].ShowFound or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_LEADS].ShowFound = value
            end,
            default = false
        }
    }
}

local function getDisplay(timeRemaining, widgetIndex)
    local display
    local hours = timeRemaining / 60 / 60
    local days = math.floor((hours / 24) + 0.5)

    if (BS.GetVar("ShowDays", widgetIndex) and days >= 1 and hours > 24) then
        display = zo_strformat(GetString(_G.BARSTEWARD_DAYS), days)
    else
        display =
            BS.SecondsToTime(
            timeRemaining,
            false,
            false,
            BS.GetVar("HideSeconds", widgetIndex),
            BS.GetVar("Format", widgetIndex),
            BS.GetVar("HideDaysWhenZero", widgetIndex)
        )
    end

    return display
end

local function getTimedActivityTimeRemaining(activityType, this, widget)
    local secondsRemaining = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(activityType)
    local colour = BS.GetTimeColour(secondsRemaining, this, nil, true, true)

    local display = getDisplay(secondsRemaining, this)

    widget:SetColour(colour)
    widget:SetValue(display)

    return secondsRemaining
end

function BS.GetTimedActivityTimeRemaining(...)
    return getTimedActivityTimeRemaining(...)
end

BS.widgets[BS.W_DAILY_ENDEAVOUR_TIME] = {
    -- v1.2.18
    name = "dailyEndeavourTime",
    update = function(widget)
        return getTimedActivityTimeRemaining(_G.TIMED_ACTIVITY_TYPE_DAILY, BS.W_DAILY_ENDEAVOUR_TIME, widget)
    end,
    timer = 1000,
    icon = "journal/u26_progress_digsite_unknown_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_TIME),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end
}

BS.widgets[BS.W_WEEKLY_ENDEAVOUR_TIME] = {
    -- v1.2.18
    name = "weeklyEndeavourTime",
    update = function(widget)
        return getTimedActivityTimeRemaining(_G.TIMED_ACTIVITY_TYPE_WEEKLY, BS.W_WEEKLY_ENDEAVOUR_TIME, widget)
    end,
    timer = 1000,
    icon = "journal/u26_progress_digsite_unknown_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_TIME),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return completed[_G.TIMED_ACTIVITY_TYPE_WEEKLY]
    end
}

BS.widgets[BS.W_TRIBUTE_CLUB_RANK] = {
    name = "tributeRank",
    update = function(widget, updateType)
        if (updateType == "initial") then
            zo_callLater(
                function()
                    RequestTributeClubData()
                end,
                1000
            )
        else
            local rank = GetTributePlayerClubRank()
            local xp, totalxp = GetTributePlayerExperienceInCurrentClubRank()
            local percent = zo_floor(xp / totalxp * 100)
            local icon = string.format("Tribute/tributeClubRank_%d", rank)
            local rankName = zo_strformat(GetString("SI_TRIBUTECLUBRANK", rank))
            local displayRank = rank + 1

            widget:SetIcon(icon)

            if (rank == 7) then
                widget:SetValue(displayRank)
            else
                widget:SetValue(displayRank .. " (" .. percent .. "%)")
            end

            local ttt = GetString(_G.BARSTEWARD_TRIBUTE_RANK) .. BS.LF
            local text = displayRank .. " - " .. rankName .. BS.LF .. BS.LF

            text = text .. xp .. " / " .. totalxp .. ((rank == 7) and "" or " (" .. percent .. "%)")
            ttt = ttt .. BS.COLOURS.OffWhite:Colorize(text)

            widget:SetTooltip(ttt)
        end
    end,
    event = {
        _G.EVENT_PLAYER_ACTIVATED,
        _G.EVENT_TRIBUTE_CLUB_RANK_CHANGED,
        _G.EVENT_TRIBUTE_CLUB_EXPERIENCE_GAINED,
        _G.EVENT_TRIBUTE_CLUB_INIT
    },
    icon = "tribute/tributeclubrank_7",
    tooltip = GetString(_G.BARSTEWARD_TRIBUTE_RANK)
}

BS.widgets[BS.W_ACHIEVEMENT_POINTS] = {
    -- v1.3.3
    name = "achievementPoints",
    update = function(widget)
        local this = BS.W_ACHIEVEMENT_POINTS
        local totalPoints = GetTotalAchievementPoints()
        local earnedPoints = GetEarnedAchievementPoints()
        local value = earnedPoints

        if (BS.GetVar("ShowPercent", this)) then
            value = math.floor((earnedPoints / totalPoints) * 100) .. "%"
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(this, true))

        local ttt = BS.Format(_G.SI_ACHIEVEMENTS_OVERALL) .. BS.LF

        ttt = ttt .. BS.COLOURS.OffWhite:Colorize(earnedPoints .. "/" .. totalPoints)

        widget:SetTooltip(ttt)

        return widget:GetValue()
    end,
    event = {
        _G.EVENT_PLAYER_ACTIVATED,
        _G.EVENT_ACHIEVEMENT_UPDATED,
        _G.EVENT_ACHIEVEMENT_AWARDED,
        _G.EVENT_ACHIEVEMENTS_UPDATED
    },
    icon = "journal/journal_tabicon_achievements_up",
    tooltip = BS.Format(_G.SI_ACHIEVEMENTS_OVERALL),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("achievements")
        else
            SCENE_MANAGER:Show("achievementsGamepad")
        end
    end
}

BS.widgets[BS.W_PLEDGES_TIME] = {
    -- v1.3.11
    -- same time as any other daily activity
    name = "dailyPledgesTime",
    update = function(widget)
        return getTimedActivityTimeRemaining(_G.TIMED_ACTIVITY_TYPE_DAILY, BS.W_PLEDGES_TIME, widget)
    end,
    timer = 1000,
    icon = "icons/undaunted_bigcoffer",
    tooltip = GetString(_G.BARSTEWARD_DAILY_PLEDGES_TIME)
}

local function setTracker(widgetIndex, resetSeconds, tooltip)
    if (not BS.Vars:GetCommon("Trackers", widgetIndex)) then
        BS.Vars:SetCommon({}, "Trackers", widgetIndex)
    end

    local thisCharacter = GetUnitName("player")

    if (not BS.Vars:GetCommon("Trackers", widgetIndex, thisCharacter)) then
        BS.Vars:SetCommon({}, "Trackers", widgetIndex, thisCharacter)
    end

    local resetTime = resetSeconds + os.time()

    BS.Vars:SetCommon(resetTime, "Trackers", widgetIndex, thisCharacter, "resetTime")

    local resets = BS.Vars:GetCommon("Trackers", widgetIndex)

    for character, time in pairs(resets) do
        if (character ~= thisCharacter) then
            local timeRemaining = 0

            if (time.resetTime > os.time()) then
                timeRemaining = time.resetTime - os.time()
            end

            local formattedTime =
                BS.SecondsToTime(timeRemaining, true, false, BS.Vars.Controls[BS.W_SHADOWY_VENDOR_TIME].HideSeconds)

            tooltip = tooltip .. BS.LF .. BS.COLOURS.Yellow:Colorize(formattedTime) .. " "
            tooltip = tooltip .. ZO_FormatUserFacingDisplayName(character)
        end
    end

    return tooltip
end

BS.isShadowyVendorUnlocked = false

function BS.IsShadowyVendorUnlocked()
    local DarkBrotherhoodSkillLineId = 118
    local skilltype, skilllineid = GetSkillLineIndicesFromSkillLineId(DarkBrotherhoodSkillLineId)
    local _, rank, _, _, _, _, active = GetSkillLineInfo(skilltype, skilllineid)

    return (rank > 3) and active
end

BS.RegisterForEvent(
    _G.EVENT_PLAYER_ACTIVATED,
    function()
        BS.isShadowyVendorUnlocked = BS.IsShadowyVendorUnlocked()
    end
)

BS.RegisterForEvent(
    _G.EVENT_SKILL_LINE_ADDED,
    function()
        BS.isShadowyVendorUnlocked = BS.IsShadowyVendorUnlocked()
    end
)

BS.widgets[BS.W_SHADOWY_VENDOR_TIME] = {
    -- v1.3.11
    name = "remainsSilentReset",
    update = function(widget)
        local this = BS.W_SHADOWY_VENDOR_TIME
        local timeToReset = GetTimeToShadowyConnectionsResetInSeconds()
        local remaining = BS.SecondsToTime(timeToReset, true, false, BS.GetVar("HideSeconds", this))

        widget:SetColour(BS.COLOURS.DefaultColour)
        widget:SetValue(remaining)
        widget:SetTooltip(setTracker(this, timeToReset, GetString(_G.BARSTEWARD_SHADOWY_VENDOR_RESET)))

        return timeToReset
    end,
    timer = 1000,
    icon = "icons/rep_darkbrotherhood_64",
    tooltip = GetString(_G.BARSTEWARD_SHADOWY_VENDOR_RESET),
    hideWhenTrue = function()
        return not BS.isShadowyVendorUnlocked
    end
}

BS.widgets[BS.W_LFG_TIME] = {
    -- v1.3.11
    name = "lfgTime",
    update = function(widget)
        local this = BS.W_LFG_TIME
        local timeToReset = GetLFGCooldownTimeRemainingSeconds(_G.LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
        local remaining = BS.SecondsToTime(timeToReset, true, false, BS.GetVar("HideSeconds", this))

        widget:SetColour(BS.COLOURS.DefaultColour)
        widget:SetValue(remaining)
        widget:SetTooltip(setTracker(this, timeToReset, GetString(_G.BARSTEWARD_DUNGEON_REWARD_RESET)))

        return timeToReset
    end,
    timer = 1000,
    icon = "lfg/lfg_indexicon_dungeon_up",
    tooltip = GetString(_G.BARSTEWARD_DUNGEON_REWARD_RESET),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepad_groupList")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end
}

local function updateLoreBooks()
    if (BS.Vars) then
        local bypass =
            BS.Vars.Controls[BS.W_LOREBOOKS].Bar + BS.Vars.Controls[BS.W_SHALIDORS_LIBRARY].Bar +
            BS.Vars.Controls[BS.W_CRAFTING_MOTIFS].Bar ==
            0

        if (bypass) then
            return
        end

        local categories = {}

        for categoryIndex = 1, GetNumLoreCategories() do
            local categoryName, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
            local category = {
                id = categoryId,
                name = categoryName,
                numCollections = numCollections,
                numKnownBooks = 0,
                totalBooks = 0
            }

            for collectionIndex = 1, numCollections do
                local _, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
                if not hidden then
                    category.numKnownBooks = category.numKnownBooks + numKnownBooks
                    category.totalBooks = category.totalBooks + totalBooks
                end
            end

            categories[categoryIndex] = category
        end

        CALLBACK_MANAGER:FireCallbacks(BS.Name .. "CB_Lorebooks_Updated", categories)
    end
end

BS.RegisterForEvent(_G.EVENT_PLAYER_ACTIVATED, updateLoreBooks)
BS.RegisterForEvent(_G.EVENT_LORE_BOOK_LEARNED, updateLoreBooks)
BS.RegisterForEvent(_G.EVENT_STYLE_LEARNED, updateLoreBooks)
BS.RegisterForEvent(_G.EVENT_TRAIT_LEARNED, updateLoreBooks)

BS.widgets[BS.W_LOREBOOKS] = {
    -- v1.4.5
    name = "lorebooks",
    update = function(widget, categories)
        if (categories == "initial") then
            return
        end

        local this = BS.W_LOREBOOKS
        local value = ""
        local tt = GetString(_G.BARSTEWARD_LOREBOOKS)

        for _, category in pairs(categories) do
            local metrics = string.format("%d/%d", category.numKnownBooks, category.totalBooks)
            local cat = BS.COLOURS.OffWhite:Colorize(category.name)

            tt = string.format("%s%s%s %s", tt, BS.LF, cat, metrics)

            if (BS.GetVar("ShowCategory", this) == category.name) then
                value = metrics
            end
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(this, true))

        widget:SetTooltip(tt)

        return #categories
    end,
    callback = {[CALLBACK_MANAGER] = {BS.Name .. "CB_Lorebooks_Updated"}},
    icon = "icons/quest_book_001",
    tooltip = GetString(_G.BARSTEWARD_LOREBOOKS),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("loreLibraryGamepad")
        else
            SCENE_MANAGER:Show("loreLibrary")
        end
    end,
    customSettings = function()
        local options = {}

        for categoryIndex = 1, GetNumLoreCategories() do
            local categoryName = GetLoreCategoryInfo(categoryIndex)

            table.insert(options, categoryName)
        end

        return {
            [1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_LOREBOOKS_CATEGORY),
                choices = options,
                getFunc = function()
                    return BS.Vars.Controls[BS.W_LOREBOOKS].ShowCategory
                end,
                setFunc = function(value)
                    BS.Vars.Controls[BS.W_LOREBOOKS].ShowCategory = value
                    BS.RefreshWidget(BS.W_LOREBOOKS)
                end,
                default = false
            }
        }
    end
}

BS.widgets[BS.W_SHALIDORS_LIBRARY] = {
    -- v1.5.2
    name = "shalidorsLibrary",
    update = function(widget, categories)
        if (categories == "initial") then
            return
        end

        local value = "0/0"
        local known = 0

        for _, category in pairs(categories) do
            if (category.id == BS.L_SHALIDORS_LIBRARY) then
                value = category.numKnownBooks .. "/" .. category.totalBooks
                known = category.numKnownBooks
                break
            end
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(BS.W_SHALIDORS_LIBRARY, true))

        return known
    end,
    callback = {[CALLBACK_MANAGER] = {BS.Name .. "CB_Lorebooks_Updated"}},
    icon = "icons/housing_sum_fur_booksfloatingset003",
    tooltip = BS.Format(_G.SI_ZONECOMPLETIONTYPE11),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("loreLibraryGamepad")
        else
            SCENE_MANAGER:Show("loreLibrary")
        end
    end
}

BS.widgets[BS.W_CRAFTING_MOTIFS] = {
    -- v1.5.2
    name = "craftingMotifs",
    update = function(widget, categories)
        if (categories == "initial") then
            return
        end

        local value = "0/0"
        local known = 0

        for _, category in pairs(categories) do
            if (category.id == BS.L_CRAFTING_MOTIFS) then
                value = category.numKnownBooks .. "/" .. category.totalBooks
                known = category.numKnownBooks
                break
            end
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(BS.W_CRAFTING_MOTIFS, true))

        return known
    end,
    callback = {[CALLBACK_MANAGER] = {BS.Name .. "CB_Lorebooks_Updated"}},
    icon = "icons/u34_crafting_style_item_sybranic_marine",
    tooltip = GetString(_G.BARSTEWARD_CRAFTING_MOTIFS),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("loreLibraryGamepad")
        else
            SCENE_MANAGER:Show("loreLibrary")
        end
    end
}

local function getActivityRewardInfo(activityTypes)
    local result = {}
    for _, activityType in ipairs(activityTypes) do
        local locationsData = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)

        if (locationsData) then
            for _, location in ipairs(locationsData) do
                if (location:ShouldForceFullPanelKeyboard()) then
                    if (location:HasRewardData()) then
                        local rewardUIDataId, xpReward = location:GetRewardData()
                        local numShownItemRewardNodes = GetNumLFGActivityRewardUINodes(rewardUIDataId)

                        for nodeIndex = 1, numShownItemRewardNodes do
                            local displayName, icon, red, green, blue =
                                GetLFGActivityRewardUINodeInfo(rewardUIDataId, nodeIndex)

                            if (icon) then
                                result[activityType] = {
                                    typeName = location:GetNameKeyboard(),
                                    xpReward = xpReward,
                                    displayName = zo_strformat(_G.SI_ACTIVITY_FINDER_REWARD_NAME_FORMAT, displayName),
                                    icon = icon,
                                    colour = BS.NewColour({r = red, g = green, b = blue}),
                                    active = location:IsActive() or false,
                                    meetsRequirements = location:DoesPlayerMeetLevelRequirements()
                                }
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return result
end

local function getActvityOutput(data)
    if (data.output ~= "") then
        data.output = data.output .. " "
        data.normalisedOutput = data.normalisedOutput .. " "
    end

    data.output = data.output .. BS.Icon(data.icon, nil, 32, 32)

    if (data.activityData.meetsRequirements) then
        local icon = BS.ColourToIcon(data.activityData.colour.r, data.activityData.colour.g, data.activityData.colour.b)
        data.output = data.output .. " " .. BS.Icon(icon, nil, 32, 32)
        data.eligibleCount = data.eligibleCount + 1
    else
        data.output = data.output .. " " .. BS.Icon(BS.INELIGIBLE_ICON)
    end

    data.normalisedOutput = data.normalisedOutput .. "XXXXXXX"

    data.tt = data.tt .. BS.LF .. BS.COLOURS.OffWhite:Colorize(BS.Format(data.label)) .. " "

    if (data.activityData.meetsRequirements) then
        local cdt = ZO_CommaDelimitNumber(data.activityData.xpReward)

        data.tt = data.tt .. data.activityData.colour:Colorize(data.activityData.displayName) .. " "
        data.tt = data.tt .. zo_strformat(_G.SI_ACTIVITY_FINDER_REWARD_XP_FORMAT, cdt)
    else
        data.tt = data.tt .. BS.COLOURS.Red:Colorize(BS.Format(_G.SI_HOUSE_TEMPLATE_UNMET_REQUIREMENTS_TEXT))
    end

    return data
end

BS.widgets[BS.W_RANDOM_DUNGEON] = {
    -- v1.4.22
    name = "randomDungeon",
    update = function(widget)
        local activities = {_G.LFG_ACTIVITY_DUNGEON, _G.LFG_ACTIVITY_MASTER_DUNGEON}
        local dungeonInfo = getActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = GetString(_G.BARSTEWARD_RANDOM_DUNGEON)
        }
        local nd = dungeonInfo[_G.LFG_ACTIVITY_DUNGEON]
        local vd = dungeonInfo[_G.LFG_ACTIVITY_MASTER_DUNGEON]

        if (nd) then
            data.activityData = nd
            data.label = _G.SI_DUNGEONDIFFICULTY1
            data.icon = BS.DUNGEON[_G.LFG_ACTIVITY_DUNGEON]
            data = getActvityOutput(data)
        end

        if (vd) then
            data.activityData = vd
            data.label = _G.SI_DUNGEONDIFFICULTY2
            data.icon = BS.DUNGEON[_G.LFG_ACTIVITY_MASTER_DUNGEON]
            data = getActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "icons/achievement_update11_dungeons_019",
    hideWhenEqual = 0,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_DUNGEON),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepadDungeonFinder")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end
}

BS.widgets[BS.W_RANDOM_BATTLEGROUND] = {
    -- v1.4.23
    name = "randomBattleground",
    update = function(widget)
        local activities = {_G.LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL, _G.LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION}
        local bgInfo = getActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = BS.Format(_G.SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT)
        }
        local ll = bgInfo[_G.LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] -- Random Battleground
        --local cp = bgInfo[_G.LFG_ACTIVITY_BATTLE_GROUND_CHAMPION]
        local np = bgInfo[_G.LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] -- Group Battleground
        local battleground = ll
        local icon = BS.BATTLEGROUND_ICON[_G.LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL]

        if (np) then
            if (np.meetsRequirements) then
                battleground = np
                icon = BS.BATTLEGROUND_ICON[_G.LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION]
            end
        end

        data.activityData = battleground
        data.label = ""
        data.icon = icon

        if (battleground) then
            data = getActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "icons/store_battleground",
    hideWhenEqual = 0,
    tooltip = BS.Format(_G.SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepadDungeonFinder")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end
}

BS.widgets[BS.W_RANDOM_TRIBUTE] = {
    -- v1.4.23
    name = "randomTribute",
    update = function(widget)
        local activities = {_G.LFG_ACTIVITY_TRIBUTE_COMPETITIVE, _G.LFG_ACTIVITY_TRIBUTE_CASUAL}
        local bgInfo = getActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = GetString(_G.BARSTEWARD_RANDOM_TRIBUTE)
        }
        local ct = bgInfo[_G.LFG_ACTIVITY_TRIBUTE_COMPETITIVE]
        local nt = bgInfo[_G.LFG_ACTIVITY_TRIBUTE_CASUAL]

        if (nt) then
            data.activityData = nt
            data.label = _G.SI_LFGACTIVITY10
            data.icon = BS.TRIBUTE_ICON[_G.LFG_ACTIVITY_TRIBUTE_CASUAL]
            data = getActvityOutput(data)
        end

        if (ct) then
            data.activityData = ct
            data.label = _G.SI_LFGACTIVITY9
            data.icon = BS.TRIBUTE_ICON[_G.LFG_ACTIVITY_TRIBUTE_COMPETITIVE]
            data = getActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    icon = "icons/u34_tribute_tutorial",
    hideWhenEqual = 0,
    tooltip = GetString(_G.BARSTEWARD_RANDOM_TRIBUTE),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("gamepadDungeonFinder")
        else
            SCENE_MANAGER:Show("groupMenuKeyboard")
        end
    end
}

-- widget based on InfoPanel

local function isChest(name)
    return BS.Search({"Truhe", "Coffre", "Chest", "сундук"}, name)
end

BS.widgets[BS.W_CHESTS_FOUND] = {
    -- v1.5.2
    name = "chestsFound",
    update = function(widget, _, result, targetName)
        if (BS.Vars.DungeonInfo.IsInDungeon) then
            if (result == _G.CLIENT_INTERACT_RESULT_SUCCESS and isChest(targetName)) then
                local x, y, _ = GetMapPlayerPosition("player")
                local delta = 0.003

                x = math.floor(x * 10000) / 10000
                y = math.floor(y * 10000) / 10000

                if
                    (math.abs(BS.Vars.DungeonInfo.PreviousChest.x - x) > delta and
                        math.abs(BS.Vars.DungeonInfo.PreviousChest.y - y) > delta)
                 then
                    BS.Vars.DungeonInfo.PreviousChest = {x = x, y = y}
                    BS.Vars.DungeonInfo.ChestCount = BS.Vars.DungeonInfo.ChestCount + 1
                end
            end
        end

        widget:SetValue(BS.Vars.DungeonInfo.ChestCount)
        widget:SetColour(BS.GetColour(BS.W_CHESTS_FOUND, true))

        return BS.Vars.DungeonInfo.ChestCount
    end,
    event = {_G.EVENT_CLIENT_INTERACT_RESULT, _G.EVENT_PLAYER_ACTIVATED},
    hideWhenTrue = function()
        return not IsUnitInDungeon("player")
    end,
    icon = "icons/quest_strosmkai_open_treasure_chest",
    tooltip = GetString(_G.BARSTEWARD_FOUND_CHESTS)
}

BS.widgets[BS.W_DAILY_PROGRESS] = {
    -- v1.5.4
    name = "dailyEndeavourBar",
    update = function(widget)
        local _, maxTask = getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_DAILY, nil, nil, nil, true)
        local this = BS.W_DAILY_PROGRESS

        if (maxTask.name and maxTask.maxProgress) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(maxTask.progress, 0, maxTask.maxProgress)
            else
                widget:SetValue(maxTask.progress .. "/" .. maxTask.maxProgress)
                widget:SetColour(BS.GetColour(this, true))
            end

            local ttt = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS_BEST) .. BS.LF

            ttt = ttt .. BS.COLOURS.OffWhite:Colorize(maxTask.name .. BS.LF .. BS.LF .. maxTask.description)

            widget:SetTooltip(ttt)

            return maxTask.progress == maxTask.maxProgress
        else
            return 0
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_DAILY_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_DAILY_PROGRESS].GradientEnd or endg

        return s, e
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_marked_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS_BEST),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return completed[_G.TIMED_ACTIVITY_TYPE_DAILY]
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_DAILY_PROGRESS].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_DAILY_PROGRESS].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        }
    }
}

local function updateQuests(questListType)
    for char, quests in pairs(BS.Vars:GetCommon(questListType)) do
        for quest, status in pairs(quests) do
            if (status == "complete") then
                BS.Vars:SetCommon(nil, questListType, char, quest)
            end
        end
    end
end

local function checkReset()
    local lastResetTime = BS.GetLastDailyResetTime(true)

    if (lastResetTime) then
        updateQuests("dailyQuestCount")

        BS.Vars:SetCommon(lastResetTime, "lastDailyResetCounts")

        local pledges = BS.Vars:GetCommon("pledges")

        if (pledges) then
            updateQuests("pledges")
        end
    end
end

local function findQuest(index)
    for _, quest in ipairs(BS.Quests) do
        if (quest.questIndex == index) then
            return quest
        end
    end
end

BS.widgets[BS.W_DAILY_COUNT] = {
    name = "dailyCount",
    update = function(widget, eventId, param1, param2, param3)
        if (BS.Vars:GetCommon("dailyQuestCount") == nil) then
            BS.Vars:SetCommon({}, "dailyQuestCount")
        end

        checkReset()
        zo_callLater(
            function()
                local player = GetUnitName("player")

                if (not BS.Vars:GetCommon("dailyQuestCount", player)) then
                    BS.Vars:SetCommon({}, "dailyQuestCount", player)
                end

                local counts = BS.Vars:GetCommon("dailyQuestCount", player)

                if (eventId == _G.EVENT_QUEST_ADDED) then
                    local quest = findQuest(param1)

                    if (quest) then
                        if (quest.repeatableType == _G.QUEST_REPEAT_DAILY) then
                            counts[param2] = "added"
                        end
                    end
                end

                if (eventId == _G.EVENT_QUEST_REMOVED) then
                    if (param1 ~= true) then
                        counts[param3] = nil
                    end
                end

                if (eventId == _G.EVENT_QUEST_COMPLETE) then
                    if (counts[param1] ~= nil) then
                        counts[param1] = "complete"
                    end
                end

                local added, complete = 0, 0

                for _, status in pairs(counts) do
                    if (status == "added") then
                        added = added + 1
                    end
                    if (status == "complete") then
                        complete = complete + 1
                    end
                end

                widget:SetValue(complete .. "/" .. BS.MAX_DAILY_QUESTS)

                local ttt = GetString(_G.BARSTEWARD_DAILY_QUEST_COUNT) .. BS.LF
                local ttext = BS.Format(_G.SI_DLC_BOOK_QUEST_STATUS_ACCEPTED) .. ": " .. added .. BS.LF

                ttext = ttext .. zo_strformat(_G.SI_NOTIFYTEXT_QUEST_COMPLETE, complete)
                ttt = ttt .. BS.COLOURS.OffWhite:Colorize(ttext)

                widget:SetTooltip(ttt)
            end,
            500
        )
    end,
    event = {
        _G.EVENT_QUEST_ADDED,
        _G.EVENT_QUEST_REMOVED,
        _G.EVENT_QUEST_COMPLETE
    },
    icon = "floatingmarkers/repeatablequest_available_icon",
    tooltip = GetString(_G.BARSTEWARD_DAILY_QUEST_COUNT)
}

SecurePostHook(
    IsInGamepadPreferredMode() and _G.FISHING_GAMEPAD or _G.FISHING_KEYBOARD,
    "PrepareForInteraction",
    function()
        local isFishing = false

        if (not SCENE_MANAGER:IsInUIMode()) then
            local additionalInfo = select(5, GetGameCameraInteractableActionInfo())

            if (additionalInfo == _G.ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
                if (GetFishingLure() ~= 0) then
                    isFishing = true
                end
            end
        end

        if (isFishing) then
            BS.isFishing = true
            BS.lastTrigger = os.time()
        end
    end
)

local fishingTimeout = 33

BS.widgets[BS.W_FISHING] = {
    -- v3.0.0
    name = "fishing",
    update = function(widget, event, ...)
        if (event == _G.EVENT_LOOT_RECEIVED) then
            if ((os.time() - fishingTimeout) > (BS.lastTrigger or 0)) then
                BS.isFishing = false
            end

            if (BS.isFishing) then
                local itemLink = select(2, ...)
                local itemType, _ = GetItemLinkItemType(itemLink)

                BS.Vars.FishingLoot[itemType] = (BS.Vars.FishingLoot[itemType] or 0) + 1
                BS.isFishing = false
            end
        end

        local loot = ""
        local tt = BS.Format(_G.SI_GUILDACTIVITYATTRIBUTEVALUE9)
        local typeCount = 0

        for lootType, count in pairs(BS.Vars.FishingLoot) do
            local info = BS.ITEM_TYPE_ICON[lootType]
            if (info) then
                loot = loot .. BS.Icon(info.icon) .. " "
                loot = loot .. count .. " "

                typeCount = typeCount + 3 + tostring(count):len()

                local ttext = zo_strformat("<<1>> <<2>> <<m:3>>", BS.Icon(info.icon), count, GetString(info.name))

                tt = tt .. BS.LF .. BS.COLOURS.OffWhite:Colorize(ttext)
            end
        end

        local setwidth = string.rep("8", typeCount)

        if (loot:len() == 0) then
            widget:SetValue(0)
        else
            widget:SetValue(BS.Trim(loot), setwidth)
            widget:SetTooltip(tt)
        end
    end,
    event = _G.EVENT_LOOT_RECEIVED,
    icon = "icons/fishing_discus_blue_turquoise",
    onLeftClick = function()
        BS.Clear(BS.Vars.FishingLoot)
        BS.RefreshWidget(BS.W_FISHING)
    end,
    tooltip = BS.Format(_G.SI_GUILDACTIVITYATTRIBUTEVALUE9)
}

local function getPledgeIds()
    local pledges = {}

    for _, info in pairs(BS.LUP.IDS) do
        for _, data in ipairs(info) do
            local id = data[2]
            local questName = GetQuestName(id)

            pledges[BS.Format(questName)] = true
        end
    end

    return pledges
end

-- check once a minute for daily reset
BS.RegisterForUpdate(60000, checkReset)

BS.widgets[BS.W_DAILY_PLEDGES] = {
    name = "dailyPledges",
    update = function(widget, event, completeName, addedName, removedName)
        if (not BS.LUP) then
            return true
        end

        if (not BS.Pledges) then
            BS.Pledges = getPledgeIds()
        end

        local update = true
        local added, done
        local character = GetUnitName("player")
        local maxPledges = 3

        checkReset()

        if (BS.Vars:GetCommon("pledges") == nil) then
            BS.Vars:SetCommon({}, "pledges")
        end

        if (BS.Vars:GetCommon("pledges", character) == nil) then
            BS.Vars:SetCommon({}, "pledges", character)
        end

        if (event == _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED) then
            addedName = 1
        end

        completeName = BS.Format((type(completeName) == "string") and completeName or "null")
        addedName = BS.Format((type(addedName) == "string") and addedName or "null")
        removedName = BS.Format((type(removedName) == "string") and removedName or "null")

        if (BS.Pledges[completeName]) then
            BS.Vars:SetCommon("done", "pledges", character, completeName)
        elseif (BS.Pledges[addedName]) then
            BS.Vars:SetCommon("added", "pledges", character, addedName)
        elseif (BS.Pledges[removedName]) then
            -- addedName is actually 'completed' in this case
            if (tostring(addedName) ~= "true") then
                BS.Vars:SetCommon(nil, "pledges", character, removedName)
            end
        elseif (event ~= "initial") then
            update = false
        end

        if (completeName == "null" and addedName == "null" and removedName == "null") then
            -- initial load
            update = true
        end

        added = BS.CountState("added", character, true)
        done = BS.CountState("done", character, true)

        local colour = BS.COLOURS.DefaultColour

        if (done == maxPledges) then
            colour = BS.COLOURS.DefaultOkColour
            BS.Vars:SetCommon(true, "pledges", character, "complete")
        elseif (added == maxPledges) then
            colour = BS.COLOURS.DefaultWarningColour
            BS.Vars:SetCommon(true, "pledges", character, "pickedup")
        end

        if (update) then
            widget:SetValue(added .. "/" .. done .. "/" .. maxPledges)
            widget:SetColour(colour)

            local ttt = GetString(_G.BARSTEWARD_DAILY_PLEDGES) .. BS.LF
            local pledgeQuests = BS.Vars:GetCommon("pledges", character)

            for name, status in pairs(pledgeQuests) do
                local ttext

                ttt = ttt .. BS.LF

                if (status == "done") then
                    ttext = string.format("%s%s - %s", ttt, name, GetString(_G.BARSTEWARD_COMPLETED))
                    ttt = ttt .. BS.COLOURS.DefaultOkColour:Colorize(ttext)
                elseif (status == "added") then
                    ttext = string.format("%s%s - %s", ttt, name, GetString(_G.BARSTEWARD_PICKED_UP))
                    ttt = ttt .. BS.COLOURS.DefaultWarningColour:Colorize(ttext)
                end
            end

            local charPledgesTT = ""

            if (BS.Vars:GetCommon("CharacterList")) then
                local ccolour = BS.COLOURS.DefaultColour
                local chars = BS.Vars:GetCommon("CharacterList")

                for char, _ in pairs(chars) do
                    if (char ~= character) then
                        local charPledges = BS.Vars:GetCommon("pledges", char)
                        local stext

                        if (charPledges and (BS.CountElements(charPledges) > 0)) then
                            local dccolour = ccolour
                            local cadded = BS.CountState("added", char, true)
                            local cdone = BS.CountState("done", char, true)
                            local status = cadded .. "/" .. cdone .. "/" .. maxPledges

                            if (cdone == maxPledges) then
                                dccolour = BS.COLOURS.DefaultOkColour
                            elseif (cadded == maxPledges) then
                                dccolour = BS.COLOURS.DefaultWarningColour
                            end

                            stext = dccolour:Colorize(status)
                            charPledgesTT = string.format("%s%s%s: %s", charPledgesTT, BS.LF, char, stext)
                        else
                            stext = ccolour:Colorize("0/0/" .. maxPledges)
                            charPledgesTT = string.format("%s%s%s: %s", charPledgesTT, BS.LF, char, stext)
                        end
                    end
                end
            end

            widget:SetTooltip(ttt .. charPledgesTT)
        end

        return done == maxPledges
    end,
    event = {
        _G.EVENT_QUEST_ADDED,
        _G.EVENT_QUEST_REMOVED,
        _G.EVENT_QUEST_COMPLETE,
        _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED
    },
    icon = "icons/event_undaunted_commendation",
    tooltip = GetString(_G.BARSTEWARD_DAILY_PLEDGES),
    hideWhenEqual = true
}
