local BS = BarSteward

function BS.RegisterDialogues()
    local buttons = {
        {
            text = BS.LC.Format(SI_OK),
            callback = function()
            end
        }
    }

    local dialogues = {
        NotEmpty = {
            title = { text = GetString(BARSTEWARD_NEWBAR_INVALID) },
            mainText = { text = GetString(BARSTEWARD_NEWBAR_BLANK) },
            buttons = buttons
        },
        NotEmptyGeneric = {
            title = { text = GetString(BARSTEWARD_GENERIC_INVALID) },
            mainText = { text = GetString(BARSTEWARD_GENERIC_BLANK) },
            buttons = buttons
        },
        Exists = {
            title = { text = GetString(BARSTEWARD_NEWBAR_INVALID) },
            mainText = { text = GetString(BARSTEWARD_NEWBAR_EXISTS) },
            buttons = buttons
        },
        ExistsGeneric = {
            title = { text = GetString(BARSTEWARD_GENERIC_INVALID) },
            mainText = { text = GetString(BARSTEWARD_GENERIC_EXISTS) },
            buttons = buttons
        },
        Reload = {
            title = { text = "Bar Steward" },
            mainText = { text = GetString(BARSTEWARD_RELOAD_MSG) },
            buttons = {
                {
                    text = BS.LC.Format(SI_OK),
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
            title = { text = "Bar Steward" },
            mainText = {
                text = string.format("%s %s?", GetString(BARSTEWARD_SETTINGS), BS.LC.Format(SI_ADDON_MANAGER_RELOAD))
            },
            buttons = {
                {
                    text = BS.LC.Format(SI_DIALOG_NO),
                    callback = function()
                        BS.BarIndex = nil
                    end
                },
                {
                    text = BS.LC.Format(SI_DIALOG_YES),
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
            title = { text = GetString(BARSTEWARD_REMOVE_BAR) },
            mainText = { text = GetString(BARSTEWARD_REMOVE_WARNING) },
            buttons = {
                {
                    text = BS.LC.Format(SI_CANCEL),
                    callback = function()
                        BS.BarIndex = nil
                    end
                },
                {
                    text = BS.LC.Format(SI_OK),
                    callback = function()
                        BS.RemoveBar()
                    end
                }
            }
        },
        RemoveGeneric = {
            title = { text = GetString(BARSTEWARD_GENERIC_REMOVE) },
            mainText = { text = GetString(BARSTEWARD_GENERIC_REMOVE_WARNING) },
            buttons = {
                {
                    text = BS.LC.Format(SI_CANCEL),
                    callback = function(dialog)
                        if (dialog.data and dialog.data.func) then
                            dialog.data.func()
                        end
                    end
                },
                {
                    text = BS.LC.Format(SI_OK),
                    callback = function(dialog)
                        if (dialog.data and dialog.data.func) then
                            dialog.data.func()
                        end
                    end
                }
            }
        },
        ItemExists = {
            title = { text = GetString(BARSTEWARD_ITEM_INVALID) },
            mainText = { text = GetString(BARSTEWARD_ITEM_EXISTS) },
            buttons = buttons
        },
        Delete = {
            title = { text = BS.LC.Format(SI_KEYCODE19) },
            mainText = {
                text = function()
                    local characters = BS.LC.Join(BS.forDeletion)

                    return zo_strformat(GetString(BARSTEWARD_DELETE_FOR), characters)
                end
            },
            buttons = {
                {
                    text = BS.LC.Format(SI_DIALOG_YES),
                    callback = function()
                        BS.DeleteTrackedData()
                    end
                },
                {
                    text = BS.LC.Format(SI_DIALOG_NO)
                }
            }
        },
        Import = {
            title = { text = GetString(BARSTEWARD_IMPORT_BAR) },
            mainText = {
                text = function()
                    return zo_strformat(GetString(BARSTEWARD_MOVE_WIDGETS), BS.MovingWidgets)
                end
            },
            buttons = {
                {
                    text = BS.LC.Format(SI_DIALOG_YES),
                    callback = function()
                        BS.DoImport()
                    end
                },
                {
                    text = BS.LC.Format(SI_DIALOG_NO)
                }
            }
        },
        Confirm = {
            title = { text = GetString(BARSTEWARD_MAIN_BAR_REPLACE) },
            mainText = {
                text = GetString(BARSTEWARD_MAIN_BAR_REPLACE_CONFIRM)
            },
            buttons = {
                {
                    text = BS.LC.Format(SI_DIALOG_YES),
                    callback = function()
                        BS.ReplaceMain = true
                        BS.DoImport()
                    end
                },
                {
                    text = BS.LC.Format(SI_DIALOG_NO),
                    callback = function()
                        BS.ReplaceMain = false
                    end
                }
            }
        }
    }

    for name, config in pairs(dialogues) do
        ZO_Dialogs_RegisterCustomDialog(string.format("%s%s", BS.Name, name), config)
    end
end
