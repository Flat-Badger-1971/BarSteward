local BS = _G.BarSteward
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
        rawset(t.Vars, key, value)
    end
}

function manager:New()
    local managerObject = self:Subclass()
    local rawTableName, isAccountWide, characterId, displayName = managerObject:Initialise()

    return setmetatable(managerObject, metatable), rawTableName, isAccountWide, characterId, displayName
end

function manager:Initialise()
    self.Defaults = BS.Defaults
    self.RawTableName = BS.Name .. "SavedVars"
    self.Profile = GetWorldName()
    self.DisplayName = GetDisplayName()
    self.CharacterId = GetCurrentCharacterId()
    self.CommonDefaults = BS.CommonDefaults
    self.Version = 1
    self.UseCharacterSettings = self:HasCharacterSettings()

    self:LoadSavedVars()

    return self.RawTableName, self.Vars.IsAccountWide, self.CharacterId, self.DisplayName
end

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

function manager:HasCharacterSettings()
    return self:GetCommon("CharacterSettings", self.CharacterId)
end

function manager:GetCommon(...)
    local rawTable = self:GetRawTable()

    return searchPath(rawTable, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

function manager:SetCommon(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, "$AccountWide", "COMMON", ...)
end

function manager:SetAccount(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, "$AccountWide", ...)
end

function manager:SetCharacter(value, ...)
    local rawTable = self:GetRawTable()

    setPath(rawTable, value, self.Profile, self.DisplayName, self.CharacterId, ...)
end

function manager:GetServerInformation()
    return self.ServerInformation
end

function manager:GetServers()
    local servers = {}

    for server, _ in pairs(self.ServerInformation) do
        table.insert(servers, server)
    end

    table.sort(servers)

    return servers
end

function manager:GetAccounts(server)
    local accounts = {}

    for account, _ in pairs(self.ServerInformation[server]) do
        table.insert(accounts, account)
    end

    table.sort(accounts)

    return accounts
end

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
end

function manager:ConvertToCharacterSettings()
    if (not self.UseCharacterSettings) then
        local settings = simpleCopy(self.Vars)

        self.Vars.UseAccountWide = false
        self.Vars =
            ZO_SavedVars:NewCharacterIdSettings(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        self:SetCommon(true, "CharacterSettings", self.CharacterId)
    end
end

function manager:ConvertToAccountSettings()
    if (self.UseCharacterSettings) then
        local settings = simpleCopy(self.Vars)

        self.Vars = ZO_SavedVars:NewAccountWide(self.RawTableName, self.Version, nil, self.Defaults, self.Profile)

        for k, v in pairs(settings) do
            self.Vars[k] = v
        end

        self:SetCommon(nil, "CharacterSettings", self.CharacterId)
    end
end

function manager:GetRawTable()
    local rawTable = _G[self.RawTableName]

    return rawTable
end

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

local function checkCommon(vars, common)
    for name, settings in pairs(vars) do
        if (ZO_IsElementInNumericallyIndexedTable(BS.COMMON_SETTINGS, name)) then
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

-- path functions from zo_savedvars.lua
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
-- based on code from LibSavedVars
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

    fillDefaults(rawTable, BS.Defaults)
end

function BS.SavedVarsNeedConverting()
    local rawTable = _G[BS.Name .. "SavedVars"]

    return searchPath(rawTable, GetWorldName(), GetDisplayName(), "$AccountWide", "COMMON") == nil
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
