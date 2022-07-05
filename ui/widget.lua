local BS = _G.BarSteward

local baseWidget = ZO_Object:Subclass()

function baseWidget:New(...)
    local widget = ZO_Object.New(self)
    widget:Initialise(...)

    return widget
end

function baseWidget:Initialise(widgetSettings)
    local name = BS.Name .. "_Widget_" .. widgetSettings.name

    self.name = widgetSettings.name
    self.minWidthChars = widgetSettings.minWidthChars
    self.control = WINDOW_MANAGER:CreateControl(name, widgetSettings.parent, CT_CONTROL)
    self.control:SetResizeToFitDescendents(true)
    self.control.ref = self

    local texture

    if (type(widgetSettings.icon) == "function") then
        texture = widgetSettings.icon()
    else
        texture = widgetSettings.icon
    end

    self.icon = WINDOW_MANAGER:CreateControl(name .. "_icon", self.control, CT_TEXTURE)
    self.icon:SetTexture(texture)
    self.icon:SetDimensions(widgetSettings.iconWidth or 32, widgetSettings.iconHeight or 32)
    self.icon:SetAnchor(widgetSettings.valueSide == LEFT and RIGHT or LEFT)

    if (widgetSettings.progress) then
        self.value = BS.CreateProgressBar(name .. "_progress", self.control)
        self.value:SetAnchor(
            widgetSettings.valueSide == LEFT and RIGHT or LEFT,
            self.icon,
            widgetSettings.valueSide,
            widgetSettings.valueSide == LEFT and -10 or 10,
            0
        )
        self.value:SetDimensions(200, 32)
        self.value:SetMinMax(0, 100)
    else
        self.value = WINDOW_MANAGER:CreateControl(name .. "_value", self.control, CT_LABEL)
        self.value:SetFont("ZoFontGame")
        self.value:SetColor(unpack(BS.Vars.DefaultColour))
        self.value:SetAnchor(
            widgetSettings.valueSide == LEFT and RIGHT or LEFT,
            self.icon,
            widgetSettings.valueSide,
            widgetSettings.valueSide == LEFT and -10 or 10,
            0
        )
        self.value:SetDimensions(widgetSettings.valueWidth or 50, widgetSettings.iconHeight or 32)
        self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end

    self.tooltip = widgetSettings.tooltip

    if (widgetSettings.tooltip) then
        local anchorControl = self.value

        if (widgetSettings.tooltipAnchor == LEFT) then
            anchorControl = self.icon
        end

        local function getTooltip()
            return self.tooltip
        end

        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseEnter",
            function()
                local tooltip = getTooltip()
                ZO_Tooltips_ShowTextTooltip(anchorControl, widgetSettings.tooltipAnchor or BOTTOM, tooltip)
            end
        )

        self.control:SetHandler(
            "OnMouseExit",
            function()
                ZO_Tooltips_HideTextTooltip()
            end
        )
    end

    if (widgetSettings.onClick ~= nil) then
        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseDown",
            function()
                widgetSettings.onClick()
            end
        )
    end

    self.spacer = WINDOW_MANAGER:CreateControl(name .. "_spacer", self.control, CT_LABEL)
    self.spacer:SetDimensions(10, widgetSettings.iconHeight or 32)
    self.spacer:SetAnchor(widgetSettings.valueSide == LEFT and RIGHT or LEFT, self.value, widgetSettings.valueSide)
end

-- add functions to the widget to mimic a standard control
-- set the widget value and adjust the value control's width accordingly
function baseWidget:SetProgress(value, min, max)
    if (self.value:GetValue() == value) then
        return
    end

    if (max and value) then
        self.value:SetMinMax(min, max)
        self.value.progress:SetText(value .. "/" .. max)
        self.value:SetValue(value)
    end
end

function baseWidget:SetValue(value)
    if (self.value:GetText() == value) then
        return
    end

    self.value:SetText(value)

    local textWidth = self.value:GetStringWidth(value)

    if (self.minWidthChars ~= nil) then
        local minWidth = self.value:GetStringWidth(self.minWidthChars)

        if (minWidth > textWidth) then
            textWidth = minWidth
        end
    end

    local scale = self.control:GetScale()

    textWidth = textWidth / (GetUIGlobalScale() * scale)

    self.value:SetWidth(textWidth)
end

function baseWidget:SetIcon(value)
    self.icon:SetTexture(value)
end

function baseWidget:GetValue()
    return self.value:GetText()
end

function baseWidget:GetWidth()
    return self.control:GetWidth()
end

function baseWidget:GetHeight()
    return self.icon:GetHeight()
end

function baseWidget:SetAnchor(...)
    self.control:SetAnchor(...)
end

function baseWidget:GetAnchor()
    return self.control:GetAnchor()
end

function baseWidget:ClearAnchors()
    self.control:ClearAnchors()
end

function baseWidget:SetHidden(hidden)
    self.control:SetHidden(hidden)
    self.isHidden = hidden
end

function baseWidget:IsHidden()
    return self.isHidden or false
end

function baseWidget:SetColour(...)
    self.value:SetColor(...)
end

function baseWidget:SetTooltip(tooltip)
    self.tooltip = tooltip
end

function baseWidget:SetTextureCoords(...)
    self.icon:SetTextureCoords(...)
end

function BS.CreateWidget(...)
    local widget = baseWidget:New(...)
    return widget
end
