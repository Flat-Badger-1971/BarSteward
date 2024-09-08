--[[
    c - default colour
    okv, okc - ok value, ok colour
    wv, wc - warning value, warning colour
    dv, dc - danger value, danger colour
]]
local x, y = GuiRoot:GetCenter()
local BS = _G.BarSteward
local cat = BS.CATNAMES

BS.Defaults = {
    BackBarIcon = "/esoui/art/tradinghouse/tradinghouse_weapons_1h_sword_up.dds",
    Categories = true,
    CategoriesCount = true,
    DefaultCombatColour = {0.3686274588, 0, 0, 1},
    DefaultColour = {(249 / 255), (249 / 255), (249 / 255), 1},
    DefaultDangerColour = {(204 / 255), 0, 0, 1},
    DefaultMaxColour = {1, 0.5, 0, 1},
    DefaultWarningColour = {1, 1, 0, 1},
    DefaultOkColour = {0, 1, 0, 1},
    DungeonInfo = {IsInDungeon = false, ChestCount = 0, PreviousChest = {x = 0, y = 0}},
    FishingLoot = {},
    Font = "Default",
    FontSize = 18,
    GridSize = 10,
    HideDuringCombat = false,
    IconSize = 32,
    MainBarIcon = "/esoui/art/tradinghouse/category_u30_equipment_up.dds",
    Movable = false,
    SnapToGrid = false,
    TimeFormat12 = "hh:m",
    TimeFormat24 = "HH:m",
    TimeType = GetString(_G.BARSTEWARD_24),
    VisibleGridSize = 65,
    Bars = {
        [1] = {
            Anchor = GetString(_G.BARSTEWARD_MIDDLE),
            Backdrop = {
                Show = true,
                Colour = {0.23, 0.23, 0.23, 0.7}
            },
            Name = GetString(_G.BARSTEWARD_MAIN_BAR),
            NudgeCompass = false,
            Orientation = GetString(_G.BARSTEWARD_HORIZONTAL),
            Position = {X = x, Y = y},
            Scale = 1,
            TooltipAnchor = GetString(_G.BARSTEWARD_BOTTOM),
            ValueSide = GetString(_G.BARSTEWARD_RIGHT)
        }
    },
    Controls = {
        [BS.W_TIME] = {
            Bar = 1,
            Cat = cat.Client,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
        },
        [BS.W_ALLIANCE_POINTS] = {
            Bar = 1,
            Cat = cat.Currency,
            PvPOnly = false,
            SoundWhenEquals = false,
            UseSeparators = false
        },
        [BS.W_CROWN_GEMS] = {
            Cat = cat.Currency,
            UseSeparators = false
        },
        [BS.W_CROWNS] = {
            Cat = cat.Currency,
            UseSeparators = false
        },
        [BS.W_EVENT_TICKETS] = {
            Announce = false,
            Bar = 1,
            Cat = cat.Currency,
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
            Cat = cat.Currency,
            UseSeparators = false
        },
        [BS.W_SEALS_OF_ENDEAVOUR] = {
            Bar = 1,
            Cat = cat.Currency,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_TELVAR_STONES] = {
            Bar = 1,
            Cat = cat.Currency,
            PvPOnly = false,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_TRANSMUTE_CRYSTALS] = {
            Cat = cat.Currency,
            ColourValues = "c,wv,wc,dv,dc,mv,mc",
            DangerValue = 50,
            HideLimit = false,
            Invert = false,
            ShowPercent = false,
            WarningValue = 200
        },
        [BS.W_UNDAUNTED_KEYS] = {
            Bar = 1,
            Cat = cat.Currency,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare"
        },
        [BS.W_WRIT_VOUCHERS] = {
            Bar = 1,
            Cat = cat.Currency,
            UseSeparators = false
        },
        [BS.W_BAG_SPACE] = {
            Announce = false,
            Bar = 1,
            Cat = cat.Inventory,
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
            Cat = cat.Inventory,
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
            Cat = cat.Client
        },
        [BS.W_LATENCY] = {
            Bar = 1,
            Cat = cat.Client,
            ColourValues = "c,wv,wc,dc,dv",
            DangerValue = 300,
            FixedWidth = true,
            WarningValue = 150
        },
        [BS.W_BLACKSMITHING] = {
            Autohide = true,
            Bar = 1,
            Cat = cat.Crafting,
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
            Cat = cat.Crafting,
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
            Cat = cat.Crafting,
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
            Cat = cat.Crafting,
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
            Cat = cat.Inventory,
            UseSeparators = false
        },
        [BS.W_MOUNT_TRAINING] = {
            Bar = 1,
            Cat = cat.Riding,
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
            Cat = cat.Companions,
            ColourValues = ""
        },
        [BS.W_CHAMPION_POINTS] = {
            Autohide = true,
            Bar = 1,
            Cat = cat.Character,
            SoundWhenEquals = false,
            SoundWhenEqualsSound = "Daily Login Reward Claim Fanfare",
            UseSeparators = false
        },
        [BS.W_MUNDUS_STONE] = {
            Autohide = true,
            Cat = cat.Character,
            ColourValues = "c,dc"
        },
        [BS.W_DURABILITY] = {
            Cat = cat.Inventory,
            ColourValues = "okc,okv,dc,dv,wc",
            DangerValue = 15,
            OkValue = 75,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            Units = "%"
        },
        [BS.W_DAILY_ENDEAVOURS] = {
            Cat = cat.Activities,
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_WEEKLY_ENDEAVOURS] = {
            Cat = cat.Activities,
            HideLimit = false,
            HideWhenCompleted = false
        },
        [BS.W_REPAIRS_KITS] = {
            Cat = cat.Inventory,
            ColourValues = "okc,dv,dc,wv,wc",
            DangerValue = 6,
            SoundWhenUnder = false,
            SoundWhenUnderSound = "Duel Forfeit",
            WarningValue = 11
        },
        [BS.W_STOLEN_ITEMS] = {
            Autohide = true,
            Cat = cat.Thievery
        },
        [BS.W_RECALL_COOLDOWN] = {
            Autohide = true,
            Cat = cat.Character
        },
        [BS.W_FENCE_TRANSACTIONS] = {
            Autohide = false,
            Cat = cat.Thievery,
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
            Cat = cat.Character
        },
        [BS.W_PLAYER_NAME] = {
            Cat = cat.Character,
            ShowClassIcon = true
        },
        [BS.W_RACE] = {
            Cat = cat.Character
        },
        [BS.W_CLASS] = {
            Cat = cat.Character
        },
        [BS.W_ALLIANCE] = {
            Cat = cat.Character,
            ColourValues = ""
        },
        [BS.W_LEADS] = {
            Autohide = true,
            Cat = cat.Activities,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_SOUL_GEMS] = {
            Cat = cat.Inventory,
            UseSeparators = false
        },
        [BS.W_FRIENDS] = {
            Announce = false,
            Cat = cat.Social,
            HideLimit = false
        },
        [BS.W_MEMORY] = {
            Cat = cat.Client,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 600,
            Precision = 1,
            UpdateFrequency = 5,
            WarningValue = 450
        },
        [BS.W_SKYSHARDS] = {
            Cat = cat.Character
        },
        [BS.W_SKILL_POINTS] = {
            Autohide = true,
            Cat = cat.Character,
            Colour = {0, 1, 0, 1}
        },
        [BS.W_WRITS_SURVEYS] = {
            Cat = cat.Inventory
        },
        [BS.W_FENCE_RESET] = {
            Autohide = true,
            Cat = cat.Thievery,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_ENDEAVOUR_PROGRESS] = {
            Cat = cat.Activities,
            HideWhenComplete = false,
            Progress = true
        },
        [BS.W_TROPHY_VAULT_KEYS] = {
            Autohide = true,
            Cat = cat.Inventory
        },
        [BS.W_LOCKPICKS] = {
            Cat = cat.Inventory,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 50
        },
        [BS.W_LAUNDER_TRANSACTIONS] = {
            Autohide = false,
            Cat = cat.Thievery,
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
            Cat = cat.Character,
            ShowPercent = false,
            Units = "mph"
        },
        [BS.W_CRAFTING_DAILIES] = {
            Autohide = false,
            Cat = cat.Crafting,
            ColourValues = ""
        },
        [BS.W_GUILD_FRIENDS] = {
            Announce = false,
            Cat = cat.Social,
            HideLimit = false
        },
        [BS.W_DAILY_ENDEAVOUR_TIME] = {
            Cat = cat.Activities,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideDaysWhenZero = true,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_WEEKLY_ENDEAVOUR_TIME] = {
            Cat = cat.Activities,
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
            Cat = cat.Companions,
            HideWhenMaxLevel = false,
            ShowXPPC = true
        },
        [BS.W_TRIBUTE_CLUB_RANK] = {
            Cat = cat.Activities
        },
        [BS.W_PLAYER_LEVEL] = {
            Autohide = true,
            Cat = cat.Character
        },
        [BS.W_ACHIEVEMENT_POINTS] = {
            Cat = cat.Activities,
            ShowPercent = false
        },
        [BS.W_PLEDGES_TIME] = {
            Cat = cat.Activities,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideDaysWhenZero = false,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 6
        },
        [BS.W_SHADOWY_VENDOR_TIME] = {
            Cat = cat.Activities,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_LFG_TIME] = {
            Cat = cat.Activities,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_CRAFTING_DAILY_TIME] = {
            Cat = cat.Crafting,
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
            Cat = cat.Inventory,
            [BS.PERFECT_ROE] = true,
            [BS.POTENT_NIRNCRUX] = true
        },
        [BS.W_TAMRIEL_TIME] = {
            Cat = cat.Client,
            Requires = "LibClockTST"
        },
        [BS.W_ACTIVE_BAR] = {
            Cat = cat.Abilities,
            ColourValues = ""
        },
        [BS.W_DPS] = {
            Cat = cat.Character,
            Requires = "LibCombat",
            UseSeparators = false
        },
        [BS.W_LOREBOOKS] = {
            Cat = cat.Activities,
            ShowCategory = ZO_CachedStrFormat("<<C:1>>", GetLoreCategoryInfo(1))
        },
        [BS.W_RECIPES] = {
            Cat = cat.Crafting
        },
        [BS.W_RANDOM_MEMENTO] = {
            Cat = cat.Inventory,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_PET] = {
            Cat = cat.Inventory,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_MOUNT] = {
            Cat = cat.Inventory,
            ColourValues = "",
            Print = true
        },
        [BS.W_RANDOM_EMOTE] = {
            Cat = cat.Inventory,
            ColourValues = "",
            Print = true
        },
        [BS.W_CONTAINERS] = {
            Autohide = false,
            Cat = cat.Inventory
        },
        [BS.W_TREASURE] = {
            Autohide = false,
            Cat = cat.Inventory
        },
        [BS.W_RANDOM_DUNGEON] = {
            Autohide = false,
            Cat = cat.Activities,
            ColourValues = ""
        },
        [BS.W_PLAYER_LOCATION] = {
            Cat = cat.Character,
            PvPOnly = false
        },
        [BS.W_RANDOM_BATTLEGROUND] = {
            Autohide = false,
            Cat = cat.Activities,
            ColourValues = ""
        },
        [BS.W_RANDOM_TRIBUTE] = {
            Autohide = false,
            Cat = cat.Activities,
            ColourValues = ""
        },
        [BS.W_PLAYER_EXPERIENCE] = {
            Cat = cat.Character,
            ShowPercent = false,
            UseSeparators = false
        },
        [BS.W_UNKNOWN_WRIT_MOTIFS] = {
            Autohide = false,
            Cat = cat.Crafting,
            Requires = "LibCharacterKnowledge"
        },
        [BS.W_FURNISHINGS] = {
            Cat = cat.Inventory,
            Autohide = false
        },
        [BS.W_COMPANION_GEAR] = {
            Cat = cat.Inventory,
            Autohide = false
        },
        [BS.W_MUSEUM] = {
            Cat = cat.Inventory,
            Autohide = false
        },
        [BS.W_EQUIPPED_POISON] = {
            Autohide = false,
            Cat = cat.Inventory,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 50
        },
        [BS.W_VAMPIRISM] = {
            Autohide = true,
            Cat = cat.Character
        },
        [BS.W_VAMPIRISM_TIMER] = {
            Autohide = true,
            Cat = cat.Character,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_VAMPIRISM_FEED_TIMER] = {
            Autohide = true,
            Cat = cat.Character,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 5,
            HideDaysWhenZero = false,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_FRAGMENTS] = {
            Cat = cat.Inventory
        },
        [BS.W_RUNEBOXES] = {
            Cat = cat.Inventory
        },
        [BS.W_RECIPE_WATCH] = {
            Announce = true,
            Autohide = false,
            Cat = cat.Inventory
        },
        [BS.W_CHESTS_FOUND] = {
            Autohide = false,
            Cat = cat.Activities
        },
        [BS.W_SHALIDORS_LIBRARY] = {
            Cat = cat.Activities
        },
        [BS.W_CRAFTING_MOTIFS] = {
            Cat = cat.Activities
        },
        [BS.W_DAILY_PROGRESS] = {
            Cat = cat.Activities,
            HideWhenComplete = false,
            Progress = true
        },
        [BS.W_WEAPON_CHARGE] = {
            Cat = cat.Inventory,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 10,
            WarningValue = 25
        },
        [BS.W_BASTIAN] = {
            Cat = cat.Companions
        },
        [BS.W_MIRRI] = {
            Cat = cat.Companions
        },
        [BS.W_EMBER] = {
            Cat = cat.Companions
        },
        [BS.W_ISOBEL] = {
            Cat = cat.Companions
        },
        [BS.W_SHARP] = {
            Cat = cat.Companions
        },
        [BS.W_AZANDAR] = {
            Cat = cat.Companions
        },
        [BS.W_EZABI] = {
            Cat = cat.Assistants
        },
        [BS.W_GHRASHAROG] = {
            Cat = cat.Assistants
        },
        [BS.W_GILADIL] = {
            Cat = cat.Assistants
        },
        [BS.W_PIRHARRI] = {
            Cat = cat.Assistants
        },
        [BS.W_TYTHIS] = {
            Cat = cat.Assistants
        },
        [BS.W_NUZHIMEH] = {
            Cat = cat.Assistants
        },
        [BS.W_ALLARIA] = {
            Cat = cat.Assistants
        },
        [BS.W_CASSUS] = {
            Cat = cat.Assistants
        },
        [BS.W_FEZEZ] = {
            Cat = cat.Assistants
        },
        [BS.W_BARON] = {
            Cat = cat.Assistants
        },
        [BS.W_FACTOTUM] = {
            Cat = cat.Assistants
        },
        [BS.W_FACTOTUM2] = {
            Cat = cat.Assistants
        },
        [BS.W_ADERENE] = {
            Cat = cat.Assistants
        },
        [BS.W_ZUQOTH] = {
            Cat = cat.Assistants
        },
        [BS.W_HOARFROST] = {
            Cat = cat.Assistants
        },
        [BS.W_PYROCLAST] = {
            Cat = cat.Assistants
        },
        [BS.W_PEDDLER] = {
            Cat = cat.Assistants
        },
        [BS.W_ARCHIVAL_FRAGMENTS] = {
            UseSeparators = false,
            Cat = cat.Currency
        },
        [BS.W_ARCHIVE_PORT] = {
            Cat = cat.InfiniteArchive
        },
        [BS.W_INFINITE_ARCHIVE_PROGRESS] = {
            Autohide = false,
            Cat = cat.InfiniteArchive,
            Progress = true
        },
        [BS.W_INFINITE_ARCHIVE_SCORE] = {
            Autohide = false,
            Cat = cat.InfiniteArchive
        },
        [BS.W_DRINWETH] = {
            Cat = cat.Assistants
        },
        [BS.W_FOOD_BUFF] = {
            Announce = false,
            Autohide = false,
            Cat = cat.Character,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_AP_BUFF] = {
            Announce = false,
            Autohide = false,
            Cat = cat.Character,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideSeconds = false,
            PvPOnly = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_XP_BUFF] = {
            Announce = false,
            Autohide = false,
            Cat = cat.Character,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 2,
            HideSeconds = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_MINUTES),
            WarningValue = 10
        },
        [BS.W_ALL_CRAFTING] = {
            Cat = cat.Crafting,
            Experimental = true,
            ColourValues = "okc,wv,wc,dv,dc",
            DangerValue = 24,
            HideSeconds = false,
            HideDaysWhenZero = false,
            Timer = true,
            Units = GetString(_G.BARSTEWARD_HOURS),
            WarningValue = 72
        },
        [BS.W_DAILY_COUNT] = {
            Cat = cat.Activities
        },
        [BS.W_PLAYER_STATUS] = {
            Cat = cat.Character
        },
        [BS.W_FISHING] = {
            Cat = cat.Activities
        },
        [BS.W_LFG_ROLE] = {
            Cat = cat.Character
        },
        [BS.W_TZOZABRAR] = {
            Cat = cat.Assistants
        },
        [BS.W_ERI] = {
            Cat = cat.Assistants
        },
        [BS.W_XYN] = {
            Cat = cat.Assistants
        },
        [BS.W_SCRIBING_INK] = {
            Cat = cat.Inventory,
            ColourValues = "okc,wv,wc,dv,wc",
            DangerValue = 10,
            WarningValue = 30
        },
        [BS.W_TITLE] = {
            Cat = cat.Character
        },
        [BS.W_BOUNTY] = {
            Autohide = true,
            Cat = cat.Character,
            ColourValues = "",
            HideSeconds = false,
            Timer = true
        },
        [BS.W_DAILY_REWARD] = {
            Cat = cat.Character,
            Experimental = true
        },
        [BS.W_DAILY_PLEDGES] = {
            Autohide = false,
            Cat = cat.Activities,
            Requires = "LibUndauntedPledges"
        },
        [BS.W_BOUNTY_AMOUNT] = {
            Autohide = false,
            Cat = cat.Character
        },
        [BS.W_ARMOURY_BUILD] = {
            Cat = cat.Character
        }
    }
}

BS.CommonDefaults = {
    CharacterList = {},
    dailyQuests = {},
    dailyQuestCount = {},
    FriendAnnounce = {},
    Gold = {},
    GuildFriendAnnounce = {},
    HouseBindings = {},
    HouseWidgets = {},
    OtherCurrencies = {},
    PreviousAnnounceTime = {},
    PreviousFriendTime = {},
    PreviousGuildFriendTime = {},
    Trackers = {},
    WatchedItems = {
        [BS.PERFECT_ROE] = true,
        [BS.POTENT_NIRNCRUX] = true
    },
    Updates = {}
}

function BS.CheckVars()
    local vars = BS.Defaults

    for widgetId, widgetData in pairs(vars.Controls) do
        if (not widgetData.Bar) then
            widgetData.Bar = 0
        end

        if (not widgetData.Order) then
            widgetData.Order = widgetId
        end

        if ((not widgetData.ColourValues or "") ~= "") then
            widgetData.ColourValues = "c"
        end

        if (not widgetData.NoIcon) then
            widgetData.NoIcon = false
        end

        if (not widgetData.NoValue) then
            widgetData.NoValue = false
        end
    end
end

do
    BS.CheckVars()
end
