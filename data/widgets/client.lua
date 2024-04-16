local BS = _G.BarSteward

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

local function addContextMenu(widget)
    widget:SetHandler(
        "OnMouseDown",
        function(self, button)
            if (button == _G.MOUSE_BUTTON_INDEX_RIGHT) then
                ClearMenu()
                AddMenuItem(
                    "Test",
                    function()
                        d("test")
                    end
                )
                ShowMenu()
            end
        end
    )
end

local timers = {
    [1] = {
        type = "description",
        text = "|cffff00" .. "Set to 0:00 to disable|r" .. BS.LF .. "|cffc0c0Important, use the format mins:secs|r",
        width = "full"
    }
}

do
    for timer = 1, 5 do
        timers[timer + 1] = {
            type = "editbox",
            name = "Timer " .. ZO_CachedStrFormat("<<n:1>>", timer),
            getFunc = function()
                return "0:00"
            end,
            setFunc = function(value)
            end,
            width = "full"
        }
    end
end

BS.widgets = {
    [BS.W_TIME] = {
        name = "time",
        update = function(widget, init)
            if (init == "initial") then
                addContextMenu(widget)
            end

            local format = BS.GetVar("TimeFormat24")
            local this = BS.W_TIME

            if (BS.GetVar("TimeType") == GetString(_G.BARSTEWARD_12)) then
                format = BS.GetVar("TimeFormat12")
            end

            local time = BS.FormatTime(format)

            widget:SetValue(time)
            widget:SetColour(unpack(BS.GetColour(this)))
            return widget:GetValue()
        end,
        timer = 1000,
        tooltip = BS.Format(_G.SI_TRADINGHOUSELISTINGSORTTYPE0),
        icon = "lfg/lfg_indexicon_timedactivities_up",
        customSettings = {
            [1] = {
                type = "submenu",
                name = "Timers",
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
