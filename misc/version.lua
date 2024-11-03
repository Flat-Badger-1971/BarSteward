local BS = _G.BarSteward

local function needsUpdate(version)
    if (not BS.Vars:GetCommon("Updates", version)) then
        return true
    end

    return false
end

-- local function replace(current)
--     local ucase = current:upper()

--     if (_G["BARSTEWARD_" .. ucase]) then
--         return GetString(_G["BARSTEWARD_" .. ucase])
--     end

--     return current
-- end

-- local function updateLanguageVars()
--     -- if a new language file has been added, some exisiting English saved vars need to be updated
--     local bars = BS.Vars.Bars

--     -- update bar settings
--     for index, _ in pairs(bars) do
--         BS.Vars.Bars[index].TooltipAnchor = replace(BS.Vars.Bars[index].TooltipAnchor)
--         BS.Vars.Bars[index].ValueSide = replace(BS.Vars.Bars[index].ValueSide)
--         BS.Vars.Bars[index].Orientation = replace(BS.Vars.Bars[index].Orientation)
--         BS.Vars.Bars[index].Anchor = replace(BS.Vars.Bars[index].Anchor)
--     end

--     -- update main bar name
--     BS.Vars.Bars[1].Name = GetString(_G.BARSTEWARD_MAIN_BAR)

--     --update widget unit settings
--     local widgets = BS.Vars.Controls

--     for _, widget in pairs(widgets) do
--         if (widget.Units) then
--             local newUnit = GetString(_G["BARSTEWARD_" .. widget.Units:upper()])

--             if (newUnit ~= "") then
--                 widget.Units = newUnit
--             end
--         end
--     end
-- end

function BS.VersionCheck()
    if (needsUpdate(3000)) then
        -- add back missing watched items
        local watchedItems = BS.Vars:GetCommon("WatchedItems") or {}

        if (watchedItems[BS.PERFECT_ROE] == nil) then
            BS.Vars:SetCommon(true, "WatchedItems", BS.PERFECT_ROE)
        end

        if (watchedItems[BS.POTENT_NIRNCRUX] == nil) then
            BS.Vars:SetCommon(true, "WatchedItems", BS.POTENT_NIRNCRUX)
        end

        BS.Vars:SetCommon(true, "Updates", 3000)
    end

    if (needsUpdate(3109)) then
        BS.Vars.Controls[BS.W_ALLIANCE_POINTS].Cat = BS.CATNAMES.PvP
        BS.Vars.Controls[BS.W_RANDOM_BATTLEGROUND].Cat = BS.CATNAMES.PvP
    end

    if (needsUpdate(3204)) then
        local servers = BS.Vars:GetServers()

        for _, server in ipairs(servers) do
            local accounts = BS.Vars:GetAccounts(server)

            for _, account in ipairs(accounts) do
                local chars = BS.Vars:GetCharacters(server, account, false)

                for _, char in ipairs(chars) do
                    local cid = BS.Vars:GetCharacterId(server, account, char)
                    local vars = BS.Vars:SearchPath(true, server, account, cid, "Controls")

                    if (vars) then
                        if (vars[145]) then
                            vars[145] = nil
                        end
                    end
                end
            end
        end

        BS.Vars:SetCommon(true, "Updates", 3204)
    end

    if (needsUpdate(3208)) then
        local servers = BS.Vars:GetServers()

        for _, server in ipairs(servers) do
            local accounts = BS.Vars:GetAccounts(server)

            for _, account in ipairs(accounts) do
                local chars = BS.Vars:GetCharacters(server, account, false)

                for _, char in ipairs(chars) do
                    local cid = BS.Vars:GetCharacterId(server, account, char)
                    local vars = BS.Vars:SearchPath(true, server, account, cid, "Controls")

                    if (vars) then
                        vars[BS.W_CHAMPION_POINTS].Cat=BS.CATNAMES.Abilities
                        vars[BS.W_MUNDUS_STONE].Cat=BS.CATNAMES.Abilities
                        vars[BS.W_SKILL_POINTS].Cat=BS.CATNAMES.Abilities
                        vars[BS.W_VAMPIRISM].Cat=BS.CATNAMES.Abilities
                        vars[BS.W_VAMPIRISM_TIMER].Cat=BS.CATNAMES.Abilities
                        vars[BS.W_VAMPIRISM_FEED_TIMER].Cat=BS.CATNAMES.Abilities
                        vars.Categories = nil
                    end
                end
            end
        end

        BS.Vars:SetCommon(true, "Updates", 3208)
    end
end

function BS.SetVersionCheck()
    local versions = {2000, 2006, 2010, 2111, 3000}

    for _, version in ipairs(versions) do
        BS.Vars:SetCommon(true, "Updates", version)
    end
end
