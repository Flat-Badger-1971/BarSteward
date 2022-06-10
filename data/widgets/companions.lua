local BS = _G.BarSteward

BS.widgets[BS.W_RAPPORT] = {
    name = "rapport",
    update = function(widget)
        local rapportValue = GetActiveCompanionRapport()
        local rapportMax = GetMaximumRapport()
        local rapportMin = GetMinimumRapport()
        local rdr, rdg, rdb = 0, 153 / 255, 102 / 255 -- dislike
        local rmr, rmg, rmb = 157 / 255, 132 / 255, 13 / 255 -- moderate
        local rlr, rlg, rlb = 114 / 255, 35 / 255, 35 / 255 -- like
        local rapportPcValue = rapportValue - rapportMin
        local rapportPcMax = rapportMax - rapportMin
        local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
        local r, g, b = BS.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

        widget:SetColour(r, g, b, 1)
        widget:SetValue(rapportValue)

        return rapportValue
    end,
    event = {_G.EVENT_COMPANION_RAPPORT_UPDATE, _G.EVENT_ACTIVE_COMPANION_STATE_CHANGED},
    icon = "/esoui/art/hud/lootHistory_icon_rapportincrease_generic.dds",
    tooltip = GetString(_G.BARSTEWARD_RAPPORT),
    hideWhenEqual = function()
        if (HasActiveCompanion()) then
            return GetMaximumRapport()
        else
            return 0
        end
    end
}
