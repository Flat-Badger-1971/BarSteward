local BS = _G.BarSteward
local iconPaths = {
    "/esoui/art/lfg/lfg_dps_up_64.dds",
    "/esoui/art/icons/ability_templar_ripping_spear.dds",
    "/esoui/art/lfg/lfg_healer_up_64.dds",
    "/esoui/art/icons/ability_companion_templar_cleansing_ritual.dds",
    "/esoui/art/lfg/lfg_tank_up_64.dds",
    "/esoui/art/icons/ability_1handed_004_a.dds",
    "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    "/esoui/art/tradinghouse/tradinghouse_weapons_1h_sword_up.dds"
}

local ignoreTypes = {
   -- [_G.INSTANCE_DISPLAY_TYPE_NONE] = true,
    [_G.INSTANCE_DISPLAY_TYPE_HOUSING] = true,
    [_G.INSTANCE_DISPLAY_TYPE_ZONE_STORY] = true
}

BS.widgets[BS.W_ACTIVE_BAR] = {
    -- v1.3.18
    name = "activeBar",
    update = function(widget, event, _, _, _, instanceDisplayType)
        local this = BS.W_ACTIVE_BAR
        local vars = BS.Vars.Controls[this]
        local activeWeaponPair = GetActiveWeaponPairInfo()
        local mainIcon = vars.MainIcon or BS.Defaults.MainBarIcon
        local backIcon = vars.BackIcon or BS.Defaults.BackBarIcon
        local icon = activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP and backIcon or mainIcon
        local text =
            activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP and GetString(_G.BARSTEWARD_BACK_BAR) or
            GetString(_G.BARSTEWARD_MAIN_BAR)

        if (event == _G.EVENT_PREPARE_FOR_JUMP and vars.Warn) then
            if (not ignoreTypes[instanceDisplayType]) then
                if
                    (activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP or
                        (activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_MAIN and not vars.WarnOnBackOnly))
                 then
                    zo_callLater(
                        function()
                            BS.Announce(
                                GetString(_G.BARSTEWARD_WARNING),
                                zo_strformat(GetString(_G.BARSTEWARD_WARN_INSTANCE_MESSAGE), text),
                                this,
                                nil,
                                nil,
                                icon
                            )
                        end,
                        2000
                    )
                end
            end
        else
            local colour =
                activeWeaponPair == _G.ACTIVE_WEAPON_PAIR_BACKUP and (vars.BackColour or BS.Vars.DefaultColour) or
                (vars.MainColour or BS.Defaults.DefaultColour)

            widget:SetColour(unpack(colour))
            widget:SetValue(text)
            widget:SetIcon(icon)
        end

        return activeWeaponPair
    end,
    event = {_G.EVENT_ACTIVE_WEAPON_PAIR_CHANGED, _G.EVENT_PREPARE_FOR_JUMP},
    icon = "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    tooltip = GetString(_G.BARSTEWARD_ACTIVE_BAR),
    customSettings = {
        [1] = {
            type = "iconpicker",
            name = GetString(_G.BARSTEWARD_MAIN_BAR_ICON),
            choices = iconPaths,
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].MainIcon or BS.Defaults.MainBarIcon
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].MainIcon = value
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            iconSize = 48,
            width = "full",
            default = BS.Defaults.MainBarIcon
        },
        [2] = {
            type = "iconpicker",
            name = GetString(_G.BARSTEWARD_BACK_BAR_ICON),
            choices = iconPaths,
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].BackIcon or BS.Defaults.MainBarIcon
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].BackIcon = value
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            iconSize = 48,
            width = "full",
            default = BS.Defaults.BackBarIcon
        },
        [3] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_MAIN_BAR_TEXT),
            getFunc = function()
                return unpack(BS.Vars.Controls[BS.W_ACTIVE_BAR].MainColour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].MainColour = {r, g, b, a}
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            width = "full",
            default = unpack(BS.Defaults.DefaultColour)
        },
        [4] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_BACK_BAR_TEXT),
            getFunc = function()
                return unpack(BS.Vars.Controls[BS.W_ACTIVE_BAR].BackColour or BS.Vars.DefaultColour)
            end,
            setFunc = function(r, g, b, a)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].BackColour = {r, g, b, a}
                BS.RefreshWidget(BS.W_ACTIVE_BAR)
            end,
            width = "full",
            default = unpack(BS.Defaults.DefaultColour)
        },
        [5] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_WARN_INSTANCE),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn = value
            end,
            width = "full",
            default = false
        },
        [6] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_WARN_INSTANCE_BACK_BAR),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ACTIVE_BAR].WarnOnBackOnly or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ACTIVE_BAR].WarnOnBackOnly = value
            end,
            disable = function()
                return not BS.Vars.Controls[BS.W_ACTIVE_BAR].Warn
            end,
            width = "full",
            default = false
        }
    }
}
