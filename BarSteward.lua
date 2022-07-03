local BS = _G.BarSteward

local function trackGold()
    local goldInBag = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    BS.Vars.Gold[character] = goldInBag
end

local function Initialise()
    -- dialogs
    local buttons = {
        {
            text = GetString(_G.SI_OK),
            callback = function()
            end
        }
    }

    local notempty = {
        title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_BLANK)},
        buttons = buttons
    }

    local exists = {
        title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
        mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_EXISTS)},
        buttons = buttons
    }

    local reload = {
        title = {text = "Bar Steward"},
        mainText = {text = GetString(_G.BARSTEWARD_RELOAD_MSG)},
        buttons = {
            {
                text = GetString(_G.SI_OK),
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
                text = GetString(_G.SI_CANCEL),
                callback = function()
                    BS.BarIndex = nil
                end
            },
            {
                text = GetString(_G.SI_OK),
                callback = function()
                    BS.RemoveBar()
                end
            }
        }
    }

    local resize = {
        title = {text = "Bar Steward"},
        mainText = {text = GetString(_G.BARSTEWARD_RESIZE_MESSAGE)},
        buttons = {
            {
                text = GetString(_G.SI_DIALOG_YES),
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
                text = GetString(_G.SI_DIALOG_NO)
            }
        }
    }

    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "NotEmpty", notempty)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Exists", exists)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Reload", reload)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Remove", remove)
    ZO_Dialogs_RegisterCustomDialog(BS.Name .. "Resize", resize)

    -- saved variables
    BS.Vars =
        _G.LibSavedVars:NewAccountWide("BarStewardSavedVars", "Account", BS.Defaults):AddCharacterSettingsToggle(
        "BarStewardSavedVars",
        "Characters"
    )

    BS.VersionCheck()
    BS.RegisterSettings()

    -- create bars
    local bars = BS.Vars.Bars
    BS.alignBars = {}

    for idx, barData in pairs(bars) do
        local widgets = {}
        local orderedWidgets = {}

        table.insert(BS.alignBars, barData.Name)

        -- get the widgets for this bar
        for id, info in ipairs(BS.Vars.Controls) do
            if (info.Bar == idx) then
                local widget = BS.widgets[id]
                widget.id = id
                table.insert(widgets, {info.Order, widget})
            end
        end

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

    -- gold tracker
    BS.RegisterForEvent(_G.EVENT_PLAYER_ACTIVATED, trackGold)
    BS.RegisterForEvent(_G.EVENT_MONEY_UPDATE, trackGold)

    EVENT_MANAGER:RegisterForEvent(
        BS.Name,
        _G.EVENT_ALL_GUI_SCREENS_RESIZED,
        function()
            ZO_Dialogs_ShowDialog(BS.Name .. "Resize")
        end
    )
    -- utiltity
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end
end

function BS.OnAddonLoaded(_, addonName)
    if (_G.LibChatMessage ~= nil) then
        BS.Chat = _G.LibChatMessage(BS.Name, "Bar Steward")
    end

    if (addonName ~= BS.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED, BS.OnAddonLoaded)
