local BS = _G.BarSteward

local assistantIcons = {}

for k, v in pairs(BS.ASSISTANTS) do
    assistantIcons[k] = select(3, GetCollectibleInfo(v))

    BS.widgets[k] = {
        --v1.7.0
        name = string.format("assistant%d", k),
        update = function(widget)
            local this = k
            local name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(v))

            widget:SetValue(name)
            widget:SetColour(unpack(BS.Vars.Controls[this].Colour or BS.Vars.DefaultColour))

            return name
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        tooltip = zo_strformat(
            GetString(_G.BARSTEWARD_ASSISTANT_WIDGET),
            ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleInfo(v))
        ),
        icon = assistantIcons[k],
        onClick = function()
            UseCollectible(v)
        end
    }
end
