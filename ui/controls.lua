local BS = _G.BarSteward
local cindex = 1

-- borrowed from Bandits UI
function BS.CreateComboBox(name, parent, width, height, choices, default, callback)
    local combo = WINDOW_MANAGER:CreateControlFromVirtual(name or ("BSCombo_" .. cindex), parent, "ZO_ComboBox")

    cindex = cindex + 1
    combo:SetDimensions(width, height)

    combo.UpdateValues = function(self, array, index)
        local comboBox = self.m_comboBox

        if (array) then
            comboBox:ClearItems()

            for idx, value in pairs(array) do
                local entry =
                    ZO_ComboBox:CreateItemEntry(
                        value,
                        function()
                            combo.value = value
                            self:UpdateParent()

                            if (callback) then
                                callback(value)
                            end
                        end
                    )
                entry.id = idx
                comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
            end
        end

        comboBox:SelectItemByIndex(index, true)
        combo.value = default
        self:UpdateParent()
    end

    combo.SetDisabled = function(self, value)
        self.disabled = value
        self:SetMouseEnabled(not value)
        self:GetNamedChild("OpenDropdown"):SetMouseEnabled(not value)
        self:SetAlpha(value and 0.5 or 1)
        self:UpdateParent()
    end

    combo.UpdateParent = function(self)
        if (parent:GetType() == CT_LABEL) then
            local colour =
                self.disabled and { 0.3, 0.3, 0.3, 1 } or choices[combo.value] == "Disabled" and { 0.5, 0.5, 0.4, 1 } or
                { 0.8, 0.8, 0.6, 1 }
            parent:SetColor(unpack(colour))
        end
    end

    local index = default

    if (type(index) == "string") then
        combo.array = {}

        for idx, value in pairs(choices) do
            combo.array[value] = idx
        end

        index = combo.array[index]
    end

    combo:UpdateValues(choices, index)

    return combo
end

function BS.CreateButton(name, parent, width, height)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")

    button:SetDimensions(width, height)
    button:SetFont("ZoFontGame")
    button:SetClickSound("Click")

    return button
end

-- based on libscroll
local function UpdateScrollList(scrollList, dataTable)
    local dataTableCopy = ZO_DeepTableCopy(dataTable)
    local dataList = ZO_ScrollList_GetDataList(scrollList)

    ZO_ScrollList_Clear(scrollList)

    -- Add data items to the list
    for _, dataItem in ipairs(dataTableCopy) do
        local entry = ZO_ScrollList_CreateDataEntry(1, dataItem, dataItem.categoryId)
        table.insert(dataList, entry)
    end

    local sortFn = scrollList.SortFunction

    if (sortFn) then
        table.sort(dataList, sortFn)
    end

    ZO_ScrollList_Commit(scrollList)
end

local function ClearList(self)
    ZO_ScrollList_Clear(self)
    ZO_ScrollList_Commit(self)
end

function BS.CreateScrollList(scrollData)
    local scrollList = WINDOW_MANAGER:CreateControlFromVirtual(scrollData.name, scrollData.parent, "ZO_ScrollList")

    scrollList:SetDimensions(scrollData.width, scrollData.height)

    ZO_ScrollList_AddDataType(
        scrollList,
        1,
        scrollData.rowTemplate,
        scrollData.rowHeight,
        scrollData.setupCallback,
        scrollData.hideCallback,
        scrollData.dataTypeSelectSound,
        scrollData.resetControlCallback
    )

    if (scrollData.selectTemplate or scrollData.selectCallback) then
        ZO_ScrollList_EnableSelection(scrollList, scrollData.selectTemplate, scrollData.selectCallback)
    end

    scrollList.scrollData = scrollData
    scrollList.SortFunction = scrollData.sortFunction

    -- Easy Access Functions
    scrollList.Clear = ClearList
    scrollList.Update = UpdateScrollList

    return scrollList
end

function BS.CreateProgressBar(barName, barParent)
    local bar = WINDOW_MANAGER:CreateControlFromVirtual(barName, barParent, "ZO_ResponsiveArrowProgressBarWithBG")

    bar.progress = bar:GetNamedChild("Progress")
    bar.progress:SetColor(unpack(BS.Vars.DefaultWarningColour))

    ZO_StatusBar_InitializeDefaultColors(bar)

    return bar
end

function BS.PBAR()
    local name = BS.Name .. "_pgbar"

    local parent = WINDOW_MANAGER:CreateTopLevelWindow(name)

    parent:SetDimensions(470, 650)
    parent:SetAnchor(CENTER, GuiRoot, CENTER)

    -- *** ZO_ArrowStatusBar ***
    name = name .. "bar"
    local bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)

    bar:SetAnchor(CENTER)

    bar:SetDimensions(315, 20)
    bar:SetTexture("esoui/art/miscellaneous/progressbar_genericfill.dds")
    bar:SetTextureCoords(0, 1, 0, 0.625)
    bar:SetLeadingEdge("EsoUI/Art/Miscellaneous/progressbar_genericFill_leadingEdge.dds", 8, 20)
    bar:SetLeadingEdgeTextureCoords(0, 1, 0, 0.625)

    -- OnInitialized self.gloss = self:GetNamedChild("Gloss")
    -- OnMinMaxValueChanged self.gloss:SetMinMax(min, max)
    -- OnValueChanged self.gloss:SetValue(value)

    bar.gloss = WINDOW_MANAGER:CreateControl(name .. "gloss", bar, CT_STATUSBAR)
    bar.gloss:SetAnchorFill()
    bar.gloss:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericFill_gloss.dds")
    bar.gloss:SetTextureCoords(0, 1, 0, 0.625)
    bar.gloss:SetLeadingEdge("EsoUI/Art/Miscellaneous/progressbar_genericFill_leadingEdge_gloss.dds", 8, 20)
    bar.gloss:SetLeadingEdgeTextureCoords(0, 1, 0, 0.625)
    -- ******

    -- *** ZO_ArrowStatusBarWithBG ***
    bar.bg = WINDOW_MANAGER:CreateControl(name .. "BG", bar, CT_CONTROL)
    bar.bg:SetAnchorFill()
    bar.bg.left = WINDOW_MANAGER:CreateControl(name .. "BGLeft", bar.bg, CT_TEXTURE)
    bar.bg.left:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame_bg.dds")
    bar.bg.left:SetTextureCoords(0, 0.0195, 0, 0.625)
    bar.bg.left:SetWidth(10)
    bar.bg.left:SetAnchor(TOPLEFT)
    bar.bg.left:SetAnchor(BOTTOMLEFT)

    bar.bg.right = WINDOW_MANAGER:CreateControl(name .. "BGRight", bar.bg, CT_TEXTURE)
    bar.bg.right:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame_bg.dds")
    bar.bg.right:SetTextureCoords(0.5938, 0.6133, 0, 0.625)
    bar.bg.right:SetWidth(10)
    bar.bg.right:SetAnchor(TOPRIGHT)
    bar.bg.right:SetAnchor(BOTTOMRIGHT)

    bar.bg.middle = WINDOW_MANAGER:CreateControl(name .. "BGMiddle", bar.bg, CT_TEXTURE)
    bar.bg.middle:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame_bg.dds")
    bar.bg.middle:SetTextureCoords(0.0195, 0.5898, 0, 0.625)
    bar.bg.middle:SetAnchor(TOPLEFT)
    bar.bg.middle:SetAnchor(BOTTOMRIGHT)

    bar.overlay = WINDOW_MANAGER:CreateControl(name .. "Overlay", bar, CT_CONTROL)
    bar.overlay:SetAnchorFill()
    bar.overlay.left = WINDOW_MANAGER:CreateControl(name .. "OverlayLeft", bar.bg, CT_TEXTURE)
    bar.overlay.left:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame.dds")
    bar.overlay.left:SetDrawLayer(DL_OVERLAY)
    bar.overlay.left:SetTextureCoords(0, 0.0195, 0, 0.625)
    bar.overlay.left:SetWidth(10)
    bar.overlay.left:SetAnchor(TOPLEFT)
    bar.overlay.left:SetAnchor(BOTTOMLEFT)

    bar.overlay.right = WINDOW_MANAGER:CreateControl(name .. "OverlayRight", bar.bg, CT_TEXTURE)
    bar.overlay.right:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame.dds")
    bar.overlay.right:SetDrawLayer(DL_OVERLAY)
    bar.overlay.right:SetTextureCoords(0.5938, 0.6133, 0, 0.625)
    bar.overlay.right:SetWidth(10)
    bar.overlay.right:SetAnchor(TOPRIGHT)
    bar.overlay.right:SetAnchor(BOTTOMRIGHT)

    bar.overlay.middle = WINDOW_MANAGER:CreateControl(name .. "OverlayMiddle", bar.bg, CT_TEXTURE)
    bar.overlay.middle:SetTexture("EsoUI/Art/Miscellaneous/progressbar_frame.dds")
    bar.overlay.middle:SetDrawLayer(DL_OVERLAY)
    bar.overlay.middle:SetTextureCoords(0.0195, 0.5898, 0, 0.625)
    bar.overlay.middle:SetAnchor(TOPLEFT, bar.overlay.left, TOPRIGHT)
    bar.overlay.middle:SetAnchor(BOTTOMRIGHT, bar.overlay.right, BOTTOMLEFT)
    -- ******
end
