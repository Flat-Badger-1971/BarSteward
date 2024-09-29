local manager = ZO_Object:Subclass()
local searchPath, setPath, simpleCopy

function manager:New(varFileName, defaults, commonDefaults)
    local managerObject = self:Subclass()

    managerObject:Initialise(varFileName, defaults, commonDefaults)

    -- set default getter/setter for vars
    -- pretty sure I'm doing this wrong, but it works, so, meh...
    local metatable = {
        __index = function(t, key)
            -- if the function exists in the main class - return that
            local parentClass = rawget(t, "__parentClasses")[1]

            if (parentClass[key] and type(parentClass[key] == "function")) then
                return parentClass[key]
            end

            -- assume anything that's not part of the main class is an attempt to read a saved variable
            local vars = rawget(t, "_vars")

            if (vars) then
                return vars[key]
            end
        end,
        __newindex = function(t, key, value)
            -- can't use rawset - doesn't like empty tables for some reason
            local vars = rawget(t, "_vars")

            vars[key] = value
        end
    }

    return setmetatable(managerObject, metatable)
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

-- switch the current character's settings from character specific to Account-wide
function manager:ConvertToAccountSettings()
    if (self._useCharacterSettings) then
        local settings = simpleCopy(self._vars, true)

        self._vars = ZO_SavedVars:NewAccountWide(self._rawTableName, self._version, nil, self._defaults, self._profile)

        for k, v in pairs(settings) do
            self._vars[k] = v
        end

        self:SetCommon(nil, "CharacterSettings", self._characterId)
        self._useCharacterSettings = false
    end
end

-- switch the current character's settings from Account-wide to character specific
function manager:ConvertToCharacterSettings()
    if (not self._useCharacterSettings) then
        local settings = simpleCopy(self._vars, true)

        self._vars.UseAccountWide = false
        self._vars =
            ZO_SavedVars:NewCharacterIdSettings(self._rawTableName, self._version, nil, self._defaults, self._profile)

        for k, v in pairs(settings) do
            self._vars[k] = v
        end

        self:SetCommon(true, "CharacterSettings", self._characterId)
        self._useCharacterSettings = true
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
        self:ConvertToCharacterSettings()
    end

    -- reload the saved vars to reflect the changes
    self:LoadSavedVars()
end

function manager:GetAllAccountCommon(...)
    local rawTable = self:GetRawTable()
    local accountVars = {}

    for server, serverData in pairs(rawTable) do
        for account, accountData in pairs(serverData) do
            local commonAccountVars = searchPath(accountData, "$AccountWide", "COMMON", ...)

            table.insert(accountVars, {server = server, account = account, vars = commonAccountVars})
        end
    end

    return accountVars
end

function manager:FillDefaults(t, defaults)
    if ((t == nil) or (type(t) ~= "table") or (defaults == nil)) then
        return
    end

    for key, defaultValue in pairs(defaults) do
        if (type(defaultValue)) == "table" then
            if (t[key] == nil) then
                t[key] = {}
            end

            self:FillDefaults(t[key], defaultValue)
        elseif (t[key] == nil) then
            t[key] = defaultValue
        end
    end
end

-- return a sorted list of accounts found in the saved vars file for the given server
function manager:GetAccounts(server)
    local accounts = {}

    if (self._serverInformation[server]) then
        for account, _ in pairs(self._serverInformation[server]) do
            table.insert(accounts, account)
        end

        table.sort(accounts)
    end
    return accounts
end

-- return the character id from the saved vars file for the given character name
function manager:GetCharacterId(server, account, character)
    local characters = self._serverInformation[server][account]

    if (character == "Account") then
        return "$AccountWide"
    end

    for id, characterName in pairs(characters) do
        if (characterName == character) then
            return tostring(id)
        end
    end
end

-- return a sorted list of characters found in the saved vars file for the given server and account
function manager:GetCharacters(server, account, excludeCurrent)
    local characters = {}

    for id, character in pairs(self._serverInformation[server][account]) do
        local insert = not (excludeCurrent and id == self._characterId)

        if (insert) then
            table.insert(characters, character)
        end
    end

    table.sort(characters)

    return characters
end

-- Get settings from the 'COMMON' section, works regardless of whether we are using Account-wide or Character settings
function manager:GetCommon(...)
    local rawTable = self:GetRawTable()

    return searchPath(rawTable, self._profile, self._displayName, "$AccountWide", "COMMON", ...)
end

-- get the current character's unique id
function manager:GetCurrentCharacterId()
    if (self:HasCharacterSettings()) then
        return self._characterId
    else
        return "$AccountWide"
    end
end

-- return the raw saved vars table
function manager:GetRawTable()
    local rawTable = _G[self._rawTableName]

    return rawTable
end

-- return a table of server/account/character information found in the saved vars file
function manager:GetServerInformation()
    return self._serverInformation
end

-- return a sorted list of servers found in the saved vars file
function manager:GetServers()
    local servers = {}

    for server, _ in pairs(self._serverInformation) do
        table.insert(servers, server)
    end

    table.sort(servers)

    return servers
end

-- Does the current character have character specific settings?
function manager:HasCharacterSettings()
    return self:GetCommon("CharacterSettings", self._characterId)
end

function manager:Initialise(varFileName, defaults, commonDefaults)
    self._defaults = defaults
    self._rawTableName = varFileName
    self._profile = GetWorldName()
    self._displayName = GetDisplayName()
    self._characterId = GetCurrentCharacterId()
    self._commonDefaults = commonDefaults
    self._version = 1
    self._useCharacterSettings = self:HasCharacterSettings()

    self:LoadSavedVars()
end

-- Load/Reload the saved vars
function manager:LoadSavedVars()
    if (self._useCharacterSettings) then
        self._vars =
            ZO_SavedVars:NewCharacterIdSettings(self._rawTableName, self._version, nil, self._defaults, self._profile)
    else
        self._vars = ZO_SavedVars:NewAccountWide(self._rawTableName, self._version, nil, self._defaults, self._profile)
    end

    -- check common defaults
    for key, value in pairs(self._commonDefaults) do
        if (not self:GetCommon(key)) then
            self:SetCommon(value, key)
        end
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

    self._serverInformation = serverInformation
end

-- loop through the default values - if the saved value matches the default value
-- then remove it. It's just wasting space as the default values will be loaded anyway
-- *** based on code from LibSavedVars ***
function manager:RemoveDefaults()
    local character = self:GetCurrentCharacterId()
    local rawTable = self:GetRawTable()
    local rawSavedVarsTable = searchPath(rawTable, self._profile, self._displayName, character)
    local commonVars = self:GetCommon()

    self:TrimDefaults(rawSavedVarsTable, self._defaults)
    self:TrimDefaults(commonVars, self._commonDefaults)
end

-- add defaults back into the saved vars file
function manager:RestoreDefaultValues()
    local character = self:GetCurrentCharacterId()
    local rawTable = self:GetRawTable()
    local rawSavedVarsTable = searchPath(rawTable, self._profile, self._displayName, character)
    local commonVars = self:GetCommon()

    self:FillDefaults(rawSavedVarsTable, self._defaults)
    self:FillDefaults(commonVars, self._commonDefaults)
end

-- Get settings from the 'Account-wide' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetAccount(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self._profile, self._displayName, "$AccountWide", ...)
end

-- Set settings from the 'COMMON' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetCommon(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self._profile, self._displayName, "$AccountWide", "COMMON", ...)
end

-- Get settings from the 'Character' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetCharacter(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self._profile, self._displayName, self._characterId, ...)
end

-- Set settings from the 'COMMON' section, works regardless of whether we are using Account-wide or Character settings
function manager:SetCommon(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self._profile, self._displayName, "$AccountWide", "COMMON", ...)
end

function manager:TrimDefaults(savedVarsTable, defaults)
    local valid = savedVarsTable ~= nil

    valid = valid and type(savedVarsTable) == "table"
    valid = valid and defaults

    if (not valid) then
        return
    end

    for key, defaultValue in pairs(defaults) do
        if (key ~= "WatchedItems") then
            if (type(defaultValue) == "table") then
                if (type(savedVarsTable[key])) == "table" then
                    self:TrimDefaults(savedVarsTable[key], defaultValue)

                    if (savedVarsTable[key] and (next(savedVarsTable[key]) == nil)) then
                        savedVarsTable[key] = nil
                    end
                end
            elseif (savedVarsTable[key] == defaultValue) then
                savedVarsTable[key] = nil
            end
        end
    end
end

-- private functions
local BS = _G.BarSteward

-- *** path functions from zo_savedvars.lua ***
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

-- set the value of path, creating a new one if it doesn't already exist
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

-- Helper functions
-- returns whether the saved vars file has been converted from the libSavedVars variant to
-- the type used by this class
function BS.SavedVarsNeedConverting()
    local rawTable = _G[BS.Name .. "SavedVars"]

    if (rawTable == nil) then
        -- new installation
        BS.NewVars = true

        return false
    end

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

local redundant = {"SurveyTracking", "WritTracking"}

local function removeRedundant(vars)
    for name, _ in pairs(vars) do
        if (ZO_IsElementInNumericallyIndexedTable(redundant, name)) then
            vars[name] = nil
        end
    end
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
                        removeRedundant(info.Account)
                        vars[server][account][character] = info.Account
                    elseif (info.Characters and BS.CountElements(info.Characters) > 2) then
                        local characterInfo = info.Characters

                        characterOnly[character] = true
                        common = checkCommon(characterInfo, common)
                        characterInfo["$LastCharacterName"] = info["$LastCharacterName"]
                        characterInfo.LibSavedVars = nil
                        removeRedundant(characterInfo)
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
local function onLogout()
    BS.Vars:RemoveDefaults()
end

local function onLogoutCancelled()
    BS.Vars:RestoreDefaultValues()
end

function BS.CreateSavedVariablesManager(varsFilename, defaults, commonDefaults)
    local savedVarsManager = manager:New(varsFilename, defaults, commonDefaults)

    ZO_PreHook("Logout", onLogout)
    ZO_PreHook("Quit", onLogout)
    ZO_PreHook("CancelLogout", onLogoutCancelled)

    return savedVarsManager
end
