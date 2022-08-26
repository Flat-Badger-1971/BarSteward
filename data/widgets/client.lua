local BS = _G.BarSteward

--[[
    {
        name = [string] "widget name",
        update = [function] function that takes widget as an argument and sets the widget value / colour. Must return the raw value,
        timer = [number] [optional] the time interval in ms before the update function is called again,
        event = [string/table] [optional] the event or array of events that will trigger the update function,
        filter = [table] table of filters to apply to an event. Key is the event, value is another table indicating the filter and value
        tooltip = [string] [optional] the tooltip text that will display when the user hovers over the value,
        icon = [string/function] path to the eso texture file,
        hideWhenTrue = [function] this boolean result of this functions determines if the widget should be hidden or not,
        minWidthChars = [string] string to use to set the minimum width of the widget value,
        onClick = [function] function to call when the widget is clicked,
        complete = [function] return true to indicate completion,
        customOptions = [object] - {
            name = [string] name for custom options,
            choices = [array] choices for custom options dropdown,
            default = [string/number] default value,
            refresh = [boolean] refresh the widget's value,
            varName = [string] saved vars variable name
        }
    }
]]
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
        tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_TRADINGHOUSELISTINGSORTTYPE0)),
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
            local colour = BS.Vars.Controls[BS.W_LATENCY].Colour or BS.Vars.DefaultColour

            if ((BS.Vars.Controls[BS.W_LATENCY].WarningValue or 0) > 0) then
                if (latency >= (BS.Vars.Controls[BS.W_LATENCY].WarningValue or 0)) then
                    colour = BS.Vars.Controls[BS.W_LATENCY].WarningColour or BS.Vars.DefaultWarningColour
                end
            end

            if ((BS.Vars.Controls[BS.W_LATENCY].DangerValue or 0) > 0) then
                if (latency >= (BS.Vars.Controls[BS.W_LATENCY].DangerValue or 0)) then
                    colour = BS.Vars.Controls[BS.W_LATENCY].DangerColour or BS.Vars.DefaultDangerColour
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
            local precision = BS.Vars.Controls[BS.W_MEMORY].Precision or 1
            local rfactor = 10 ^ precision
            local colour = BS.Vars.DefaultOkColour

            usedMiB = math.ceil(usedMiB * rfactor) / rfactor

            if (usedMiB > (BS.Vars.Controls[BS.W_MEMORY].DangerValue or 99999)) then
                colour = BS.Vars.Controls[BS.W_MEMORY].DangerColour or BS.Vars.DefaultDangerColour
            elseif (usedMiB > (BS.Vars.Controls[BS.W_MEMORY].WarningValue or 99999)) then
                colour = BS.Vars.Controls[BS.W_MEMORY].WarningColour or BS.Vars.DefaultWarningColour
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
    }
}
