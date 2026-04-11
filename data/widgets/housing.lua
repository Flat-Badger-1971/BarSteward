local BS = BarSteward
local ALL_HOUSES = "icons/housing_ayl_duc_wayshrine001"

local function getPTFInfo(id)
    local ptfHouses = {}

    if (BS.PTF) then
        if ((not BS.PTFHouses) or BS.PTFRefreshRequired) then
            BS.PTFHouses = BS.PTF.GetFavorites()
        end

        for ptfId, ptfInfo in ipairs(BS.PTFHouses) do
            if (ptfInfo.houseId == id) then
                table.insert(ptfHouses, { name = ptfInfo.name, ptfId = ptfId })
            end
        end
    end

    return ptfHouses
end

local function encodeHouseKey(houseId, ptfId)
    if (ptfId) then
        return tostring(houseId) .. "_" .. tostring(ptfId)
    end

    return houseId
end

local function decodeHouseKey(houseKey)
    if (type(houseKey) == "string") then
        local houseId, ptfId = houseKey:match("^(%d+)_(%d+)$")

        if (houseId and ptfId) then
            return tonumber(houseId), tonumber(ptfId)
        end
    end

    return houseKey, nil
end

local function addPTFName(text, house)
    if (house.ptfName) then
        return string.format("%s (%s)", text, house.ptfName)
    end

    return text
end

local function getLegacyPTFId(houseId)
    if (not BS.houses) then
        return nil
    end

    for _, house in ipairs(BS.houses) do
        if (house.id == houseId and house.ptfId) then
            return house.ptfId
        end
    end
end

local function fixDuplicates(bindings)
    local assigned = {}

    for key, value in pairs(bindings) do
        if (value > BS.MAX_BINDINGS) then
            bindings[key] = nil
        end

        if (ZO_IsElementInNumericallyIndexedTable(assigned, value)) then
            local newValue = BS.LC.GetNextIndex(bindings)
            if (newValue <= BS.MAX_BINDINGS) then
                bindings[key] = newValue
                table.insert(assigned, newValue)
            end
        else
            table.insert(assigned, value)
        end
    end
end

function BS.GetHouses(ptfOnly)
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects()
    local houses = {}

    for _, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            local houseEntry = {
                icon = entry:GetIcon(),
                id = referenceId,
                location = entry:GetFormattedHouseLocation(),
                name = entry:GetFormattedName(),
                owned = not entry:IsLocked(),
                primary = entry:IsPrimaryResidence()
            }

            if (not ptfOnly) then
                table.insert(houses, houseEntry)
            end

            for _, ptfHouse in ipairs(getPTFInfo(referenceId)) do
                table.insert(
                    houses,
                    {
                        icon = houseEntry.icon,
                        id = houseEntry.id,
                        location = houseEntry.location,
                        name = houseEntry.name,
                        owned = houseEntry.owned,
                        primary = houseEntry.primary,
                        ptfName = ptfHouse.name,
                        ptfId = ptfHouse.ptfId
                    }
                )
            end
        end
    end

    table.sort(
        houses,
        function(a, b)
            return addPTFName(a.name, a) < addPTFName(b.name, b)
        end
    )

    return houses
end

function BS.GetHouseFromReferenceId(id, ptfId)
    for _, house in ipairs(BS.houses) do
        if (house.id == id and house.ptfId == ptfId) then
            return house
        end
    end
end

local function getHouseSettings(id, ptfId)
    local settingsId = 1000

    if (not ptfId) then
        local legacyId = 1000 + id
        local legacySettings = BS.Vars.Controls[legacyId]

        if (legacySettings) then
            return legacySettings, legacyId
        end
    end

    for settingId, settings in pairs(BS.Vars.Controls) do
        if (settingId > settingsId) then
            if (settings.Id == id) then
                if (ptfId) then
                    if (settings.PTF and settings.PTFId == ptfId) then
                        return settings, settingId
                    end
                elseif (not settings.PTF) then
                    return settings, settingId
                end
            end
        end
    end
end

local function getStoredHouseVarId(houseKey)
    local storedVarId = BS.Vars:GetCommon("HouseWidgets", houseKey)

    if (type(storedVarId) == "number" and BS.Vars.Controls[storedVarId]) then
        return storedVarId
    end
end

local function getHouseSettingsByKey(houseKey)
    local houseId, ptfId = decodeHouseKey(houseKey)
    local storedVarId = getStoredHouseVarId(houseKey)
    local vars, varId

    if (storedVarId) then
        vars = BS.Vars.Controls[storedVarId]
        varId = storedVarId
    else
        vars, varId = getHouseSettings(houseId, ptfId)
    end

    if (vars and vars.PTF and not ptfId) then
        ptfId = vars.PTFId or getLegacyPTFId(houseId)
    end

    return vars, varId, houseId, ptfId
end

function BS.AddHousingWidgets(idx, widgets)
    if (BS.Vars:GetCommon("HouseWidgets")) then
        BS.PTF = PortToFriend

        if (not BS.houses) then
            BS.houses = BS.GetHouses()
        end

        local bindings = BS.Vars:GetCommon("HouseBindings") or {}

        -- clear out unused bindings
        for houseKey, _ in pairs(bindings) do
            if (not getHouseSettingsByKey(houseKey)) then
                bindings[houseKey] = nil
            end
        end

        -- remove any duplicate binding values
        fixDuplicates(bindings)

        for houseKey, _ in pairs(BS.Vars:GetCommon("HouseWidgets")) do
            local vars, varId, houseId, ptfId = getHouseSettingsByKey(houseKey)
            local house = BS.GetHouseFromReferenceId(houseId, ptfId)

            if (vars and house) then
                if (vars.Bar == idx) then
                    if (idx > 0) then
                        local tooltip =
                            vars.Name .. BS.LF .. BS.COLOURS.White:Colorize(house.name .. BS.LF .. house.location)

                        if (house.ptfName) then
                            tooltip = tooltip .. BS.LF .. BS.COLOURS.ZOSGreen:Colorize(house.ptfName)
                        end

                        local widget = {
                            name = "house_" .. tostring(houseKey),
                            update = function(widget)
                                local colour = BS.GetColour(varId, true)

                                widget:SetColour(colour)
                                widget:SetValue(vars.Name, vars.RawName)
                            end,
                            tooltip = tooltip,
                            icon = house.icon,
                            onLeftClick = function()
                                if (house.ptfName and vars.PTF) then
                                    JumpToSpecificHouse(house.ptfName, house.id, false)
                                else
                                    RequestJumpToHouse(house.id, vars.Outside)
                                end
                            end,
                            id = varId
                        }

                        table.insert(widgets, { vars.Order, widget })
                        BS.widgets[varId] = widget
                    end

                    if (not bindings[houseKey]) then
                        bindings[houseKey] = BS.LC.GetNextIndex(bindings)
                        BS.Vars:SetCommon(bindings, "HouseBindings")
                    end

                    if (bindings[houseKey] < BS.MAX_BINDINGS) then
                        local stringId = "SI_BINDING_NAME_BARSTEWARD_KEYBIND_TOGGLE_HOUSE_" .. bindings[houseKey]
                        local bindingText = ZO_CachedStrFormat(BARSTEWARD_PORT_TO, addPTFName(house.name, house))

                        if (not _G[stringId]) then
                            ZO_CreateStringId(stringId, bindingText)
                        else
                            SafeAddString(_G[stringId], bindingText, 1)
                        end
                    end
                end
            end
        end
    end
end

function BS.PortToHouse(index)
    local houseKey = BS.LC.GetByValue(BS.Vars:GetCommon("HouseBindings"), index)

    if (not houseKey) then
        return
    end

    if (not BS.houses) then
        BS.houses = BS.GetHouses()
    end

    local vars, _, houseId, ptfId = getHouseSettingsByKey(houseKey)
    local house = BS.GetHouseFromReferenceId(houseId, ptfId)

    if (not vars or not house) then
        return
    end

    if (house.ptfName and vars.PTF) then
        JumpToSpecificHouse(house.ptfName, house.id, false)
    else
        RequestJumpToHouse(house.id, vars.Outside)
    end
end

local function getHouseWidgetName()
    local widgetName, rawName
    local house = BS.houses[BS.House_SelectedHouse]

    if (BS.House_ShowLocationOnly) then
        widgetName = house.location
    elseif (BS.House_ShowLocationToo) then
        widgetName = house.name .. " - " .. house.location
    else
        widgetName = house.name
    end

    widgetName = addPTFName(widgetName, house)
    rawName = widgetName

    if (house.ptfName) then
        widgetName = widgetName .. " " .. BS.Icon(BS.FRIENDS_ICON)
        rawName = rawName .. " XX"
    end

    return widgetName, rawName
end

local function getNextAvailableHouseIndex()
    local index = 1001

    while (BS.Vars.Controls[index]) do
        index = index + 1
    end

    return index
end

local function addHouseWidget()
    if ((BS.House_SelectedHouse or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmptyGeneric")
        return
    end

    local houseWidgets = BS.Vars:GetCommon("HouseWidgets") or {}
    local house = BS.houses[BS.House_SelectedHouse]
    local houseKey = encodeHouseKey(house.id, house.ptfId)

    if (houseWidgets[houseKey]) then
        ZO_Dialogs_ShowDialog(BS.Name .. "ExistsGeneric")
        return
    end

    local name, rawName = getHouseWidgetName()
    local nextIndex = getNextAvailableHouseIndex()
    local ptfHouse = house.ptfName ~= nil

    BS.Vars.Controls[nextIndex] = {
        Bar = 0,
        Order = 1000 + house.id,
        ColourValues = "c",
        Name = name,
        RawName = rawName,
        Id = house.id,
        PTF = ptfHouse,
        PTFId = house.ptfId
    }

    houseWidgets[houseKey] = nextIndex
    BS.Vars:SetCommon(houseWidgets, "HouseWidgets")

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
end

local function addSubmenu(barNames, vars, varId, house, houseKey, controls)
    local submenuControls = {
        [1] = {
            type = "dropdown",
            name = GetString(BARSTEWARD_BAR),
            choices = barNames,
            getFunc = function()
                local barName = BS.LC.Format(SI_DAMAGETYPE0)

                if (vars.Bar ~= 0) then
                    barName = BS.Vars.Bars[vars.Bar].Name
                end

                return barName
            end,
            setFunc = function(value)
                local tbars = BS.Vars.Bars
                local barNum = 0

                for bnum, bdata in ipairs(tbars) do
                    if (bdata.Name == value) then
                        barNum = bnum
                    end
                end

                local oldBarNum = BS.Vars.Controls[varId].Bar

                vars.Bar = barNum
                BS.RegenerateBar(oldBarNum, varId)
                BS.RegenerateBar(barNum)
            end,
            width = "full",
            default = 0
        },
        [2] = {
            type = "colorpicker",
            name = GetString(BARSTEWARD_DEFAULT_COLOUR),
            getFunc = function()
                return unpack(vars.Colour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                vars.Colour = { r, g, b, a }
                BS.RefreshWidget(varId)
            end,
            width = "full",
            default = unpack(BS.Vars.DefaultColour)
        },
        [3] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_HIDE_WIDGET_ICON),
            getFunc = function()
                return vars.NoIcon or false
            end,
            setFunc = function(value)
                vars.NoIcon = value
                BS.RefreshWidget(varId, true)
            end,
            width = "full",
            default = false,
            requiresReload = true
        },
        [4] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return vars.NoValue or false
            end,
            setFunc = function(value)
                vars.NoValue = value
                BS.GetWidget(varId):SetNoValue(value)
                BS.RegenerateBar(BS.Vars.Controls[varId].Bar, varId)
            end,
            width = "full",
            default = false
        }
    }

    if (house) then
        if (house.ptfName == nil) then
            submenuControls[#submenuControls + 1] = {
                type = "checkbox",
                name = BS.LC.Format(SI_HOUSING_BOOK_ACTION_TRAVEL_TO_HOUSE_OUTSIDE),
                getFunc = function()
                    return vars.Outside
                end,
                setFunc = function(value)
                    vars.Outside = value
                end,
                width = "full",
                default = false,
                disabled = function()
                    return house.ptfName ~= nil
                end
            }
        end
    end

    submenuControls[#submenuControls + 1] = {
        type = "editbox",
        name = GetString(BARSTEWARD_CHANGE),
        getFunc = function()
            local name = vars.Name

            name = name:gsub("(%s+[|]t.+[|]t)", "")
            return name
        end,
        setFunc = function(value)
            vars.RawName = value

            if (vars.Name:find("|t")) then
                value = value .. " " .. BS.Icon(BS.FRIENDS_ICON)
                vars.RawName = vars.RawName .. " XX"
            end

            vars.Name = value

            if (vars.Bar ~= 0) then
                BS.RefreshWidget(varId)
            end
        end,
        isMultiLine = false,
        width = "half"
    }

    submenuControls[#submenuControls + 1] = {
        type = "button",
        name = GetString(BARSTEWARD_GENERIC_REMOVE),
        tooltip = GetString(BARSTEWARD_GENERIC_REMOVE_WARNING),
        func = function()
            BS.Vars.Controls[varId] = nil
            BS.Vars:SetCommon(nil, "HouseWidgets", houseKey)
            BS.Vars:SetCommon(nil, "HouseBindings", houseKey)

            ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
        end,
        requiresReload = true,
        width = "full"
    }

    local icon = house and house.icon or ALL_HOUSES

    controls[#controls + 1] = {
        type = "submenu",
        name = vars.Name,
        controls = submenuControls,
        icon = BS.FormatIcon(icon),
        reference = "house_submenu" .. tostring(houseKey)
    }
end

function BS.GetPortToHouseSettings()
    BS.houses = BS.GetHouses()

    local choices = {}
    local choicesValues = {}

    for index, house in ipairs(BS.houses) do
        if (house.ptfName or house.owned) then
            table.insert(choices, addPTFName(house.name .. " - " .. house.location, house))
            table.insert(choicesValues, index)
        end
    end

    local controls = {
        [1] = {
            type = "description",
            text = GetString(BARSTEWARD_PORT_TO_HOUSE_DESCRIPTION) ..
                ". " .. GetString(BARSTEWARD_PORT_TO_HOUSE_PTF_INFO),
            width = "full"
        }
    }

    if (PortToFriend) then
        local ptfIcon = BS.Icon(BS.FRIENDS_ICON)
        local ptfText = BS.COLOURS.ZOSGreen:Colorize(zo_strformat(GetString(BARSTEWARD_PORT_TO_HOUSE_PTF), ptfIcon))
        controls[#controls + 1] = {
            type = "description",
            text = ptfText,
            width = "full"
        }
    end

    controls[#controls + 1] = {
        type = "dropdown",
        name = GetString(BARSTEWARD_PORT_TO_HOUSE_SELECT),
        choices = choices,
        choicesValues = choicesValues,
        scrollable = true,
        getFunc = function()
            return BS.House_SelectedHouse
        end,
        setFunc = function(value)
            BS.House_SelectedHouse = value
        end,
        width = "full"
    }

    controls[#controls + 1] = {
        type = "checkbox",
        name = GetString(BARSTEWARD_PORT_TO_HOUSE_LOCATION_ONLY),
        getFunc = function()
            return BS.House_ShowLocationOnly
        end,
        setFunc = function(value)
            BS.House_ShowLocationOnly = value

            if (value) then
                BS.House_ShowLocationToo = false
            end
        end,
        width = "full"
    }

    controls[#controls + 1] = {
        type = "checkbox",
        name = GetString(BARSTEWARD_PORT_TO_HOUSE_LOCATION_TOO),
        getFunc = function()
            return BS.House_ShowLocationToo
        end,
        setFunc = function(value)
            BS.House_ShowLocationToo = value

            if (value) then
                BS.House_ShowLocationOnly = false
            end
        end,
        width = "full"
    }

    controls[#controls + 1] = {
        type = "description",
        text = GetString(BARSTEWARD_PORT_TO_HOUSE_PREVIEW),
        width = "full"
    }

    controls[#controls + 1] = {
        type = "description",
        text = function()
            local text = ""
            local icon = ""

            if (BS.House_SelectedHouse) then
                local selectedHouse = BS.houses[BS.House_SelectedHouse]
                icon = BS.Icon(selectedHouse.icon, nil, 32, 32) .. " "
                text = getHouseWidgetName()
            end

            return icon .. text
        end,
        width = "full",
        reference = "BarSteward_HousePreview"
    }

    controls[#controls + 1] = {
        type = "button",
        name = GetString(BARSTEWARD_ADD_WIDGET),
        func = addHouseWidget,
        width = "full",
        requiresReload = true,
        disabled = function()
            return not BS.House_SelectedHouse
        end
    }

    local addedHouses = BS.Vars:GetCommon("HouseWidgets")

    if (addedHouses) then
        local bars = BS.Vars.Bars
        local none = GetString(BARSTEWARD_NONE_BAR)
        local barNames = {}

        for _, v in ipairs(bars) do
            table.insert(barNames, v.Name)
        end

        table.insert(barNames, none)

        -- sort the houses by name
        local sortedHouses = {}

        for houseKey, _ in pairs(addedHouses) do
            local vars, varId, houseId, ptfId = getHouseSettingsByKey(houseKey)

            if (vars and varId) then
                table.insert(sortedHouses, {
                    house = BS.GetHouseFromReferenceId(houseId, ptfId),
                    houseKey = houseKey,
                    varId = varId,
                    vars = vars
                })
            end
        end

        table.sort(
            sortedHouses,
            function(a, b)
                return a.vars.RawName < b.vars.RawName
            end
        )

        for _, houseInfo in ipairs(sortedHouses) do
            addSubmenu(barNames, houseInfo.vars, houseInfo.varId, houseInfo.house, houseInfo.houseKey, controls)
        end
    end

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(BARSTEWARD_PORT_TO_HOUSE),
        controls = controls,
        reference = "BarStewardPortToHouse",
        icon = "/esoui/art/icons/poi/poi_group_house_glow.dds"
    }
end
