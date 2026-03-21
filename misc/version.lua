local BS = BarSteward

local function needsUpdate(version)
    if (not BS.Vars:GetCommon("Updates", version)) then
        return true
    end

    return false
end

local function encodeHouseKey(houseId, ptfId)
    if (ptfId) then
        return tostring(houseId) .. "_" .. tostring(ptfId)
    end

    return houseId
end

local function decodeHouseKey(houseKey)
    if (type(houseKey) == "string") then
        local houseId, ptfId = houseKey:match("^(%d+)_(%d+)$")

        if (houseId and ptfId) then
            return tonumber(houseId), tonumber(ptfId)
        end
    end

    return houseKey, nil
end

local function getLegacyPTFId(houseId)
    if (not PortToFriend) then
        return nil
    end

    local favorites = PortToFriend.GetFavorites()

    for ptfId, ptfInfo in ipairs(favorites) do
        if (ptfInfo.houseId == houseId) then
            return ptfId
        end
    end
end

local function findHousingControlId(houseId, ptfId)
    if (not ptfId) then
        for controlId, settings in pairs(BS.Vars.Controls) do
            if (controlId > 1000 and settings.Id == houseId and settings.PTF and not settings.PTFId) then
                return controlId
            end
        end
    end

    if (not ptfId) then
        local legacyId = 1000 + houseId

        if (BS.Vars.Controls[legacyId]) then
            return legacyId
        end
    end

    for controlId, settings in pairs(BS.Vars.Controls) do
        if (controlId > 1000 and settings.Id == houseId) then
            if (ptfId) then
                if (settings.PTF and settings.PTFId == ptfId) then
                    return controlId
                end
            elseif (not settings.PTF) then
                return controlId
            end
        end
    end
end

local function migrateHousingWidgets()
    local houseWidgets = BS.Vars:GetCommon("HouseWidgets") or {}
    local houseBindings = BS.Vars:GetCommon("HouseBindings") or {}
    local migratedWidgets = {}
    local migratedBindings = {}

    for houseKey, bindingIndex in pairs(houseBindings) do
        migratedBindings[houseKey] = bindingIndex
    end

    for houseKey, storedValue in pairs(houseWidgets) do
        local houseId, ptfId = decodeHouseKey(houseKey)
        local controlId = type(storedValue) == "number" and storedValue or nil

        if (controlId and not BS.Vars.Controls[controlId]) then
            controlId = nil
        end

        if (not controlId) then
            controlId = findHousingControlId(houseId, ptfId)
        end

        if (controlId) then
            local settings = BS.Vars.Controls[controlId]

            if ((not ptfId) and settings.PTF and not settings.PTFId) then
                ptfId = getLegacyPTFId(houseId)
            end

            settings.Id = houseId
            settings.PTF = ptfId ~= nil
            settings.PTFId = ptfId

            local migratedKey = encodeHouseKey(houseId, ptfId)

            migratedWidgets[migratedKey] = controlId

            if (houseBindings[houseKey] ~= nil) then
                migratedBindings[migratedKey] = houseBindings[houseKey]
                migratedBindings[houseKey] = nil
            end
        end
    end

    for controlId, settings in pairs(BS.Vars.Controls) do
        if (controlId > 1000 and settings.Id) then
            if (settings.PTF and not settings.PTFId) then
                settings.PTFId = getLegacyPTFId(settings.Id)
            end

            local migratedKey = encodeHouseKey(settings.Id, settings.PTF and settings.PTFId)

            migratedWidgets[migratedKey] = controlId
        end
    end

    BS.Vars:SetCommon(migratedWidgets, "HouseWidgets")
    BS.Vars:SetCommon(migratedBindings, "HouseBindings")
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
--     BS.Vars.Bars[1].Name = GetString(BARSTEWARD_MAIN_BAR)

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
                        if (vars[BS.CHAMPION_POINTS]) then
                            vars[BS.CHAMPION_POINTS].Cat = BS.CATNAMES.Abilities
                        end
                        if (vars[BS.W_MUNDUS_STONE]) then
                            vars[BS.W_MUNDUS_STONE].Cat = BS.CATNAMES.Abilities
                        end
                        if (vars[BS.W_SKILL_POINTS]) then
                            vars[BS.W_SKILL_POINTS].Cat = BS.CATNAMES.Abilities
                        end
                        if (vars[BS.W_VAMPIRISM]) then
                            vars[BS.W_VAMPIRISM].Cat = BS.CATNAMES.Abilities
                        end
                        if (vars[BS.W_VAMPIRISM_TIMER]) then
                            vars[BS.W_VAMPIRISM_TIMER].Cat = BS.CATNAMES.Abilities
                        end
                        if (vars[BS.W_VAMPIRISM_FEED_TIMER]) then
                            vars[BS.W_VAMPIRISM_FEED_TIMER].Cat = BS.CATNAMES.Abilities
                        end

                        vars.Categories = nil
                    end
                end
            end
        end

        BS.Vars:SetCommon(true, "Updates", 3208)
    end

    if (needsUpdate(3400)) then
        BS.Vars.Controls[BS.W_ALL_CRAFTING].Experimental = false
        BS.Vars:SetCommon(true, "Updates", 3400)
    end

    if (needsUpdate(3500)) then
        local deadWidgets = { 26, 27, 45, 52, 53, 93 }

        for _, widget in ipairs(deadWidgets) do
            BS.Vars.Controls[widget] = nil
        end

        BS.Vars:SetCommon(true, "Updates", 3500)
    end

    local charId = GetCurrentCharacterId()
    if (needsUpdate("3502_" .. charId)) then
        migrateHousingWidgets()
        BS.Vars:SetCommon(true, "Updates", "3502_" .. charId)
    end
end

function BS.SetVersionCheck()
    local versions = { 2000, 2006, 2010, 2111, 3000 }

    for _, version in ipairs(versions) do
        BS.Vars:SetCommon(true, "Updates", version)
    end
end
