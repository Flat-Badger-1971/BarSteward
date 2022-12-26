local BS = _G.BarSteward
local researchSlots = {
    [_G.CRAFTING_TYPE_BLACKSMITHING] = {},
    [_G.CRAFTING_TYPE_WOODWORKING] = {},
    [_G.CRAFTING_TYPE_CLOTHIER] = {},
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = {}
}

local fullyUsed = {
    [_G.CRAFTING_TYPE_BLACKSMITHING] = false,
    [_G.CRAFTING_TYPE_WOODWORKING] = false,
    [_G.CRAFTING_TYPE_CLOTHIER] = false,
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = false
}

local function clearSlots(craftType)
    for slot, _ in pairs(researchSlots[craftType]) do
        researchSlots[craftType][slot] = 0
    end
end

-- based on code from AI Research Timer
local function getResearchTimer(craftType)
    local maxTimer = 2000000
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

    if (BS.Vars.Controls[widgetIndex].ShowDays and days >= 1 and hours > 24) then
        display = zo_strformat(GetString(_G.BARSTEWARD_DAYS), days)
    else
        display =
            BS.SecondsToTime(
            timeRemaining,
            false,
            false,
            BS.Vars.Controls[widgetIndex].HideSeconds,
            BS.Vars.Controls[widgetIndex].Format,
            BS.Vars.Controls[widgetIndex].HideDaysWhenZero
        )
    end

    if (inUse ~= nil) then
        display =
            display .. (BS.Vars.Controls[widgetIndex].ShowSlots and " (" .. inUse .. "/" .. maxResearch .. ")" or "")
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

BS.widgets[BS.W_BLACKSMITHING] = {
    name = "blacksmithing",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)
        local vars = BS.Vars.Controls[BS.W_BLACKSMITHING]
        local colour = vars.OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (vars.DangerValue * 3600)) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (vars.WarningValue * 3600)) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        end

        fullyUsed[_G.CRAFTING_TYPE_BLACKSMITHING] = inUse == maxResearch
        local display = getDisplay(timeRemaining, BS.W_BLACKSMITHING, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE1))

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_BLACKSMITHING][slot] or 0, BS.W_BLACKSMITHING)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_smithy.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE1)),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_BLACKSMITHING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_BLACKSMITHING)
    end,
    customSettings = getSettings(BS.W_BLACKSMITHING)
}

BS.widgets[BS.W_WOODWORKING] = {
    name = "woodworking",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_WOODWORKING)
        local vars = BS.Vars.Controls[BS.W_WOODWORKING]
        local colour = vars.OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (vars.DangerValue * 3600)) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (vars.WarningValue * 3600)) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        end

        fullyUsed[_G.CRAFTING_TYPE_WOODWORKING] = inUse == maxResearch
        local display = getDisplay(timeRemaining, BS.W_WOODWORKING, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE6))

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_WOODWORKING][slot] or 0, BS.W_WOODWORKING)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE6)),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_WOODWORKING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_WOODWORKING)
    end,
    customSettings = getSettings(BS.W_WOODWORKING)
}

BS.widgets[BS.W_CLOTHING] = {
    name = "clothing",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_CLOTHIER)
        local vars = BS.Vars.Controls[BS.W_CLOTHING]
        local colour = vars.OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (vars.DangerValue * 3600)) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (vars.WarningValue * 3600)) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        end

        fullyUsed[_G.CRAFTING_TYPE_CLOTHIER] = inUse == maxResearch
        local display = getDisplay(timeRemaining, BS.W_CLOTHING, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE2))

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText .. getDisplay(researchSlots[_G.CRAFTING_TYPE_CLOTHIER][slot] or 0, BS.W_CLOTHING)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_outfitter.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE2)),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_CLOTHIER]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_CLOTHIER)
    end,
    customSettings = getSettings(BS.W_CLOTHING)
}

BS.widgets[BS.W_JEWELCRAFTING] = {
    name = "jewelcrafting",
    update = function(widget)
        local timeRemaining, maxResearch, inUse = getResearchTimer(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
        local vars = BS.Vars.Controls[BS.W_JEWELCRAFTING]
        local colour = vars.OkColour or BS.Vars.DefaultOkColour

        if (timeRemaining < (vars.DangerValue * 3600)) then
            colour = vars.DangerColour or BS.Vars.DefaultDangerColour
        elseif (timeRemaining < (vars.WarningValue * 3600)) then
            colour = vars.WarningColour or BS.Vars.DefaultWarningColour
        end

        fullyUsed[_G.CRAFTING_TYPE_JEWELRYCRAFTING] = inUse == maxResearch
        local display = getDisplay(timeRemaining, BS.W_JEWELCRAFTING, inUse, maxResearch)

        widget:SetColour(unpack(colour))
        widget:SetValue(display)

        local ttt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE7))

        for slot = 1, maxResearch do
            local slotText = BS.LF .. "|cf9f9f9" .. slot .. " - "

            ttt = ttt .. slotText
            ttt = ttt .. getDisplay(researchSlots[_G.CRAFTING_TYPE_JEWELRYCRAFTING][slot] or 0, BS.W_JEWELCRAFTING)
        end

        widget.tooltip = ttt

        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/icon_jewelrycrafting_symbol.dds",
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADESKILLTYPE7)),
    hideWhenEqual = 0,
    fullyUsed = function()
        return fullyUsed[_G.CRAFTING_TYPE_JEWELRYCRAFTING]
    end,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
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
            elseif (added == qualifiedCount) then
                colour = BS.Vars.DefaultWarningColour
                BS.Vars.dailyQuests[character].pickedup = true
            end

            widget:SetValue(added .. "/" .. done .. "/" .. qualifiedCount)
            widget:SetColour(unpack(colour))

            local ttt = GetString(_G.BARSTEWARD_DAILY_CRAFTING) .. BS.LF

            for name, _ in pairs(qualifiedQuestNames) do
                local tdone = BS.Vars.dailyQuests[character][name] == "done"
                local tadded = BS.Vars.dailyQuests[character][name] == "added"
                local tcolour = BS.ARGBConvert(BS.Vars.DefaultColour)

                if (tdone) then
                    ttt = ttt .. BS.LF .. BS.ARGBConvert(BS.Vars.DefaultOkColour)
                    ttt = ttt .. name .. " - " .. GetString(_G.BARSTEWARD_COMPLETED) .. "|r"
                elseif (tadded) then
                    ttt = ttt .. BS.LF .. BS.ARGBConvert(BS.Vars.DefaultWarningColour)
                    ttt = ttt .. name .. " - " .. GetString(_G.BARSTEWARD_PICKED_UP) .. "|r"
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
                            local dccolour = ccolour

                            if (BS.Vars.dailyQuests[char].complete) then
                                dccolour = BS.ARGBConvert(BS.Vars.DefaultOkColour)
                            elseif (BS.Vars.dailyQuests[char].pickedup) then
                                dccolour = BS.ARGBConvert(BS.Vars.DefaultWarningColour)
                            end

                            ttt = ttt .. BS.LF .. dccolour .. char .. "|r"
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

BS.widgets[BS.W_CRAFTING_DAILY_TIME] = {
    -- v1.3.11
    -- same time as any other daily activity
    name = "craftingDailyTime",
    update = function(widget)
        return BS.GetTimedActivityTimeRemaining(_G.TIMED_ACTIVITY_TYPE_DAILY, BS.W_CRAFTING_DAILY_TIME, widget)
    end,
    timer = 1000,
    icon = "/esoui/art/icons/crafting_outfitter_logo.dds",
    tooltip = GetString(_G.BARSTEWARD_DAILY_WRITS_TIME)
}

local function getRecipeList()
    BS.recipeList = {
        food = {known = 0, unknown = 0.},
        drink = {known = 0, unknown = 0},
        furnishing = {known = 0, unknown = 0}
    }

    BS.unknownRecipeLinks = {[_G.ITEMTYPE_FOOD] = {}, [_G.ITEMTYPE_DRINK] = {}, [_G.ITEMTYPE_FURNISHING] = {}}

    for recipeListIndex = 1, GetNumRecipeLists() do
        local name, numRecipes = GetRecipeListInfo(recipeListIndex)

        for recipeIndex = 1, numRecipes do
            local known, _, _, _, _, _, _, resultItemId = GetRecipeInfo(recipeListIndex, recipeIndex)

            if (not BS.IGNORE_RECIPE[resultItemId]) then
                local link = BS.MakeItemLink(resultItemId)
                local itemType, sit = GetItemLinkItemType(link)

                if (itemType + sit ~= 0) then
                    if (itemType == _G.ITEMTYPE_FOOD) then
                        if (known == true) then
                            BS.recipeList.food.known = BS.recipeList.food.known + 1
                        else
                            BS.recipeList.food.unknown = BS.recipeList.food.unknown + 1
                            table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_FOOD], link)
                        end
                    elseif (itemType == _G.ITEMTYPE_DRINK) then
                        if (known == true) then
                            BS.recipeList.drink.known = BS.recipeList.drink.known + 1
                        else
                            BS.recipeList.drink.unknown = BS.recipeList.drink.unknown + 1
                            table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK], link)
                        end
                    elseif (itemType == _G.ITEMTYPE_FURNISHING) then
                        if (name ~= "") then
                            if (known) then
                                BS.recipeList.furnishing.known = BS.recipeList.furnishing.known + 1
                            else
                                BS.recipeList.furnishing.unknown = BS.recipeList.furnishing.unknown + 1
                                table.insert(BS.unknownRecipeLinks[_G.ITEMTYPE_FURNISHING], link)
                            end
                        end
                    end
                end
            end
        end
    end
end

local food = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ITEMTYPE4))
local drink = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ITEMTYPE12))
local foodAndDrink = food .. " + " .. drink
local furnishing = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ITEMTYPE61))
local recipes = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_ITEMTYPEDISPLAYCATEGORY21))

BS.widgets[BS.W_RECIPES] = {
    -- v1.4.6
    name = "recipes",
    update = function(widget, event)
        if ((BS.recipeList == nil) or (event ~= _G.EVENT_PLAYER_ACTIVATED)) then
            getRecipeList()
        end

        local allFood = BS.recipeList.food.known + BS.recipeList.food.unknown
        local allDrink = BS.recipeList.drink.known + BS.recipeList.drink.unknown
        local allFoodAndDrink = allFood + allDrink
        local allFurnishing = BS.recipeList.furnishing.known + BS.recipeList.furnishing.unknown
        local tt = recipes
        local vars = BS.Vars.Controls[BS.W_RECIPES]

        tt = tt .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.food.known .. "/" .. allFood .. "|r |cf9f9f9"
        tt = tt .. food .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.drink.known .. "/" .. allDrink .. "|r |cf9f9f9"
        tt = tt .. drink .. BS.LF .. "|cffd700"
        tt = tt .. (BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink .. "|r |cf9f9f9"
        tt = tt .. foodAndDrink .. BS.LF .. "|cffd700"
        tt = tt .. BS.recipeList.furnishing.known .. "/" .. allFurnishing .. "|r |cf9f9f9"
        tt = tt .. furnishing

        local value = BS.recipeList.food.known .. "/" .. allFood

        if (vars.Display == drink) then
            value = BS.recipeList.drink.known .. "/" .. allDrink
        elseif (vars.Display == foodAndDrink) then
            value = (BS.recipeList.drink.known + BS.recipeList.food.known) .. "/" .. allFoodAndDrink
        elseif (vars.Display == furnishing) then
            value = BS.recipeList.furnishing.known .. "/" .. allFurnishing
        end

        widget:SetValue(value)
        widget.tooltip = tt

        return widget:GetValue()
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_RECIPE_LEARNED, _G.EVENT_MULTIPLE_RECIPES_LEARNED},
    icon = "/esoui/art/tradinghouse/tradinghouse_trophy_recipe_fragment_up.dds",
    tooltip = recipes,
    onClick = function()
        local vars = BS.Vars.Controls[BS.W_RECIPES]
        local display = BS.unknownRecipeLinks[_G.ITEMTYPE_FOOD]

        if (vars.Display == drink) then
            display = BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK]
        elseif (vars.Display == foodAndDrink) then
            display = BS.MergeTables(display, BS.unknownRecipeLinks[_G.ITEMTYPE_DRINK])
        elseif (vars.Display == furnishing) then
            display = BS.unknownRecipeLinks[_G.ITEMTYPE_FURNISHING]
        end

        for _, link in ipairs(display) do
            -- chat router insists on having the name, even though the link works in game
            local itemName = GetItemLinkName(link)
            local itemId = GetItemLinkItemId(link)
            local newLink = BS.MakeItemLink(itemId, itemName)

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
