local BS = _G.BarSteward

local function configureWidget(widget, complete, maxComplete, activityType, tasks)
    widget:SetValue(complete .. "/" .. maxComplete)
    widget:SetColour(
        unpack(
            BS.Vars.Controls[
                activityType == _G.TIMED_ACTIVITY_TYPE_DAILY and BS.W_DAILY_ENDEAVOURS or BS.W_WEEKLY_ENDEAVOURS
            ].Colour or BS.Vars.DefaultColour
        )
    )

    if (#tasks > 0) then
        local tooltipText = ""

        for _, t in ipairs(tasks) do
            if (tooltipText ~= "") then
                tooltipText = tooltipText .. BS.LF
            end

            tooltipText = tooltipText .. t
        end

        widget.tooltip = tooltipText
    end
end

local function getTimedActivityProgress(activityType, widget)
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
            local pcProgress = max / progress
            local ttext = name .. "  (" .. progress .. "/" .. max .. ")"
            local colour = "|cb4b4b4"

            if (progress > 0 and progress < max and complete ~= maxComplete) then
                colour = "|cffff00"
            elseif (complete == maxComplete and max ~= progress) then
                colour = "|cb4b4b4"
            elseif (max == progress) then
                complete = complete + 1
                colour = "|c00ff00"
            end

            -- get reward info
            local numRewards = GetNumTimedActivityRewards(idx)
            local reward = ""

            for rewardIndex = 1, numRewards do
                local rewardId, quantity = GetTimedActivityRewardInfo(idx, rewardIndex)
                local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, quantity)

                if (reward ~= "") then
                    reward = reward .. ", "
                end

                reward = reward .. zo_iconFormat(rewardData.lootIcon or rewardData.icon, 16, 16) .. quantity
            end

            ttext = colour .. ttext .. "|r" .. " " .. reward

            table.insert(tasks, ttext)

            if (pcProgress > maxPcProgress) then
                maxTask = {
                    name = name,
                    description = GetTimedActivityDescription(idx),
                    progress = progress,
                    maxProgress = max
                }
            end
        end
    end

    if (widget ~= nil) then
        configureWidget(widget, complete, maxComplete, activityType, tasks)
    end

    return complete, maxTask
end

BS.widgets[BS.W_DAILY_ENDEAVOURS] = {
    -- v1.0.1
    name = "dailyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_DAILY, widget)
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "/esoui/art/journal/u26_progress_digsite_checked_incomplete.dds",
    tooltip = GetString(_G.BARSTEWARD_DAILY_ENDEAVOUR_PROGRESS),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end
}

BS.widgets[BS.W_WEEKLY_ENDEAVOURS] = {
    -- v1.0.1
    name = "weeklyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, widget)
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "/esoui/art/journal/u26_progress_digsite_checked_complete.dds",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end
}

BS.widgets[BS.W_ENDEAVOUR_PROGRESS] = {
    -- v1.2.14
    name = "weeklyEndeavourBar",
    update = function(widget)
        local _, maxTask = getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, nil)

        widget:SetProgress(maxTask.progress, 0, maxTask.maxProgress)

        local ttt = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST) .. BS.LF
        ttt = ttt .. "|cf6f6f6"
        ttt = ttt .. maxTask.name ..BS.LF .. BS.LF
        ttt = ttt .. maxTask.description

        widget.tooltip = ttt

        return maxTask.progress == maxTask.maxProgress
    end,
    progress = true,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "/esoui/art/journal/u26_progress_digsite_marked_complete.dds",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS_BEST),
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            GROUP_MENU_KEYBOARD:ShowCategory(_G.TIMED_ACTIVITIES_FRAGMENT)
        else
            ZO_ACTIVITY_FINDER_ROOT_GAMEPAD:ShowCategory(TIMED_ACTIVITIES_GAMEPAD:GetCategoryData())
        end
    end
}

local difficultyColours = {
    [_G.ANTIQUITY_DIFFICULTY_TRIVIAL] = "e6e6e6",
    [_G.ANTIQUITY_DIFFICULTY_SIMPLE] = "2dc50e",
    [_G.ANTIQUITY_DIFFICULTY_INTERMEDIATE] = "3a92ff",
    [_G.ANTIQUITY_DIFFICULTY_ADVANCED] = "a02ef7",
    [_G.ANTIQUITY_DIFFICULTY_MASTER] = "ccaa1a",
    [_G.ANTIQUITY_DIFFICULTY_ULTIMATE] = "e58b27"
}

local function getLeadColour(lead)
    if ((lead.quality or 0) == 0) then
        return BS.ARGBConvert(BS.Vars.Controls[BS.W_LEADS].Colour or BS.Vars.DefaultColour)
    end

    return "|c" .. difficultyColours[lead.quality]
end

BS.widgets[BS.W_LEADS] = {
    -- v1.1.0
    name = "leads",
    update = function(widget)
        local antiquityId = GetNextAntiquityId()
        local minTime = 99999999
        local leads = {}

        while antiquityId do
            if (DoesAntiquityHaveLead(antiquityId)) then
                local lead = {
                    name = ZO_CachedStrFormat("<<C:1>>", GetAntiquityName(antiquityId)),
                    remaining = GetAntiquityLeadTimeRemainingSeconds(antiquityId),
                    quality = GetAntiquityQuality(antiquityId),
                    zone = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(GetAntiquityZoneId(antiquityId))),
                    id = antiquityId
                }

                table.insert(leads, lead)

                if (lead.remaining < minTime) then
                    minTime = lead.remaining
                end
            end

            antiquityId = GetNextAntiquityId(antiquityId)
        end

        if (#leads > 0) then
            local timeColour = BS.Vars.DefaultOkColour

            if (minTime <= (BS.Vars.Controls[BS.W_LEADS].DangerValue) * 3600) then
                timeColour = BS.Vars.Controls[BS.W_LEADS].DangerColour or BS.Vars.DefaultDangerColour
            elseif (minTime <= (BS.Vars.Controls[BS.W_LEADS].WarningValue * 3600)) then
                timeColour = BS.Vars.Controls[BS.W_LEADS].WarningColour or BS.Vars.DefaultWarningColour
            end

            widget:SetColour(unpack(timeColour))
            widget:SetValue(BS.SecondsToTime(minTime, false, false, true, BS.Vars.Controls[BS.W_LEADS].Format))

            local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS))

            for _, lead in ipairs(leads) do
                local nameAndZone = lead.name .. " - " .. lead.zone
                local time = BS.SecondsToTime(lead.remaining, false, false, true, BS.Vars.Controls[BS.W_LEADS].Format)
                local ttlColour = getLeadColour(lead)

                timeColour = BS.Vars.DefaultOkColour

                if (lead.remaining <= (BS.Vars.Controls[BS.W_LEADS].DangerValue * 3600)) then
                    timeColour = BS.Vars.Controls[BS.W_LEADS].DangerColour or BS.Vars.DefaultDangerColour
                elseif (lead.remaining <= (BS.Vars.Controls[BS.W_LEADS].WarningValue * 3600)) then
                    timeColour = BS.Vars.Controls[BS.W_LEADS].WarningColour or BS.Vars.DefaultWarningColour
                end

                ttt = ttt .. BS.LF .. ttlColour .. nameAndZone .. " - |r" .. BS.ARGBConvert(timeColour) .. time .. "|r"
            end

            widget.tooltip = ttt
        end

        return minTime
    end,
    timer = 1000,
    icon = GetAntiquityLeadIcon(),
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS)),
    hideWhenEqual = 99999999
}
