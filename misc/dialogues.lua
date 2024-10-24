local BS = _G.BarSteward

function BS.RegisterDialogues()
    local buttons = {
        {
            text = BS.LC.Format(_G.SI_OK),
            callback = function()
            end
        }
    }

    local dialogues = {
        NotEmpty = {
            title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
            mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_BLANK)},
            buttons = buttons
        },
        NotEmptyGeneric = {
            title = {text = GetString(_G.BARSTEWARD_GENERIC_INVALID)},
            mainText = {text = GetString(_G.BARSTEWARD_GENERIC_BLANK)},
            buttons = buttons
        },
        Exists = {
            title = {text = GetString(_G.BARSTEWARD_NEWBAR_INVALID)},
            mainText = {text = GetString(_G.BARSTEWARD_NEWBAR_EXISTS)},
            buttons = buttons
        },
        ExistsGeneric = {
            title = {text = GetString(_G.BARSTEWARD_GENERIC_INVALID)},
            mainText = {text = GetString(_G.BARSTEWARD_GENERIC_EXISTS)},
            buttons = buttons
        },
        Reload = {
            title = {text = "Bar Steward"},
            mainText = {text = GetString(_G.BARSTEWARD_RELOAD_MSG)},
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_OK),
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
        },
        ReloadQuestion = {
            title = {text = "Bar Steward"},
            mainText = {
                text = string.format("%s %s?", GetString(_G.BARSTEWARD_SETTINGS), BS.LC.Format(_G.SI_ADDON_MANAGER_RELOAD))
            },
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_NO),
                    callback = function()
                        BS.BarIndex = nil
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_DIALOG_YES),
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
        },
        Remove = {
            title = {text = GetString(_G.BARSTEWARD_REMOVE_BAR)},
            mainText = {text = GetString(_G.BARSTEWARD_REMOVE_WARNING)},
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_CANCEL),
                    callback = function()
                        BS.BarIndex = nil
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_OK),
                    callback = function()
                        BS.RemoveBar()
                    end
                }
            }
        },
        RemoveGeneric = {
            title = {text = GetString(_G.BARSTEWARD_GENERIC_REMOVE)},
            mainText = {text = GetString(_G.BARSTEWARD_GENERIC_REMOVE_WARNING)},
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_CANCEL),
                    callback = function(dialog)
                        if (dialog.data and dialog.data.func) then
                            dialog.data.func()
                        end
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_OK),
                    callback = function(dialog)
                        if (dialog.data and dialog.data.func) then
                            dialog.data.func()
                        end
                    end
                }
            }
        },
        Resize = {
            title = {text = "Bar Steward"},
            mainText = {text = GetString(_G.BARSTEWARD_RESIZE_MESSAGE)},
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_YES),
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
                    text = BS.LC.Format(_G.SI_DIALOG_NO)
                }
            }
        },
        ItemExists = {
            title = {text = GetString(_G.BARSTEWARD_ITEM_INVALID)},
            mainText = {text = GetString(_G.BARSTEWARD_ITEM_EXISTS)},
            buttons = buttons
        },
        Delete = {
            title = {text = BS.LC.Format(_G.SI_KEYCODE19)},
            mainText = {
                text = function()
                    local characters = BS.LC.Join(BS.forDeletion)

                    return zo_strformat(GetString(_G.BARSTEWARD_DELETE_FOR), characters)
                end
            },
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_YES),
                    callback = function()
                        BS.DeleteTrackedData()
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_DIALOG_NO)
                }
            }
        },
        Import = {
            title = {text = GetString(_G.BARSTEWARD_IMPORT_BAR)},
            mainText = {
                text = function()
                    return zo_strformat(GetString(_G.BARSTEWARD_MOVE_WIDGETS), BS.MovingWidgets)
                end
            },
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_YES),
                    callback = function()
                        BS.DoImport()
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_DIALOG_NO)
                }
            }
        },
        Confirm = {
            title = {text = GetString(_G.BARSTEWARD_MAIN_BAR_REPLACE)},
            mainText = {
                text = GetString(_G.BARSTEWARD_MAIN_BAR_REPLACE_CONFIRM)
            },
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_YES),
                    callback = function()
                        BS.ReplaceMain = true
                        BS.DoImport()
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_DIALOG_NO),
                    callback = function()
                        BS.ReplaceMain = false
                    end
                }
            }
        },
        -- based on pChat by Puddy, Ayantir, Baertram, DesertDwellers
        Backup = {
            title = {text = "|cff9900Bar |r|c4f34ebSteward|r"},
            mainText = {
                text = GetString(_G.BARSTEWARD_BACKUP_DIALOG_TEXT)
            },
            buttons = {
                {
                    text = BS.LC.Format(_G.SI_DIALOG_CONFIRM),
                    callback = function()
                        BS.ConvertFromLibSavedVars()
                        BS.ContinueIntialising()
                    end
                },
                {
                    text = BS.LC.Format(_G.SI_CANCEL),
                    callback = function()
                        ZO_Alert(
                            _G.UI_ALERT_CATEGORY,
                            _G.SOUNDS.AVA_GATE_OPENED,
                            GetString(_G.BARSTEWARD_BACKUP_WARNING)
                        )
                        RequestOpenUnsafeURL("https://www.esoui.com/forums/showthread.php?t=9235")
                    end
                }
            }
        }
    }

    for name, config in pairs(dialogues) do
        ZO_Dialogs_RegisterCustomDialog(string.format("%s%s", BS.Name, name), config)
    end
end
