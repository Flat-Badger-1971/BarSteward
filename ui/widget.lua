local BS = _G.BarSteward

local baseWidget = ZO_Object:Subclass()

function baseWidget:New(...)
    local widget = ZO_Object.New(self)
    widget:Initialise(...)

    return widget
end

function baseWidget:Initialise(metadata, parent, tooltipAnchor, valueSide)
    local name = BS.Name .. "_Widget_" .. metadata.name

    self.name = metadata.name
    self.minWidthChars = metadata.minWidthChars
    self.control = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    self.control:SetResizeToFitDescendents(true)
    self.control.ref = self

    local texture

    if (type(metadata.icon) == "function") then
        texture = metadata.icon()
    else
        texture = metadata.icon
    end

    self.icon = WINDOW_MANAGER:CreateControl(name .. "_icon", self.control, CT_TEXTURE)
    self.icon:SetTexture(texture)
    self.icon:SetDimensions(metadata.iconWidth or 32, metadata.iconHeight or 32)
    self.icon:SetAnchor(valueSide == LEFT and RIGHT or LEFT)

    if (metadata.progress) then
        self.value = BS.CreateProgressBar(name .. "_progress", self.control)
        self.value:SetAnchor(
            valueSide == LEFT and RIGHT or LEFT,
            self.icon,
            valueSide,
            valueSide == LEFT and -10 or 10,
            0
        )
        self.value:SetDimensions(200, 32)
        self.value:SetMinMax(0, 100)
        self.value.progress:SetColor(
            unpack(BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].ProgressColour or BS.Vars.DefaultWarningColour)
        )
        self.value.progress:SetFont(BS.GetFont(BS.Vars.Font))

        if (metadata.gradient) then
            local startg, endg = metadata.gradient()
            local sr, sg, sb = unpack(startg)
            local er, eg, eb = unpack(endg)

            self.value:SetGradientColors(sr, sg, sb, 1, er, eg, eb, 1)
        end
    else
        self.value = WINDOW_MANAGER:CreateControl(name .. "_value", self.control, CT_LABEL)
        self.value:SetFont(BS.GetFont(BS.Vars.Font))
        self.value:SetColor(unpack(BS.Vars.DefaultColour))
        self.value:SetAnchor(
            valueSide == LEFT and RIGHT or LEFT,
            self.icon,
            valueSide,
            valueSide == LEFT and -10 or 10,
            0
        )
        self.value:SetDimensions(metadata.valueWidth or 50, metadata.iconHeight or 32)
        self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end

    self.tooltip = metadata.tooltip

    if (metadata.tooltip) then
        local anchorControl = self.value

        if (tooltipAnchor == LEFT) then
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

                if (not IsInGamepadPreferredMode()) then
                    BS.InfoTTDims = {_G.InformationTooltip:GetDimensionConstraints()}
                    _G.InformationTooltip:SetDimensionConstraints(
                        BS.InfoTTDims[1],
                        BS.InfoTTDims[2],
                        0,
                        BS.InfoTTDims[4]
                    )
                end

                ZO_Tooltips_ShowTextTooltip(anchorControl, tooltipAnchor or BOTTOM, tooltip)
            end
        )

        self.control:SetHandler(
            "OnMouseExit",
            function()
                ZO_Tooltips_HideTextTooltip()

                if (BS.InfoTTDims) then
                    -- reset the tooltip to its default values so as no to interfere with other users
                    _G.InformationTooltip:SetDimensionConstraints(
                        BS.InfoTTDims[1],
                        BS.InfoTTDims[2],
                        BS.InfoTTDims[3],
                        BS.InfoTTDims[4]
                    )
                end
            end
        )
    end

    if (metadata.onClick ~= nil) then
        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseDown",
            function()
                metadata.onClick()
            end
        )
    end

    self.spacer = WINDOW_MANAGER:CreateControl(name .. "_spacer", self.control, CT_LABEL)
    self.spacer:SetDimensions(10, metadata.iconHeight or 32)
    self.spacer:SetAnchor(valueSide == LEFT and RIGHT or LEFT, self.value, valueSide)
end

-- add functions to the widget to mimic a standard control
-- set the widget value and adjust the value control's width accordingly
function baseWidget:SetProgress(value, min, max)
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

function baseWidget:SetFont(font)
    if (self.value.progress) then
        self.value.progress:SetFont(font)
    else
        self.value:SetFont(font)
    end
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
