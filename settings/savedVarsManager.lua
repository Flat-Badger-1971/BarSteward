local BS = _G.BarSteward
local manager = ZO_Object:Subclass()
local addToTable, removeFromTable, searchPath, setPath, simpleCopy

-- set default getter/setter for vars
local metatable = {
    __index = function(t, key)
        -- if the key exists in the main class - return that
        local parentClass = rawget(t, "__parentClasses")[1]

        if (parentClass[key]) then
            return parentClass[key]
        end

        -- assume anything that's not part of the main class is an attempt to read a saved variable
        local vars = rawget(t, "Vars")

        if (vars) then
            return vars[key]
        end
    end,
    __newindex = function(t, key, value)
        rawset(t.Vars, key, value)
    end
}

function manager:New()
    local managerObject = self:Subclass()
    local rawTableName, isAccountWide, characterId, displayName = managerObject:Initialise()

    return setmetatable(managerObject, metatable), rawTableName, isAccountWide, characterId, displayName
end

function manager:Initialise()
    self.Defaults = BS.SavedVarDefaults
    self.RawTableName = BS.Name .. "SavedVars"
    self.Profile = GetWorldName()
    self.DisplayName = GetDisplayName()
    self.CharacterId = GetCurrentCharacterId()
    self.CommonDefaults = BS.CommonDefaults
    self.Version = 1
    self.UseCharacterSettings = self:HasCharacterSettings()

    if (self.UseCharacterSettings) then
        self.Vars =
            ZO_SavedVars:NewCharacterIdSettings(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)
    else
        self.Vars = ZO_SavedVars:NewAccountWide(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)
    end

    local rawTable = self:GetRawTable()
    local serverInformation = {}

    for server, serverData in pairs(rawTable) do
        serverInformation[server] = {}
        for account, accountData in pairs(serverData) do
            serverInformation[server][account] = {}
            for character, settings in pairs(accountData) do
                serverInformation[server][account][character] = settings["$LastCharacterName"] or "Account"
            end
        end
    end

    self.ServerInformation = serverInformation

    return self.RawTableName, self.Vars.IsAccountWide, self.CharacterId, self.DisplayName
end

function manager:HasCharacterSettings()
    local characterSettings = self:GetCommon("CharacterSettings")

    if (characterSettings and type(characterSettings) == "table") then
        if (ZO_IsElementInNumericallyIndexedTable(characterSettings, self.CharacterId)) then
            return true
        end
    end

    return false
end

function manager:GetCommon(...)
    local rawTable = self:GetRawTable()

    return searchPath(rawTable, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

function manager:SetCommon(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

function manager:GetServerInformation()
    return self.ServerInformation
end

function manager:GetServers()
    local servers = {}

    for server, _ in pairs(self.ServerInformation) do
        table.insert(servers, server)
    end

    return servers
end

function manager:GetAccounts(server)
    local accounts = {}

    for account, _ in pairs(self.ServerInformation[server]) do
        table.insert(accounts, account)
    end

    return accounts
end

function manager:GetCharacters(server, account)
    local characters = {}

    for _, character in pairs(self.ServerInformation[server][account]) do
        table.insert(characters, character)
    end

    return characters
end

function manager:GetCharacterId(server, account, character)
    local characters = self.ServerInformation[server][account]

    if (character == "Account") then
        return "$AccountWide"
    end

    for id, characterName in pairs(characters) do
        if (characterName == character) then
            return id
        end
    end
end

function manager:IsAccountWide()
    return not self.UseCharacterSettings
end

function manager:Copy(server, account, character)
    local characterId = "$AccountWide"

    if (character ~= "Account") then
        characterId = self:GetCharacterId(server, account, character)
    end

    local characterSettings = simpleCopy(self.ServerInformation[server][account][characterId])

    local common = self:GetCommon()

    for key, value in ipairs(characterSettings) do
        if (not common[key]) then
            self.Vars[key] = value
        end
    end
end

function manager:ConvertToCharacterSettings()
    if (not self.HasCharacterSettings) then
        local settings = simpleCopy(self.Vars)

        self.Vars.UseAccountWide = false
        self.Vars =
            ZO_SavedVars:NewCharacterIdSettings(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        local characterSettings = self:GetCommon("CharacterSettings")

        characterSettings = addToTable(characterSettings, self.CharacterId)
        self:SetCommon("CharacterSettings", characterSettings)
    end
end

function manager:ConvertToAccountSettings()
    if (self.HasCharacterSettings) then
        local settings = simpleCopy(self.Vars)

        self.Vars = ZO_SavedVars:NewAccountWide(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        local characterSettings = self:GetCommon("CharacterSettings")

        characterSettings = removeFromTable(characterSettings, self.CharacterId)
        self:SetCommon("CharacterSettings", characterSettings)
    end
end

function manager:GetRawTable()
    local rawTable = _G[self.RawTableName]

    return rawTable
end

function simpleCopy (t)
    local output = {}

    for name, settings in pairs(t) do
        if (type(settings) == "table") then
            for k, v in pairs(settings) do
                output[name] = output[name] or {}
                output[name][k] = v
            end
        else
            output[name] = settings
        end
    end

    return output
end

function removeFromTable(t, v)
    local newTable = {}

    for _, value in ipairs(t) do
        if (value ~= v) then
            table.insert(newTable, value)
        end
    end

    return newTable
end

function addToTable(t, v)
    if (not ZO_IsElementInNumericallyIndexedTable(t, v)) then
        table.insert(t, v)
    end

    return t
end

local commonSettings = {
    "CharacterList",
    "dailyQuests",
    "dailyQuestCount",
    "FriendAnnounce",
    "Gold",
    "GuildFriendAnnounce",
    "HouseBindings",
    "HouseWidgets",
    "OtherCurrencies",
    "PreviousAnnounceTime",
    "PreviousFriendTime",
    "PreviousGuildFriendTime",
    "Trackers",
    "WatchedItems",
    "Updates"
}

local function checkCommon(vars, common)
    for name, settings in pairs(vars) do
        if (ZO_IsElementInNumericallyIndexedTable(commonSettings, name)) then
            if (type(settings) == "table") then
                for k, v in pairs(settings) do
                    common[name] = common[name] or {}
                    common[name][k] = v
                end
            else
                common[name] = settings
            end

            vars[name] = nil
        end
    end

    return common
end

local function countElements(t)
    local count = 0

    for _, _ in pairs(t) do
        count = count + 1
    end

    return count
end

-- functions from zo_savedvars.lua
function searchPath(t, ...)
    local current = t

    for i = 1, select("#", ...) do
        local key = select(i, ...)

        if (key ~= nil) then
            if (current == nil) then
                return
            end

            current = current[key]
        end
    end

    return current
end

local function createPath(t, ...)
    local current = t
    local container
    local containerKey

    for i = 1, select("#", ...) do
        local key = select(i, ...)

        if (key ~= nil) then
            if (not current[key]) then
                current[key] = {}
            end

            container = current
            containerKey = key
            current = current[key]
        end
    end

    return current, container, containerKey
end

function setPath(t, value, ...)
    if value ~= nil then
        createPath(t, ...)
    end

    local current = t
    local parent
    local lastKey

    for i = 1, select("#", ...) do
        local key = select(i, ...)

        if (key ~= nil) then
            lastKey = key
            parent = current

            if (current == nil) then
                return
            end

            current = current[key]
        end
    end

    if (parent ~= nil) then
        parent[lastKey] = value
    end
end

-- loop through the default values - if the saved value matches the default value
-- then remove it. It's just wasting space as the default values will be loaded anyway
local function trim(savedVarsTable, defaults)
    local valid = savedVarsTable ~= nil

    valid = valid and type(savedVarsTable) == "table"
    valid = valid and defaults

    if (not valid) then
        return
    end

    for key, defaultValue in pairs(defaults) do
        if (type(defaultValue) == "table") then
            if (type(savedVarsTable[key])) == "table" then
                trim(savedVarsTable[key], defaultValue)

                if (savedVarsTable[key] and (next(savedVarsTable[key]) == nil)) then
                    savedVarsTable[key] = nil
                end
            end
        elseif (savedVarsTable[key] == defaultValue) then
            savedVarsTable[key] = nil
        end
    end
end

local function fillDefaults(t, defaults)
    if ((t == nil) or (type(t) ~= "table") or (defaults == nil)) then
        return
    end

    for key, defaultValue in pairs(defaults) do
        if (type(defaultValue)) == "table" then
            if (t[key] == nil) then
                t[key] = {}
            end

            fillDefaults(t[key], defaultValue)
        elseif (t[key] == nil) then
            t[key] = defaultValue
        end
    end
end

local function removeDefaults()
    local character = BS.VarData.AccountWide and "$AccountWide" or BS.VarData.CharacterId
    local rawTable = _G[BS.VarData.RawTableName]
    local rawSavedVarsTable = searchPath(rawTable, BS.VarData.Profile, BS.VarData.DisplayName, character)

    trim(rawSavedVarsTable, BS.SavedVarDefaults)
end

local function onLogout()
    removeDefaults()

    local rawTable = _G[BS.VarData.RawTableName]
    local nextKey

    repeat
        nextKey = next(rawTable, nextKey)
    until nextKey ~= "version" and nextKey ~= "$LastCharacterName"

    if (nextKey == nil) then
        rawTable.version = nil
        rawTable["$LastCharacterName"] = nil
    end
end

local function onLogoutCancelled()
    local rawTable = _G[BS.VarData.RawTableName]

    fillDefaults(rawTable, BS.SavedVarDefaults)
end

function BS.HasLibSavedVars()
    local rawTable = _G[BS.Name .. "SavedVars"]

    return searchPath(rawTable, GetWorldName(), GetDisplayName(), "$AccountWide", "COMMON") ~= nil
end

function BS.ConvertFromLibSavedVars()
    local vars = _G[BS.Name .. "SavedVars"]

    for server, serverVars in pairs(vars) do
        for account, accountVars in pairs(serverVars) do
            if (not vars[server][account]["$AccountWide"].COMMON) then
                local characterOnly = {}
                local common = {}

                for character, info in pairs(accountVars) do
                    if (character == "$AccountWide" and info.Account) then
                        common = checkCommon(info.Account, common)
                        vars[server][account][character] = info.Account
                    elseif (info.Characters and countElements(info.Characters) > 2) then
                        local characterInfo = info.Characters

                        characterOnly[character] = true
                        common = checkCommon(characterInfo, common)
                        characterInfo["$LastCharacterName"] = info["$LastCharacterName"]
                        characterInfo.LibSavedVars = nil
                        vars[server][account][character] = characterInfo
                    elseif (info.Characters) then
                        vars[server][account][character] = nil
                    end
                end

                vars[server][account]["$AccountWide"].COMMON = common
                vars[server][account]["$AccountWide"].COMMON.CharacterSettings = characterOnly
            end
        end
    end
end

function BS.CreateSavedVariablesManager()
    ZO_PreHook("Logout", onLogout)
    ZO_PreHook("Quit", onLogout)
    ZO_PreHook("CancelLogout", onLogoutCancelled)

    return manager:New()
end