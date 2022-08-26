local BS = _G.BarSteward

local function needsUpdate(version)
    if (not BS.Vars.Updates[version]) then
        return true
    end

    return false
end

local function replace(current)
    local ucase = string.upper(current)

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
            local newUnit = GetString(_G["BARSTEWARD_" .. string.upper(widget.Units)])

            if (newUnit ~= "") then
                widget.Units = newUnit
            end
        end
    end
end

local function updateLanguageVars1223()
    local bars = BS.Vars.Bars
    local corrections = {
        ["Bas"] = "En bas",
        ["Droite"] = "À droite",
        ["Milieu"] = "Au milieu",
        ["Horizontal"] = "Horizontale",
        ["Gauche"] = "À gauche",
        ["Vertical"] = "Verticale",
        ["Haut"] = "En haut"
    }
    local vars = {"TooltipAnchor", "ValueSide", "Orientation", "Anchor"}

    for index, _ in pairs(bars) do
        for _, val in ipairs(vars) do
            local cval = corrections[BS.Vars.Bars[index][val]]

            if (cval) then
                BS.Vars.Bars[index][val] = cval
            end
        end
    end
end

function BS.VersionCheck()
    if (needsUpdate(112)) then
        -- update timer value from seconds to hours
        local value = BS.Vars.Controls[BS.W_LEADS].DangerValue
        local newValue = math.floor(value / 3.6) / 1000

        if (newValue < 1) then
            newValue = 1
        end

        BS.Vars.Controls[BS.W_LEADS].DangerValue = newValue
        BS.Vars.Controls[BS.W_LEADS].Units = GetString(_G.BARSTEWARD_HOURS)
        BS.Vars.Controls[BS.W_LEADS].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_BLACKSMITHING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_CLOTHING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_JEWELCRAFTING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].ColourValues = "okc,wv,wc,dv,dc"
        BS.Vars.Controls[BS.W_WOODWORKING].ColourValues = "okc,wv,wc,dv,dc"

        BS.Vars.Controls[BS.W_BLACKSMITHING].DangerValue = 24
        BS.Vars.Controls[BS.W_CLOTHING].DangerValue = 24
        BS.Vars.Controls[BS.W_JEWELCRAFTING].DangerValue = 24
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].DangerValue = 3
        BS.Vars.Controls[BS.W_WOODWORKING].DangerValue = 24
        BS.Vars.Controls[BS.W_BLACKSMITHING].WarningValue = 72
        BS.Vars.Controls[BS.W_CLOTHING].WarningValue = 72
        BS.Vars.Controls[BS.W_JEWELCRAFTING].WarningValue = 72
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].WarningValue = 6
        BS.Vars.Controls[BS.W_WOODWORKING].WarningValue = 72

        -- remove autohide from timers
        BS.Vars.Controls[BS.W_BLACKSMITHING].Autohide = nil
        BS.Vars.Controls[BS.W_CLOTHING].Autohide = nil
        BS.Vars.Controls[BS.W_JEWELCRAFTING].Autohide = nil
        BS.Vars.Controls[BS.W_MOUNT_TRAINING].Autohide = nil
        BS.Vars.Controls[BS.W_WOODWORKING].Autohide = nil

        BS.Vars.Updates[112] = true
    end

    if (needsUpdate(113)) then
        BS.Vars.Movable = false
    end

    if (needsUpdate(1222)) then
        if (GetCVar("language.2") == "fr") then
            updateLanguageVars()
        end

        BS.Vars.Updates[1222] = true
    end

    if (needsUpdate(1223)) then
        if (GetCVar("language.2") == "fr") then
            updateLanguageVars1223()
        end

        BS.Vars.Updates[1223] = true
    end

    if (needsUpdate(1224)) then
        if (GetCVar("language.2") == "fr") then
            BS.Vars.Bars[1].Name = GetString(_G.BARSTEWARD_MAIN_BAR)

            local widgets = BS.Vars.Controls

            for _, widget in pairs(widgets) do
                if (widget.Units) then
                    local newUnit = GetString(_G["BARSTEWARD_" .. string.upper(widget.Units)])

                    if (newUnit ~= "") then
                        widget.Units = newUnit
                    end
                end
            end
        end

        BS.Vars.Updates[1224] = true
    end

    if (needsUpdate(1301)) then
        BS.Vars.Controls[BS.W_LATENCY].ColourValues = BS.Defaults.Controls[BS.W_LATENCY].ColourValues
        BS.Vars.Updates[1301] = true
    end
end
