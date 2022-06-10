local x, y = GuiRoot:GetCenter()
--[[
    c - default colour
    okv, okc - ok value, ok colour
    wv, wc - warning value, warning colour
    dv, dc - danger value, danger colour
]]
local BS = _G.BarSteward

BS.Defaults = {
    DefaultColour = {0.9, 0.9, 0.9, 1},
    DefaultDangerColour = {0.8, 0, 0, 1},
    DefaultWarningColour = {1, 1, 0, 1},
    DefaultOkColour = {0, 1, 0, 1},
    Movable = true,
    TimeFormat12 = "hh:m:s",
    TimeFormat24 = "HH:m:s",
    TimeType = GetString(_G.BARSTEWARD_24),
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
            DangerValue = 8
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
        [BS.W_TAL_VAR_STONES] = {
            Bar = 1,
            Order = 8,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            PvPOnly = false,
            UseSeparators = false,
            ColourValues = "c"
        },
        [BS.W_TRANSMUTE_CRYSTALS] = {Bar = 0, Order = 9, ShowPercent = false, ColourValues = "c"},
        [BS.W_UNDAUNTED_KEYS] = {
            Bar = 1,
            Order = 10,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            ColourValues = "c"
        },
        [BS.W_WRIT_VOUCHERS] = {Bar = 1, Order = 11, ColourValues = "c"},
        [BS.W_BAG_SPACE] = {
            Bar = 1,
            Order = 12,
            ShowPercent = true,
            SoundWhenOver = false,
            SoundWhenOverSound = "Duel Forfeit",
            Units = "%",
            ColourValues = "okc,wv,wc,dv,dc",
            WarningValue = 85,
            DangerValue = 95
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
            DangerValue = 95
        },
        [BS.W_FPS] = {Bar = 0, Order = 14, ColourValues = "c"},
        [BS.W_LATENCY] = {Bar = 1, Order = 15, ColourValues = "c"},
        [BS.W_BLACKSMITHING] = {
            Bar = 1,
            Order = 16,
            Autohide = true,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "c,dc"
        },
        [BS.W_WOODWORKING] = {
            Bar = 1,
            Order = 17,
            Autohide = true,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "c,dc"
        },
        [BS.W_CLOTHING] = {
            Bar = 1,
            Order = 18,
            Autohide = true,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "c,dc"
        },
        [BS.W_JEWELCRAFTING] = {
            Bar = 1,
            Order = 19,
            Autohide = true,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "c,dc"
        },
        [BS.W_REPAIR_COST] = {Bar = 1, Order = 20, Autohide = true, UseSeparators = false, ColourValues = "c"},
        [BS.W_MOUNT_TRAINING] = {
            Bar = 1,
            Order = 21,
            Autohide = true,
            HideSeconds = false,
            HideWhenComplete = false,
            ColourValues = "c,dc"
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
        [BS.W_DAILY_ENDEAVOURS] = {Bar = 0, Order = 26, ColourValues = "c"},
        [BS.W_WEEKLY_ENDEAVOURS] = {Bar = 0, Order = 27, ColourValues = "c"},
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
            DangerValue = 95
        },
        [BS.W_ZONE] = {Bar = 0, Order = 32, ColourValues = "c"},
        [BS.W_PLAYER_NAME] = {Bar = 0, Order = 33, ColourValues = "c"},
        [BS.W_RACE] = {Bar = 0, Order = 34, ColourValues = "c"},
        [BS.W_CLASS] = {Bar = 0, Order = 35, ColourValues = "c"},
        [BS.W_ALLIANCE] = {Bar = 0, Order = 36},
        [BS.W_LEADS] = {
            Bar = 1,
            Order = 37,
            ColourValues = "dv,dc",
            DangerValue = 300,
            Units = GetString(_G.BARSTEWARD_SECONDS),
            Autohide = true
        }
    }
}
