local BS = _G.BarSteward

local function getTimedActivityProgress(activityType, widget)
    local complete = 0
    local maxComplete = GetTimedActivityTypeLimit(activityType)
    local tasks = {}

    for idx = 1, 30 do
        local name = GetTimedActivityName(idx)

        if (name == "") then
            break
        end

        if (GetTimedActivityType(idx) == activityType) then
            local max = GetTimedActivityMaxProgress(idx)
            local progress = GetTimedActivityProgress(idx)
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

            ttext = colour .. ttext .. "|r"

            table.insert(tasks, ttext)
        end
    end

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

    return complete
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
            SCENE_MANAGER:Show("groupMenuKeyboard")
        else
            SCENE_MANAGER:Show("gamepad_groupList")
        end
    end
}

BS.widgets[BS.W_WEEKLY_ENDEAVOURS] = {
    -- v1.0.1
    name = "weekyEndeavourProgress",
    update = function(widget)
        return getTimedActivityProgress(_G.TIMED_ACTIVITY_TYPE_WEEKLY, widget)
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED},
    icon = "/esoui/art/journal/u26_progress_digsite_checked_complete.dds",
    tooltip = GetString(_G.BARSTEWARD_WEEKLY_ENDEAVOUR_PROGRESS),
    onClick = function()
        SCENE_MANAGER:Show("groupMenuKeyboard")
    end
}

local qualityColours = {
    [1] = "2dc50e",
    [2] = "3a92ff",
    [3] = "a02ef7",
    [4] = "ccaa1a",
    [5] = "e58b27"
}

local function getLeadColour(lead)
    if ((lead.difficulty or 0) == 0) then
        return BS.ARGBConvert(BS.Vars.Controls[BS.W_LEADS].Colour or BS.Vars.DefaultColour)
    end

    local quality = lead.difficulty > 5 and lead.quality or lead.difficulty

    return "|c" .. qualityColours[quality]
end

BS.widgets[BS.W_LEADS] = {
    -- v1.1.0
    name = "leads",
    update = function(widget)
        local antiquityId = GetNextAntiquityId()
        local minTime = 99999999
        local minLeadId = 0
        local leads = {}

        while antiquityId do
            if (DoesAntiquityHaveLead(antiquityId)) then
                local lead = {
                    name = ZO_CachedStrFormat("<<C:1>>", GetAntiquityName(antiquityId)),
                    remaining = GetAntiquityLeadTimeRemainingSeconds(antiquityId),
                    quality = GetAntiquityQuality(antiquityId),
                    difficulty = GetAntiquityDifficulty(antiquityId),
                    zone = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(GetAntiquityZoneId(antiquityId))),
                    id = antiquityId
                }

                table.insert(leads, lead)

                if (lead.remaining < minTime) then
                    minTime = lead.remaining
                    minLeadId = lead.id
                end
            end

            antiquityId = GetNextAntiquityId(antiquityId)
        end

        if (#leads > 0) then
            local colour = BS.Vars.Controls[BS.W_LEADS].Colour or BS.Vars.DefaultColour

            if (minTime <= BS.Vars.Controls[BS.W_LEADS].DangerValue) then
                colour = BS.Vars.Controls[BS.W_LEADS].DangerColour or BS.Vars.DefaultDangerColour
            end

            widget:SetColour(unpack(colour))
            widget:SetValue(BS.SecondsToTime(minTime, false, false, true))

            local ttt = GetString(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS) .. BS.LF

            for _, lead in ipairs(leads) do
                local nameAndZone = lead.name .. " - " .. lead.zone
                local time = BS.SecondsToTime(lead.remaining, false, false, true)
                local ttlColour = getLeadColour(lead)

                if (lead.id == minLeadId) then
                    if (minTime <= BS.Vars.Controls[BS.W_LEADS].DangerValue) then
                        ttlColour = BS.ARGBConvert(BS.Vars.DefaultDangerColour)
                    end
                end

                ttt = ttt .. ttlColour .. nameAndZone .. " - " .. time .. BS.LF .. "|r"
            end

            widget.tooltip = ttt
        end

        return minTime
    end,
    timer = 1000,
    icon = GetAntiquityLeadIcon(),
    tooltip = GetString(_G.SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS),
    hideWhenEqual = 99999999
}
