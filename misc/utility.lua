local BS = _G.BarSteward

function BS.SecondsToTime(seconds, hideDays, hideHours, hideSeconds, format, hideDaysWhenZero)
    return BS.LC.SecondsToTime(
        seconds,
        hideDays,
        hideHours,
        hideSeconds,
        format,
        hideDaysWhenZero,
        _G.BARSTEWARD_TIMER_FORMAT_TEXT,
        _G.BARSTEWARD_TIMER_FORMAT_TEXT_NO_DAYS,
        _G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS_NO_DAYS,
        _G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS
    )
end

function BS.SetLockState(frame, lock)
    local lockNormal = "/esoui/art/miscellaneous/unlocked_up.dds"
    local lockPressed = "/esoui/art/miscellaneous/unlocked_down.dds"
    local lockMouseOver = "/esoui/art/miscellaneous/unlocked_over.dds"

    if (lock) then
        lockNormal = "/esoui/art/miscellaneous/locked_up.dds"
        lockPressed = "/esoui/art/miscellaneous/locked_down.dds"
        lockMouseOver = "/esoui/art/miscellaneous/locked_over.dds"
    end

    frame.lock:SetNormalTexture(lockNormal)
    frame.lock:SetPressedTexture(lockPressed)
    frame.lock:SetMouseOverTexture(lockMouseOver)
end

BS.EventManager = BS.LC.EventManager:New(BS.Name)
BS.TimerManager = BS.LC.TimerManager:New(BS.Name)

function BS.CheckPerformance(inCombat)
    if (BS.Vars.DisableTimersInCombat) then
        if (inCombat == nil) then
            inCombat = IsUnitInCombat("player")
        end

        if (inCombat and BS.disabledTimers == nil) then
            BS.TimerManager:DisableUpdates()
            BS.disabledTimers = true
        elseif (BS.disabledTimers ~= nil) then
            BS.TimerManager:EnableUpdates()
            BS.disabledTimers = nil
        end
    else
        if (BS.disabledTimers ~= nil) then
            BS.TimerManager:EnableUpdates()
            BS.disabledTimers = nil
        end
    end
end

function BS.GetAnchorFromText(text, adjust)
    if (text == GetString(_G.BARSTEWARD_LEFT)) then
        if (adjust) then
            return TOPLEFT
        end

        return LEFT
    end

    if (text == GetString(_G.BARSTEWARD_RIGHT)) then
        if (adjust) then
            return TOPRIGHT
        end

        return RIGHT
    end

    if (text == GetString(_G.BARSTEWARD_TOP)) then
        return TOP
    end

    if (text == GetString(_G.BARSTEWARD_BOTTOM)) then
        return BOTTOM
    end

    return CENTER
end

function BS.AddSeparators(number)
    local grouping = tonumber(GetString(_G.BARSTEWARD_NUMBER_GROUPING))
    local separator = BS.Vars.NumberSeparator or GetString(_G.BARSTEWARD_NUMBER_SEPARATOR)

    return BS.LC.AddSeparators(number, grouping, separator)
end

-- based on Wykkyd toolbar
function BS.ResetNudge()
    if (ZO_CompassFrame:GetTop()) ~= 40 then
        ZO_CompassFrame:ClearAnchors()
        ZO_CompassFrame:SetAnchor(TOP, GuiRoot, TOP, 0, 40)
        ZO_TargetUnitFramereticleover:ClearAnchors()
        ZO_TargetUnitFramereticleover:SetAnchor(TOP, GuiRoot, TOP, 0, 88)
    end
end

function BS.NudgeCompass()
    local bar1Top = BS.BarObjectPool:GetActiveObject(BS.BarObjects[1]).bar:GetTop()

    if (bar1Top <= 80) then
        if (ZO_CompassFrame:GetTop() ~= bar1Top + 70) then
            ZO_CompassFrame:ClearAnchors()
            ZO_CompassFrame:SetAnchor(TOP, GuiRoot, TOP, 0, bar1Top + 70)
            ZO_TargetUnitFramereticleover:ClearAnchors()
            ZO_TargetUnitFramereticleover:SetAnchor(TOP, GuiRoot, TOP, 0, bar1Top + 118)
        end
    elseif (bar1Top <= 100) then
        ZO_TargetUnitFramereticleover:ClearAnchors()
        ZO_TargetUnitFramereticleover:SetAnchor(TOP, GuiRoot, TOP, 0, bar1Top + 50)
    else
        BS.ResetNudge()
    end
end

function BS.IsTraitResearchComplete(craftingType)
    local complete = true

    for researchLineIndex = 1, GetNumSmithingResearchLines(craftingType) do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)

        for traitIndex = 1, numTraits do
            local _, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)

            if (not known) then
                return false
            end
        end
    end

    return complete
end

function BS.Announce(header, message, widgetIconNumber, lifespan, sound, otherIcon)
    local iconData

    if (widgetIconNumber) then
        iconData = BS.FormatIcon(otherIcon or BS.widgets[widgetIconNumber].icon)
    end

    BS.LC.ScreenAnnounce(header, message, iconData, lifespan, sound)
end

-- ensure all widget ordering is in a continuous
-- ordered sequence within the bar
function BS.CleanUpBarOrder(barNumber)
    local barTable = {}
    local controls = BS.Vars.Controls

    for key, control in pairs(controls) do
        if (control.Bar == barNumber) then
            table.insert(barTable, {key = key, control = control})
        end
    end

    table.sort(
        barTable,
        function(a, b)
            return a.control.Order < b.control.Order
        end
    )

    -- resequence the controls
    local index = 1
    for _, controlData in pairs(barTable) do
        controls[controlData.key].Order = index
        index = index + 1
    end
end

function BS.GetFont(vars)
    local font = BS.Vars.Font
    local size = BS.Vars.FontSize
    local style = BS.Vars.FontStyle

    if (vars) then
        if (vars.Font) then
            font = vars.Font
        end

        if (vars.FontSize) then
            size = vars.FontSize
        end

        if (vars.FontStyle) then
            style = vars.FontStyle
        end
    end

    return BS.LC.GetFont(font, size, style)
end

function BS.AddToScenes(sceneType, barIndex, bar, override)
    if (sceneType == "Default") then
        return
    end

    local group = BS[sceneType:upper() .. "_SCENES"]

    sceneType = "ShowWhilst" .. sceneType

    if (BS.Vars.Bars[barIndex][sceneType] or override) then
        for _, scene in ipairs(group) do
            SCENE_MANAGER:GetScene(scene):AddFragment(bar.fragment)
        end
    end
end

function BS.RemoveFromScenes(sceneType, bar)
    if (sceneType == "Default" or bar == nil) then
        return
    end

    local group = BS[sceneType:upper() .. "_SCENES"]

    for _, scene in ipairs(group) do
        SCENE_MANAGER:GetScene(scene):RemoveFragment(bar.fragment)
    end
end

function BS.RemoveFromAllScenes(barIndex)
    local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[barIndex])

    if (bar) then
        for _, scene in ipairs(BS.SCENES) do
            BS.RemoveFromScenes(scene, bar)
        end
    end
end

function BS.ForceResize(widgetIndex)
    local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[widgetIndex])

    widget:ForceResize()
end

function BS.RefreshWidget(widgetIndex, doIcon)
    if (BS.Vars.Controls[widgetIndex].Bar ~= 0) then
        local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[widgetIndex])

        if (widget ~= nil) then
            BS.widgets[widgetIndex].update(widget, "initial")

            if (doIcon) then
                local icon = BS.widgets[widgetIndex].icon

                if (type(icon) == "function") then
                    icon = icon()
                end

                widget:SetIcon(icon)
            end
        end
    end
end

function BS.RefreshBar(widgetIndex)
    if (BS.Vars.Controls[widgetIndex].Bar ~= 0) then
        local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[widgetIndex])

        if (widget ~= nil) then
            local barIndex = BS.Vars.Controls[widgetIndex].Bar
            local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[barIndex])
            local metadata = BS.widgets[widgetIndex]

            metadata.widget = widget
            bar:DoUpdate(metadata)
        end
    end
end

function BS.RefreshAll()
    for widgetIndex in pairs(BS.Vars.Controls) do
        BS.RefreshWidget(widgetIndex)
    end
end

function BS.ResizeBar(barIndex)
    if ((barIndex or 0) == 0) then
        return
    end

    local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[barIndex])

    if (barObject) then
        local bar = barObject.bar

        bar:SetResizeToFitDescendents(false)
        bar:SetDimensions(0, 0)
        bar:SetResizeToFitDescendents(true)

        -- check for hidden widgets
        local allHidden = true

        for index, widget in pairs(BS.Vars.Controls) do
            if (widget.Bar == barIndex) then
                local w = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[index])

                if (w and not w:IsHidden()) then
                    allHidden = false
                    break
                end
            end
        end

        -- if the bar is hidden, hide the border
        if (allHidden) then
            bar.border:SetEdgeTexture("", 128, 2)
            bar.border:SetEdgeColor(0, 0, 0, 0)
        elseif (bar.ToggleState ~= "hidden") then
            if ((BS.Vars.Bars[barIndex].Border or 99) ~= 99) then
                bar.border:SetEdgeTexture(unpack(BS.LC.Borders[BS.Vars.Bars[barIndex].Border]))
                bar.border:SetEdgeColor(1, 1, 1, 1)
            end
        end
    end
end

function BS.ColourToIcon(r, g, b)
    local quality = BS.LC.ColourToQuality(r, g, b)

    return BS.FormatIcon(BS.ITEM_COLOUR_ICON[quality or 1])
end

function BS.GetWritType(itemId)
    for key, itemIds in pairs(BS.WRITS) do
        for _, id in pairs(itemIds) do
            if (id == itemId) then
                return key
            end
        end
    end

    return 0
end

function BS.ToWritFields(item_link)
    local parsedLink = {ZO_LinkHandler_ParseLink(item_link)}
    local bsValues = {
        itemId = tonumber(parsedLink[4]),
        writType = BS.GetWritType(tonumber(parsedLink[4])),
        subType = tonumber(parsedLink[5]),
        itemType = BS.LC.GetByValue(BS.WRIT_ITEM_TYPES, tonumber(parsedLink[10])) or 0,
        itemQuality = tonumber(parsedLink[12]),
        motifNumber = tonumber(parsedLink[15])
    }

    return bsValues
end

local function addQuotes(value, sub)
    return '"' .. GetString(value, sub) .. '"'
end

local function cleanseAndEncode(input)
    local output = input

    output = output:gsub("#true%^", "#t%^")
    output = output:gsub("#false%^", "#f%^")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_VERTICAL), "#v")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_HORIZONTAL), "#h")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_LEFT), "#l")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_RIGHT), "#r")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_TOP), "#to")
    output = output:gsub("#" .. addQuotes(_G.BARSTEWARD_BOTTOM), "#b")

    for bg = 1, 14 do
        output = output:gsub("#" .. addQuotes("BARSTEWARD_BACKGROUND_STYLE_", bg), "#bg" .. tostring(bg))

        if (bg < 8) then
            output = output:gsub("#" .. addQuotes("BARSTEWARD_BORDER_STYLE_", bg), "#bo" .. tostring(bg))
        end
    end

    return output
end

local function decode(input)
    local output = input:gsub("#t%^", "#true%^")

    output = output:gsub("#f%^", "#false%^")
    output = output:gsub("#v", "#" .. addQuotes(_G.BARSTEWARD_VERTICAL))
    output = output:gsub("#h", "#" .. addQuotes(_G.BARSTEWARD_HORIZONTAL))
    output = output:gsub("#l", "#" .. addQuotes(_G.BARSTEWARD_LEFT))
    output = output:gsub("#r", "#" .. addQuotes(_G.BARSTEWARD_RIGHT))
    output = output:gsub("#to", "#" .. addQuotes(_G.BARSTEWARD_TOP))
    output = output:gsub("#b", "#" .. addQuotes(_G.BARSTEWARD_BOTTOM))

    for bg = 1, 14 do
        output = output:gsub("#bg" .. tostring(bg), "#" .. addQuotes("BARSTEWARD_BACKGROUND_STYLE_", bg))

        if (bg < 8) then
            output = output:gsub("#bo" .. tostring(bg), "#" .. addQuotes("BARSTEWARD_BORDER_STYLE_", bg))
        end
    end

    for keyword, abbr in pairs(BS.ENCODING) do
        output = output:gsub("::" .. abbr .. "#", "::" .. keyword .. "#")
        output = output:gsub("%^" .. abbr .. "#", "%^" .. keyword .. "#")
    end

    return output
end

local function convert(value)
    if (not value) then
        return
    end

    if (value == "true") then
        return true
    end

    if (value == "false") then
        return false
    end

    local count = BS.LC.Count(value, "%-")

    if (count == 3) then
        local array = BS.LC.Split(value, "%-")

        for index, val in pairs(array) do
            val = val:gsub("%%", "")
            array[index] = tonumber(val)
        end

        return array
    end

    if (tonumber(value)) then
        return tonumber(value)
    end

    return value
end

local function generateTable(input)
    assert(input:sub(1, 3) == "b::", GetString(_G.BARSTEWARD_IMPORT_ERROR_BAR))
    assert(input:sub(-1) == "^", GetString(_G.BARSTEWARD_IMPORT_ERROR_DATA))
    assert(input:find("w::"), GetString(_G.BARSTEWARD_IMPORT_ERROR_WIDGET))

    local widgetStartPos = input:find("w::")
    local barData = BS.LC.Split(input:sub(4, widgetStartPos - 1), "%^")
    local widgetData = BS.LC.Split(input:sub(widgetStartPos + 3), "%^")

    local barObject = {}

    -- convert bar data to a table
    for _, token in pairs(barData) do
        local info = BS.LC.Split(token, "#")

        if (info[1]) then
            -- check for backdrop.colour
            if (info[1] == string.format("%s_%s", BS.ENCODING["Backdrop"], BS.ENCODING["Colour"])) then
                -- check for backdrop.show
                barObject.Backdrop = {Colour = convert(info[2])}
            elseif (info[1] == string.format("%s_%s", BS.ENCODING["Backdrop"], BS.ENCODING["Show"])) then
                barObject.Backdrop = {Show = convert(info[2])}
            else
                barObject[info[1]] = convert(info[2])
            end
        end
    end

    -- convert widget data to a table
    local currentWidget
    local widgetsObject = {}

    for _, token in pairs(widgetData) do
        local info = BS.LC.Split(token, "#")

        if (info[1] and info[1] ~= "%") then
            if (info[1]:sub(1, 1) == "@") then
                currentWidget = tonumber(info[1]:sub(2))
                widgetsObject[currentWidget] = {}
            elseif (currentWidget) then
                widgetsObject[currentWidget][info[1]] = convert(info[2])
            end
        end
    end

    return {
        Bar = barObject,
        Widgets = widgetsObject
    }
end

function BS.ExportBar(barNumber)
    local destBar = BS.LC.DeepCopy(BS.Vars.Bars[barNumber])

    -- remove any default values, no point keeping those
    for k, v in pairs(destBar) do
        if (type(v) ~= "table") then
            if (v == BS.Defaults.Bars[1][k]) then
                destBar[k] = nil
            end
        end
    end

    if (destBar.Backdrop.Colour) then
        if (BS.LC.SimpleTableCompare(destBar.Backdrop.Colour, BS.Defaults.Bars[1].Backdrop.Colour)) then
            destBar.Backdrop.Colour = nil
        end
    end

    if (destBar.Backdrop.Show) then
        if (destBar.Backdrop.Show == BS.Defaults.Bars[1].Backdrop.Show) then
            destBar.Backdrop.Show = nil
        end
    end

    if (destBar.CombatColour) then
        if (BS.LC.SimpleTableCompare(destBar.CombatColour, BS.Defaults.DefaultCombatColour)) then
            destBar.CombatColour = nil
        end
    end

    -- don't copy unneeded values
    destBar.Position = nil
    destBar.ToggleState = nil
    destBar.HideBarEnable = nil
    destBar.Disable = nil

    local forExport = {
        Bar = destBar,
        Controls = {}
    }

    -- copy the widgets
    for widgetIndex, widgetSettings in pairs(BS.Vars.Controls) do
        -- ignore housing widgets - they are too client specific
        if (widgetIndex < 1000) then
            if (widgetSettings.Bar == barNumber) then
                forExport.Controls[widgetIndex] = BS.LC.DeepCopy(widgetSettings)
                forExport.Controls[widgetIndex].Bar = nil
                forExport.Controls[widgetIndex].Exclude = nil

                -- remove any default values, no point keeping those
                for k, v in pairs(forExport.Controls[widgetIndex]) do
                    if (type(v) ~= "table") then
                        if (v == BS.Defaults.Controls[widgetIndex][k]) then
                            forExport.Controls[widgetIndex][k] = nil
                        end
                    end
                end
            end
        end
    end

    local output = "b::"

    -- add bar info
    for key, value in pairs(forExport.Bar) do
        if (key == "Backdrop") then
            if (forExport.Bar.Backdrop.Colour) then
                output =
                    output ..
                    string.format(
                        "%s_%s#%.3g-%.3g-%.3g-%.3g^",
                        BS.ENCODING["Backdrop"],
                        BS.ENCODING["Colour"],
                        forExport.Bar.Backdrop.Colour[1],
                        forExport.Bar.Backdrop.Colour[2],
                        forExport.Bar.Backdrop.Colour[3],
                        forExport.Bar.Backdrop.Colour[4]
                    )
            end

            if (forExport.Bar.Backdrop.Show) then
                output =
                    output ..
                    string.format(
                        "%s_%s#%s",
                        BS.ENCODING["Backdrop"],
                        BS.ENCODING["Show"],
                        tostring(forExport.Bar.Backdrop.Show)
                    )
            end
        elseif (key == "CombatColour") then
            if (forExport.Bar.CombatColour) then
                output =
                    output ..
                    string.format(
                        "%s#%.3g-%.3g-%.3g-%.3g^",
                        BS.ENCODING["CombatColour"],
                        forExport.Bar.CombatColour[1],
                        forExport.Bar.CombatColour[2],
                        forExport.Bar.CombatColour[3],
                        forExport.Bar.CombatColour[4]
                    )
            end
        else
            output = output .. string.format("%s#%s^", BS.ENCODING[key] or key, tostring(value))
        end
    end

    -- add widget info
    output = output .. "w::"

    for widgetIndex, widgetInfo in pairs(forExport.Controls) do
        output = output .. string.format("@%d^", widgetIndex)

        for key, value in pairs(widgetInfo) do
            if (key:sub(-6) == "Colour" and key ~= "NoLimitColour") then
                output =
                    output ..
                    string.format(
                        "%s#%.3g-%.3g-%.3g-%.3g^",
                        BS.ENCODING[key],
                        forExport.Controls[widgetIndex][key][1] or "0",
                        forExport.Controls[widgetIndex][key][2] or "0",
                        forExport.Controls[widgetIndex][key][3] or "0",
                        forExport.Controls[widgetIndex][key][4] or "0"
                    )
            else
                output = output .. string.format("%s#%s^", BS.ENCODING[key] or key, tostring(value))
            end
        end
    end

    output = cleanseAndEncode(output)

    return output
end

local function cleanAssert(message)
    message = message:gsub("assert: ", "")

    local stacktraceStart = message:find("stack traceback")

    message = message:sub(1, stacktraceStart - 1)

    return message
end

local function validate(data)
    local status, decoded = pcall(decode, data)

    if (not status) then
        BS.ExportFrame.error:SetText(cleanAssert(decoded))
        return
    end

    local tableStatus, importTable = pcall(generateTable, decoded)

    if ((not tableStatus) or type(importTable) ~= "table") then
        BS.ExportFrame.error:SetText(cleanAssert(importTable))
        return
    end

    if (importTable.Bar == nil or importTable.Widgets == nil) then
        BS.ExportFrame.error:SetText(GetString(_G.BARSTEWARD_IMPORT_ERROR_WIDGET_OR_BAR))
        return
    end

    BS.ExportFrame.fragment:SetHiddenForReason("disabled", true)

    return importTable
end

function BS.CheckBarName(name, bars)
    for _, bar in pairs(bars) do
        if ((bar.Name or "") == name) then
            name = name .. "1"
        end
    end

    return name
end

function BS.DoImport()
    local data = BS.ImportData
    local bars = BS.Vars.Bars
    local newBarId = #bars + 1
    local barname = data.Bar.Name or zo_strformat(GetString(_G.BARSTEWARD_NEW_BAR_DEFAULT_NAME), newBarId)
    local x, y = GuiRoot:GetCenter()

    barname = BS.CheckBarName(barname, bars)

    if (BS.ReplaceMain) then
        BS.DestroyBar(BS.MAIN_BAR)

        local widgets = BS.Vars.Controls

        for _, widgetData in pairs(widgets) do
            if (widgetData.Bar == BS.MAIN_BAR) then
                widgetData.Bar = 0
            end
        end

        newBarId = BS.MAIN_BAR
        barname = nil
    end

    BS.Vars.Bars[newBarId] = {
        Orientation = GetString(_G.BARSTEWARD_HORIZONTAL),
        Position = {X = x, Y = y},
        Name = barname,
        Backdrop = {
            Show = data.Bar.Backdrop and data.Bar.Backdrop.Show or true,
            Colour = data.Bar.Backdrop and data.Bar.Backdrop.Colour or {0.23, 0.23, 0.23, 0.7}
        },
        TooltipAnchor = GetString(_G.BARSTEWARD_BOTTOM),
        ValueSide = GetString(_G.BARSTEWARD_RIGHT)
    }

    for key, value in pairs(data.Bar) do
        if (key ~= "Backdrop") then
            BS.Vars.Bars[newBarId][key] = value
        end
    end

    -- add widgets to the bar
    for widgetIndex, widgetData in pairs(data.Widgets) do
        BS.Vars.Controls[widgetIndex].Bar = newBarId

        for key, value in pairs(widgetData) do
            BS.Vars.Controls[widgetIndex][key] = value
        end
    end

    zo_callLater(
        function()
            ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
        end,
        500
    )
end

function BS.ImportBar(data, replaceMain)
    local importTable = validate(data)

    if (importTable) then
        -- check widget movement
        local widgetCount = 0

        for widgetIndex, _ in pairs(importTable.Widgets) do
            if (BS.Vars.Controls[widgetIndex].Bar ~= 0) then
                widgetCount = widgetCount + 1
            end
        end

        BS.ImportData = importTable

        if (ZO_CheckButton_IsChecked(replaceMain)) then
            ZO_Dialogs_ShowDialog(BS.Name .. "Confirm")
        elseif (widgetCount > 0) then
            BS.MovingWidgets = widgetCount
            ZO_Dialogs_ShowDialog(BS.Name .. "Import")
        else
            BS.DoImport()
        end
    end
end

local function getWidgets(barIndex)
    local widgets = {}

    -- get the widgets for this bar
    for id, info in ipairs(BS.Vars.Controls) do
        if (id ~= BS.W_PORT) then
            if (info.Bar == barIndex and not (BS.Defaults.Controls[id].Hidden)) then
                local add = true

                if (info.Requires) then
                    local requiredLib = info.Requires

                    if (_G[requiredLib] == nil) then
                        add = false
                    end
                end

                if (add) then
                    local widget = BS.widgets[id]

                    widget.id = id
                    table.insert(widgets, {info.Order, widget})
                end
            end
        end
    end

    -- add any housing widgets
    BS.AddHousingWidgets(barIndex, widgets)

    -- ensure the widgets are in the order we want them drawn
    table.sort(
        widgets,
        function(a, b)
            return a[1] < b[1]
        end
    )

    local orderedWidgets = {}

    if (#widgets > 0) then
        -- ensure there are no gaps in the array sequence
        local widgetIndex = 1

        for _, v in ipairs(widgets) do
            orderedWidgets[widgetIndex] = v[2]
            widgetIndex = widgetIndex + 1
        end
    end

    return orderedWidgets
end

local function setBinding(barIndex, barName)
    local stringId = "SI_BINDING_NAME_BARSTEWARD_KEYBIND_TOGGLE_BAR_" .. barIndex

    if (not _G[stringId]) then
        if (barIndex < BS.MAX_BINDINGS) then
            ZO_CreateStringId(stringId, ZO_CachedStrFormat(_G.BARSTEWARD_TOGGLE, barName))
        end
    -- else
    --     local id = _G[stringId]
    --     _G[stringId] = nil
    --     _G.EsoStrings[id] = nil
    end
end

function BS.GenerateBar(barIndex)
    if ((barIndex or 0) == 0) then
        return
    end

    local barData = BS.Vars.Bars[barIndex]
    local bar =
        BS.CreateBar(
        {
            index = barIndex,
            position = barData.Orientation == GetString(_G.BARSTEWARD_HORIZONTAL) and TOP or LEFT,
            scale = barData.Scale or GuiRoot:GetScale(),
            settings = barData
        }
    )

    local widgets = getWidgets(barIndex)

    if (#widgets > 0) then
        bar:AddWidgets(widgets)

        if (barData.ToggleState == "hidden") then
            zo_callLater(
                function()
                    bar:Hide()
                end,
                500
            )
        end
    end

    if (barData.NudgeCompass) then
        BS.NudgeCompass()
        -- from Bandits UI
        -- stop the game move the compass back to its original position
        local block = {ZO_CompassFrame_Keyboard_Template = true, ZO_CompassFrame_Gamepad_Template = true}
        local ZO_ApplyTemplateToControl = _G.ApplyTemplateToControl

        _G.ApplyTemplateToControl = function(control, templateName)
            if block[templateName] then
                return
            else
                ZO_ApplyTemplateToControl(control, templateName)
            end
        end
    end

    local barName = barData.Name
    setBinding(barIndex, barName)

    if (not ZO_IsElementInNumericallyIndexedTable(BS.alignBars, barName)) then
        table.insert(BS.alignBars, barName)
        table.insert(BS.Bars, barName)
    end
end

function BS.DestroyBar(barIndex)
    if ((barIndex or 0) == 0) then
        return
    end

    -- remove the bar from all scenes
    BS.RemoveFromAllScenes(barIndex)

    -- return widgets to the pool
    local widgets = getWidgets(barIndex)

    for widgetIndex = #widgets, 1, -1 do
        local keyIndex = widgets[widgetIndex].id
        local widgetKey = BS.WidgetObjects[keyIndex]

        BS.WidgetObjectPool:ReleaseObject(widgetKey)
    end

    -- return bar to the pool
    local barKey = BS.BarObjects[barIndex]

    BS.BarObjectPool:ReleaseObject(barKey)

    -- unset the binding
    --setBinding(barIndex)

    -- remove the bar name from the list of alignment bars
    local barName = BS.Vars.Bars[barIndex].Name

    BS.alignBars =
        BS.LC.Filter(
        BS.alignBars,
        function(v)
            return v ~= barName
        end
    )

    BS.Bars =
        BS.LC.Filter(
        BS.Bars,
        function(v)
            return v ~= barName
        end
    )
end

local function refreshBarWidgets(barIndex)
    local widgets = getWidgets(barIndex)

    for _, widget in pairs(widgets) do
        BS.RefreshWidget(widget.id)
    end
end

function BS.RegenerateBar(barIndex, destroyWidget)
    if ((barIndex or 0) == 0) then
        return
    end

    if (destroyWidget) then
        local widgetKey = BS.WidgetObjects[destroyWidget]

        if (widgetKey) then
            BS.WidgetObjectPool:ReleaseObject(widgetKey)
        end
    end

    if (not BS.Vars.Bars[barIndex].Disable) then
        BS.DestroyBar(barIndex)
        BS.GenerateBar(barIndex)
        refreshBarWidgets(barIndex)
        BS.ResizeBar(barIndex)
    end
end

function BS.RegenerateAllBars(barsToRegenerate)
    local bars = BS.Vars.Bars
    local regenerate = true

    for barIndex, barInfo in pairs(bars) do
        if (barsToRegenerate) then
            if (barsToRegenerate[barIndex]) then
                regenerate = true
            else
                regenerate = false
            end
        end

        if ((not barInfo.Disable) and regenerate) then
            BS.RegenerateBar(barIndex)
        end
    end
end

function BS.FormatIcon(path)
    if (path:find("BarSteward")) then
        return path
    end

    if (not path:lower():find("esoui")) then
        path = "/esoui/art/" .. path
    end

    if (not path:find(".dds")) then
        path = path .. ".dds"
    end

    return path
end

function BS.Icon(path, colour, width, height)
    if (not path:find("BarSteward")) then
        path = BS.FormatIcon(path)
    end

    return BS.LC.GetIconTexture(path, colour, width, height)
end

function BS.GetVar(name, widget)
    local value
    local continue = false

    if (BS) then
        if (BS.Vars) then
            if (BS.Vars.Controls) then
                continue = true
            end
        end
    end

    if (continue) then
        if (widget) then
            if (BS.Vars.Controls[widget]) then
                value = BS.Vars.Controls[widget][name]
            end
            if (value == nil) then
                if (BS.Defaults.Controls[widget]) then
                    value = BS.Defaults.Controls[widget][name]
                end
            end
        else
            value = BS.Vars[name]

            if (value == nil) then
                value = BS.Defaults[name]
            end
        end
    end

    return value
end

function BS.SetVar(value, name, widget)
    local continue = false

    if (BS) then
        if (BS.Vars) then
            if (BS.Vars.Controls) then
                continue = true
            end
        end
    end

    if (continue) then
        BS.Vars.Controls[widget][name] = value
    end
end

function BS.GetTimeColour(value, this, multiplier, useOK, useZoColours)
    local colour

    if (useOK) then
        colour = BS.GetColour(this, "Ok", nil, useZoColours)
    end

    multiplier = multiplier or 3600

    if (value <= (BS.GetVar("DangerValue", this)) * multiplier) then
        colour = BS.GetColour(this, "Danger", nil, useZoColours)
    elseif (value <= (BS.GetVar("WarningValue", this) * multiplier)) then
        colour = BS.GetColour(this, "Warning", nil, useZoColours)
    end

    return colour
end

function BS.GetColour(this, colourType, default, useZoColours)
    if (type(colourType) == "boolean") then
        useZoColours = colourType
        colourType = nil
    end

    if (type(default) == "boolean") then
        useZoColours = default
        default = nil
    end

    local colour = "Colour"
    local defaultColour = "Default" .. colour
    local defColour

    if (colourType) then
        colour = colourType .. colour
        defaultColour = "Default" .. colour
    end

    if (default) then
        defColour = BS.GetVar(default) or {0, 0, 0, 0}
    else
        defColour = BS.GetVar(defaultColour) or {0, 0, 0, 0}
    end

    local retColour = BS.GetVar(colour, this) or defColour

    if (useZoColours) then
        return BS.LC.Colour(retColour)
    else
        return retColour
    end
end

function BS.GetWidget(widgetIndex)
    return BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[widgetIndex])
end

local function getBar(barNumber)
    local barKey = BS.BarObjects[barNumber]
    local bar = BS.BarObjectPool:GetActiveObject(barKey)

    return bar
end

function BS.GetBar(widgetIndex)
    local barNumber = BS.Vars.Controls[widgetIndex].Bar

    if (barNumber ~= 0) then
        return getBar(barNumber)
    end
end

function BS.UpdateIconGap(barNumber)
    if (barNumber and (barNumber > 0)) then
        local widgets = getWidgets(barNumber)

        for _, widgetData in pairs(widgets) do
            local widget = BS.GetWidget(widgetData.id)

            widget:SetValueAnchor()
        end

        BS.RegenerateBar(barNumber)
    end
end

function BS.GetLastDailyResetTime(counts, ach)
    local timeRemaining =
        TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(_G.TIMED_ACTIVITY_TYPE_DAILY)
    local secondsInADay = 86400
    local lastResetTime = os.time() - (secondsInADay - timeRemaining)

    if (counts) then
        if (BS.Vars:GetCommon("lastDailyResetCounts") == nil) then
            BS.Vars:SetCommon(lastResetTime, "lastDailyResetCounts")
        end

        if ((BS.Vars:GetCommon("lastDailyResetCounts") + secondsInADay) < os.time()) then
            return lastResetTime
        end
    elseif (ach) then
        if (BS.Vars:GetCommon("lastDailyResetAch") == nil) then
            BS.Vars:SetCommon(lastResetTime, "lastDailyResetAch")
        end

        if ((BS.Vars:GetCommon("lastDailyResetAch") + secondsInADay) < os.time()) then
            return lastResetTime
        end
    else
        if (BS.Vars:GetCommon("lastDailyReset") == nil) then
            BS.Vars:SetCommon(lastResetTime, "lastDailyReset")
        end

        if ((BS.Vars:GetCommon("lastDailyReset") + secondsInADay) < os.time()) then
            return lastResetTime
        end
    end
end

function BS.GetQuestInfo()
    if (BS.GetVar("Bar", BS.W_DAILY_COUNT) ~= 0) then
        QUEST_JOURNAL_MANAGER:RegisterCallback(
            "QuestListUpdated",
            function()
                if (BS.GetVar("Bar", BS.W_DAILY_COUNT) ~= 0) then
                    BS.Quests = QUEST_JOURNAL_MANAGER:GetQuestList()
                end
            end
        )
    end
end

function BS.PopulateSoundOptions()
    BS.SoundChoices, BS.SoundLookup = BS.LC.GetSoundDropdownOptions()
end

function BS.ToggleBar(index)
    local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[index])

    if (bar) then
        bar:Toggle()
    end
end

function BS.ToggleHidden(hide)
    for barNumber, barData in pairs(BS.Vars.Bars) do
        if (not barData.Disable) then
            local bar = getBar(barNumber)

            if (bar) then
                if (hide and not bar.bar:IsHidden()) then
                    bar:ForceHide()
                elseif ((not hide) and bar.bar:IsHidden()) then
                    bar:ForceShow()
                end
            end
        end
    end
end

function BS.HideInCombat()
    for barNumber, barData in pairs(BS.Vars.Bars) do
        if (not barData.Disable) then
            if (BS.GetVar("HideDuringCombat")) then
                local bar = getBar(barNumber)

                if (bar) then
                    if (BS.inCombat) then
                        bar:ForceHide()
                    else
                        bar:ForceShow()
                    end
                end
            end
        end
    end
end

function BS.HideWhenDead()
    for barNumber, barData in pairs(BS.Vars.Bars) do
        if (not barData.Disable) then
            if (BS.GetVar("HideWhenDead")) then
                local bar = getBar(barNumber)

                if (bar) then
                    if (IsUnitDead("player")) then
                        bar:ForceHide()
                    else
                        bar:ForceShow()
                    end
                end
            end
        end
    end
end

function BS.RegisterColours()
    BS.COLOURS = {
        DefaultCombatColour = BS.LC.Colour(BS.Defaults.DefaultCombatColour),
        DefaultColour = BS.LC.Colour(BS.Defaults.DefaultColour),
        DefaultDangerColour = BS.LC.Colour(BS.Defaults.DefaultDangerColour),
        DefaultMaxColour = BS.LC.Colour(BS.Defaults.DefaultMaxColour),
        DefaultWarningColour = BS.LC.Colour(BS.Defaults.DefaultWarningColour),
        DefaultOkColour = BS.LC.Colour(BS.Defaults.DefaultOkColour),
        Blue = BS.LC.Colour("34a4eb"),
        Green = BS.LC.Colour("00ff00"),
        Grey = BS.LC.Colour("bababa"),
        Red = BS.LC.Colour("f90000"),
        Yellow = BS.LC.Colour("ffff00"),
        White = BS.LC.Colour("f9f9f9"),
        ZOSBlue = BS.LC.Colour("3a92ff"),
        ZOSGold = BS.LC.Colour("ccaa1a"),
        ZOSGreen = BS.LC.Colour("2dc50e"),
        ZOSGrey = BS.LC.Colour("e6e6e6"),
        ZOSOrange = BS.LC.Colour("e58b27"),
        ZOSPurple = BS.LC.Colour("a02ef7")
    }
end

function BS.ScanBuffs(buffList, widgetIndex)
    local formatter = function(remaining)
        return BS.SecondsToTime(
            remaining,
            true,
            false,
            BS.GetVar("HideSeconds", widgetIndex),
            BS.GetVar("Format", widgetIndex)
        )
    end

    local buffs = BS.LC.ScanBuffs(buffList, formatter)

    return buffs
end

function BS.FindBar(barName)
    for index, barData in pairs(BS.Vars.Bars) do
        if (barData.Name:lower() == barName:lower()) then
            return BS.BarObjectPool:GetActiveObject(BS.BarObjects[index]), index
        end
    end
end

function BS.RegisterHooks()
    -- handle logout / quit
    -- disable timer based widgets to prevent errors
    -- trying to access destroyed objects
    ZO_PreHook(
        "Logout",
        function()
            if (not BS.disabledTimers) then
                BS.TimerManager:DisableUpdates(true)
                BS.LoggingOut = true
            end
        end
    )

    ZO_PreHook(
        "Quit",
        function()
            if (not BS.disabledTimers) then
                BS.TimerManager:DisableUpdates(true)
                BS.LoggingOut = true
            end
        end
    )

    ZO_PostHook(
        "CancelLogout",
        function()
            if (not BS.disabledTimers) then
                BS.TimerManager:EnableUpdates(true)
                BS.LoggingOut = false
            end
        end
    )

    BS.CheckCriminalActivity()
end

BS.UpToSomething = {
    bounty = false,
    stealing = false,
    crimeQuest = false
}

function BS.IsUpToSomething()
    return BS.UpToSomething.bounty or BS.UpToSomething.stealing or BS.UpToSomething.crimeQuest
end

-- need to check on inventory callback, quest list updated callback and

function BS.CheckCriminalActivity()
    if (BS.Vars.CheckCrime) then
        local bountyFunc = function(bounty)
            if (bounty.infamyMeterState.isTrespassing or bounty.infamyMeterState.bounty > 0) then
                if (BS.UpToSomething.bounty == false) then
                    BS.UpToSomething.bounty = true
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            else
                if (BS.UpToSomething.bounty) then
                    BS.UpToSomething.bounty = false
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            end
        end

        local bagFunc = function()
            if (BS.LC.IsCarryingStolenItems()) then
                if (BS.UpToSomething.stealing == false) then
                    BS.UpToSomething.stealing = true
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            else
                if (BS.UpToSomething.stealing) then
                    BS.UpToSomething.stealing = false
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            end
        end

        local questFunc = function()
            if (BS.HasCriminalQuest()) then
                if (BS.UpToSomething.crimeQuest == false) then
                    BS.UpToSomething.crimeQuest = true
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            else
                if (BS.UpToSomething.crimeQuest) then
                    BS.UpToSomething.crimeQuest = false
                    BS.FireCallbacks("CriminalActivityUpdate", BS.IsUpToSomething())
                end
            end
        end

        SecurePostHook(_G.HUD_INFAMY_METER, "UpdateInfamyMeterState", bountyFunc)
        _G.SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", bagFunc)
        _G.QUEST_JOURNAL_MANAGER:RegisterCallback("QuestListUpdated", questFunc)

        BS.EventManager:RegisterForEvent(
            _G.EVENT_PLAYER_ACTIVATED,
            function()
                bagFunc()
                questFunc()
            end
        )
    end
end

function BS.HasCriminalQuest()
    if (not BS.CrimeQuests) then
        BS.CrimeQuests = BS.LC.BuildList(BS.CRIMEQUESTS)
    end

    local journalQuests = QUEST_JOURNAL_MANAGER:GetQuestList()

    for _, quest in ipairs(journalQuests) do
        if (quest.questType == _G.QUEST_TYPE_GUILD) then
            if (BS.CrimeQuests[quest.name]) then
                return true
            end
        end
    end

    return false
end

function BS.ShowFrameMovers(value)
    for index, _ in pairs(BS.Vars.Bars) do
        local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[index])

        if (bar) then
            bar.bar:SetMovable(value)
            bar.bar.overlay:SetHidden(not value)
        end
    end

    local frame = BS.lock or BS.CreateLockButton()

    if (value) then
        SCENE_MANAGER:Show("hudui")
        frame.fragment:SetHiddenForReason("disabled", false)
        SetGameCameraUIMode(true)
    else
        frame.fragment:SetHiddenForReason("disabled", true)
    end
end

local function updateTrackedAchiementCategories()
    local ids = BS.IsTracked()

    if (BS.TrackedCategories) then
        BS.LC.Clear(BS.TrackedCategories)
    else
        BS.TrackedCategories = {}
    end

    for id, _ in pairs(ids) do
        local topLevelIndex, categoryIndex = GetCategoryInfoFromAchievementId(id)

        if (not BS.TrackedCategories[topLevelIndex]) then
            BS.TrackedCategories[topLevelIndex] = {}
        end

        table.insert(BS.TrackedCategories[topLevelIndex], categoryIndex)
    end
end

function BS.IsTrackedCategory(topIndex, catIndex)
    if (not BS.TrackedCategories) then
        updateTrackedAchiementCategories()
    end

    if (catIndex) then
        if (BS.TrackedCategories[topIndex]) then
            return ZO_IsElementInNumericallyIndexedTable(BS.TrackedCategories[topIndex], catIndex)
        end
    else
        return BS.TrackedCategories[topIndex] ~= nil
    end
end

function BS.IsTracked(id)
    local ids = BS.Vars:GetCommon("AchievementTracking") or {}

    if (id) then
        return ids[id]
    else
        return ids
    end
end

function BS.SetTracked(id, track)
    local ids = BS.Vars:GetCommon("AchievementTracking") or {}

    if (track == false) then
        track = nil
    end

    ids[id] = track
    BS.Vars:SetCommon(ids, "AchievementTracking")
    updateTrackedAchiementCategories()
end

function BS.Track(self, id, track)
    BS.SetTracked(id, track)
    self:Show(id)
    _G.ACHIEVEMENTS:BuildCategories()
end

function BS.TrackAchievements()
    if (BS.Vars.Controls[BS.W_ACHIEVEMENT_TRACKER].Bar ~= 0) then
        -- luacheck: push ignore 112 113
        BS.OriginalAchievmentFunction = Achievement.OnClicked
        BS.OriginalApplyColour = ZO_Achievements_ApplyTextColorToLabel

        local trackedLabel = BS.LC.ZOSOrange:Colorize(BS.LC.Format(_G.SI_SCREEN_NARRATION_TRACKED_ICON_NARRATION))

        function ZO_Achievements_ApplyTextColorToLabel(label, ...)
            if (label:GetName():find("Title")) then
                local parent = label:GetParent()
                local id = parent.achievement.achievementId

                if (BS.IsTracked(id)) then
                    label:SetText(label:GetText() .. "  " .. trackedLabel)
                end
            end

            BS.OriginalApplyColour(label, ...)
        end

        local origAddCat = _G.ACHIEVEMENTS.AddCategory

        _G.ACHIEVEMENTS.AddCategory = function(self, lookup, tree, nodeTemplate, parent, categoryIndex, name, ...)
            if (parent) then
                local data = parent:GetData()

                if (BS.IsTrackedCategory(data.categoryIndex, categoryIndex)) then
                    name = name .. " " .. BS.LC.ZOSOrange:Colorize("*")
                end
            else
                if (BS.IsTrackedCategory(categoryIndex)) then
                    name = name .. " " .. BS.LC.ZOSOrange:Colorize("*")
                end
            end

            return origAddCat(self, lookup, tree, nodeTemplate, parent, categoryIndex, name, ...)
        end

        function Achievement:OnClicked(button)
            local id = self:GetId()
            local tracked = BS.IsTracked(id)
            local text = tracked and GetString(_G.BARSTEWARD_UNTRACK) or GetString(_G.BARSTEWARD_TRACK)

            if button == _G.MOUSE_BUTTON_INDEX_LEFT then
                self:ToggleCollapse()
                self:RefreshTooltip(self.control)
            elseif button == _G.MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() then
                ClearMenu()
                AddMenuItem(
                    GetString(_G.SI_ITEM_ACTION_LINK_TO_CHAT),
                    function()
                        ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, self:GetId()))
                    end
                )
                AddMenuItem(
                    text,
                    function()
                        local value = not tracked

                        if (value == false) then
                            ---@diagnostic disable-next-line: cast-local-type
                            value = nil
                        end

                        BS.Track(self, id, value)
                        BS.RefreshWidget(BS.W_ACHIEVEMENT_TRACKER)
                    end
                )
                ShowMenu(self.control)
            end

            BS.Tracking = true
        end
    -- luacheck: pop
    end
end

function BS.AchievementNotifier(id, checkAnnounce)
    local status = ACHIEVEMENTS_MANAGER:GetAchievementStatus(id)
    local name, _, _, icon = GetAchievementInfo(id)
    local announce = BS.GetVar("Announce", BS.W_ACHIEVEMENT_TRACKER) and checkAnnounce
    local stepsRemaining = 0
    local numCriteria = GetAchievementNumCriteria(id)
    local totalCriteria = numCriteria

    for criteria = 1, numCriteria do
        local _, completed, required = GetAchievementCriterion(id, criteria)

        if (completed ~= required) then
            stepsRemaining = stepsRemaining + (required - completed)
        end

        if (numCriteria == 1) then
            totalCriteria = required
        end
    end

    if (name) then
        name = zo_strformat(name)
    end

    if (announce and (status == _G.ZO_ACHIEVEMENTS_COMPLETION_STATUS.IN_PROGRESS)) then
        if (stepsRemaining > 0) then
            local message =
                ZO_CachedStrFormat(GetString(_G.BARSTEWARD_PROGRESS), BS.LC.Yellow:Colorize(name), stepsRemaining)

            BS.LC.ScreenAnnounce(BS.LC.Format(_G.BARSTEWARD_PROGRESS_ACHIEVEMENT), message, icon)
        end
    end

    return name, icon, stepsRemaining, totalCriteria
end

function BS.HideGoldenPursuitsDefaultUI()
    local gp = BS.W_GOLDEN_PURSUITS

    if (not IsPromotionalEventSystemLocked()) then
        if (BS.GetVar("Bar", gp) > 0) then
            if (BS.GetVar("HideDefault", gp)) then
                -- _G.PROMOTIONAL_EVENT_TRACKER:GetFragment():SetHiddenForReason(
                --     "BarStewardHidden",
                --     true,
                --     _G.DEFAULT_HUD_DURATION,
                --     _G.DEFAULT_HUD_DURATION
                -- )
                _G.PROMOTIONAL_EVENT_TRACKER:SetHidden(true)
            end
        end
    end
end

-- developer utility functions
-- luacheck: push ignore 113
function BS.FindItem(text)
    local filteredItems =
        SHARED_INVENTORY:GenerateFullSlotData(
        function(itemdata)
            local match = itemdata.name:find(text)

            return match ~= nil
        end,
        _G.BAG_BACKPACK
    )

    for _, item in ipairs(filteredItems) do
        d(item.name)
        d(item.bagId, item.slotIndex)
        d(GetItemId(item.bagId, item.slotIndex))
        d(GetItemType(item.bagId, item.slotIndex))
    end
end

function BS.FindAbility(text, start, finish)
    for abilityId = start, finish do
        local name = GetAbilityName(abilityId)

        if (name:find(text)) then
            d(abilityId)
            d(name)
        end
    end
end
-- luacheck: pop
