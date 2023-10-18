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
            Order = 1,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_ALLIANCE_POINTS] = {
            Bar = 1,
            Order = 2,
            SoundWhenEquals = false,
            PvPOnly = false,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_CROWN_GEMS] = {
            Bar = 0,
            Order = 3,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_CROWNS] = {
            Bar = 0,
            Order = 4,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_EVENT_TICKETS] = {
            Bar = 1,
            Order = 5,
            ShowPercent = false,
            SoundWhenEquals = false,
            SoundWhenOver = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            SoundWhenOverSound = "Duel Forfeit",
            ColourValues = "c,dv,dc,mv,mc",
            DangerValue = 8,
            Announce = false,
            HideLimit = false,
            NoLimitColour = false,
            Cat = 7
        },
        [BS.W_GOLD] = {
            Bar = 1,
            Order = 6,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_SEALS_OF_ENDEAVOUR] = {
            Bar = 1,
            Order = 7,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_TELVAR_STONES] = {
            Bar = 1,
            Order = 8,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            PvPOnly = false,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_TRANSMUTE_CRYSTALS] = {
            Bar = 0,
            Order = 9,
            ShowPercent = false,
            ColourValues = "c,wv,wc,dv,dc,mv,mc",
            WarningValue = 200,
            DangerValue = 50,
            HideLimit = false,
            Invert = false,
            Cat = 7
        },
        [BS.W_UNDAUNTED_KEYS] = {
            Bar = 1,
            Order = 10,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            ColourValues = "c",
            Cat = 7
        },
        [BS.W_WRIT_VOUCHERS] = {
            Bar = 1,
            Order = 11,
            ColourValues = "c",
            UseSeparators = false,
            Cat = 7
        },
        [BS.W_BAG_SPACE] = {
            Bar = 1,
            Order = 12,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc,mv,mc",
            WarningValue = 85,
            DangerValue = 95,
            Announce = false,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false,
            Cat = 9
        },
        [BS.W_BANK_SPACE] = {
            Bar = 1,
            Order = 13,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc,mv,mc",
            WarningValue = 85,
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false,
            Cat = 9
        },
        [BS.W_FPS] = {
            Bar = 0,
            Order = 14,
            ColourValues = "c",
            Cat = 4
        },
        [BS.W_LATENCY] = {
            Bar = 1,
            Order = 15,
            ColourValues = "c,wv,wc,dc,dv",
            Cat = 4
        },
        [BS.W_BLACKSMITHING] = {
            Bar = 1,
            Order = 16,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            Autohide = true,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Cat = 6
        },
        [BS.W_WOODWORKING] = {
            Bar = 1,
            Order = 17,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            Autohide = true,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Cat = 6
        },
        [BS.W_CLOTHING] = {
            Bar = 1,
            Order = 18,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            Autohide = true,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Cat = 6
        },
        [BS.W_JEWELCRAFTING] = {
            Bar = 1,
            Order = 19,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            Autohide = true,
            HideWhenFullyUsed = false,
            HideDaysWhenZero = false,
            Cat = 6
        },
        [BS.W_REPAIR_COST] = {
            Bar = 1,
            Order = 20,
            Autohide = true,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_MOUNT_TRAINING] = {
            Bar = 1,
            Order = 21,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 3,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            HideWhenFullyUsed = false,
            Cat = 10
        },
        [BS.W_RAPPORT] = {
            Bar = 1,
            Order = 22,
            Autohide = true,
            Cat = 5
        },
        [BS.W_CHAMPION_POINTS] = {
            Bar = 1,
            Order = 23,
            Autohide = true,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_MUNDUS_STONE] = {
            Bar = 0,
            Order = 24,
            Autohide = true,
            ColourValues = "c,dc",
            Cat = 3
        },
        [BS.W_DURABILITY] = {
            Bar = 0,
            Order = 25,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,okv,dc,dv,wc",
            OkValue = 75,
            DangerValue = 15,
            Cat = 9
        },
        [BS.W_DAILY_ENDEAVOURS] = {
            Bar = 0,
            Order = 26,
            ColourValues = "c",
            HideLimit = false,
            HideWhenCompleted = false,
            Cat = 2
        },
        [BS.W_WEEKLY_ENDEAVOURS] = {
            Bar = 0,
            Order = 27,
            ColourValues = "c",
            HideLimit = false,
            HideWhenCompleted = false,
            Cat = 2
        },
        [BS.W_REPAIRS_KITS] = {
            Bar = 0,
            Order = 28,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            ColourValues = "okc,dv,dc,wv,wc",
            DangerValue = 6,
            WarningValue = 11,
            Cat = 9
        },
        [BS.W_STOLEN_ITEMS] = {
            Bar = 0,
            Order = 29,
            Autohide = true,
            ColourValues = "c",
            Cat = 12
        },
        [BS.W_RECALL_COOLDOWN] = {
            Bar = 0,
            Order = 30,
            Autohide = true,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_FENCE_TRANSACTIONS] = {
            Bar = 0,
            Order = 31,
            SoundWhenOver = false,
            SoundWhenOverSound = "Dual Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 85,
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            Autohide = false,
            Cat = 12
        },
        [BS.W_ZONE] = {
            Bar = 0,
            Order = 32,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_PLAYER_NAME] = {
            Bar = 0,
            Order = 33,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_RACE] = {
            Bar = 0,
            Order = 34,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_CLASS] = {
            Bar = 0,
            Order = 35,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_ALLIANCE] = {
            Bar = 0,
            Order = 36,
            NoValue = false,
            Cat = 3
        },
        [BS.W_LEADS] = {
            Bar = 0,
            Order = 37,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Autohide = true,
            Timer = true,
            HideDaysWhenZero = false,
            Cat = 2
        },
        [BS.W_SOUL_GEMS] = {
            Bar = 0,
            Order = 38,
            ColourValues = "c",
            UseSeparators = false,
            Cat = 9
        },
        [BS.W_FRIENDS] = {
            Bar = 0,
            Order = 39,
            ColourValues = "c",
            Announce = false,
            HideLimit = false,
            Cat = 11
        },
        [BS.W_MEMORY] = {
            Bar = 0,
            Order = 40,
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 450,
            DangerValue = 600,
            Precision = 1,
            UpdateFrequency = 5,
            Cat = 4
        },
        [BS.W_SKYSHARDS] = {
            Bar = 0,
            Order = 41,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_SKILL_POINTS] = {
            Bar = 0,
            Order = 42,
            ColourValues = "c",
            Autohide = true,
            Colour = {0, 1, 0, 1},
            Cat = 3
        },
        [BS.W_WRITS_SURVEYS] = {
            Bar = 0,
            Order = 43,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_FENCE_RESET] = {
            Bar = 0,
            Order = 44,
            HideSeconds = false,
            Timer = true,
            Autohide = true,
            Cat = 12
        },
        [BS.W_ENDEAVOUR_PROGRESS] = {
            Bar = 0,
            Order = 45,
            Progress = true,
            HideWhenComplete = false,
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_TROPHY_VAULT_KEYS] = {
            Bar = 0,
            Order = 46,
            ColourValues = "c",
            Autohide = true,
            Cat = 9
        },
        [BS.W_LOCKPICKS] = {
            Bar = 0,
            Order = 47,
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 50,
            DangerValue = 10,
            Cat = 9
        },
        [BS.W_LAUNDER_TRANSACTIONS] = {
            Bar = 0,
            Order = 48,
            SoundWhenOver = false,
            SoundWhenOverSound = "Dual Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 85,
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            Autohide = false,
            Cat = 12
        },
        [BS.W_SPEED] = {
            Bar = 0,
            Order = 49,
            ColourValues = "c",
            Units = "mph",
            ShowPercent = false,
            Cat = 3
        },
        [BS.W_CRAFTING_DAILIES] = {
            Bar = 0,
            Order = 50,
            Cat = 6
        },
        [BS.W_GUILD_FRIENDS] = {
            Bar = 0,
            Order = 51,
            ColourValues = "c",
            Announce = false,
            HideLimit = false,
            Cat = 11
        },
        [BS.W_DAILY_ENDEAVOUR_TIME] = {
            Bar = 0,
            Order = 52,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = true,
            Cat = 2
        },
        [BS.W_WEEKLY_ENDEAVOUR_TIME] = {
            Bar = 0,
            Order = 53,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 48,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = false,
            Cat = 2
        },
        [BS.W_COMPANION_LEVEL] = {
            Bar = 0,
            Order = 54,
            ColourValues = "c",
            Autohide = true,
            ShowXPPC = true,
            HideWhenMaxLevel = false,
            Cat = 5
        },
        [BS.W_TRIBUTE_CLUB_RANK] = {
            Bar = 0,
            Order = 55,
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_PLAYER_LEVEL] = {
            Bar = 0,
            Order = 56,
            ColourValues = "c",
            Autohide = true,
            Cat = 3
        },
        [BS.W_ACHIEVEMENT_POINTS] = {
            Bar = 0,
            Order = 57,
            ColourValues = "c",
            ShowPercent = false,
            Cat = 2
        },
        [BS.W_PLEDGES_TIME] = {
            Bar = 0,
            Order = 58,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = false,
            Cat = 2
        },
        [BS.W_SHADOWY_VENDOR_TIME] = {
            Bar = 0,
            Order = 59,
            HideSeconds = false,
            Timer = true,
            Cat = 2
        },
        [BS.W_LFG_TIME] = {
            Bar = 0,
            Order = 60,
            HideSeconds = false,
            Timer = true,
            Cat = 2
        },
        [BS.W_CRAFTING_DAILY_TIME] = {
            Bar = 0,
            Order = 61,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = true,
            Cat = 6
        },
        [BS.W_WATCHED_ITEMS] = {
            Bar = 0,
            Order = 62,
            ColourValues = "c",
            Announce = false,
            [BS.PERFECT_ROE] = true,
            [BS.POTENT_NIRNCRUX] = true,
            Cat = 9
        },
        [BS.W_TAMRIEL_TIME] = {
            Bar = 0,
            Order = 63,
            ColourValues = "c",
            Requires = "LibClockTST",
            Cat = 4
        },
        [BS.W_ACTIVE_BAR] = {
            Bar = 0,
            Order = 64,
            Cat = 1
        },
        [BS.W_DPS] = {
            Bar = 0,
            Order = 65,
            UseSeparators = false,
            ColourValues = "c",
            Requires = "LibCombat",
            Cat = 3
        },
        [BS.W_LOREBOOKS] = {
            Bar = 0,
            Order = 66,
            ColourValues = "c",
            ShowCategory = GetLoreCategoryInfo(1),
            Cat = 2
        },
        [BS.W_RECIPES] = {
            Bar = 0,
            Order = 67,
            ColourValues = "c",
            Cat = 6
        },
        [BS.W_RANDOM_MEMENTO] = {
            Bar = 0,
            Order = 68,
            Print = true,
            Cat = 9
        },
        [BS.W_RANDOM_PET] = {
            Bar = 0,
            Order = 69,
            Print = true,
            Cat = 9
        },
        [BS.W_RANDOM_MOUNT] = {
            Bar = 0,
            Order = 70,
            Print = true,
            Cat = 9
        },
        [BS.W_RANDOM_EMOTE] = {
            Bar = 0,
            Order = 71,
            Print = true,
            Cat = 9
        },
        [BS.W_CONTAINERS] = {
            Bar = 0,
            Order = 72,
            Autohide = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_TREASURE] = {
            Bar = 0,
            Order = 73,
            Autohide = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_RANDOM_DUNGEON] = {
            Bar = 0,
            Order = 74,
            Autohide = false,
            Cat = 2
        },
        [BS.W_PLAYER_LOCATION] = {
            Bar = 0,
            Order = 75,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_RANDOM_BATTLEGROUND] = {
            Bar = 0,
            Order = 76,
            Autohide = false,
            Cat = 2
        },
        [BS.W_RANDOM_TRIBUTE] = {
            Bar = 0,
            Order = 77,
            Autohide = false,
            Cat = 2
        },
        [BS.W_PLAYER_EXPERIENCE] = {
            Bar = 0,
            Order = 78,
            UseSeparators = false,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_UNKNOWN_WRIT_MOTIFS] = {
            Bar = 0,
            Order = 79,
            Autohide = false,
            ColourValues = "c",
            Requires = "LibCharacterKnowledge",
            Cat = 6
        },
        [BS.W_FURNISHINGS] = {
            Bar = 0,
            Order = 80,
            Autohide = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_COMPANION_GEAR] = {
            Bar = 0,
            Order = 81,
            Autohide = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_MUSEUM] = {
            Bar = 0,
            Order = 82,
            Autohide = false,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_EQUIPPED_POISON] = {
            Bar = 0,
            Order = 83,
            Autohide = false,
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 50,
            DangerValue = 10,
            Cat = 9
        },
        [BS.W_VAMPIRISM] = {
            Bar = 0,
            Order = 84,
            Autohide = true,
            ColourValues = "c",
            Cat = 3
        },
        [BS.W_VAMPIRISM_TIMER] = {
            Bar = 0,
            Order = 85,
            Autohide = true,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            WarningValue = 10,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            Timer = true,
            Cat = 3
        },
        [BS.W_VAMPIRISM_FEED_TIMER] = {
            Bar = 0,
            Order = 86,
            Autohide = true,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            WarningValue = 10,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            Timer = true,
            HideDaysWhenZero = false,
            Cat = 3
        },
        [BS.W_FRAGMENTS] = {
            Bar = 0,
            Order = 87,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_RUNEBOXES] = {
            Bar = 0,
            Order = 88,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_RECIPE_WATCH] = {
            Bar = 0,
            Order = 89,
            Autohide = false,
            Announce = true,
            ColourValues = "c",
            Cat = 9
        },
        [BS.W_CHESTS_FOUND] = {
            Bar = 0,
            Order = 90,
            ColourValues = "c",
            Autohide = false,
            Cat = 2
        },
        [BS.W_SHALIDORS_LIBRARY] = {
            Bar = 0,
            Order = 91,
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_CRAFTING_MOTIFS] = {
            Bar = 0,
            Order = 92,
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_DAILY_PROGRESS] = {
            Bar = 0,
            Order = 93,
            Progress = true,
            HideWhenComplete = false,
            ColourValues = "c",
            Cat = 2
        },
        [BS.W_WEAPON_CHARGE] = {
            Bar = 0,
            Order = 94,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 25,
            Cat = 9
        },
        [BS.W_BASTIAN] = {
            Bar = 0,
            Order = 95,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_MIRRI] = {
            Bar = 0,
            Order = 96,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_EMBER] = {
            Bar = 0,
            Order = 97,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_ISOBEL] = {
            Bar = 0,
            Order = 98,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_SHARP] = {
            Bar = 0,
            Order = 99,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_AZANDAR] = {
            Bar = 0,
            Order = 100,
            ColourValues = "c",
            Cat = 5
        },
        [BS.W_EZABI] = {
            Bar = 0,
            Order = 101,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_GHRASHAROG] = {
            Bar = 0,
            Order = 102,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_GILADIL] = {
            Bar = 0,
            Order = 103,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_PIRHARRI] = {
            Bar = 0,
            Order = 104,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_TYTHIS] = {
            Bar = 0,
            Order = 105,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_NUZHIMEH] = {
            Bar = 0,
            Order = 106,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_ALLARIA] = {
            Bar = 0,
            Order = 107,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_CASSUS] = {
            Bar = 0,
            Order = 108,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_FEZEZ] = {
            Bar = 0,
            Order = 109,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_BARON] = {
            Bar = 0,
            Order = 110,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_FACTOTUM] = {
            Bar = 0,
            Order = 111,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_FACTOTUM2] = {
            Bar = 0,
            Order = 112,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_ADERENE] = {
            Bar = 0,
            Order = 113,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_ZUQOTH] = {
            Bar = 0,
            Order = 114,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_HOARFROST] = {
            Bar = 0,
            Order = 115,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_PYROCLAST] = {
            Bar = 0,
            Order = 116,
            ColourValues = "c",
            Cat = 13
        },
        [BS.W_PEDDLER] = {
            Bar = 0,
            Order = 117,
            ColourValues = "c",
            Cat = 13
        }
    }
}

if (_G.CURT_ENDLESS_DUNGEON) then
    BS.Defaults.Controls[BS.W_ARCHIVAL_FRAGMENTS] = {
        Bar = 0,
        Order = 118,
        UseSeparators = false,
        ColourValues = "c",
        Cat = 7
    }
end