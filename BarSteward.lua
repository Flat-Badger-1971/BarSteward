local BS = _G.BarSteward

local function trackGold()
    local goldInBag = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    BS.Vars.Gold[character] = goldInBag
end

local function trackOtherCurrency(currency)
    local currencyInBag = GetCurrencyAmount(currency, _G.CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    BS.Vars.OtherCurrencies[currency] = BS.Vars.OtherCurrencies[currency] or {}
    BS.Vars.OtherCurrencies[currency][character] = currencyInBag
end

local function Initialise()
    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    if (_G.SLASH_COMMANDS["/rld"] == nil) then
        _G.SLASH_COMMANDS["/rld"] = function()
            if (_G.LibDebugLogger) then
                _G.LibDebugLogger:ClearLog()
            end
            ReloadUI()
        end
    end

    -- dialogs
    local buttons = {
        {
            text = BS.Format(_G.SI_OK),
            callback = function()
            end
        }
    }

    local notempty = {
        title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_BLANK)},
        buttons = buttons
    }

    local notemptyGeneric = {
        title = {text = GetString(_G.BARSTEWARD_GENERIC_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_GENERIC_BLANK)},
        buttons = buttons
    }

    local exists = {
        title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_EXISTS)},
        buttons = buttons
    }

    local existsGeneric = {
        title = {text = GetString(_G.BARSTEWARD_GENERIC_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_GENERIC_EXISTS)},
        buttons = buttons
    }

    local reload = {
        title = {text = "Bar Steward"},
        mainText = {text = GetString(_G.BARSTEWARD_RELOAD_MSG)},
        buttons = {
            {
                text = BS.Format(_G.SI_OK),
                callback = function()
                    zo_callLater(
                        function()
                            ReloadUI()
                        end,
                        200
                    )
                end
            }
        }
    }

    local remove = {
        title = {text = GetString(_G.BARSTEWARD_REMOVE_BAR)},
        mainText = {text = GetString(_G.BARSTEWARD_REMOVE_WARNING)},
        buttons = {
            {
                text = BS.Format(_G.SI_CANCEL),
                callback = function()
                    BS.BarIndex = nil
                end
            },
            {
                text = BS.Format(_G.SI_OK),
                callback = function()
                    BS.RemoveBar()
                end
            }
        }
    }

    local removeGeneric = {
        title = {text = GetString(_G.BARSTEWARD_GENERIC_REMOVE)},
        mainText = {text = GetString(_G.BARSTEWARD_GENERIC_REMOVE_WARNING)},
        buttons = {
            {
                text = BS.Format(_G.SI_CANCEL),
                callback = function(dialog)
                    if (dialog.data and dialog.data.func) then
                        dialog.data.func()
                    end
                end
            },
            {
                text = BS.Format(_G.SI_OK),
                callback = function(dialog)
                    if (dialog.data and dialog.data.func) then
                        dialog.data.func()
                    end
                end
            }
        }
    }

    local resize = {
        title = {text = "Bar Steward"},
        mainText = {text = GetString(_G.BARSTEWARD_RESIZE_MESSAGE)},
        buttons = {
            {
                text = BS.Format(_G.SI_DIALOG_YES),
                callback = function()
                    zo_callLater(
                        function()
                            ReloadUI()
                        end,
                        500
                    )
                end
            },
            {
                text = BS.Format(_G.SI_DIALOG_NO)
            }
        }
    }

    local itemExists = {
        title = {text = GetString(_G.BARSTEWARD_ITEM_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_ITEM_EXISTS)},
        buttons = buttons
    }

    local delete = {
        title = {text = BS.Format(_G.SI_KEYCODE19)},
        mainText = {
            text = function()
                local characters = BS.Join(BS.forDeletion)

                return zo_strformat(GetString(_G.BARSTEWARD_DELETE_FOR), characters)
            end
        },
        buttons = {
            {
                text = BS.Format(_G.SI_DIALOG_YES),
                callback = function()
                    BS.DeleteTrackedData()
                end
            },
            {
                text = BS.Format(_G.SI_DIALOG_NO)
            }
        }
    }

    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "NotEmpty", notempty)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "NotEmptyGeneric", notemptyGeneric)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Exists", exists)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "ExistsGeneric", existsGeneric)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "ItemExists", itemExists)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Reload", reload)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Remove", remove)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "RemoveGeneric", removeGeneric)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Resize", resize)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Delete", delete)

    -- saved variables
    BS.Vars =
        _G.LibSavedVars:NewAccountWide("BarStewardSavedVars", "Account", BS.Defaults):AddCharacterSettingsToggle(
        "BarStewardSavedVars",
        "Characters"
    )

    BS.VersionCheck()

    -- gold tracker
    BS.RegisterForEvent(_G.EVENT_PLAYER_ACTIVATED, trackGold)
    BS.RegisterForEvent(_G.EVENT_MONEY_UPDATE, trackGold)

    -- tel var tracker
    trackOtherCurrency(_G.CURT_TELVAR_STONES)
    BS.RegisterForEvent(
        _G.EVENT_TELVAR_STONE_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_TELVAR_STONES)
        end
    )

    -- alliance points tracker
    trackOtherCurrency(_G.CURT_ALLIANCE_POINTS)
    BS.RegisterForEvent(
        _G.EVENT_ALLIANCE_POINT_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_ALLIANCE_POINTS)
        end
    )

    -- writ voucher tracker
    trackOtherCurrency(_G.CURT_WRIT_VOUCHERS)
    BS.RegisterForEvent(
        _G.EVENT_WRIT_VOUCHER_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_WRIT_VOUCHERS)
        end
    )

    -- get a reference to LibClockTST if it's installed
    if (_G.LibClockTST) then
        BS.LibClock = _G.LibClockTST:Instance()
    end

    -- get a reference to LibCharacterKnowledge if it's installed
    if (_G.LibCharacterKnowledge) then
        BS.LibCK = _G.LibCharacterKnowledge
    end

    BS.RegisterSettings()

    -- create bars
    local bars = BS.Vars.Bars
    BS.alignBars = {}

    for idx, barData in pairs(bars) do
        if (not BS.Vars.Bars[idx].Disable) then
            if (idx < BS.MAX_BINDINGS) then
                ZO_CreateStringId(
                    "SI_BINDING_NAME_BARSTEWARD_KEYBIND_TOGGLE_BAR_" .. idx,
                    ZO_CachedStrFormat(_G.BARSTEWARD_TOGGLE, barData.Name)
                )
            end

            local widgets = {}
            local orderedWidgets = {}

            table.insert(BS.alignBars, barData.Name)

            -- get the widgets for this bar
            for id, info in ipairs(BS.Vars.Controls) do
                if (info.Bar == idx) then
                    local add = true
                    if (info.Requires) then
                        local requiredLib = info.Requires
                        if (_G[requiredLib] == nil) then
                            add = false
                        end
                    end

                    if (add) then
                        local widget = BS.widgets[id]
                        widget.id = id
                        table.insert(widgets, {info.Order, widget})
                    end
                end
            end

            -- add any housing widgets
            BS.AddHousingWidgets(idx, widgets)

            -- ensure the widgets are in the order we want them drawn
            table.sort(
                widgets,
                function(a, b)
                    return a[1] < b[1]
                end
            )

            if (#widgets > 0) then
                -- ensure there are no gaps in the array sequence
                local widgetIndex = 1
                for _, v in ipairs(widgets) do
                    orderedWidgets[widgetIndex] = v[2]
                    widgetIndex = widgetIndex + 1
                end

                local bar =
                    BS.CreateBar(
                    {
                        index = idx,
                        position = barData.Orientation == GetString(_G.BARSTEWARD_HORIZONTAL) and TOP or LEFT,
                        scale = barData.Scale or GuiRoot:GetScale(),
                        settings = BS.Vars.Bars[idx]
                    }
                )

                bar:AddWidgets(orderedWidgets)

                if (BS.Vars.Bars[idx].ToggleState == "hidden") then
                    zo_callLater(
                        function()
                            bar:Hide()
                        end,
                        500
                    )
                end
            end

            if (BS.Vars.Bars[idx].NudgeCompass) then
                BS.NudgeCompass()
                -- from Bandits UI
                -- stop the game move the compass back to its original position
                local block = {ZO_CompassFrame_Keyboard_Template = true, ZO_CompassFrame_Gamepad_Template = true}
                local ZO_ApplyTemplateToControl = _G.ApplyTemplateToControl
                _G.ApplyTemplateToControl = function(control, templateName)
                    if block[templateName] then
                        return
                    else
                        ZO_ApplyTemplateToControl(control, templateName)
                    end
                end
            end
        end
    end

    -- performance
    BS.RegisterForEvent(
        _G.EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            BS.CheckPerformance(inCombat)
        end
    )

    -- track character names
    if (BS.Vars.CharacterList == nil) then
        BS.Vars.CharacterList = {}

        if (BS.Vars.Gold) then
            local gold = BS.Vars.Gold

            for char, _ in pairs(gold) do
                BS.Vars.CharacterList[char] = true
            end
        end
    end

    BS.Vars.CharacterList[GetUnitName("player")] = true
end

function BS.ToggleBar(index)
    _G[BS.Name .. "_bar_" .. index].ref:Toggle()
end

function BS.OnAddonLoaded(_, addonName)
    if (addonName ~= BS.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED, BS.OnAddonLoaded)
