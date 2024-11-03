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

        local words = BS.LC.Split(tt, " ")
        local category = GetString(BS.CATEGORIES[defaults.Cat].name)

        for _, word in pairs(words) do
            table.insert(
                lookup,
                {word = word:lower(), widget = string.format("%s %s %s", category, arrow, tt), icon = icon}
            )
        end
    end
end

local function alreadyAdded(data)
    for _, widget in ipairs(results) do
        if (widget.widget == data.widget) then
            return true
        end
    end

    return false
end

local function search(text)
    ZO_ClearNumericallyIndexedTable(results)
    local distance

    for _, info in ipairs(lookup) do
        if (text:find(" ")) then
            -- multiple words
            local words = BS.LC.Split(text, " ")
            local tempdistance, count = 0, 0

            for _, word in ipairs(words) do
                if (BS.LC.Trim(word):len() > 2) then
                    local d = BS.LC.Distance(info.word, word:lower())

                    if (d < 3) then
                        tempdistance = tempdistance + d
                        count = count + 1
                    end
                end
            end

            if (count > 0) then
                distance = tempdistance / count
            else
                distance = 99
            end
        else
            distance = BS.LC.Distance(info.word, text:lower())
        end

        if (distance < 3) then
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
    local itemKey = 1

    for key, widget in ipairs(res) do
        dataItems[itemKey] = {
            widget = widget.widget,
            icon = widget.icon,
            key = key
        }
        itemKey = itemKey + 1
    end

    return dataItems
end

local function setupDataRow(rowControl, data)
    local icon = data.icon
    local title = rowControl:GetNamedChild("Title")

    title:SetWidth(rowControl:GetParent():GetWidth())
    title:SetText(BS.LC.ToSentenceCase(data.widget))

    rowControl:GetNamedChild("Icon"):SetTexture(BS.FormatIcon(icon))
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
    parent.label:SetText(BS.LC.Format(_G.SI_GAMEPAD_HELP_SEARCH_PROMPT))
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

            if (text:len() > 2) then
                local r = search(text)
                local dataItems = updateList(r)

                parent.scrollList:Update(dataItems)
            else
                parent.scrollList:Clear()
            end
        end
    )

    parent.searchText.bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent.searchText, "ZO_EditBackdrop")
    parent.searchText.bg:SetAnchorFill()

    parent.scrollList = createScrollList(parent)
    parent.scrollList:SetAnchor(TOPLEFT, parent.searchText, BOTTOMLEFT, 0, 20)
    parent.scrollList:SetDimensions(parent:GetWidth() - 10, 300)
end

function BS.AddSearch()
    createLookup()

    local searchControl = {
        [1] = {
            type = "custom",
            reference = "BS_Search",
            createFunc = createSearchControl,
            --refreshFunc=function(control)end,
            minHeight = 100,
            maxHeight = 300,
            width = "full"
        }
    }

    local searchSub = {
        type = "submenu",
        name = BS.LC.Format(_G.SI_GAMECAMERAACTIONTYPE1),
        icon = "esoui/art/miscellaneous/search_icon.dds",
        controls = searchControl
    }

    return searchSub
end
