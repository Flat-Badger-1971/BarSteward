local BS = _G.BarSteward

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
    if (BS.Vars.HouseWidgets) then
        BS.PTF = _G.PortToFriend

        if (not BS.houses) then
            BS.houses = BS.GetHouses()
        end

        local bindings = BS.Vars.HouseBindings or {}

        for id, active in pairs(BS.Vars.HouseWidgets) do
            if (active) then
                local house = BS.GetHouseFromReferenceId(id)
                local vars = BS.Vars.Controls[1000 + id]

                if (BS.Vars.Controls[1000 + id].Bar == idx) then
                    local tooltip = vars.Name .. BS.LF .. "|cf9f9f9"

                    tooltip = tooltip .. house.name .. BS.LF
                    tooltip = tooltip .. house.location .. "|r"

                    local widget = {
                        name = "house_" .. id,
                        update = function(widget)
                            local colour = BS.Vars.Controls[1000 + id].Colour or BS.Vars.DefaultColour

                            widget:SetColour(unpack(colour))
                            widget:SetValue(vars.Name, vars.RawName)
                        end,
                        tooltip = tooltip,
                        icon = house.icon,
                        onClick = function()
                            if (house.ptfName) then
                                JumpToSpecificHouse(house.ptfName, id)
                            else
                                RequestJumpToHouse(id, vars.Outside)
                            end
                        end,
                        id = 1000 + id
                    }

                    table.insert(widgets, {BS.Vars.Controls[1000 + id].Order, widget})
                    BS.widgets[1000 + id] = widget

                    if (not bindings[id]) then
                        bindings[id] = BS.GetNextIndex(bindings)
                        BS.Vars.HouseBindings = bindings
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
    local id = BS.GetByValue(BS.Vars.HouseBindings, index)

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
        widgetName = widgetName .. " " .. zo_iconFormat(BS.FRIENDS_ICON, 16, 16)
        rawName = rawName .. " XX"
    end

    return widgetName, rawName
end

local function addHouseWidget()
    if ((BS.House_SelectedHouse or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmptyGeneric")
        return
    end

    local houseWidgets = BS.Vars.HouseWidgets or {}
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
    BS.Vars.HouseWidgets = houseWidgets

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
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
        local ptfIcon = zo_iconFormat(BS.FRIENDS_ICON, 16, 16)
        local ptfText = "|c00994c" .. zo_strformat(GetString(_G.BARSTEWARD_PORT_TO_HOUSE_PTF), ptfIcon) .. "|r"

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
                icon = zo_iconFormat(selectedHouse.icon, 32, 32) .. " "
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

    local addedHouses = BS.Vars.HouseWidgets

    if (addedHouses) then
        local bars = BS.Vars.Bars
        local none = GetString(_G.BARSTEWARD_NONE_BAR)
        local barNames = {}

        for _, v in ipairs(bars) do
            table.insert(barNames, v.Name)
        end

        table.insert(barNames, none)

        for id, _ in pairs(addedHouses) do
            local varId = 1000 + id
            local vars = BS.Vars.Controls[varId]
            local house = BS.GetHouseFromReferenceId(id)
            local submenuControls = {
                [1] = {
                    type = "dropdown",
                    name = GetString(_G.BARSTEWARD_BAR),
                    choices = barNames,
                    getFunc = function()
                        local barName = BS.Format(_G.SI_DAMAGETYPE0)

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

                        vars.Bar = barNum
                    end,
                    width = "full",
                    requiresReload = true,
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
                }
            }

            if (house.ptfName == nil) then
                submenuControls[#submenuControls + 1] = {
                    type = "checkbox",
                    name = BS.Format(_G.SI_HOUSING_BOOK_ACTION_TRAVEL_TO_HOUSE_OUTSIDE),
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

            submenuControls[#submenuControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_CHANGE),
                getFunc = function()
                    local name = vars.Name

                    name = string.gsub(name, "(%s+[|]t.+[|]t)", "")
                    return name
                end,
                setFunc = function(value)
                    vars.RawName = value

                    if (string.find(vars.Name, "|t")) then
                        value = value .. " " .. zo_iconFormat(BS.FRIENDS_ICON, 16, 16)
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
                    BS.Vars.HouseWidgets[id] = nil
                    BS.Vars.HouseBindings[id] = nil

                    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
                end,
                requiresReload = true,
                width = "full"
            }

            controls[#controls + 1] = {
                type = "submenu",
                name = vars.Name,
                controls = submenuControls,
                icon = BS.GetHouseFromReferenceId(id).icon,
                reference = "house_submenu" .. id
            }
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
