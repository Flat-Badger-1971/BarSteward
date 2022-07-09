local BS = _G.BarSteward

BS.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "Bar Steward",
    displayName = "|cff9900Bar Steward|r",
    author = "Flat Badger",
    version = "1.2.16",
    registerForDefaults = true,
    registerForRefresh = true,
    slashCommand = "/bs"
}

local soundChoices = {}
BS.SoundLookup = {}
BS.SoundLastPlayed = {}

-- populate the sound selection and lookup tables
do
    for _, v in ipairs(BS.Sounds) do
        if (_G.SOUNDS[v] ~= nil) then
            local soundName = _G.SOUNDS[v]:gsub("_", " ")
            table.insert(soundChoices, soundName)
            BS.SoundLookup[soundName] = _G.SOUNDS[v]
        end
    end
end

local function initialise()
    BS.options = {}
    BS.options[1] = BS.Vars:GetLibAddonMenuAccountCheckbox()
    BS.options[2] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_MOVEFRAME),
        getFunc = function()
            return BS.Vars.Movable
        end,
        setFunc = function(value)
            BS.Vars.Movable = value

            for _, bar in ipairs(BS.Bars) do
                _G[bar]:SetMovable(value)
                _G[bar].ref.bar.overlay:SetHidden(not value)
            end

            local frame = BS.lock or BS.CreateLockButton()

            if (value) then
                SCENE_MANAGER:Show("hudui")
                SetGameCameraUIMode(true)
                frame.fragment:SetHiddenForReason("disabled", false)
            else
                frame.fragment:SetHiddenForReason("disabled", true)
            end
        end,
        width = "full",
        default = BS.Defaults.Movable
    }
    BS.options[3] = {
        type = "divider",
        alpha = 0
    }
    BS.options[4] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_ALIGN_BARS),
        func = function()
            local frame = BS.frame or BS.CreateAlignmentFrame(BS.alignBars)
            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            frame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "half"
    }
    BS.options[5] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_REORDER_WIDGETS),
        func = function()
            local frame = BS.w_order or BS.CreateWidgetOrderTool(BS.alignBars)
            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            frame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "half"
    }
    BS.options[6] = {
        type = "divider",
        alpha = 0
    }
end

function BS.NewBar()
    local name = BS.NewBarName
    name = name:match("^%s*(.-)%s*$")

    if ((name or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmpty")
        return
    end

    for _, bar in pairs(BS.Vars.Bars) do
        if (bar.name == name) then
            ZO_Dialogs_ShowDialog(BS.Name .. "Exists")
            return
        end
    end

    local bars = BS.Vars.Bars
    local newBarId = #bars + 1
    local x, y = GuiRoot:GetCenter()

    BS.Vars.Bars[newBarId] = {
        Orientation = GetString(_G.BARSTEWARD_HORIZONTAL),
        Position = {X = x, Y = y},
        Name = name,
        Backdrop = {
            Show = true,
            Colour = {0.23, 0.23, 0.23, 0.7}
        },
        TooltipAnchor = GetString(_G.BARSTEWARD_BOTTOM),
        ValueSide = GetString(_G.BARSTEWARD_RIGHT)
    }

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
end

function BS.RemoveBarCheck(index)
    BS.BarIndex = index
    ZO_Dialogs_ShowDialog(BS.Name .. "Remove")
end

function BS.RemoveBar()
    if (BS.BarIndex == nil) then
        return
    end

    BS.Vars.Bars[BS.BarIndex] = nil

    local controls = BS.Vars.Controls

    for k, v in ipairs(controls) do
        if (v.Bar == BS.BarIndex) then
            BS.Vars.Controls[k].Bar = 0
        end
    end

    BS.BarIndex = nil

    zo_callLater(
        function()
            ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
        end,
        200
    )
end

local function getBarSettings()
    local bars = BS.Vars.Bars

    for idx, data in ipairs(bars) do
        local controls = {
            [1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_ORIENTATION),
                choices = {GetString(_G.BARSTEWARD_HORIZONTAL), GetString(_G.BARSTEWARD_VERTICAL)},
                getFunc = function()
                    return BS.Vars.Bars[idx].Orientation
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].Orientation = value
                end,
                width = "full",
                requiresReload = true,
                default = BS.Defaults.Bars[1].Orientation
            },
            [2] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SHOW_BACKDROP),
                getFunc = function()
                    return BS.Vars.Bars[idx].Backdrop.Show
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].Backdrop.Show = value
                    _G[BS.Name .. "_bar_" .. idx].background:SetHidden(not value)
                end,
                default = BS.Defaults.Bars[1].Backdrop.Show
            },
            [3] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_BACKDROP_COLOUR),
                getFunc = function()
                    return unpack(BS.Vars.Bars[idx].Backdrop.Colour)
                end,
                setFunc = function(r, g, b, a)
                    BS.Vars.Bars[idx].Backdrop.Colour = {r, g, b, a}
                    _G[BS.Name .. "_bar_" .. idx].background:SetCenterColor(r, g, b, a)
                end,
                width = "full",
                disabled = function()
                    return not BS.Vars.Bars[idx].Backdrop.Show
                end,
                default = unpack(BS.Defaults.Bars[1].Backdrop.Colour)
            },
            [4] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TOOLTIP_ANCHOR),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT),
                    GetString(_G.BARSTEWARD_TOP),
                    GetString(_G.BARSTEWARD_BOTTOM)
                },
                getFunc = function()
                    return BS.Vars.Bars[idx].TooltipAnchor
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].TooltipAnchor = value
                end,
                requiresReload = true,
                default = BS.Defaults.Bars[1].TooltipAnchor
            },
            [5] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_VALUE_SIDE),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT)
                },
                getFunc = function()
                    return BS.Vars.Bars[idx].ValueSide
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].ValueSide = value
                end,
                requiresReload = true,
                default = BS.Defaults.Bars[1].ValueSide
            },
            [6] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR_ANCHOR),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT),
                    GetString(_G.BARSTEWARD_MIDDLE)
                },
                getFunc = function()
                    return BS.Vars.Bars[idx].Anchor or GetString(_G.BARSTEWARD_MIDDLE)
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].Anchor = value
                end,
                requiresReload = true,
                default = BS.Defaults.Bars[1].Anchor
            },
            [7] = {
                type = "slider",
                name = GetString(_G.BARSTEWARD_SCALE),
                getFunc = function()
                    return BS.Vars.Bars[idx].Scale or 1
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].Scale = value

                    local barToScale = _G[BS.Name .. "_bar_" .. idx]

                    barToScale:SetScale(value * GetUIGlobalScale())
                    barToScale:SetResizeToFitDescendents(false)
                    barToScale:SetWidth(0)
                    barToScale:SetResizeToFitDescendents(true)
                end,
                min = 0.4,
                max = 2,
                step = 0.1,
                decimals = 1,
                width = "full",
                default = BS.Defaults.Bars[1].Scale
            },
            [8] = {
                type = "divider",
                alpha = 0
            },
            [9] = {
                type = "button",
                name = GetString(_G.BARSTEWARD_ALIGN),
                func = function()
                    local bar = _G[BS.Name .. "_bar_" .. idx]
                    local _, posY = bar:GetCenter()
                    local guiHeight = GuiRoot:GetHeight() / 2
                    local centre

                    if (posY > guiHeight) then
                        centre = posY - guiHeight
                    else
                        centre = (guiHeight - posY) * -1
                    end

                    _G[BS.Name .. "_bar_" .. idx]:SetAnchor(CENTER, GuiRoot, CENTER, 0, centre)
                    local xPos, yPos = bar:GetCenter()

                    BS.Vars.Bars[idx].Anchor = GetString(_G.BARSTEWARD_MIDDLE)
                    BS.Vars.Bars[idx].Position = {X = xPos, Y = yPos}
                end,
                width = "full"
            }
        }

        if (idx ~= 1) then
            controls[#controls + 1] = {
                type = "button",
                name = "|ce60000" .. GetString(_G.SI_GAMEPAD_MAIL_SEND_DETACH_ITEM) .. "|r",
                func = function()
                    BS.RemoveBarCheck(idx)
                end,
                width = "full"
            }
        else
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_NUDGE),
                getFunc = function()
                    return BS.Vars.Bars[idx].NudgeCompass
                end,
                setFunc = function(value)
                    BS.Vars.Bars[idx].NudgeCompass = value
                end,
                width = "full",
                requiresReload = true,
                default = BS.Defaults.Bars[1].NudgeCompass,
                warning = GetString(_G.BARSTEWARD_NUDGE_WARNING)
            }
        end

        BS.options[#BS.options + 1] = {
            type = "submenu",
            name = data.Name,
            controls = controls,
            reference = "BarStewardBar" .. idx
        }
    end

    BS.options[#BS.options + 1] = {
        type = "description",
        text = "|ce60000" .. GetString(_G.BARSTEWARD_NEWBAR_WARNING) .. "|r",
        width = "full"
    }

    BS.options[#BS.options + 1] = {
        type = "editbox",
        name = GetString(_G.BARSTEWARD_NEWBAR_NAME),
        getFunc = function()
            return BS.NewBarName or ""
        end,
        setFunc = function(value)
            BS.NewBarName = value
        end,
        isMultiLine = false,
        width = "half"
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_NEWBAR_ADD),
        func = function()
            BS.NewBar()
        end,
        disabled = function()
            return (BS.NewBarName or "") == ""
        end,
        warning = GetString(_G.BARSTEWARD_RELOAD),
        width = "half"
    }
end

-- Performance
local function getPerformanceSettings()
    local controls = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PERFORMANCE_TIMERS),
            tooltip = GetString(_G.BARSTEWARD_PERFORMANCE_TIMERS_TOOLTIP),
            getFunc = function()
                return BS.Vars.DisableTimersInCombat
            end,
            setFunc = function(value)
                BS.Vars.DisableTimersInCombat = value
                BS.CheckPerformance()
            end,
            default = false
        }
    }

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_PERFORMANCE),
        controls = controls,
        reference = "Performance"
    }
end

-- 12 hour time formats
local twelveFormats = {
    "hh:m:s",
    "hh:m:s a",
    "hh:m:s A",
    "h:m:s",
    "h:m:s a",
    "h:m:s A",
    "hh:m",
    "hh:m a",
    "hh:m A",
    "h:m",
    "h:m a",
    "h:m A",
    "hh.m.s",
    "hh.m.s a",
    "hh.m.s A",
    "h.m.s",
    "h.m.s a",
    "h.m.s A",
    "hh.m",
    "hh.m a",
    "hh.m A",
    "h.m",
    "h.m a",
    "h.m A"
}

-- 24 hour time formats
local twentyFourFormats = {
    "HH:m:s",
    "H:m:s",
    "HH:m",
    "H:m",
    "HH.m.s",
    "H.m.s",
    "HH.m",
    "H.m"
}

local function getCV(index)
    local var = BS.Vars.Controls[index].ColourValues
    local lookup = {}

    if (var ~= nil) then
        for _, val in ipairs(BS.Split(var)) do
            lookup[val] = true
        end

        return lookup
    end

    return nil
end

local function getWidgetSettings()
    local widgets = BS.Vars.Controls
    local bars = BS.Vars.Bars
    local none = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_DAMAGETYPE0))
    local controls = {}
    local barNames = {}

    for _, v in ipairs(bars) do
        table.insert(barNames, v.Name)
    end

    table.insert(barNames, none)

    local timeSamples12 = {}
    local timeSamples24 = {}

    for _, format in ipairs(twelveFormats) do
        table.insert(timeSamples12, BS.FormatTime(format, "09:23:12"))
    end

    for _, format in ipairs(twentyFourFormats) do
        table.insert(timeSamples24, BS.FormatTime(format, "09:23:12"))
    end

    -- sort the widget settings into alphabetical order
    local ordered = {}

    for key, widget in ipairs(widgets) do
        table.insert(ordered, {key = key, widget = widget})
    end

    table.sort(
        ordered,
        function(a, b)
            return BS.widgets[a.key].tooltip < BS.widgets[b.key].tooltip
        end
    )

    --for k, v in ipairs(widgets) do
    for idx, w in ipairs(ordered) do
        local k = w.key
        local v = w.widget
        local widgetControls = {
            [1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR),
                choices = barNames,
                getFunc = function()
                    local barName = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_DAMAGETYPE0))

                    if (v.Bar ~= 0) then
                        barName = BS.Vars.Bars[v.Bar].Name
                    end

                    return barName
                end,
                setFunc = function(value)
                    local tbars = BS.Vars.Bars
                    local barNum = 0

                    for bnum, bdata in ipairs(tbars) do
                        if (bdata.Name == value) then
                            barNum = bnum
                        end
                    end

                    BS.Vars.Controls[k].Bar = barNum
                end,
                width = "full",
                requiresReload = true,
                default = BS.Defaults.Controls[k].Bar
            }
        }

        -- Autohide
        if (BS.Defaults.Controls[k].Autohide ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_AUTOHIDE),
                tooltip = GetString(_G.BARSTEWARD_AUTOHIDE_TOOLTIP),
                getFunc = function()
                    return BS.Vars.Controls[k].Autohide
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].Autohide = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref
                        local bar = widget.control:GetParent().ref
                        local metadata = BS.widgets[k]
                        metadata.widget = widget
                        bar:DoUpdate(metadata)
                    end
                end,
                width = "full",
                default = BS.Defaults.Controls[k].Autohide
            }
        end

        -- Hide when complete
        if (BS.Defaults.Controls[k].HideWhenComplete ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE),
                tooltip = GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE_TOOLTIP),
                getFunc = function()
                    return BS.Vars.Controls[k].HideWhenComplete
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].HideWhenComplete = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref
                        local bar = widget.control:GetParent().ref
                        local metadata = BS.widgets[k]
                        metadata.widget = widget
                        bar:DoUpdate(metadata)
                    end
                end,
                width = "full",
                default = BS.Defaults.Controls[k].HideWhenComplete
            }
        end

        -- PvP only
        if (BS.Defaults.Controls[k].PvPOnly ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_PVP_ONLY),
                getFunc = function()
                    return BS.Vars.Controls[k].PvPOnly
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].PvPOnly = value
                    local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref
                    local bar = widget.control:GetParent().ref
                    local metadata = BS.widgets[k]
                    metadata.widget = widget
                    bar:DoUpdate(metadata)
                end,
                width = "full",
                default = BS.Defaults.Controls[k].PvPOnly
            }
        end

        -- Show Percentage
        if (BS.Defaults.Controls[k].ShowPercent ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_PERCENTAGE),
                getFunc = function()
                    return BS.Vars.Controls[k].ShowPercent
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].ShowPercent = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end
                end,
                width = "full",
                default = BS.Defaults.Controls[k].ShowPercent
            }
        end

        -- Use separators
        if (BS.Defaults.Controls[k].UseSeparators ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_ADD_SEPARATORS),
                getFunc = function()
                    return BS.Vars.Controls[k].UseSeparators
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].UseSeparators = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end
                end,
                width = "full",
                default = BS.Defaults.Controls[k].UseSeparators
            }
        end

        -- Hide seconds
        if (BS.Defaults.Controls[k].HideSeconds ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_HIDE_SECONDS),
                getFunc = function()
                    return BS.Vars.Controls[k].HideSeconds
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].HideSeconds = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end
                end,
                width = "full",
                default = BS.Defaults.Controls[k].HideSeconds
            }
        end

        -- Sound when equals
        if (BS.Defaults.Controls[k].SoundWhenEquals ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SOUND_VALUE_EQUALS),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenEquals
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenEquals = value
                end,
                width = "full",
                default = BS.Defaults.Controls[k].SoundWhenEquals
            }

            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_VALUE),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenEqualsValue
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenEqualsValue = value
                end,
                width = "full",
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenEquals
                end,
                default = nil
            }

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_SOUND),
                choices = soundChoices,
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenEqualsSound
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenEqualsSound = value
                    PlaySound(BS.SoundLookup[value])
                end,
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenEquals
                end,
                default = nil
            }
        end

        -- Sound when over
        if (BS.Defaults.Controls[k].SoundWhenOver ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SOUND_VALUE_EXCEEDS),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenOver
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenOver = value
                end,
                width = "full",
                default = BS.Defaults.Controls[k].SoundWhenOver
            }

            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_VALUE),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenOverValue
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenOverValue = value
                end,
                width = "full",
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenOver
                end,
                default = nil
            }

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_SOUND),
                choices = soundChoices,
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenOverSound
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenOverSound = value
                    PlaySound(BS.SoundLookup[value])
                end,
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenOver
                end,
                default = nil
            }
        end

        -- Sound when under
        if (BS.Defaults.Controls[k].SoundWhenUnder ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SOUND_VALUE_BELOW),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenUnder
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenUnder = value
                end,
                width = "full",
                default = BS.Defaults.Controls[k].SoundWhenUnder
            }

            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_VALUE),
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenUnderValue
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenUnderValue = value
                end,
                width = "full",
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenUnder
                end,
                default = nil
            }

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_SOUND),
                choices = soundChoices,
                getFunc = function()
                    return BS.Vars.Controls[k].SoundWhenUnderSound
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].SoundWhenUnderSound = value
                    PlaySound(BS.SoundLookup[value])
                end,
                disabled = function()
                    return not BS.Vars.Controls[k].SoundWhenUnder
                end,
                default = nil
            }
        end

        -- Announcement
        if (BS.Defaults.Controls[k].Announce ~= nil) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = (k == BS.W_FRIENDS) and GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND) or
                    GetString(_G.BARSTEWARD_ANNOUNCEMENT),
                getFunc = function()
                    return BS.Vars.Controls[k].Announce
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].Announce = value
                end,
                width = "full",
                default = BS.Defaults.Controls[k].Announce
            }
        end

        -- Progress bars
        if (BS.Defaults.Controls[k].Progress == true) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_PROGRESS_VALUE),
                getFunc = function()
                    local colour =
                        BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].ProgressColour or BS.Vars.DefaultWarningColour

                    return unpack(colour)
                end,
                setFunc = function(r, g, b, a)
                    BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].ProgressColour = {r, g, b, a}

                    local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_ENDEAVOUR_PROGRESS].name].ref
                    widget.value.progress:SetColor(r, g, b, a)
                end,
                width = "full",
                default = function()
                    return unpack(BS.Vars.DefaultWarningColour)
                end
            }

            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_START),
                getFunc = function()
                    local startg = {
                        GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                    }
                    local colour = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientStart or startg
                    local r, g, b = unpack(colour)

                    return r, g, b
                end,
                setFunc = function(r, g, b)
                    BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientStart = {r, g, b}

                    local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_ENDEAVOUR_PROGRESS].name].ref
                    local endg = {
                        GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                    }
                    local er, eg, eb = unpack(BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientEnd or endg)

                    widget.value:SetGradientColors(r, g, b, 1, er, eg, eb, 1)
                end,
                width = "full",
                default = function()
                    return GetInterfaceColor(
                        _G.INTERFACE_COLOR_TYPE_GENERAL,
                        _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START
                    )
                end
            }

            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_END),
                getFunc = function()
                    local endg = {
                        GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                    }
                    local colour = BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientEnd or endg
                    local r, g, b = unpack(colour)

                    return r, g, b
                end,
                setFunc = function(r, g, b)
                    BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientEnd = {r, g, b}

                    local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[BS.W_ENDEAVOUR_PROGRESS].name].ref
                    local startg = {
                        GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                    }
                    local sr, sg, sb = unpack(BS.Vars.Controls[BS.W_ENDEAVOUR_PROGRESS].GradientStart or startg)

                    widget.value:SetGradientColors(sr, sg, sb, 1, r, g, b, 1)
                end,
                width = "full",
                default = function()
                    return unpack(BS.Vars.DefaultWarningColour)
                end
            }
        end

        -- Custom dropdown option
        local copts = BS.widgets[k].customOptions
        if (copts) then
            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = copts.name,
                tooltip = copts.tooltip,
                choices = copts.choices,
                getFunc = function()
                    return BS.Vars.Controls[k][copts.varName] or copts.default
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k][copts.varName] = value
                    if (copts.refresh) then
                        if (BS.Vars.Controls[k].Bar ~= 0) then
                            BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                        end
                    end
                end,
                width = "full",
                default = copts.default
            }
        end

        -- time
        if (k == 1) then
            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TWELVE_TWENTY_FOUR),
                choices = {GetString(_G.BARSTEWARD_12), GetString(_G.BARSTEWARD_24)},
                getFunc = function()
                    return BS.Vars.TimeType
                end,
                setFunc = function(value)
                    BS.Vars.TimeType = value
                end,
                default = BS.Defaults.TimeType
            }

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TIME_FORMAT_12),
                choices = timeSamples12,
                getFunc = function()
                    local format = BS.Vars.TimeFormat12
                    return BS.FormatTime(format, "09:23:12")
                end,
                setFunc = function(value)
                    local format

                    for _, f in ipairs(twelveFormats) do
                        if (BS.FormatTime(f, "09:23:12") == value) then
                            format = f
                            break
                        end
                    end

                    BS.Vars.TimeFormat12 = format
                end,
                disabled = function()
                    return BS.Vars.TimeType ~= GetString(_G.BARSTEWARD_12)
                end,
                default = BS.Defaults.TimeFormat12
            }

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TIME_FORMAT_24),
                choices = timeSamples24,
                getFunc = function()
                    local format = BS.Vars.TimeFormat24
                    return BS.FormatTime(format, "09:23:12")
                end,
                setFunc = function(value)
                    local format

                    for _, f in ipairs(twentyFourFormats) do
                        if (BS.FormatTime(f, "09:23:12") == value) then
                            format = f
                            break
                        end
                    end

                    BS.Vars.TimeFormat24 = format
                end,
                disabled = function()
                    return BS.Vars.TimeType == GetString(_G.BARSTEWARD_12)
                end,
                default = BS.Defaults.TimeFormat24
            }
        end

        if (BS.Defaults.Controls[k].Timer == true) then
            local timerFormat =
                k == BS.W_LEADS and ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT, 1, 12, 4) or
                ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS, 1, 12, 4, 10)

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TIMER_FORMAT),
                choices = {
                    timerFormat,
                    "01:12:04:10"
                },
                getFunc = function()
                    local default = (k == BS.W_LEADS) and "01:12:04" or "01:12:04:10"

                    return BS.Vars.Controls[k].Format or default
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].Format = value
                    if (BS.Vars.Controls[k].Bar ~= 0) then
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end
                end,
                default = k == BS.W_LEADS and "01:12:04" or "01:12:04:10"
            }
        end

        -- colour / value options
        local cv = getCV(k)

        if (cv) then
            if (cv.c) then
                widgetControls[#widgetControls + 1] = {
                    type = "colorpicker",
                    name = GetString(_G.BARSTEWARD_DEFAULT_COLOUR),
                    getFunc = function()
                        return unpack(BS.Vars.Controls[k].Colour or BS.Vars.DefaultColour)
                    end,
                    setFunc = function(r, g, b, a)
                        BS.Vars.Controls[k].Colour = {r, g, b, a}
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    width = "full",
                    default = unpack(BS.Vars.DefaultColour)
                }
            end

            if (cv.okc) then
                widgetControls[#widgetControls + 1] = {
                    type = "colorpicker",
                    name = GetString(_G.BARSTEWARD_OK_COLOUR),
                    getFunc = function()
                        return unpack(BS.Vars.Controls[k].OkColour or BS.Vars.DefaultOkColour)
                    end,
                    setFunc = function(r, g, b, a)
                        BS.Vars.Controls[k].OkColour = {r, g, b, a}
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    width = "full",
                    default = unpack(BS.Vars.DefaultOkColour)
                }
            end

            if (cv.wc) then
                widgetControls[#widgetControls + 1] = {
                    type = "colorpicker",
                    name = GetString(_G.BARSTEWARD_WARNING_COLOUR),
                    getFunc = function()
                        return unpack(BS.Vars.Controls[k].WarningColour or BS.Vars.DefaultWarningColour)
                    end,
                    setFunc = function(r, g, b, a)
                        BS.Vars.Controls[k].WarningColour = {r, g, b, a}
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    width = "full",
                    default = unpack(BS.Vars.DefaultWarningColour)
                }
            end

            if (cv.dc) then
                widgetControls[#widgetControls + 1] = {
                    type = "colorpicker",
                    name = GetString(_G.BARSTEWARD_DANGER_COLOUR),
                    getFunc = function()
                        return unpack(BS.Vars.Controls[k].DangerColour or BS.Vars.DefaultDangerColour)
                    end,
                    setFunc = function(r, g, b, a)
                        BS.Vars.Controls[k].DangerColour = {r, g, b, a}
                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    width = "full",
                    default = unpack(BS.Vars.DefaultDangerColour)
                }
            end

            local units = BS.Vars.Controls[k].Units

            if (cv.okv) then
                widgetControls[#widgetControls + 1] = {
                    type = "editbox",
                    name = GetString(_G.BARSTEWARD_OK_VALUE) .. (units and (" (" .. units .. ")") or ""),
                    getFunc = function()
                        return BS.Vars.Controls[k].OkValue or ""
                    end,
                    setFunc = function(value)
                        if (value == nil or value == "") then
                            BS.Vars.Controls[k].OkValue = BS.Default.Controls[k].OkValue
                        else
                            BS.Vars.Controls[k].OkValue = tonumber(value)
                        end

                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    textType = _G.TEXT_TYPE_NUMERIC,
                    isMultiLine = false,
                    width = "half",
                    default = nil
                }
            end

            if (cv.wv) then
                widgetControls[#widgetControls + 1] = {
                    type = "editbox",
                    name = GetString(_G.BARSTEWARD_WARNING_VALUE) .. (units and (" (" .. units .. ")") or ""),
                    getFunc = function()
                        return BS.Vars.Controls[k].WarningValue or ""
                    end,
                    setFunc = function(value)
                        if (value == nil or value == "") then
                            BS.Vars.Controls[k].WarningValue = BS.Default.Controls[k].WarningValue
                        else
                            BS.Vars.Controls[k].WarningValue = tonumber(value)
                        end

                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    textType = _G.TEXT_TYPE_NUMERIC,
                    isMultiLine = false,
                    width = "half",
                    default = nil
                }
            end

            if (cv.dv) then
                widgetControls[#widgetControls + 1] = {
                    type = "editbox",
                    name = GetString(_G.BARSTEWARD_DANGER_VALUE) .. (units and (" (" .. units .. ")") or ""),
                    getFunc = function()
                        return BS.Vars.Controls[k].DangerValue or ""
                    end,
                    setFunc = function(value)
                        if (value == nil or value == "") then
                            BS.Vars.Controls[k].DangerValue = BS.Default.Controls[k].DangerValue
                        else
                            BS.Vars.Controls[k].DangerValue = tonumber(value)
                        end

                        BS.widgets[k].update(_G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref)
                    end,
                    textType = _G.TEXT_TYPE_NUMERIC,
                    isMultiLine = false,
                    width = "half",
                    default = nil
                }
            end
        end

        -- custom settings
        local cset = BS.widgets[k].customSettings
        if (cset) then
            local csettings = cset

            if (type(cset) == "function") then
                csettings = cset()
            end

            for _, setting in pairs(csettings) do
                widgetControls[#widgetControls + 1] = setting
            end
        end

        local textureCoords = nil

        if (k == BS.W_ALLIANCE) then
            textureCoords = {0, 1, 0, 0.6}
        end

        controls[idx] = {
            type = "submenu",
            name = BS.widgets[k].tooltip:gsub(":", ""),
            icon = BS.widgets[k].icon,
            iconTextureCoords = textureCoords,
            controls = widgetControls,
            reference = "BarStewardWidgets" .. k
        }
    end

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_WIDGETS),
        controls = controls,
        reference = "BarStewardWidgets"
    }
end

function BS.RegisterSettings()
    initialise()
    getPerformanceSettings()
    getWidgetSettings()
    getBarSettings()
    BS.OptionsPanel = BS.LAM:RegisterAddonPanel("BarStewardOptionsPanel", panel)
    BS.LAM:RegisterOptionControls("BarStewardOptionsPanel", BS.options)
end
