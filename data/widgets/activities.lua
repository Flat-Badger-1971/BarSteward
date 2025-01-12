local BS = _G.BarSteward
local star = BS.Icon("targetmarkers/target_gold_star_64")

local function getColourOptions(widgetIndex)
    local colours = {["Red"] = "Danger", ["Amber"] = "Warning", ["Green"] = "Ok"}
    local vars = BS.Vars.Controls[widgetIndex]
    local index = 2
    local settings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_RAG),
            getFunc = function()
                return BS.Vars.Controls[widgetIndex].UseRag
            end,
            setFunc = function(value)
                BS.Vars.Controls[widgetIndex].UseRag = value
                BS.RefreshWidget(widgetIndex)
            end,
            width = "full",
            default = false
        }
    }

    for colour, default in pairs(colours) do
        local c = colour .. "Colour"

        settings[index] = {
            type = "colorpicker",
            name = GetString(_G["BARSTEWARD_" .. colour:upper()]),
            getFunc = function()
                return unpack(vars[c] or BS.Vars["Default" .. default .. "Colour"])
            end,
            setFunc = function(r, g, b, a)
                if (BS.LC.CompareColours({r, g, b, a}, BS.Vars["Default" .. default .. "Colour"])) then
                    vars[c] = nil
                else
                    vars[c] = {r, g, b, a}
                end

                BS.RefreshWidget(widgetIndex)
            end,
            width = "full",
            default = unpack(BS.Vars["Default" .. default .. "Colour"]),
            disabled = function()
                return not BS.Vars.Controls[widgetIndex].UseRag
            end
        }

        index = index + 1
    end

    return settings
end

local function configureWidget(widget, complete, maxComplete, activityType, tasks, hideLimit, defaultTooltip)
    local widgetIndex = activityType == TIMED_ACTIVITY_TYPE_DAILY and BS.W_DAILY_ENDEAVOURS or BS.W_WEEKLY_ENDEAVOURS
    local colour = BS.GetColour(widgetIndex, true)

    if (BS.GetVar("UseRag", widgetIndex)) then
        if (complete > 0 and complete < maxComplete) then
            colour = BS.GetColour(widgetIndex, "Amber", "DefaultWarningColour", true)
        elseif (complete == maxComplete) then
            colour = BS.GetColour(widgetIndex, "Green", "DefaultOkColour", true)
        else
            colour = BS.GetColour(widgetIndex, "Red", "DefaultDangerColour", true)
        end
    end

    widget:SetValue(complete .. (hideLimit and "" or ("/" .. maxComplete)))
    widget:SetColour(colour)

    if (#tasks > 0) then
        local tooltipText = defaultTooltip or ""
        local maxValue, maxIndex, allEqual = 0, 0, true

        if (activityType == TIMED_ACTIVITY_TYPE_DAILY) then
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
            if (activityType == TIMED_ACTIVITY_TYPE_DAILY) then
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
            TIMED_ACTIVITY_TYPE_DAILY,
            widget,
            BS.GetVar("HideLimit", BS.W_DAILY_ENDEAVOURS),
            GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS)
        )
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_checked_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
            TIMED_ACTIVITIES_KEYBOARD:SetCurrentActivityType(TIMED_ACTIVITY_TYPE_DAILY)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_DAILY)
    end,
    customSettings = function()
        return getColourOptions(BS.W_DAILY_ENDEAVOURS)
    end
}

BS.widgets[BS.W_WEEKLY_ENDEAVOURS] = {
    -- v1.0.1
    name = "weeklyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(
            TIMED_ACTIVITY_TYPE_WEEKLY,
            widget,
            BS.GetVar("HideLimit", BS.W_WEEKLY_ENDEAVOURS),
            GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS)
        )
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_checked_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
            TIMED_ACTIVITIES_KEYBOARD:SetCurrentActivityType(TIMED_ACTIVITY_TYPE_WEEKLY)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_WEEKLY)
    end,
    customSettings = function()
        return getColourOptions(BS.W_WEEKLY_ENDEAVOURS)
    end
}

BS.widgets[BS.W_ENDEAVOUR_PROGRESS] = {
    -- v1.2.14
    name = "weeklyEndeavourBar",
    update = function(widget)
        local this = BS.W_ENDEAVOUR_PROGRESS
        local _, maxTask = getTimedActivityProgress(TIMED_ACTIVITY_TYPE_WEEKLY, nil)

        if (maxTask.name and maxTask.maxProgress) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(maxTask.progress, 0, maxTask.maxProgress)
            else
                widget:SetValue(maxTask.progress .. "/" .. maxTask.maxProgress)
                widget:SetColour(BS.GetColour(this, true))
            end

            local ttt = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST) .. BS.LF
            local taskInfo = maxTask.name .. BS.LF .. BS.LF .. maxTask.description

            ttt = ttt .. BS.COLOURS.White:Colorize(taskInfo)

            widget:SetTooltip(ttt)

            return maxTask.progress == maxTask.maxProgress
        else
            return 0
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientEnd or endg

        return s, e
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_marked_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_WEEKLY)
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
        [ANTIQUITY_DIFFICULTY_TRIVIAL] = BS.COLOURS.ZOSGrey,
        [ANTIQUITY_DIFFICULTY_SIMPLE] = BS.COLOURS.ZOSGreen,
        [ANTIQUITY_DIFFICULTY_INTERMEDIATE] = BS.COLOURS.ZOSBlue,
        [ANTIQUITY_DIFFICULTY_ADVANCED] = BS.COLOURS.ZOSPurple,
        [ANTIQUITY_DIFFICULTY_MASTER] = BS.COLOURS.ZOSGold,
        [ANTIQUITY_DIFFICULTY_ULTIMATE] = BS.COLOURS.ZOSOrange
    }

    if ((lead.quality or 0) == 0) then
        return BS.GetColour(BS.W_LEADS, true)
    end

    return difficultyColours[lead.quality]
end

BS.isScryingUnlocked = false

BS.EventManager:RegisterForEvent(
    EVENT_PLAYER_ACTIVATED,
    function()
        BS.isScryingUnlocked = ZO_IsScryingUnlocked()
    end
)

BS.EventManager:RegisterForEvent(
    EVENT_SKILL_LINE_ADDED,
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
                    name = BS.LC.Format(leadInfo:GetName()),
                    colourName = leadInfo:GetColorizedFormattedName(),
                    remaining = leadInfo:GetLeadTimeRemainingS(),
                    quality = leadInfo:GetQuality(),
                    zone = BS.LC.Format(GetZoneNameById(leadInfo:GetZoneId())),
                    id = antiquityId,
                    inProgress = GetNumAntiquityDigSites(antiquityId) > 0,
                    recovered = leadInfo:GetNumRecovered()
                }

                if (not (BS.GetVar("HideFound", this) and (lead.recovered > 0))) then
                    table.insert(leads, lead)

                    if (not lead.inProgress) then
                        if (lead.remaining < minTime) then
                            minTime = lead.remaining
                        end
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

            local ttt = BS.LC.Format(SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS)

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
                    local found = zo_strformat(SI_ANTIQUITY_TIMES_ACQUIRED, lead.recovered)
                    ttt = ttt .. " - " .. found
                end
            end

            widget:SetTooltip(ttt)
        end

        return minTime
    end,
    timer = 1000,
    icon = GetAntiquityLeadIcon(),
    tooltip = BS.LC.Format(SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS),
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
        },
        [4] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_FOUND),
            getFunc = function()
                return BS.Vars.Controls[BS.W_LEADS].HideFound or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_LEADS].HideFound = value
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
        return getTimedActivityTimeRemaining(TIMED_ACTIVITY_TYPE_DAILY, BS.W_DAILY_ENDEAVOUR_TIME, widget)
    end,
    timer = 1000,
    event = EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_DAILY)
    end,
    icon = "journal/u26_progress_digsite_unknown_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_TIME),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end
}

BS.widgets[BS.W_WEEKLY_ENDEAVOUR_TIME] = {
    -- v1.2.18
    name = "weeklyEndeavourTime",
    update = function(widget)
        return getTimedActivityTimeRemaining(TIMED_ACTIVITY_TYPE_WEEKLY, BS.W_WEEKLY_ENDEAVOUR_TIME, widget)
    end,
    timer = 1000,
    event = EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
    icon = "journal/u26_progress_digsite_unknown_complete",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_TIME),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_WEEKLY)
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
            local percent = BS.LC.ToPercent(xp, totalxp)
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
            ttt = ttt .. BS.COLOURS.White:Colorize(text)

            widget:SetTooltip(ttt)
        end
    end,
    event = {
        EVENT_PLAYER_ACTIVATED,
        EVENT_TRIBUTE_CLUB_RANK_CHANGED,
        EVENT_TRIBUTE_CLUB_EXPERIENCE_GAINED,
        EVENT_TRIBUTE_CLUB_INIT
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
            value = BS.LC.ToPercent(earnedPoints, totalPoints, true)
        end

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(this, true))

        local ttt = BS.LC.Format(SI_ACHIEVEMENTS_OVERALL) .. BS.LF

        ttt = ttt .. BS.COLOURS.White:Colorize(earnedPoints .. "/" .. totalPoints)

        widget:SetTooltip(ttt)

        return widget:GetValue()
    end,
    event = {
        EVENT_PLAYER_ACTIVATED,
        EVENT_ACHIEVEMENT_UPDATED,
        EVENT_ACHIEVEMENT_AWARDED,
        EVENT_ACHIEVEMENTS_UPDATED
    },
    icon = "journal/journal_tabicon_achievements_up",
    tooltip = BS.LC.Format(SI_ACHIEVEMENTS_OVERALL),
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
        return getTimedActivityTimeRemaining(TIMED_ACTIVITY_TYPE_DAILY, BS.W_PLEDGES_TIME, widget)
    end,
    timer = 1000,
    icon = "icons/undaunted_bigcoffer",
    tooltip = GetString(_G.BARSTEWARD_DAILY_PLEDGES_TIME)
}

local function setTracker(widgetIndex, resetSeconds, tooltip)
    if (not BS.Vars:GetCommon("Trackers", widgetIndex)) then
        BS.Vars:SetCommon({}, "Trackers", widgetIndex)
    end

    local thisCharacter = BS.CHAR.name

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

BS.EventManager:RegisterForEvent(
    EVENT_PLAYER_ACTIVATED,
    function()
        BS.isShadowyVendorUnlocked = BS.IsShadowyVendorUnlocked()
    end
)

BS.EventManager:RegisterForEvent(
    EVENT_SKILL_LINE_ADDED,
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
        local timeToReset = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
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
                if (not hidden) then
                    category.numKnownBooks = category.numKnownBooks + numKnownBooks
                    category.totalBooks = category.totalBooks + totalBooks
                end
            end

            categories[categoryIndex] = category
        end

        BS.FireCallbacks("LorebooksUpdated", categories)
    end
end

BS.EventManager:RegisterForEvent(EVENT_PLAYER_ACTIVATED, updateLoreBooks)
BS.EventManager:RegisterForEvent(EVENT_LORE_BOOK_LEARNED, updateLoreBooks)
BS.EventManager:RegisterForEvent(EVENT_STYLE_LEARNED, updateLoreBooks)
BS.EventManager:RegisterForEvent(EVENT_TRAIT_LEARNED, updateLoreBooks)

BS.widgets[BS.W_LOREBOOKS] = {
    -- v1.4.5
    name = "lorebooks",
    update = function(widget, categories)
        if (categories == "initial") then
            categories = {}
        end

        local this = BS.W_LOREBOOKS
        local value = "0/0"
        local tt = GetString(_G.BARSTEWARD_LOREBOOKS)

        for _, category in pairs(categories) do
            local metrics = string.format("%s/%s", category.numKnownBooks, category.totalBooks)
            local cat = BS.COLOURS.White:Colorize(category.name)

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
    callback = {[BS.CallbackManager] = {"LorebooksUpdated"}},
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
    callback = {[BS.CallbackManager] = {"LorebooksUpdated"}},
    icon = "icons/housing_sum_fur_booksfloatingset003",
    tooltip = BS.LC.Format(SI_ZONECOMPLETIONTYPE11),
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
    callback = {[BS.CallbackManager] = {"LorebooksUpdated"}},
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

function BS.GetActivityRewardInfo(activityTypes)
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
                                    displayName = zo_strformat(SI_ACTIVITY_FINDER_REWARD_NAME_FORMAT, displayName),
                                    icon = icon,
                                    colour = BS.LC.Colour({r = red, g = green, b = blue}),
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

function BS.GetActvityOutput(data)
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

    data.tt = data.tt .. BS.LF .. BS.COLOURS.White:Colorize(BS.LC.Format(data.label)) .. " "

    if (data.activityData.meetsRequirements) then
        local cdt = ZO_CommaDelimitNumber(data.activityData.xpReward)

        data.tt = data.tt .. data.activityData.colour:Colorize(data.activityData.displayName) .. " "
        data.tt = data.tt .. zo_strformat(SI_ACTIVITY_FINDER_REWARD_XP_FORMAT, cdt)
    else
        data.tt = data.tt .. BS.COLOURS.Red:Colorize(BS.LC.Format(SI_HOUSE_TEMPLATE_UNMET_REQUIREMENTS_TEXT))
    end

    return data
end

BS.widgets[BS.W_RANDOM_DUNGEON] = {
    -- v1.4.22
    name = "randomDungeon",
    update = function(widget)
        local activities = {LFG_ACTIVITY_DUNGEON, LFG_ACTIVITY_MASTER_DUNGEON}
        local dungeonInfo = BS.GetActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = GetString(_G.BARSTEWARD_RANDOM_DUNGEON)
        }
        local nd = dungeonInfo[LFG_ACTIVITY_DUNGEON]
        local vd = dungeonInfo[LFG_ACTIVITY_MASTER_DUNGEON]

        if (nd) then
            data.activityData = nd
            data.label = SI_DUNGEONDIFFICULTY1
            data.icon = BS.DUNGEON[LFG_ACTIVITY_DUNGEON]
            data = BS.GetActvityOutput(data)
        end

        if (vd) then
            data.activityData = vd
            data.label = SI_DUNGEONDIFFICULTY2
            data.icon = BS.DUNGEON[LFG_ACTIVITY_MASTER_DUNGEON]
            data = BS.GetActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = EVENT_PLAYER_ACTIVATED,
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

BS.widgets[BS.W_RANDOM_TRIBUTE] = {
    -- v1.4.23
    name = "randomTribute",
    update = function(widget)
        local activities = {LFG_ACTIVITY_TRIBUTE_COMPETITIVE, LFG_ACTIVITY_TRIBUTE_CASUAL}
        local bgInfo = BS.GetActivityRewardInfo(activities)
        local data = {
            output = "",
            normalisedOutput = "",
            eligibleCount = 0,
            tt = GetString(_G.BARSTEWARD_RANDOM_TRIBUTE)
        }
        local ct = bgInfo[LFG_ACTIVITY_TRIBUTE_COMPETITIVE]
        local nt = bgInfo[LFG_ACTIVITY_TRIBUTE_CASUAL]

        if (nt) then
            data.activityData = nt
            data.label = SI_LFGACTIVITY10
            data.icon = BS.TRIBUTE_ICON[LFG_ACTIVITY_TRIBUTE_CASUAL]
            data = BS.GetActvityOutput(data)
        end

        if (ct) then
            data.activityData = ct
            data.label = SI_LFGACTIVITY9
            data.icon = BS.TRIBUTE_ICON[LFG_ACTIVITY_TRIBUTE_COMPETITIVE]
            data = BS.GetActvityOutput(data)
        end

        widget:SetValue(data.output, data.normalisedOutput)
        widget:SetTooltip(data.tt)

        return data.eligibleCount
    end,
    event = EVENT_PLAYER_ACTIVATED,
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
    return BS.LC.Search({"Truhe", "Coffre", "Chest", "сундук", "胸部"}, name)
end

BS.widgets[BS.W_CHESTS_FOUND] = {
    -- v1.5.2
    name = "chestsFound",
    update = function(widget, _, result, targetName)
        if (BS.Vars.DungeonInfo.IsInDungeon) then
            if (result == CLIENT_INTERACT_RESULT_SUCCESS and isChest(targetName)) then
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
    event = {EVENT_CLIENT_INTERACT_RESULT, EVENT_PLAYER_ACTIVATED},
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
        local _, maxTask = getTimedActivityProgress(TIMED_ACTIVITY_TYPE_DAILY, nil, nil, nil, true)
        local this = BS.W_DAILY_PROGRESS

        if (maxTask.name and maxTask.maxProgress) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(maxTask.progress, 0, maxTask.maxProgress)
            else
                widget:SetValue(maxTask.progress .. "/" .. maxTask.maxProgress)
                widget:SetColour(BS.GetColour(this, true))
            end

            local ttt = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS_BEST) .. BS.LF

            ttt = ttt .. BS.COLOURS.White:Colorize(maxTask.name .. BS.LF .. BS.LF .. maxTask.description)

            widget:SetTooltip(ttt)

            return maxTask.progress == maxTask.maxProgress
        else
            return 0
        end
    end,
    gradient = function()
        local startg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_DAILY_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_DAILY_PROGRESS].GradientEnd or endg

        return s, e
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "journal/u26_progress_digsite_marked_incomplete",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS_BEST),
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end,
    complete = function()
        return TIMED_ACTIVITIES_MANAGER:IsAtTimedActivityTypeLimit(TIMED_ACTIVITY_TYPE_DAILY)
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
    local list = BS.Vars:GetCommon(questListType)

    if (not list) then
        BS.Vars:SetCommon({}, questListType)
        list = BS.Vars:GetCommon(questListType)
    end

    if (list) then
        for char, quests in pairs(list) do
            for quest, status in pairs(quests) do
                if (status == "complete" or status == "done") then
                    BS.Vars:SetCommon(nil, questListType, char, quest)
                end
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
                local player = BS.CHAR.name

                if (not BS.Vars:GetCommon("dailyQuestCount", player)) then
                    BS.Vars:SetCommon({}, "dailyQuestCount", player)
                end

                local counts = BS.Vars:GetCommon("dailyQuestCount", player)

                if (eventId == EVENT_QUEST_ADDED) then
                    local quest = findQuest(param1)

                    if (quest) then
                        if (quest.repeatableType == QUEST_REPEAT_DAILY) then
                            counts[param2] = "added"
                        end
                    end
                end

                if (eventId == EVENT_QUEST_REMOVED) then
                    if (param1 ~= true) then
                        counts[param3] = nil
                    end
                end

                if (eventId == EVENT_QUEST_COMPLETE) then
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

                widget:SetValue(tostring(complete) .. "/" .. BS.MAX_DAILY_QUESTS)
                widget:ForceResize()
                BS.ResizeBar(BS.GetVar("Bar", BS.W_DAILY_COUNT))

                local ttt = GetString(_G.BARSTEWARD_DAILY_QUEST_COUNT) .. BS.LF
                local ttext = BS.LC.Format(SI_DLC_BOOK_QUEST_STATUS_ACCEPTED) .. ": " .. added .. BS.LF

                ttext = ttext .. zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, complete)
                ttt = ttt .. BS.COLOURS.White:Colorize(ttext)

                widget:SetTooltip(ttt)
            end,
            500
        )
    end,
    event = {
        EVENT_QUEST_ADDED,
        EVENT_QUEST_REMOVED,
        EVENT_QUEST_COMPLETE
    },
    icon = "floatingmarkers/repeatablequest_available_icon",
    tooltip = GetString(_G.BARSTEWARD_DAILY_QUEST_COUNT)
}

SecurePostHook(
    IsInGamepadPreferredMode() and FISHING_GAMEPAD or FISHING_KEYBOARD,
    "PrepareForInteraction",
    function()
        local isFishing = false

        if (not SCENE_MANAGER:IsInUIMode()) then
            local additionalInfo = select(5, GetGameCameraInteractableActionInfo())

            if (additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
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
        if (event == EVENT_LOOT_RECEIVED) then
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
        local tt = BS.LC.Format(SI_GUILDACTIVITYATTRIBUTEVALUE9)
        local typeCount = 0

        for lootType, count in pairs(BS.Vars.FishingLoot) do
            local info = BS.ITEM_TYPE_ICON[lootType]

            if (info) then
                loot = loot .. BS.Icon(info.icon) .. " "
                loot = loot .. count .. " "

                typeCount = typeCount + 3 + tostring(count):len()

                local ttext = zo_strformat("<<1>> <<2>> <<m:3>>", BS.Icon(info.icon), count, GetString(info.name))

                tt = tt .. BS.LF .. BS.COLOURS.White:Colorize(ttext)
            end
        end
        local setwidth = string.rep("8", typeCount)

        if (loot:len() == 0) then
            widget:SetValue(0)
        else
            widget:SetValue(BS.LC.Trim(loot), setwidth)
            widget:SetTooltip(tt)
        end
    end,
    event = EVENT_LOOT_RECEIVED,
    icon = "icons/fishing_discus_blue_turquoise",
    onLeftClick = function()
        BS.LC.Clear(BS.Vars.FishingLoot)
        BS.RefreshBar(BS.W_FISHING)
        BS.ForceResize(BS.W_FISHING)
        BS.ResizeBar(BS.GetVar("Bar", BS.W_FISHING))
    end,
    tooltip = BS.LC.Format(SI_GUILDACTIVITYATTRIBUTEVALUE9)
}

local function getPledgeIds()
    local pledges = {}

    for _, info in pairs(BS.LUP.IDS) do
        for _, data in ipairs(info) do
            local id = data[2]
            local questName = GetQuestName(id)

            pledges[BS.LC.Format(questName)] = true
        end
    end

    return pledges
end

-- check once a minute for daily reset
BS.TimerManager:RegisterForUpdate(60000, checkReset)

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
        local character = BS.CHAR.name
        local maxPledges = 3

        checkReset()

        if (BS.Vars:GetCommon("pledges") == nil) then
            BS.Vars:SetCommon({}, "pledges")
        end

        if (BS.Vars:GetCommon("pledges", character) == nil) then
            BS.Vars:SetCommon({}, "pledges", character)
        end

        if (event == EVENT_QUEST_CONDITION_COUNTER_CHANGED) then
            addedName = 1
        end

        completeName = BS.LC.Format((type(completeName) == "string") and completeName or "null")
        addedName = BS.LC.Format((type(addedName) == "string") and addedName or "null")
        removedName = BS.LC.Format((type(removedName) == "string") and removedName or "null")

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

            local ttt, tt = GetString(_G.BARSTEWARD_DAILY_PLEDGES) .. BS.LF, ""
            local pledgeQuests = BS.Vars:GetCommon("pledges", character)

            for name, status in pairs(pledgeQuests) do
                local ttext

                if (status == "done") then
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_COMPLETED))
                    tt = string.format("%s%s%s", tt, BS.COLOURS.DefaultOkColour:Colorize(ttext), BS.LF)
                elseif (status == "added") then
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_PICKED_UP))
                    tt = string.format("%s%s%s", tt, BS.COLOURS.DefaultWarningColour:Colorize(ttext), BS.LF)
                end
            end

            ttt = ttt .. tt

            local charPledgesTT = ""

            if (BS.Vars:GetCommon("CharacterList")) then
                local ccolour = BS.COLOURS.DefaultColour
                local chars = BS.Vars:GetCommon("CharacterList")

                for char, _ in pairs(chars) do
                    if (char ~= character) then
                        local charPledges = BS.Vars:GetCommon("pledges", char)
                        local stext

                        if (charPledges and (BS.LC.CountElements(charPledges) > 0)) then
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

            widget:SetTooltip(BS.LC.Trim(ttt .. charPledgesTT))
        end

        return done == maxPledges
    end,
    event = {
        EVENT_QUEST_ADDED,
        EVENT_QUEST_REMOVED,
        EVENT_QUEST_COMPLETE,
        EVENT_QUEST_CONDITION_COUNTER_CHANGED
    },
    icon = "icons/event_undaunted_commendation",
    tooltip = GetString(_G.BARSTEWARD_DAILY_PLEDGES),
    hideWhenEqual = true
}

local function resetAchTracker()
    local achs = BS.IsTracked()

    for id, _ in pairs(achs) do
        achs[id] = "ready"
    end

    BS.Vars:SetCommon(achs, "AchievementTracking")
end

local function checkAchReset()
    local lastResetTime = BS.GetLastDailyResetTime(nil, true)

    if (lastResetTime) then
        resetAchTracker()
        BS.Vars:SetCommon(lastResetTime, "lastDailyResetAch")
    end
end

local achievements = {}

BS.widgets[BS.W_ACHIEVEMENT_TRACKER] = {
    -- v3.2.17
    name = "achTracker",
    update = function(widget, event, updatedId, _, awardedId)
        if (not BS.Tracking) then
            BS.TrackAchievements()
        end

        local id = event == EVENT_ACHIEVEMENT_UPDATED and updatedId or awardedId
        local this = BS.W_ACHIEVEMENT_TRACKER
        local tracked = BS.IsTracked()
        local completed, achCount = 0, BS.LC.CountElements(tracked)
        local daily = BS.GetVar("Daily", this)

        if (BS.IsTracked(id) and event ~= "initial") then
            -- TODO: update achievementId for staged achievements
            -- TODO: option to remove completed achievements
            -- TODO: sort out daily reset
            local name, icon, stepsRemaining, stepsRequired = BS.AchievementNotifier(id, true)

            achievements[id] = {
                completed = stepsRemaining == 0,
                icon = icon,
                name = name,
                remaining = stepsRemaining,
                required = stepsRequired,
                updated = true
            }

            if (daily) then
                BS.SetTracked(id, "done")
            end
        elseif (event == "initial") then
            for achId, track in pairs(tracked) do
                if (track) then
                    local name, icon, stepsRemaining, stepsRequired = BS.AchievementNotifier(achId, false)
                    local topLevelIndex = GetCategoryInfoFromAchievementId(achId)
                    local catName = GetAchievementCategoryInfo(topLevelIndex)

                    achievements[achId] = {
                        category = BS.LC.Format(catName),
                        completed = stepsRemaining == 0,
                        icon = icon,
                        name = name,
                        remaining = stepsRemaining,
                        required = stepsRequired
                    }

                    completed = completed + ((stepsRemaining == 0) and 1 or 0)

                    if (daily and (track == "done")) then
                        achievements[achId].updated = true
                    end
                end
            end
        end

        if (daily) then
            checkAchReset()
            completed =
                BS.LC.CountElements(
                BS.LC.Filter(
                    achievements,
                    function(v)
                        return v.updated == true
                    end
                )
            )
        end

        local usePc = BS.GetVar("ShowPercent", this)
        local value =
            usePc and BS.LC.ToPercent(completed, achCount, true) or
            string.format("%s/%s", tostring(completed), tostring(achCount))

        widget:SetValue(value)
        widget:SetColour(BS.GetColour(this, true))

        local tt = GetString(_G.BARSTEWARD_TRACKER) .. BS.LF
        local tttable = {}

        for _, ach in pairs(achievements) do
            table.insert(
                tttable,
                {
                    category = ach.category,
                    completed = ach.completed,
                    name = ach.name,
                    remaining = ach.remaining,
                    required = ach.required,
                    updated = ach.updated
                }
            )
        end

        table.sort(
            tttable,
            function(a, b)
                local compa = (a.category or "") .. (a.name or "")
                local compb = (b.category or "") .. (b.name or "")

                return compa < compb
            end
        )

        for _, data in ipairs(tttable) do
            local done = data.required - data.remaining
            local required = data.required
            local colour = daily and BS.LC.Grey or BS.LC.Yellow
            local t

            if (daily) then
                if (data.updated) then
                    colour = BS.LC.ZOSGreen
                end
            else
                if (data.completed) then
                    done = required
                    colour = BS.LC.ZOSGreen
                end
            end

            local progress =
                usePc and BS.LC.ToPercent(done, required, true) or
                string.format("%s/%s", tostring(done), tostring(required))
            t = string.format("%s - %s - %s", data.category, colour:Colorize(data.name), BS.LC.White:Colorize(progress))

            tt = string.format("%s%s%s", tt, BS.LF, t)
        end

        widget:SetTooltip(BS.LC.Trim(tt))

        return #achievements
    end,
    event = {EVENT_ACHIEVEMENT_AWARDED, EVENT_ACHIEVEMENT_UPDATED},
    icon = "icons/housing_u42_mb_eye",
    tooltip = GetString(_G.BARSTEWARD_TRACKER),
    onLeftClick = function()
        if (IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("achievementsGamepad")
        else
            SCENE_MANAGER:Show("achievements")
        end
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = BS.LC.Format(SI_TIMEDACTIVITYTYPE0),
            getFunc = function()
                return BS.GetVar("Daily", BS.W_ACHIEVEMENT_TRACKER)
            end,
            setFunc = function(value)
                local overall = BS.GetVar("Overall", BS.W_ACHIEVEMENT_TRACKER)

                if (value and overall) then
                    BS.SetVar(false, "Overall", BS.W_ACHIEVEMENT_TRACKER)
                end

                BS.SetVar(value, "Daily", BS.W_ACHIEVEMENT_TRACKER)
                BS.RefreshWidget(BS.W_ACHIEVEMENT_TRACKER)
            end,
            width = "full",
            default = false
        },
        [2] = {
            type = "checkbox",
            name = BS.LC.Format(SI_CAMPAIGN_LEADERBOARDS_OVERALL),
            getFunc = function()
                return BS.GetVar("Overall", BS.W_ACHIEVEMENT_TRACKER)
            end,
            setFunc = function(value)
                local overall = BS.GetVar("Daily", BS.W_ACHIEVEMENT_TRACKER)

                if (value and overall) then
                    BS.SetVar(false, "Daily", BS.W_ACHIEVEMENT_TRACKER)
                end

                BS.SetVar(value, "Overall", BS.W_ACHIEVEMENT_TRACKER)
                BS.RefreshWidget(BS.W_ACHIEVEMENT_TRACKER)
            end,
            width = "full",
            default = true
        },
        [3] = {
            type = "checkbox",
            name = BS.LC.Format(_G.BARSTEWARD_PROGRESS_SCREEN),
            getFunc = function()
                return BS.GetVar("Announce", BS.W_ACHIEVEMENT_TRACKER)
            end,
            setFunc = function(value)
                BS.SetVar(value, "Announce", BS.W_ACHIEVEMENT_TRACKER)
            end,
            width = "full"
        },
        [4] = {
            type = "description",
            text = BS.LC.Yellow:Colorize(GetString(_G.BARSTEWARD_TRACKER_INFO)),
            width = "full"
        }
    }
}

BS.widgets[BS.W_GOLDEN_PURSUITS] = {
    -- v3.2.17
    name = "goldenPursuits",
    update = function(widget)
        local campaigns = GetNumActivePromotionalEventCampaigns()
        local completed, max = 0, 0
        local activityData, campaign, milestoneData = {}, {}, {}
        local rewards, claimed = 0, 0
        --BS.HideGoldenPursuitsDefaultUI()

        if (campaigns > 0) then
            local campaignKey = GetActivePromotionalEventCampaignKey(1)
            local campaignData = PROMOTIONAL_EVENT_MANAGER:GetCampaignDataByKey(campaignKey)

            if (campaignData) then
                campaign.name = campaignData:GetDisplayName()
                campaign.isRewardClaimed = campaignData:IsRewardClaimed()
                campaign.canClaimReward = campaignData:CanClaimReward()

                rewards = rewards + (campaign.canClaimReward and 1 or 0)
                claimed = claimed + (campaign.isRewardClaimed and 1 or 0)

                local milestones = campaignData:GetMilestones()

                if (milestones and #milestones > 0) then
                    for _, milestone in pairs(milestones) do
                        local canClaim, hasClaimed = milestone:CanClaimReward(), milestone:IsRewardClaimed()

                        table.insert(
                            milestoneData,
                            {
                                hasReachedMilestone = milestone:HasReachedMilestone(),
                                isRewardClaimed = hasClaimed,
                                canClaimReward = canClaim
                            }
                        )

                        rewards = rewards + (canClaim and 1 or 0)
                        claimed = claimed + (hasClaimed and 1 or 0)
                    end
                end

                local activities = campaignData:GetActivities()

                completed = campaignData:GetNumActivitiesCompleted()
                max = campaignData:GetCapstoneRewardThreshold()

                if (activities and #activities > 0) then
                    for _, activity in pairs(activities) do
                        local canClaim, hasClaimed = activity:CanClaimReward(), activity:IsRewardClaimed()

                        table.insert(
                            activityData,
                            {
                                name = activity:GetDisplayName(),
                                progress = activity:GetProgress(),
                                maxProgress = activity:GetCompletionThreshold(),
                                canClaimReward = canClaim,
                                isRewardClaimed = hasClaimed
                            }
                        )

                        rewards = rewards + (canClaim and 1 or 0)
                        claimed = claimed + (hasClaimed and 1 or 0)
                    end

                    table.sort(
                        activityData,
                        function(a, b)
                            return a.name < b.name
                        end
                    )
                end
            end

            local unclaimedRewards = (rewards > 0) and BS.Icon("mappins/ava_attackburst_32") or ""

            widget:SetValue(completed .. "/" .. max .. unclaimedRewards)
        else
            widget:SetValue(BS.LC.Format(SI_MARKET_SUBSCRIPTION_PAGE_SUBSCRIPTION_STATUS_NOT_ACTIVE))
        end

        widget:SetColour(BS.GetColour(BS.W_GOLDEN_PURSUITS, true))

        local tt = BS.LC.Format(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)

        if (campaign.name) then
            -- tt = tt .. BS.LF
            -- tt = tt .. campaign.name
            tt = tt .. BS.LF .. BS.LF
            if (rewards > 0) then
                tt = tt .. BS.LC.Format(SI_PLAYER_TO_PLAYER_PROMOTIONAL_EVENT_CLAIMABLE_REWARD)
            else
                tt = tt .. ZO_CachedStrFormat(SI_PROMOTIONAL_EVENT_REWARDS_CLAIMED_ANNOUNCEMENT, claimed)
            end
        end

        if (#activityData > 0) then
            tt = tt .. BS.LF .. BS.LF

            for _, activity in pairs(activityData) do
                local n = string.format("%s:", activity.name)
                local c = BS.LC.White

                if (activity.progress > 0) then
                    if (activity.progress < activity.maxProgress) then
                        c = BS.LC.Yellow
                    else
                        c = BS.LC.Green
                    end
                end

                n = c:Colorize(n)
                tt = tt .. string.format("%s %s/%s%s", n, activity.progress, activity.maxProgress, BS.LF)
            end
        end

        widget:SetTooltip(BS.LC.Trim(tt))

        return max
    end,
    hideWhenTrue = function()
        return GetNumActivePromotionalEventCampaigns() == 0
    end,
    callback = {[PROMOTIONAL_EVENT_MANAGER] = {"CampaignsUpdated", "RewardsClaimed"}},
    event = {
        EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED,
        EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED
    },
    icon = "icons/event_confetti_kit",
    tooltip = BS.LC.Format(SI_PROMOTIONAL_EVENT_TRACKER_HEADER),
    onLeftClick = function()
        PROMOTIONAL_EVENT_MANAGER:ShowPromotionalEventScene()
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_GOLDEN_PURSUITS_HIDE_DEFAULT),
            getFunc = function()
                return BS.GetVar("HideDefault", BS.W_GOLDEN_PURSUITS)
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_GOLDEN_PURSUITS].HideDefault = value
                if (value) then
                    BS.HideGoldenPursuitsDefaultUI()
                end
            end,
            width = "full"
        }
    }
}
