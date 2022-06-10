local BS = _G.BarSteward

local -- based on code from AI Research Timer
function getResearchTimer(craftType)
    local maxTimer = 2000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)
    local maxLines = GetNumSmithingResearchLines(craftType)

    for i = 1, maxLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftType, i)

        for j = 1, numTraits do
            local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j)

            if (duration ~= nil and timeRemaining ~= nil) then
                maxResearch = maxResearch - 1
                maxTimer = math.min(maxTimer, timeRemaining)
            end
        end
    end

    if (maxResearch > 0) then
        maxTimer = 0
    end

    return maxTimer
end

BS.widgets[BS.W_BLACKSMITHING] = {
    name = "blacksmithing",
    update = function(widget)
        local timeRemaining = getResearchTimer(_G.CRAFTING_TYPE_BLACKSMITHING)
        local colour = BS.Vars.Controls[BS.W_BLACKSMITHING].Colour or BS.Vars.DefaultColour

        if (timeRemaining == 0) then
            colour = BS.Vars.Controls[BS.W_BLACKSMITHING].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[BS.W_BLACKSMITHING].HideSeconds))
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_smithy.dds",
    tooltip = GetString(_G.SI_TRADESKILLTYPE1),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_BLACKSMITHING)
    end
}

BS.widgets[BS.W_WOODWORKING] = {
    name = "woodworking",
    update = function(widget)
        local timeRemaining = getResearchTimer(_G.CRAFTING_TYPE_WOODWORKING)
        local colour = BS.Vars.Controls[BS.W_WOODWORKING].Colour or BS.Vars.DefaultColour

        if (timeRemaining == 0) then
            colour = BS.Vars.Controls[BS.W_WOODWORKING].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[BS.W_WOODWORKING].HideSeconds))
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_woodworking.dds",
    tooltip = GetString(_G.SI_TRADESKILLTYPE6),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_WOODWORKING)
    end
}

BS.widgets[BS.W_CLOTHING] = {
    name = "clothing",
    update = function(widget)
        local timeRemaining = getResearchTimer(_G.CRAFTING_TYPE_CLOTHIER)
        local colour = BS.Vars.Controls[BS.W_CLOTHING].Colour or BS.Vars.DefaultColour

        if (timeRemaining == 0) then
            colour = BS.Vars.Controls[BS.W_CLOTHING].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[BS.W_CLOTHING].HideSeconds))
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/servicemappins/servicepin_outfitter.dds",
    tooltip = GetString(_G.SI_TRADESKILLTYPE2),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_CLOTHIER)
    end
}

BS.widgets[BS.W_JEWELCRAFTING] = {
    name = "jewelcrafting",
    update = function(widget)
        local timeRemaining = getResearchTimer(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
        local colour = BS.Vars.Controls[BS.W_JEWELCRAFTING].Colour or BS.Vars.DefaultColour

        if (timeRemaining == 0) then
            colour = BS.Vars.Controls[BS.W_JEWELCRAFTING].DangerColour or BS.Vars.DefaultDangerColour
        end

        widget:SetColour(unpack(colour))
        widget:SetValue(BS.SecondsToTime(timeRemaining, false, false, BS.Vars.Controls[BS.W_JEWELCRAFTING].HideSeconds))
        return timeRemaining
    end,
    timer = 1000,
    icon = "/esoui/art/icons/icon_jewelrycrafting_symbol.dds",
    tooltip = GetString(_G.SI_TRADESKILLTYPE7),
    hideWhenEqual = 0,
    complete = function()
        return BS.IsTraitResearchComplete(_G.CRAFTING_TYPE_JEWELRYCRAFTING)
    end
}
