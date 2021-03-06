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
    self.bar:SetScale(barSettings.scale * GetUIGlobalScale())
    self.bar:SetResizeToFitDescendents(true)

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
        if (BS.Vars.Bars[self.index].NudgeCompass == true and barSettings.index == 1) then
            BS.NudgeCompass()
        end

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

    self.bar.overlay = WINDOW_MANAGER:CreateControl(barName .. "_overlay", self.bar, CT_CONTROL)
    self.bar.overlay:SetDrawTier(_G.DT_HIGH)
    self.bar.overlay:SetAnchorFill(self.bar)
    self.bar.overlay:SetHidden(true)
    self.bar.overlay:SetMouseEnabled(true)
    self.bar.overlay:SetHandler(
        "OnMouseDown",
        function()
            self.bar:StartMoving()
        end
    )

    self.bar.overlay:SetHandler(
        "OnMouseUp",
        function()
            onMouseUp()
        end
    )

    self.bar.overlay.background =
        WINDOW_MANAGER:CreateControl(barName .. "_overlay_background", self.bar.overlay, CT_TEXTURE)
    self.bar.overlay.background:SetAnchorFill(self.bar.overlay)
    self.bar.overlay.background:SetTexture("/esoui/art/itemupgrade/eso_itemupgrade_wildslot.dds")

    if (BS.Vars.Bars[self.index].NudgeCompass == true and barSettings.index == 1) then
        BS.NudgeCompass()
    end

    -- prevent the bar from displaying when not in hud or hudui modes
    self.bar.fragment = ZO_HUDFadeSceneFragment:New(self.bar)
    SCENE_MANAGER:GetScene("hud"):AddFragment(self.bar.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.bar.fragment)

    BS.AddToScenes("Crafting", barSettings.index, self.bar)
    BS.AddToScenes("Banking", barSettings.index, self.bar)
    BS.AddToScenes("Inventory", barSettings.index, self.bar)
    BS.AddToScenes("Mail", barSettings.index, self.bar)
    BS.AddToScenes("Siege", barSettings.index, self.bar)
    BS.AddToScenes("Menu", barSettings.index, self.bar)
end

-- hide the widget, also shrink it to shrink the bar whilst retaining the anchors for the other widgets
function baseBar:SetHiddenWidget(widget, hidden)
    if (hidden and widget:IsHidden()) or (not hidden and not widget:IsHidden()) then
        return
    end

    if (hidden) then
        widget.control:SetResizeToFitDescendents(false)
        widget.control:SetDimensions(0, 0)
        widget:SetHidden(true)
        self.bar:SetResizeToFitDescendents(false)
        self.bar:SetDimensions(0, 0)
        self.bar:SetResizeToFitDescendents(true)
    else
        widget.control:SetResizeToFitDescendents(true)
        widget:SetHidden(false)
        self.bar:SetResizeToFitDescendents(false)
        self.bar:SetDimensions(0, 0)
        self.bar:SetResizeToFitDescendents(true)
    end
end

function baseBar:HideWhen(metadata, value)
    local hideValue

    if (metadata.complete) then
        if (value == "hide it!") then
            self:SetHiddenWidget(metadata.widget, true)

            return
        else
            self:SetHiddenWidget(metadata.widget, false)
        end
    end

    if (metadata.hideWhenTrue) then
        hideValue = metadata.hideWhenTrue()
        self:SetHiddenWidget(metadata.widget, hideValue)

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

        self:SetHiddenWidget(metadata.widget, hideValue == value)
    end

    if (metadata.hideWhenLessThan) then
        if (type(metadata.hideWhenLessThan) == "function") then
            hideValue = metadata.hideWhenLessThan(value)
        else
            hideValue = metadata.hideWhenLessThan
        end

        self:SetHiddenWidget(metadata.widget, hideValue < value)
    end

    if (metadata.hideWhenGreaterThan) then
        if (type(metadata.hideWhenGreaterThan) == "function") then
            hideValue = metadata.hideWhenGreaterThan(value)
        else
            hideValue = metadata.hideWhenGreaterThan
        end

        self:SetHiddenWidget(metadata.widget, hideValue > value)
    end
end

function baseBar:DoUpdate(metadata, ...)
    -- update the widget and capture the raw value for use in HideWhen
    -- get the widget's current (new) value
    local value = metadata.update(metadata.widget, ...)
    local hidecheck = false

    -- set the intial state as unhidden
    self:SetHiddenWidget(metadata.widget, false)

    -- check for hide on completion
    if (metadata.complete) then
        if (BS.Vars.Controls[metadata.id].HideWhenComplete) then
            hidecheck = true
            if (metadata.complete() == true) then
                self:HideWhen(metadata, "hide it!")
            else
                self:HideWhen(metadata, "unhide it!")
            end
        end
    end

    -- check if it needs to be hidden
    if (metadata.hideWhenEqual or metadata.hideWhenGreaterThan or metadata.hideWhenLessThan) then
        if (BS.Vars.Controls[metadata.id].Autohide and not hidecheck) then
            self:HideWhen(metadata, value)
        end
    end

    -- check for hide when true
    if (metadata.hideWhenTrue) then
        self:HideWhen(metadata, value)
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
        metadata.progress = BS.Defaults.Controls[metadata.id].Progress
        metadata.widget = BS.CreateWidget(metadata, self.bar, tooltipAnchor, self.valueSide)

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
                    function(...)
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
            if (metadata.name == "time") then
                EVENT_MANAGER:RegisterForUpdate(
                    BS.Name .. metadata.name,
                    metadata.timer,
                    function()
                        self:DoUpdate(metadata)
                    end
                )
            else
                BS.RegisterForUpdate(
                    metadata.timer,
                    function()
                        self:DoUpdate(metadata)
                    end
                )
            end
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
