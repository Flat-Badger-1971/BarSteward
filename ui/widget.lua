local DEBUG = false
local BS = _G.BarSteward

local baseWidget = ZO_Object:Subclass()

function baseWidget:New(...)
    local widget = ZO_Object.New(self)
    widget:Initialise(...)

    return widget
end

function baseWidget:Initialise()
    self.control = self.control or WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_CONTROL)
    self.control:SetResizeToFitDescendents(true)
    self.control.ref = self

    if (DEBUG) then
        self.overlay = self.overlay or WINDOW_MANAGER:CreateControl(nil, self.control, CT_CONTROL)
        self.overlay:SetDrawTier(_G.DT_HIGH)
        self.overlay:ClearAnchors()
        self.overlay:SetAnchorFill(self.bar)

        self.overlay.background = self.overlay.background or WINDOW_MANAGER:CreateControl(nil, self.overlay, CT_TEXTURE)
        self.overlay.background:ClearAnchors()
        self.overlay.background:SetAnchorFill(self.overlay)
        self.overlay.background:SetTexture("/esoui/art/itemupgrade/eso_itemupgrade_blueslot.dds")
    end
end

function baseWidget:ApplyFontCorrection()
    if (BS.Vars.FontCorrection and not self.fontCheckApplied) then
        -- create an invisible label for width testing so it doesn't mess with the visible one
        local parent = self:GetParent()

        if (not parent.ref.fontCheck) then
            parent.ref.fontCheck =
                WINDOW_MANAGER:CreateControl(BS.Name .. "_FONT_CHECKER_" .. parent.ref.index, parent, CT_LABEL)
            parent.ref.fontCheck:SetFont(self.font)
            parent.ref.fontCheck:SetAnchor(TOPLEFT)
            parent.ref.fontCheck:SetDimensions(50, 32)
            parent.ref.fontCheck:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            parent.ref.fontCheck:SetHidden(true)
        end

        self.fontCheck = parent.ref.fontCheck
        self.fontCheckApplied = true
    end
end

function baseWidget:CreateSpacer()
    self.spacer = self.spacer or WINDOW_MANAGER:CreateControl(nil, self.control, CT_LABEL)
    self.spacer:SetDimensions(self.horizontalPadding, self.verticalPadding)
    self.spacer:ClearAnchors()
    self.spacer:SetAnchor(
        self.valueSide == LEFT and RIGHT or LEFT,
        (self.noValue and self.icon or self.value),
        self.valueSide
    )
end

function baseWidget:CreateTooltip(tooltip)
    if (tooltip) then
        local anchorControl = self.noValue and self.icon or self.value

        self.tooltip = tooltip

        if (self.tooltipAnchor == LEFT) then
            anchorControl = self.icon
        end

        local function getTooltip()
            if (not BS.Vars.HideMouse) then
                if (self:HasOnClick()) then
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
                local tooltiptext = getTooltip()

                if (not IsInGamepadPreferredMode()) then
                    BS.InfoTTDims = {_G.InformationTooltip:GetDimensionConstraints()}
                    _G.InformationTooltip:SetDimensionConstraints(
                        BS.InfoTTDims[1],
                        BS.InfoTTDims[2],
                        0,
                        BS.InfoTTDims[4]
                    )
                end

                ZO_Tooltips_ShowTextTooltip(anchorControl, self.tooltipAnchor or BOTTOM, tooltiptext)
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
end

function baseWidget:SetOnClick(onClick)
    if (onClick) then
        self.hasOnClick = true
        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseDown",
            function()
                onClick()
            end
        )
    else
        self.hasOnClick = false
    end
end

function baseWidget:HasOnClick()
    return self.hasOnClick == true
end

function baseWidget:SetTooltipAnchor(anchor)
    self.tooltipAnchor = anchor
end

function baseWidget:GetTooltipAnchor()
    return self.tooltipAnchor
end

BS.ProgressIndex = 0

function baseWidget:CreateProgress(progress, gradient)
    if (progress) then
        local name = BS.Name .. "_progress_" .. BS.ProgressIndex

        BS.ProgressIndex = BS.ProgressIndex + 1
        self.value = self.value or BS.CreateProgressBar(name, self.control)
        self.value:ClearAnchors()
        self.value:SetAnchor(
            self.valueSide == LEFT and RIGHT or LEFT,
            self.icon,
            self.valueSide,
            self.valueSide == LEFT and -10 or 10,
            0
        )
        self.value:SetDimensions(200, 32)
        self.value:SetMinMax(0, 100)
        self.value.progress:SetColor(unpack(BS.Vars.Controls[self.id].ProgressColour or BS.Vars.DefaultWarningColour))
        self.value.progress:SetFont(self.font)

        if (gradient) then
            local startg, endg = gradient()
            local sr, sg, sb = unpack(startg)
            local er, eg, eb = unpack(endg)

            self.value:SetGradientColors(sr, sg, sb, 1, er, eg, eb, 1)
        end
    else
        if (not self:HasNoValue()) then
            self.value = self.value or WINDOW_MANAGER:CreateControl(nil, self.control, CT_LABEL)
            self.value:SetFont(self.font)
            self.value:SetColor(unpack(BS.Vars.DefaultColour))
            self.value:ClearAnchors()
            self.value:SetAnchor(
                self.valueSide == LEFT and RIGHT or LEFT,
                self.icon,
                self.valueSide,
                self.valueSide == LEFT and -10 or 10,
                0
            )
            self.value:SetDimensions(50, 32)
            self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end
end

function baseWidget:SetInitialFont()
    if (self.barSettings.Override and self.barSettings.Font) then
        self.font = BS.GetFont(self.barSettings)
    else
        self.font = BS.GetFont()
    end
end

function baseWidget:GetInitialFont()
    return self.font
end

function baseWidget:CreateCooldown()
    self.icon.cooldown = self.icon.cooldown or WINDOW_MANAGER:CreateControl(nil, self.icon, CT_COOLDOWN)
    self.icon.cooldown:SetDimensions(self.icon:GetWidth(), self.icon:GetHeight())
    self.icon.cooldown:ClearAnchors()
    self.icon.cooldown:SetAnchor(CENTER, self.icon, CENTER, 0, 0)
    self.icon.cooldown:SetFillColor(0, 0.1, 0.1, 0.6)
    self.icon.cooldown:SetHidden(true)
end

function baseWidget:CreateIcon(icon)
    local texture

    if (type(icon) == "function") then
        texture = icon()
    else
        texture = icon
    end

    self.icon = self.icon or WINDOW_MANAGER:CreateControl(nil, self.control, CT_TEXTURE)
    self.icon:SetTexture(texture)
    self.icon:SetDimensions(self.iconSize, self.iconSize)
    self.icon:ClearAnchors()
    self.icon:SetAnchor(self.valueSide == LEFT and RIGHT or LEFT)
end

function baseWidget:SetValueSide(valueSide)
    self.valueSide = valueSide
end

function baseWidget:GetValueSide()
    return self.valueSide
end

function baseWidget:SetPadding()
    local horizontalPadding = BS.Vars.HorizontalPadding or 0
    local verticalPadding = BS.Vars.VerticalPadding or 0

    if (self.barSettings.Override) then
        horizontalPadding = self.barSettings.HorizontalPadding or 0
        verticalPadding = self.barSettings.VerticalPadding or 0
    end

    self.horizontalPadding = horizontalPadding + 10
    self.minVertical = self.iconSize
    self.verticalPadding = verticalPadding + self.minVertical
end

function baseWidget:GetPadding()
    return self.horizontalPadding, self.verticalPadding
end

function baseWidget:SetIconSize()
    self.iconSize = self.barSettings.Override and self.barSettings.IconSize or BS.Vars.IconSize

    if (self.iconSize == nil) then
        self.iconSize = BS.Vars.IconSize
    end
end

function baseWidget:GetIconSize()
    return self.iconSize
end

function baseWidget:SetBarSettings(settings)
    self.barSettings = settings
end

function baseWidget:GetBarSettings()
    return self.barSettings
end

function baseWidget:SetId(id)
    self.id = id
end

function baseWidget:GetId()
    return self.id
end

function baseWidget:SetNoValue(noValue)
    self.noValue = noValue
end

function baseWidget:HasNoValue()
    return self.noValue == true
end

function baseWidget:SetParent(parent)
    self.control:SetParent(parent)
end

function baseWidget:GetParent()
    return self.control:GetParent()
end

function baseWidget:SetMinWidthChars(minWidthChars)
    self.minWidthChars = minWidthChars
end

function baseWidget:GetMinWidthChars()
    return self.minWidthChars
end

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

    if (self.value) then
        if (self.value.progress) then
            self.value.progress:SetFont(font)
        else
            self.value:SetFont(font)
        end
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

local function checkOrCreatePool()
    if (not BS.WidgetObjectPool) then
        BS.WidgetObjects = {}
        BS.WidgetObjectPool =
            ZO_ObjectPool:New(
            -- factory
            function()
                d("new")
                return baseWidget:New()
            end,
            --reset
            function(widget)
                -- if (widget.value) then
                --     if (not widget.value.progress) then
                --         widget.value:SetText("")
                --     end

                --     widget.value:ClearAnchors()
                -- end

                -- if (widget.icon) then
                --     widget.icon:SetTexture("")
                --     widget.icon:ClearAnchors()
                -- end
                widget.control:SetHidden(true)
                widget:SetParent(GuiRoot)
                widget:ClearAnchors()

                widget.destroyed = true
            end
        )
    end
end

function BS.CreateWidget(metadata, parent, tooltipAnchor, valueSide, noValue, barSettings)
    checkOrCreatePool()

    -- try to resuse the original widget
    local widgetKey = BS.WidgetObjects[metadata.id]
    local widget, key = BS.WidgetObjectPool:AcquireObject(widgetKey)
    local extant = BS.GetByValue(BS.WidgetObjects, key)

    -- if this widget was being used by something else previously, clear it
    -- so a new one will be created
    if (extant) then
        BS.WidgetObjects[extant] = nil
    end

    BS.WidgetObjects[metadata.id] = key

    widget:SetMinWidthChars(metadata.minWidthChars)
    widget:SetParent(parent)
    widget:SetNoValue(noValue)
    widget:SetId(metadata.id)
    widget:SetBarSettings(barSettings)
    widget:SetIconSize()
    widget:SetPadding()
    widget:SetValueSide(valueSide)
    widget:CreateIcon(metadata.icon)
    widget:CreateCooldown()
    widget:SetInitialFont()
    widget:CreateProgress(metadata.progress, metadata.gradient)
    widget:SetTooltipAnchor(tooltipAnchor)
    widget:SetOnClick(metadata.onClick)
    widget:CreateTooltip(metadata.tooltip)
    widget:CreateSpacer()
    widget:ApplyFontCorrection()
    widget:SetHidden(false)

    widget.destroyed = false

    return widget
end
