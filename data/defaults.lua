--[[
    c - default colour
    okv, okc - ok value, ok colour
    wv, wc - warning value, warning colour
    dv, dc - danger value, danger colour
]]
local x, y = GuiRoot:GetCenter()
local BS = _G.BarSteward

BS.Defaults = {
    BackBarIcon = "/esoui/art/tradinghouse/tradinghouse_weapons_1h_sword_up.dds",
    Categories = true,
    CategoriesCount = true,
    DefaultCombatColour = {0.3686274588, 0, 0, 1},
    DefaultColour = {(230 / 255), (230 / 255), (230 / 255), 1},
    DefaultDangerColour = {(204 / 255), 0, 0, 1},
    DefaultMaxColour = {1, 0.5, 0, 1},
    DefaultWarningColour = {1, 1, 0, 1},
    DefaultOkColour = {0, 1, 0, 1},
    DungeonInfo = {IsInDungeon = false, ChestCount = 0, PreviousChest = {x = 0, y = 0}},
    Font = "Default",
    FontSize = 18,
    FriendAnnounce = {},
    Gold = {},
    GridSize = 10,
    GuildFriendAnnounce = {},
    IconSize = 32,
    MainBarIcon = "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    Movable = false,
    OtherCurrencies = {},
    PreviousFriendTime = {},
    PreviousGuildFriendTime = {},
    PreviousAnnounceTime = {},
    SnapToGrid = false,
    TimeFormat12 = "hh:m",
    TimeFormat24 = "HH:m",
    TimeType = GetString(_G.BARSTEWARD_24),
    Trackers = {},
    Updates = {},
    VisibleGridSize = 65,
    WatchedItems = {
        [BS.PERFECT_ROE] = true,
        [BS.POTENT_NIRNCRUX] = true
    },
    Bars = {
        [1] = {
            Orientation = GetString(_G.BARSTEWARD_HORIZONTAL),
            Position = {X = x, Y = y},
            Name = GetString(_G.BARSTEWARD_MAIN_BAR),
            Backdrop = {
                Show = true,
                Colour = {0.23, 0.23, 0.23, 0.7}
            },
            TooltipAnchor = GetString(_G.BARSTEWARD_BOTTOM),
            ValueSide = GetString(_G.BARSTEWARD_RIGHT),
            Anchor = GetString(_G.BARSTEWARD_MIDDLE),
            Scale = 1,
            NudgeCompass = false
        }
    },
    Controls = {
        [BS.W_TIME] = {
            Bar = 1,
            Cat = 2,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
        },
        [BS.W_ALLIANCE_POINTS] = {
            Bar = 1,
            Cat = 7,
            PvPOnly = false,
            SoundWhenEquals = false,
            UseSeparators = false
        },
        [BS.W_CROWN_GEMS] = {
            Cat = 7,
            UseSeparators = false
        },
        [BS.W_CROWNS] = {
            Cat = 7,
            UseSeparators = false
        },
        [BS.W_EVENT_TICKETS] = {
            Announce = false,
            Bar = 1,
            Cat = 7,
            ColourValues = "c,dv,dc,mv,mc",
            DangerValue = 8,
            HideLimit = false,
            NoLimitColour = false,
            ShowPercent = false,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit"
        },
        [BS.W_GOLD] = {
            Bar = 1,
            Cat = 7,
            UseSeparators = false
        },
        [BS.W_SEALS_OF_ENDEAVOUR] = {
            Bar = 1,
            Cat = 7,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_TELVAR_STONES] = {
            Bar = 1,
            Cat = 7,
            PvPOnly = false,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_TRANSMUTE_CRYSTALS] = {
            Cat = 7,
            ColourValues = "c,wv,wc,dv,dc,mv,mc",
            DangerValue = 50,
            HideLimit = false,
            Invert = false,
            ShowPercent = false,
            WarningValue = 200
        },
        [BS.W_UNDAUNTED_KEYS] = {
            Bar = 1,
            Cat = 7,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
        },
        [BS.W_WRIT_VOUCHERS] = {
            Bar = 1,
            Cat = 7,
            UseSeparators = false
        },
        [BS.W_BAG_SPACE] = {
            Announce = false,
            Bar = 1,
            Cat = 9,
            ColourValues = "okc,wv,wc,dv,dc,mv,mc",
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            WarningValue = 85
        },
        [BS.W_BANK_SPACE] = {
            Bar = 1,
            Cat = 9,
            ColourValues = "okc,wv,wc,dv,dc,mv,mc",
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            WarningValue = 85
        },
        [BS.W_FPS] = {
            Cat = 4
        },
        [BS.W_LATENCY] = {
            Bar = 1,
            Cat = 4,
            ColourValues = "c,wv,wc,dc,dv"
        },
        [BS.W_BLACKSMITHING] = {
            Autohide = true,
            Bar = 1,
            Cat = 6,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideSeconds = false,
            HideWhenComplete = false,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_WOODWORKING] = {
            Autohide = true,
            Bar = 1,
            Cat = 6,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideSeconds = false,
            HideWhenComplete = false,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_CLOTHING] = {
            Autohide = true,
            Bar = 1,
            Cat = 6,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideSeconds = false,
            HideWhenComplete = false,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_JEWELCRAFTING] = {
            Autohide = true,
            Bar = 1,
            Cat = 6,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideSeconds = false,
            HideWhenComplete = false,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_REPAIR_COST] = {
            Autohide = true,
            Bar = 1,
            Cat = 9,
            UseSeparators = false
        },
        [BS.W_MOUNT_TRAINING] = {
            Bar = 1,
            Cat = 10,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 3,
            HideSeconds = false,
            HideWhenComplete = false,
            HideWhenFullyUsed = false,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_RAPPORT] = {
            Autohide = true,
            Bar = 1,
            Cat = 5,
            ColourValues = ""
        },
        [BS.W_CHAMPION_POINTS] = {
            Autohide = true,
            Bar = 1,
            Cat = 3,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_MUNDUS_STONE] = {
            Autohide = true,
            Cat = 3,
            ColourValues = "c,dc"
        },
        [BS.W_DURABILITY] = {
            Cat = 9,
            ColourValues = "okc,okv,dc,dv,wc",
            DangerValue = 15,
            OkValue = 75,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            Units = "%"
        },
        [BS.W_DAILY_ENDEAVOURS] = {
            Cat = 2,
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_WEEKLY_ENDEAVOURS] = {
            Cat = 2,
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_REPAIRS_KITS] = {
            Cat = 9,
            ColourValues = "okc,dv,dc,wv,wc",
            DangerValue = 6,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            WarningValue = 11
        },
        [BS.W_STOLEN_ITEMS] = {
            Autohide = true,
            Cat = 12
        },
        [BS.W_RECALL_COOLDOWN] = {
            Autohide = true,
            Cat = 3
        },
        [BS.W_FENCE_TRANSACTIONS] = {
            Autohide = false,
            Cat = 12,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            SoundWhenOver = false,
            SoundWhenOverSound = "Dual Forfeit",
            Units = "%",
            WarningValue = 85
        },
        [BS.W_ZONE] = {
            Cat = 3
        },
        [BS.W_PLAYER_NAME] = {
            Cat = 3
        },
        [BS.W_RACE] = {
            Cat = 3
        },
        [BS.W_CLASS] = {
            Cat = 3
        },
        [BS.W_ALLIANCE] = {
            Cat = 3,
            ColourValues = "",
            NoValue = false
        },
        [BS.W_LEADS] = {
            Autohide = true,
            Cat = 2,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_SOUL_GEMS] = {
            Cat = 9,
            UseSeparators = false
        },
        [BS.W_FRIENDS] = {
            Announce = false,
            Cat = 11,
            HideLimit = false
        },
        [BS.W_MEMORY] = {
            Cat = 4,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 600,
            Precision = 1,
            UpdateFrequency = 5,
            WarningValue = 450
        },
        [BS.W_SKYSHARDS] = {
            Cat = 3
        },
        [BS.W_SKILL_POINTS] = {
            Autohide = true,
            Cat = 3,
            Colour = {0, 1, 0, 1}
        },
        [BS.W_WRITS_SURVEYS] = {
            Cat = 9
        },
        [BS.W_FENCE_RESET] = {
            Autohide = true,
            Cat = 12,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_ENDEAVOUR_PROGRESS] = {
            Cat = 2,
            HideWhenComplete = false,
            Progress = true
        },
        [BS.W_TROPHY_VAULT_KEYS] = {
            Autohide = true,
            Cat = 9
        },
        [BS.W_LOCKPICKS] = {
            Cat = 9,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 50
        },
        [BS.W_LAUNDER_TRANSACTIONS] = {
            Autohide = false,
            Cat = 12,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            SoundWhenOver = false,
            SoundWhenOverSound = "Dual Forfeit",
            Units = "%",
            WarningValue = 85
        },
        [BS.W_SPEED] = {
            Cat = 3,
            ShowPercent = false,
            Units = "mph"
        },
        [BS.W_CRAFTING_DAILIES] = {
            Cat = 6,
            ColourValues = ""
        },
        [BS.W_GUILD_FRIENDS] = {
            Announce = false,
            Cat = 11,
            HideLimit = false
        },
        [BS.W_DAILY_ENDEAVOUR_TIME] = {
            Cat = 2,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideDaysWhenZero = true,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_WEEKLY_ENDEAVOUR_TIME] = {
            Cat = 2,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 48,
            HideDaysWhenZero = false,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_COMPANION_LEVEL] = {
            Autohide = true,
            Cat = 5,
            HideWhenMaxLevel = false,
            ShowXPPC = true
        },
        [BS.W_TRIBUTE_CLUB_RANK] = {
            Cat = 2
        },
        [BS.W_PLAYER_LEVEL] = {
            Autohide = true,
            Cat = 3
        },
        [BS.W_ACHIEVEMENT_POINTS] = {
            Cat = 2,
            ShowPercent = false
        },
        [BS.W_PLEDGES_TIME] = {
            Cat = 2,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideDaysWhenZero = false,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_SHADOWY_VENDOR_TIME] = {
            Cat = 2,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_LFG_TIME] = {
            Cat = 2,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_CRAFTING_DAILY_TIME] = {
            Cat = 6,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideDaysWhenZero = true,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_WATCHED_ITEMS] = {
            Announce = false,
            Cat = 9,
            [BS.PERFECT_ROE] = true,
            [BS.POTENT_NIRNCRUX] = true
        },
        [BS.W_TAMRIEL_TIME] = {
            Cat = 4,
            Requires = "LibClockTST"
        },
        [BS.W_ACTIVE_BAR] = {
            Cat = 1,
            ColourValues = ""
        },
        [BS.W_DPS] = {
            Cat = 3,
            Requires = "LibCombat",
            UseSeparators = false
        },
        [BS.W_LOREBOOKS] = {
            Cat = 2,
            ShowCategory = GetLoreCategoryInfo(1)
        },
        [BS.W_RECIPES] = {
            Cat = 6
        },
        [BS.W_RANDOM_MEMENTO] = {
            Cat = 9,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_PET] = {
            Cat = 9,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_MOUNT] = {
            Cat = 9,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_EMOTE] = {
            Cat = 9,
            ColourValues = "",
            Print = true
        },
        [BS.W_CONTAINERS] = {
            Autohide = false,
            Cat = 9
        },
        [BS.W_TREASURE] = {
            Autohide = false,
            Cat = 9
        },
        [BS.W_RANDOM_DUNGEON] = {
            Autohide = false,
            Cat = 2,
            ColourValues = ""
        },
        [BS.W_PLAYER_LOCATION] = {
            Cat = 3
        },
        [BS.W_RANDOM_BATTLEGROUND] = {
            Autohide = false,
            Cat = 2,
            ColourValues = ""
        },
        [BS.W_RANDOM_TRIBUTE] = {
            Autohide = false,
            Cat = 2,
            ColourValues = ""
        },
        [BS.W_PLAYER_EXPERIENCE] = {
            Cat = 3,
            UseSeparators = false
        },
        [BS.W_UNKNOWN_WRIT_MOTIFS] = {
            Autohide = false,
            Cat = 6,
            Requires = "LibCharacterKnowledge"
        },
        [BS.W_FURNISHINGS] = {
            Cat = 9,
            Autohide = false
        },
        [BS.W_COMPANION_GEAR] = {
            Cat = 9,
            Autohide = false
        },
        [BS.W_MUSEUM] = {
            Cat = 9,
            Autohide = false
        },
        [BS.W_EQUIPPED_POISON] = {
            Autohide = false,
            Cat = 9,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 50
        },
        [BS.W_VAMPIRISM] = {
            Autohide = true,
            Cat = 3
        },
        [BS.W_VAMPIRISM_TIMER] = {
            Autohide = true,
            Cat = 3,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_VAMPIRISM_FEED_TIMER] = {
            Autohide = true,
            Cat = 3,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            HideDaysWhenZero = false,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_FRAGMENTS] = {
            Cat = 9
        },
        [BS.W_RUNEBOXES] = {
            Cat = 9
        },
        [BS.W_RECIPE_WATCH] = {
            Announce = true,
            Autohide = false,
            Cat = 9
        },
        [BS.W_CHESTS_FOUND] = {
            Autohide = false,
            Cat = 2
        },
        [BS.W_SHALIDORS_LIBRARY] = {
            Cat = 2
        },
        [BS.W_CRAFTING_MOTIFS] = {
            Cat = 2
        },
        [BS.W_DAILY_PROGRESS] = {
            Cat = 2,
            HideWhenComplete = false,
            Progress = true
        },
        [BS.W_WEAPON_CHARGE] = {
            Cat = 9,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 25
        },
        [BS.W_BASTIAN] = {
            Cat = 5
        },
        [BS.W_MIRRI] = {
            Cat = 5
        },
        [BS.W_EMBER] = {
            Cat = 5
        },
        [BS.W_ISOBEL] = {
            Cat = 5
        },
        [BS.W_SHARP] = {
            Cat = 5
        },
        [BS.W_AZANDAR] = {
            Cat = 5
        },
        [BS.W_EZABI] = {
            Cat = 13
        },
        [BS.W_GHRASHAROG] = {
            Cat = 13
        },
        [BS.W_GILADIL] = {
            Cat = 13
        },
        [BS.W_PIRHARRI] = {
            Cat = 13
        },
        [BS.W_TYTHIS] = {
            Cat = 13
        },
        [BS.W_NUZHIMEH] = {
            Cat = 13
        },
        [BS.W_ALLARIA] = {
            Cat = 13
        },
        [BS.W_CASSUS] = {
            Cat = 13
        },
        [BS.W_FEZEZ] = {
            Cat = 13
        },
        [BS.W_BARON] = {
            Cat = 13
        },
        [BS.W_FACTOTUM] = {
            Cat = 13
        },
        [BS.W_FACTOTUM2] = {
            Cat = 13
        },
        [BS.W_ADERENE] = {
            Cat = 13
        },
        [BS.W_ZUQOTH] = {
            Cat = 13
        },
        [BS.W_HOARFROST] = {
            Cat = 13
        },
        [BS.W_PYROCLAST] = {
            Cat = 13
        },
        [BS.W_PEDDLER] = {
            Cat = 13
        },
        [BS.W_ARCHIVAL_FRAGMENTS] = {
            UseSeparators = false,
            Cat = 7
        }
    }
}

for widgetId, widgetData in pairs(BS.Defaults.Controls) do
    if (not widgetData.Bar) then
        widgetData.Bar = 0
    end

    if (not widgetData.Order) then
        widgetData.Order = widgetId
    end

    if ((widgetData.ColourValues or "") ~= "") then
        widgetData.ColourValues = "c"
    end
end
