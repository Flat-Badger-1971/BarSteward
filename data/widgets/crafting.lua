local BS = _G.BarSteward
local researchSlots = {
    [CRAFTING_TYPE_BLACKSMITHING] = {},
    [CRAFTING_TYPE_WOODWORKING] = {},
    [CRAFTING_TYPE_CLOTHIER] = {},
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {}
}

local fullyUsed = {
    [CRAFTING_TYPE_BLACKSMITHING] = false,
    [CRAFTING_TYPE_WOODWORKING] = false,
    [CRAFTING_TYPE_CLOTHIER] = false,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = false
}

local function clearSlots(craftType)
    for slot, _ in pairs(researchSlots[craftType]) do
        researchSlots[craftType][slot] = 0
    end
end

-- based on code from AI Research Timer
local function getResearchTimer(craftType)
    local maxTimer = 6000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)
    local maxLines = GetNumSmithingResearchLines(craftType)
    local maxR = maxResearch
    local inuse = 0

    clearSlots(craftType)

    for i = 1, maxLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftType, i)

        for j = 1, numTraits do
            local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j)

            if (duration ~= nil and timeRemaining ~= nil) then
                maxResearch = maxResearch - 1
                inuse = inuse + 1
                maxTimer = math.min(maxTimer, timeRemaining)
                researchSlots[craftType][inuse] = timeRemaining
            end
        end
    end

    if (maxResearch > 0) then
        maxTimer = 0
    end

    return maxTimer, maxR, inuse
end

local function getDisplay(timeRemaining, widgetIndex, inUse, maxResearch)
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

    if (inUse ~= nil) then
        display = display .. (BS.GetVar("ShowSlots", widgetIndex) and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
    end

    return display
end

local function getSettings(widgetIndex)
    local settings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_SLOTS),
            getFunc = function()
                return BS.Vars.Controls[widgetIndex].ShowSlots
            end,
            setFunc = function(value)
                BS.Vars.Controls[widgetIndex].ShowSlots = value
                BS.RefreshWidget(widgetIndex)
            end,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_DAYS_ONLY),
            tooltip = GetString(_G.BARSTEWARD_DAYS_ONLY_TOOLTIP),
            getFunc = function()
                return BS.Vars.Controls[widgetIndex].ShowDays
            end,
            setFunc = function(value)
                BS.Vars.Controls[widgetIndex].ShowDays = value
                BS.RefreshWidget(widgetIndex)
            end,
            width = "full"
        }
    }

    return settings
end

local allTypes = {
    CRAFTING_TYPE_BLACKSMITHING,
    CRAFTING_TYPE_CLOTHIER,
    CRAFTING_TYPE_WOODWORKING,
    CRAFTING_TYPE_JEWELRYCRAFTING
}

local craftingIcons = {
    [CRAFTING_TYPE_BLACKSMITHING] = "icons/servicemappins/servicepin_smithy",
    [CRAFTING_TYPE_CLOTHIER] = "icons/servicemappins/servicepin_outfitter",
    [CRAFTING_TYPE_WOODWORKING] = "icons/servicemappins/servicepin_woodworking",
    [CRAFTING_TYPE_JEWELRYCRAFTING] = "icons/icon_jewelrycrafting_symbol"
}

local function getMinType(timers)
    local minType

    for craftingType, timer in pairs(timers) do
        minType = minType or craftingType

        if (timer.timeRemaining < timers[minType].timeRemaining) then
            minType = craftingType
        end
    end

    return minType
end

BS.widgets[BS.W_ALL_CRAFTING] = {
    name = "allCrafting",
    update = function(widget)
        local this = BS.W_ALL_CRAFTING
        local timers = {}
        local text, ttt = "", BS.LC.Format(SI_GAMEPAD_SMITHING_CURRENT_RESEARCH_HEADER) .. BS.LF
        local totalInUse, totalMaxResearch = 0, 0

        for _, craftingType in ipairs(allTypes) do
            local timeRemaining, maxResearch, inUse = getResearchTimer(craftingType)
            local ttColour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

            timers[craftingType] = {timeRemaining = timeRemaining, inUse = inUse, maxResearch = maxResearch}
            totalInUse = totalInUse + inUse
            totalMaxResearch = totalMaxResearch + maxResearch

            local ttext =
                string.format(
                "%s %s",
                BS.Icon(craftingIcons[craftingType]),
                getDisplay(timeRemaining, this, inUse, maxResearch)
            )

            ttt = string.format("%s%s%s", ttt, BS.LF, ttColour:Colorize(ttext))
        end

        local minType = getMinType(timers)
        local timeRemaining = 0

        if (minType) then
            text = getDisplay(timers[minType].timeRemaining, this, totalInUse, totalMaxResearch)
            timeRemaining = timers[minType].timeRemaining
        end

        local colour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

        widget:SetColour(colour)
        widget:SetValue(text)
        widget:SetTooltip(ttt)

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/housing_gen_crf_clothingattunabletable001",
    tooltip = BS.LC.Format(SI_GAMEPAD_SMITHING_CURRENT_RESEARCH_HEADER),
    customSettings = getSettings(BS.W_ALL_CRAFTING)
}

BS.widgets[BS.W_BLACKSMITHING] = {
    name = "blacksmithing",
    update = function(widget)
        local this = BS.W_BLACKSMITHING
        local timeRemaining, maxResearch, inUse = getResearchTimer(CRAFTING_TYPE_BLACKSMITHING)
        local colour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

        fullyUsed[CRAFTING_TYPE_BLACKSMITHING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(colour)
        widget:SetValue(display)

        local ttt = BS.LC.Format(SI_TRADESKILLTYPE1)

        for slot = 1, maxResearch do
            ttt =
                string.format(
                "%s%s%s",
                ttt,
                BS.LF,
                BS.COLOURS.White:Colorize(
                    slot .. " - " .. getDisplay(researchSlots[CRAFTING_TYPE_BLACKSMITHING][slot] or 0, this)
                )
            )
        end

        widget:SetTooltip(ttt)

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_smithy",
    tooltip = BS.LC.Format(SI_TRADESKILLTYPE1),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[CRAFTING_TYPE_BLACKSMITHING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(CRAFTING_TYPE_BLACKSMITHING)
    end,
    customSettings = getSettings(BS.W_BLACKSMITHING)
}

BS.widgets[BS.W_WOODWORKING] = {
    name = "woodworking",
    update = function(widget)
        local this = BS.W_WOODWORKING
        local timeRemaining, maxResearch, inUse = getResearchTimer(CRAFTING_TYPE_WOODWORKING)
        local colour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

        fullyUsed[CRAFTING_TYPE_WOODWORKING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(colour)
        widget:SetValue(display)

        local ttt = BS.LC.Format(SI_TRADESKILLTYPE6)

        for slot = 1, maxResearch do
            ttt =
                string.format(
                "%s%s%s",
                ttt,
                BS.LF,
                BS.COLOURS.White:Colorize(
                    slot .. " - " .. getDisplay(researchSlots[CRAFTING_TYPE_WOODWORKING][slot] or 0, this)
                )
            )
        end

        widget:SetTooltip(ttt)

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_woodworking",
    tooltip = BS.LC.Format(SI_TRADESKILLTYPE6),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[CRAFTING_TYPE_WOODWORKING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(CRAFTING_TYPE_WOODWORKING)
    end,
    customSettings = getSettings(BS.W_WOODWORKING)
}

BS.widgets[BS.W_CLOTHING] = {
    name = "clothing",
    update = function(widget)
        local this = BS.W_CLOTHING
        local timeRemaining, maxResearch, inUse = getResearchTimer(CRAFTING_TYPE_CLOTHIER)
        local colour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

        fullyUsed[CRAFTING_TYPE_CLOTHIER] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(colour)
        widget:SetValue(display)

        local ttt = BS.LC.Format(SI_TRADESKILLTYPE2)

        for slot = 1, maxResearch do
            ttt =
                string.format(
                "%s%s%s",
                ttt,
                BS.LF,
                BS.COLOURS.White:Colorize(
                    slot .. " - " .. getDisplay(researchSlots[CRAFTING_TYPE_CLOTHIER][slot] or 0, this)
                )
            )
        end

        widget:SetTooltip(ttt)

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/servicemappins/servicepin_outfitter",
    tooltip = BS.LC.Format(SI_TRADESKILLTYPE2),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[CRAFTING_TYPE_CLOTHIER]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(CRAFTING_TYPE_CLOTHIER)
    end,
    customSettings = getSettings(BS.W_CLOTHING)
}

BS.widgets[BS.W_JEWELCRAFTING] = {
    name = "jewelcrafting",
    update = function(widget)
        local this = BS.W_JEWELCRAFTING
        local timeRemaining, maxResearch, inUse = getResearchTimer(CRAFTING_TYPE_JEWELRYCRAFTING)
        local colour = BS.GetTimeColour(timeRemaining, this, nil, true, true)

        fullyUsed[CRAFTING_TYPE_JEWELRYCRAFTING] = inUse == maxResearch

        local display = getDisplay(timeRemaining, this, inUse, maxResearch)

        widget:SetColour(colour)
        widget:SetValue(display)

        local ttt = BS.LC.Format(SI_TRADESKILLTYPE7)

        for slot = 1, maxResearch do
            ttt =
                string.format(
                "%s%s%s",
                ttt,
                BS.LF,
                BS.COLOURS.White:Colorize(
                    slot .. " - " .. getDisplay(researchSlots[CRAFTING_TYPE_JEWELRYCRAFTING][slot] or 0, this)
                )
            )
        end

        widget:SetTooltip(ttt)

        return timeRemaining
    end,
    timer = 1000,
    icon = "icons/icon_jewelrycrafting_symbol",
    tooltip = BS.LC.Format(SI_TRADESKILLTYPE7),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[CRAFTING_TYPE_JEWELRYCRAFTING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(CRAFTING_TYPE_JEWELRYCRAFTING)
    end,
    customSettings = getSettings(BS.W_JEWELCRAFTING)
}

local qualifiedQuestNames = {}
local qualifiedCount = 0

local function updateQualifications()
    qualifiedCount = 0

    for craftType, _ in pairs(BS.CRAFTING_DAILY) do
        local achievementData = BS.CRAFTING_ACHIEVEMENT[craftType]
        local _, numCompleted = GetAchievementCriterion(achievementData.achievementId, achievementData.criterionIndex)

        if (numCompleted > 0) then
            qualifiedQuestNames[BS.CRAFTING_DAILY[craftType]] = true
            qualifiedCount = qualifiedCount + 1
        end
    end

    return qualifiedCount
end

BS.EventManager:RegisterForEvent(
    EVENT_ACHIEVEMENT_UPDATED,
    function(_, achievementId)
        if (BS.CRAFTING_ACHIEVEMENT_IDS[achievementId]) then
            updateQualifications()
        end
    end
)

function BS.CountState(state, character, pledges)
    local count = 0

    for _, s in pairs(BS.Vars:GetCommon(pledges and "pledges" or "dailyQuests", character)) do
        if (s == state) then
            count = count + 1
        end
    end

    return count
end

local function checkReset()
    if (BS.Vars) then
        local lastResetTime = BS.GetLastDailyResetTime()

        if (lastResetTime) then
            BS.Vars:SetCommon({}, "dailyQuests")
            BS.Vars:SetCommon(lastResetTime, "lastDailyReset")
        end
    end
end

local function getReadyForHandIn(character)
    local update = false
    local questList = QUEST_JOURNAL_MANAGER:GetQuestListData()

    for _, quest in ipairs(questList) do
        if (quest.questType == QUEST_TYPE_CRAFTING and quest.repeatableType == QUEST_REPEAT_DAILY) then
            local conditionInfo = {}
            local numConditions = GetJournalQuestNumConditions(quest.questIndex)

            QUEST_JOURNAL_MANAGER:BuildTextForConditions(
                quest.questIndex,
                QUEST_MAIN_STEP_INDEX,
                numConditions,
                conditionInfo
            )

            for info = 1, #conditionInfo do
                local conditionText = zo_strformat("<<z:1>>", conditionInfo[info].name)

                if (string.find(conditionText, GetString(_G.BARSTEWARD_DELIVER))) then
                    if (BS.Vars:GetCommon("dailyQuests", character, quest.name) ~= "ready") then
                        BS.Vars:SetCommon("ready", "dailyQuests", character, quest.name)
                        update = true
                        break
                    end
                end
            end
        end
    end

    return update
end

-- check once a minute for daily reset
BS.TimerManager:RegisterForUpdate(60000, checkReset)

BS.widgets[BS.W_CRAFTING_DAILIES] = {
    name = "craftingDailies",
    update = function(widget, event, completeName, addedName, removedName)
        local this = BS.W_CRAFTING_DAILIES
        local update = true
        local added, done, ready
        local character = BS.CHAR.name
        local iconString = "icons/mapkey/mapkey_%s"
        local DAILY_COLOURS = {
            ["done"] = BS.COLOURS.Green,
            ["ready"] = BS.COLOURS.Blue,
            ["added"] = BS.COLOURS.Yellow
        }

        checkReset()

        if (#qualifiedQuestNames == 0) then
            updateQualifications()
        end

        if (BS.Vars:GetCommon("dailyQuests") == nil) then
            BS.Vars:SetCommon({}, "dailyQuests")
        end

        if (BS.Vars:GetCommon("dailyQuests", character) == nil) then
            BS.Vars:SetCommon({}, "dailyQuests", character)
        end

        if (event == EVENT_QUEST_CONDITION_COUNTER_CHANGED) then
            addedName = 1
        end

        completeName = (type(completeName) == "string") and completeName or "null"
        addedName = (type(addedName) == "string") and addedName or "null"
        removedName = (type(removedName) == "string") and removedName or "null"

        if (qualifiedQuestNames[completeName]) then
            BS.Vars:SetCommon("done", "dailyQuests", character, completeName)
        elseif (qualifiedQuestNames[addedName]) then
            BS.Vars:SetCommon("added", "dailyQuests", character, addedName)
        elseif (qualifiedQuestNames[removedName]) then
            -- addedName is actually 'completed' in this case
            if (tostring(addedName) ~= "true") then
                BS.Vars:SetCommon(nil, "dailyQuests", character, removedName)
            end
        else
            update = false
        end

        update = update or getReadyForHandIn(character)

        if (completeName == "null" and addedName == "null" and removedName == "null") then
            -- initial load
            update = true
        end

        added = BS.CountState("added", character)
        done = BS.CountState("done", character)
        ready = BS.CountState("ready", character)

        local colour = BS.COLOURS.DefaultColour

        if (done == qualifiedCount) then
            colour = BS.COLOURS.DefaultOkColour
            BS.Vars:SetCommon(true, "dailyQuests", character, "complete")
        elseif (ready == qualifiedCount) then
            colour = BS.COLOURS.ZOSBlue
        elseif (added == qualifiedCount) then
            colour = BS.COLOURS.DefaultWarningColour
            BS.Vars:SetCommon(true, "dailyQuests", character, "pickedup")
        end

        if (update) then
            local tName
            if (BS.GetVar("UseIcons", this)) then
                local output = ""

                for craftingType, info in pairs(BS.CRAFTING_ACHIEVEMENT) do
                    if (qualifiedQuestNames[BS.CRAFTING_DAILY[craftingType]]) then
                        local cname = BS.CRAFTING_DAILY[craftingType]
                        local cvar = BS.Vars:GetCommon("dailyQuests", character, cname)
                        local ciconName = iconString:format(info.icon)

                        colour = cvar and DAILY_COLOURS[cvar] or BS.COLOURS.Grey

                        tName = BS.Icon(ciconName, colour, 20, 20)
                        output = string.format("%s %s", output, tName)
                    end
                end

                widget:SetValue(output)
            else
                widget:SetValue(added .. "/" .. ready .. "/" .. done .. "/" .. qualifiedCount)
                widget:SetColour(colour)
            end

            local ttt = GetString(_G.BARSTEWARD_DAILY_CRAFTING) .. BS.LF

            for name, _ in pairs(qualifiedQuestNames) do
                local tdone = BS.Vars:GetCommon("dailyQuests", character, name) == "done"
                local tadded = BS.Vars:GetCommon("dailyQuests", character, name) == "added"
                local tready = BS.Vars:GetCommon("dailyQuests", character, name) == "ready"
                local tcolour = BS.COLOURS.DefaultColour
                local ttext

                if (tready) then
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_READY))
                    ttext = BS.COLOURS.Blue:Colorize(ttext)
                    ttt = string.format("%s%s", ttt, ttext)
                elseif (tdone) then
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_COMPLETED))
                    ttext = BS.COLOURS.DefaultOkColour:Colorize(ttext)
                    ttt = string.format("%s%s", ttt, ttext)
                elseif (tadded) then
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_PICKED_UP))
                    ttext = BS.COLOURS.DefaultWarningColour:Colorize(ttext)
                    ttt = string.format("%s%s", ttt, ttext)
                else
                    ttext = string.format("%s - %s", name, GetString(_G.BARSTEWARD_NOT_PICKED_UP))
                    ttext = tcolour:Colorize(ttext)
                    ttt = string.format("%s%s", ttt, ttext)
                end

                ttt = ttt .. BS.LF
            end

            if (BS.Vars:GetCommon("CharacterList")) then
                local ccolour = BS.COLOURS.DefaultColour
                local chars = BS.Vars:GetCommon("CharacterList")

                ttt = ttt .. BS.LF

                for char, _ in pairs(chars) do
                    if (char ~= character) then
                        local charQuests = BS.Vars:GetCommon("dailyQuests", char)

                        if (charQuests) then
                            local dccolour = ccolour

                            if (charQuests.completed) then
                                dccolour = BS.COLOURS.DefaultOkColour
                            elseif (charQuests.pickedup) then
                                dccolour = BS.COLOURS.DefaultWarningColour
                            end

                            ttt = string.format("%s%s%s", ttt, BS.LF, dccolour:Colorize(char))
                        else
                            ttt = string.format("%s%s%s", ttt, BS.LF, ccolour:Colorize(char))
                        end
                    end
                end
            end

            widget:SetTooltip(ttt)
        end

        return done == qualifiedCount
    end,
    event = {
        EVENT_QUEST_ADDED,
        EVENT_QUEST_REMOVED,
        EVENT_QUEST_COMPLETE,
        EVENT_QUEST_CONDITION_COUNTER_CHANGED
    },
    icon = "icons/quest_wrothgar_item_029",
    tooltip = GetString(_G.BARSTEWARD_DAILY_CRAFTING),
    hideWhenEqual = true,
    customSettings = {
        [1] = {
            name = GetString(_G.BARSTEWARD_USE_ICONS),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_CRAFTING_DAILIES].UseIcons
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_CRAFTING_DAILIES].UseIcons = value
                BS.RefreshWidget(BS.W_CRAFTING_DAILIES)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_CRAFTING_DAILY_TIME] = {
    -- v1.3.11
    -- same time as any other daily activity
    name = "craftingDailyTime",
    update = function(widget)
        return BS.GetTimedActivityTimeRemaining(TIMED_ACTIVITY_TYPE_DAILY, BS.W_CRAFTING_DAILY_TIME, widget)
    end,
    timer = 1000,
    icon = "icons/crafting_outfitter_logo",
    tooltip = GetString(_G.BARSTEWARD_DAILY_WRITS_TIME)
}

local function getRecipeList()
    BS.recipeList = {
        food = {known = 0, unknown = 0.},
        drink = {known = 0, unknown = 0},
        furnishing = {known = 0, unknown = 0}
    }

    BS.unknownRecipeLinks = {[ITEMTYPE_FOOD] = {}, [ITEMTYPE_DRINK] = {}, [ITEMTYPE_FURNISHING] = {}}

    for recipeListIndex = 1, GetNumRecipeLists() do
        local name, numRecipes = GetRecipeListInfo(recipeListIndex)

        for recipeIndex = 1, numRecipes do
            local known, _, _, _, _, _, _, resultItemId = GetRecipeInfo(recipeListIndex, recipeIndex)

            if (not BS.IGNORE_RECIPE[resultItemId]) then
                local link = BS.LC.MakeItemLink(resultItemId)
                local itemType, sit = GetItemLinkItemType(link)

                if (itemType + sit ~= 0) then
                    if (itemType == ITEMTYPE_FOOD) then
                        if (known == true) then
                            BS.recipeList.food.known = BS.recipeList.food.known + 1
                        else
                            BS.recipeList.food.unknown = BS.recipeList.food.unknown + 1
                            table.insert(BS.unknownRecipeLinks[ITEMTYPE_FOOD], link)
                        end
                    elseif (itemType == ITEMTYPE_DRINK) then
                        if (known == true) then
                            BS.recipeList.drink.known = BS.recipeList.drink.known + 1
                        else
                            BS.recipeList.drink.unknown = BS.recipeList.drink.unknown + 1
                            table.insert(BS.unknownRecipeLinks[ITEMTYPE_DRINK], link)
                        end
                    elseif (itemType == ITEMTYPE_FURNISHING) then
                        if (name ~= "") then
                            if (known) then
                                BS.recipeList.furnishing.known = BS.recipeList.furnishing.known + 1
                            else
                                BS.recipeList.furnishing.unknown = BS.recipeList.furnishing.unknown + 1
                                table.insert(BS.unknownRecipeLinks[ITEMTYPE_FURNISHING], link)
                            end
                        end
                    end
                end
            end
        end
    end
end

local food = BS.LC.Format(SI_ITEMTYPE4)
local drink = BS.LC.Format(SI_ITEMTYPE12)
local foodAndDrink = food .. " + " .. drink
local furnishing = BS.LC.Format(SI_ITEMTYPE61)
local recipes = BS.LC.Format(SI_ITEMTYPEDISPLAYCATEGORY21)

BS.widgets[BS.W_RECIPES] = {
    -- v1.4.6
    name = "recipes",
    update = function(widget, event)
        if ((BS.recipeList == nil) or (event ~= EVENT_PLAYER_ACTIVATED)) then
            getRecipeList()
        end

        local allFood = BS.recipeList.food.known + BS.recipeList.food.unknown
        local allDrink = BS.recipeList.drink.known + BS.recipeList.drink.unknown
        local allFoodAndDrink = allFood + allDrink
        local allFurnishing = BS.recipeList.furnishing.known + BS.recipeList.furnishing.unknown
        local tt = recipes
        local this = BS.W_RECIPES
        local white, gold = BS.COLOURS.White, BS.COLOURS.ZOSGold

        tt = tt .. BS.LF .. gold:Colorize(BS.recipeList.food.known .. "/" .. allFood)
        tt = tt .. white:Colorize(" " .. food) .. BS.LF
        tt = tt .. gold:Colorize(BS.recipeList.drink.known .. "/" .. allDrink)
        tt = tt .. white:Colorize(" " .. drink) .. BS.LF
        tt = tt .. gold:Colorize((BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink)
        tt = tt .. white:Colorize(" " .. foodAndDrink) .. BS.LF
        tt = tt .. gold:Colorize(BS.recipeList.furnishing.known .. "/" .. allFurnishing)
        tt = tt .. white:Colorize(" " .. furnishing)

        local value = BS.recipeList.food.known .. "/" .. allFood
        local colour = BS.GetColour(this, true)
        local display = BS.GetVar("Display", this)

        if (display == drink) then
            value = BS.recipeList.drink.known .. "/" .. allDrink
        elseif (display == foodAndDrink) then
            value = (BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink
        elseif (display == furnishing) then
            value = BS.recipeList.furnishing.known .. "/" .. allFurnishing
        end

        widget:SetValue(value)
        widget:SetColour(colour)
        widget:SetTooltip(tt)

        return widget:GetValue()
    end,
    event = {EVENT_PLAYER_ACTIVATED, EVENT_RECIPE_LEARNED, EVENT_MULTIPLE_RECIPES_LEARNED},
    icon = "tradinghouse/tradinghouse_trophy_recipe_fragment_up",
    tooltip = recipes,
    onLeftClick = function()
        local vars = BS.Vars.Controls[BS.W_RECIPES]
        local display = BS.unknownRecipeLinks[ITEMTYPE_FOOD]

        if (vars.Display == drink) then
            display = BS.unknownRecipeLinks[ITEMTYPE_DRINK]
        elseif (vars.Display == foodAndDrink) then
            display = BS.LC.MergeTables(display, BS.unknownRecipeLinks[ITEMTYPE_DRINK])
        elseif (vars.Display == furnishing) then
            display = BS.unknownRecipeLinks[ITEMTYPE_FURNISHING]
        end

        for _, link in ipairs(display) do
            -- chat router insists on having the name, even though the link works in game
            local itemName = GetItemLinkName(link)
            local itemId = GetItemLinkItemId(link)
            local newLink = BS.LC.MakeItemLink(itemId, itemName)

            CHAT_ROUTER:AddSystemMessage(newLink)
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_RECIPES_DISPLAY),
        choices = {food, drink, foodAndDrink, furnishing},
        varName = "Display",
        refresh = true,
        default = food
    }
}

BS.widgets[BS.W_UNKNOWN_WRIT_MOTIFS] = {
    -- v1.4.30
    name = "unknownWritMotifs",
    update = function(widget, event)
        local this = BS.W_UNKNOWN_WRIT_MOTIFS

        if (event == "initial") then
            widget:SetColour(BS.GetColour(this, true))
            return
        end

        local writs = 0
        local bags = {BAG_BACKPACK, BAG_BANK}
        local unknown = {}

        if (IsESOPlusSubscriber()) then
            table.insert(bags, BAG_SUBSCRIBER_BANK)
        end

        for _, bag in pairs(bags) do
            for _, data in pairs(_G.SHARED_INVENTORY.bagCache[bag]) do
                if (data.specializedItemType == SPECIALIZED_ITEMTYPE_MASTER_WRIT) then
                    writs = writs + 1
                    local itemLink = GetItemLink(bag, data.slotIndex)
                    local writData = BS.ToWritFields(itemLink)

                    -- only interested in crafting types that use motifs
                    if
                        (writData.writType == CRAFTING_TYPE_BLACKSMITHING or writData.writType == CRAFTING_TYPE_CLOTHIER or
                            writData.writType == CRAFTING_TYPE_WOODWORKING)
                     then
                        local knowsMotif =
                            BS.LibCK.GetMotifKnowledgeForCharacter(
                            tonumber(writData.motifNumber),
                            tonumber(writData.itemType)
                        )

                        if (knowsMotif ~= BS.LibCK.KNOWLEDGE_KNOWN) then
                            local styleName = GetItemStyleName(writData.motifNumber)
                            local chapterName = GetString("SI_ITEMSTYLECHAPTER", writData.itemType)
                            local motifName = zo_strformat("<<C:1>> <<m:2>>", styleName, chapterName)
                            local colour = GetItemQualityColor(writData.itemQuality)
                            local name = colour:Colorize(motifName)
                            local motifInfo = _G.LibCharacterKnowledgeInternal.GetStyleMotifItems(writData.motifNumber)

                            if (motifInfo) then
                                name = (motifInfo.number) .. ". " .. name
                            else
                                name = "**. " .. name
                            end

                            unknown[name] = true
                        end
                    end
                end
            end
        end

        local display = {}

        for motif, _ in pairs(unknown) do
            table.insert(display, motif)
        end

        table.sort(display)

        widget:SetColour(BS.GetColour(this, true))
        widget:SetValue(tostring(#display))
        widget:ForceResize()
        BS.ResizeBar(BS.GetVar("Bar", this))

        if (#display > 0) then
            local tt = GetString(_G.BARSTEWARD_UNKNOWN_WRIT_MOTIFS)

            for _, motif in ipairs(display) do
                tt = string.format("%s%s%s", tt, BS.LF, motif)
            end

            widget:SetTooltip(tt)
        end

        return widget:GetValue()
    end,
    event = {EVENT_LORE_BOOK_LEARNED},
    callbackLCK = true,
    callback = {[SHARED_INVENTORY] = {"SingleSlotInventoryUpdate"}},
    icon = "icons/crafting_motif_binding_welkynar",
    tooltip = GetString(_G.BARSTEWARD_UNKNOWN_WRIT_MOTIFS)
}
