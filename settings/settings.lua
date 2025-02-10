local BS = _G.BarSteward

BS.LAM = _G.LibAddonMenu2

BS.SoundLastPlayed = {}

local fontNames, fontStyles, backgroundNames, borderNames, none

local function initialise()
    none = BS.LC.Format(SI_ANTIALIASINGTYPE0)

    -- populate the lookup tables
    fontNames, fontStyles = BS.LC.GetFontNamesAndStyles()
    backgroundNames, borderNames =
        BS.LC.GetBackgroundsAndBorders("BARSTEWARD_BACKGROUND_STYLE_", "BARSTEWARD_BORDER_STYLE_")

    -- populate the sound selection and lookup tables
    if (not BS.SoundChoices) then
        BS.PopulateSoundOptions()
    end

    BS.options = {}
    BS.options[#BS.options + 1] = {
        type = "divider",
        height = 15,
        alpha = 0.5,
        width = "full"
    }

    BS.options[#BS.options + 1] = BS.Vars:AddAccountSettingsCheckbox()
    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_MOVEFRAME),
        getFunc = function()
            return BS.Vars.Movable
        end,
        setFunc = function(value)
            BS.Vars.Movable = value
            BS.ShowFrameMovers(value)
        end,
        width = "full",
        default = BS.Defaults.Movable
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_SNAP),
        getFunc = function()
            return BS.Vars.SnapToGrid
        end,
        setFunc = function(value)
            BS.Vars.SnapToGrid = value
        end,
        width = "full",
        default = BS.Defaults.SnapToGrid
    }

    BS.options[#BS.options + 1] = {
        type = "slider",
        name = GetString(_G.BARSTEWARD_GRID_SIZE),
        min = 2,
        max = 50,
        getFunc = function()
            return BS.Vars.GridSize
        end,
        setFunc = function(value)
            BS.Vars.GridSize = value
        end,
        default = BS.Defaults.GridSize,
        disabled = function()
            return not BS.Vars.SnapToGrid
        end
    }

    BS.options[#BS.options + 1] = {
        type = "slider",
        name = GetString(_G.BARSTEWARD_GRID_SIZE_VISIBLE),
        min = 30,
        max = 100,
        getFunc = function()
            return BS.Vars.VisibleGridSize
        end,
        setFunc = function(value)
            BS.Vars.VisibleGridSize = value
            BS.GridChanged = true
        end,
        disabled = function()
            return BS.ShowGridSetting
        end,
        default = BS.Defaults.VisibleGridSize
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_SHOW_GRID),
        getFunc = function()
            return BS.ShowGridSetting or false
        end,
        setFunc = function(value)
            BS.ShowGridSetting = value
            BS.ShowGrid(value)
        end,
        width = "full",
        default = BS.Defaults.ShowGrid
    }

    BS.options[#BS.options + 1] = {
        type = "dropdown",
        name = GetString(_G.BARSTEWARD_FONT),
        choices = fontNames,
        getFunc = function()
            return BS.Vars.Font
        end,
        setFunc = function(value)
            BS.Vars.Font = value

            BS.RegenerateAllBars()
            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont({Font = value}))
        end,
        default = BS.Defaults.Font
    }

    BS.options[#BS.options + 1] = {
        type = "dropdown",
        name = GetString(_G.BARSTEWARD_FONT_STYLE),
        choices = fontStyles,
        getFunc = function()
            return BS.Vars.FontStyle
        end,
        setFunc = function(value)
            BS.Vars.FontStyle = value

            BS.RegenerateAllBars()
            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont({Style = value}))
        end,
        default = BS.Defaults.FontStyle
    }

    BS.options[#BS.options + 1] = {
        type = "slider",
        name = GetString(_G.BARSTEWARD_FONT_SIZE),
        min = 8,
        max = 32,
        getFunc = function()
            return BS.Vars.FontSize
        end,
        setFunc = function(value)
            BS.Vars.FontSize = value

            BS.RegenerateAllBars()
            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont({Size = value}))
        end,
        default = BS.Defaults.FontSize
    }

    BS.options[#BS.options + 1] = {
        type = "description",
        text = function()
            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont())

            return "|c009933" .. GetString(_G.BARSTEWARD_SAMPLE) .. "|r"
        end,
        width = "full",
        reference = "BarSteward_SampleText"
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_USE_FONT_CORRECTION),
        tooltip = GetString(_G.BARSTEWARD_USE_FONT_CORRECTION_TOOLTIP),
        getFunc = function()
            return BS.Vars.FontCorrection
        end,
        setFunc = function(value)
            BS.Vars.FontCorrection = value
            BS.RegenerateAllBars()
        end,
        default = false
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_HIDE_MOUSE),
        getFunc = function()
            return BS.Vars.HideMouse or false
        end,
        setFunc = function(value)
            BS.Vars.HideMouse = value
        end,
        width = "full",
        default = false
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_CRIME_ONLY_DETECTION),
        tooltip = GetString(_G.BARSTEWARD_CRIME_ONLY_TOOLTIP),
        getFunc = function()
            return BS.Vars.CheckCrime or false
        end,
        setFunc = function(value)
            BS.Vars.CheckCrime = value
        end,
        requiresReload = true,
        width = "full",
        default = false
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_HIDE_DURING_COMBAT),
        getFunc = function()
            return BS.Vars.HideDuringCombat or false
        end,
        setFunc = function(value)
            BS.Vars.HideDuringCombat = value
        end,
        width = "full",
        default = false
    }

    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_HIDE_WHEN_DEAD),
        getFunc = function()
            return BS.Vars.HideWhenDead or false
        end,
        setFunc = function(value)
            BS.Vars.HideWhenDead = value
        end,
        width = "full",
        default = false
    }

    BS.options[#BS.options + 1] = {
        type = "divider",
        alpha = 0
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_ALIGN_BARS),
        func = function()
            local frame = BS.frame or BS.CreateAlignmentFrame(BS.alignBars)
            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            frame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "half"
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_REORDER_WIDGETS),
        func = function()
            local frame = BS.w_order or BS.CreateWidgetOrderTool(BS.alignBars)
            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            frame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "half"
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_COPY_SETTINGS),
        func = function()
            local frame = BS.CopyFrame or BS.CreateCopyFrame()
            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            frame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "half"
    }

    BS.options[#BS.options + 1] = {
        type = "divider",
        alpha = 0
    }
end

function BS.NewBar()
    local name = BS.NewBarName
    name = zo_strmatch(name, "^%s*(.-)%s*$")

    if ((name or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmpty")
        return
    end

    for _, bar in pairs(BS.Vars.Bars) do
        if (zo_strupper(bar.Name) == zo_strupper(name)) then
            ZO_Dialogs_ShowDialog(BS.Name .. "Exists")
            return
        end
    end

    local bars = BS.Vars.Bars
    local newBarId = #bars + 1
    local x, y = GuiRoot:GetCenter()

    BS.Vars.Bars[newBarId] = {
        Orientation = GetString(_G.BARSTEWARD_HORIZONTAL),
        Position = {X = x, Y = y},
        Name = name,
        Backdrop = {
            Show = true,
            Colour = {0.23, 0.23, 0.23, 0.7}
        },
        TooltipAnchor = GetString(_G.BARSTEWARD_BOTTOM),
        ValueSide = GetString(_G.BARSTEWARD_RIGHT)
    }

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
end

function BS.RemoveBarCheck(index)
    BS.BarIndex = index
    ZO_Dialogs_ShowDialog(BS.Name .. "Remove")
end

function BS.RemoveBar()
    if (BS.BarIndex == nil) then
        return
    end

    BS.Vars.Bars[BS.BarIndex] = nil

    local controls = BS.Vars.Controls

    for k, v in ipairs(controls) do
        if (v.Bar == BS.BarIndex) then
            BS.Vars.Controls[k].Bar = 0
        end
    end

    BS.BarIndex = nil

    zo_callLater(
        function()
            BS.DestroyBar(BS.BarIndex)
        end,
        200
    )
end

function BS.RenameBar(index)
    local name = BS.BarRename
    name = zo_strmatch(name, "^%s*(.-)%s*$")

    if ((name or "") == "") then
        ZO_Dialogs_ShowDialog(BS.Name .. "NotEmpty")
        return
    end

    for _, bar in pairs(BS.Vars.Bars) do
        if (zo_strupper(bar.Name) == zo_strupper(name)) then
            ZO_Dialogs_ShowDialog(BS.Name .. "Exists")
            return
        end
    end

    BS.Vars.Bars[index].Name = BS.BarRename
    BS.BarRename = ""

    ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
end

local function getBarSettings()
    local bars = BS.Vars.Bars
    local showOptions = {
        ["CRAFTING"] = "ShowWhilstCrafting",
        ["BANKING"] = "ShowWhilstBanking",
        ["INVENTORY"] = "ShowWhilstInventory",
        ["MAIL"] = "ShowWhilstMail",
        ["SIEGE"] = "ShowWhilstSiege",
        ["MENU"] = "ShowWhilstMenu",
        ["INTERACTING"] = "ShowWhilstInteracting",
        ["GUILDSTORE"] = "ShowWhilstGuildStore"
    }

    BS.options[#BS.options + 1] = {
        type = "header",
        name = GetString(_G.BARSTEWARD_BARS),
        width = "full"
    }

    for idx, data in ipairs(bars) do
        local vars = BS.Vars.Bars[idx]
        local controls = {
            [1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_ORIENTATION),
                choices = {GetString(_G.BARSTEWARD_HORIZONTAL), GetString(_G.BARSTEWARD_VERTICAL)},
                getFunc = function()
                    return vars.Orientation
                end,
                setFunc = function(value)
                    vars.Orientation = value
                    BS.RegenerateBar(idx)
                end,
                width = "full",
                default = BS.Defaults.Bars[1].Orientation
            },
            [2] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_SHOW_BACKDROP),
                getFunc = function()
                    return vars.Backdrop.Show
                end,
                setFunc = function(value)
                    vars.Backdrop.Show = value
                    BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx]).bar.background:SetHidden(not value)
                end,
                default = BS.Defaults.Bars[1].Backdrop.Show
            },
            [3] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_BACKDROP_COLOUR),
                getFunc = function()
                    return unpack(vars.Backdrop.Colour)
                end,
                setFunc = function(r, g, b, a)
                    vars.Backdrop.Colour = {r, g, b, a}
                    BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx]).bar.background:SetCenterColor(r, g, b, a)
                end,
                width = "full",
                disabled = function()
                    return not vars.Backdrop.Show
                end,
                default = unpack(BS.Defaults.Bars[1].Backdrop.Colour)
            },
            [4] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BACKGROUND_STYLE),
                choices = backgroundNames,
                getFunc = function()
                    if ((vars.Background or 99) == 99) then
                        return none
                    else
                        return GetString("BARSTEWARD_BACKGROUND_STYLE_", vars.Background)
                    end
                end,
                setFunc = function(value)
                    local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                    if (value == none) then
                        vars.Background = 99
                    else
                        for id, _ in pairs(BS.LC.Backgrounds) do
                            if (GetString("BARSTEWARD_BACKGROUND_STYLE_", id) == value) then
                                vars.Background = id
                                break
                            end
                        end
                    end

                    if (bar) then
                        bar.checkBackground()
                    end
                end,
                disabled = function()
                    return not vars.Backdrop.Show
                end,
                default = 99
            },
            [5] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BORDER_STYLE),
                choices = borderNames,
                getFunc = function()
                    if ((vars.Border or 99) == 99) then
                        return none
                    else
                        return GetString("BARSTEWARD_BORDER_STYLE_", vars.Border)
                    end
                end,
                setFunc = function(value)
                    local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                    if (value == none) then
                        vars.Border = 99
                    else
                        for id, _ in pairs(BS.LC.Borders) do
                            if (GetString("BARSTEWARD_BORDER_STYLE_", id) == value) then
                                vars.Border = id
                                break
                            end
                        end
                    end

                    local border = {"", 128, 2}

                    if (bar) then
                        if (vars.Border ~= 99) then
                            border = BS.LC.Borders[vars.Border]
                            bar.bar.border:SetEdgeColor(1, 1, 1, 1)
                        else
                            bar.bar.border:SetEdgeColor(0, 0, 0, 0)
                        end

                        bar.bar.border:SetEdgeTexture(unpack(border))
                        bar.checkBackground()
                    end
                end,
                disabled = function()
                    return not vars.Backdrop.Show
                end,
                default = 99
            },
            [6] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_TOOLTIP_ANCHOR),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT),
                    GetString(_G.BARSTEWARD_TOP),
                    GetString(_G.BARSTEWARD_BOTTOM)
                },
                getFunc = function()
                    return vars.TooltipAnchor
                end,
                setFunc = function(value)
                    vars.TooltipAnchor = value
                    BS.RegenerateBar(idx)
                end,
                default = BS.Defaults.Bars[1].TooltipAnchor
            },
            [7] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_VALUE_SIDE),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT)
                },
                getFunc = function()
                    return vars.ValueSide
                end,
                setFunc = function(value)
                    vars.ValueSide = value
                    BS.RegenerateBar(idx)
                end,
                default = BS.Defaults.Bars[1].ValueSide
            },
            [8] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR_ANCHOR),
                choices = {
                    GetString(_G.BARSTEWARD_LEFT),
                    GetString(_G.BARSTEWARD_RIGHT),
                    GetString(_G.BARSTEWARD_MIDDLE)
                },
                getFunc = function()
                    return vars.Anchor or GetString(_G.BARSTEWARD_MIDDLE)
                end,
                setFunc = function(value)
                    vars.Anchor = value
                    BS.RegenerateBar(idx)
                end,
                default = BS.Defaults.Bars[1].Anchor
            },
            [9] = {
                type = "slider",
                name = GetString(_G.BARSTEWARD_SCALE),
                getFunc = function()
                    return vars.Scale or 1
                end,
                setFunc = function(value)
                    vars.Scale = value

                    local barToScale = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx]).bar

                    barToScale:SetScale(value * GetUIGlobalScale())
                    barToScale:SetResizeToFitDescendents(false)
                    barToScale:SetWidth(0)
                    barToScale:SetResizeToFitDescendents(true)
                end,
                min = 0.4,
                max = 2,
                step = 0.1,
                decimals = 1,
                width = "full",
                default = BS.Defaults.Bars[1].Scale
            },
            [10] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_EXPAND),
                tooltip = GetString(_G.BARSTEWARD_EXPAND_TOOLTIP),
                getFunc = function()
                    return vars.Expand
                end,
                setFunc = function(value)
                    local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])
                    local bar = barObject.bar

                    vars.Expand = value

                    if (barObject) then
                        barObject:SetExpand(value)

                        if (value) then
                            bar.border:SetParent(bar.expandtlc)
                            bar.border:ClearAnchors()
                            bar.border:SetAnchorFill()
                        else
                            bar.border:SetParent(bar)
                            bar.border:ClearAnchors()
                            bar.border:SetAnchorFill()
                        end

                        barObject.checkBackground()
                        barObject.OnRectChanged()
                    end
                end,
                default = false,
                disabled = function()
                    return vars.Orientation ~= GetString(_G.BARSTEWARD_HORIZONTAL)
                end
            }
        }

        controls[#controls + 1] = {
            type = "divider"
        }

        if (idx ~= 1) then
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_DISABLE),
                getFunc = function()
                    return vars.Disable
                end,
                setFunc = function(value)
                    vars.Disable = value

                    if (value) then
                        BS.DestroyBar(idx)
                    else
                        BS.GenerateBar(idx)
                    end
                end,
                width = "full",
                default = false
            }
        end

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_ONLY),
            getFunc = function()
                return vars.PvPOnly or false
            end,
            setFunc = function(value)
                vars.PvPOnly = value

                local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                barObject:CheckPvP()
            end,
            width = "full",
            default = false
        }

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_CRIME_ONLY),
            tooltip = string.format(
                "%s.%s",
                GetString(_G.BARSTEWARD_CRIME_ONLY_TOOLTIP),
                BS.Vars.CrimeCheck and "" or GetString(_G.BARSTEWARD_CRIME_ONLY_CONDITION)
            ),
            getFunc = function()
                return vars.CrimeOnly or false
            end,
            setFunc = function(value)
                vars.CrimeOnly = value

                local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                barObject:CheckCrime()
            end,
            width = "full",
            default = false,
            disabled = function()
                return not BS.Vars.CheckCrime
            end
        }

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SHOW_EVERYWHERE),
            getFunc = function()
                return vars.ShowEverywhere or false
            end,
            setFunc = function(value)
                local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                vars.ShowEverywhere = value

                if (value and barObject) then
                    barObject:RemoveFromScenes(true)
                    barObject.bar:SetHidden(false)
                else
                    barObject:AddToScenes()
                end
            end,
            width = "full",
            default = false
        }

        for varType, varName in pairs(showOptions) do
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G["BARSTEWARD_SHOW_WHILST_" .. varType]),
                getFunc = function()
                    return vars[varName] or false
                end,
                setFunc = function(value)
                    vars[varName] = value

                    local barObject = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx])

                    if (barObject) then
                        local bar = barObject.bar

                        BS.AddToScenes(varType, idx, bar)

                        if (value == false) then
                            BS.RemoveFromScenes(varType, bar)
                        end
                    end
                end,
                width = "full",
                default = false,
                disabled = function()
                    return vars.ShowEverywhere
                end
            }
        end

        controls[#controls + 1] = {
            type = "divider"
        }

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_COMBAT_COLOUR),
            getFunc = function()
                return vars.CombatColourChange or false
            end,
            setFunc = function(value)
                vars.CombatColourChange = value
            end,
            width = "full",
            default = false
        }

        controls[#controls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_COMBAT_COLOUR_BACKDROP),
            getFunc = function()
                return unpack(vars.CombatColour or BS.Vars.DefaultCombatColour)
            end,
            setFunc = function(r, g, b, a)
                vars.CombatColour = {r, g, b, a}
            end,
            width = "full",
            disabled = function()
                return not vars.CombatColourChange
            end,
            default = unpack(BS.Vars.DefaultCombatColour)
        }

        -- custom overrides
        controls[#controls + 1] = {
            type = "divider"
        }

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_OVERRIDE),
            getFunc = function()
                return vars.Override
            end,
            setFunc = function(value)
                vars.Override = value
                BS.RegenerateBar(idx)
            end,
            default = false,
            width = "full"
        }

        controls[#controls + 1] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_WIDGET_ICON_SIZE),
            getFunc = function()
                return vars.IconSize or BS.Vars.IconSize
            end,
            setFunc = function(value)
                vars.IconSize = value
                BS.RegenerateBar(idx, true)
            end,
            min = 8,
            max = 64,
            width = "full",
            default = BS.Defaults.IconSize,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_ICONGAP),
            getFunc = function()
                return vars.IconGap or 10
            end,
            setFunc = function(value)
                vars.IconGap = value
                BS.UpdateIconGap(idx)
            end,
            min = 0,
            max = 40,
            width = "true"
        }

        local ref = "BarSteward_SampleText_bar_" .. idx

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_FONT),
            choices = fontNames,
            getFunc = function()
                return vars.Font or BS.Vars.Font
            end,
            setFunc = function(value)
                vars.Font = value
                BS.RegenerateBar(idx)
                _G[ref].desc:SetFont(BS.GetFont(vars))
            end,
            default = BS.Defaults.Font,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_FONT_STYLE),
            choices = fontStyles,
            getFunc = function()
                return vars.FontStyle or BS.Vars.FontStyle
            end,
            setFunc = function(value)
                vars.FontStyle = value
                BS.RegenerateBar(idx)
                _G[ref].desc:SetFont(BS.GetFont(vars))
            end,
            default = BS.Defaults.FontStyle,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_FONT_SIZE),
            min = 8,
            max = 32,
            getFunc = function()
                return vars.FontSize or BS.Vars.FontSize
            end,
            setFunc = function(value)
                vars.FontSize = value
                BS.RegenerateBar(idx)
                _G[ref].desc:SetFont(BS.GetFont(vars))
            end,
            default = BS.Defaults.FontSize,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "description",
            text = function()
                _G[ref].desc:SetFont(BS.GetFont(vars))
                return "|c009933" .. GetString(_G.BARSTEWARD_SAMPLE) .. "|r"
            end,
            width = "full",
            reference = ref
        }

        controls[#controls + 1] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_HORIZONTAL),
            getFunc = function()
                return vars.HorizontalPadding or 0
            end,
            setFunc = function(value)
                vars.HorizontalPadding = value
                BS.RegenerateBar(idx)
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_VERTICAL),
            getFunc = function()
                return vars.VerticalPadding or 0
            end,
            setFunc = function(value)
                vars.VerticalPadding = value
                BS.RegenerateBar(idx)
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            disabled = function()
                return not vars.Override
            end
        }

        controls[#controls + 1] = {
            type = "divider"
        }

        if (idx ~= 1) then
            controls[#controls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_BAR_NAME),
                getFunc = function()
                    return BS.BarRename or ""
                end,
                setFunc = function(value)
                    BS.BarRename = value
                end,
                isMultiLine = false,
                width = "half"
            }

            controls[#controls + 1] = {
                type = "button",
                name = ZO_CachedStrFormat("<<C:1>>", GetString(SI_COLLECTIBLE_ACTION_RENAME)),
                func = function()
                    BS.RenameBar(idx)
                end,
                disabled = function()
                    return (BS.BarRename or "") == ""
                end,
                warning = GetString(_G.BARSTEWARD_RELOAD),
                width = "half",
                requiresReload = true
            }

            controls[#controls + 1] = {
                type = "divider"
            }

            controls[#controls + 1] = {
                type = "button",
                name = "|ce60000" .. GetString(SI_GAMEPAD_MAIL_SEND_DETACH_ITEM) .. "|r",
                func = function()
                    BS.RemoveBarCheck(idx)
                end,
                width = "full"
            }
        else
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_NUDGE),
                getFunc = function()
                    return vars.NudgeCompass
                end,
                setFunc = function(value)
                    vars.NudgeCompass = value

                    if (value) then
                        BS.NudgeCompass()
                    else
                        BS.ResetNudge()
                    end
                end,
                width = "full",
                default = BS.Defaults.Bars[1].NudgeCompass,
                warning = GetString(_G.BARSTEWARD_NUDGE_WARNING)
            }
        end

        controls[#controls + 1] = {
            type = "button",
            name = GetString(_G.BARSTEWARD_ALIGN),
            func = function()
                local bar = BS.BarObjectPool:GetActiveObject(BS.BarObjects[idx]).bar
                local _, posY = bar:GetCenter()
                local guiHeight = GuiRoot:GetHeight() / 2
                local centre

                if (posY > guiHeight) then
                    centre = posY - guiHeight
                else
                    centre = (guiHeight - posY) * -1
                end

                bar:SetAnchor(CENTER, GuiRoot, CENTER, 0, centre)
                local xPos, yPos = bar:GetCenter()

                BS.Vars.Bars[idx].Anchor = GetString(_G.BARSTEWARD_MIDDLE)
                BS.Vars.Bars[idx].Position = {X = xPos, Y = yPos}
            end,
            width = "full"
        }

        BS.options[#BS.options + 1] = {
            type = "submenu",
            name = data.Name,
            controls = controls,
            reference = "BarStewardBar_" .. idx,
            icon = function()
                if (idx == 1) then
                    return "/esoui/art/compass/compass_dragon.dds"
                else
                    return "/esoui/art/compass/compass_waypoint.dds"
                end
            end,
            disabled = function()
                return BS.Vars.Bars[idx] == nil
            end
        }
    end

    BS.options[#BS.options + 1] = {
        type = "description",
        text = "|ce60000" .. GetString(_G.BARSTEWARD_NEWBAR_WARNING) .. "|r",
        width = "full"
    }

    BS.options[#BS.options + 1] = {
        type = "editbox",
        name = GetString(_G.BARSTEWARD_NEWBAR_NAME),
        getFunc = function()
            return BS.NewBarName or ""
        end,
        setFunc = function(value)
            BS.NewBarName = value
        end,
        isMultiLine = false,
        width = "half"
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_NEWBAR_ADD),
        func = function()
            BS.NewBar()
        end,
        disabled = function()
            return (BS.NewBarName or "") == ""
        end,
        warning = GetString(_G.BARSTEWARD_RELOAD),
        width = "half"
    }

    local barChoices = {}
    local barNumbers = {}

    for idx, bar in pairs(bars) do
        table.insert(barChoices, bar.Name)
        barNumbers[bar.Name] = idx
    end

    table.sort(barChoices)
    BS.options[#BS.options + 1] = {
        type = "dropdown",
        name = GetString(_G.BARSTEWARD_EXPORT_BAR),
        choices = barChoices,
        getFunc = function()
            return BS.Export
        end,
        setFunc = function(value)
            BS.Export = value
        end,
        default = nil
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_EXPORT),
        func = function()
            local data = BS.ExportBar(barNumbers[BS.Export])
            local exportFrame = BS.ExportFrame or BS.CreateExportFrame()

            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            exportFrame.content:SetText(data)
            exportFrame.heading:SetText(GetString(_G.BARSTEWARD_EXPORT_BAR))
            exportFrame.note:SetText(GetString(_G.BARSTEWARD_COPY))
            exportFrame.import:SetHidden(true)
            exportFrame.replace:SetHidden(true)
            exportFrame.error:SetText("")
            exportFrame.fragment:SetHiddenForReason("disabled", false)
        end,
        width = "full",
        disabled = function()
            return BS.Export == nil
        end
    }

    BS.options[#BS.options + 1] = {
        type = "button",
        name = GetString(_G.BARSTEWARD_IMPORT_BAR),
        func = function()
            local importFrame = BS.ExportFrame or BS.CreateExportFrame()

            SCENE_MANAGER:Show("hudui")
            SetGameCameraUIMode(true)
            importFrame.content:Clear()
            importFrame.heading:SetText(GetString(_G.BARSTEWARD_IMPORT_BAR))
            importFrame.note:SetText(GetString(_G.BARSTEWARD_PASTE))
            importFrame.import:SetHidden(false)
            importFrame.replace:SetHidden(false)
            importFrame.error:SetText("")
            importFrame.fragment:SetHiddenForReason("disabled", false)
            BS.ReplaceMain = false
        end,
        width = "full"
    }
end

-- Performance
local function getPerformanceSettings()
    local controls = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PERFORMANCE_TIMERS),
            tooltip = GetString(_G.BARSTEWARD_PERFORMANCE_TIMERS_TOOLTIP),
            getFunc = function()
                return BS.Vars.DisableTimersInCombat
            end,
            setFunc = function(value)
                BS.Vars.DisableTimersInCombat = value
                BS.CheckPerformance()
            end,
            default = false
        }
    }

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_PERFORMANCE),
        controls = controls,
        reference = "BarStewardPerformance",
        icon = "/esoui/art/ava/avacapturebar_fill_aldmeri.dds"
    }
end

local function getWidgetName(id)
    local tooltip = BS.widgets[id].tooltip

    if (type(tooltip) == "function") then
        tooltip = tooltip()
    end

    local widgetName = zo_strgsub(tooltip, ":", "")

    if (BS.Vars.Controls[id].Bar ~= 0) then
        widgetName = "|c4c9900" .. widgetName .. "|r"
    end

    return widgetName
end

local function getWidgetSettings()
    local widgets = BS.Vars.Controls
    local bars = BS.Vars.Bars
    local noBar = GetString(_G.BARSTEWARD_NONE_BAR)
    local barNames = {noBar}

    for _, v in ipairs(bars) do
        table.insert(barNames, v.Name)
    end

    local ordered = {}

    for key, widget in pairs(widgets) do
        if (not widget.Hidden and key < 1000) then
            table.insert(ordered, {key = key, widget = widget})
        end
    end

    if (BS.Vars.WidgetSortOrder) then
        -- sort the widget settings by index number
        table.sort(
            ordered,
            function(a, b)
                return a.key > b.key
            end
        )
    else
        -- sort the widget settings into alphabetical order
        table.sort(
            ordered,
            function(a, b)
                local tta = BS.widgets[a.key].tooltip
                local ttb = BS.widgets[b.key].tooltip

                if (type(tta) == "function") then
                    tta = tta()
                end
                if (type(ttb) == "function") then
                    ttb = ttb()
                end

                return tta < ttb
            end
        )
    end

    if (BS.Vars.WidgetSortOrderUsed) then
        -- sort the widget settings into used/unused
        local used =
            BS.LC.Filter(
            ordered,
            function(v)
                return BS.Vars.Controls[v.key].Bar > 0
            end
        )
        local unused =
            BS.LC.Filter(
            ordered,
            function(v)
                return BS.Vars.Controls[v.key].Bar == 0
            end
        )

        table.sort(
            used,
            function(a, b)
                local tta, ttb = BS.widgets[a.key].tooltip, BS.widgets[b.key].tooltip

                if (type(tta) == "function") then
                    tta = tta()
                end
                if (type(ttb) == "function") then
                    ttb = ttb()
                end

                return tta < ttb
            end
        )
        table.sort(
            unused,
            function(a, b)
                local tta, ttb = BS.widgets[a.key].tooltip, BS.widgets[b.key].tooltip

                if (type(tta) == "function") then
                    tta = tta()
                end
                if (type(ttb) == "function") then
                    ttb = ttb()
                end

                return tta < ttb
            end
        )

        ordered = BS.LC.MergeTables(used, unused)
    end

    local controls = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SORT),
            getFunc = function()
                return BS.Vars.WidgetSortOrder or false
            end,
            setFunc = function(value)
                BS.Vars.WidgetSortOrder = value

                if (value) then
                    BS.Vars.WidgetSortOrderUsed = false
                end
            end,
            width = "full",
            default = false,
            requiresReload = true
        },
        [2] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SORT_USED),
            getFunc = function()
                return BS.Vars.WidgetSortOrderUsed or false
            end,
            setFunc = function(value)
                BS.Vars.WidgetSortOrderUsed = value

                if (value) then
                    BS.Vars.WidgetSortOrder = false
                end
            end,
            width = "full",
            default = false,
            requiresReload = true
        },
        [3] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_WIDGET_ICON_SIZE),
            getFunc = function()
                return BS.Vars.IconSize
            end,
            setFunc = function(value)
                BS.Vars.IconSize = value
                BS.RegenerateAllBars()
            end,
            min = 8,
            max = 64,
            width = "full",
            default = BS.Defaults.IconSize
        },
        [4] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_HORIZONTAL),
            getFunc = function()
                return BS.Vars.HorizontalPadding or 0
            end,
            setFunc = function(value)
                BS.Vars.HorizontalPadding = value
                BS.RegenerateAllBars()
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0
        },
        [5] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_VERTICAL),
            getFunc = function()
                return BS.Vars.VerticalPadding or 0
            end,
            setFunc = function(value)
                BS.Vars.VerticalPadding = value
                BS.RegenerateAllBars()
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0
        },
        [6] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_CATEGORY_INCLUDE),
            getFunc = function()
                return BS.Vars.CategoriesCount or false
            end,
            setFunc = function(value)
                BS.Vars.CategoriesCount = value
            end,
            width = "full",
            default = false,
            requiresReload = true
        }
    }

    local defaultColours = {
        ["_"] = {0.9, 0.9, 0.9, 1},
        ["Ok"] = {0, 1, 0, 1},
        ["Warning"] = {1, 1, 0, 1},
        ["Danger"] = {0.8, 0, 0, 1}
    }

    for colourType, defaultValue in pairs(defaultColours) do
        local i18Name = string.format("BARSTEWARD_CHANGE_DEFAULT%s", zo_strgsub(zo_strupper(colourType), "_", ""))
        local defaultName = string.format("Default%sColour", zo_strgsub(colourType, "_", ""))

        controls[#controls + 1] = {
            type = "colorpicker",
            name = GetString(_G[i18Name]),
            getFunc = function()
                return unpack(BS.Vars[defaultName])
            end,
            setFunc = function(r, g, b, a)
                BS.Vars[defaultName] = {r, g, b, a}
                BS.RefreshAll()
            end,
            width = "full",
            default = unpack(defaultValue)
        }
    end

    controls[#controls + 1] = {
        type = "editbox",
        name = GetString(_G.BARSTEWARD_NUMBER_SEPARATORS),
        getFunc = function()
            return BS.Vars.NumberSeparator or GetString(_G.BARSTEWARD_NUMBER_SEPARATOR)
        end,
        setFunc = function(value)
            BS.Vars.NumberSeparator = value
            BS.RefreshAll()
        end,
        isMultiLine = false,
        isExtraWide = false,
        maxChars = 3,
        width = "full",
        default = GetString(_G.BARSTEWARD_NUMBER_SEPARATOR)
    }

    local categories = {}
    local categoryIndex = {}

    for k, cat in pairs(BS.CATEGORIES) do
        categories[k] = {
            type = "submenu",
            name = GetString(cat.name),
            icon = BS.FormatIcon(cat.icon),
            controls = {},
            reference = "BarStewardCategory_" .. k
        }

        categoryIndex[k] = 1
    end

    for _, w in ipairs(ordered) do
        local k = w.key
        local v = w.widget
        local widgetControls = {}
        local disabled = false
        local vars = BS.Vars.Controls[k]
        local defaults = BS.Defaults.Controls[k]

        if (not BS.Vars.Bars) then
            break
        end

        if (widgets[k].Requires and not _G[widgets[k].Requires]) then
            widgetControls[#widgetControls + 1] = {
                type = "description",
                text = "|cff0000" .. zo_strformat(GetString(_G.BARSTEWARD_REQUIRES), widgets[k].Requires) .. "|r",
                width = "full"
            }
            disabled = true
        else
            BS.CheckExperimental(defaults, widgetControls)

            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR),
                choices = barNames,
                getFunc = function()
                    local barName = ZO_CachedStrFormat("<<C:1>>", GetString(SI_DAMAGETYPE0))

                    if (v.Bar ~= 0) then
                        barName = BS.Vars.Bars[v.Bar].Name
                    end

                    return barName
                end,
                setFunc = function(value)
                    local tbars = BS.Vars.Bars
                    local barNum = 0

                    for bnum, bdata in ipairs(tbars) do
                        if (bdata.Name == value) then
                            barNum = bnum
                        end
                    end

                    local oldBarNum = BS.Vars.Controls[k].Bar

                    BS.Vars.Controls[k].Bar = barNum
                    BS.GetQuestInfo()
                    BS.RegenerateBar(oldBarNum, k)
                    BS.RegenerateBar(barNum)
                end,
                width = "full",
                default = BS.Defaults.Controls[k].Bar,
                disabled = function()
                    if (k ~= BS.W_TAMRIEL_TIME) then
                        return false
                    end

                    if (not BS.LibClock) then
                        return true
                    end
                end
            }
        end

        if (not disabled) then
            BS.AddSettings(defaults, widgetControls, vars, k)
        end

        local textureCoords = nil

        if (k == BS.W_ALLIANCE) then
            textureCoords = {0, 1, 0, 0.6}
        end

        local iconInfo = BS.widgets[k].icon

        if (type(iconInfo) == "function") then
            iconInfo = iconInfo()
        end

        local widgetData = {
            type = "submenu",
            name = function()
                return getWidgetName(k)
            end,
            icon = BS.FormatIcon(iconInfo),
            iconTextureCoords = textureCoords,
            controls = widgetControls,
            reference = "BarStewardWidget_" .. k
        }

        categories[vars.Cat].controls[categoryIndex[vars.Cat]] = widgetData
        categoryIndex[vars.Cat] = categoryIndex[vars.Cat] + 1
    end

    local cats = {}

    for _, cat in pairs(categories) do
        if (BS.Vars.CategoriesCount) then
            cat.name =
                string.format(
                "%s  %s",
                cat.name,
                BS.COLOURS.DefaultWarningColour:Colorize(" " .. tostring(#cat.controls))
            )
        end

        table.insert(cats, {name = cat.name, value = cat})
    end

    table.sort(
        cats,
        function(a, b)
            return a.name < b.name
        end
    )

    -- add search
    controls[#controls + 1] = BS.AddSearch()
    --

    for _, v in ipairs(cats) do
        controls[#controls + 1] = v.value
    end

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_WIDGETS),
        controls = controls,
        reference = "BarStewardWidgets",
        icon = "/esoui/art/collections/collections_tabicon_collectibles_up.dds"
    }
end

function BS.RegisterSettings()
    local version = BS.LC.GetAddonVersion(BS.Name)

    BS.Panel = {
        type = "panel",
        name = "Bar Steward",
        displayName = "|cff9900Bar |r|c4f34ebSteward|r",
        author = "Flat Badger",
        version = version,
        registerForDefaults = true,
        registerForRefresh = true
    }

    zo_callLater(
        function()
            initialise()
            getPerformanceSettings()
            BS.GetMaintenanceSettings()
            getWidgetSettings()
            BS.GetPortToHouseSettings()
            getBarSettings()
            BS.OptionsPanel = BS.LAM:RegisterAddonPanel("BarStewardOptionsPanel", BS.Panel)
            BS.LAM:RegisterOptionControls("BarStewardOptionsPanel", BS.options)
        end,
        500
    )
end
