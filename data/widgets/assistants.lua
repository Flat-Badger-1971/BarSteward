local BS = _G.BarSteward

local assistantIcons = {}

for k, v in pairs(BS.ASSISTANTS) do
    assistantIcons[k] = select(3, GetCollectibleInfo(v))

    BS.widgets[k] = {
        --v1.7.0
        name = string.format("assistant%d", k),
        update = function(widget)
            local this = k
            local name = ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleName(v))

            widget:SetValue(name)
            widget:SetColour(BS.GetColour(this, true))

            return name
        end,
        event = _G.EVENT_PLAYER_ACTIVATED,
        tooltip = zo_strformat(
            GetString(_G.BARSTEWARD_ASSISTANT_WIDGET),
            ZO_CachedStrFormat(_G.SI_UNIT_NAME, GetCollectibleName(v))
        ),
        icon = assistantIcons[k],
        onLeftClick = function()
            UseCollectible(v)
        end,
        customSettings = {
            [1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_HIDE_TEXT),
                getFunc = function()
                    return BS.Vars.Controls[k].NoValue or false
                end,
                setFunc = function(value)
                    BS.Vars.Controls[k].NoValue = value
                    BS.GetWidget(k):SetNoValue(value)
                    BS.RegenerateBar(BS.Vars.Controls[k].Bar, k)
                end,
                width = "full",
                default = false
            }
        }
    }
end
