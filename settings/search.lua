local BS = _G.BarSteward
local lookup, results = {}, {}

local function createLookup()
    if (#lookup > 0) then
        ZO_ClearNumericallyIndexedTable(lookup)
    end

    local arrow = BS.Icon("buttons/large_rightarrow_up", nil, 32, 32)

    for index, defaults in pairs(BS.Defaults.Controls) do
        local tt = BS.widgets[index].tooltip
        local icon = BS.widgets[index].icon

        if (type(tt) == "function") then
            tt = tt()
        end

        if (type(icon) == "function") then
            icon = icon()
        end

        local category = GetString(BS.CATEGORIES[defaults.Cat].name)

        table.insert(
            lookup,
            {
                widget = string.format("%s %s %s", category, arrow, tt),
                icon = icon,
                category = defaults.Cat,
                rawname = tt:lower(),
                id = index
            }
        )
    end
end

local function alreadyAdded(data)
    for _, widget in ipairs(results) do
        if (widget.rawname == data.rawname) then
            return true
        end
    end

    return false
end

local function search(text)
    ZO_ClearNumericallyIndexedTable(results)

    for _, info in ipairs(lookup) do
        if (info.rawname:find(text:lower())) then
            if (not alreadyAdded(info)) then
                table.insert(results, info)
            end
        end
    end

    return results
end

local function widgetSortFunction(a, b)
    return a.data.widget < b.data.widget
end

local function updateList(res)
    local dataItems = {}

    for index, widget in ipairs(res) do
        dataItems[index] = {
            widget = widget.widget,
            icon = widget.icon,
            category = widget.category,
            id = widget.id
        }
    end

    return dataItems
end

local function contractSubmenus()
    -- probably overkill, but keeps thinks clean
    local submenus = {"BarStewardPerformance", "BarStewardMaintenance", "BarStewardSearch", "BarStewardPortToHouse"}

    for widget, _ in pairs(BS.Defaults.Controls) do
        local submenu = string.format("BarStewardWidget_%s", widget)

        table.insert(submenus, submenu)
    end

    for category, _ in pairs(BS.CATEGORIES) do
        local submenu = string.format("BarStewardCategory_%s", category)

        table.insert(submenus, submenu)
    end

    for bar, _ in pairs(BS.Vars.Bars) do
        local submenu = string.format("BarStewardBar_%s", bar)

        table.insert(submenus, submenu)
    end

    for _, submenu in ipairs(submenus) do
        local menu = _G[submenu]

        if (menu) then
            menu.open = false
            menu.animation:PlayFromStart()
        end
    end
end

local function setupDataRow(rowControl, data)
    local icon = data.icon
    local title = rowControl:GetNamedChild("Title")

    title:SetWidth(rowControl:GetParent():GetWidth())
    title:SetText(BS.LC.ToSentenceCase(data.widget))

    rowControl:GetNamedChild("Icon"):SetTexture(BS.FormatIcon(icon))
    rowControl.data = data

    rowControl:SetHandler(
        "OnMouseDoubleClick",
        function(self)
            local container = _G.BarStewardOptionsPanel.container

            contractSubmenus()

            local category = _G["BarStewardCategory_" .. self.data.category]
            local widget = _G["BarStewardWidget_" .. self.data.id]

            if (not category.open) then
                category.open = true
                category.animation:PlayFromEnd()
            end

            if (not widget.open) then
                widget.open = true
                widget.animation:PlayFromEnd()
            end

            -- wait for animations to finish
            zo_callLater(
                function()
                    ZO_Scroll_ScrollControlIntoCentralView(container, category)
                end,
                600
            )
        end
    )
end

local function createScrollList(parent)
    local scrollData = {
        name = "BarStewardSearchList",
        parent = parent,
        width = parent:GetWidth() - 20,
        height = 300,
        rowHeight = 36,
        rowTemplate = "BarSteward_Search_Template",
        setupCallback = setupDataRow,
        sortFunction = widgetSortFunction
    }
    local scrollList = BS.CreateScrollList(scrollData)

    return scrollList
end

local function createSearchControl(parent)
    local font = "$(MEDIUM_FONT)|18"

    parent.label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    parent.label:SetAnchor(TOPLEFT)
    parent.label:SetText(BS.LC.Format(SI_GAMEPAD_HELP_SEARCH_PROMPT))
    parent.label:SetDimensions(parent:GetWidth(), 20)
    parent.label:SetFont(font)

    parent.searchText = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_DefaultEditForBackdrop")
    parent.searchText:SetAnchor(TOPLEFT, parent.label, BOTTOMLEFT, 0, 10)
    parent.searchText:SetAnchor(BOTTOMRIGHT, parent.label, BOTTOMLEFT, 200, 38)
    parent.searchText:SetFont(font)
    parent.searchText:SetMaxInputChars(50)
    parent.searchText:SetHandler(
        "OnTextChanged",
        function(control)
            local text = control:GetText()

            if (text:len() > 0) then
                local r = search(text)
                local dataItems = updateList(r)

                parent.scrollList:Update(dataItems)

                if (parent.scrollList:IsHidden()) then
                    parent.scrollList:SetHidden(false)
                    parent:SetResizeToFitDescendents(false)
                    parent:SetResizeToFitDescendents(true)
                end
            else
                parent.scrollList:Clear()
                parent.scrollList:SetHidden(true)
                parent:SetResizeToFitDescendents(false)
                parent:SetResizeToFitDescendents(true)
            end
        end
    )

    parent.searchText.bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent.searchText, "ZO_EditBackdrop")
    parent.searchText.bg:SetAnchorFill()

    parent.scrollList = createScrollList(parent)
    parent.scrollList:SetAnchor(TOPLEFT, parent.searchText, BOTTOMLEFT, 0, 40)
    parent.scrollList:SetDimensions(parent:GetWidth() - 10, 300)
    parent.scrollList:SetHidden(true)
    parent:SetResizeToFitDescendents(true)

    parent.hint = WINDOW_MANAGER:CreateControl(nil, parent.scrollList, CT_LABEL)
    parent.hint:SetAnchor(TOPLEFT, parent.scrollList, TOPLEFT, 0, -30)
    parent.hint:SetText(GetString(_G.BARSTEWARD_DOUBLE_CLICK))
    parent.hint:SetDimensions(parent:GetWidth(), 20)
    parent.hint:SetFont("$(MEDIUM_FONT)|14")
end

function BS.AddSearch()
    createLookup()

    local searchControl = {
        [1] = {
            type = "custom",
            createFunc = createSearchControl,
            minHeight = 100,
            maxHeight = 300,
            width = "full"
        }
    }

    local searchSub = {
        type = "submenu",
        name = BS.LC.Format(SI_GAMECAMERAACTIONTYPE1),
        icon = "esoui/art/miscellaneous/search_icon.dds",
        controls = searchControl,
        reference = "BarStewardSearch"
    }

    return searchSub
end
