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

    if (BS.DEBUG) then
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
                        self.tooltip = BS.Icon(BS.CLICK, nil, 32, 32) .. " " .. self.tooltip
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

function baseWidget:SetOnClick(onLeftClick, onRightClick)
    if (onLeftClick or onRightClick) then
        self.hasOnClick = true
        self.control:SetMouseEnabled(true)
        self.control:SetHandler(
            "OnMouseDown",
            function(_, button)
                if (button == _G.MOUSE_BUTTON_INDEX_LEFT) then
                    if (onLeftClick) then
                        onLeftClick()
                    end
                elseif (button == _G.MOUSE_BUTTON_INDEX_RIGHT) then
                    if (onRightClick) then
                        onRightClick()
                    elseif (onLeftClick) then
                        onLeftClick()
                    end
                end
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

function baseWidget:CreateProgress(progress, gradient, transition)
    local name = BS.Name .. "_progress_" .. BS.ProgressIndex

    BS.ProgressIndex = BS.ProgressIndex + 1

    self.progress = self.progress or BS.CreateProgressBar(name, self.control)
    self.progress:ClearAnchors()
    self.progress:SetDimensions(200, 32)
    self.progress:SetAnchor(
        self.valueSide == LEFT and RIGHT or LEFT,
        self.icon,
        self.valueSide,
        self.valueSide == LEFT and -10 or 10,
        0
    )
    self.progress:SetMinMax(0, 100)
    self.progress.progress:SetColor(unpack(BS.Vars.Controls[self.id].ProgressColour or BS.Vars.DefaultWarningColour))
    self.progress.progress:SetFont(self.font)

    if (gradient) then
        local startg, endg = gradient()
        local sr, sg, sb = unpack(startg)
        local er, eg, eb = unpack(endg)

        self.progress:SetGradientColors(sr, sg, sb, 1, er, eg, eb, 1)
    end

    self.progress:SetHidden(not progress)

    if (not self:HasNoValue()) then
        if (transition) then
            if (self.value and not self.transition) then
                self.value = WINDOW_MANAGER:CreateControlFromVirtual(nil, self.control, "ZO_RollingMeterLabel")
            end

            self.value =
                self.value or WINDOW_MANAGER:CreateControlFromVirtual(nil, self.control, "ZO_RollingMeterLabel")
            self.value:SetHorizontalAlignment(_G.TEXT_ALIGN_LEFT)
            self.value:SetResizeToFitLabels(true)
            self.value.transitionManager = self.value:GetOrCreateTransitionManager()
            self.value.transitionManager:SetMaxTransitionSteps(50)
            self.transition = true
        else
            if (self.value and not self.value.SetFont) then
                self.value = WINDOW_MANAGER:CreateControl(nil, self.control, CT_LABEL)
            end

            self.value = self.value or WINDOW_MANAGER:CreateControl(nil, self.control, CT_LABEL)
            self.value:SetDimensions(50, 32)
            self.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end

        self.value:SetFont(self.font)
        self.value:SetColor(unpack(BS.Vars.DefaultColour))
        self.value:ClearAnchors()

        if (BS.DEBUG) then
            self.value.overlay = self.value.overlay or WINDOW_MANAGER:CreateControl(nil, self.value, CT_CONTROL)
            self.value.overlay:SetDrawTier(_G.DT_HIGH)
            self.value.overlay:ClearAnchors()
            self.value.overlay:SetAnchorFill(self.value)

            self.value.overlay.background =
                self.value.overlay.background or WINDOW_MANAGER:CreateControl(nil, self.value.overlay, CT_TEXTURE)
            self.value.overlay.background:ClearAnchors()
            self.value.overlay.background:SetAnchorFill(self.value.overlay)
            self.value.overlay.background:SetTexture("/esoui/art/itemupgrade/eso_itemupgrade_redslot.dds")
        end

        self:SetValueAnchor()
        self.value:SetHidden(progress ~= false)
    end
end

function baseWidget:SetValueAnchor()
    local icongap = self.noIcon and 0 or (self.barSettings.IconGap or 10)

    self.value:SetAnchor(
        self.valueSide == LEFT and RIGHT or LEFT,
        self.icon,
        self.valueSide,
        self.valueSide == LEFT and (icongap * -1) or icongap,
        0
    )
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

function baseWidget:SetNoIcon(value)
    self.noIcon = value
end

function baseWidget:GetNoIcon()
    return self.noIcon
end

function baseWidget:CreateIcon(icon)
    local texture

    self.icon = self.icon or WINDOW_MANAGER:CreateControl(nil, self.control, CT_TEXTURE)

    if (self.noIcon) then
        self.icon:SetTexture(nil)
        self.icon:SetDimensions(1, self.iconSize)
        self.icon:SetColor(0, 0, 0, 0)
    else
        if (type(icon) == "function") then
            texture = icon()
        else
            texture = icon
        end

        self.icon:SetTexture(BS.FormatIcon(texture))
        self.icon:SetDimensions(self.iconSize, self.iconSize)
    end

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

function baseWidget:SetProgress(value, min, max, text)
    if (self.noValue) then
        return
    end

    if (self.progress:IsHidden()) then
        self.progress:SetHidden(false)
    end

    if (max and value) then
        self.progress:SetMinMax(min, max)
        self.progress.progress:SetText(text or (value .. "/" .. max))
        self.progress:SetValue(value)
    end
end

function baseWidget:SetValue(value, plainValue, immediate)
    if (self.noValue) then
        return
    end

    if (self.value:IsHidden()) then
        self.value:SetHidden(false)
    end

    if (self.transition) then
        -- TODO: figure out how to stop resizing issues
        -- and the control jumping around

        if (immediate) then
            self.value.transitionManager:SetValueImmediately(value)
        else
            self.value.transitionManager:SetValue(value)
        end
    else
        self.value:SetText(value)
    end

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
    if (not self.noIcon) then
        self.icon:SetTexture(BS.FormatIcon(value))
    end
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

function baseWidget:SetColour(r, g, b, a)
    if (not self.noValue) then
        if (type(r) == "table") then
            if (r.New) then
                r, g, b, a = r:UnpackRGBA()
            elseif (r.r) then
                r, g, b, a = r.r, r.g, r.b, r.a
            else
                r, g, b, a = unpack(r)
            end
        end

        self.value:SetColor(r, g, b, a)
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

function baseWidget:ToggleResize(toggle)
    self.control:SetResizeToFitDescendents(toggle == "on")
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
                return baseWidget:New()
            end,
            --reset
            function(widget)
                widget.control:SetHidden(true)
                widget:SetParent(GuiRoot)
                widget:ClearAnchors()

                if (widget.value) then
                    widget.value:SetHidden(true)
                end

                widget.destroyed = true
            end
        )
    end
end

function BS.CreateWidget(metadata, parent, tooltipAnchor, valueSide, noValue, barSettings, noIcon)
    checkOrCreatePool()

    -- try to resuse the original widget
    local widgetKey = BS.WidgetObjects[metadata.id]
    local widget, key = BS.WidgetObjectPool:AcquireObject(widgetKey)
    local extant = BS.GetByValue(BS.WidgetObjects, key)

    -- if this object was being used by something else previously, clear it
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
    widget:SetNoIcon(noIcon)
    widget:CreateIcon(metadata.icon)
    widget:CreateCooldown()
    widget:SetInitialFont()
    widget:CreateProgress(metadata.progress, metadata.gradient, metadata.transition)
    widget:SetTooltipAnchor(tooltipAnchor)
    widget:SetOnClick(metadata.onLeftClick, metadata.onRightClick)
    widget:CreateTooltip(metadata.tooltip)
    widget:CreateSpacer()
    widget:ApplyFontCorrection()
    widget:SetHidden(false)

    widget.destroyed = false

    return widget
end
