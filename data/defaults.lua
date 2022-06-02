local x, y = GuiRoot:GetCenter()

_G.BarSteward = {
    Name = "BarSteward",
    Defaults = {
        Movable = true,
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
                ValueSide = GetString(_G.BARSTEWARD_RIGHT)
            }
        },
        Controls = {
            [1] = {
                Bar = 1,
                Order = 1,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
            }, -- time
            [2] = {Bar = 1, Order = 2, SoundWhenEquals = false}, -- alliance points
            [3] = {Bar = 0, Order = 3}, -- crown gems
            [4] = {Bar = 0, Order = 4}, -- crowns
            [5] = {
                Bar = 1,
                Order = 5,
                ShowPercent = false,
                SoundWhenEquals = false,
                SoundWhenOver = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
                SoundWhenOverSound = "Duel Forfeit"
            }, -- event tickets
            [6] = {Bar = 1, Order = 6}, -- gold
            [7] = {
                Bar = 1,
                Order = 7,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
            }, -- seals of endeavour
            [8] = {
                Bar = 1,
                Order = 8,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
            }, -- tel var stones
            [9] = {Bar = 0, Order = 9, ShowPercent = false}, -- transmute crystals
            [10] = {
                Bar = 1,
                Order = 10,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
            }, -- undaunted keys
            [11] = {Bar = 1, Order = 11}, -- writ vouchers
            [12] = {Bar = 1, Order = 12, ShowPercent = true, SoundWhenOver = false, SoundWhenOverSound = "Duel Forfeit"}, -- bag space
            [13] = {Bar = 1, Order = 13, ShowPercent = true, SoundWhenOver = false, SoundWhenOverSound = "Duel Forfeit"}, -- bank space
            [14] = {Bar = 0, Order = 14}, -- fps
            [15] = {Bar = 1, Order = 15}, -- latency
            [16] = {Bar = 1, Order = 16, Autohide = true}, -- blacksmithing
            [17] = {Bar = 1, Order = 17, Autohide = true}, -- woodowrking
            [18] = {Bar = 1, Order = 18, Autohide = true}, -- clothing
            [19] = {Bar = 1, Order = 19, Autohide = true}, -- jewel crafting
            [20] = {Bar = 1, Order = 20, Autohide = true}, -- item repair cost
            [21] = {Bar = 1, Order = 21, Autohide = true}, -- mount training
            [22] = {Bar = 1, Order = 22, Autohide = true}, -- companion rapport
            [23] = {
                Bar = 1,
                Order = 23,
                Autohide = true,
                SoundWhenEquals = false,
                SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
            }, -- champion points
            [24] = {Bar = 0, Order = 24, Autohide = true}, -- mundus stone
            [25] = {Bar = 0, Order = 25, SoundWhenUnder = false, SoundWhenUnderSound = "Duel Forfeit"}, -- durability
            [26] = {Bar = 0, Order = 26}, -- daily endeavour progress
            [27] = {Bar = 0, Order = 27}, -- weekly endeavour progress
            [28] = {Bar = 0, Order = 28, SoundWhenUnder = false, SoundWhenUnderSound = "Duel Forfeit"}, -- repair kit count
            [29] = {Bar = 0, Order = 29, Autohide = true}, -- stolen item count
            [30] = {Bar = 0, Order = 30, Autohide = true} -- recall cooldown
        },
        TimeFormat24 = "HH:m:s",
        TimeFormat12 = "hh:m:s",
        TimeType = GetString(_G.BARSTEWARD_24)
    }
}
