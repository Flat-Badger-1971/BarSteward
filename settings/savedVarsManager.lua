local BS = _G.BarSteward

-- apply logout hooks for default trimming, create a new saved vars manager and return it
local function onLogout()
    BS.Vars:RemoveDefaults()
end

local function onLogoutCancelled()
    BS.Vars:RestoreDefaultValues()
end

function BS.CreateSavedVariablesManager(varsFilename, defaults, commonDefaults)
    local savedVarsManager =
        BS.LC.SavedVarsManager:New(
        varsFilename,
        defaults,
        commonDefaults,
        GetString(_G.BARSTEWARD_ACCOUNT_WIDE),
        GetString(_G.BARSTEWARD_ACCOUNT_WIDE_TOOLTIP)
    )

    ZO_PreHook("Logout", onLogout)
    ZO_PreHook("Quit", onLogout)
    ZO_PreHook("CancelLogout", onLogoutCancelled)

    return savedVarsManager
end
