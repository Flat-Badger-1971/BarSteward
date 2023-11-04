local BS = _G.BarSteward

BS.LAM = _G.LibAddonMenu2
BS.VERSION = "1.7.4"

local panel = {
    type = "panel",
    name = "Bar Steward",
    displayName = "|cff9900Bar Steward|r",
    author = "Flat Badger",
    version = BS.VERSION,
    registerForDefaults = true,
    registerForRefresh = true,
    slashCommand = "/bs"
}

local soundChoices = {}
BS.SoundLookup = {}
BS.SoundLastPlayed = {}

-- populate the sound selection and lookup tables
do
    for _, v in ipairs(BS.Sounds) do
        if (_G.SOUNDS[v] ~= nil) then
            local soundName = _G.SOUNDS[v]:gsub("_", " ")
            table.insert(soundChoices, soundName)
            BS.SoundLookup[soundName] = _G.SOUNDS[v]
        end
    end
end

-- populate the lookup tables
local fontNames = {}
local backgroundNames = {}
local borderNames = {}

do
    for font, _ in pairs(BS.FONTS) do
        table.insert(fontNames, font)
    end

    for background, _ in pairs(BS.BACKGROUNDS) do
        table.insert(backgroundNames, GetString("BARSTEWARD_BACKGROUND_STYLE_", background))
    end

    table.insert(backgroundNames, " ")

    for border, _ in pairs(BS.BORDERS) do
        table.insert(borderNames, GetString("BARSTEWARD_BORDER_STYLE_", border))
    end

    table.insert(borderNames, " ")
end

local function initialise()
    BS.options = {}
    BS.options[#BS.options + 1] = BS.Vars:GetLibAddonMenuAccountCheckbox()
    BS.options[#BS.options + 1] = {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_MOVEFRAME),
        getFunc = function()
            return BS.Vars.Movable
        end,
        setFunc = function(value)
            BS.Vars.Movable = value

            for _, bar in ipairs(BS.Bars) do
                _G[bar]:SetMovable(value)
                _G[bar].ref.bar.overlay:SetHidden(not value)
            end

            local frame = BS.lock or BS.CreateLockButton()

            if (value) then
                SCENE_MANAGER:Show("hudui")
                frame.fragment:SetHiddenForReason("disabled", false)
                SetGameCameraUIMode(true)
            else
                frame.fragment:SetHiddenForReason("disabled", true)
            end
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

            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont(value))
        end,
        requiresReload = true,
        default = BS.Defaults.Font
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
            _G.BarSteward_SampleText.desc:SetFont(BS.GetFont())
        end,
        requiresReload = true,
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
        end,
        requiresReload = true,
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
        type = "divider",
        alpha = 0
    }
end

function BS.NewBar()
    local name = BS.NewBarName
    name = name:match("^%s*(.-)%s*$")

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
            ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
        end,
        200
    )
end

function BS.RenameBar(index)
    local name = BS.BarRename
    name = name:match("^%s*(.-)%s*$")

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
                end,
                width = "full",
                requiresReload = true,
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
                    _G[BS.Name .. "_bar_" .. idx].background:SetHidden(not value)
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
                    _G[BS.Name .. "_bar_" .. idx].background:SetCenterColor(r, g, b, a)
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
                        return " "
                    else
                        return GetString("BARSTEWARD_BACKGROUND_STYLE_", vars.Background)
                    end
                end,
                setFunc = function(value)
                    local bar = _G[BS.Name .. "_bar_" .. idx]

                    if (value == " ") then
                        vars.Background = 99
                    else
                        for id, _ in pairs(BS.BACKGROUNDS) do
                            if (GetString("BARSTEWARD_BACKGROUND_STYLE_", id) == value) then
                                vars.Background = id
                                break
                            end
                        end
                    end

                    if (bar) then
                        bar.ref.checkBackground()
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
                        return " "
                    else
                        return GetString("BARSTEWARD_BORDER_STYLE_", vars.Border)
                    end
                end,
                setFunc = function(value)
                    local bar = _G[BS.Name .. "_bar_" .. idx]

                    if (value == " ") then
                        vars.Border = 99
                    else
                        for id, _ in pairs(BS.BORDERS) do
                            if (GetString("BARSTEWARD_BORDER_STYLE_", id) == value) then
                                vars.Border = id
                                break
                            end
                        end
                    end

                    local border = {"", 128, 2}

                    if (bar) then
                        if (vars.Border ~= 99) then
                            border = BS.BORDERS[vars.Border]
                            bar.border:SetEdgeColor(1, 1, 1, 1)
                        else
                            bar.border:SetEdgeColor(0, 0, 0, 0)
                        end

                        bar.border:SetEdgeTexture(unpack(border))
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
                end,
                requiresReload = true,
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
                end,
                requiresReload = true,
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
                end,
                requiresReload = true,
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

                    local barToScale = _G[BS.Name .. "_bar_" .. idx]

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
                    vars.Expand = value

                    local bar = _G[BS.Name .. "_bar_" .. idx]

                    if (bar) then
                        bar.ref.checkBackground()

                        if (value) then
                            bar.border:SetParent(bar.expandtlc)
                            bar.border:ClearAnchors()
                            bar.border:SetAnchorFill()
                        else
                            bar.border:SetParent(bar)
                            bar.border:ClearAnchors()
                            bar.border:SetAnchorFill()
                        end
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
                end,
                width = "full",
                default = false,
                requiresReload = true
            }
        end

        controls[#controls + 1] = {
            type = "checkbox",
            name = GetString(_G["BARSTEWARD_SHOW_EVERYWHERE"]),
            getFunc = function()
                return vars.ShowEverywhere or false
            end,
            setFunc = function(value)
                vars.ShowEverywhere = value
            end,
            width = "full",
            default = false,
            requiresReload = true
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

                    local barname = _G[BS.Name .. "_bar_" .. idx]

                    if (barname) then
                        local bar = barname.ref.bar

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
            end,
            default = false,
            requiresReload = true,
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
            end,
            min = 8,
            max = 64,
            width = "full",
            default = BS.Defaults.IconSize,
            requiresReload = true,
            disabled = function()
                return not vars.Override
            end
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

                _G[ref].desc:SetFont(BS.GetFont(vars))
            end,
            requiresReload = true,
            default = BS.Defaults.Font,
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

                _G[ref].desc:SetFont(BS.GetFont(vars))
            end,
            requiresReload = true,
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
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            requiresReload = true,
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
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            requiresReload = true,
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
                name = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_COLLECTIBLE_ACTION_RENAME)),
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
                name = "|ce60000" .. GetString(_G.SI_GAMEPAD_MAIL_SEND_DETACH_ITEM) .. "|r",
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
                end,
                width = "full",
                requiresReload = true,
                default = BS.Defaults.Bars[1].NudgeCompass,
                warning = GetString(_G.BARSTEWARD_NUDGE_WARNING)
            }
        end

        controls[#controls + 1] = {
            type = "button",
            name = GetString(_G.BARSTEWARD_ALIGN),
            func = function()
                local bar = _G[BS.Name .. "_bar_" .. idx]
                local _, posY = bar:GetCenter()
                local guiHeight = GuiRoot:GetHeight() / 2
                local centre

                if (posY > guiHeight) then
                    centre = posY - guiHeight
                else
                    centre = (guiHeight - posY) * -1
                end

                _G[BS.Name .. "_bar_" .. idx]:SetAnchor(CENTER, GuiRoot, CENTER, 0, centre)
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
            reference = "BarStewardBar" .. idx,
            icon = function()
                if (idx == 1) then
                    return "/esoui/art/compass/compass_dragon.dds"
                else
                    return "/esoui/art/compass/compass_waypoint.dds"
                end
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
            importFrame.error:SetText("")
            importFrame.fragment:SetHiddenForReason("disabled", false)
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
        reference = "Performance",
        icon = "/esoui/art/ava/avacapturebar_fill_aldmeri.dds"
    }
end

-- 12 hour time formats
local twelveFormats = {
    "hh:m:s",
    "hh:m:s a",
    "hh:m:s A",
    "h:m:s",
    "h:m:s a",
    "h:m:s A",
    "hh:m",
    "hh:m a",
    "hh:m A",
    "h:m",
    "h:m a",
    "h:m A",
    "hh.m.s",
    "hh.m.s a",
    "hh.m.s A",
    "h.m.s",
    "h.m.s a",
    "h.m.s A",
    "hh.m",
    "hh.m a",
    "hh.m A",
    "h.m",
    "h.m a",
    "h.m A"
}

-- 24 hour time formats
local twentyFourFormats = {
    "HH:m:s",
    "H:m:s",
    "HH:m",
    "H:m",
    "HH.m.s",
    "H.m.s",
    "HH.m",
    "H.m"
}

local function getCV(index)
    local var = BS.Vars.Controls[index].ColourValues
    local lookup = {}

    if ((var or "") ~= "") then
        for _, val in ipairs(BS.Split(var)) do
            lookup[val] = true
        end

        return lookup
    end

    return nil
end

local function checkAutoHide(defaults, widgetControls, vars, key)
    if (defaults.Autohide ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_AUTOHIDE),
            tooltip = GetString(_G.BARSTEWARD_AUTOHIDE_TOOLTIP),
            getFunc = function()
                return vars.Autohide
            end,
            setFunc = function(value)
                vars.Autohide = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.Autohide
        }
    end
end

local function checkInvert(defaults, widgetControls, vars, key)
    if (defaults.Invert ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_INVERT),
            tooltip = GetString(_G.BARSTEWARD_INVERT_TOOLTIP),
            getFunc = function()
                return vars.Invert or false
            end,
            setFunc = function(value)
                vars.Invert = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = false
        }
    end
end

local function checkHideWhenComplete(defaults, widgetControls, vars, key)
    if (defaults.HideWhenComplete ~= nil or defaults.HideWhenCompleted ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE),
            tooltip = (defaults.HideWhenCompleted ~= nil) and "" or GetString(_G.BARSTEWARD_HIDE_WHEN_COMPLETE_TOOLTIP),
            getFunc = function()
                return vars.HideWhenComplete
            end,
            setFunc = function(value)
                vars.HideWhenComplete = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenComplete
        }
    end
end

local function checkHideWhenFullyUsed(defaults, widgetControls, vars, key)
    if (defaults.HideWhenFullyUsed ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED),
            tooltip = GetString(_G.BARSTEWARD_HIDE_WHEN_FULLY_USED_TOOLTIP),
            getFunc = function()
                return vars.HideWhenFullyUsed
            end,
            setFunc = function(value)
                vars.HideWhenFullyUsed = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenFullyUsed
        }
    end
end

local function checkHideWhenMaxLevel(defaults, widgetControls, vars, key)
    if (defaults.HideWhenMaxLevel ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_MAX),
            getFunc = function()
                return vars.HideWhenMaxLevel
            end,
            setFunc = function(value)
                vars.HideWhenMaxLevel = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.HideWhenMaxLevel
        }
    end
end

local function checkPvPOnly(defaults, widgetControls, vars, key)
    if (defaults.PvPOnly ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PVP_ONLY),
            getFunc = function()
                return vars.PvPOnly
            end,
            setFunc = function(value)
                vars.PvPOnly = value
                BS.RefreshBar(key)
            end,
            width = "full",
            default = defaults.PvPOnly
        }
    end
end

local function checkShowPercentage(defaults, widgetControls, vars, key)
    if (defaults.ShowPercent ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_PERCENTAGE),
            getFunc = function()
                return vars.ShowPercent
            end,
            setFunc = function(value)
                vars.ShowPercent = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.ShowPercent
        }
    end
end

local function checkUseSeparators(defaults, widgetControls, vars, key)
    if (defaults.UseSeparators ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_ADD_SEPARATORS),
            getFunc = function()
                return vars.UseSeparators
            end,
            setFunc = function(value)
                vars.UseSeparators = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.UseSeparators
        }
    end
end

local function checkHideSeconds(defaults, widgetControls, vars, key)
    if (defaults.HideSeconds ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_SECONDS),
            getFunc = function()
                return vars.HideSeconds
            end,
            setFunc = function(value)
                vars.HideSeconds = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideSeconds
        }
    end
end

local function checkHideDaysWhenZero(defaults, widgetControls, vars, key)
    if (defaults.HideDaysWhenZero ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_ZERO_DAYS),
            getFunc = function()
                return vars.HideDaysWhenZero
            end,
            setFunc = function(value)
                vars.HideDaysWhenZero = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideDaysWhenZero
        }
    end
end

local function checkHideLimit(defaults, widgetControls, vars, key)
    if (defaults.HideLimit ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_HIDE_LIMIT),
            tooltip = GetString(_G.BARSTEWARD_HIDE_LIMIT_TOOLTIP),
            getFunc = function()
                return vars.HideLimit
            end,
            setFunc = function(value)
                vars.HideLimit = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.HideLimit
        }
    end
end

local function checkNoLimitColour(defaults, widgetControls, vars, key)
    if (defaults.NoLimitColour ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR),
            tooltip = GetString(_G.BARSTEWARD_NO_LIMIT_COLOUR_TOOLTIP),
            getFunc = function()
                return vars.NoLimitColour
            end,
            setFunc = function(value)
                vars.NoLimitColour = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.NoLimitColour
        }
    end
end

local function checkShowFreeSpace(defaults, widgetControls, vars, key)
    if (defaults.ShowFreeSpace ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_BAG_FREE),
            tooltip = GetString(_G.BARSTEWARD_BAG_FREE_TOOLTIP),
            getFunc = function()
                return vars.ShowFreeSpace or false
            end,
            setFunc = function(value)
                vars.ShowFreeSpace = value
                BS.RefreshWidget(key)
            end,
            width = "full",
            default = defaults.ShowFreeSpace
        }
    end
end

local function checkSoundWhenEquals(defaults, widgetControls, vars)
    if (defaults.SoundWhenEquals ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SOUND_VALUE_EQUALS),
            getFunc = function()
                return vars.SoundWhenEquals
            end,
            setFunc = function(value)
                vars.SoundWhenEquals = value
            end,
            width = "full",
            default = defaults.SoundWhenEquals
        }

        widgetControls[#widgetControls + 1] = {
            type = "editbox",
            name = GetString(_G.BARSTEWARD_VALUE),
            getFunc = function()
                return vars.SoundWhenEqualsValue
            end,
            setFunc = function(value)
                vars.SoundWhenEqualsValue = value
            end,
            width = "full",
            disabled = function()
                return not vars.SoundWhenEquals
            end,
            default = nil
        }

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_SOUND),
            choices = soundChoices,
            getFunc = function()
                return vars.SoundWhenEqualsSound
            end,
            setFunc = function(value)
                vars.SoundWhenEqualsSound = value
                PlaySound(BS.SoundLookup[value])
            end,
            disabled = function()
                return not vars.SoundWhenEquals
            end,
            default = nil
        }
    end
end

local function checkSoundWhenOver(defaults, widgetControls, vars)
    if (defaults.SoundWhenOver ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SOUND_VALUE_EXCEEDS),
            getFunc = function()
                return vars.SoundWhenOver
            end,
            setFunc = function(value)
                vars.SoundWhenOver = value
            end,
            width = "full",
            default = defaults.SoundWhenOver
        }

        widgetControls[#widgetControls + 1] = {
            type = "editbox",
            name = GetString(_G.BARSTEWARD_VALUE),
            getFunc = function()
                return vars.SoundWhenOverValue
            end,
            setFunc = function(value)
                vars.SoundWhenOverValue = value
            end,
            width = "full",
            disabled = function()
                return not vars.SoundWhenOver
            end,
            default = nil
        }

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_SOUND),
            choices = soundChoices,
            getFunc = function()
                return vars.SoundWhenOverSound
            end,
            setFunc = function(value)
                vars.SoundWhenOverSound = value
                PlaySound(BS.SoundLookup[value])
            end,
            disabled = function()
                return not vars.SoundWhenOver
            end,
            default = nil
        }
    end
end

local function checkSoundWhenUnder(defaults, widgetControls, vars)
    if (defaults.SoundWhenUnder ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_SOUND_VALUE_BELOW),
            getFunc = function()
                return vars.SoundWhenUnder
            end,
            setFunc = function(value)
                vars.SoundWhenUnder = value
            end,
            width = "full",
            default = defaults.SoundWhenUnder
        }

        widgetControls[#widgetControls + 1] = {
            type = "editbox",
            name = GetString(_G.BARSTEWARD_VALUE),
            getFunc = function()
                return vars.SoundWhenUnderValue
            end,
            setFunc = function(value)
                vars.SoundWhenUnderValue = value
            end,
            width = "full",
            disabled = function()
                return not vars.SoundWhenUnder
            end,
            default = nil
        }

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_SOUND),
            choices = soundChoices,
            getFunc = function()
                return vars.SoundWhenUnderSound
            end,
            setFunc = function(value)
                vars.SoundWhenUnderSound = value
                PlaySound(BS.SoundLookup[value])
            end,
            disabled = function()
                return not vars.SoundWhenUnder
            end,
            default = nil
        }
    end
end

local function checkAnnouncement(defaults, widgetControls, vars, key)
    if (defaults.Announce ~= nil) then
        local nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT)

        if (key == BS.W_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND)
        elseif (key == BS.W_GUILD_FRIENDS) then
            nameValue = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND_GUILD)
        end

        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = nameValue,
            getFunc = function()
                return vars.Announce
            end,
            setFunc = function(value)
                vars.Announce = value
            end,
            width = "full",
            default = defaults.Announce
        }
    end
end

local function checkProgressBar(_, widgetControls, vars, key)
    if (vars.Progress == true) then
        widgetControls[#widgetControls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_VALUE),
            getFunc = function()
                local colour = vars.ProgressColour or BS.Vars.DefaultWarningColour

                return unpack(colour)
            end,
            setFunc = function(r, g, b, a)
                vars.ProgressColour = {r, g, b, a}

                local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[key].name].ref
                widget.value.progress:SetColor(r, g, b, a)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }

        widgetControls[#widgetControls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_START),
            getFunc = function()
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local colour = vars.GradientStart or startg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                vars.GradientStart = {r, g, b}

                local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[key].name].ref
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local er, eg, eb = unpack(vars.GradientEnd or endg)

                widget.value:SetGradientColors(r, g, b, 1, er, eg, eb, 1)
            end,
            width = "full",
            default = function()
                return GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
            end
        }

        widgetControls[#widgetControls + 1] = {
            type = "colorpicker",
            name = GetString(_G.BARSTEWARD_PROGRESS_GRADIENT_END),
            getFunc = function()
                local endg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)
                }
                local colour = vars.GradientEnd or endg
                local r, g, b = unpack(colour)

                return r, g, b
            end,
            setFunc = function(r, g, b)
                vars.GradientEnd = {r, g, b}

                local widget = _G[BS.Name .. "_Widget_" .. BS.widgets[key].name].ref
                local startg = {
                    GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)
                }
                local sr, sg, sb = unpack(vars.GradientStart or startg)

                widget.value:SetGradientColors(sr, sg, sb, 1, r, g, b, 1)
            end,
            width = "full",
            default = function()
                return unpack(BS.Vars.DefaultWarningColour)
            end
        }
    end
end

local function checkCustomDropdown(widgetControls, key)
    local copts = BS.widgets[key].customOptions
    if (copts) then
        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = copts.name,
            tooltip = copts.tooltip,
            choices = copts.choices,
            getFunc = function()
                return BS.Vars.Controls[key][copts.varName] or copts.default
            end,
            setFunc = function(value)
                BS.Vars.Controls[key][copts.varName] = value
                if (copts.refresh) then
                    BS.RefreshWidget(key)
                end
            end,
            width = "full",
            default = copts.default
        }
    end
end

local function checkTime(widgetControls, key)
    local timeSamples12 = {}
    local timeSamples24 = {}

    for _, format in ipairs(twelveFormats) do
        table.insert(timeSamples12, BS.FormatTime(format, "09:23:12"))
    end

    for _, format in ipairs(twentyFourFormats) do
        table.insert(timeSamples24, BS.FormatTime(format, "09:23:12"))
    end

    if (key == BS.W_TIME or (key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        local timeVars = (key == BS.W_TIME) and BS.Vars or BS.Vars.Controls[BS.W_TAMRIEL_TIME]

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TWELVE_TWENTY_FOUR),
            choices = {GetString(_G.BARSTEWARD_12), GetString(_G.BARSTEWARD_24)},
            getFunc = function()
                return timeVars.TimeType or BS.Defaults.TimeType
            end,
            setFunc = function(value)
                timeVars.TimeType = value
            end,
            default = BS.Defaults.TimeType
        }

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_12),
            choices = timeSamples12,
            getFunc = function()
                local format = timeVars.TimeFormat12 or BS.Defaults.TimeFormat12
                return BS.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(twelveFormats) do
                    if (BS.FormatTime(f, "09:23:12") == value) then
                        format = f
                        break
                    end
                end

                timeVars.TimeFormat12 = format
            end,
            disabled = function()
                return (timeVars.TimeType or BS.Defaults.TimeType) ~= GetString(_G.BARSTEWARD_12)
            end,
            default = BS.Defaults.TimeFormat12
        }

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIME_FORMAT_24),
            choices = timeSamples24,
            getFunc = function()
                local format = timeVars.TimeFormat24 or BS.Defaults.TimeFormat24
                return BS.FormatTime(format, "09:23:12")
            end,
            setFunc = function(value)
                local format

                for _, f in ipairs(twentyFourFormats) do
                    if (BS.FormatTime(f, "09:23:12") == value) then
                        format = f
                        break
                    end
                end

                timeVars.TimeFormat24 = format
            end,
            disabled = function()
                return (timeVars.TimeType or BS.Defaults.TimeType) == GetString(_G.BARSTEWARD_12)
            end,
            default = BS.Defaults.TimeFormat24
        }
    end
end

local function checkTimer(defaults, widgetControls, vars, key)
    if (defaults.Timer == true) then
        local timerFormat =
            key == BS.W_LEADS and ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT, 1, 12, 4) or
            ZO_CachedStrFormat(_G.BARSTEWARD_TIMER_FORMAT_TEXT_WITH_SECONDS, 1, 12, 4, 10)

        widgetControls[#widgetControls + 1] = {
            type = "dropdown",
            name = GetString(_G.BARSTEWARD_TIMER_FORMAT),
            choices = {
                timerFormat,
                "01:12:04:10"
            },
            getFunc = function()
                local default = (key == BS.W_LEADS) and "01:12:04" or "01:12:04:10"

                return vars.Format or default
            end,
            setFunc = function(value)
                vars.Format = value
                BS.RefreshWidget(key)
            end,
            default = key == BS.W_LEADS and "01:12:04" or "01:12:04:10"
        }
    end
end

local function checkColourOptions(widgetControls, vars, key)
    local cv = getCV(key)

    if (cv and key ~= BS.W_TAMRIEL_TIME or (key == BS.W_TAMRIEL_TIME and BS.LibClock ~= nil)) then
        if (cv.c and not vars.Progress) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DEFAULT_COLOUR),
                getFunc = function()
                    return unpack(vars.Colour or BS.Vars.DefaultColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.CompareColours({r, g, b, a}, BS.Vars.DefaultColour)) then
                        vars.Colour = nil
                    else
                        vars.Colour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultColour)
            }
        end

        if (cv.okc) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_OK_COLOUR),
                getFunc = function()
                    return unpack(vars.OkColour or BS.Vars.DefaultOkColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.CompareColours({r, g, b, a}, BS.Vars.DefaultOkColour)) then
                        vars.OkColour = nil
                    else
                        vars.OkColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultOkColour)
            }
        end

        if (cv.wc) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_WARNING_COLOUR),
                getFunc = function()
                    return unpack(vars.WarningColour or BS.Vars.DefaultWarningColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.CompareColours({r, g, b, a}, BS.Vars.DefaultWarningColour)) then
                        vars.WarningColour = nil
                    else
                        vars.WarningColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultWarningColour)
            }
        end

        if (cv.dc) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_DANGER_COLOUR),
                getFunc = function()
                    return unpack(vars.DangerColour or BS.Vars.DefaultDangerColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.CompareColours({r, g, b, a}, BS.Vars.DefaultDangerColour)) then
                        vars.DangerColour = nil
                    else
                        vars.DangerColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultDangerColour)
            }
        end

        if (cv.mc) then
            widgetControls[#widgetControls + 1] = {
                type = "colorpicker",
                name = GetString(_G.BARSTEWARD_MAX_COLOUR),
                getFunc = function()
                    return unpack(vars.MaxColour or BS.Vars.DefaultMaxColour)
                end,
                setFunc = function(r, g, b, a)
                    if (BS.CompareColours({r, g, b, a}, BS.Vars.DefaultMaxColour)) then
                        vars.MaxColour = nil
                    else
                        vars.MaxColour = {r, g, b, a}
                    end

                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = unpack(BS.Vars.DefaultMaxColour)
            }
        end

        local units = vars.Units

        if (cv.okv) then
            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_OK_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.OkValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.OkValue = BS.Default.Controls[key].OkValue
                    else
                        vars.OkValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.wv) then
            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_WARNING_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.WarningValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.WarningValue = BS.Default.Controls[key].WarningValue
                    else
                        vars.WarningValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.dv) then
            widgetControls[#widgetControls + 1] = {
                type = "editbox",
                name = GetString(_G.BARSTEWARD_DANGER_VALUE) .. (units and (" (" .. units .. ")") or ""),
                getFunc = function()
                    return vars.DangerValue or ""
                end,
                setFunc = function(value)
                    if (value == nil or value == "") then
                        vars.DangerValue = BS.Default.Controls[key].DangerValue
                    else
                        vars.DangerValue = tonumber(value)
                    end

                    BS.RefreshWidget(key)
                end,
                textType = _G.TEXT_TYPE_NUMERIC,
                isMultiLine = false,
                width = "half",
                default = nil
            }
        end

        if (cv.mv) then
            widgetControls[#widgetControls + 1] = {
                type = "checkbox",
                name = GetString(_G.BARSTEWARD_MAX_VALUE),
                getFunc = function()
                    return vars.MaxValue or false
                end,
                setFunc = function(value)
                    vars.MaxValue = value
                    BS.RefreshWidget(key)
                end,
                width = "full",
                default = false
            }
        end
    end
end

local function checkCustomOptions(widgetControls, key)
    local cset = BS.widgets[key].customSettings
    if (cset) then
        local csettings = cset

        if (type(cset) == "function") then
            csettings = cset()
        end

        for _, setting in ipairs(csettings) do
            widgetControls[#widgetControls + 1] = setting
        end
    end
end

local function checkPrint(defaults, widgetControls, vars)
    if (defaults.Print ~= nil) then
        widgetControls[#widgetControls + 1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_RANDOM_PRINT),
            getFunc = function()
                return vars.Print
            end,
            setFunc = function(value)
                vars.Print = value
            end,
            width = "full",
            default = defaults.Print
        }
    end
end

local function getWidgetSettings()
    local widgets = BS.Vars.Controls
    local bars = BS.Vars.Bars
    local none = GetString(_G.BARSTEWARD_NONE_BAR)
    local barNames = {none}

    for _, v in ipairs(bars) do
        table.insert(barNames, v.Name)
    end

    local ordered = {}

    for key, widget in ipairs(widgets) do
        table.insert(ordered, {key = key, widget = widget})
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
                return BS.widgets[a.key].tooltip < BS.widgets[b.key].tooltip
            end
        )
    end

    if (BS.Vars.WidgetSortOrderUsed) then
        -- sort the widget settings into used/unused
        local used =
            BS.Filter(
            ordered,
            function(v)
                return BS.Vars.Controls[v.key].Bar > 0
            end
        )
        local unused =
            BS.Filter(
            ordered,
            function(v)
                return BS.Vars.Controls[v.key].Bar == 0
            end
        )

        table.sort(
            used,
            function(a, b)
                return BS.widgets[a.key].tooltip < BS.widgets[b.key].tooltip
            end
        )
        table.sort(
            unused,
            function(a, b)
                return BS.widgets[a.key].tooltip < BS.widgets[b.key].tooltip
            end
        )

        ordered = BS.MergeTables(used, unused)
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
            end,
            min = 8,
            max = 64,
            width = "full",
            default = BS.Defaults.IconSize,
            requiresReload = true
        },
        [4] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_HORIZONTAL),
            getFunc = function()
                return BS.Vars.HorizontalPadding or 0
            end,
            setFunc = function(value)
                BS.Vars.HorizontalPadding = value
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            requiresReload = true
        },
        [5] = {
            type = "slider",
            name = GetString(_G.BARSTEWARD_PADDING_VERTICAL),
            getFunc = function()
                return BS.Vars.VerticalPadding or 0
            end,
            setFunc = function(value)
                BS.Vars.VerticalPadding = value
            end,
            min = 0,
            max = 64,
            width = "full",
            default = 0,
            requiresReload = true
        },
        [6] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_CATEGORY_USE),
            getFunc = function()
                return BS.Vars.Categories or false
            end,
            setFunc = function(value)
                BS.Vars.Categories = value
            end,
            width = "full",
            default = false,
            requiresReload = true
        },
        [7] = {
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
            disabled = function()
                return not BS.Vars.Categories
            end,
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
        local i18Name = string.format("BARSTEWARD_CHANGE_DEFAULT%s", colourType:upper():gsub("_", ""))
        local defaultName = string.format("Default%sColour", colourType:gsub("_", ""))

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

    local numBaseControls = #controls
    local categories = {}
    local categoryIndex = {}

    if (BS.Vars.Categories) then
        for k, cat in pairs(BS.CATEGORIES) do
            categories[k] = {
                type = "submenu",
                name = GetString(cat.name),
                icon = string.format("esoui/art/%s.dds", cat.icon),
                controls = {},
                reference = "BarStewardCategory" .. k
            }

            categoryIndex[k] = 1
        end
    end

    for idx, w in ipairs(ordered) do
        local k = w.key
        local v = w.widget
        local widgetControls = {}
        local disabled = false

        if (widgets[k].Requires and not _G[widgets[k].Requires]) then
            widgetControls[#widgetControls + 1] = {
                type = "description",
                text = "|cff0000" .. zo_strformat(GetString(_G.BARSTEWARD_REQUIRES), widgets[k].Requires) .. "|r",
                width = "full"
            }
            disabled = true
        else
            widgetControls[#widgetControls + 1] = {
                type = "dropdown",
                name = GetString(_G.BARSTEWARD_BAR),
                choices = barNames,
                getFunc = function()
                    local barName = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_DAMAGETYPE0))

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

                    BS.Vars.Controls[k].Bar = barNum
                end,
                width = "full",
                requiresReload = true,
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

        local vars = BS.Vars.Controls[k]
        local defaults = BS.Defaults.Controls[k]

        if (not disabled) then
            checkAutoHide(defaults, widgetControls, vars, k)
            checkHideWhenComplete(defaults, widgetControls, vars, k)
            checkHideWhenFullyUsed(defaults, widgetControls, vars, k)
            checkHideWhenMaxLevel(defaults, widgetControls, vars, k)
            checkPvPOnly(defaults, widgetControls, vars, k)
            checkShowPercentage(defaults, widgetControls, vars, k)
            checkUseSeparators(defaults, widgetControls, vars, k)
            checkHideSeconds(defaults, widgetControls, vars, k)
            checkHideDaysWhenZero(defaults, widgetControls, vars, k)
            checkHideLimit(defaults, widgetControls, vars, k)
            checkNoLimitColour(defaults, widgetControls, vars, k)
            checkShowFreeSpace(defaults, widgetControls, vars, k)
            checkSoundWhenEquals(defaults, widgetControls, vars)
            checkSoundWhenOver(defaults, widgetControls, vars)
            checkSoundWhenUnder(defaults, widgetControls, vars)
            checkAnnouncement(defaults, widgetControls, vars, k)
            checkProgressBar(defaults, widgetControls, vars, k)
            checkCustomDropdown(widgetControls, k)
            checkTime(widgetControls, k)
            checkTimer(defaults, widgetControls, vars, k)
            checkColourOptions(widgetControls, vars, k)
            checkCustomOptions(widgetControls, k)
            checkPrint(defaults, widgetControls, vars)
            checkInvert(defaults, widgetControls, vars, k)
        end

        local textureCoords = nil

        if (k == BS.W_ALLIANCE) then
            textureCoords = {0, 1, 0, 0.6}
        end

        local widgetName = BS.widgets[k].tooltip:gsub(":", "")

        if (vars.Bar ~= 0) then
            widgetName = "|c4c9900" .. widgetName .. "|r"
        end

        if (BS.Vars.Categories) then
            categories[vars.Cat].controls[categoryIndex[vars.Cat]] = {
                type = "submenu",
                name = widgetName,
                icon = BS.widgets[k].icon,
                iconTextureCoords = textureCoords,
                controls = widgetControls,
                reference = "BarStewardCategoryWidgets" .. k
            }

            categoryIndex[vars.Cat] = categoryIndex[vars.Cat] + 1
        else
            controls[idx + numBaseControls] = {
                type = "submenu",
                name = widgetName,
                icon = BS.widgets[k].icon,
                iconTextureCoords = textureCoords,
                controls = widgetControls,
                reference = "BarStewardWidgets" .. k
            }
        end
    end

    if (BS.Vars.Categories) then
        local cats = {}

        for _, cat in pairs(categories) do
            if (BS.Vars.CategoriesCount) then
                cat.name =
                    string.format(
                    "%s  %s %d|r",
                    cat.name,
                    BS.ARGBConvert(BS.Defaults.DefaultWarningColour),
                    #cat.controls
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

        for _, v in ipairs(cats) do
            controls[#controls + 1] = v.value
        end
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
    zo_callLater(
        function()
            initialise()
            getPerformanceSettings()
            BS.GetMaintenanceSettings()
            getWidgetSettings()
            BS.GetPortToHouseSettings()
            getBarSettings()
            BS.OptionsPanel = BS.LAM:RegisterAddonPanel("BarStewardOptionsPanel", panel)
            BS.LAM:RegisterOptionControls("BarStewardOptionsPanel", BS.options)
        end,
        500
    )
end
