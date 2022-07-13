local BS = _G.BarSteward
local researchTimersActive = {
    [_G.CRAFTING_TYPE_BLACKSMITHING] = true,
    [_G.CRAFTING_TYPE_WOODWORKING] = true,
    [_G.CRAFTING_TYPE_CLOTHIER] = true,
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = true
}

-- based on code from AI Research Timer
local function getResearchTimer(craftType)
    local maxTimer = 2000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)

    if (researchTimersActive[craftType]) then
        local maxLines = GetNumSmithingResearchLines(craftType)
        local maxR = maxResearch
        local inuse = 0

        for i = 1, maxLines do
            local _, _, numTraits = GetSmithingResearchLineInfo(craftType, i)

            for j = 1, numTraits do
                local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j)

                if (duration ~= nil and timeRemaining ~= nil) then
                    maxResearch = maxResearch - 1
                    inuse = inuse + 1
                    maxTimer = math.min(maxTimer, timeRemaining)
                end
            end
        end

        if (maxResearch > 0) then
            maxTimer = 0
        end

        if (maxTimer == 0) then
            researchTimersActive[craftType] = false
        end

        return maxTimer, maxR, inuse
    else
        return 0, maxResearch, 0
    end
end

-- only run the research queries when necessary
EVENT_MANAGER:RegisterForEvent(
    BS.Name,
    _G.EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
    function(_, craftType)
        researchTimersActive[craftType] = true
    end
)

EVENT_MANAGER:RegisterForEvent(
    BS.Name,
    _G.EVENT_SMITHING_TRAIT_RESEARCH_CANCELED,
    function(_, craftType)
        researchTimersActive[craftType] = false
    end
)

EVENT_MANAGER:RegisterForEvent(
    BS.Name,
    _G.EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
    function(_, craftType)
        researchTimersActive[craftType] = false
    end
)

BS.widgets[BS.W_BLACKSMITHING] = {
    name = "blacksmithing",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)
        local colour = BS.Vars.Controls[BS.W_BLACKSMITHING].OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (BS.Vars.Controls[BS.W_BLACKSMITHING].DangerValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_BLACKSMITHING].DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (BS.Vars.Controls[BS.W_BLACKSMITHING].WarningValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_BLACKSMITHING].WarningColour or BS.Vars.DefaultWarningColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(
            BS.SecondsToTime(
                timeRemaining,
                false,
                false,
                BS.Vars.Controls[BS.W_BLACKSMITHING].HideSeconds,
                BS.Vars.Controls[BS.W_BLACKSMITHING].Format
            ) .. (BS.Vars.Controls[BS.W_BLACKSMITHING].ShowSlots and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
        )
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_smithy.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE1)),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_BLACKSMITHING)
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_BLACKSMITHING].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_BLACKSMITHING].ShowSlots = value
                BS.widgets[BS.W_BLACKSMITHING].update(
                    _G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_BLACKSMITHING].name].ref
                )
            end,
            width = "full"
        }
    }
}

BS.widgets[BS.W_WOODWORKING] = {
    name = "woodworking",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_WOODWORKING)
        local colour = BS.Vars.Controls[BS.W_WOODWORKING].OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (BS.Vars.Controls[BS.W_WOODWORKING].DangerValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_WOODWORKING].DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (BS.Vars.Controls[BS.W_WOODWORKING].WarningValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_WOODWORKING].WarningColour or BS.Vars.DefaultWarningColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(
            BS.SecondsToTime(
                timeRemaining,
                false,
                false,
                BS.Vars.Controls[BS.W_WOODWORKING].HideSeconds,
                BS.Vars.Controls[BS.W_WOODWORKING].Format
            ) .. (BS.Vars.Controls[BS.W_WOODWORKING].ShowSlots and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
        )
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE6)),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_WOODWORKING)
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_WOODWORKING].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_WOODWORKING].ShowSlots = value
                BS.widgets[BS.W_WOODWORKING].update(_G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_WOODWORKING].name].ref)
            end,
            width = "full"
        }
    }
}

BS.widgets[BS.W_CLOTHING] = {
    name = "clothing",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_CLOTHIER)
        local colour = BS.Vars.Controls[BS.W_CLOTHING].OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (BS.Vars.Controls[BS.W_CLOTHING].DangerValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_CLOTHING].DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (BS.Vars.Controls[BS.W_CLOTHING].WarningValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_CLOTHING].WarningColour or BS.Vars.DefaultWarningColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(
            BS.SecondsToTime(
                timeRemaining,
                false,
                false,
                BS.Vars.Controls[BS.W_CLOTHING].HideSeconds,
                BS.Vars.Controls[BS.W_CLOTHING].Format
            ) .. (BS.Vars.Controls[BS.W_CLOTHING].ShowSlots and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
        )
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_outfitter.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE2)),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_CLOTHIER)
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_CLOTHING].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CLOTHING].ShowSlots = value
                BS.widgets[BS.W_CLOTHING].update(_G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_CLOTHING].name].ref)
            end,
            width = "full"
        }
    }
}

BS.widgets[BS.W_JEWELCRAFTING] = {
    name = "jewelcrafting",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
        local colour = BS.Vars.Controls[BS.W_JEWELCRAFTING].OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (BS.Vars.Controls[BS.W_JEWELCRAFTING].DangerValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_JEWELCRAFTING].DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (BS.Vars.Controls[BS.W_JEWELCRAFTING].WarningValue * 3600)) then
            colour = BS.Vars.Controls[BS.W_JEWELCRAFTING].WarningColour or BS.Vars.DefaultWarningColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(
            BS.SecondsToTime(
                timeRemaining,
                false,
                false,
                BS.Vars.Controls[BS.W_JEWELCRAFTING].HideSeconds,
                BS.Vars.Controls[BS.W_JEWELCRAFTING].Format
            ) .. (BS.Vars.Controls[BS.W_JEWELCRAFTING].ShowSlots and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
        )
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/icon_jewelrycrafting_symbol.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE7)),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
    end,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_JEWELCRAFTING].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_JEWELCRAFTING].ShowSlots = value
                BS.widgets[BS.W_JEWELCRAFTING].update(
                    _G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_JEWELCRAFTING].name].ref
                )
            end,
            width = "full"
        }
    }
}

local qualifiedQuestNames = {}
local qualifiedCount = 0

local function updateQualifications()
    local qualifications = {}
    qualifiedCount = 0

    for craftType, _ in pairs(BS.CRAFTING_DAILY) do
        local achievementData = BS.CRAFTING_ACHIEVEMENT[craftType]
        local _, numCompleted = GetAchievementCriterion(achievementData.achievementId, achievementData.criterionIndex)

        if (numCompleted > 0) then
            qualifiedQuestNames[BS.CRAFTING_DAILY[craftType]] = true
            qualifiedCount = qualifiedCount + 1
        end
    end

    return qualifications
end

BS.RegisterForEvent(
    _G.EVENT_ACHIEVEMENT_UPDATED,
    function(_, achievementId)
        if (BS.CRAFTING_ACHIEVEMENT_IDS[achievementId]) then
            updateQualifications()
        end
    end
)

local function countState(state, character)
    local count = 0

    for _, s in pairs(BS.Vars.dailyQuests[character]) do
        if (s == state) then
            count = count + 1
        end
    end

    return count
end

local function checkReset()
    local timeRemaining =
        TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(_G.TIMED_ACTIVITY_TYPE_DAILY)
    local secondsInADay = 86400
    local lastResetTime = os.time() - (secondsInADay - timeRemaining)

    BS.Vars.lastDailyReset = BS.Vars.lastDailyReset or lastResetTime

    if ((BS.Vars.lastDailyReset + secondsInADay) < os.time()) then
        BS.Vars.dailyQuests = {}
        BS.Vars.lastDailyReset = lastResetTime
    end
end

-- check once a minute for daily reset
BS.RegisterForUpdate(60000, checkReset)

BS.widgets[BS.W_CRAFTING_DAILIES] = {
    name = "craftingDailies",
    update = function(widget, _, completeName, addedName, removedName)
        local update = true
        local added, done
        local character = GetUnitName("player")

        checkReset()

        if (#qualifiedQuestNames == 0) then
            updateQualifications()
        end

        BS.Vars.dailyQuests = BS.Vars.dailyQuests or {}
        BS.Vars.dailyQuests[character] = BS.Vars.dailyQuests[character] or {}

        completeName = (type(completeName) == "string") and completeName or "null"
        addedName = (type(addedName) == "string") and addedName or "null"
        removedName = (type(removedName) == "string") and removedName or "null"

        if (qualifiedQuestNames[completeName]) then
            BS.Vars.dailyQuests[character][completeName] = "done"
        elseif (qualifiedQuestNames[addedName]) then
            BS.Vars.dailyQuests[character][addedName] = "added"
        elseif (qualifiedQuestNames[removedName]) then
            -- addedName is actually 'completed' in this case
            if (tostring(addedName) ~= "true") then
                BS.Vars.dailyQuests[character][removedName] = nil
            end
        else
            update = false
        end

        if (completeName == "null" and addedName == "null" and removedName == "null") then
            -- initial load
            update = true
        end

        if (update) then
            added = countState("added", character)
            done = countState("done", character)

            local colour = BS.Vars.DefaultColour

            if (done == qualifiedCount) then
                colour = BS.Vars.DefaultOkColour
                BS.Vars.dailyQuests[character].complete = true
            end

            widget:SetValue(added .. "/" .. done .. "/" .. qualifiedCount)
            widget:SetColour(unpack(colour))

            local ttt = GetString(_G.BARSTEWARD_DAILY_CRAFTING) .. BS.LF

            for name, _ in pairs(qualifiedQuestNames) do
                local tdone = BS.Vars.dailyQuests[character][name] == "done"
                local tadded = BS.Vars.dailyQuests[character][name] == "added"
                local tcolour = BS.ARGBConvert(BS.Vars.DefaultColour)

                if (tdone) then
                    ttt =
                        ttt ..
                        BS.LF ..
                            BS.ARGBConvert(BS.Vars.DefaultOkColour) ..
                                name .. " - " .. GetString(_G.BARSTEWARD_COMPLETED) .. "|r"
                elseif (tadded) then
                    ttt =
                        ttt ..
                        BS.LF ..
                            BS.ARGBConvert(BS.Vars.DefaultWarningColour) ..
                                name .. " - " .. GetString(_G.BARSTEWARD_PICKED_UP) .. "|r"
                else
                    ttt = ttt .. BS.LF .. tcolour .. name .. " - " .. GetString(_G.BARSTEWARD_NOT_PICKED_UP) .. "|r"
                end
            end

            if (BS.Vars.CharacterList) then
                local ccolour = BS.ARGBConvert(BS.Vars.DefaultColour)
                local chars = BS.Vars.CharacterList

                ttt = ttt .. BS.LF

                for char, _ in pairs(chars) do
                    if (char ~= character) then
                        if (BS.Vars.dailyQuests[char]) then
                            ttt =
                                ttt ..
                                BS.LF ..
                                    (BS.Vars.dailyQuests[char].complete and BS.ARGBConvert(BS.Vars.DefaultOkColour) or
                                        ccolour) ..
                                        char .. "|r"
                        else
                            ttt = ttt .. BS.LF .. ccolour .. char .. "|r"
                        end
                    end
                end
            end

            widget.tooltip = ttt
        end

        return done
    end,
    event = {_G.EVENT_QUEST_ADDED, _G.EVENT_QUEST_REMOVED, _G.EVENT_QUEST_COMPLETE},
    icon = "/esoui/art/floatingmarkers/repeatablequest_available_icon.dds",
    tooltip = GetString(_G.BARSTEWARD_DAILY_CRAFTING)
}
