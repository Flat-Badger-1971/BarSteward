local x, y = GuiRoot:GetCenter()
--[[
    c - default colour
    okv, okc - ok value, ok colour
    wv, wc - warning value, warning colour
    dv, dc - danger value, danger colour
]]
_G.BarSteward = {
    Name = "BarSteward",
    Defaults = {
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
            [1] = {
                Bar = 1,
                Order = 1,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                ColourValues = "c"
            }, -- time
            [2] = {
                Bar = 1,
                Order = 2,
                SoundWhenEquals = false,
                PvPOnly = false,
                UseSeparators = false,
                ColourValues = "c"
            }, -- alliance points
            [3] = {Bar = 0, Order = 3, UseSeparators = false, ColourValues = "c"}, -- crown gems
            [4] = {Bar = 0, Order = 4, UseSeparators = false, ColourValues = "c"}, -- crowns
            [5] = {
                Bar = 1,
                Order = 5,
                ShowPercent = false,
                SoundWhenEquals = false,
                SoundWhenOver = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                SoundWhenOverSound = "Duel Forfeit",
                ColourValues = "c,dv,dc",
                DangerValue = 8
            }, -- event tickets
            [6] = {Bar = 1, Order = 6, UseSeparators = false, ColourValues = "c"}, -- gold
            [7] = {
                Bar = 1,
                Order = 7,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                UseSeparators = false,
                ColourValues = "c"
            }, -- seals of endeavour
            [8] = {
                Bar = 1,
                Order = 8,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                PvPOnly = false,
                UseSeparators = false,
                ColourValues = "c"
            }, -- tel var stones
            [9] = {Bar = 0, Order = 9, ShowPercent = false, ColourValues = "c"}, -- transmute crystals
            [10] = {
                Bar = 1,
                Order = 10,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                ColourValues = "c"
            }, -- undaunted keys
            [11] = {Bar = 1, Order = 11, ColourValues = "c"}, -- writ vouchers
            [12] = {
                Bar = 1,
                Order = 12,
                ShowPercent = true,
                SoundWhenOver = false,
                SoundWhenOverSound = "Duel Forfeit",
                Units = "%",
                ColourValues = "okc,wv,wc,dv,dc",
                WarningValue = 85,
                DangerValue = 95
            }, -- bag space
            [13] = {
                Bar = 1,
                Order = 13,
                ShowPercent = true,
                SoundWhenOver = false,
                SoundWhenOverSound = "Duel Forfeit",
                Units = "%",
                ColourValues = "okc,wv,wc,dv,dc",
                WarningValue = 85,
                DangerValue = 95
            }, -- bank space
            [14] = {Bar = 0, Order = 14, ColourValues = "c"}, -- fps
            [15] = {Bar = 1, Order = 15, ColourValues = "c"}, -- latency
            [16] = {
                Bar = 1,
                Order = 16,
                Autohide = true,
                HideSeconds = false,
                HideWhenComplete = false,
                ColourValues = "c,dc"
            }, -- blacksmithing
            [17] = {
                Bar = 1,
                Order = 17,
                Autohide = true,
                HideSeconds = false,
                HideWhenComplete = false,
                ColourValues = "c,dc"
            }, -- woodowrking
            [18] = {
                Bar = 1,
                Order = 18,
                Autohide = true,
                HideSeconds = false,
                HideWhenComplete = false,
                ColourValues = "c,dc"
            }, -- clothing
            [19] = {
                Bar = 1,
                Order = 19,
                Autohide = true,
                HideSeconds = false,
                HideWhenComplete = false,
                ColourValues = "c,dc"
            }, -- jewel crafting
            [20] = {Bar = 1, Order = 20, Autohide = true, UseSeparators = false, ColourValues = "c"}, -- item repair cost
            [21] = {
                Bar = 1,
                Order = 21,
                Autohide = true,
                HideSeconds = false,
                HideWhenComplete = false,
                ColourValues = "c,dc"
            }, -- mount training
            [22] = {Bar = 1, Order = 22, Autohide = true}, -- companion rapport
            [23] = {
                Bar = 1,
                Order = 23,
                Autohide = true,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                UseSeparators = false,
                ColourValues = "c"
            }, -- champion points
            [24] = {Bar = 0, Order = 24, Autohide = true, ColourValues = "c,dc"}, -- mundus stone
            [25] = {
                Bar = 0,
                Order = 25,
                SoundWhenUnder = false,
                SoundWhenUnderSound = "Duel Forfeit",
                Units = "%",
                ColourValues = "okc,okv,dc,dv,wc",
                OkValue = 75,
                DangerValue = 15
            }, -- durability
            [26] = {Bar = 0, Order = 26, ColourValues = "c"}, -- daily endeavour progress
            [27] = {Bar = 0, Order = 27, ColourValues = "c"}, -- weekly endeavour progress
            [28] = {
                Bar = 0,
                Order = 28,
                SoundWhenUnder = false,
                SoundWhenUnderSound = "Duel Forfeit",
                ColourValues = "okc,dv,dc,wv,wc",
                DangerValue = 6,
                WarningValue =11
            }, -- repair kit count
            [29] = {Bar = 0, Order = 29, Autohide = true, ColourValues = "c"}, -- stolen item count
            [30] = {Bar = 0, Order = 30, Autohide = true, ColourValues = "c"}, -- recall cooldown
            [31] = {
                Bar = 0,
                Order = 31,
                SoundWhenOver = false,
                SoundWhenOverSound = "Dual Forfeit",
                Units = "%",
                ColourValues = "okc,wv,wc,dv,dc",
                WarningValue = 85,
                DangerValue = 95
            }, -- fence/launder transactions
            [32] = {Bar = 0, Order = 32, ColourValues = "c"}, -- current zone
            [33] = {Bar = 0, Order = 33, ColourValues = "c"}, -- player name
            [34] = {Bar = 0, Order = 34, ColourValues = "c"}, -- player race
            [35] = {Bar = 0, Order = 35, ColourValues = "c"}, -- player class
            [36] = {Bar = 0, Order = 36} -- player alliance
        }
    }
}
