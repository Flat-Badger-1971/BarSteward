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

BS.FONTS = {
    ["Default"] = "EsoUi/Common/Fonts/Univers57.otf",
    ["Univers55"] = "EsoUi/Common/Fonts/Univers55.otf",
    ["ESO Bold"] = "EsoUi/Common/Fonts/Univers67.otf",
    ["Antique"] = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
    ["Handwritten"] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
    ["Trajan"] = "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
    ["Futura"] = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.otf",
    ["Futura Bold"] = "EsoUI/Common/Fonts/FuturaStd-Condensed.otf"
}

BS.CRAFTING_SCENES = {
    "alchemy",
    "enchanting",
    "provisioner",
    "smithing"
}

BS.BANKING_SCENES = {
    "bank",
    "guildBank",
    "houseBank"
}

BS.INVENTORY_SCENES = {
    "inventory"
}

BS.MAIL_SCENES = {
    "mailInbox",
    "mailSend"
}

BS.SIEGE_SCENES = {
    "siegeBar",
    "siegeBarUI"
}

BS.MENU_SCENES = {
    "gameMenuInGame"
}

BS.INTERACTING_SCENES = {
    "interact"
}

BS.GUILDSTORE_SCENES = {
    "tradinghouse"
}

BS.CRAFTING_ACHIEVEMENT_IDS = {
    [1145] = true,
    [2225] = true
}

BS.CRAFTING_ACHIEVEMENT = {
    [_G.CRAFTING_TYPE_ALCHEMY] = {achievementId = 1145, criterionIndex = 1},
    [_G.CRAFTING_TYPE_BLACKSMITHING] = {achievementId = 1145, criterionIndex = 2},
    [_G.CRAFTING_TYPE_CLOTHIER] = {achievementId = 1145, criterionIndex = 3},
    [_G.CRAFTING_TYPE_ENCHANTING] = {achievementId = 1145, criterionIndex = 4},
    [_G.CRAFTING_TYPE_JEWELRYCRAFTING] = {achievementId = 2225, criterionIndex = 1},
    [_G.CRAFTING_TYPE_PROVISIONING] = {achievementId = 1145, criterionIndex = 5},
    [_G.CRAFTING_TYPE_WOODWORKING] = {achievementId = 1145, criterionIndex = 6}
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

BS.COLLAPSE = "/esoui/art/buttons/large_leftdoublearrow_up.dds"
BS.EXPAND = "/esoui/art/buttons/large_rightdoublearrow_up.dds"

BS.FADE_IN_TIME = 250
BS.FADE_OUT_TIME = 750

BS.CLICK = "/esoui/art/miscellaneous/icon_lmb.dds"

BS.DUNGEON = {
    [_G.LFG_ACTIVITY_DUNGEON] = "/esoui/art/leveluprewards/levelup_dungeon_64.dds",
    [_G.LFG_ACTIVITY_MASTER_DUNGEON] = "/esoui/art/leveluprewards/levelup_veteran_dungeon_64.dds"
}

BS.INELIGIBLE_ICON = "/esoui/art/castbar/forbiddenaction.dds"
BS.NORMAL_ICON = "/esoui/art/ava/ava_hud_emblem_neutral.dds"
BS.MAGIC_ICON = "/esoui/art/progression/stamina_points_frame.dds"
BS.ARCANE_ICON = "/esoui/art/scrying/crystal_on.dds"
BS.ARTIFACT_ICON = "/esoui/art/battlegrounds/battlegrounds_teamicon_purple_64.dds"
BS.LEGENDARY_ICON = "/esoui/art/market/keyboard/esoplus_chalice_gold2_64.dds"

BS.ITEM_COLOUR_ICON = {
    [_G.ITEM_DISPLAY_QUALITY_NORMAL] = BS.NORMAL_ICON,
    [_G.ITEM_DISPLAY_QUALITY_MAGIC] = BS.MAGIC_ICON,
    [_G.ITEM_DISPLAY_QUALITY_ARCANE] = BS.ARCANE_ICON,
    [_G.ITEM_DISPLAY_QUALITY_ARTIFACT] = BS.ARTIFACT_ICON,
    [_G.ITEM_DISPLAY_QUALITY_LEGENDARY] = BS.LEGENDARY_ICON,
    [_G.ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = BS.LEGENDARY_ICON
}

BS.BATTLEGROUND_ICON = {
    [_G.LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "/esoui/art/icons/battleground_medal_murderballcarry_001.dds",
    [_G.LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "/esoui/art/icons/battleground_medal_murderballcarry_002.dds",
    [_G.LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "/esoui/art/icons/battleground_medal_murderballcarry_003.dds"
}

BS.TRIBUTE_ICON = {
    [_G.LFG_ACTIVITY_TRIBUTE_CASUAL] = "/esoui/art/icons/u34_tribute_quest3.dds",
    [_G.LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "/esoui/art/icons/u34_tribute_pvedaily30.dds"
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

BS.VAMPIRE_STAGES = {[135397] = true, [135399] = true, [135400] = true, [135402] = true, [135412] = true}
BS.VAMPIRE_FEED = {[40359] = true}
