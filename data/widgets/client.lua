local BS = _G.BarSteward
local startButton = BS.Icon("buttons/rightarrow_up", "00ff00", 16, 16)
local stopButton = BS.Icon("buttons/gamepad/console-widget-checkbox", "ff0000", 16, 16)
local timerFunctions = {}

BS.TimerRunning = {}

local startFunction = function(t)
    if (BS.TimerRunning[t]) then
        BS.TimerRunning[t] = BS.TimerRunning[t] - 1

        if (BS.TimerRunning[t] == 0) then
            BS.TimerRunning[t] = nil
            BS.TimerManager:UnregisterForUpdate(1000, timerFunctions[t])

            local sound = BS.Vars[string.format("Timer%dSound", t)]

            if (sound) then
                PlaySound(BS.SoundLookup[sound])
            end
        end
    end
end

do
    for timer = 1, BS.MAX_TIMERS do
        timerFunctions[timer] = function()
            startFunction(timer)
        end
    end
end

local function getTimers()
    local nums = {}
    local added = 0

    for timer = 1, BS.MAX_TIMERS do
        if (BS.Vars[string.format("Timer%dEnabled", timer)]) then
            local timerValue = BS.Vars[string.format("Timer%dTime", timer)] or "0:00"
            local index = 0
            local defaultName = ZO_CachedStrFormat(_G.BARSTEWARD_TIMER, ZO_CachedStrFormat("<<n:1>>", timer))
            local timerName = BS.Vars[string.format("Timer%dName", timer)] or defaultName

            if (timerName == "") then
                timerName = defaultName
            end

            for digits in timerValue:gmatch("%d+") do
                index = index + 1
                nums[index] = tonumber(digits)
            end

            local seconds =
                BS.TimerRunning[timer] and BS.TimerRunning[timer] or (((nums[1] or 0) * 60) + (nums[2] or 0))
            local formatted = BS.LC.SecondsToMinutes(seconds)
            local title =
                string.format("%s  %s - %s", BS.TimerRunning[timer] and stopButton or startButton, formatted, timerName)
            local timerFunction = function()
                if (BS.TimerRunning[timer]) then
                    BS.TimerRunning[timer] = nil
                    BS.TimerManager:UnregisterForUpdate(1000, timerFunctions[timer])
                else
                    BS.TimerRunning[timer] = seconds
                    BS.TimerManager:RegisterForUpdate(1000, timerFunctions[timer])
                end
            end

            AddMenuItem(title, timerFunction)
            added = added + 1
        end
    end

    if (added == 0) then
        AddMenuItem(
            BS.LC.Format(_G.BARSTEWARD_TIMER_NONE),
            function()
                BS.LAM:OpenToPanel(BS.OptionsPanel)
            end
        )
    end
end

local note =
    "|cffff00" .. BS.LC.Format(_G.BARSTEWARD_TIMER_NOTE) .. BS.LF .. BS.LC.Format(_G.BARSTEWARD_TIMER_WARNING) .. "|r"
local timers = {
    [1] = {
        type = "description",
        text = note,
        width = "full"
    }
}

do
    if (not BS.SoundChoices) then
        BS.PopulateSoundOptions()
    end

    for timer = 1, BS.MAX_TIMERS do
        timers[timer + 1] = {
            type = "submenu",
            name = ZO_CachedStrFormat(_G.BARSTEWARD_TIMER, ZO_CachedStrFormat("<<n:1>>", timer)),
            controls = {
                [1] = {
                    type = "checkbox",
                    name = BS.LC.Format(SI_ADDONLOADSTATE2),
                    getFunc = function()
                        return BS.Vars[string.format("Timer%dEnabled", timer)]
                    end,
                    setFunc = function(value)
                        BS.Vars[string.format("Timer%dEnabled", timer)] = value
                    end,
                    width = "full"
                },
                [2] = {
                    type = "editbox",
                    name = ZO_CachedStrFormat(_G.BARSTEWARD_TIMER, ZO_CachedStrFormat("<<n:1>>", timer)),
                    getFunc = function()
                        return BS.Vars[string.format("Timer%dTime", timer)] or "0:00"
                    end,
                    setFunc = function(value)
                        BS.Vars[string.format("Timer%dTime", timer)] = value
                    end,
                    disabled = function()
                        return not BS.Vars[string.format("Timer%dEnabled", timer)]
                    end,
                    width = "full"
                },
                [3] = {
                    type = "editbox",
                    name = BS.LC.Format(SI_ADDON_MANAGER_NAME),
                    getFunc = function()
                        return BS.Vars[string.format("Timer%dName", timer)] or
                            ZO_CachedStrFormat(_G.BARSTEWARD_TIMER, ZO_CachedStrFormat("<<n:1>>", timer))
                    end,
                    setFunc = function(value)
                        BS.Vars[string.format("Timer%dName", timer)] = value
                    end,
                    disabled = function()
                        return not BS.Vars[string.format("Timer%dEnabled", timer)]
                    end,
                    width = "full"
                },
                [4] = {
                    type = "dropdown",
                    name = GetString(_G.BARSTEWARD_SOUND),
                    choices = BS.SoundChoices,
                    getFunc = function()
                        return BS.Vars[string.format("Timer%dSound", timer)]
                    end,
                    setFunc = function(value)
                        BS.Vars[string.format("Timer%dSound", timer)] = value
                        PlaySound(BS.SoundLookup[value])
                    end,
                    disabled = function()
                        return not BS.Vars[string.format("Timer%dEnabled", timer)]
                    end,
                    scrollable = true,
                    default = nil
                }
            }
        }
    end
end

local function getMoonPhaseIcon()
    if (BS.LibClock) then
        local constants = _G.LibClockTST.CONSTANTS()
        local moonInfo = BS.LibClock:GetMoon()

        for idx, data in ipairs(constants.moon.phasesPercentage) do
            if (data.name == moonInfo.currentPhaseName) then
                return idx
            end
        end
    end

    return 5
end

local latency_icons = {
    ["danger"] = "campaign/campaignbrowser_lowpop",
    ["warning"] = "campaign/campaignbrowser_medpop",
    ["ok"] = "campaign/campaignbrowser_hipop"
}

BS.widgets = {
    [BS.W_TIME] = {
        name = "time",
        update = function(widget)
            local format = BS.GetVar("TimeFormat24")
            local this = BS.W_TIME

            if (BS.GetVar("TimeType") == GetString(_G.BARSTEWARD_12)) then
                format = BS.GetVar("TimeFormat12")
            end

            local time = BS.LC.FormatTime(format)

            widget:SetValue(time)
            widget:SetColour(BS.GetColour(this, true))

            widget:SetTooltip(
                BS.LC.Format(SI_TRADINGHOUSELISTINGSORTTYPE0) ..
                BS.LF .. BS.COLOURS.White:Colorize(BS.LC.Format(_G.BARSTEWARD_TIMER_TIP))
            )

            return widget:GetValue()
        end,
        onRightClick = function()
            ClearMenu()
            getTimers()
            ShowMenu()
        end,
        timer = 1000,
        tooltip = BS.LC.Format(SI_TRADINGHOUSELISTINGSORTTYPE0),
        icon = "hud/gamepad/gp_radialicon_defer_down",
        customSettings = {
            [1] = {
                type = "submenu",
                name = "|c34cceb" .. BS.LC.Format(_G.BARSTEWARD_TIMERS) .. "|r",
                controls = timers
            }
        }
    },
    [BS.W_FPS] = {
        name = "fps",
        update = function(widget)
            local framerate = GetFramerate()

            widget:SetValue(math.floor(framerate), BS.GetVar("FixedWidth", BS.W_FPS) and "____" or nil)
            widget:SetColour(BS.GetColour(BS.W_FPS, true))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = function()
            if (BS.GetVar("ShowText", BS.W_FPS)) then
                if (GetCVar("language.2") == "zh") then
                    return "BarSteward/assets/fps_zh.dds"
                else
                    return "BarSteward/assets/fps.dds"
                end
            else
                return "champion/actionbar/champion_bar_combat_selection"
            end
        end,
        tooltip = GetString(_G.BARSTEWARD_FPS),
        customSettings = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SHOW_TEXT),
                tooltip = GetString(_G.BARSTEWARD_SHOW_TEXT_TOOLTIP),
                getFunc = function()
                    return BS.GetVar("ShowText", BS.W_FPS)
                end,
                setFunc = function(value)
                    BS.Vars.Controls[BS.W_FPS].ShowText = value
                    BS.RefreshWidget(BS.W_FPS, true)
                end,
                width = "full",
                default = false
            },
            [2] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_FIXED_WIDTH),
                getFunc = function()
                    return BS.Vars.Controls[BS.W_FPS].FixedWidth or false
                end,
                setFunc = function(value)
                    BS.Vars.Controls[BS.W_FPS].FixedWidth = value
                    BS.RefreshWidget(BS.W_FPS)
                end,
                default = true
            }
        }
    },
    [BS.W_LATENCY] = {
        name = "latency",
        update = function(widget)
            local latency = GetLatency()
            local this = BS.W_LATENCY
            local colour = BS.GetColour(this, true)
            local icon = latency_icons["ok"]

            if ((BS.GetVar("WarningValue", this) or 0) > 0) then
                if (latency >= (BS.GetVar("WarningValue", this) or 0)) then
                    colour = BS.GetColour(this, "Warning", true)
                    icon = latency_icons["warning"]
                end
            end

            if ((BS.GetVar("DangerValue", this) or 0) > 0) then
                if (latency >= (BS.GetVar("DangerValue", this) or 0)) then
                    colour = BS.GetColour(this, "Danger", true)
                    icon = latency_icons["danger"]
                end
            end

            widget:SetValue(math.floor(latency), BS.GetVar("FixedWidth", this) and "____" or nil)
            widget:SetColour(colour)
            widget:SetIcon(icon, colour)

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "Campaign/campaignBrowser_hiPop",
        tooltip = GetString(_G.BARSTEWARD_LATENCY),
        customSettings = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_FIXED_WIDTH),
                getFunc = function()
                    return BS.Vars.Controls[BS.W_LATENCY].FixedWidth or false
                end,
                setFunc = function(value)
                    BS.Vars.Controls[BS.W_LATENCY].FixedWidth = value
                    BS.RefreshWidget(BS.W_LATENCY)
                end,
                default = true
            }
        }
    },
    [BS.W_MEMORY] = {
        -- v1.2.2
        name = "memory",
        update = function(widget)
            local usedKiB = collectgarbage("count")
            local usedMiB = (usedKiB / 1024)
            local this = BS.W_MEMORY
            local precision = BS.GetVar("Precision", this) or 1
            local rfactor = 10 ^ precision
            local colour = BS.GetColour(this, "Ok", true)

            usedMiB = math.ceil(usedMiB * rfactor) / rfactor

            if (usedMiB > (BS.GetVar("DangerValue", this) or 99999)) then
                colour = BS.GetColour(this, "Danger", true)
            elseif (usedMiB > (BS.GetVar("WarningValue", this) or 99999)) then
                colour = BS.GetColour(this, "Warning", true)
            end

            widget:SetValue(ZO_FastFormatDecimalNumber(tostring(usedMiB)) .. " MiB")
            widget:SetColour(colour)

            return usedMiB
        end,
        timer = 5000,
        icon = "enchanting/enchanting_highlight",
        tooltip = GetString(_G.BARSTEWARD_MEMORY),
        customOptions = {
            name = GetString(_G.BARSTEWARD_DECIMAL_PLACES),
            choices = { 0, 1, 2, 3 },
            varName = "Precision",
            refresh = true,
            default = 1
        },
        minWidthChars = "______"
    },
    [BS.W_TAMRIEL_TIME] = {
        -- v1.3.17
        name = "tamrielTime",
        update = function(widget)
            local this = BS.W_TAMRIEL_TIME
            local format = BS.GetVar("TimeFormat24", this) or BS.Defaults.TimeFormat24

            if ((BS.GetVar("TimeType", this) or BS.Defaults.TimeType) == GetString(_G.BARSTEWARD_12)) then
                format = BS.GetVar("TimeFormat12", this) or BS.Defaults.TimeFormat12
            end

            if (BS.LibClock) then
                local tamrielTime = BS.LibClock:GetTime()
                local time = BS.LC.FormatTime(format, nil, tamrielTime)
                local phase = getMoonPhaseIcon() or 5

                widget:SetIcon("BarSteward/assets/moon/" .. phase .. ".dds")
                widget:SetValue(time)
                widget:SetColour(BS.GetColour(this, true))

                return widget:GetValue()
            end
        end,
        hideWhenTrue = function()
            return not BS.LibClock
        end,
        timer = 1000,
        tooltip = GetString(_G.BARSTEWARD_TAMRIEL_TIME),
        icon = "BarSteward/assets/moon/5.dds"
    },
    [BS.W_SERVER] = {
        -- v3.3.1
        name = "server",
        update = function(widget)
            local this = BS.W_SERVER
            local server = BS.LC.Format(GetWorldName())

            widget:SetValue(server)
            widget:SetColour(BS.GetColour(this, true))
            d(server)
            return server
        end,
        event = EVENT_PLAYER_ACTIVATED,
        tooltip = GetString(_G.BARSTEWARD_SERVER),
        icon = "login/link_loginlogo_eso"
    }
}
