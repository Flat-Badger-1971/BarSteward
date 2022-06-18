local BS = _G.BarSteward

-- borrowed from Bandits UI
function BS.CreateComboBox(name, parent, width, height, choices, default, callback)
    local combo = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ComboBox")

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
                comboBox:AddItem(entry, _G.ZO_COMBOBOX_SUPRESS_UPDATE)
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
                self.disabled and {0.3, 0.3, 0.3, 1} or choices[combo.value] == "Disabled" and {0.5, 0.5, 0.4, 1} or
                {0.8, 0.8, 0.6, 1}
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
