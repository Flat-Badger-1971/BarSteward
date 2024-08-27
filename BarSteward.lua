local BS = _G.BarSteward

local function trackGold()
    local goldInBag = GetCurrencyAmount(_G.CURT_MONEY, _G.CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    BS.Vars:SetCommon(goldInBag, "Gold", character)
end

local function trackOtherCurrency(currency)
    local currencyInBag = GetCurrencyAmount(currency, _G.CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    if (BS.Vars:GetCommon("OtherCurrencies", currency) == nil) then
        BS.Vars:SetCommon({}, "OtherCurrencies")
    end

    if (BS.Vars:GetCommon("OtherCurrencies", currency, character) == nil) then
        BS.Vars:SetCommon(currencyInBag, "OtherCurrencies", currency, character)
    end
end

function BS.ContinueIntialising()
    BS.Vars = BS.CreateSavedVariablesManager("BarStewardSavedVars", BS.Defaults, BS.CommonDefaults)
    BS.CheckVars(BS.Vars)

    if (BS.NewVars) then
        BS.SetVersionCheck()
    else
        BS.VersionCheck()
    end

    -- gold tracker
    BS.RegisterForEvent(_G.EVENT_PLAYER_ACTIVATED, trackGold)
    BS.RegisterForEvent(_G.EVENT_MONEY_UPDATE, trackGold)

    -- tel var tracker
    trackOtherCurrency(_G.CURT_TELVAR_STONES)
    BS.RegisterForEvent(
        _G.EVENT_TELVAR_STONE_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_TELVAR_STONES)
        end
    )

    -- alliance points tracker
    trackOtherCurrency(_G.CURT_ALLIANCE_POINTS)
    BS.RegisterForEvent(
        _G.EVENT_ALLIANCE_POINT_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_ALLIANCE_POINTS)
        end
    )

    -- writ voucher tracker
    trackOtherCurrency(_G.CURT_WRIT_VOUCHERS)
    BS.RegisterForEvent(
        _G.EVENT_WRIT_VOUCHER_UPDATE,
        function()
            trackOtherCurrency(_G.CURT_WRIT_VOUCHERS)
        end
    )

    -- get a reference to LibClockTST if it's installed
    if (_G.LibClockTST) then
        BS.LibClock = _G.LibClockTST:Instance()
    end

    -- get a reference to LibCharacterKnowledge if it's installed
    if (_G.LibCharacterKnowledge) then
        BS.LibCK = _G.LibCharacterKnowledge
    end

    -- get a reference to LibUndauntedPledges if it's installed
    if (_G.LibUndauntedPledges) then
        BS.LUP = _G.LibUndauntedPledges
    end

    BS.RegisterSettings()

    -- create bars
    local bars = BS.Vars.Bars

    BS.Bars = {}
    BS.alignBars = {}

    for barIndex in pairs(bars) do
        if (not BS.Vars.Bars[barIndex].Disable) then
            BS.GenerateBar(barIndex)
        end
    end

    -- ensure all houses get a keybind option
    BS.AddHousingWidgets(0)

    -- performance
    BS.RegisterForEvent(
        _G.EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            BS.CheckPerformance(inCombat)
        end
    )

    -- track character names
    if (BS.Vars:GetCommon("CharacterList") == nil) then
        BS.Vars:SetCommon({}, "CharacterList")

        if (BS.Vars:GetCommon("Gold")) then
            local gold = BS.Vars:GetCommon("Gold")

            for char, _ in pairs(gold) do
                BS.Vars:SetCommon(true, "CharacterList", char)
            end
        end
    end

    BS.Vars:SetCommon(true, "CharacterList", GetUnitName("player"))

    -- handle quest info
    BS.GetQuestInfo()

    BS.RegisterForEvent(
        _G.EVENT_PLAYER_ACTIVATED,
        function()
            if (BS.Vars.Controls[BS.W_CHESTS_FOUND].Bar == 0) then
                return
            end

            local isInDungeon = IsUnitInDungeon("player")

            if (BS.Vars.DungeonInfo.IsInDungeon ~= isInDungeon) then
                BS.Vars.DungeonInfo.IsInDungeon = isInDungeon
                BS.Vars.DungeonInfo.ChestCount = 0
            end
        end
    )

    BS.GridChanged = true
end

local function Initialise()
    -- *** utiltity ***
    if (_G.SLASH_COMMANDS["/rl"] == nil) then
        _G.SLASH_COMMANDS["/rl"] = function()
            ReloadUI()
        end
    end

    if (_G.SLASH_COMMANDS["/rld"] == nil) then
        _G.SLASH_COMMANDS["/rld"] = function()
            if (_G.LibDebugLogger) then
                _G.LibDebugLogger:ClearLog()
            end
            ReloadUI()
        end
    end

    -- if (_G.SLASH_COMMANDS["/bslang"] == nil) then
    --     _G.SLASH_COMMANDS["/bslang"] = function(lang)
    --         SetCVar("language.2", lang)
    --     end
    -- end

    -- ***

    BS.RegisterDialogues()
    BS.RegisterColours()

    --if (BS.SavedVarsNeedConverting()) then
    --    ZO_Dialogs_ShowDialog(BS.Name .. "Backup")
    --else
    BS.ContinueIntialising()
    --end
end

function BS.OnAddonLoaded(_, addonName)
    if (addonName ~= BS.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(BS.Name, _G.EVENT_ADD_ON_LOADED, BS.OnAddonLoaded)
