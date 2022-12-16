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
    DefaultColour = {0.9, 0.9, 0.9, 1},
    DefaultDangerColour = {0.8, 0, 0, 1},
    DefaultWarningColour = {1, 1, 0, 1},
    DefaultOkColour = {0, 1, 0, 1},
    Font = "Default",
    FontSize = 18,
    FriendAnnounce = {},
    Gold = {},
    GuildFriendAnnounce = {},
    MainBarIcon = "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    Movable = false,
    OtherCurrencies = {},
    PreviousFriendTime = {},
    PreviousGuildFriendTime = {},
    PreviousAnnounceTime = {},
    TimeFormat12 = "hh:m",
    TimeFormat24 = "HH:m",
    TimeType = GetString(_G.BARSTEWARD_24),
    Trackers = {},
    Updates = {},
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
            ColourValues = "c"
        },
        [BS.W_ALLIANCE_POINTS] = {
            Bar = 1,
            Order = 2,
            SoundWhenEquals = false,
            PvPOnly = false,
            UseSeparators = false,
            ColourValues = "c"
        },
        [BS.W_CROWN_GEMS] = {Bar = 0, Order = 3, UseSeparators = false, ColourValues = "c"},
        [BS.W_CROWNS] = {Bar = 0, Order = 4, UseSeparators = false, ColourValues = "c"},
        [BS.W_EVENT_TICKETS] = {
            Bar = 1,
            Order = 5,
            ShowPercent = false,
            SoundWhenEquals = false,
            SoundWhenOver = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            SoundWhenOverSound = "Duel Forfeit",
            ColourValues = "c,dv,dc",
            DangerValue = 8,
            Announce = false,
            HideLimit = false,
            NoLimitColour = false
        },
        [BS.W_GOLD] = {Bar = 1, Order = 6, UseSeparators = false, ColourValues = "c"},
        [BS.W_SEALS_OF_ENDEAVOUR] = {
            Bar = 1,
            Order = 7,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false,
            ColourValues = "c"
        },
        [BS.W_TELVAR_STONES] = {
            Bar = 1,
            Order = 8,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            PvPOnly = false,
            UseSeparators = false,
            ColourValues = "c"
        },
        [BS.W_TRANSMUTE_CRYSTALS] = {
            Bar = 0,
            Order = 9,
            ShowPercent = false,
            ColourValues = "c,wv,wc,dv,dc",
            WarningValue = 200,
            DangerValue = 50,
            HideLimit = false
        },
        [BS.W_UNDAUNTED_KEYS] = {
            Bar = 1,
            Order = 10,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            ColourValues = "c"
        },
        [BS.W_WRIT_VOUCHERS] = {Bar = 1, Order = 11, ColourValues = "c", UseSeparators = false},
        [BS.W_BAG_SPACE] = {
            Bar = 1,
            Order = 12,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 85,
            DangerValue = 95,
            Announce = false,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false
        },
        [BS.W_BANK_SPACE] = {
            Bar = 1,
            Order = 13,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 85,
            DangerValue = 95,
            HideLimit = false,
            NoLimitColour = false,
            ShowFreeSpace = false
        },
        [BS.W_FPS] = {Bar = 0, Order = 14, ColourValues = "c"},
        [BS.W_LATENCY] = {Bar = 1, Order = 15, ColourValues = "c,wv,wc,dc,dv"},
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
            HideDaysWhenZero = false
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
            HideDaysWhenZero = false
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
            HideDaysWhenZero = false
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
            HideDaysWhenZero = false
        },
        [BS.W_REPAIR_COST] = {Bar = 1, Order = 20, Autohide = true, UseSeparators = false, ColourValues = "c"},
        [BS.W_MOUNT_TRAINING] = {
            Bar = 1,
            Order = 21,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 3,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            HideWhenFullyUsed = false
        },
        [BS.W_RAPPORT] = {Bar = 1, Order = 22, Autohide = true},
        [BS.W_CHAMPION_POINTS] = {
            Bar = 1,
            Order = 23,
            Autohide = true,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false,
            ColourValues = "c"
        },
        [BS.W_MUNDUS_STONE] = {Bar = 0, Order = 24, Autohide = true, ColourValues = "c,dc"},
        [BS.W_DURABILITY] = {
            Bar = 0,
            Order = 25,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,okv,dc,dv,wc",
            OkValue = 75,
            DangerValue = 15
        },
        [BS.W_DAILY_ENDEAVOURS] = {
            Bar = 0,
            Order = 26,
            ColourValues = "c",
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_WEEKLY_ENDEAVOURS] = {
            Bar = 0,
            Order = 27,
            ColourValues = "c",
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_REPAIRS_KITS] = {
            Bar = 0,
            Order = 28,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            ColourValues = "okc,dv,dc,wv,wc",
            DangerValue = 6,
            WarningValue = 11
        },
        [BS.W_STOLEN_ITEMS] = {Bar = 0, Order = 29, Autohide = true, ColourValues = "c"},
        [BS.W_RECALL_COOLDOWN] = {Bar = 0, Order = 30, Autohide = true, ColourValues = "c"},
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
            Autohide = false
        },
        [BS.W_ZONE] = {Bar = 0, Order = 32, ColourValues = "c"},
        [BS.W_PLAYER_NAME] = {Bar = 0, Order = 33, ColourValues = "c"},
        [BS.W_RACE] = {Bar = 0, Order = 34, ColourValues = "c"},
        [BS.W_CLASS] = {Bar = 0, Order = 35, ColourValues = "c"},
        [BS.W_ALLIANCE] = {Bar = 0, Order = 36},
        [BS.W_LEADS] = {
            Bar = 0,
            Order = 37,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            WarningValue = 72,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Autohide = true,
            Timer = true,
            HideDaysWhenZero = false
        },
        [BS.W_SOUL_GEMS] = {Bar = 0, Order = 38, ColourValues = "c", UseSeparators = false},
        [BS.W_FRIENDS] = {
            Bar = 0,
            Order = 39,
            ColourValues = "c",
            Announce = false,
            HideLimit = false
        },
        [BS.W_MEMORY] = {
            Bar = 0,
            Order = 40,
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 450,
            DangerValue = 600,
            Precision = 1,
            UpdateFrequency = 5
        },
        [BS.W_SKYSHARDS] = {Bar = 0, Order = 41, ColourValues = "c"},
        [BS.W_SKILL_POINTS] = {Bar = 0, Order = 42, ColourValues = "c", Autohide = true, Colour = {0, 1, 0, 1}},
        [BS.W_WRITS_SURVEYS] = {Bar = 0, Order = 43, ColourValues = "c"},
        [BS.W_FENCE_RESET] = {
            Bar = 0,
            Order = 44,
            HideSeconds = false,
            Timer = true,
            Autohide = true
        },
        [BS.W_ENDEAVOUR_PROGRESS] = {Bar = 0, Order = 45, Progress = true, HideWhenComplete = false},
        [BS.W_TROPHY_VAULT_KEYS] = {Bar = 0, Order = 46, ColourValues = "c", Autohide = true},
        [BS.W_LOCKPICKS] = {Bar = 0, Order = 47, ColourValues = "okc,wv,wc,dv,dc", WarningValue = 50, DangerValue = 10},
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
            Autohide = false
        },
        [BS.W_SPEED] = {Bar = 0, Order = 49, ColourValues = "c", Units = "mph", ShowPercent = false},
        [BS.W_CRAFTING_DAILIES] = {Bar = 0, Order = 50},
        [BS.W_GUILD_FRIENDS] = {Bar = 0, Order = 51, ColourValues = "c", Announce = false, HideLimit = false},
        [BS.W_DAILY_ENDEAVOUR_TIME] = {
            Bar = 0,
            Order = 52,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = true
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
            HideDaysWhenZero = false
        },
        [BS.W_COMPANION_LEVEL] = {
            Bar = 0,
            Order = 54,
            ColourValues = "c",
            Autohide = true,
            ShowXPPC = true,
            HideWhenMaxLevel = false
        },
        [BS.W_TRIBUTE_CLUB_RANK] = {Bar = 0, Order = 55, ColourValues = "c"},
        [BS.W_PLAYER_LEVEL] = {Bar = 0, Order = 56, ColourValues = "c", Autohide = true},
        [BS.W_ACHIEVEMENT_POINTS] = {Bar = 0, Order = 57, ColourValues = "c", ShowPercent = false},
        [BS.W_PLEDGES_TIME] = {
            Bar = 0,
            Order = 58,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = false
        },
        [BS.W_SHADOWY_VENDOR_TIME] = {Bar = 0, Order = 59, HideSeconds = false, Timer = true},
        [BS.W_LFG_TIME] = {Bar = 0, Order = 60, HideSeconds = false, Timer = true},
        [BS.W_CRAFTING_DAILY_TIME] = {
            Bar = 0,
            Order = 61,
            HideSeconds = false,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            WarningValue = 6,
            Units = GetString(_G.BARSTEWARD_HOURS),
            Timer = true,
            HideDaysWhenZero = true
        },
        [BS.W_WATCHED_ITEMS] = {
            Bar = 0,
            Order = 62,
            ColourValues = "c",
            Announce = false,
            [BS.PERFECT_ROE] = true,
            [BS.POTENT_NIRNCRUX] = true
        },
        [BS.W_TAMRIEL_TIME] = {Bar = 0, Order = 63, ColourValues = "c"},
        [BS.W_ACTIVE_BAR] = {Bar = 0, Order = 64},
        [BS.W_DPS] = {Bar = 0, Order = 65, UseSeparators = false, ColourValues = "c"},
        [BS.W_LOREBOOKS] = {Bar = 0, Order = 66, ColourValues = "c", ShowCategory = GetLoreCategoryInfo(1)},
        [BS.W_RECIPES] = {Bar = 0, Order = 67, ColourValues = "c"},
        [BS.W_RANDOM_MEMENTO] = {Bar = 0, Order = 68, Print = true},
        [BS.W_RANDOM_PET] = {Bar = 0, Order = 69, Print = true},
        [BS.W_RANDOM_MOUNT] = {Bar = 0, Order = 70, Print = true},
        [BS.W_RANDOM_EMOTE] = {Bar = 0, Order = 71, Print = true},
        [BS.W_CONTAINERS] = {Bar = 0, Order = 72, Autohide = false, ColourValues = "c"},
        [BS.W_TREASURE] = {Bar = 0, Order = 73, Autohide = false, ColourValues = "c"},
        [BS.W_RANDOM_DUNGEON] = {Bar = 0, Order = 74, Autohide = false},
        [BS.W_PLAYER_LOCATION] = {Bar = 0, Order = 75, ColourValues = "c"}
    }
}
