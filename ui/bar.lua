local BS = _G.BarSteward

local baseBar = ZO_Object:Subclass()

function baseBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialise(...)

    return bar
end

function baseBar:Initialise(barSettings)
    local barName = BS.Name .. "_bar_" .. barSettings.index
    local settings = barSettings.settings

    self.name = barName
    self.index = barSettings.index
    self.position = barSettings.position
    self.orientation = (barSettings.position == TOP or barSettings == BOTTOM) and "horizontal" or "vertical"
    self.defaultHeight = barSettings.iconHeight or 32

    self.bar = WINDOW_MANAGER:CreateTopLevelWindow(barName)
    self.bar.ref = self
    self.bar:SetScale(barSettings.scale)

    local valueSide = BS.Vars.Bars[barSettings.index].ValueSide

    self.valueSide = BS.GetAnchorFromText(valueSide)

    local x = BS.Vars.Bars[barSettings.index].Position.X
    local y = BS.Vars.Bars[barSettings.index].Position.Y

    local barAnchor = BS.GetAnchorFromText(BS.Vars.Bars[barSettings.index].Anchor, true)

    self.bar:SetAnchor(barAnchor, GuiRoot, TOPLEFT, x, y)
    self.bar:SetMouseEnabled(true)

    if (BS.Vars.Movable) then
        self.bar:SetMovable(true)
    end

    -- save the bar position after it's moved
    local onMouseUp = function()
        local anchor = BS.GetAnchorFromText(BS.Vars.Bars[barSettings.index].Anchor)
        local xPos, yPos

        if (anchor == CENTER) then
            xPos, yPos = self.bar:GetCenter()
        elseif (anchor == LEFT) then
            xPos, yPos = self.bar:GetLeft(), self.bar:GetTop()
        elseif (anchor == RIGHT) then
            xPos, yPos = self.bar:GetRight(), self.bar:GetTop()
        end

        BS.Vars.Bars[barSettings.index].Position = {X = xPos, Y = yPos}
    end

    self.bar:SetHandler("OnMouseUp", onMouseUp)

    self.bar.background = WINDOW_MANAGER:CreateControl(barName .. "_background", self.bar, CT_BACKDROP)
    self.bar.background:SetAnchorFill(self.bar)
    self.bar.background:SetCenterColor(unpack(settings.Backdrop.Colour))
    self.bar.background:SetEdgeColor(0, 0, 0, 0)
    self.bar.background:SetHidden(not settings.Backdrop.Show)

    self.handle = WINDOW_MANAGER:CreateControl(barName .. "_handle", self.bar, CT_CONTROL)
    self.handle:SetDimensions(16, 32)
    self.handle:SetAnchor(TOPRIGHT, self.bar, TOPLEFT)
    self.handle.anchor = LEFT
    self.handle:SetMouseEnabled(true)
    self.handle:SetHandler(
        "OnMouseDown",
        function()
            self.bar:StartMoving()
        end
    )

    local adjustHandle = function()
        -- adjust the position of the handle if it's close the left edge of the screen
        if (self.handle:GetLeft() < 80 and self.handle.anchor ~= RIGHT) then
            self.handle:ClearAnchors()
            self.handle:SetAnchor(TOPLEFT, self.bar, TOPRIGHT)
            self.handle.anchor = RIGHT
        elseif (self.handle.anchor ~= LEFT and self.handle:GetLeft() >= 80) then
            self.handle:ClearAnchors()
            self.handle:SetAnchor(TOPRIGHT, self.bar, TOPLEFT)
            self.handle.anchor = LEFT
        end
    end

    adjustHandle()

    self.handle:SetHandler(
        "OnMouseUp",
        function()
            adjustHandle()
            onMouseUp()
        end
    )

    self.handle:SetHidden(not BS.Vars.Movable)

    self.handle.background = WINDOW_MANAGER:CreateControl(barName .. "handle_background", self.handle, CT_BACKDROP)
    self.handle.background:SetAnchorFill(self.handle)
    self.handle.background:SetCenterColor(unpack(settings.Backdrop.Colour))
    self.handle.background:SetEdgeColor(0, 0, 0, 0)
    self.handle.background:SetHidden(not settings.Backdrop.Show)

    self.handle.icon = WINDOW_MANAGER:CreateControl(barName .. "_handle_icon", self.handle.background, CT_TEXTURE)
    self.handle.icon:SetTexture("/esoui/art/dye/dye_amorslot_highlight.dds")
    self.handle.icon:SetDimensions(6, 32)
    self.handle.icon:SetAnchor(CENTER)

    if (BS.Vars.Bars[self.index].NudgeCompass == true) then
        -- something is making the compass jump back to its original position
        -- this puts it back again, but it's nasty - what's causing the move in the first place?
        EVENT_MANAGER:RegisterForUpdate(BS.Name, 500, function() BS.NudgeCompass() end)
    end

    -- prevent the bar from displaying when not in hud or hudui modes
    self.bar.fragment = ZO_HUDFadeSceneFragment:New(self.bar)
    SCENE_MANAGER:GetScene("hud"):AddFragment(self.bar.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.bar.fragment)
end

-- hide the widget, also shrink it to shrink the bar whilst retaining the anchors for the other widgets
local function SetHiddenWidget(widget, hidden)
    if (hidden and widget:IsHidden()) or (not hidden and not widget:IsHidden()) then
        return
    end

    if (hidden) then
        widget.control:SetResizeToFitDescendents(false)
        widget.control:SetDimensions(0, 0)
        widget:SetHidden(true)
    else
        widget.control:SetResizeToFitDescendents(true)
        widget:SetHidden(false)
    end
end

local function HideWhen(metadata, value)
    local hideValue

    if (metadata.complete and value == "hide it!") then
        SetHiddenWidget(metadata.widget, true)

        return
    end

    if (metadata.hideWhenTrue) then
        hideValue = metadata.hideWhenTrue()
        SetHiddenWidget(metadata.widget, hideValue)

        if (hideValue == true) then
            return
        end

        return
    end

    if (metadata.hideWhenEqual) then
        if (type(metadata.hideWhenEqual) == "function") then
            hideValue = metadata.hideWhenEqual(value)
        else
            hideValue = metadata.hideWhenEqual
        end

        SetHiddenWidget(metadata.widget, hideValue == value)
    end

    if (metadata.hideWhenLessThan) then
        if (type(metadata.hideWhenLessThan) == "function") then
            hideValue = metadata.hideWhenLessThan(value)
        else
            hideValue = metadata.hideWhenLessThan
        end

        SetHiddenWidget(metadata.widget, hideValue < value)
    end

    if (metadata.hideWhenGreaterThan) then
        if (type(metadata.hideWhenGreaterThan) == "function") then
            hideValue = metadata.hideWhenGreaterThan(value)
        else
            hideValue = metadata.hideWhenGreaterThan
        end

        SetHiddenWidget(metadata.widget, hideValue > value)
    end
end

function baseBar:DoUpdate(metadata, ...)
    -- update the widget and capture the raw value for use in HideWhen
    -- get the widget's current (new) value
    local value = metadata.update(metadata.widget, ...)
    local hidecheck = false

    -- check for hide on completion
    if (metadata.complete) then
        if (BS.Vars.Controls[metadata.id].HideWhenComplete) then
            hidecheck = true
            if (metadata.complete() == true) then
                HideWhen(metadata, "hide it!")
            end
        end
    end

    -- check if it needs to be hidden
    if (metadata.hideWhenEqual or metadata.hideWhenGreaterThan or metadata.hideWhenLessThan) then
        if (BS.Vars.Controls[metadata.id].Autohide and not hidecheck) then
            HideWhen(metadata, value)
        end
    end

    -- check for hide when true
    if (metadata.hideWhenTrue) then
        HideWhen(metadata, value)
    end

    -- check if a sound needs to be played
    local sound = nil

    if (BS.Vars.Controls[metadata.id].SoundWhenEquals) then
        if (tostring(BS.Vars.Controls[metadata.id].SoundWhenEqualsValue) == tostring(value)) then
            sound = BS.SoundLookup[BS.Vars.Controls[metadata.id].SoundWhenEqualsSound]
        else
            BS.SoundLastPlayed[metadata.id] = nil
        end
    elseif (BS.Vars.Controls[metadata.id].SoundWhenOver) then
        local compareTo = tonumber(BS.Vars.Controls[metadata.id].SoundWhenOverValue)
        local current = tonumber(value)

        if (current and compareTo) then
            if (current > compareTo) then
                sound = BS.SoundLookup[BS.Vars.Controls[metadata.id].SoundWhenOverSound]
            else
                BS.SoundLastPlayed[metadata.id] = nil
            end
        end
    elseif (BS.Vars.Controls[metadata.id].SoundWhenUnder) then
        local compareTo = tonumber(BS.Vars.Controls[metadata.id].SoundWhenUnderValue)
        local current = tonumber(value)

        if (current and compareTo) then
            if (current < compareTo) then
                sound = BS.SoundLookup[BS.Vars.Controls[metadata.id].SoundWhenUnderSound]
            else
                BS.SoundLastPlayed[metadata.id] = nil
            end
        end
    end

    if (sound) then
        local play = BS.SoundLastPlayed[metadata.id] == nil

        if (BS.SoundLastPlayed[metadata.id]) then
            if ((os.time() - BS.SoundLastPlayed[metadata.id].time) < 61) then
                play = false
            end

            if (BS.SoundLastPlayed[metadata.id].value == value) then
                play = false
            end
        end

        if (play) then
            PlaySound(sound)
            BS.SoundLastPlayed[metadata.id] = {time = os.time(), value = value}
        end
    end

    if (... ~= "initial") then
        self:ResizeBar()
    end
end

function baseBar:ResizeBar()
    if (self.orientation == "horizontal") then
        local width = self:GetCalculatedWidth()
        self.bar:SetWidth(width)
        self.bar:SetHeight(self.defaultHeight)
    else
        local width = self:GetMaxWidgetWidth()
        self.bar:SetWidth(width)
        local height = self:GetCalculatedHeight()
        self.bar:SetHeight(height)
    end
end

-- calculate the current width of the visible widgets
function baseBar:GetCalculatedWidth()
    local width = 0

    for _, widget in pairs(self.widgets) do
        if (widget.widget:IsHidden() == false) then
            width = width + widget.widget:GetWidth()
        end
    end

    return width
end

function baseBar:GetCalculatedHeight()
    local height = 0
    local widgetCount = 0

    for _, widget in pairs(self.widgets) do
        if (widget.widget:IsHidden() == false) then
            height = height + widget.widget:GetHeight()
            widgetCount = widgetCount + 1
        end
    end

    return height
end

function baseBar:GetMaxWidgetWidth()
    local maxWidth = 20
    local width

    for _, widget in pairs(self.widgets) do
        width = widget.widget:GetWidth()
        if (width > maxWidth) then
            maxWidth = width
        end
    end

    return maxWidth
end

function baseBar:AddWidgets(widgets)
    local tooltipAnchorTrans = BS.Vars.Bars[self.index].TooltipAnchor
    local tooltipAnchor

    tooltipAnchor = BS.GetAnchorFromText(tooltipAnchorTrans)

    local firstWidget = true
    local previousWidget

    self.widgets = {}

    for idx, metadata in ipairs(widgets) do
        -- draw the widget
        metadata.widget =
            BS.CreateWidget(
            {
                icon = metadata.icon,
                minWidthChars = metadata.minWidthChars,
                name = metadata.name,
                parent = self.bar,
                tooltip = metadata.tooltip,
                tooltipAnchor = tooltipAnchor,
                valueSide = self.valueSide,
                onClick = metadata.onClick
            }
        )

        -- register widgets that need to watch for events
        if (metadata.event) then
            local events

            if (type(metadata.event) == "table") then
                events = metadata.event
            else
                events = {metadata.event}
            end

            for _, event in ipairs(events) do
                BS.RegisterForEvent(
                    event,
                    function(_, ...)
                        self:DoUpdate(metadata, ...)
                    end
                )
            end

            if (metadata.filter) then
                for event, filterInfo in pairs(metadata.filter) do
                    EVENT_MANAGER:AddFilterForEvent(BS.Name, event, filterInfo[1], filterInfo[2])
                end
            end
        end

        -- register wigdets that need to update after a set interval
        if (metadata.timer) then
            EVENT_MANAGER:RegisterForUpdate(
                BS.Name .. metadata.name,
                metadata.timer,
                function()
                    self:DoUpdate(metadata)
                end
            )
        end

        if (self.orientation == "horizontal") then
            if (firstWidget) then
                metadata.widget:SetAnchor(LEFT, self.bar, LEFT)
            else
                metadata.widget:SetAnchor(LEFT, previousWidget.control, RIGHT)
            end
        else
            if (firstWidget) then
                metadata.widget:SetAnchor(
                    self.valueSide == LEFT and TOPRIGHT or TOPLEFT,
                    self.bar,
                    self.valueSide == LEFT and TOPRIGHT or TOPLEFT
                )
            else
                metadata.widget:SetAnchor(
                    self.valueSide == LEFT and TOPRIGHT or TOPLEFT,
                    previousWidget.control,
                    self.valueSide == LEFT and BOTTOMRIGHT or BOTTOMLEFT
                )
            end
        end

        previousWidget = metadata.widget
        firstWidget = false
        self.widgets[idx] = metadata
    end

    for _, widget in ipairs(self.widgets) do
        self:DoUpdate(widget, "initial")
    end

    zo_callLater(
        function()
            self:ResizeBar()
        end,
        200
    )
end

function baseBar:SetAnchor(...)
    self.bar:SetAnchor(...)
end

function BS.CreateBar(...)
    local bar = baseBar:New(...)

    BS.Bars = BS.Bars or {}
    table.insert(BS.Bars, bar.name)

    return bar
end
