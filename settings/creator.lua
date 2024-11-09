local BS = _G.BarSteward
local sc = ZO_InitializingObject:Subclass()

BS.Creator = sc

function sc:Initialize()
    -- 12 hour time formats
    self.twelveFormats = {
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
    self.twentyFourFormats = {
        "HH:m:s",
        "H:m:s",
        "HH:m",
        "H:m",
        "HH.m.s",
        "H.m.s",
        "HH.m",
        "H.m"
    }
end

function sc:Setup(controls, defaults, vars, key)
    self.controls = controls
    self.defaults = defaults
    self.vars = vars
    self.key = key
end

function sc:GetCV()
    local var = self.vars.ColourValues
    local lookup = {}

    if ((var or "") ~= "") then
        for _, val in ipairs(BS.LC.Split(var)) do
            lookup[val] = true
        end

        return lookup
    end

    return nil
end

function sc:AddSettings()
    if (self.defaults.NoIcon ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WIDGET_ICON),
            getFunc = function()
                return self.vars.NoIcon or false
            end,
            setFunc = function(value)
                self.vars.NoIcon = value
                BS.RefreshWidget(self.key, true)
            end,
            width = "full",
            default = false,
            requiresReload = true
        }
    end

    if (self.defaults.NoValue ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_TEXT),
            getFunc = function()
                return self.vars.NoValue or false
            end,
            setFunc = function(value)
                self.vars.NoValue = value
                BS.GetWidget(self.key):SetNoValue(value)
                BS.RegenerateBar(BS.Vars.Controls[self.key].Bar, self.key)
            end,
            width = "full",
            default = false
        }
    end

    if (self.defaults.Invert ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_INVERT),
            tooltip = GetString(_G.BARSTEWARD_INVERT_TOOLTIP),
            getFunc = function()
                return self.vars.Invert or false
            end,
            setFunc = function(value)
                self.vars.Invert = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = false
        }
    end

    if (self.key ~= BS.W_INFINITE_ARCHIVE_SCORE and self.key ~= BS.W_INFINITE_ARCHIVE_PROGRESS) then
        if (self.defaults.Autohide ~= nil) then
            self.controls[#self.controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_AUTOHIDE),
                tooltip = GetString(_G.BARSTEWARD_AUTOHIDE_TOOLTIP),
                getFunc = function()
                    return self.vars.Autohide
                end,
                setFunc = function(value)
                    self.vars.Autohide = value
                    BS.RefreshBar(self.key)
                end,
                width = "full",
                default = self.defaults.Autohide
            }
        end
    end

    if (self.defaults.HideWhenComplete ~= nil or self.defaults.HideWhenCompleted ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE),
            tooltip = (self.defaults.HideWhenCompleted ~= nil) and "" or
                GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE_TOOLTIP),
            getFunc = function()
                return self.vars.HideWhenComplete
            end,
            setFunc = function(value)
                self.vars.HideWhenComplete = value
                BS.RefreshBar(self.key)
            end,
            width = "full",
            default = self.defaults.HideWhenComplete
        }
    end

    if (self.defaults.HideWhenFullyUsed ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED),
            tooltip = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED_TOOLTIP),
            getFunc = function()
                return self.vars.HideWhenFullyUsed
            end,
            setFunc = function(value)
                self.vars.HideWhenFullyUsed = value
                BS.RefreshBar(self.key)
            end,
            width = "full",
            default = self.defaults.HideWhenFullyUsed
        }
    end

    if (self.defaults.HideWhenMaxLevel ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_MAX),
            getFunc = function()
                return self.vars.HideWhenMaxLevel
            end,
            setFunc = function(value)
                self.vars.HideWhenMaxLevel = value
                BS.RefreshBar(self.key)
            end,
            width = "full",
            default = self.defaults.HideWhenMaxLevel
        }
    end

    if (self.defaults.PvPOnly ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_ONLY),
            getFunc = function()
                return self.vars.PvPOnly
            end,
            setFunc = function(value)
                self.vars.PvPOnly = value
                BS.RefreshBar(self.key)
            end,
            width = "full",
            default = self.defaults.PvPOnly
        }
    end

    if (self.defaults.PvPNever ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_NEVER),
            getFunc = function()
                return self.vars.PvPNever
            end,
            setFunc = function(value)
                self.vars.PvPNever = value
                BS.RefreshBar(self.key)
            end,
            width = "full",
            default = self.defaults.PvPNever
        }
    end

    if (self.defaults.ShowPercent ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PERCENTAGE),
            getFunc = function()
                return self.vars.ShowPercent
            end,
            setFunc = function(value)
                self.vars.ShowPercent = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.ShowPercent
        }
    end

    if (self.defaults.UseSeparators ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_ADD_SEPARATORS),
            getFunc = function()
                return self.vars.UseSeparators
            end,
            setFunc = function(value)
                self.vars.UseSeparators = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.UseSeparators
        }
    end

    if (self.defaults.HideSeconds ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_SECONDS),
            getFunc = function()
                return self.vars.HideSeconds
            end,
            setFunc = function(value)
                self.vars.HideSeconds = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.HideSeconds
        }
    end

    if (self.defaults.HideDaysWhenZero ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_ZERO_DAYS),
            getFunc = function()
                return self.vars.HideDaysWhenZero
            end,
            setFunc = function(value)
                self.vars.HideDaysWhenZero = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.HideDaysWhenZero
        }
    end

    if (self.defaults.HideLimit ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_LIMIT),
            tooltip = GetString(_G.BARSTEWARD_HIDE_LIMIT_TOOLTIP),
            getFunc = function()
                return self.vars.HideLimit
            end,
            setFunc = function(value)
                self.vars.HideLimit = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.HideLimit
        }
    end

    if (self.defaults.NoLimitColour ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR),
            tooltip = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR_TOOLTIP),
            getFunc = function()
                return self.vars.NoLimitColour
            end,
            setFunc = function(value)
                self.vars.NoLimitColour = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.NoLimitColour
        }
    end

    if (self.defaults.ShowFreeSpace ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_BAG_FREE),
            tooltip = GetString(_G.BARSTEWARD_BAG_FREE_TOOLTIP),
            getFunc = function()
                return self.vars.ShowFreeSpace or false
            end,
            setFunc = function(value)
                self.vars.ShowFreeSpace = value
                BS.RefreshWidget(self.key)
            end,
            width = "full",
            default = self.defaults.ShowFreeSpace
        }
    end

    local checks = {EQUALS = "Equals", EXCEEDS = "Over", BELOW = "Under"}

    for langSuffix, varsuffix in pairs(checks) do
        if (self.defaults["SoundWhen" .. varsuffix] ~= nil) then
            self.controls[#self.controls + 1] = {
                type = "checkbox",
                name = GetString(_G["BARSTEWARD_SOUND_VALUE_" .. langSuffix]),
                getFunc = function()
                    return self.vars["SoundWhen" .. varsuffix]
                end,
                setFunc = function(value)
                    self.vars["SoundWhen" .. varsuffix] = value
                end,
                width = "full",
                default = self.defaults["SoundWhen" .. varsuffix]
            }

            self.controls[#self.controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_VALUE),
                getFunc = function()
                    return self.vars["SoundWhen" .. varsuffix .. "Value"]
                end,
                setFunc = function(value)
                    self.vars["SoundWhen" .. varsuffix .. "Value"] = value
                end,
                width = "full",
                disabled = function()
                    return not self.vars["SoundWhen" .. varsuffix]
                end,
                default = nil
            }

            self.controls[#self.controls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_SOUND),
                choices = BS.SoundChoices,
                getFunc = function()
                    return self.vars["SoundWhen" .. varsuffix .. "Sound"]
                end,
                setFunc = function(value)
                    self.vars["SoundWhen" .. varsuffix .. "Sound"] = value
                    PlaySound(BS.SoundLookup[value])
                end,
                disabled = function()
                    return not self.vars["SoundWhen" .. varsuffix]
                end,
                scrollable = true,
                default = nil
            }
        end
    end

    if (self.defaults.Announce ~= nil) then
        local nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT)

        if (self.key == BS.W_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND)
        elseif (self.key == BS.W_GUILD_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND_GUILD)
        end

        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = nameValue,
            getFunc = function()
                return self.vars.Announce
            end,
            setFunc = function(value)
                self.vars.Announce = value
            end,
            width = "full",
            default = self.defaults.Announce
        }
    end

    if (self.vars.Progress == true) then
        self.controls[#self.controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_VALUE),
            getFunc = function()
                local colour = self.vars.ProgressColour or BS.Vars.DefaultWarningColour

                return unpack(colour)
            end,
            setFunc = function(r, g, b, a)
                self.vars.ProgressColour = {r, g, b, a}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[self.key])

                widget.value.progress:SetColor(r, g, b, a)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }

        self.controls[#self.controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_START),
            getFunc = function()
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local colour = self.vars.GradientStart or startg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                self.vars.GradientStart = {r, g, b}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[self.key])
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local er, eg, eb = unpack(self.vars.GradientEnd or endg)

                widget.value:SetGradientColors(r, g, b, 1, er, eg, eb, 1)
            end,
            width = "full",
            default = function()
                return GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
            end
        }

        self.controls[#self.controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_END),
            getFunc = function()
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local colour = self.vars.GradientEnd or endg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                self.vars.GradientEnd = {r, g, b}

                local widget = BS.WidgetObjectPool:GetActiveObject(BS.WidgetObjects[self.key])
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local sr, sg, sb = unpack(self.vars.GradientStart or startg)

                widget.value:SetGradientColors(sr, sg, sb, 1, r, g, b, 1)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }
    end

    local copts = BS.widgets[self.key].customOptions

    if (copts) then
        self.controls[#self.controls + 1] = {
            type = "dropdown",
            name = copts.name,
            tooltip = copts.tooltip,
            choices = copts.choices,
            getFunc = function()
                return BS.Vars.Controls[self.key][copts.varName] or copts.default
            end,
            setFunc = function(value)
                BS.Vars.Controls[self.key][copts.varName] = value
                if (copts.refresh) then
                    BS.RefreshWidget(self.key)
                end
            end,
            width = "full",
            default = copts.default
        }
    end

    local timeSamples12 = {}
    local timeSamples24 = {}

    for _, format in ipairs(self.twelveFormats) do
        table.insert(timeSamples12, BS.LC.FormatTime(format, "09:23:12"))
    end

    for _, format in ipairs(self.twentyFourFormats) do
        table.insert(timeSamples24, BS.LC.FormatTime(format, "09:23:12"))
    end

    if (self.key == BS.W_TIME or (self.key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        local timevars = (self.key == BS.W_TIME) and BS.Vars or BS.Vars.Controls[BS.W_TAMRIEL_TIME]

        self.controls[#self.controls + 1] = {
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

        self.controls[#self.controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_12),
            choices = timeSamples12,
            getFunc = function()
                local format = timevars.TimeFormat12 or BS.Defaults.TimeFormat12
                return BS.LC.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(self.twelveFormats) do
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

        self.controls[#self.controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_24),
            choices = timeSamples24,
            getFunc = function()
                local format = timevars.TimeFormat24 or BS.Defaults.TimeFormat24
                return BS.LC.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(self.twentyFourFormats) do
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

    if (self.defaults.Timer == true) then
        local timerFormat =
            self.key == BS.W_LEADS and ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT, 1, 12, 4) or
            ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS, 1, 12, 4, 10)

        self.controls[#self.controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIMER_FORMAT),
            choices = {
                timerFormat,
                "01:12:04:10"
            },
            getFunc = function()
                local default = (self.key == BS.W_LEADS) and "01:12:04" or "01:12:04:10"

                return self.vars.Format or default
            end,
            setFunc = function(value)
                self.vars.Format = value
                BS.RefreshWidget(self.key)
            end,
            default = self.key == BS.W_LEADS and "01:12:04" or "01:12:04:10"
        }
    end

    local cv = self:GetCV()

    if (cv and self.key ~= BS.W_TAMRIEL_TIME or (self.key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        if (cv.c and not self.vars.Progress) then
            self.controls[#self.controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DEFAULT_COLOUR),
                getFunc = function()
                    return unpack(self.vars.Colour or BS.Vars.DefaultColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultColour)) then
                        self.vars.Colour = nil
                    else
                        self.vars.Colour = {r, g, b, a}
                    end

                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultColour)
            }
        end

        if (cv.okc) then
            self.controls[#self.controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_OK_COLOUR),
                getFunc = function()
                    return unpack(self.vars.OkColour or BS.Vars.DefaultOkColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultOkColour)) then
                        self.vars.OkColour = nil
                    else
                        self.vars.OkColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultOkColour)
            }
        end

        if (cv.wc) then
            self.controls[#self.controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_WARNING_COLOUR),
                getFunc = function()
                    return unpack(self.vars.WarningColour or BS.Vars.DefaultWarningColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultWarningColour)) then
                        self.vars.WarningColour = nil
                    else
                        self.vars.WarningColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultWarningColour)
            }
        end

        if (cv.dc) then
            self.controls[#self.controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DANGER_COLOUR),
                getFunc = function()
                    return unpack(self.vars.DangerColour or BS.Vars.DefaultDangerColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultDangerColour)) then
                        self.vars.DangerColour = nil
                    else
                        self.vars.DangerColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultDangerColour)
            }
        end

        if (cv.mc) then
            self.controls[#self.controls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_MAX_COLOUR),
                getFunc = function()
                    return unpack(self.vars.MaxColour or BS.Vars.DefaultMaxColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.LC.CompareColours({r, g, b, a}, BS.Vars.DefaultMaxColour)) then
                        self.vars.MaxColour = nil
                    else
                        self.vars.MaxColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultMaxColour)
            }
        end

        local units = self.vars.Units

        if (cv.okv) then
            self.controls[#self.controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_OK_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return self.vars.OkValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        self.vars.OkValue = BS.Default.Controls[self.key].OkValue
                    else
                        self.vars.OkValue = tonumber(value)
                    end

                    BS.RefreshWidget(self.key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.wv) then
            self.controls[#self.controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_WARNING_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return self.vars.WarningValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        self.vars.WarningValue = BS.Default.Controls[self.key].WarningValue
                    else
                        self.vars.WarningValue = tonumber(value)
                    end

                    BS.RefreshWidget(self.key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.dv) then
            self.controls[#self.controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_DANGER_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return self.vars.DangerValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        self.vars.DangerValue = BS.Default.Controls[self.key].DangerValue
                    else
                        self.vars.DangerValue = tonumber(value)
                    end

                    BS.RefreshWidget(self.key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.mv) then
            self.controls[#self.controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_MAX_VALUE),
                getFunc = function()
                    return self.vars.MaxValue or false
                end,
                setFunc = function(value)
                    self.vars.MaxValue = value
                    BS.RefreshWidget(self.key)
                end,
                width = "full",
                default = false
            }
        end
    end

    local cset = BS.widgets[self.key].customSettings

    if (cset) then
        local csettings = cset

        if (type(cset) == "function") then
            csettings = cset()
        end

        for _, setting in ipairs(csettings) do
            self.controls[#self.controls + 1] = setting
        end
    end

    if (self.defaults.Print ~= nil) then
        self.controls[#self.controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_RANDOM_PRINT),
            getFunc = function()
                return self.vars.Print
            end,
            setFunc = function(value)
                self.vars.Print = value
            end,
            width = "full",
            default = self.defaults.Print
        }
    end
end

function sc:CheckExperimental()
    if (self.defaults.Experimental) then
        self.controls[#self.controls + 1] = {
            type = "description",
            text = "|cff0000" .. GetString(_G.BARSTEWARD_EXPERIMENTAL) .. "|r",
            tooltip = GetString(_G.BARSTEWARD_EXPERIMENTAL_DESC),
            width = "full"
        }
    end
end
