local BS = BarSteward

-- debug helpers
if (GetDisplayName() == "@Flat-Badger") then
    BS.DEBUG = false  --  all
    BS.DEBUGC = false -- control
    BS.DEBUGV = false -- value
    BS.DEBUGS = false -- spacer
end

local function trackGold()
    local goldInBag = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    local character = GetUnitName("player")

    BS.Vars:SetCommon(goldInBag, "Gold", character)
end

local function trackOtherCurrency(currency)
    local currencyInBag = GetCurrencyAmount(currency, CURRENCY_LOCATION_CHARACTER)
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
    BS.LC.GetAddonVersion()
    BS.CheckVars(BS.Vars)

    if (BS.NewVars) then
        BS.SetVersionCheck()
    else
        BS.VersionCheck()
    end

    -- gold tracker
    BS.EventManager:RegisterForEvent(EVENT_PLAYER_ACTIVATED, trackGold)
    BS.EventManager:RegisterForEvent(EVENT_MONEY_UPDATE, trackGold)

    -- tel var tracker
    trackOtherCurrency(CURT_TELVAR_STONES)
    BS.EventManager:RegisterForEvent(
        EVENT_TELVAR_STONE_UPDATE,
        function()
            trackOtherCurrency(CURT_TELVAR_STONES)
        end
    )

    -- alliance points tracker
    trackOtherCurrency(CURT_ALLIANCE_POINTS)
    BS.EventManager:RegisterForEvent(
        EVENT_ALLIANCE_POINT_UPDATE,
        function()
            trackOtherCurrency(CURT_ALLIANCE_POINTS)
        end
    )

    -- writ voucher tracker
    trackOtherCurrency(CURT_WRIT_VOUCHERS)
    BS.EventManager:RegisterForEvent(
        EVENT_WRIT_VOUCHER_UPDATE,
        function()
            trackOtherCurrency(CURT_WRIT_VOUCHERS)
        end
    )

    -- get a reference to LibClockTST if it's installed
    if (LibClockTST) then
        BS.LibClock = LibClockTST:Instance()
    end

    -- get a reference to LibCharacterKnowledge if it's installed
    if (LibCharacterKnowledge) then
        BS.LibCK = LibCharacterKnowledge
    end

    -- get a reference to LibUndauntedPledges if it's installed
    if (LibUndauntedPledges) then
        BS.LUP = LibUndauntedPledges
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
    BS.EventManager:RegisterForEvent(
        EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            BS.CheckPerformance(inCombat)
        end
    )

    -- track character names1111
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

    BS.EventManager:RegisterForEvent(
        EVENT_PLAYER_ACTIVATED,
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
    BS.RegisterHooks()

    if (BS.Vars.Controls[BS.W_GOLDEN_PURSUITS].HideDefault) then
        BS.HideGoldenPursuitsDefaultUI()
    end
end

local function Initialise()
    BS.RegisterDialogues()
    BS.RegisterSlashCommands()
    BS.RegisterColours()
    BS.ContinueIntialising()
end

function BS.OnAddonLoaded(_, addonName)
    if (addonName ~= BS.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BS.Name, EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(BS.Name, EVENT_ADD_ON_LOADED, BS.OnAddonLoaded)
