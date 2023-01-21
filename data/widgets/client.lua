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

BS.widgets = {
    [BS.W_TIME] = {
        name = "time",
        update = function(widget)
            local format = BS.Vars.TimeFormat24

            if (BS.Vars.TimeType == GetString(_G.BARSTEWARD_12)) then
                format = BS.Vars.TimeFormat12
            end

            local time = BS.FormatTime(format)

            widget:SetValue(time)
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_TIME].Colour or BS.Vars.DefaultColour))
            return widget:GetValue()
        end,
        timer = 1000,
        tooltip = BS.Format(_G.SI_TRADINGHOUSELISTINGSORTTYPE0),
        icon = "/esoui/art/lfg/lfg_indexicon_timedactivities_up.dds"
    },
    [BS.W_FPS] = {
        name = "fps",
        update = function(widget)
            local framerate = GetFramerate()

            widget:SetValue(math.floor(framerate))
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_FPS].Colour or BS.Vars.DefaultColour))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "/esoui/art/champion/actionbar/champion_bar_combat_selection.dds",
        tooltip = GetString(_G.BARSTEWARD_FPS),
        minWidthChars = "888"
    },
    [BS.W_LATENCY] = {
        name = "latency",
        update = function(widget)
            local latency = GetLatency()
            local vars = BS.Vars.Controls[BS.W_LATENCY]
            local colour = vars.Colour or BS.Vars.DefaultColour

            if ((vars.WarningValue or 0) > 0) then
                if (latency >= (vars.WarningValue or 0)) then
                    colour = vars.WarningColour or BS.Vars.DefaultWarningColour
                end
            end

            if ((vars.DangerValue or 0) > 0) then
                if (latency >= (vars.DangerValue or 0)) then
                    colour = vars.DangerColour or BS.Vars.DefaultDangerColour
                end
            end

            widget:SetValue(math.floor(latency))
            widget:SetColour(unpack(colour))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "/esoui/art/ava/overview_icon_underdog_score.dds",
        tooltip = GetString(_G.BARSTEWARD_LATENCY),
        minWidthChars = "8888"
    },
    [BS.W_MEMORY] = {
        -- v1.2.2
        name = "memory",
        update = function(widget)
            local usedKiB = collectgarbage("count")
            local usedMiB = (usedKiB / 1024)
            local vars = BS.Vars.Controls[BS.W_MEMORY]
            local precision = vars.Precision or 1
            local rfactor = 10 ^ precision
            local colour = vars.OkColour or BS.Vars.DefaultOkColour

            usedMiB = math.ceil(usedMiB * rfactor) / rfactor

            if (usedMiB > (vars.DangerValue or 99999)) then
                colour = vars.DangerColour or BS.Vars.DefaultDangerColour
            elseif (usedMiB > (vars.WarningValue or 99999)) then
                colour = vars.WarningColour or BS.Vars.DefaultWarningColour
            end

            widget:SetValue(ZO_FastFormatDecimalNumber(tostring(usedMiB)) .. " MiB")
            widget:SetColour(unpack(colour))

            return usedMiB
        end,
        timer = 5000,
        icon = "/esoui/art/enchanting/enchanting_highlight.dds",
        tooltip = GetString(_G.BARSTEWARD_MEMORY),
        customOptions = {
            name = GetString(_G.BARSTEWARD_DECIMAL_PLACES),
            choices = {0, 1, 2, 3},
            varName = "Precision",
            refresh = true,
            default = 1
        },
        minWidthChars = "888888"
    },
    [BS.W_TAMRIEL_TIME] = {
        -- v1.3.17
        name = "tamrielTime",
        update = function(widget)
            local vars = BS.Vars.Controls[BS.W_TAMRIEL_TIME]
            local format = vars.TimeFormat24 or BS.Defaults.TimeFormat24

            if ((vars.TimeType or BS.Defaults.TimeType) == GetString(_G.BARSTEWARD_12)) then
                format = vars.TimeFormat12 or BS.Defaults.TimeFormat12
            end

            if (BS.LibClock) then
                local tamrielTime = BS.LibClock:GetTime()
                local time = BS.FormatTime(format, nil, tamrielTime)
                local phase = getMoonPhaseIcon() or 5

                widget:SetIcon("BarSteward/assets/moon/" .. phase .. ".dds")
                widget:SetValue(time)
                widget:SetColour(unpack(vars.Colour or BS.Vars.DefaultColour))

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
