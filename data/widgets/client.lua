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
            BS.UnregisterForUpdate(1000, timerFunctions[t])

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
            local formatted = BS.SecondsToMinutes(seconds)
            local title =
                string.format("%s  %s - %s", BS.TimerRunning[timer] and stopButton or startButton, formatted, timerName)
            local timerFunction = function()
                if (BS.TimerRunning[timer]) then
                    BS.TimerRunning[timer] = nil
                    BS.UnregisterForUpdate(1000, timerFunctions[timer])
                else
                    BS.TimerRunning[timer] = seconds
                    BS.RegisterForUpdate(1000, timerFunctions[timer])
                end
            end

            AddMenuItem(title, timerFunction)
            added = added + 1
        end
    end

    if (added == 0) then
        AddMenuItem(
            BS.Format(_G.BARSTEWARD_TIMER_NONE),
            function()
                BS.LAM:OpenToPanel(BS.OptionsPanel)
            end
        )
    end
end

local note =
    "|cffff00" .. BS.Format(_G.BARSTEWARD_TIMER_NOTE) .. BS.LF .. BS.Format(_G.BARSTEWARD_TIMER_WARNING) .. "|r"
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
                    name = BS.Format(_G.SI_ADDONLOADSTATE2),
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
                    name = BS.Format(_G.SI_ADDON_MANAGER_NAME),
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

BS.widgets = {
    [BS.W_TIME] = {
        name = "time",
        update = function(widget)
            local format = BS.GetVar("TimeFormat24")
            local this = BS.W_TIME

            if (BS.GetVar("TimeType") == GetString(_G.BARSTEWARD_12)) then
                format = BS.GetVar("TimeFormat12")
            end

            local time = BS.FormatTime(format)

            widget:SetValue(time)
            widget:SetColour(unpack(BS.GetColour(this)))

            widget.tooltip =
                BS.Format(_G.SI_TRADINGHOUSELISTINGSORTTYPE0) ..
                BS.LF .. "|cf9f9f9" .. BS.Format(_G.BARSTEWARD_TIMER_TIP) .. "|r"

            return widget:GetValue()
        end,
        onRightClick = function()
            ClearMenu()
            getTimers()
            ShowMenu()
        end,
        timer = 1000,
        tooltip = BS.Format(_G.SI_TRADINGHOUSELISTINGSORTTYPE0),
        icon = "lfg/lfg_indexicon_timedactivities_up",
        customSettings = {
            [1] = {
                type = "submenu",
                name = "|c34cceb" .. BS.Format(_G.BARSTEWARD_TIMERS) .. "|r",
                controls = timers
            }
        }
    },
    [BS.W_FPS] = {
        name = "fps",
        update = function(widget)
            local framerate = GetFramerate()

            widget:SetValue(math.floor(framerate))
            widget:SetColour(unpack(BS.GetColour(BS.W_FPS)))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "champion/actionbar/champion_bar_combat_selection",
        tooltip = GetString(_G.BARSTEWARD_FPS),
        minWidthChars = "___"
    },
    [BS.W_LATENCY] = {
        name = "latency",
        update = function(widget)
            local latency = GetLatency()
            local this = BS.W_LATENCY
            local colour = BS.GetColour(this)

            if ((BS.GetVar("WarningValue", this) or 0) > 0) then
                if (latency >= (BS.GetVar("WarningValue", this) or 0)) then
                    colour = BS.GetColour(this, "Warning")
                end
            end

            if ((BS.GetVar("DangerValue", this) or 0) > 0) then
                if (latency >= (BS.GetVar("DangerValue", this) or 0)) then
                    colour = BS.GetColour(this, "Danger")
                end
            end

            widget:SetValue(math.floor(latency))
            widget:SetColour(unpack(colour))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "ava/overview_icon_underdog_score",
        tooltip = GetString(_G.BARSTEWARD_LATENCY),
        minWidthChars = "____"
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
            local colour = BS.GetColour(this, "Ok")

            usedMiB = math.ceil(usedMiB * rfactor) / rfactor

            if (usedMiB > (BS.GetVar("DangerValue", this) or 99999)) then
                colour = BS.GetColour(this, "Danger")
            elseif (usedMiB > (BS.GetVar("WarningValue", this) or 99999)) then
                colour = BS.GetColour(this, "Warning")
            end

            widget:SetValue(ZO_FastFormatDecimalNumber(tostring(usedMiB)) .. " MiB")
            widget:SetColour(unpack(colour))

            return usedMiB
        end,
        timer = 5000,
        icon = "enchanting/enchanting_highlight",
        tooltip = GetString(_G.BARSTEWARD_MEMORY),
        customOptions = {
            name = GetString(_G.BARSTEWARD_DECIMAL_PLACES),
            choices = {0, 1, 2, 3},
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
                local time = BS.FormatTime(format, nil, tamrielTime)
                local phase = getMoonPhaseIcon() or 5

                widget:SetIcon("BarSteward/assets/moon/" .. phase .. ".dds")
                widget:SetValue(time)
                widget:SetColour(unpack(BS.GetColour(this)))

                return widget:GetValue()
            end
        end,
        hideWhenTrue = function()
            return not BS.LibClock
        end,
        timer = 1000,
        tooltip = GetString(_G.BARSTEWARD_TAMRIEL_TIME),
        icon = "BarSteward/assets/moon/5.dds"
    }
}
