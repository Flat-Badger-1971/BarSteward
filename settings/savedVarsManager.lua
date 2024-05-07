local manager = ZO_Object:Subclass()
local searchPath, setPath, simpleCopy

-- set default getter/setter for vars
-- pretty sure I'm doing this wrong, but it works, so, meh...
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
        -- can't use rawset - doesn't like empty tables for some reason
        local vars = rawget(t, "Vars")

        vars[key] = value
    end
}

function manager:New(varFileName, defaults, CommonDefaults)
    local managerObject = self:Subclass()
    local rawTableName, isAccountWide, characterId, displayName =
        managerObject:Initialise(varFileName, defaults, CommonDefaults)

    return setmetatable(managerObject, metatable), rawTableName, isAccountWide, characterId, displayName
end

function manager:Initialise(varFileName, defaults, commonDefaults)
    self.Defaults = defaults
    self.RawTableName = varFileName
    self.Profile = GetWorldName()
    self.DisplayName = GetDisplayName()
    self.CharacterId = GetCurrentCharacterId()
    self.CommonDefaults = commonDefaults
    self.Version = 1
    self.UseCharacterSettings = self:HasCharacterSettings()

    self:LoadSavedVars()

    return self.RawTableName, self.Vars.IsAccountWide, self.CharacterId, self.DisplayName
end

-- Load/Reload the saved vars
function manager:LoadSavedVars()
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
end
-- Does the current character have character specific settings?
function manager:HasCharacterSettings()
    return self:GetCommon("CharacterSettings", self.CharacterId)
end

-- Get settings from the 'COMMON' section, works regardless of whether we are using Account-wide or Character settings
function manager:GetCommon(...)
    local rawTable = self:GetRawTable()

    return searchPath(rawTable, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

-- Set settings from the 'COMMON' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetCommon(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

-- Get settings from the 'Account-wide' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetAccount(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, "$AccountWide", ...)
end

-- Get settings from the 'Character' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetCharacter(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, self.CharacterId, ...)
end

-- return a table of server/account/character information found in the saved vars file
function manager:GetServerInformation()
    return self.ServerInformation
end

-- return a sorted list of servers found in the saved vars file
function manager:GetServers()
    local servers = {}

    for server, _ in pairs(self.ServerInformation) do
        table.insert(servers, server)
    end

    table.sort(servers)

    return servers
end

-- return a sorted list of accounts found in the saved vars file for the given server
function manager:GetAccounts(server)
    local accounts = {}

    for account, _ in pairs(self.ServerInformation[server]) do
        table.insert(accounts, account)
    end

    table.sort(accounts)

    return accounts
end

-- return a sorted list of characters found in the saved vars file for the given server and account
function manager:GetCharacters(server, account, excludeCurrent)
    local characters = {}

    for id, character in pairs(self.ServerInformation[server][account]) do
        local insert = not (excludeCurrent and id == self.CharacterId)

        if (insert) then
            table.insert(characters, character)
        end
    end

    table.sort(characters)

    return characters
end

-- return the character id from the saved vars file for the given character name
function manager:GetCharacterId(server, account, character)
    local characters = self.ServerInformation[server][account]

    if (character == "Account") then
        return "$AccountWide"
    end

    for id, characterName in pairs(characters) do
        if (characterName == character) then
            return tostring(id)
        end
    end
end

-- copy all settings, excluding common settings, from one character/account to another
function manager:Copy(server, account, character, copyToAccount)
    local characterId = "$AccountWide"

    if (character ~= "Account") then
        characterId = self:GetCharacterId(server, account, character)
    end

    local rawTable = self:GetRawTable()
    local path = searchPath(rawTable, server, account, characterId)
    local characterSettings = simpleCopy(path, true)

    if (copyToAccount) then
        if (characterId == "$AccountWide") then
            return
        end

        self:SetAccount(characterSettings)
    else
        self:SetCharacter(characterSettings)
    end

    -- reload the saved vars to reflect the changes
    self:LoadSavedVars()
end

-- switch the current character's settings from Account-wide to character specific
function manager:ConvertToCharacterSettings()
    if (not self.UseCharacterSettings) then
        local settings = simpleCopy(self.Vars, true)

        self.Vars.UseAccountWide = false
        self.Vars =
            ZO_SavedVars:NewCharacterIdSettings(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        self:SetCommon(true, "CharacterSettings", self.CharacterId)
    end
end

-- switch the current character's settings from character specific to Account-wide
function manager:ConvertToAccountSettings()
    if (self.UseCharacterSettings) then
        local settings = simpleCopy(self.Vars, true)

        self.Vars = ZO_SavedVars:NewAccountWide(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        self:SetCommon(nil, "CharacterSettings", self.CharacterId)
    end
end

-- return the raw saved vars table
function manager:GetRawTable()
    local rawTable = _G[self.RawTableName]

    return rawTable
end

-- add a 'Use Aaccount-wide settings' checkbox to libAddonMenu
function manager:AddAccountSettingsCheckbox()
    return {
        type = "checkbox",
        name = GetString(_G.BARSTEWARD_ACCOUNT_WIDE),
        tooltip = GetString(_G.BARSTEWARD_ACCOUNT_WIDE_TOOLTIP),
        getFunc = function()
            return not self:HasCharacterSettings()
        end,
        setFunc = function(value)
            if (value) then
                self:ConvertToAccountSettings()
            else
                self:ConvertToCharacterSettings()
            end
        end
    }
end

-- private functions
local BS = _G.BarSteward

-- simple, two level deep, table copying function
function simpleCopy(t, excludeCommon)
    local output = {}
    for name, settings in pairs(t) do
        if (type(settings) == "table") then
            if ((excludeCommon and name ~= "COMMON") or (not excludeCommon)) then
                for k, v in pairs(settings) do
                    output[name] = output[name] or {}
                    output[name][k] = v
                end
            end
        else
            output[name] = settings
        end
    end

    return output
end

-- generic table element count (#table only works correctly on sequentially numerically indexed tables)
local function countElements(t)
    local count = 0

    for _, _ in pairs(t) do
        count = count + 1
    end

    return count
end

-- *** path functions from zo_savedvars.lua ***
-- find the supplied path and return the value
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

-- add a path to the supplied table
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

-- set the value of path, creating a new one if it does not already exist
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
-- *** ***

-- loop through the default values - if the saved value matches the default value
-- then remove it. It's just wasting space as the default values will be loaded anyway
-- *** based on code from LibSavedVars ***
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

    trim(rawSavedVarsTable, BS.Defaults)
end

local function onLogout()
    if (BS.VarData) then
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
end

local function onLogoutCancelled()
    local rawTable = _G[BS.VarData.RawTableName]

    fillDefaults(rawTable, BS.Defaults)
end
--*** ***

-- Helper functions
-- returns whether the saved vars file has been converted from the libSavedVars variant to
-- the type used by this class
function BS.SavedVarsNeedConverting()
    local rawTable = _G[BS.Name .. "SavedVars"]

    return searchPath(rawTable, GetWorldName(), GetDisplayName(), "$AccountWide", "COMMON") == nil
end

-- determine whether the supplied vars belong in the COMMON section and merge if appropriate
-- returns the merged table
local commonSettings = {}

do
    for key, _ in pairs(BS.CommonDefaults) do
        table.insert(commonSettings, key)
    end
end

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

-- converts a libSavedVars type saved vars file to the type used by this class
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

-- apply logout hooks for default trimming, create a new saved vars manager and return it
function BS.CreateSavedVariablesManager(varsFilename, defaults, commonDefaults)
    ZO_PreHook("Logout", onLogout)
    ZO_PreHook("Quit", onLogout)
    ZO_PreHook("CancelLogout", onLogoutCancelled)

    return manager:New(varsFilename, defaults, commonDefaults)
end
