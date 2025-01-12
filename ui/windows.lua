local BS = _G.BarSteward

function BS.CreateAlignmentFrame(alignBars)
    local name = BS.Name .. "_alignment"
    BS.frame = WINDOW_MANAGER:CreateTopLevelWindow(name)

    local frame = BS.frame
    frame:SetDimensions(450, 700)
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)

    frame.bgc = WINDOW_MANAGER:CreateControl(name .. "_background", frame, CT_TEXTURE)
    frame.bgc:SetAnchorFill(frame)
    frame.bgc:SetTexture("/esoui/art/miscellaneous/centerscreen_left.dds")

    frame.bge = WINDOW_MANAGER:CreateControl(name .. "_edges", frame, CT_TEXTURE)
    frame.bge:SetDimensions(24, frame:GetHeight())
    frame.bge:SetAnchor(TOPLEFT, frame.bgc, TOPRIGHT)
    frame.bge:SetTexture("esoui/art/miscellaneous/centerscreen_right.dds")

    local fontSize = 24
    local fontStyle = "${BOLD_FONT}"
    local fontWeight = "soft-shadow-thick"
    local nameFont = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)

    frame.heading = WINDOW_MANAGER:CreateControl(name .. "_heading", frame, CT_LABEL)
    frame.heading:SetFont(nameFont)
    frame.heading:SetColor(0.9, 0.9, 0.9, 1)
    frame.heading:SetAnchor(TOPLEFT, frame, TOPLEFT, 50, 80)
    frame.heading:SetText(GetString(_G.BARSTEWARD_BAR_ALIGN))
    frame.heading:SetDimensions(350)

    frame.divider = WINDOW_MANAGER:CreateControl(name .. "_divider", frame, CT_TEXTURE)
    frame.divider:SetDimensions(470, 4)
    frame.divider:SetAnchor(TOPLEFT, frame.heading, BOTTOMLEFT, -50, 10)
    frame.divider:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    frame.alignBar = WINDOW_MANAGER:CreateControl(name .. "_align_bar", frame, CT_LABEL)
    frame.alignBar:SetFont("ZoFontGame")
    frame.alignBar:SetColor(0.8, 0.8, 0.6, 1)
    frame.alignBar:SetAnchor(TOPLEFT, frame.divider, TOPLEFT, 50, 30)
    frame.alignBar:SetText(GetString(_G.BARSTEWARD_ALIGN_BAR))
    frame.alignBar:SetDimensions(350)

    frame.alignBarValue = BS.CreateComboBox(name .. "_alignBarValue", frame, 200, 32, alignBars, alignBars[1])
    frame.alignBarValue:SetAnchor(TOPLEFT, frame.alignBar, BOTTOMLEFT, 0, 10)

    local anchorOptions = {
        GetString(_G.BARSTEWARD_TOP),
        GetString(_G.BARSTEWARD_BOTTOM),
        GetString(_G.BARSTEWARD_LEFT),
        GetString(_G.BARSTEWARD_RIGHT),
        GetString(_G.BARSTEWARD_MIDDLE)
    }

    frame.alignAnchor = WINDOW_MANAGER:CreateControl(name .. "_align_anchor", frame, CT_LABEL)
    frame.alignAnchor:SetFont("ZoFontGame")
    frame.alignAnchor:SetColor(0.8, 0.8, 0.6, 1)
    frame.alignAnchor:SetAnchor(TOPLEFT, frame.alignBarValue, BOTTOMLEFT, 0, 10)
    frame.alignAnchor:SetText(GetString(_G.BARSTEWARD_ALIGN_BAR_ANCHOR))
    frame.alignAnchor:SetDimensions(350)

    frame.alignBarAnchorValue =
        BS.CreateComboBox(name .. "_alignBarAnchorValue", frame, 200, 32, anchorOptions, anchorOptions[3])
    frame.alignBarAnchorValue:SetAnchor(TOPLEFT, frame.alignAnchor, BOTTOMLEFT, 0, 10)

    frame.alignRel = WINDOW_MANAGER:CreateControl(name .. "_align_rel", frame, CT_LABEL)
    frame.alignRel:SetFont("ZoFontGame")
    frame.alignRel:SetColor(0.8, 0.8, 0.6, 1)
    frame.alignRel:SetAnchor(TOPLEFT, frame.alignBarAnchorValue, BOTTOMLEFT, 0, 10)
    frame.alignRel:SetText(GetString(_G.BARSTEWARD_ALIGN_RELATIVE))
    frame.alignRel:SetDimensions(350)

    local relOptions = {}

    for _, bar in ipairs(alignBars) do
        table.insert(relOptions, bar)
    end

    table.insert(relOptions, GetString(_G.BARSTEWARD_SCREEN))

    frame.relativeBarValue =
        BS.CreateComboBox(name .. "_relativeBarValue", frame, 200, 32, relOptions, relOptions[2] or relOptions[1])
    frame.relativeBarValue:SetAnchor(TOPLEFT, frame.alignRel, BOTTOMLEFT, 0, 10)

    frame.relAnchor = WINDOW_MANAGER:CreateControl(name .. "_rel_anchor", frame, CT_LABEL)
    frame.relAnchor:SetFont("ZoFontGame")
    frame.relAnchor:SetColor(0.8, 0.8, 0.6, 1)
    frame.relAnchor:SetAnchor(TOPLEFT, frame.relativeBarValue, BOTTOMLEFT, 0, 10)
    frame.relAnchor:SetText(GetString(_G.BARSTEWARD_ALIGN_BAR_ANCHOR))
    frame.relAnchor:SetDimensions(350)

    frame.relativeBarAnchorValue =
        BS.CreateComboBox(name .. "_relativeBarAnchorValue", frame, 200, 32, anchorOptions, anchorOptions[3])
    frame.relativeBarAnchorValue:SetAnchor(TOPLEFT, frame.relAnchor, BOTTOMLEFT, 0, 10)

    frame.button = BS.CreateButton(name .. "_button", frame, 100, 32)
    frame.button:SetText(GetString(_G.BARSTEWARD_BUTTON_ALIGN))
    frame.button:SetAnchor(TOPLEFT, frame.relativeBarAnchorValue, BOTTOMLEFT, 0, 40)

    local onClick = function()
        local alignBarName = frame.alignBarValue.value
        local alignBarAnchor = frame.alignBarAnchorValue.value
        local relBarName = frame.relativeBarValue.value
        local relBarAnchor = frame.relativeBarAnchorValue.value

        if (alignBarName == relBarName) then
            return
        end

        -- find the bars
        local bars = BS.Vars.Bars
        local alignBar, relBar

        if (relBarName == GetString(_G.BARSTEWARD_SCREEN)) then
            relBar = GuiRoot
        end

        for idx, barData in pairs(bars) do
            if (barData.Name == alignBarName and not alignBar) then
                alignBar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])
                alignBar.index = idx
            end

            if (barData.Name == relBarName and not relBar) then
                relBar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])
                relBar.index = idx
            end
        end

        if (alignBar and relBar) then
            local alignAnchor = BS.GetAnchorFromText(alignBarAnchor)
            local relAnchor = BS.GetAnchorFromText(relBarAnchor)
            local constraint

            if (alignAnchor == LEFT or alignAnchor == RIGHT) then
                constraint = ANCHOR_CONSTRAINS_X
            else
                constraint = ANCHOR_CONSTRAINS_Y
            end

            alignBar:ClearAnchors()
            alignBar:SetAnchor(alignAnchor, relBar.bar, relAnchor, 0, 0, constraint)

            local barAnchor = BS.GetAnchorFromText(BS.Vars.Bars[alignBar.index].Anchor, true)
            local xPos, yPos

            if (barAnchor == CENTER) then
                xPos, yPos = alignBar.bar:GetCenter()
            elseif (barAnchor == TOPLEFT) then
                xPos, yPos = alignBar.bar:GetLeft(), alignBar.bar:GetTop()
            elseif (barAnchor == TOPRIGHT) then
                xPos, yPos = alignBar.bar:GetRight(), alignBar.bar:GetTop()
            end

            alignBar:ClearAnchors()
            alignBar:SetAnchor(barAnchor, GuiRoot, TOPLEFT, xPos, yPos)
            BS.Vars.Bars[alignBar.index].Position = {X = xPos, Y = yPos}
        end
    end

    frame.button:SetHandler("OnClicked", onClick)

    frame.close = BS.CreateButton(name .. "_close", frame, 100, 32)
    frame.close:SetText(BS.LC.Format(SI_DIALOG_CLOSE))
    frame.close:SetAnchor(TOPLEFT, frame.button, TOPRIGHT, 150, 0)
    frame.close:SetHandler(
        "OnClicked",
        function()
            frame.fragment:SetHiddenForReason("disabled", true)
        end
    )

    frame.fragment = ZO_HUDFadeSceneFragment:New(frame)
    frame.fragment:SetHiddenForReason("disabled", true)

    SCENE_MANAGER:GetScene("hud"):AddFragment(frame.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(frame.fragment)

    return frame
end

function BS.SetBarOptions(bars)
    BS.frame.alignBarValue.UpdateValues(BS.frame.alignBarValue, bars, bars[1])
    BS.frame.relativeBarValue.UpdateValues(BS.frame.relativeBarValue, bars, bars[1])
end

function BS.CreateLockButton()
    local name = BS.Name .. "_Lock_Button"

    BS.lock = WINDOW_MANAGER:CreateTopLevelWindow(name)
    BS.lock:SetDimensions(500, 150)
    BS.lock:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    BS.lock:SetHidden(true)

    BS.lock.button = WINDOW_MANAGER:CreateControl(name .. "_icon", BS.lock, CT_BUTTON)
    BS.lock.button:SetAnchorFill(BS.lock)
    BS.lock.button:SetNormalTexture("/esoui/art/buttons/button_xlarge_mouseup.dds")
    BS.lock.button:SetPressedTexture("/esoui/art/buttons/button_xlarge_mousedown.dds")
    BS.lock.button:SetMouseOverTexture("/esoui/art/buttons/button_xlarge_mouseover.dds")
    BS.lock.button:SetClickSound(_G.SOUNDS.MENU_BAR_CLICK)
    BS.lock.button:SetHandler(
        "OnClicked",
        function()
            BS.Vars.Movable = false

            for index, _ in pairs(BS.Vars.Bars) do
                local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[index])

                if (bar) then
                    bar.bar:SetMovable(false)
                    bar.bar.overlay:SetHidden(true)
                end
            end

            BS.lock.fragment:SetHiddenForReason("disabled", true)
            SCENE_MANAGER:Show("hud")
        end
    )

    local icon = BS.Icon("miscellaneous/locked_up", nil, 24, 24)

    BS.lock.label = WINDOW_MANAGER:CreateControl(name .. "_label", BS.lock, CT_LABEL)
    BS.lock.label:SetFont("${BOLD_FONT}|36|soft-shadow-thick")
    BS.lock.label:SetColor(0.8, 0.8, 0.8, 1)
    BS.lock.label:SetText(icon .. " " .. GetString(_G.BARSTEWARD_LOCK_FRAMES))
    BS.lock.label:SetDimensions(BS.lock:GetWidth(), 50)
    BS.lock.label:SetAnchor(CENTER, BS.lock, CENTER, 0, -30)
    BS.lock.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    BS.lock.fragment = ZO_HUDFadeSceneFragment:New(BS.lock)
    BS.lock.fragment:SetHiddenForReason("disabled", true)
    SCENE_MANAGER:GetScene("hud"):AddFragment(BS.lock.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(BS.lock.fragment)

    return BS.lock
end

local selected = -1

local function onClicked(key)
    selected = key
    BS.w_order.scrollList:Update(BS.dataItems)
end

local function setupDataRow(rowControl, data)
    local icon = data.icon

    if (type(icon) == "function") then
        icon = icon()
    end

    rowControl:GetNamedChild("Title"):SetText(data.name)
    rowControl:GetNamedChild("Icon"):SetTexture(BS.FormatIcon(icon))

    local cb = rowControl:GetNamedChild("CheckBox")
    local c = cb:GetNamedChild("Check")

    c:SetHandler(
        "OnClicked",
        function()
            onClicked(data.key)
        end
    )

    if (data.key ~= selected) then
        ZO_CheckButton_SetCheckState(c, false)
    else
        ZO_CheckButton_SetCheckState(c, true)
    end

    if (data.key == BS.W_ALLIANCE) then
        rowControl:GetNamedChild("Icon"):SetTextureCoords(0, 1, 0, 0.6)
    end
end

local function widgetSortFunction(widgetA, widgetB)
    return widgetA.data.order < widgetB.data.order
end

local function updateList(barName)
    -- find the bars
    local bars = BS.Vars.Bars
    local barIndex

    for idx, barData in pairs(bars) do
        if (barData.Name == barName) then
            barIndex = idx
            break
        end
    end

    if (barIndex) then
        --ensure the order is correct
        BS.CleanUpBarOrder(barIndex)

        -- get the widgets
        local controls = BS.Vars.Controls

        BS.dataItems = {}
        local itemKey = 1

        for key, control in pairs(controls) do
            if (control.Bar == barIndex) then
                local widget = BS.widgets[key]
                BS.dataItems[itemKey] = {
                    name = widget.tooltip,
                    icon = widget.icon,
                    key = key,
                    order = control.Order,
                    selected = key == selected
                }
                itemKey = itemKey + 1
            end
        end
    end
end

local function createScrollList(barName)
    local scrollData = {
        name = "BarStewardOrderList",
        parent = BS.w_order,
        width = 400,
        height = 500,
        rowHeight = 36,
        rowTemplate = "BarSteward_Order_Template",
        setupCallback = setupDataRow,
        sortFunction = widgetSortFunction
    }
    local scrollList = BS.CreateScrollList(scrollData)

    updateList(barName)
    scrollList:Update(BS.dataItems)

    return scrollList
end

function BS.CreateWidgetOrderTool(bars)
    BS.w_order = WINDOW_MANAGER:CreateTopLevelWindow()
    local frame = BS.w_order

    frame:SetDimensions(470, 1050)
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)

    frame.bgc = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.bgc:SetAnchorFill(frame)
    frame.bgc:SetTexture("/esoui/art/miscellaneous/centerscreen_left.dds")

    frame.bge = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.bge:SetDimensions(24, frame:GetHeight())
    frame.bge:SetAnchor(TOPLEFT, frame.bgc, TOPRIGHT)
    frame.bge:SetTexture("esoui/art/miscellaneous/centerscreen_right.dds")

    local fontSize = 24
    local fontStyle = "${BOLD_FONT}"
    local fontWeight = "soft-shadow-thick"
    local nameFont = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)

    frame.heading = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    frame.heading:SetFont(nameFont)
    frame.heading:SetColor(0.9, 0.9, 0.9, 1)
    frame.heading:SetAnchor(TOPLEFT, frame, TOPLEFT, 50, 80)
    frame.heading:SetText(GetString(_G.BARSTEWARD_WIDGET_ORDERING))
    frame.heading:SetDimensions(350, 24)

    frame.divider = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.divider:SetDimensions(470, 4)
    frame.divider:SetAnchor(TOPLEFT, frame.heading, BOTTOMLEFT, -50, 10)
    frame.divider:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    frame.bar = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    frame.bar:SetFont("ZoFontGame")
    frame.bar:SetColor(0.8, 0.8, 0.6, 1)
    frame.bar:SetAnchor(TOPLEFT, frame.divider, TOPLEFT, 50, 30)
    frame.bar:SetText(GetString(_G.BARSTEWARD_BAR))
    frame.bar:SetDimensions(350)

    local function comboCallback(value)
        updateList(value)
        frame.scrollList:Update(BS.dataItems)
    end

    frame.barValue = BS.CreateComboBox(nil, frame, 200, 32, bars, bars[1], comboCallback)
    frame.barValue:SetAnchor(TOPLEFT, frame.bar, BOTTOMLEFT, 0, 10)

    frame.moveUpButton = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.moveUpButton:SetTexture("/esoui/art/buttons/large_uparrow_up.dds")
    frame.moveUpButton:SetDimensions(32, 32)
    frame.moveUpButton:SetAnchor(TOPRIGHT, frame.barValue, TOPRIGHT, 185, 0)
    frame.moveUpButton:SetMouseEnabled(true)
    frame.moveUpButton:SetHandler(
        "OnMouseDown",
        function()
            BS.OrderUp()
        end
    )

    frame.moveDownButton = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.moveDownButton:SetTexture("/esoui/art/buttons/large_downarrow_up.dds")
    frame.moveDownButton:SetDimensions(32, 32)
    frame.moveDownButton:SetAnchor(RIGHT, frame.moveUpButton, LEFT, 10, 0)
    frame.moveDownButton:SetMouseEnabled(true)
    frame.moveDownButton:SetHandler(
        "OnMouseDown",
        function()
            BS.OrderDown()
        end
    )

    frame.divider2 = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    frame.divider2:SetDimensions(470, 4)
    frame.divider2:SetAnchor(TOPLEFT, frame.barValue, BOTTOMLEFT, -50, 10)
    frame.divider2:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    frame.scrollList = createScrollList(bars[1])
    frame.scrollList:SetAnchor(TOPLEFT, frame.divider2, BOTTOMLEFT, 50, 10)

    frame.button = BS.CreateButton(nil, frame, 100, 32)
    frame.button:SetText(GetString(_G.BARSTEWARD_REORDER))
    frame.button:SetAnchor(TOPLEFT, frame.scrollList, BOTTOMLEFT, 0, 40)

    local onClick = function()
        local barsToRegenerate = {}
        for _, item in pairs(BS.dataItems) do
            BS.Vars.Controls[item.key].Order = item.order
            barsToRegenerate[BS.Vars.Controls[item.key].Bar] = true
        end

        -- only regenerate altered bars
        BS.RegenerateAllBars(barsToRegenerate)
    end

    frame.button:SetHandler("OnClicked", onClick)

    frame.close = BS.CreateButton(nil, frame, 100, 32)
    frame.close:SetText(BS.LC.Format(SI_DIALOG_CLOSE))
    frame.close:SetAnchor(TOPLEFT, frame.button, TOPRIGHT, 170, 0)
    frame.close:SetHandler(
        "OnClicked",
        function()
            frame.fragment:SetHiddenForReason("disabled", true)
        end
    )

    frame.fragment = ZO_HUDFadeSceneFragment:New(frame)
    frame.fragment:SetHiddenForReason("disabled", true)

    SCENE_MANAGER:GetScene("hud"):AddFragment(frame.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(frame.fragment)

    return frame
end

local function findByKey(key)
    for _, item in pairs(BS.dataItems) do
        if (item.key == key) then
            return item
        end
    end
end

local function findByOrder(order)
    for key, item in pairs(BS.dataItems) do
        if (item.order == order) then
            return key
        end
    end
end

local function setOrder(old, new)
    local item1 = findByOrder(old)
    local item2 = findByOrder(new)

    BS.dataItems[item1].order = new
    BS.dataItems[item2].order = old
end

function BS.OrderDown()
    local widget = findByKey(selected)

    if (widget.order == #BS.dataItems) then
        return
    end

    setOrder(widget.order, widget.order + 1)
    BS.w_order.scrollList.Update(BS.w_order.scrollList, BS.dataItems)
end

function BS.OrderUp()
    local widget = findByKey(selected)

    if (widget.order == 1) then
        return
    end

    setOrder(widget.order, widget.order - 1)
    BS.w_order.scrollList.Update(BS.w_order.scrollList, BS.dataItems)
end

local function setupFriendsDataRow(rowControl, data)
    local checkBox = rowControl:GetNamedChild("Check")

    ZO_CheckButton_SetLabelText(checkBox, data.name)

    local function onCheckClicked(checkButton, checked)
        BS.Vars:SetCommon(checked, "FriendAnnounce", checkButton.label:GetText())
    end

    ZO_CheckButton_SetToggleFunction(checkBox, onCheckClicked)
    ZO_CheckButton_SetCheckState(checkBox, BS.Vars:GetCommon("FriendAnnounce", checkBox.label:GetText()))
end

function BS.UpdateFriendsList()
    local masterList = FRIENDS_LIST_MANAGER:GetMasterList()

    BS.friendDataItems = {}
    local itemKey = 1

    for _, friend in ipairs(masterList) do
        local dname = ZO_FormatUserFacingDisplayName(friend.displayName) or friend.displayName
        BS.friendDataItems[itemKey] = {name = dname}
        itemKey = itemKey + 1
    end
end

function BS.FriendsUpdate(scrollList)
    BS.UpdateFriendsList()

    local list = scrollList or BS.w_friends_list.scrollList
    list:Update(BS.friendDataItems)
end

local function getGuilds()
    local guilds = {}

    for i = 1, GetNumGuilds() do
        local id = GetGuildId(i)
        guilds[id] = GetGuildName(id)
    end

    BS.guilds = guilds

    return guilds
end

local function CreateTool(heading, toolName, varName, setupFunc, guild)
    local name = BS.Name .. "_" .. toolName .. "_Tool"
    local lowerName = toolName:lower()
    local frameName = "w_" .. lowerName .. "_list"

    BS[frameName] = WINDOW_MANAGER:CreateTopLevelWindow(name)
    local frame = BS[frameName]

    frame:SetDimensions(470, 900 + (guild and 50 or 0))
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)

    frame.bgc = WINDOW_MANAGER:CreateControl(name .. "_background", frame, CT_TEXTURE)
    frame.bgc:SetAnchorFill(frame)
    frame.bgc:SetTexture("/esoui/art/miscellaneous/centerscreen_left.dds")

    frame.bge = WINDOW_MANAGER:CreateControl(name .. "_edges", frame, CT_TEXTURE)
    frame.bge:SetDimensions(24, frame:GetHeight())
    frame.bge:SetAnchor(TOPLEFT, frame.bgc, TOPRIGHT)
    frame.bge:SetTexture("esoui/art/miscellaneous/centerscreen_right.dds")

    local fontSize = 24
    local fontStyle = "${BOLD_FONT}"
    local fontWeight = "soft-shadow-thick"
    local nameFont = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)

    frame.heading = WINDOW_MANAGER:CreateControl(name .. "_heading", frame, CT_LABEL)
    frame.heading:SetFont(nameFont)
    frame.heading:SetColor(0.9, 0.9, 0.9, 1)
    frame.heading:SetAnchor(TOPLEFT, frame, TOPLEFT, 50, 80)
    frame.heading:SetText(heading)
    frame.heading:SetDimensions(350, 24)

    frame.divider = WINDOW_MANAGER:CreateControl(name .. "_divider", frame, CT_TEXTURE)
    frame.divider:SetDimensions(470, 4)
    frame.divider:SetAnchor(TOPLEFT, frame.heading, BOTTOMLEFT, -50, 10)
    frame.divider:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    if (guild) then
        frame.guild = WINDOW_MANAGER:CreateControl(name .. "_guild", frame, CT_LABEL)
        frame.guild:SetFont("ZoFontGame")
        frame.guild:SetColor(0.8, 0.8, 0.6, 1)
        frame.guild:SetAnchor(TOPLEFT, frame.divider, TOPLEFT, 50, 10)
        frame.guild:SetText(BS.LC.Format(SI_SKILLTYPE5))
        frame.guild:SetDimensions(350)

        local guilds = getGuilds()
        local guildList = {}

        for _, g in pairs(guilds) do
            table.insert(guildList, g)
        end

        BS.firstguild = guildList[1]

        local function guildCallback(selectedGuild)
            BS.selectedGuild = selectedGuild
            BS.GuildFriendsUpdate(frame.scrollList)
        end

        frame.guildValue =
            BS.CreateComboBox(name .. "_guildValue", frame, 200, 32, guildList, BS.firstguild, guildCallback)
        frame.guildValue:SetAnchor(TOPLEFT, frame.guild, BOTTOMLEFT, 0, 10)
    end

    local scrollData = {
        name = "BarSteward" .. toolName .. "List",
        parent = frame,
        width = 400,
        height = 500,
        rowHeight = 36,
        rowTemplate = "BarSteward_Friends_Template",
        setupCallback = setupFunc
    }

    local anchor = guild and frame.guildValue or frame.divider
    local xoffset = guild and 0 or 50

    frame.scrollList = BS.CreateScrollList(scrollData)
    frame.scrollList:SetAnchor(TOPLEFT, anchor, BOTTOMLEFT, xoffset, 10)
    BS[toolName .. "Update"](frame.scrollList)

    frame.button = BS.CreateButton(name .. "_button", frame, 100, 32)
    frame.button:SetText(GetString(_G.BARSTEWARD_OK_COLOUR))
    frame.button:SetAnchor(TOPRIGHT, frame.scrollList, BOTTOMRIGHT, 0, 5)
    frame.button:SetHandler(
        "OnClicked",
        function()
            frame.fragment:SetHiddenForReason("disabled", true)

            local ftype = guild and BS.W_GUILD_FRIENDS or BS.W_FRIENDS

            if (BS.Vars.Controls[ftype].Bar ~= 0) then
                BS.widgets[ftype].update(BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[ftype]))
            end
        end
    )

    frame.selectAll = BS.CreateButton(name .. "_select_all", frame, 100, 32)
    frame.selectAll:SetText(GetString(_G.BARSTEWARD_SELECT_ALL))
    frame.selectAll:SetAnchor(TOPLEFT, frame.scrollList, BOTTOMLEFT, 0, 5)
    frame.selectAll:SetHandler(
        "OnClicked",
        function()
            local dataItems = BS.friendDataItems
            local value = true

            if (guild) then
                dataItems = BS.guildFriendDataItems
                value = BS.GetGuildId(BS.selectedGuild)
            end

            for _, friend in ipairs(dataItems) do
                BS.Vars[varName][friend.name] = value
                BS[string.format("%sUpdate", toolName)](frame.scrollList)
            end
        end
    )

    frame.selectNone = BS.CreateButton(name .. "_select_none", frame, 100, 32)
    frame.selectNone:SetText(GetString(_G.BARSTEWARD_SELECT_NONE))
    frame.selectNone:SetAnchor(LEFT, frame.selectAll, RIGHT, 10, 0)
    frame.selectNone:SetHandler(
        "OnClicked",
        function()
            local dataItems = BS.friendDataItems

            if (guild) then
                dataItems = BS.guildFriendDataItems
            end

            for _, friend in ipairs(dataItems) do
                BS.Vars[varName][friend.name] = nil
                BS[toolName .. "Update"](frame.scrollList)
            end
        end
    )

    frame.fragment = ZO_HUDFadeSceneFragment:New(frame)
    frame.fragment:SetHiddenForReason("disabled", true)

    SCENE_MANAGER:GetScene("hud"):AddFragment(frame.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(frame.fragment)

    return frame
end

function BS.CreateFriendsTool()
    return CreateTool(GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND), "Friends", "FriendAnnounce", setupFriendsDataRow)
end

-- guild friends
local function getGuildMembers(guildId)
    local localPlayerIndex = GetPlayerGuildMemberIndex(guildId)
    local numGuildMembers = GetNumGuildMembers(guildId)
    local members = {}

    for guildMemberIndex = 1, numGuildMembers do
        local displayName, _, _, status = GetGuildMemberInfo(guildId, guildMemberIndex)
        local isLocalPlayer = guildMemberIndex == localPlayerIndex
        local hasCharacter, rawCharacterName, _, _, alliance = GetGuildMemberCharacterInfo(guildId, guildMemberIndex)

        if (isLocalPlayer == false) then
            table.insert(
                members,
                {
                    index = guildMemberIndex,
                    displayName = displayName,
                    hasCharacter = hasCharacter,
                    isLocalPlayer = isLocalPlayer,
                    characterName = ZO_CachedStrFormat(SI_UNIT_NAME, rawCharacterName),
                    alliance = alliance,
                    status = status
                }
            )
        end
    end

    return members
end

function BS.GetGuildId(guildName)
    for id, guild in pairs(BS.guilds) do
        if (guild == guildName) then
            return id
        end
    end
end

local function setupGuildFriendsDataRow(rowControl, data)
    local checkBox = rowControl:GetNamedChild("Check")

    ZO_CheckButton_SetLabelText(checkBox, data.name)

    local function onAnnounceClicked(checkButton, checked)
        if (checked) then
            BS.Var:SetCommon(BS.GetGuildId(BS.selectedGuild), "GuildFriendAnnounce", checkButton.label:GetText())
        else
            BS.Vars:SetCommon(nil, "GuildFriendAnnounce", checkButton.label:GetText())
        end
    end

    ZO_CheckButton_SetToggleFunction(checkBox, onAnnounceClicked)
    ZO_CheckButton_SetCheckState(checkBox, BS.Vars:GetCommon("GuildFriendAnnounce", checkBox.label:GetText()))
end

function BS.UpdateGuildFriendsList()
    local guildId = BS.GetGuildId(BS.selectedGuild or BS.firstguild)
    local masterList = getGuildMembers(guildId)

    table.sort(
        masterList,
        function(a, b)
            return a.displayName < b.displayName
        end
    )
    BS.guildFriendDataItems = {}
    local itemKey = 1

    for _, friend in ipairs(masterList) do
        local dname = ZO_FormatUserFacingDisplayName(friend.displayName) or friend.displayName
        BS.guildFriendDataItems[itemKey] = {name = dname}
        itemKey = itemKey + 1
    end
end

function BS.GuildFriendsUpdate(scrollList)
    BS.UpdateGuildFriendsList()

    local list = scrollList or BS.w_guildfriends_list.scrollList
    list:Update(BS.guildFriendDataItems)
end

function BS.CreateGuildFriendsTool()
    local tool =
        CreateTool(
        GetString(_G.BARSTEWARD_GUILD_FRIENDS_MONITORING),
        "GuildFriends",
        "GuildFriendAnnounce",
        setupGuildFriendsDataRow,
        true
    )
    BS.selectedGuild = BS.GetGuildId(BS.firstguild)

    return tool
end

function BS.CreateExportFrame()
    local name = BS.Name .. "_Export_Frame"

    BS.ExportFrame = WINDOW_MANAGER:CreateTopLevelWindow(name)
    local frame = BS.ExportFrame

    frame:SetDimensions(470, 900)
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)

    frame.bgc = WINDOW_MANAGER:CreateControl(name .. "_background", frame, CT_TEXTURE)
    frame.bgc:SetAnchorFill(frame)
    frame.bgc:SetTexture("/esoui/art/miscellaneous/centerscreen_left.dds")

    frame.bge = WINDOW_MANAGER:CreateControl(name .. "_edges", frame, CT_TEXTURE)
    frame.bge:SetDimensions(24, frame:GetHeight())
    frame.bge:SetAnchor(TOPLEFT, frame.bgc, TOPRIGHT)
    frame.bge:SetTexture("esoui/art/miscellaneous/centerscreen_right.dds")

    local fontSize = 24
    local fontStyle = "${BOLD_FONT}"
    local fontWeight = "soft-shadow-thick"
    local nameFont = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)

    frame.heading = WINDOW_MANAGER:CreateControl(name .. "_heading", frame, CT_LABEL)
    frame.heading:SetFont(nameFont)
    frame.heading:SetColor(1, 0.39, 0, 1)
    frame.heading:SetAnchor(TOPLEFT, frame, TOPLEFT, 50, 80)
    frame.heading:SetText(GetString(_G.BARSTEWARD_EXPORT_BAR))
    frame.heading:SetDimensions(350, 24)

    frame.divider = WINDOW_MANAGER:CreateControl(name .. "_divider", frame, CT_TEXTURE)
    frame.divider:SetDimensions(470, 4)
    frame.divider:SetAnchor(TOPLEFT, frame.heading, BOTTOMLEFT, -50, 10)
    frame.divider:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    frame.note = WINDOW_MANAGER:CreateControl(name .. "_note", frame, CT_LABEL)
    frame.note:SetFont("ZoFontGame")
    frame.note:SetAnchor(TOPLEFT, frame.divider, BOTTOMLEFT, 30, 10)
    frame.note:SetText(GetString(_G.BARSTEWARD_COPY))
    frame.note:SetDimensions(430, 75)

    frame.background = WINDOW_MANAGER:CreateControlFromVirtual(nil, frame, "ZO_EditBackdrop")
    frame.background:SetAnchor(TOPLEFT, frame.note, BOTTOMLEFT, 0, 10)
    frame.background:SetDimensions(430, 400)

    frame.content = WINDOW_MANAGER:CreateControlFromVirtual(nil, frame.background, "ZO_DefaultEditMultiLineForBackdrop")
    frame.content:SetAnchorFill()
    frame.content:SetTextType(TEXT_TYPE_ALL)
    frame.content:SetMaxInputChars(2000)

    frame.error = WINDOW_MANAGER:CreateControl(name .. "_error", frame, CT_LABEL)
    frame.error:SetFont("ZoFontGame")
    frame.error:SetColor(1, 0, 0, 1)
    frame.error:SetAnchor(TOPLEFT, frame.background, BOTTOMLEFT, 20, 10)
    frame.error:SetDimensions(420, 50)
    frame.error:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    frame.import = BS.CreateButton(name .. "_import", frame, 100, 32)
    frame.import:SetText(GetString(_G.BARSTEWARD_IMPORT))
    frame.import:SetAnchor(BOTTOMLEFT, frame, BOTTOMLEFT, 20, -200)
    frame.import:SetHandler(
        "OnClicked",
        function()
            BS.ImportBar(frame.content:GetText(), frame.replace)
        end
    )

    frame.replace = WINDOW_MANAGER:CreateControlFromVirtual(name .. "_replace", frame, "ZO_CheckButton")
    frame.replace:SetDimensions(32, 32)
    frame.replace:SetAnchor(LEFT, frame.import, RIGHT, 20, -2)

    ZO_CheckButton_SetLabelText(frame.replace, GetString(_G.BARSTEWARD_MAIN_BAR_REPLACE))
    ZO_CheckButtonLabel_SetTextColor(frame.replace, 1, 0, 0)
    ZO_CheckButtonLabel_SetDefaultColors(
        frame.replace:GetNamedChild("Label"),
        ZO_ERROR_COLOR,
        ZO_ERROR_COLOR,
        ZO_ERROR_COLOR
    )

    frame.close = BS.CreateButton(name .. "_close", frame, 100, 32)
    frame.close:SetText(BS.LC.Format(SI_DIALOG_CLOSE))
    frame.close:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -20, -200)
    frame.close:SetHandler(
        "OnClicked",
        function()
            frame.content:Clear()
            frame.fragment:SetHiddenForReason("disabled", true)
        end
    )

    frame.fragment = ZO_HUDFadeSceneFragment:New(frame)
    frame.fragment:SetHiddenForReason("disabled", true)

    SCENE_MANAGER:GetScene("hud"):AddFragment(frame.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(frame.fragment)

    return frame
end

local function checkOrCreatePool(grid)
    if (not BS.SquareObjectPool) then
        BS.SquareObjectPool =
            ZO_ObjectPool:New(
            -- factory
            function()
                local square = WINDOW_MANAGER:CreateControl(nil, grid, CT_BACKDROP)

                square:SetCenterColor(0, 0, 0, 0)
                square:SetEdgeColor(0, 0, 0, 0.7)
                square:SetEdgeTexture("", 2, 2, 1, 0)

                return square
            end,
            --reset
            function(square)
                square:SetHidden(true)
                square:ClearAnchors()
            end
        )
    end
end

--Based on RAEIH InfoHub, but modified to object pool to avoid UI reloads
function BS.ShowGrid(showGrid)
    if (showGrid) then
        if (BS.GridChanged) then
            local gridSquares = BS.Vars.VisibleGridSize
            local guiWidth, guiHeight = GuiRoot:GetDimensions()
            local gridDimension = guiWidth / gridSquares
            local gridYNumMax = guiHeight / gridDimension
            local gridYNum = 1
            local gridX, gridY = 0, 0
            local index = 1

            if (not BS.Grid) then
                BS.Grid = WINDOW_MANAGER:CreateTopLevelWindow()
                BS.Grid:SetAnchorFill()
                checkOrCreatePool(BS.Grid)
            end

            -- release any old squares
            BS.SquareObjectPool:ReleaseAllObjects()

            while (index <= gridSquares) do
                local square = BS.SquareObjectPool:AcquireObject()

                square:SetDimensions(gridDimension, gridDimension)
                square:SetSimpleAnchor(BS.Grid, gridX, gridY)
                square:SetHidden(false)

                gridX = gridX + gridDimension
                index = index + 1

                if (index == gridSquares + 1 and gridYNum < gridYNumMax) then
                    gridX = 0
                    gridY = gridY + gridDimension
                    gridYNum = gridYNum + 1
                    index = 1
                end
            end

            BS.GridChanged = false
        end

        BS.Grid:SetHidden(false)
    else
        if (BS.Grid) then
            BS.Grid:SetHidden(true)
        end
    end
end

function BS.CreateCopyFrame()
    local name = BS.Name .. "_Copy_Frame"

    BS.CopyFrame = WINDOW_MANAGER:CreateTopLevelWindow(name)
    local frame = BS.CopyFrame

    frame:SetDimensions(470, 650)
    frame:SetAnchor(CENTER, GuiRoot, CENTER)
    frame:SetHidden(true)

    frame.bgc = WINDOW_MANAGER:CreateControl(name .. "_background", frame, CT_TEXTURE)
    frame.bgc:SetAnchorFill(frame)
    frame.bgc:SetTexture("/esoui/art/miscellaneous/centerscreen_left.dds")

    frame.bge = WINDOW_MANAGER:CreateControl(name .. "_edges", frame, CT_TEXTURE)
    frame.bge:SetDimensions(24, frame:GetHeight())
    frame.bge:SetAnchor(TOPLEFT, frame.bgc, TOPRIGHT)
    frame.bge:SetTexture("esoui/art/miscellaneous/centerscreen_right.dds")

    local fontSize = 24
    local fontStyle = "${BOLD_FONT}"
    local fontWeight = "soft-shadow-thick"
    local nameFont = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)

    frame.heading = WINDOW_MANAGER:CreateControl(name .. "_heading", frame, CT_LABEL)
    frame.heading:SetFont(nameFont)
    frame.heading:SetColor(1, 0.39, 0, 1)
    frame.heading:SetAnchor(TOPLEFT, frame, TOPLEFT, 50, 80)
    frame.heading:SetText(GetString(_G.BARSTEWARD_COPY_SETTINGS))
    frame.heading:SetDimensions(350, 24)

    frame.divider = WINDOW_MANAGER:CreateControl(name .. "_divider", frame, CT_TEXTURE)
    frame.divider:SetDimensions(470, 4)
    frame.divider:SetAnchor(TOPLEFT, frame.heading, BOTTOMLEFT, -50, 10)
    frame.divider:SetTexture("/esoui/art/campaign/campaignbrowser_divider_short.dds")

    local servers = BS.Vars:GetServers()
    local accounts = BS.Vars:GetAccounts(servers[1])
    local characters = BS.Vars:GetCharacters(servers[1], accounts[1], true)

    local function serverSelected(value)
        BS.selectedServer = value
        accounts = BS.Vars:GetAccounts(value)
        frame.accounts:UpdateValues(accounts, 1)
        frame.accounts:SetDisabled(false)
        characters = BS.Vars:GetCharacters(value, accounts[1], true)
        BS.selectedAccount = accounts[1]
        BS.selectedCharacter = characters[1]
        frame.characters:UpdateValues(characters, 1)
    end

    local function accountSelected(value)
        BS.selectedAccount = value
        characters = BS.Vars:GetCharacters(BS.selectedServer, value, true)
        frame.characters:UpdateValues(characters, 1)
        frame.characters:SetDisabled(false)
        BS.selectedCharacter = characters[1]
    end

    local function characterSelected(value)
        BS.selectedCharacter = value
    end

    frame.fromlabel = WINDOW_MANAGER:CreateControl(name .. "_from", frame, CT_LABEL)
    frame.fromlabel:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.fromlabel:SetColor(1, 1, 0, 1)
    frame.fromlabel:SetAnchor(TOPLEFT, frame.divider, BOTTOMLEFT, 40, 20)
    frame.fromlabel:SetText(BS.LC.Format(SI_MAIL_INBOX_FROM_COLUMN))
    frame.fromlabel:SetDimensions(100, 24)

    frame.serverlabel = WINDOW_MANAGER:CreateControl(name .. "_serverLabel", frame, CT_LABEL)
    frame.serverlabel:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.serverlabel:SetColor(0.98, 0.98, 0.98, 1)
    frame.serverlabel:SetAnchor(TOPLEFT, frame.fromlabel, BOTTOMLEFT, 10, 20)
    frame.serverlabel:SetText(GetString(_G.BARSTEWARD_SERVER))
    frame.serverlabel:SetDimensions(100, 24)

    frame.servers = BS.CreateComboBox(name .. "_server", frame, 250, 32, servers, servers[1], serverSelected)
    frame.servers:SetAnchor(LEFT, frame.serverlabel, RIGHT, 30, 0)

    frame.accountlabel = WINDOW_MANAGER:CreateControl(name .. "_accountLabel", frame, CT_LABEL)
    frame.accountlabel:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.accountlabel:SetColor(0.98, 0.98, 0.98, 1)
    frame.accountlabel:SetAnchor(TOPLEFT, frame.serverlabel, BOTTOMLEFT, 0, 20)
    frame.accountlabel:SetText(BS.LC.Format(SI_CURRENCYLOCATION3))
    frame.accountlabel:SetDimensions(100, 24)

    frame.accounts = BS.CreateComboBox(name .. "_account", frame, 250, 32, nil, nil, accountSelected)
    frame.accounts:SetAnchor(LEFT, frame.accountlabel, RIGHT, 30, 0)
    frame.accounts:SetDisabled(true)

    frame.characterlabel = WINDOW_MANAGER:CreateControl(name .. "_characterLabel", frame, CT_LABEL)
    frame.characterlabel:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.characterlabel:SetColor(0.98, 0.98, 0.98, 1)
    frame.characterlabel:SetAnchor(TOPLEFT, frame.accountlabel, BOTTOMLEFT, 0, 20)
    frame.characterlabel:SetText(BS.LC.Format(SI_CURRENCYLOCATION0))
    frame.characterlabel:SetDimensions(100, 24)

    frame.characters = BS.CreateComboBox(name .. "_character", frame, 250, 32, nil, nil, characterSelected)
    frame.characters:SetAnchor(LEFT, frame.characterlabel, RIGHT, 30, 0)
    frame.characters:SetDisabled(true)

    serverSelected(servers[1])
    accountSelected(accounts[1])
    characterSelected(characters[1])

    frame.tolabel = WINDOW_MANAGER:CreateControl(name .. "_to", frame, CT_LABEL)
    frame.tolabel:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.tolabel:SetColor(1, 1, 0, 1)
    frame.tolabel:SetAnchor(TOPLEFT, frame.characterlabel, BOTTOMLEFT, -10, 20)
    frame.tolabel:SetText(BS.LC.Format(SI_GAMEPAD_MAIL_SEND_TO))
    frame.tolabel:SetDimensions(100, 24)

    frame.thisaccount = WINDOW_MANAGER:CreateControlFromVirtual(name .. "_acc_sel", frame, "ZO_CheckButton")
    frame.thisaccount:SetDimensions(24, 24)
    frame.thisaccount:SetAnchor(TOPLEFT, frame.tolabel, LEFT, 10, 20)

    ZO_CheckButton_SetLabelText(frame.thisaccount, GetString(_G.BARSTEWARD_THIS_ACCOUNT))

    local function onAccountClicked(_, checked)
        BS.selectedAccountOption = checked

        if (BS.selectedCharacterOption and checked) then
            ZO_CheckButton_SetCheckState(frame.thischaracter, false)
        else
            ZO_CheckButton_SetCheckState(frame.thischaracter, true)
            BS.selectedCharacterOption = true
        end
    end

    ZO_CheckButton_SetToggleFunction(frame.thisaccount, onAccountClicked)
    ZO_CheckButtonLabel_SetTextColor(frame.thisaccount, 0.98, 0.98, 0.98)

    frame.thischaracter = WINDOW_MANAGER:CreateControlFromVirtual(name .. "_char_sel", frame, "ZO_CheckButton")
    frame.thischaracter:SetDimensions(24, 24)
    frame.thischaracter:SetAnchor(LEFT, frame.thisaccount, LEFT, 225, 0)

    ZO_CheckButton_SetLabelText(frame.thischaracter, GetString(_G.BARSTEWARD_THIS_CHARACTER))

    local function onCharacterClicked(_, checked)
        BS.selectedCharacterOption = checked

        if (BS.selectedAccountOption and checked) then
            ZO_CheckButton_SetCheckState(frame.thisaccount, false)
        else
            ZO_CheckButton_SetCheckState(frame.thisaccount, true)
            BS.selectedAccountOption = true
        end
    end

    ZO_CheckButton_SetToggleFunction(frame.thischaracter, onCharacterClicked)
    ZO_CheckButtonLabel_SetTextColor(frame.thischaracter, 0.98, 0.98, 0.98)

    -- set initial state
    BS.selectedCharacterOption = true
    ZO_CheckButton_SetCheckState(frame.thisaccount, false)
    ZO_CheckButton_SetCheckState(frame.thischaracter, true)

    frame.warning = WINDOW_MANAGER:CreateControl(name .. "_warning", frame, CT_LABEL)
    frame.warning:SetFont("$(MEDIUM_FONT)|$(KB_18)|$(soft-shadow-fix)")
    frame.warning:SetColor(1, 1, 0, 1)
    frame.warning:SetAnchor(TOPLEFT, frame.thisaccount, BOTTOMLEFT, -10, 20)
    frame.warning:SetText(GetString(_G.BARSTEWARD_SETTINGS))
    frame.warning:SetDimensions(390, 72)

    frame.close = BS.CreateButton(name .. "_close", frame, 100, 32)
    frame.close:SetText(BS.LC.Format(SI_CANCEL))
    frame.close:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -20, -140)
    frame.close:SetHandler(
        "OnClicked",
        function()
            frame.fragment:SetHiddenForReason("disabled", true)
        end
    )

    frame.ok = BS.CreateButton(name .. "_ok", frame, 100, 32)
    frame.ok:SetText(BS.LC.Format(SI_OK))
    frame.ok:SetAnchor(RIGHT, frame.close, LEFT, -20, 0)
    frame.ok:SetHandler(
        "OnClicked",
        function()
            if (BS.selectedServer and BS.selectedAccount and BS.selectedCharacter) then
                BS.Vars:Copy(BS.selectedServer, BS.selectedAccount, BS.selectedCharacter, BS.selectedAccountOption)
                BS.RegenerateAllBars()
            end

            frame.fragment:SetHiddenForReason("disabled", true)
            ZO_Dialogs_ShowDialog(BS.Name .. "ReloadQuestion")
        end
    )

    frame.fragment = ZO_HUDFadeSceneFragment:New(frame)
    frame.fragment:SetHiddenForReason("disabled", true)

    SCENE_MANAGER:GetScene("hud"):AddFragment(frame.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(frame.fragment)

    return frame
end
