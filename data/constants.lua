_G.BarSteward = {Name = "BarSteward"}

local BS = _G.BarSteward

-- linefeed character
BS.LF = string.char(10)

-- widgets
BS.W_TIME = 1
BS.W_ALLIANCE_POINTS = 2
BS.W_CROWN_GEMS = 3
BS.W_CROWNS = 4
BS.W_EVENT_TICKETS = 5
BS.W_GOLD = 6
BS.W_SEALS_OF_ENDEAVOUR = 7
BS.W_TELVAR_STONES = 8
BS.W_TRANSMUTE_CRYSTALS = 9
BS.W_UNDAUNTED_KEYS = 10
BS.W_WRIT_VOUCHERS = 11
BS.W_BAG_SPACE = 12
BS.W_BANK_SPACE = 13
BS.W_FPS = 14
BS.W_LATENCY = 15
BS.W_BLACKSMITHING = 16
BS.W_WOODWORKING = 17
BS.W_CLOTHING = 18
BS.W_JEWELCRAFTING = 19
BS.W_REPAIR_COST = 20
BS.W_MOUNT_TRAINING = 21
BS.W_RAPPORT = 22
BS.W_CHAMPION_POINTS = 23
BS.W_MUNDUS_STONE = 24
BS.W_DURABILITY = 25
BS.W_DAILY_ENDEAVOURS = 26
BS.W_WEEKLY_ENDEAVOURS = 27
BS.W_REPAIRS_KITS = 28
BS.W_STOLEN_ITEMS = 29
BS.W_RECALL_COOLDOWN = 30
BS.W_FENCE_TRANSACTIONS = 31
BS.W_ZONE = 32
BS.W_PLAYER_NAME = 33
BS.W_RACE = 34
BS.W_CLASS = 35
BS.W_ALLIANCE = 36
BS.W_LEADS = 37
BS.W_SOUL_GEMS = 38
BS.W_FRIENDS = 39
BS.W_MEMORY = 40
BS.W_SKYSHARDS = 41
BS.W_SKILL_POINTS = 42
BS.W_WRITS_SURVEYS = 43
BS.W_FENCE_RESET = 44
BS.W_ENDEAVOUR_PROGRESS = 45
BS.W_TROPHY_VAULT_KEYS = 46
BS.W_LOCKPICKS = 47
BS.W_LAUNDER_TRANSACTIONS = 48
BS.W_SPEED = 49
BS.W_CRAFTING_DAILIES = 50
BS.W_GUILD_FRIENDS = 51
BS.W_DAILY_ENDEAVOUR_TIME = 52
BS.W_WEEKLY_ENDEAVOUR_TIME = 53
BS.W_COMPANION_LEVEL = 54
BS.W_TRIBUTE_CLUB_RANK = 55
BS.W_PLAYER_LEVEL = 56
BS.W_ACHIEVEMENT_POINTS = 57
BS.W_PLEDGES_TIME = 58
BS.W_SHADOWY_VENDOR_TIME = 59
BS.W_LFG_TIME = 60
BS.W_CRAFTING_DAILY_TIME = 61
BS.W_WATCHED_ITEMS = 62
BS.W_TAMRIEL_TIME = 63
BS.W_ACTIVE_BAR = 64
BS.W_DPS = 65
BS.W_LOREBOOKS = 66
BS.W_RECIPES = 67
BS.W_RANDOM_MEMENTO = 68
BS.W_RANDOM_PET = 69
BS.W_RANDOM_MOUNT = 70
BS.W_RANDOM_EMOTE = 71
BS.W_CONTAINERS = 72
BS.W_TREASURE = 73
BS.W_RANDOM_DUNGEON = 74
BS.W_PLAYER_LOCATION = 75
BS.W_RANDOM_BATTLEGROUND = 76
BS.W_RANDOM_TRIBUTE = 77
BS.W_PLAYER_EXPERIENCE = 78
BS.W_UNKNOWN_WRIT_MOTIFS = 79
BS.W_FURNISHINGS = 80
BS.W_COMPANION_GEAR = 81
BS.W_MUSEUM = 82
BS.W_EQUIPPED_POISON = 83
BS.W_VAMPIRISM = 84
BS.W_VAMPIRISM_TIMER = 85
BS.W_VAMPIRISM_FEED_TIMER = 86
BS.W_FRAGMENTS = 87
BS.W_RUNEBOXES = 88
BS.W_RECIPE_WATCH = 89
BS.W_CHESTS_FOUND = 90
BS.W_SHALIDORS_LIBRARY = 91
BS.W_CRAFTING_MOTIFS = 92
BS.W_DAILY_PROGRESS = 93
BS.W_WEAPON_CHARGE = 94
BS.W_BASTIAN = 95
BS.W_MIRRI = 96
BS.W_EMBER = 97
BS.W_ISOBEL = 98
BS.W_SHARP = 99
BS.W_AZANDAR = 100
BS.W_EZABI = 101
BS.W_GHRASHAROG = 102
BS.W_GILADIL = 103
BS.W_PIRHARRI = 104
BS.W_TYTHIS = 105
BS.W_NUZHIMEH = 106
BS.W_ALLARIA = 107
BS.W_CASSUS = 108
BS.W_FEZEZ = 109
BS.W_BARON = 110
BS.W_FACTOTUM = 111
BS.W_FACTOTUM2 = 112
BS.W_ADERENE = 113
BS.W_ZUQOTH = 114
BS.W_HOARFROST = 115
BS.W_PYROCLAST = 116
BS.W_PEDDLER = 117
BS.W_ARCHIVAL_FRAGMENTS = 118
BS.W_ARCHIVE_PORT = 119
BS.W_INFINITE_ARCHIVE_PROGRESS = 120
BS.W_INFINITE_ARCHIVE_SCORE = 121
BS.W_DRINWETH = 122
BS.W_FOOD_BUFF = 123
BS.W_AP_BUFF = 124
BS.W_XP_BUFF = 125

BS.WRITS = {
    [_G.CRAFTING_TYPE_ALCHEMY] = {
        119696,
        110698,
        119699,
        119700,
        119701,
        119702,
        119703,
        119704,
        119705,
        119818,
        119819,
        119820
    },
    [_G.CRAFTING_TYPE_BLACKSMITHING] = {119563, 119680, 121527, 121529},
    [_G.CRAFTING_TYPE_CLOTHIER] = {119694, 119695, 121532, 121533},
    [_G.CRAFTING_TYPE_ENCHANTING] = {119564, 121528},
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = {138789, 138799, 153737, 153739},
    [_G.CRAFTING_TYPE_PROVISIONING] = {119693},
    [_G.CRAFTING_TYPE_WOODWORKING] = {119681, 119682, 121530, 121531}
}

BS.TROPHY_VAULT_KEYS = {
    [64491] = true,
    [64568] = true,
    [64572] = true,
    [64574] = true,
    [64576] = true,
    [64570] = true,
    [69404] = true,
    [69405] = true
}

BS.MUNDUS_STONES = {
    [13940] = true,
    [13943] = true,
    [13974] = true,
    [13975] = true,
    [13976] = true,
    [13977] = true,
    [13978] = true,
    [13979] = true,
    [13980] = true,
    [13981] = true,
    [13982] = true,
    [13984] = true,
    [13985] = true
}

BS.BAGICON = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds")
BS.BANKICON = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds")

-- scions check
local suffix = _G.CURT_ARCHIVAL_FORTUNES and "slug" or "otf"

BS.FONTS = {
    ["Default"] = "EsoUi/Common/Fonts/Univers57." .. suffix,
    ["Univers55"] = "EsoUi/Common/Fonts/Univers55." .. suffix,
    ["ESO Bold"] = "EsoUi/Common/Fonts/Univers67." .. suffix,
    ["Antique"] = "EsoUI/Common/Fonts/ProseAntiquePSMT." .. suffix,
    ["Handwritten"] = "EsoUI/Common/Fonts/Handwritten_Bold." .. suffix,
    ["Trajan"] = "EsoUI/Common/Fonts/TrajanPro-Regular." .. suffix,
    ["Futura"] = "EsoUI/Common/Fonts/FuturaStd-CondensedLight." .. suffix,
    ["Futura Bold"] = "EsoUI/Common/Fonts/FuturaStd-Condensed." .. suffix
}

BS.CRAFTING_SCENES = {"alchemy", "enchanting", "provisioner", "smithing"}
BS.BANKING_SCENES = {"bank", "guildBank", "houseBank"}
BS.INVENTORY_SCENES = {"inventory"}
BS.MAIL_SCENES = {"mailInbox", "mailSend"}
BS.SIEGE_SCENES = {"siegeBar", "siegeBarUI"}
BS.MENU_SCENES = {"gameMenuInGame", "mainMenuGamepad"}
BS.INTERACTING_SCENES = {"interact"}
BS.GUILDSTORE_SCENES = {"tradinghouse"}
BS.DEFAULT_SCENES = {"hud", "hudui"}
BS.SCENES = {"banking", "crafting", "default", "guildstore", "interacting", "inventory", "mail", "menu", "siege"}

BS.CRAFTING_ACHIEVEMENT_IDS = {
    [1145] = true,
    [2225] = true
}

BS.CRAFTING_ACHIEVEMENT = {
    [_G.CRAFTING_TYPE_ALCHEMY] = {achievementId = 1145, criterionIndex = 1, icon = "alchemist"},
    [_G.CRAFTING_TYPE_BLACKSMITHING] = {achievementId = 1145, criterionIndex = 2, icon = "smithy"},
    [_G.CRAFTING_TYPE_CLOTHIER] = {achievementId = 1145, criterionIndex = 3, icon = "clothier"},
    [_G.CRAFTING_TYPE_ENCHANTING] = {achievementId = 1145, criterionIndex = 4, icon = "enchanter"},
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = {achievementId = 2225, criterionIndex = 1, icon = "jewelrycrafting"},
    [_G.CRAFTING_TYPE_PROVISIONING] = {achievementId = 1145, criterionIndex = 5, icon = "inn"},
    [_G.CRAFTING_TYPE_WOODWORKING] = {achievementId = 1145, criterionIndex = 6, icon = "woodworker"}
}

BS.CRAFTING_DAILY = {
    [_G.CRAFTING_TYPE_ALCHEMY] = GetString(_G.BARSTEWARD_WRIT_ALCHEMY),
    [_G.CRAFTING_TYPE_BLACKSMITHING] = GetString(_G.BARSTEWARD_WRIT_BLACKSMITHING),
    [_G.CRAFTING_TYPE_CLOTHIER] = GetString(_G.BARSTEWARD_WRIT_CLOTHIER),
    [_G.CRAFTING_TYPE_ENCHANTING] = GetString(_G.BARSTEWARD_WRIT_ENCHANTING),
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = GetString(_G.BARSTEWARD_WRIT_JEWELLERY),
    [_G.CRAFTING_TYPE_PROVISIONING] = GetString(_G.BARSTEWARD_WRIT_PROVISIONING),
    [_G.CRAFTING_TYPE_WOODWORKING] = GetString(_G.BARSTEWARD_WRIT_WOODWORKING)
}

BS.PERFECT_ROE = 64222
BS.POTENT_NIRNCRUX = 56863

-- these are in the game code but don't appear to be available anywhere
BS.IGNORE_RECIPE = {
    [64470] = true, -- Recipe: Old Orsinium Bloop Soup
    [121098] = true, -- Blueprint: Common Campfire, Outdoor
    [126863] = true, -- Diagram: Dwarven Pipeline Cap, Sealed
    [132173] = true, -- Blueprint: Witches Brazier, Primitive Log
    [132179] = true -- Blueprint: Witches Totem, Antler Charms
}

BS.COLLAPSE = "buttons/large_leftdoublearrow_up"
BS.EXPAND = "buttons/large_rightdoublearrow_up"

BS.FADE_IN_TIME = 250
BS.FADE_OUT_TIME = 750

BS.CLICK = "miscellaneous/icon_lmb"

BS.DUNGEON = {
    [_G.LFG_ACTIVITY_DUNGEON] = "leveluprewards/levelup_dungeon_64",
    [_G.LFG_ACTIVITY_MASTER_DUNGEON] = "leveluprewards/levelup_veteran_dungeon_64"
}

BS.INELIGIBLE_ICON = "castbar/forbiddenaction"
BS.NORMAL_ICON = "ava/ava_hud_emblem_neutral"
BS.MAGIC_ICON = "progression/stamina_points_frame"
BS.ARCANE_ICON = "scrying/crystal_on"
BS.ARTIFACT_ICON = "battlegrounds/battlegrounds_teamicon_purple_64"
BS.LEGENDARY_ICON = "market/keyboard/esoplus_chalice_gold2_64"

BS.ITEM_COLOUR_ICON = {
    [_G.ITEM_DISPLAY_QUALITY_NORMAL] = BS.NORMAL_ICON,
    [_G.ITEM_DISPLAY_QUALITY_MAGIC] = BS.MAGIC_ICON,
    [_G.ITEM_DISPLAY_QUALITY_ARCANE] = BS.ARCANE_ICON,
    [_G.ITEM_DISPLAY_QUALITY_ARTIFACT] = BS.ARTIFACT_ICON,
    [_G.ITEM_DISPLAY_QUALITY_LEGENDARY] = BS.LEGENDARY_ICON,
    [_G.ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = BS.LEGENDARY_ICON
}

BS.BATTLEGROUND_ICON = {
    [_G.LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "icons/battleground_medal_murderballcarry_001",
    [_G.LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "icons/battleground_medal_murderballcarry_002",
    [_G.LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "icons/battleground_medal_murderballcarry_003"
}

BS.TRIBUTE_ICON = {
    [_G.LFG_ACTIVITY_TRIBUTE_CASUAL] = "icons/u34_tribute_quest3",
    [_G.LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "icons/u34_tribute_pvedaily30"
}

BS.FRIENDS_ICON = "/esoui/art/chatwindow/chat_friendsonline_up.dds"

-- reflects the number of bindings setup in ui/bindings.xml
BS.MAX_BINDINGS = 20

-- info from Writ Worthy
BS.WRIT_ITEM_TYPES = {
    [_G.ITEM_STYLE_CHAPTER_HELMETS] = {26, 35, 44},
    [_G.ITEM_STYLE_CHAPTER_GLOVES] = {34, 43, 52},
    [_G.ITEM_STYLE_CHAPTER_BOOTS] = {32, 41, 50},
    [_G.ITEM_STYLE_CHAPTER_LEGS] = {31, 40, 49},
    [_G.ITEM_STYLE_CHAPTER_CHESTS] = {28, 37, 46, 75},
    [_G.ITEM_STYLE_CHAPTER_BELTS] = {30, 39, 48},
    [_G.ITEM_STYLE_CHAPTER_SHOULDERS] = {29, 38, 47},
    [_G.ITEM_STYLE_CHAPTER_SWORDS] = {59, 67},
    [_G.ITEM_STYLE_CHAPTER_MACES] = {56, 69},
    [_G.ITEM_STYLE_CHAPTER_AXES] = {53, 68},
    [_G.ITEM_STYLE_CHAPTER_DAGGERS] = {62},
    [_G.ITEM_STYLE_CHAPTER_STAVES] = {71, 72, 73, 74},
    [_G.ITEM_STYLE_CHAPTER_SHIELDS] = {65},
    [_G.ITEM_STYLE_CHAPTER_BOWS] = {70}
}

BS.VAMPIRE_STAGES = {[135397] = 1, [135399] = 2, [135400] = 3, [135402] = 4, [135412] = 5}
BS.VAMPIRE_FEED = {[40359] = true}

BS.BACKGROUNDS = {
    [1] = "actionbar/quickslotbg",
    [2] = "announcewindow/blackfade",
    [3] = "antiquities/codex_missing_document",
    [4] = "antiquities/icon_backdrop",
    [5] = "interaction/conversation_textbg",
    [6] = "interaction/conversationwindow_overlay_important",
    [7] = "miscellaneous/dialog_scrollinset_left",
    [8] = "achievements/achievements_iconbg",
    [9] = "actionbar/abilitycooldowninsert",
    [10] = "ava/ava_bonuses_left",
    [11] = "campaign/overview_scoringbg_aldmeri_left",
    [12] = "campaign/overview_scoringbg_daggerfall_left",
    [13] = "campaign/overview_scoringbg_ebonheart_left",
    [14] = "art/champion/champion_sky_cloud1"
}

BS.BORDERS = {
    [1] = {"/esoui/art/worldmap/worldmap_frame_edge.dds", 128, 16},
    [2] = {"/esoui/art/crafting/crafting_tooltip_glow_edge_blue64.dds", 256, 8},
    [3] = {"/esoui/art/crafting/crafting_tooltip_glow_edge_gold64.dds", 256, 8},
    [4] = {"/esoui/art/crafting/crafting_tooltip_glow_edge_red64.dds", 256, 8},
    [5] = {"/esoui/art/chatwindow/gamepad/gp_hud_chatwindowbg_edge.dds", 512, 4},
    [6] = {"/esoui/art/interaction/conversationborder.dds", 128, 8},
    [7] = {"/esoui/art/market/market_highlightedge16.dds", 128, 16}
}

BS.MAIN_BAR = 1
BS.BACK_BAR = 2
BS.BOTH = 3
BS.ACTIVE_BAR = 4

BS.CURRENCIES = {
    [_G.CURT_MONEY] = {icon = "currency_gold_64", crownStore = false, text = _G.SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS},
    [_G.CURT_CROWNS] = {icon = "currency_crowns_32", crownStore = true, text = _G.BARSTEWARD_CROWNS},
    [_G.CURT_CROWN_GEMS] = {icon = "currency_crown_gems", crownStore = true, text = _G.BARSTEWARD_CROWN_GEMS},
    [_G.CURT_WRIT_VOUCHERS] = {icon = "currency_writvoucher_64", crownStore = false, text = _G.BARSTEWARD_WRIT_VOUCHERS},
    [_G.CURT_TELVAR_STONES] = {
        icon = "currency_telvar_64",
        crownStore = false,
        text = _G.SI_GAMEPAD_INVENTORY_TELVAR_STONES
    },
    [_G.CURT_EVENT_TICKETS] = {icon = "currency_eventticket", crownStore = false, text = _G.BARSTEWARD_EVENT_TICKETS},
    [_G.CURT_ENDEAVOR_SEALS] = {
        icon = "currency_seals_of_endeavor_64",
        crownStore = true,
        text = _G.SI_CROWN_STORE_MENU_SEALS_STORE_LABEL
    },
    [_G.CURT_UNDAUNTED_KEYS] = {
        icon = "/esoui/art/icons/quest_key_002.dds",
        crownStore = false,
        text = _G.BARSTEWARD_UNDAUNTED_KEYS
    },
    [_G.CURT_ALLIANCE_POINTS] = {
        icon = "alliancepoints_64",
        crownStore = false,
        text = _G.SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS
    },
    [_G.CURT_CHAOTIC_CREATIA] = {
        icon = "currency_seedcrystal_64",
        crownStore = false,
        text = _G.BARSTEWARD_TRANSMUTE_CRYSTALS
    },
    [_G.CURT_ENDLESS_DUNGEON or _G.CURT_ARCHIVAL_FORTUNES] = {
        icon = "archivalfragments_mipmaps",
        crownStore = true,
        text = _G.BARSTEWARD_ARCHIVAL_FRAGMENTS
    }
}

BS.FRAGMENT_TYPES = {
    _G.SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
    _G.SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
    _G.SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
    _G.SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT
}

BS.L_SHALIDORS_LIBRARY = 1
BS.L_EIDETIC_MEMORY = 2
BS.L_CRAFTING_MOTIFS = 4

BS.COMPANION_DEFIDS = {
    [BS.W_BASTIAN] = 1,
    [BS.W_MIRRI] = 2,
    [BS.W_EMBER] = 5,
    [BS.W_ISOBEL] = 6,
    [BS.W_SHARP] = 8,
    [BS.W_AZANDAR] = 9
}

BS.CATNAMES = {
    Abilities = 1,
    Activities = 2,
    Character = 3,
    Client = 4,
    Companions = 5,
    Crafting = 6,
    Currency = 7,
    Housing = 8,
    Inventory = 9,
    Riding = 10,
    Social = 11,
    Thievery = 12,
    Assistants = 13,
    InfiniteArchive = 14
}

BS.CATEGORIES = {
    [BS.CATNAMES.Abilities] = {name = _G.BARSTEWARD_CATEGORY_ABILITIES, icon = "actionbar/stateoverlay_wound"},
    [BS.CATNAMES.Activities] = {name = _G.BARSTEWARD_CATEGORY_ACTIVITIES, icon = "crafting/designs_tabicon_up"},
    [BS.CATNAMES.Character] = {
        name = _G.BARSTEWARD_CATEGORY_CHARACTER,
        icon = "charactercreate/charactercreate_bodyicon_up"
    },
    [BS.CATNAMES.Client] = {name = _G.BARSTEWARD_CATEGORY_CLIENT, icon = "login/gamepad/loading-ouroboros"},
    [BS.CATNAMES.Companions] = {
        name = _G.BARSTEWARD_CATEGORY_COMPANIONS,
        icon = "companion/keyboard/category_u30_allies_up"
    },
    [BS.CATNAMES.Crafting] = {name = _G.BARSTEWARD_CATEGORY_CRAFTING, icon = "crafting/reconstruct_tabicon_up"},
    [BS.CATNAMES.Currency] = {name = _G.BARSTEWARD_CATEGORY_CURRENCY, icon = "bank/bank_purchasenormal"},
    -- [BS.CATNAMES.Housing] =  {name=_G.BARSTEWARD_CATEGORY_HOUSING,icon="icons/poi/poi_group_house_owned"},
    [BS.CATNAMES.Inventory] = {
        name = _G.BARSTEWARD_CATEGORY_INVENTORY,
        icon = "collections/collections_tabicon_outfitstyles_up"
    },
    [BS.CATNAMES.Riding] = {name = _G.BARSTEWARD_CATEGORY_RIDING, icon = "mounts/tabicon_ridingskills_up"},
    [BS.CATNAMES.Social] = {name = _G.BARSTEWARD_CATEGORY_SOCIAL, icon = "friends/friends_tabicon_friends"},
    [BS.CATNAMES.Thievery] = {name = _G.BARSTEWARD_CATEGORY_THIEVERY, icon = "icons/mapkey/mapkey_fence"},
    [BS.CATNAMES.Assistants] = {name = _G.BARSTEWARD_ASSISTANTS, icon = "icons/assistant_premiumbanker_01"},
    [BS.CATNAMES.InfiniteArchive] = {
        name = _G.SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE,
        icon = "icons/poi/poi_endlessdungeon_complete"
    }
}

BS.ASSISTANTS = {
    [BS.W_TYTHIS] = 267,
    [BS.W_PIRHARRI] = 300,
    [BS.W_NUZHIMEH] = 301,
    [BS.W_ALLARIA] = 396,
    [BS.W_CASSUS] = 397,
    [BS.W_EZABI] = 6376,
    [BS.W_FEZEZ] = 6378,
    [BS.W_BARON] = 8994,
    [BS.W_PEDDLER] = 8995,
    [BS.W_FACTOTUM] = 9743,
    [BS.W_FACTOTUM2] = 9744,
    [BS.W_GHRASHAROG] = 9745,
    [BS.W_GILADIL] = 10184,
    [BS.W_ADERENE] = 10617,
    [BS.W_ZUQOTH] = 10618,
    [BS.W_HOARFROST] = 11059,
    [BS.W_PYROCLAST] = 11097,
    [BS.W_DRINWETH] = 11876
}

BS.INFINITE_ARCHIVE_NODE_INDEX = 550

BS.COLOURS = {
    GREY = "bababa",
    YELLOW = "ffff00",
    GREEN = "00ff00",
    BLUE = "34a4eb"
}

BS.INFINITE_ARCHIVE_MAX_COUNTS = {
    [_G.ENDLESS_DUNGEON_COUNTER_TYPE_STAGE] = 3,
    [_G.ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE] = 3,
    [_G.ENDLESS_DUNGEON_COUNTER_TYPE_ARC] = 5
}

BS.FOOD_BUFFS = {
    [17407] = true,
    [17577] = true,
    [17581] = true,
    [17614] = true,
    [61218] = true,
    [61255] = true,
    [61257] = true,
    [61259] = true,
    [61260] = true,
    [61261] = true,
    [61294] = true,
    [61335] = true,
    [61340] = true,
    [61341] = true,
    [61344] = true,
    [61345] = true,
    [61350] = true,
    [66124] = true,
    [66125] = true,
    [66127] = true,
    [66128] = true,
    [66129] = true,
    [66130] = true,
    [66131] = true,
    [66132] = true,
    [66136] = true,
    [66137] = true,
    [66140] = true,
    [66141] = true,
    [66551] = true,
    [66568] = true,
    [68411] = true,
    [68412] = true,
    [68413] = true,
    [68416] = true,
    [72816] = true,
    [72822] = true,
    [72824] = true,
    [72957] = true,
    [72960] = true,
    [72962] = true,
    [72819] = true,
    [72956] = true,
    [72959] = true,
    [72961] = true,
    [84678] = true,
    [84681] = true,
    [84700] = true,
    [84704] = true,
    [84709] = true,
    [84720] = true,
    [84725] = true,
    [84731] = true,
    [84735] = true,
    [85484] = true,
    [86559] = true,
    [86673] = true,
    [86746] = true,
    [89955] = true,
    [89957] = true,
    [89971] = true,
    [100488] = true,
    [100498] = true,
    [100502] = true,
    [107748] = true,
    [107789] = true,
    [127531] = true,
    [127572] = true,
    [127596] = true
}

BS.AP_BUFFS = {
    [66282] = true,
    [147466] = true,
    [147467] = true,
    [147687] = true,
    [147733] = true,
    [147734] = true,
    [147797] = true
}

BS.XP_BUFFS = {
    [15429] = true,
    [15450] = true,
    [63570] = true,
    [64210] = true,
    [66776] = true,
    [85501] = true,
    [85502] = true,
    [85503] = true,
    [88445] = true,
    [89683] = true,
    [91365] = true,
    [91368] = true,
    [91369] = true,
    [99462] = true,
    [99463] = true,
    [174237] = true,
    [193152] = true
}
