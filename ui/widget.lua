local DEBUG = false
local BS = _G.BarSteward

local baseWidget = ZO_Object:Subclass()

function baseWidget:New(...)
    local widget = ZO_Object.New(self)
    widget:Initialise(...)

    return widget
end

function baseWidget:Initialise(metadata, parent, tooltipAnchor, valueSide, noValue, barSettings)
    local name = BS.Name .. "_Widget_" .. metadata.name

    self.name = metadata.name
    self.minWidthChars = metadata.minWidthChars
    self.control = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    self.control:SetResizeToFitDescendents(true)
    self.control.ref = self
    self.noValue = noValue
    self.id = metadata.id

    local texture

    if (type(metadata.icon) == "function") then
        texture = metadata.icon()
    else
        texture = metadata.icon
    end

    local iconSize = barSettings.Override and barSettings.IconSize or BS.Vars.IconSize

    if (iconSize == nil) then
        iconSize = BS.Vars.IconSize
    end

    local horizontalPadding = (barSettings.Override and (barSettings.HorizontalPadding or 0) or 0) + 10
    local minVertical = iconSize
    local verticalPadding = (barSettings.Override and (barSettings.VerticalPadding or 0) or 0) + minVertical

    self.icon = WINDOW_MANAGER:CreateControl(name .. "_icon", self.control, CT_TEXTURE)
    self.icon:SetTexture(texture)
    self.icon:SetDimensions(iconSize, iconSize)
    self.icon:SetAnchor(valueSide == LEFT and RIGHT or LEFT)

    if (metadata.cooldown) then
        self.icon.cooldown = WINDOW_MANAGER:CreateControl(name .. "_icon_cooldown", self.icon, CT_COOLDOWN)
        self.icon.cooldown:SetDimensions(self.icon:GetWidth(), self.icon:GetHeight())
        self.icon.cooldown:SetAnchor(CENTER, self.icon, CENTER, 0, 0)
        self.icon.cooldown:SetFillColor(0, 0.1, 0.1, 0.6)
        self.icon.cooldown:SetHidden(true)
    end

    local font = BS.GetFont(barSettings.Override and barSettings)

    if (font == nil) then
        font = BS.Vars.Font
    end

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
            unpack(BS.Vars.Controls[metadata.id].ProgressColour or BS.Vars.DefaultWarningColour)
        )
        self.value.progress:SetFont(font)

        if (metadata.gradient) then
            local startg, endg = metadata.gradient()
            local sr, sg, sb = unpack(startg)
            local er, eg, eb = unpack(endg)

            self.value:SetGradientColors(sr, sg, sb, 1, er, eg, eb, 1)
        end
    else
        if (not noValue) then
            self.value = WINDOW_MANAGER:CreateControl(name .. "_value", self.control, CT_LABEL)
            self.value:SetFont(font)
            self.value:SetColor(unpack(BS.Vars.DefaultColour))
            self.value:SetAnchor(
                valueSide == LEFT and RIGHT or LEFT,
                self.icon,
                valueSide,
                valueSide == LEFT and -10 or 10,
                0
            )
            self.value:SetDimensions(metadata.valueWidth or 50, 32)
            self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end

    self.tooltip = metadata.tooltip

    if (metadata.tooltip) then
        local anchorControl = noValue and self.icon or self.value

        if (tooltipAnchor == LEFT) then
            anchorControl = self.icon
        end

        local function getTooltip()
            if (not BS.Vars.HideMouse) then
                if (metadata.onClick) then
                    if (self.tooltip:sub(1, 2) ~= "|t") then
                        self.tooltip = zo_iconFormat(BS.CLICK, 32, 32) .. " " .. self.tooltip
                    end
                end
            end

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

    if (metadata.onClick) then
        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseDown",
            function()
                metadata.onClick()
            end
        )
    end

    self.spacer = WINDOW_MANAGER:CreateControl(name .. "_spacer", self.control, CT_LABEL)
    self.spacer:SetDimensions(horizontalPadding, verticalPadding)
    self.spacer:SetAnchor(valueSide == LEFT and RIGHT or LEFT, (noValue and self.icon or self.value), valueSide)

    if (BS.Vars.FontCorrection) then
        -- create an invisible label for width testing so it doesn't mess with the visible one
        if (not parent.ref.fontCheck) then
            parent.ref.fontCheck =
                WINDOW_MANAGER:CreateControl(BS.Name .. "_FONT_CHECKER_" .. parent.ref.index, parent, CT_LABEL)
            parent.ref.fontCheck:SetFont(font)
            parent.ref.fontCheck:SetAnchor(TOPLEFT)
            parent.ref.fontCheck:SetDimensions(50, 32)
            parent.ref.fontCheck:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            parent.ref.fontCheck:SetHidden(true)
        end
        self.fontCheck = parent.ref.fontCheck
    end

    if (DEBUG) then
        self.overlay = WINDOW_MANAGER:CreateControl(name .. "_overlay", self.control, CT_CONTROL)
        self.overlay:SetDrawTier(_G.DT_HIGH)
        self.overlay:SetAnchorFill(self.bar)

        self.overlay.background = WINDOW_MANAGER:CreateControl(name .. "_overlay_background", self.overlay, CT_TEXTURE)
        self.overlay.background:SetAnchorFill(self.overlay)
        self.overlay.background:SetTexture("/esoui/art/itemupgrade/eso_itemupgrade_blueslot.dds")
    end
end

-- add functions to the widget to mimic a standard control
-- set the widget value and adjust the value control's width accordingly
function baseWidget:SetProgress(value, min, max)
    if (self.noValue) then
        return
    end

    if (max and value) then
        self.value:SetMinMax(min, max)
        self.value.progress:SetText(value .. "/" .. max)
        self.value:SetValue(value)
    end
end

function baseWidget:SetValue(value, plainValue)
    if (self.noValue) then
        return
    end

    if (self.value:GetText() == value) then
        return
    end

    self.value:SetText(value)

    -- use the undecorated value for width calculations
    local textWidth = self.value:GetStringWidth(plainValue or value)

    if (self.minWidthChars ~= nil) then
        local minWidth = self.value:GetStringWidth(self.minWidthChars)

        if (minWidth > textWidth) then
            textWidth = minWidth
        end
    end

    local scale = self.control:GetScale()

    textWidth = textWidth / (GetUIGlobalScale() * scale)

    self.value:SetWidth(textWidth)

    if (BS.Vars.FontCorrection and self.fontCheck and self.value) then
        self.fontCheck:SetHeight(self.value:GetHeight() * 2)
        self.fontCheck:SetWidth(textWidth)
        self.fontCheck:SetText(value)

        if (self.fontCheck:DidLineWrap()) then
            local fontFactor = ((BS.Defaults.FontSize - BS.Vars.FontSize) / BS.Defaults.FontSize) + 0.9
            textWidth = textWidth * fontFactor
            textWidth = textWidth / (GetUIGlobalScale() * scale)

            self.value:SetWidth(textWidth)
        end
    end
end

function baseWidget:SetFont(font)
    if (self.noValue) then
        return
    end

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
    if (self.noValue) then
        return ""
    end

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

function baseWidget:SetColour(...)
    if (not self.noValue) then
        self.value:SetColor(...)
    end
end

function baseWidget:SetTooltip(tooltip)
    self.tooltip = tooltip
end

function baseWidget:SetTextureCoords(...)
    self.icon:SetTextureCoords(...)
end

function baseWidget:StartCooldown(remaining, duration, isSeconds)
    local multiplier = 1

    if (isSeconds) then
        multiplier = 1000
    end

    if (self.icon.cooldown) then
        self.icon.cooldown:StartCooldown(
            remaining * multiplier,
            duration * multiplier,
            CD_TYPE_RADIAL,
            CD_TIME_TYPE_TIME_UNTIL,
            false
        )
        self.icon.cooldown:SetHidden(false)
    end
end

function baseWidget:SetHidden(hidden)
    if (hidden) then
        self.control:SetResizeToFitDescendents(false)
        self.control:SetDimensions(0, 0)
        self.control:SetHidden(true)
        self.isHidden = true
    else
        self.control:SetResizeToFitDescendents(true)
        self.control:SetHidden(false)
        self.isHidden = false
    end
end

function baseWidget:IsHidden()
    return self.isHidden or false
end

function BS.CreateWidget(...)
    local widget = baseWidget:New(...)
    return widget
end
