local BS = _G.BarSteward

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

local function getCV(vars)
    local var = vars.ColourValues
    local lookup = {}

    if ((var or "") ~= "") then
        for _, val in ipairs(BS.LC.Split(var)) do
            lookup[val] = true
        end

        return lookup
    end

    return nil
end

function BS.AddSettings(defaults, controls, vars, key)
    if (defaults.NoIcon ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WIDGET_ICON),
            getFunc = function()
                return vars.NoIcon or false
            end,
            setFunc = function(value)
                vars.NoIcon = value
                BS.RefreshWidget(key, true)
            end,
            width = "full",
            default = false,
            requiresReload = true
        }
    end

    if (defaults.NoValue ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return vars.NoValue or false
            end,
            setFunc = function(value)
                vars.NoValue = value
                BS.GetWidget(key):SetNoValue(value)
                BS.RegenerateBar(vars.Bar, key)
            end,
            width = "full",
            default = false
        }
    end

    if (defaults.Invert ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_INVERT),
            tooltip = GetString(_G.BARSTEWARD_INVERT_TOOLTIP),
            getFunc = function()
                return vars.Invert or false
            end,
            setFunc = function(value)
                vars.Invert = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = false
        }
    end

    if (key ~= BS.W_INFINITE_ARCHIVE_SCORE and key ~= BS.W_INFINITE_ARCHIVE_PROGRESS) then
        if (defaults.Autohide ~= nil) then
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_AUTOHIDE),
                tooltip = GetString(_G.BARSTEWARD_AUTOHIDE_TOOLTIP),
                getFunc = function()
                    return vars.Autohide
                end,
                setFunc = function(value)
                    vars.Autohide = value
                    BS.RefreshBar(key)
                end,
                width = "full",
                default = defaults.Autohide
            }
        end
    end

    if (defaults.HideWhenComplete ~= nil or defaults.HideWhenCompleted ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE),
            tooltip = (defaults.HideWhenCompleted ~= nil) and "" or GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE_TOOLTIP),
            getFunc = function()
                return vars.HideWhenComplete
            end,
            setFunc = function(value)
                vars.HideWhenComplete = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenComplete
        }
    end

    if (defaults.HideWhenFullyUsed ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED),
            tooltip = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED_TOOLTIP),
            getFunc = function()
                return vars.HideWhenFullyUsed
            end,
            setFunc = function(value)
                vars.HideWhenFullyUsed = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenFullyUsed
        }
    end

    if (defaults.HideWhenMaxLevel ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_MAX),
            getFunc = function()
                return vars.HideWhenMaxLevel
            end,
            setFunc = function(value)
                vars.HideWhenMaxLevel = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenMaxLevel
        }
    end

    if (defaults.PvPOnly ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_ONLY),
            getFunc = function()
                return vars.PvPOnly
            end,
            setFunc = function(value)
                vars.PvPOnly = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.PvPOnly
        }
    end

    if (defaults.PvPNever ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_NEVER),
            getFunc = function()
                return vars.PvPNever
            end,
            setFunc = function(value)
                vars.PvPNever = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.PvPNever
        }
    end

    if (defaults.ShowPercent ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PERCENTAGE),
            getFunc = function()
                return vars.ShowPercent
            end,
            setFunc = function(value)
                vars.ShowPercent = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.ShowPercent
        }
    end

    if (defaults.UseSeparators ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_ADD_SEPARATORS),
            getFunc = function()
                return vars.UseSeparators
            end,
            setFunc = function(value)
                vars.UseSeparators = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.UseSeparators
        }
    end

    if (defaults.HideSeconds ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_SECONDS),
            getFunc = function()
                return vars.HideSeconds
            end,
            setFunc = function(value)
                vars.HideSeconds = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideSeconds
        }
    end

    if (defaults.HideDaysWhenZero ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_ZERO_DAYS),
            getFunc = function()
                return vars.HideDaysWhenZero
            end,
            setFunc = function(value)
                vars.HideDaysWhenZero = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideDaysWhenZero
        }
    end

    if (defaults.HideLimit ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_LIMIT),
            tooltip = GetString(_G.BARSTEWARD_HIDE_LIMIT_TOOLTIP),
            getFunc = function()
                return vars.HideLimit
            end,
            setFunc = function(value)
                vars.HideLimit = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideLimit
        }
    end

    if (defaults.NoLimitColour ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR),
            tooltip = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR_TOOLTIP),
            getFunc = function()
                return vars.NoLimitColour
            end,
            setFunc = function(value)
                vars.NoLimitColour = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.NoLimitColour
        }
    end

    if (defaults.ShowFreeSpace ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_BAG_FREE),
            tooltip = GetString(_G.BARSTEWARD_BAG_FREE_TOOLTIP),
            getFunc = function()
                return vars.ShowFreeSpace or false
            end,
            setFunc = function(value)
                vars.ShowFreeSpace = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.ShowFreeSpace
        }
    end

    local checks = {EQUALS = "Equals", EXCEEDS = "Over", BELOW = "Under"}

    for langSuffix, varsuffix in pairs(checks) do
        if (defaults["SoundWhen" .. varsuffix] ~= nil) then
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G["BARSTEWARD_SOUND_VALUE_" .. langSuffix]),
                getFunc = function()
                    return vars["SoundWhen" .. varsuffix]
                end,
                setFunc = function(value)
                    vars["SoundWhen" .. varsuffix] = value
                end,
                width = "full",
                default = defaults["SoundWhen" .. varsuffix]
            }

            controls[#controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_VALUE),
                getFunc = function()
                    return vars["SoundWhen" .. varsuffix .. "Value"]
                end,
                setFunc = function(value)
                    vars["SoundWhen" .. varsuffix .. "Value"] = value
                end,
                width = "full",
                disabled = function()
                    return not vars["SoundWhen" .. varsuffix]
                end,
                default = nil
            }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_SOUND),
                choices = BS.SoundChoices,
                getFunc = function()
                    return vars["SoundWhen" .. varsuffix .. "Sound"]
                end,
                setFunc = function(value)
                    vars["SoundWhen" .. varsuffix .. "Sound"] = value
                    PlaySound(BS.SoundLookup[value])
                end,
                disabled = function()
                    return not vars["SoundWhen" .. varsuffix]
                end,
                scrollable = true,
                default = nil
            }
        end
    end

    if (defaults.Announce ~= nil) then
        local nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT)

        if (key == BS.W_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND)
        elseif (key == BS.W_GUILD_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND_GUILD)
        end

        controls[#controls + 1] = {
            type = "checkbox",
            name = nameValue,
            getFunc = function()
                return vars.Announce
            end,
            setFunc = function(value)
                vars.Announce = value
            end,
            width = "full",
            default = defaults.Announce
        }
    end

    if (vars.Progress == true) then
        controls[#controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_VALUE),
            getFunc = function()
                local colour = vars.ProgressColour or BS.Vars.DefaultWarningColour

                return unpack(colour)
            end,
            setFunc = function(r, g, b, a)
                vars.ProgressColour = {r, g, b, a}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[key])

                widget.value.progress:SetColor(r, g, b, a)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }

        controls[#controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_START),
            getFunc = function()
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local colour = vars.GradientStart or startg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                vars.GradientStart = {r, g, b}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[key])
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local er, eg, eb = unpack(vars.GradientEnd or endg)

                widget.value:SetGradientColors(r, g, b, 1, er, eg, eb, 1)
            end,
            width = "full",
            default = function()
                return GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
            end
        }

        controls[#controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_END),
            getFunc = function()
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local colour = vars.GradientEnd or endg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                vars.GradientEnd = {r, g, b}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[key])
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local sr, sg, sb = unpack(vars.GradientStart or startg)

                widget.value:SetGradientColors(sr, sg, sb, 1, r, g, b, 1)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }
    end

    local copts = BS.widgets[key].customOptions

    if (copts) then
        controls[#controls + 1] = {
            type = "dropdown",
            name = copts.name,
            tooltip = copts.tooltip,
            choices = copts.choices,
            getFunc = function()
                return BS.Vars.Controls[key][copts.varName] or copts.default
            end,
            setFunc = function(value)
                BS.Vars.Controls[key][copts.varName] = value
                if (copts.refresh) then
                    BS.RefreshWidget(key)
                end
            end,
            width = "full",
            default = copts.default
        }
    end

    local timeSamples12 = {}
    local timeSamples24 = {}

    for _, format in ipairs(twelveFormats) do
        table.insert(timeSamples12, BS.LC.FormatTime(format, "09:23:12"))
    end

    for _, format in ipairs(twentyFourFormats) do
        table.insert(timeSamples24, BS.LC.FormatTime(format, "09:23:12"))
    end

    if (key == BS.W_TIME or (key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        local timevars = (key == BS.W_TIME) and BS.Vars or BS.Vars.Controls[BS.W_TAMRIEL_TIME]

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TWELVE_TWENTY_FOUR),
            choices = {GetString(_G.BARSTEWARD_12), GetString(_G.BARSTEWARD_24)},
            getFunc = function()
                return timevars.TimeType or BS.Defaults.TimeType
            end,
            setFunc = function(value)
                timevars.TimeType = value
            end,
            default = BS.Defaults.TimeType
        }

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_12),
            choices = timeSamples12,
            getFunc = function()
                local format = timevars.TimeFormat12 or BS.Defaults.TimeFormat12
                return BS.LC.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(twelveFormats) do
                    if (BS.LC.FormatTime(f, "09:23:12") == value) then
                        format = f
                        break
                    end
                end

                timevars.TimeFormat12 = format
            end,
            disabled = function()
                return (timevars.TimeType or BS.Defaults.TimeType) ~= GetString(_G.BARSTEWARD_12)
            end,
            default = BS.Defaults.TimeFormat12
        }

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_24),
            choices = timeSamples24,
            getFunc = function()
                local format = timevars.TimeFormat24 or BS.Defaults.TimeFormat24
                return BS.LC.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(twentyFourFormats) do
                    if (BS.LC.FormatTime(f, "09:23:12") == value) then
                        format = f
                        break
                    end
                end

                timevars.TimeFormat24 = format
            end,
            disabled = function()
                return (timevars.TimeType or BS.Defaults.TimeType) == GetString(_G.BARSTEWARD_12)
            end,
            default = BS.Defaults.TimeFormat24
        }
    end

    if (defaults.Timer == true) then
        local timerFormat =
            key == BS.W_LEADS and ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT, 1, 12, 4) or
            ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS, 1, 12, 4, 10)

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIMER_FORMAT),
            choices = {
                timerFormat,
                "01:12:04:10"
            },
            getFunc = function()
                local default = (key == BS.W_LEADS) and "01:12:04" or "01:12:04:10"

                return vars.Format or default
            end,
            setFunc = function(value)
                vars.Format = value
                BS.RefreshWidget(key)
            end,
            default = key == BS.W_LEADS and "01:12:04" or "01:12:04:10"
        }
    end

    local cv = getCV(vars)

    if (cv and key ~= BS.W_TAMRIEL_TIME or (key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        if (cv.c and not vars.Progress) then
            controls[#controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DEFAULT_COLOUR),
                getFunc = function()
                    return unpack(vars.Colour or BS.Vars.DefaultColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultColour)) then
                        vars.Colour = nil
                    else
                        vars.Colour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultColour)
            }
        end

        if (cv.okc) then
            controls[#controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_OK_COLOUR),
                getFunc = function()
                    return unpack(vars.OkColour or BS.Vars.DefaultOkColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultOkColour)) then
                        vars.OkColour = nil
                    else
                        vars.OkColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultOkColour)
            }
        end

        if (cv.wc) then
            controls[#controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_WARNING_COLOUR),
                getFunc = function()
                    return unpack(vars.WarningColour or BS.Vars.DefaultWarningColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultWarningColour)) then
                        vars.WarningColour = nil
                    else
                        vars.WarningColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultWarningColour)
            }
        end

        if (cv.dc) then
            controls[#controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DANGER_COLOUR),
                getFunc = function()
                    return unpack(vars.DangerColour or BS.Vars.DefaultDangerColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultDangerColour)) then
                        vars.DangerColour = nil
                    else
                        vars.DangerColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultDangerColour)
            }
        end

        if (cv.mc) then
            controls[#controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_MAX_COLOUR),
                getFunc = function()
                    return unpack(vars.MaxColour or BS.Vars.DefaultMaxColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultMaxColour)) then
                        vars.MaxColour = nil
                    else
                        vars.MaxColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultMaxColour)
            }
        end

        local units = vars.Units

        if (cv.okv) then
            controls[#controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_OK_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.OkValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.OkValue = BS.Default.Controls[key].OkValue
                    else
                        vars.OkValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.wv) then
            controls[#controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_WARNING_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.WarningValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.WarningValue = BS.Default.Controls[key].WarningValue
                    else
                        vars.WarningValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.dv) then
            controls[#controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_DANGER_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.DangerValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.DangerValue = BS.Default.Controls[key].DangerValue
                    else
                        vars.DangerValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.mv) then
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_MAX_VALUE),
                getFunc = function()
                    return vars.MaxValue or false
                end,
                setFunc = function(value)
                    vars.MaxValue = value
                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = false
            }
        end
    end

    local cset = BS.widgets[key].customSettings

    if (cset) then
        local csettings = cset

        if (type(cset) == "function") then
            csettings = cset()
        end

        for _, setting in ipairs(csettings) do
            controls[#controls + 1] = setting
        end
    end

    if (defaults.Print ~= nil) then
        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_RANDOM_PRINT),
            getFunc = function()
                return vars.Print
            end,
            setFunc = function(value)
                vars.Print = value
            end,
            width = "full",
            default = defaults.Print
        }
    end
end

function BS.CheckExperimental(defaults, widgetControls)
    if (defaults.Experimental) then
        widgetControls[#widgetControls + 1] = {
            type = "description",
            text = "|cff0000" .. GetString(_G.BARSTEWARD_EXPERIMENTAL) .. "|r",
            tooltip = GetString(_G.BARSTEWARD_EXPERIMENTAL_DESC),
            width = "full"
        }
    end
end
