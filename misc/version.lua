local BS = _G.BarSteward

local function needsUpdate(version)
    if (not BS.Vars:GetCommon("Updates", version)) then
        return true
    end

    return false
end

local function replace(current)
    local ucase = current:upper()

    if (_G["BARSTEWARD_" .. ucase]) then
        return GetString(_G["BARSTEWARD_" .. ucase])
    end

    return current
end

local function updateLanguageVars()
    -- if a new language file has been added, some exisiting English saved vars need to be updated
    local bars = BS.Vars.Bars

    -- update bar settings
    for index, _ in pairs(bars) do
        BS.Vars.Bars[index].TooltipAnchor = replace(BS.Vars.Bars[index].TooltipAnchor)
        BS.Vars.Bars[index].ValueSide = replace(BS.Vars.Bars[index].ValueSide)
        BS.Vars.Bars[index].Orientation = replace(BS.Vars.Bars[index].Orientation)
        BS.Vars.Bars[index].Anchor = replace(BS.Vars.Bars[index].Anchor)
    end

    -- update main bar name
    BS.Vars.Bars[1].Name = GetString(_G.BARSTEWARD_MAIN_BAR)

    --update widget unit settings
    local widgets = BS.Vars.Controls

    for _, widget in pairs(widgets) do
        if (widget.Units) then
            local newUnit = GetString(_G["BARSTEWARD_" .. widget.Units:upper()])

            if (newUnit ~= "") then
                widget.Units = newUnit
            end
        end
    end
end

function BS.VersionCheck()
    if (needsUpdate(2000)) then
        BS.Vars.Categories = true
        BS.Vars.CategoriesCount = true
        BS.Vars:SetCommon(true, "Updates", 2000)
    end

    if (needsUpdate(2006)) then
        local oldUpdates = {112, 1222, 1223, 1224, 1301, 1304, 1421, 1504, 1506}

        for _, ver in ipairs(oldUpdates) do
            BS.Vars:SetCommon(nil, "Updates", ver)
        end

        BS.Vars:SetCommon(true, "Updates", 2006)
    end

    if (needsUpdate(2010)) then
        local widgets = {BS.W_ENDLESS_ARCHIVE_PROGRESS, BS.W_ENDLESS_ARCHIVE_SCORE, BS.W_ARCHIVE_PORT}

        for _, widget in ipairs(widgets) do
            BS.Vars.Controls[widget].Cat = BS.CATNAMES.EndlessArchive
        end

        BS.Vars:SetCommon(true, "Updates", 2010)
    end

    if (needsUpdate(2111)) then
        if (GetCVar("language.2") == "zh") then
            updateLanguageVars()
        end

        BS.Vars:SetCommon(true, "Updates", 2111)
    end

    if (needsUpdate(3000)) then
        -- add back missing watched items
        local watchedItems = BS.Vars:GetCommon("WatchedItems") or {}

        if (watchedItems[BS.PERFECT_ROE] == nil) then
            BS.Vars:SetCommon(true, "WatchedItems", BS.PERFECT_ROE)
        end

        if (watchedItems[BS.POTENT_NIRNCRUX] == nil) then
            BS.Vars:SetCommon(true, "WatchedItems", BS.POTENT_NIRNCRUX)
        end

        BS.Vars:SetCommon(true, "Updates", 3000)
    end

    if (needsUpdate(3109)) then
        BS.Vars.Controls[BS.W_ALLIANCE_POINTS].Cat = BS.CATNAMES.PvP
        BS.Vars.Controls[BS.W_RANDOM_BATTLEGROUND].Cat = BS.CATNAMES.PvP
    end

    if (needsUpdate(3203) and _G.CURT_IMPERIAL_FRAGMENTS) then
        local tvk = BS.Vars.Controls[145]

        if (tvk) then
            if (tvk.Bar ~= 0) then
                BS.Vars.Controls[BS.W_IMPERIAL_FRAGMENTS].Bar = tvk.Bar
                BS.Vars.Controls[BS.W_IMPERIAL_FRAGMENTS].Order = tvk.Order
                BS.Vars.Controls[BS.W_IMPERIAL_FRAGMENTS].NoIcon = tvk.NoIcon
                BS.Vars.Controls[BS.W_IMPERIAL_FRAGMENTS].NoValue = tvk.NoValue
                BS.Vars.Controls[145] = nil
            end
        end

        BS.Vars:SetCommon(true, "Updates", 3203)
    end
end

function BS.SetVersionCheck()
    local versions = {2000, 2006, 2010, 2111, 3000}

    for _, version in ipairs(versions) do
        BS.Vars:SetCommon(true, "Updates", version)
    end
end
