local BS = _G.BarSteward

function BS.RegisterSlashCommands()
    -- reload ui
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    -- reload ui and clear debug logger window
    if (_G.SLASH_COMMANDS["/rld"] == nil) then
        _G.SLASH_COMMANDS["/rld"] = function()
            if (_G.LibDebugLogger) then
                _G.LibDebugLogger:ClearLog()
            end
            ReloadUI()
        end
    end

    -- bs commands
    -- open options panel
    _G.SLASH_COMMANDS["/bs"] = function(parameters)
        local options = {}
        local find = {zo_strmatch(parameters, "^(%S*)%s*(.-)$")}

        for _, value in pairs(find) do
            if ((value or "") ~= "") then
                table.insert(options, string.lower(value))
            end
        end

        if (#options == 0) then
            -- open Bar Steward's settings
            BS.LAM:OpenToPanel(BS.OptionsPanel)
        else
            local cmd = zo_strlower(options[1])
            local param = options[2]

            if (param) then
                param = zo_strlower(param)
            end

            -- hide the bar
            if (cmd == GetString(_G.BARSTEWARD_SLASH_HIDE)) then
                local bar = BS.FindBar(param)

                if (bar) then
                    bar:Hide()
                end
            elseif (cmd == GetString(_G.BARSTEWARD_SLASH_SHOW)) then
                -- unhide the bar
                local bar = BS.FindBar(param)

                if (bar) then
                    bar:Show()
                end
            elseif (cmd == zo_strlower(GetString(_G.BARSTEWARD_DISABLE))) then
                -- disable the bar
                local _, id = BS.FindBar(param)

                if (id) then
                    if (BS.Vars.Bars[id].Disable ~= true) then
                        BS.Vars.Bars[id].Disable = true
                        BS.DestroyBar(id)
                    end
                end
            elseif (cmd == GetString(_G.BARSTEWARD_SLASH_ENABLE)) then
                -- enable the bar
                local _, id = BS.FindBar(param)

                if (id) then
                    if (BS.Vars.Bars[id].Disable == true) then
                        BS.Vars.Bars[id].Disable = false
                        BS.GenerateBar(id)
                    end
                end
            elseif (cmd == zo_strlower(BS.LC.Format(SI_HOUSINGEDITORCOMMANDTYPE1))) then
                BS.ShowFrameMovers(true)
            elseif (cmd == "lang") then
                -- change the UI language (intended for dev only)
                SetCVar("language.2", param)
            end
        end
    end

    if (_G.SLASH_COMMANDS["/bslang"] == nil) then
        _G.SLASH_COMMANDS["/bslang"] = function(lang)
            SetCVar("language.2", lang)
        end
    end
end
