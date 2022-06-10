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
        tooltip = GetString(_G.SI_TRADINGHOUSELISTINGSORTTYPE0),
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

            widget:SetValue(math.floor(latency))
            widget:SetColour(unpack(BS.Vars.Controls[BS.W_LATENCY].Colour or BS.Vars.DefaultColour))

            return widget:GetValue()
        end,
        timer = 1000,
        icon = "/esoui/art/ava/overview_icon_underdog_score.dds",
        tooltip = GetString(_G.BARSTEWARD_LATENCY),
        minWidthChars = "8888"
    }
}
