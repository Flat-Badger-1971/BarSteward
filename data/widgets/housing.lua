local BS = _G.BarSteward
local ALL_HOUSES = "icons/housing_ayl_duc_wayshrine001"

local function getPTFInfo(id)
    if (BS.PTF) then
        if ((not BS.PTFHouses) or BS.PTFRefreshRequired) then
            BS.PTFHouses = BS.PTF.GetFavorites()
        end

        for _, ptfInfo in ipairs(BS.PTFHouses) do
            if (ptfInfo.houseId == id) then
                return ptfInfo.name
            end
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

function BS.GetHouses()
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects()
    local houses = {}

    for _, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            local ptfName = getPTFInfo(referenceId)
            local houseEntry = {
                icon = entry:GetIcon(),
                id = referenceId,
                location = entry:GetFormattedHouseLocation(),
                name = entry:GetFormattedName(),
                owned = not entry:IsLocked(),
                primary = entry:IsPrimaryResidence(),
                ptfName = ptfName
            }

            table.insert(houses, houseEntry)
        end
    end

    table.sort(
        houses,
        function(a, b)
            return a.name < b.name
        end
    )

    return houses
end

function BS.GetHouseFromReferenceId(id)
    for _, house in ipairs(BS.houses) do
        if (house.id == id) then
            return house
        end
    end
end

function BS.AddHousingWidgets(idx, widgets)
    if (BS.Vars:GetCommon("HouseWidgets")) then
        BS.PTF = _G.PortToFriend

        if (not BS.houses) then
            BS.houses = BS.GetHouses()
        end

        local bindings = BS.Vars:GetCommon("HouseBindings") or {}

        -- clear out unused bindings
        for id, _ in pairs(bindings) do
            if (not BS.Vars.Controls[1000 + id]) then
                bindings[id] = nil
            end
        end

        -- remove any duplicate binding values
        fixDuplicates(bindings)

        for id, _ in pairs(BS.Vars:GetCommon("HouseWidgets")) do
            local varId = 1000 + id
            local house = BS.GetHouseFromReferenceId(id)
            local vars = BS.Vars.Controls[varId]

            if (vars) then
                if (BS.Vars.Controls[varId].Bar == idx) then
                    if (idx > 0) then
                        local tooltip =
                            vars.Name .. BS.LF .. BS.LC.White:Colorize(house.name .. BS.LF .. house.location)

                        local widget = {
                            name = "house_" .. id,
                            update = function(widget)
                                local colour = BS.GetColour(varId, true)

                                widget:SetColour(colour)
                                widget:SetValue(vars.Name, vars.RawName)
                            end,
                            tooltip = tooltip,
                            icon = house.icon,
                            onLeftClick = function()
                                if (house.ptfName) then
                                    JumpToSpecificHouse(house.ptfName, id)
                                else
                                    RequestJumpToHouse(id, vars.Outside)
                                end
                            end,
                            id = varId
                        }

                        table.insert(widgets, {BS.Vars.Controls[varId].Order, widget})
                        BS.widgets[varId] = widget
                    end

                    if (not bindings[id]) then
                        bindings[id] = BS.LC.GetNextIndex(bindings)
                        BS.Vars:SetCommon(bindings, "HouseBindings")
                    end

                    if (bindings[id] < BS.MAX_BINDINGS) then
                        ZO_CreateStringId(
                            "SI_BINDING_NAME_BARSTEWARD_KEYBIND_TOGGLE_HOUSE_" .. bindings[id],
                            ZO_CachedStrFormat(_G.BARSTEWARD_TOGGLE, house.name)
                        )
                    end
                end
            end
        end
    end
end

function BS.PortToHouse(index)
    local id = BS.LC.GetByValue(BS.Vars:GetCommon("HouseBindings"), index)

    if (not id) then
        return
    end

    if (not BS.houses) then
        BS.houses = BS.GetHouses()
    end

    local house = BS.GetHouseFromReferenceId(id)
    local vars = BS.Vars.Controls[1000 + id]

    if (house.ptfName) then
        JumpToSpecificHouse(house.ptfName, id)
    else
        RequestJumpToHouse(id, vars.Outside)
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

    rawName = widgetName

    if (house.ptfName) then
        widgetName = widgetName .. " " .. BS.Icon(BS.FRIENDS_ICON)
        rawName = rawName .. " XX"
    end

    return widgetName, rawName
end

local function addHouseWidget()
    if ((BS.House_SelectedHouse or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmptyGeneric")
        return
    end

    local houseWidgets = BS.Vars:GetCommon("HouseWidgets") or {}
    local house = BS.houses[BS.House_SelectedHouse]

    for houseId, _ in pairs(houseWidgets) do
        if (houseId == house.id) then
            ZO_Dialogs_ShowDialog(BS.Name .. "ExistsGeneric")
            return
        end
    end

    local name, rawName = getHouseWidgetName()

    BS.Vars.Controls[1000 + house.id] = {
        Bar = 0,
        Order = 1000 + house.id,
        ColourValues = "c",
        Name = name,
        RawName = rawName
    }

    houseWidgets[house.id] = true
    BS.Vars:SetCommon(houseWidgets, "HouseWidgets")

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
end

local function addSubmenu(barNames, vars, varId, house, id, controls)
    local submenuControls = {
        [1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_BAR),
            choices = barNames,
            getFunc = function()
                local barName = BS.LC.Format(_G.SI_DAMAGETYPE0)

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
            name = GetString(_G.BARSTEWARD_DEFAULT_COLOUR),
            getFunc = function()
                return unpack(vars.Colour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                vars.Colour = {r, g, b, a}
                BS.RefreshWidget(varId)
            end,
            width = "full",
            default = unpack(BS.Vars.DefaultColour)
        },
        [3] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WIDGET_ICON),
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
            name = GetString(_G.BARSTEWARD_HIDE_TEXT),
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
                name = BS.LC.Format(_G.SI_HOUSING_BOOK_ACTION_TRAVEL_TO_HOUSE_OUTSIDE),
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

    if (id < 1999) then
        submenuControls[#submenuControls + 1] = {
            type = "editbox",
            name = GetString(_G.BARSTEWARD_CHANGE),
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
                    BS.RefreshWidget(1000 + id)
                end
            end,
            isMultiLine = false,
            width = "half"
        }

        submenuControls[#submenuControls + 1] = {
            type = "button",
            name = GetString(_G.BARSTEWARD_GENERIC_REMOVE),
            tooltip = GetString(_G.BARSTEWARD_GENERIC_REMOVE_WARNING),
            func = function()
                BS.Vars.Controls[1000 + id] = nil
                BS.Vars:SetCommon(nil, "HouseWidgets", id)
                BS.Vars:SetCommon(nil, "HouseBindings", id)

                ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
            end,
            requiresReload = true,
            width = "full"
        }
    end

    local icon = house and BS.GetHouseFromReferenceId(id).icon or ALL_HOUSES

    controls[#controls + 1] = {
        type = "submenu",
        name = vars.Name,
        controls = submenuControls,
        icon = BS.FormatIcon(icon),
        reference = "house_submenu" .. id
    }
end

function BS.GetPortToHouseSettings()
    BS.houses = BS.GetHouses()

    local choices = {}
    local choicesValues = {}

    for index, house in ipairs(BS.houses) do
        if (house.ptfName or house.owned) then
            table.insert(choices, house.name .. " - " .. house.location)
            table.insert(choicesValues, index)
        end
    end

    local controls = {
        [1] = {
            type = "description",
            text = GetString(_G.BARSTEWARD_PORT_TO_HOUSE_DESCRIPTION) ..
                ". " .. GetString(_G.BARSTEWARD_PORT_TO_HOUSE_PTF_INFO),
            width = "full"
        }
    }

    if (_G.PortToFriend) then
        local ptfIcon = BS.Icon(BS.FRIENDS_ICON)
        local ptfText = BS.LC.ZOSGreen:Colorize(zo_strformat(GetString(_G.BARSTEWARD_PORT_TO_HOUSE_PTF), ptfIcon))
        controls[#controls + 1] = {
            type = "description",
            text = ptfText,
            width = "full"
        }
    end

    controls[#controls + 1] = {
        type = "dropdown",
        name = GetString(_G.BARSTEWARD_PORT_TO_HOUSE_SELECT),
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
        name = GetString(_G.BARSTEWARD_PORT_TO_HOUSE_LOCATION_ONLY),
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
        name = GetString(_G.BARSTEWARD_PORT_TO_HOUSE_LOCATION_TOO),
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
        text = GetString(_G.BARSTEWARD_PORT_TO_HOUSE_PREVIEW),
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
        name = GetString(_G.BARSTEWARD_ADD_WIDGET),
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
        local none = GetString(_G.BARSTEWARD_NONE_BAR)
        local barNames = {}

        for _, v in ipairs(bars) do
            table.insert(barNames, v.Name)
        end

        table.insert(barNames, none)

        -- sort the houses by name
        local sortedHouses = {}

        for id, _ in pairs(addedHouses) do
            if (BS.Vars.Controls[1000 + id]) then
                table.insert(sortedHouses, id)
            end
        end

        table.sort(
            sortedHouses,
            function(a, b)
                local houseNameA = BS.Vars.Controls[1000 + a].RawName
                local houseNameB = BS.Vars.Controls[1000 + b].RawName

                return houseNameA < houseNameB
            end
        )

        for _, id in ipairs(sortedHouses) do
            local varId = 1000 + id
            local vars = BS.Vars.Controls[varId]
            local house = BS.GetHouseFromReferenceId(id)

            addSubmenu(barNames, vars, varId, house, id, controls)
        end
    end

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_PORT_TO_HOUSE),
        controls = controls,
        reference = "BarStewardPortToHouse",
        icon = "/esoui/art/icons/poi/poi_group_house_glow.dds"
    }
end
