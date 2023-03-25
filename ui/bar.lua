local BS = _G.BarSteward

local baseBar = ZO_Object:Subclass()

function baseBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialise(...)

    return bar
end

local function getPosition(bar, anchor)
    if (anchor == CENTER) then
        return bar:GetCenter()
    elseif (anchor == LEFT) then
        return bar:GetLeft(), bar:GetTop()
    elseif (anchor == RIGHT) then
        return bar:GetRight(), bar:GetTop()
    end
end

function baseBar:Initialise()
    self.bar = WINDOW_MANAGER:CreateTopLevelWindow()
    self.bar.ref = self
    self.bar:SetResizeToFitDescendents(true)
    self.bar:SetMouseEnabled(true)

    if (BS.Vars.Movable) then
        self.bar:SetMovable(true)
    end

    -- save the bar position after it's moved
    local onMouseUp = function()
        if (BS.Vars.Bars[self.index].NudgeCompass == true and self.index == 1) then
            BS.NudgeCompass()
        end

        local anchor = BS.GetAnchorFromText(BS.Vars.Bars[self.index].Anchor)
        local xPos, yPos = getPosition(self.bar, anchor)
        local snapX, snapY
        local gridSize = BS.Vars.GridSize

        if (BS.Vars.SnapToGrid) then
            snapX = BS.GetNearest(xPos, gridSize)
            snapY = BS.GetNearest(yPos, gridSize)

            self.bar:ClearAnchors()
            self.bar:SetAnchor(self.barAnchor, GuiRoot, TOPLEFT, snapX, snapY)

            xPos, yPos = snapX, snapY
        end

        BS.Vars.Bars[self.index].Position = {X = xPos, Y = yPos}

        -- stop UI mode being reset too soon
        SetGameCameraUIMode(true)
    end

    self.bar:SetHandler("OnMouseUp", onMouseUp)
    self.bar.background = WINDOW_MANAGER:CreateControl(nil, self.bar, CT_BACKDROP)
    self.bar.background:SetAnchorFill(self.bar)
    self.bar.background:SetEdgeColor(0, 0, 0, 0)

    self.bar.border = WINDOW_MANAGER:CreateControl(nil, self.bar, CT_BACKDROP)
    self.bar.border:SetDrawTier(_G.DT_MEDIUM)
    self.bar.border:SetCenterTexture(0, 0, 0, 0)
    self.bar.border:SetAnchorFill(self.bar)

    self.bar.overlay = WINDOW_MANAGER:CreateControl(nil, self.bar, CT_CONTROL)
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

    self.bar.overlay.background = WINDOW_MANAGER:CreateControl(nil, self.bar.overlay, CT_TEXTURE)
    self.bar.overlay.background:SetAnchorFill(self.bar.overlay)
    self.bar.overlay.background:SetTexture("/esoui/art/itemupgrade/eso_itemupgrade_wildslot.dds")

    -- prevent the bar from displaying when not in hud or hudui modes
    self.bar.fragment = ZO_HUDFadeSceneFragment:New(self.bar)

    -- change the bar's colour during combat if required by the user
    BS.RegisterForEvent(
        _G.EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            if (BS.Vars.Bars[self.index].CombatColourChange) then
                if (inCombat == nil) then
                    inCombat = IsUnitInCombat("player")
                end

                if (inCombat) then
                    if ((self.background or 99) ~= 99) then
                        self.bar.background:SetCenterTexture("")
                    end

                    self.bar.background:SetCenterColor(
                        unpack(BS.Vars.Bars[self.index].CombatColour or BS.Vars.DefaultCombatColour)
                    )
                else
                    if ((self.background or 99) ~= 99) then
                        self.bar.background:SetCenterColor(nil)
                        self.bar.background:SetCenterTexture(BS.BACKGROUNDS[self.background])
                    else
                        self.bar.background:SetCenterColor(unpack(self.backdropColour))
                    end
                end
            else
                self.bar.background:SetCenterColor(unpack(self.backdropColour))
            end
        end
    )
end

function baseBar:NudgeCompass()
    if (BS.Vars.Bars[self.index].NudgeCompass == true and self.index == 1) then
        BS.NudgeCompass(self.index)
    end
end

function baseBar:SetBorder()
    if ((self.settings.Border or 99) ~= 99) then
        self.bar.border:SetEdgeTexture(unpack(BS.BORDERS[self.settings.Border]))
    else
        self.bar.border:SetEdgeTexture("", 128, 2)
        self.bar.border:SetEdgeColor(0, 0, 0, 0)
    end
end

function baseBar:SetBackground()
    self.backdropColour = self.settings.Backdrop.Colour

    if ((self.settings.Background or 99) ~= 99) then
        self.bar.background:SetCenterTexture(BS.BACKGROUNDS[self.settings.Background])
    else
        self.bar.background:SetCenterColor(unpack(self.settings.Backdrop.Colour))
    end

    self.bar.background:SetHidden(not self.settings.Backdrop.Show)
end

function baseBar:SetAnchors()
    local x = BS.Vars.Bars[self.index].Position.X
    local y = BS.Vars.Bars[self.index].Position.Y

    self.barAnchor = BS.GetAnchorFromText(BS.Vars.Bars[self.index].Anchor, true)

    self.bar:SetAnchor(self.barAnchor, GuiRoot, TOPLEFT, x, y)
end

function baseBar:GetAnchor(index)
    return self.bar:GetAnchor(index)
end

function baseBar:ClearAnchors()
    self.bar:ClearAnchors()
end

function baseBar:SetValueSide()
    local valueSide = BS.Vars.Bars[self.index].ValueSide

    self.valueSide = BS.GetAnchorFromText(valueSide)
end

function baseBar:GetValueSize()
    return self.valueSide
end

function baseBar:SetScale(scale)
    self.bar:SetScale(scale * GetUIGlobalScale())
end

function baseBar:GetScale()
    return self.bar:GetScale()
end

function baseBar:SetSettings(settings)
    self.settings = settings
end

function baseBar:GetSettings()
    return self.settings
end

function baseBar:SetIconSize(iconSize)
    self.defaultHeight = iconSize or BS.Vars.IconSize
end

function baseBar:GetDefaultHeight()
    return self.defaultHeight
end

function baseBar:SetPositionAndOrientation(position)
    self.position = position
    self.orientation = (self.position == TOP or self.position == BOTTOM) and "horizontal" or "vertical"
end

function baseBar:GetPosition()
    return self.position
end

function baseBar:GetOrientation()
    return self.orientation
end

function baseBar:SetIndex(index)
    self.index = index
end

function baseBar:GetIndex()
    return self.index
end

function baseBar:AddToScenes()
    if (not BS.Vars.Bars[self.index].ShowEverywhere) then
        SCENE_MANAGER:GetScene("hud"):AddFragment(self.bar.fragment)
        SCENE_MANAGER:GetScene("hudui"):AddFragment(self.bar.fragment)

        BS.AddToScenes("Crafting", self.index, self.bar)
        BS.AddToScenes("Banking", self.index, self.bar)
        BS.AddToScenes("Inventory", self.index, self.bar)
        BS.AddToScenes("Mail", self.index, self.bar)
        BS.AddToScenes("Siege", self.index, self.bar)
        BS.AddToScenes("Menu", self.index, self.bar)
        BS.AddToScenes("Interacting", self.index, self.bar)
        BS.AddToScenes("GuildStore", self.index, self.bar)
        BS.AddToScenes("CrownStore", self.index, self.bar)
    end
end

function baseBar:RemoveFromScenes()
    if (not BS.Vars.Bars[self.index].ShowEverywhere) then
        SCENE_MANAGER:GetScene("hud"):RemoveFragment(self.bar.fragment)
        SCENE_MANAGER:GetScene("hudui"):RemoveFragment(self.bar.fragment)

        BS.RemoveFromScenes("Crafting", self.bar)
        BS.RemoveFromScenes("Banking", self.bar)
        BS.RemoveFromScenes("Inventory", self.bar)
        BS.RemoveFromScenes("Mail", self.bar)
        BS.RemoveFromScenes("Siege", self.bar)
        BS.RemoveFromScenes("Menu", self.bar)
        BS.RemoveFromScenes("Interacting", self.bar)
        BS.RemoveFromScenes("GuildStore", self.bar)
    end
end

-- hide the widget, also shrink it to shrink the bar whilst retaining the anchors for the other widgets
function baseBar:SetHiddenWidget(widget, hidden)
    if (hidden and widget:IsHidden()) or (not hidden and not widget:IsHidden()) then
        return
    end

    widget:SetHidden(hidden)
    BS.ResizeBar(self.index)
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
    end

    if (metadata.hideWhenEqual) then
        if (type(metadata.hideWhenEqual) == "function") then
            hideValue = metadata.hideWhenEqual(value)
        else
            hideValue = metadata.hideWhenEqual
        end

        self:SetHiddenWidget(metadata.widget, hideValue == value)

        if (hideValue == value) then
            return
        end
    end

    if (metadata.hideWhenLessThan) then
        if (type(metadata.hideWhenLessThan) == "function") then
            hideValue = metadata.hideWhenLessThan(value)
        else
            hideValue = metadata.hideWhenLessThan
        end

        self:SetHiddenWidget(metadata.widget, hideValue < value)

        if (hideValue < value) then
            return
        end
    end

    if (metadata.hideWhenGreaterThan) then
        if (type(metadata.hideWhenGreaterThan) == "function") then
            hideValue = metadata.hideWhenGreaterThan(value)
        else
            hideValue = metadata.hideWhenGreaterThan
        end

        self:SetHiddenWidget(metadata.widget, hideValue > value)

        if (hideValue > value) then
            return
        end
    end

    if (metadata.hideWhenMaxLevel) then
        if (type(metadata.hideWhenMaxLevel) == "function") then
            hideValue = metadata.hideWhenMaxLevel(value)
        else
            hideValue = metadata.hideWhenMaxLevel
        end

        self:SetHiddenWidget(metadata.widget, hideValue == value)
    end
end

function baseBar:DoUpdate(metadata, ...)
    -- update the widget and capture the raw value for use in HideWhen

    if (self.destroyed) then
        return
    end

    local widgetKey = BS.WidgetObjects[metadata.id]
    local widget = BS.WidgetObjectPool:AcquireObject(widgetKey)

    if (widget.destroyed) then
        return
    end

    -- get the widget's current (new) value
    local value = metadata.update(metadata.widget, ...)
    local hidecheck = false

    -- store the value
    if (not self.widgetValue) then
        self.widgetValue = {}
    end

    self.widgetValue[metadata.id] = value

    -- set the intial state as unhidden
    self:SetHiddenWidget(metadata.widget, false)

    local hidden = false

    --- check for hide on completion
    if (metadata.complete) then
        if (BS.Vars.Controls[metadata.id].HideWhenComplete or BS.Vars.Controls[metadata.id].HideWhenCompleted) then
            hidecheck = true
            if (metadata.complete() == true) then
                self:HideWhen(metadata, "hide it!")
                hidden = true
            else
                self:HideWhen(metadata, "unhide it!")
                hidden = false
            end
        end
    end

    -- check for hide when fully used
    if (metadata.fullyUsed) then
        if (BS.Vars.Controls[metadata.id].HideWhenFullyUsed) then
            hidecheck = true
            if (metadata.fullyUsed() == true) then
                self:HideWhen(metadata, "hide it!")
            elseif (not hidden) then
                self:HideWhen(metadata, "unhide it!")
            end
        end
    end

    -- check if it needs to be hidden
    if (hidecheck == false) then
        if (metadata.hideWhenEqual or metadata.hideWhenGreaterThan or metadata.hideWhenLessThan) then
            if (BS.Vars.Controls[metadata.id].Autohide) then
                self:HideWhen(metadata, value)
            end
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
        local controlDefaults = BS.Defaults.Controls[metadata.id]

        if (controlDefaults) then
            metadata.progress = controlDefaults.Progress
        end

        local noValue = BS.Vars.Controls[metadata.id].NoValue or false

        metadata.widget = BS.CreateWidget(metadata, self.bar, tooltipAnchor, self.valueSide, noValue, self.settings)

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
                    string.format("%s%s", BS.Name, metadata.name),
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

        -- register widgets that need to respond to callbacks
        if (metadata.callback) then
            for object, events in pairs(metadata.callback) do
                for _, event in ipairs(events) do
                    object:RegisterCallback(
                        event,
                        function(...)
                            self:DoUpdate(metadata, ...)
                        end
                    )
                end
            end
        end

        -- register LibCharacterKnowledge callback
        if (metadata.callbackLCK) then
            if (BS.LibCK) then
                BS.LibCK.RegisterForCallback(
                    BS.Name .. metadata.name,
                    BS.LibCK.EVENT_INITIALIZED,
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

function baseBar:Hide()
    self.bar.fragment:SetHiddenForReason("userHidden", true, BS.FADE_IN_TIME, BS.FADE_OUT_TIME)
    self.hidden = true
end

function baseBar:Show()
    self.bar.fragment:SetHiddenForReason("userHidden", false, BS.FADE_IN_TIME, BS.FADE_OUT_TIME)
    self.hidden = false
end

function baseBar:Toggle()
    if (self.hidden) then
        self:Show()
        BS.Vars.Bars[self.index].ToggleState = "shown"
    else
        self:Hide()
        BS.Vars.Bars[self.index].ToggleState = "hidden"
    end
end

local function checkOrCreatePool()
    if (not BS.BarObjectPool) then
        BS.BarObjects = {}
        BS.BarObjectPool =
            ZO_ObjectPool:New(
            -- factory
            function()
                return baseBar:New()
            end,
            --reset
            function(bar)
                bar.destroyed = true
                bar:RemoveFromScenes()
                bar:Hide()
                bar.bar:SetHidden(true)
                bar:ClearAnchors()
            end
        )
    end
end

function BS.CreateBar(barSettings)
    checkOrCreatePool()

    local barKey = BS.BarObjects[barSettings.index]
    local bar, key = BS.BarObjectPool:AcquireObject(barKey)

    BS.BarObjects[barSettings.index] = key

    bar:SetIndex(barSettings.index)
    bar:SetPositionAndOrientation(barSettings.position)
    bar:SetIconSize(barSettings.iconSize)
    bar:SetSettings(barSettings.settings)
    bar:SetScale(barSettings.scale)
    bar:SetValueSide()
    bar:SetAnchors()
    bar:SetBackground()
    bar:SetBorder()
    bar:NudgeCompass()
    bar:AddToScenes()
    bar:Show()

    bar.destroyed = false

    if (bar.bar:IsHidden()) then
        bar.bar:SetHidden(false)
    end

    return bar
end
