local BS = _G.BarSteward

BS.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "Bar Steward",
    displayName = "Bar Steward",
    author = "Flat Badger",
    version = "1.0.0",
    registerForDefaults = true,
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

local function Initialise()
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
                _G[bar].ref.handle:SetHidden(not value)
            end

        end,
        width = "full",
        default = BS.Defaults.Movable
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

local function GetBarSettings()
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
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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
        end

        BS.options[3 + idx] = {
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
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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

local function GetWidgetSettings()
    local widgets = BS.Vars.Controls
    local bars = BS.Vars.Bars
    local none = GetString(_G.SI_DAMAGETYPE0)
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

    local widgetNums = {}

    for k, _ in ipairs(widgets) do
        table.insert(widgetNums, k)
    end

    for k, v in ipairs(widgets) do
        local widgetControls = {
            [1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR),
                choices = barNames,
                getFunc = function()
                    local barName = GetString(_G.SI_DAMAGETYPE0)

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
            },
            [2] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_POSITION),
                choices = widgetNums,
                getFunc = function()
                    return BS.Vars.Controls[k].Order
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].Order = value
                end,
                width = "full",
                requiresReload = true,
                default = BS.Defaults.Controls[k].Order
            }
        }

        -- Autohide
        if (BS.Defaults.Controls[k].Autohide ~= nil) then
            widgetControls[3] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_AUTOHIDE),
                tooltip = GetString(_G.BARSTEWARD_AUTOHIDE_TOOLTIP),
                getFunc = function()
                    return BS.Vars.Controls[k].Autohide
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].Autohide = value
                    local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[k].name].ref
                    local bar = widget.control:GetParent().ref
                    local metadata = BS.widgets[k]
                    metadata.widget = widget
                    bar:DoUpdate(metadata)
                end,
                width = "full",
                default = BS.Defaults.Controls[k].Autohide
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
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BS.OptionsPanel)
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

        controls[k] = {
            type = "submenu",
            name = BS.widgets[k].tooltip,
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
    Initialise()
    GetWidgetSettings()
    GetBarSettings()
    BS.OptionsPanel = BS.LAM:RegisterAddonPanel("BarStewardOptionsPanel", panel)
    BS.LAM:RegisterOptionControls("BarStewardOptionsPanel", BS.options)
end
