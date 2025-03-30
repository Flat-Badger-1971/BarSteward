--- @type table
BarSteward = {
    Name = "BarSteward",
    --too much hassle to refactor the whole addon to use classes properly, so adding a callback manager here
    CallbackManager = ZO_CallbackObject:Subclass():New(),
    LC = LibFBCommon,
    -- widget constants
    W_TIME = 1,
    W_ALLIANCE_POINTS = 2,
    W_CROWN_GEMS = 3,
    W_CROWNS = 4,
    W_EVENT_TICKETS = 5,
    W_GOLD = 6,
    W_SEALS_OF_ENDEAVOUR = 7,
    W_TELVAR_STONES = 8,
    W_TRANSMUTE_CRYSTALS = 9,
    W_UNDAUNTED_KEYS = 10,
    W_WRIT_VOUCHERS = 11,
    W_BAG_SPACE = 12,
    W_BANK_SPACE = 13,
    W_FPS = 14,
    W_LATENCY = 15,
    W_BLACKSMITHING = 16,
    W_WOODWORKING = 17,
    W_CLOTHING = 18,
    W_JEWELCRAFTING = 19,
    W_REPAIR_COST = 20,
    W_MOUNT_TRAINING = 21,
    W_RAPPORT = 22,
    W_CHAMPION_POINTS = 23,
    W_MUNDUS_STONE = 24,
    W_DURABILITY = 25,
    W_DAILY_ENDEAVOURS = 26,
    W_WEEKLY_ENDEAVOURS = 27,
    W_REPAIRS_KITS = 28,
    W_STOLEN_ITEMS = 29,
    W_RECALL_COOLDOWN = 30,
    W_FENCE_TRANSACTIONS = 31,
    W_ZONE = 32,
    W_PLAYER_NAME = 33,
    W_RACE = 34,
    W_CLASS = 35,
    W_ALLIANCE = 36,
    W_LEADS = 37,
    W_SOUL_GEMS = 38,
    W_FRIENDS = 39,
    W_MEMORY = 40,
    W_SKYSHARDS = 41,
    W_SKILL_POINTS = 42,
    W_WRITS_SURVEYS = 43,
    W_FENCE_RESET = 44,
    W_ENDEAVOUR_PROGRESS = 45,
    W_IMPERIAL_FRAGMENTS = 46,
    W_LOCKPICKS = 47,
    W_LAUNDER_TRANSACTIONS = 48,
    W_SPEED = 49,
    W_CRAFTING_DAILIES = 50,
    W_GUILD_FRIENDS = 51,
    W_DAILY_ENDEAVOUR_TIME = 52,
    W_WEEKLY_ENDEAVOUR_TIME = 53,
    W_COMPANION_LEVEL = 54,
    W_TRIBUTE_CLUB_RANK = 55,
    W_PLAYER_LEVEL = 56,
    W_ACHIEVEMENT_POINTS = 57,
    W_PLEDGES_TIME = 58,
    W_SHADOWY_VENDOR_TIME = 59,
    W_LFG_TIME = 60,
    W_CRAFTING_DAILY_TIME = 61,
    W_WATCHED_ITEMS = 62,
    W_TAMRIEL_TIME = 63,
    W_ACTIVE_BAR = 64,
    W_DPS = 65,
    W_LOREBOOKS = 66,
    W_RECIPES = 67,
    W_RANDOM_MEMENTO = 68,
    W_RANDOM_PET = 69,
    W_RANDOM_MOUNT = 70,
    W_RANDOM_EMOTE = 71,
    W_CONTAINERS = 72,
    W_TREASURE = 73,
    W_RANDOM_DUNGEON = 74,
    W_PLAYER_LOCATION = 75,
    W_RANDOM_BATTLEGROUND = 76,
    W_RANDOM_TRIBUTE = 77,
    W_PLAYER_EXPERIENCE = 78,
    W_UNKNOWN_WRIT_MOTIFS = 79,
    W_FURNISHINGS = 80,
    W_COMPANION_GEAR = 81,
    W_MUSEUM = 82,
    W_EQUIPPED_POISON = 83,
    W_VAMPIRISM = 84,
    W_VAMPIRISM_TIMER = 85,
    W_VAMPIRISM_FEED_TIMER = 86,
    W_FRAGMENTS = 87,
    W_RUNEBOXES = 88,
    W_RECIPE_WATCH = 89,
    W_CHESTS_FOUND = 90,
    W_SHALIDORS_LIBRARY = 91,
    W_CRAFTING_MOTIFS = 92,
    W_DAILY_PROGRESS = 93,
    W_WEAPON_CHARGE = 94,
    W_BASTIAN = 95,
    W_MIRRI = 96,
    W_EMBER = 97,
    W_ISOBEL = 98,
    W_SHARP = 99,
    W_AZANDAR = 100,
    W_EZABI = 101,
    W_GHRASHAROG = 102,
    W_GILADIL = 103,
    W_PIRHARRI = 104,
    W_TYTHIS = 105,
    W_NUZHIMEH = 106,
    W_ALLARIA = 107,
    W_CASSUS = 108,
    W_FEZEZ = 109,
    W_BARON = 110,
    W_FACTOTUM = 111,
    W_FACTOTUM2 = 112,
    W_ADERENE = 113,
    W_ZUQOTH = 114,
    W_HOARFROST = 115,
    W_PYROCLAST = 116,
    W_PEDDLER = 117,
    W_ARCHIVAL_FRAGMENTS = 118,
    W_ARCHIVE_PORT = 119,
    W_INFINITE_ARCHIVE_PROGRESS = 120,
    W_INFINITE_ARCHIVE_SCORE = 121,
    W_DRINWETH = 122,
    W_FOOD_BUFF = 123,
    W_AP_BUFF = 124,
    W_XP_BUFF = 125,
    W_ALL_CRAFTING = 126,
    W_DAILY_COUNT = 127,
    W_PLAYER_STATUS = 128,
    W_FISHING = 129,
    W_LFG_ROLE = 130,
    W_TZOZABRAR = 131,
    W_ERI = 132,
    W_XYN = 133,
    W_SCRIBING_INK = 134,
    W_TITLE = 135,
    W_BOUNTY = 136,
    W_DAILY_REWARD = 137,
    W_DAILY_PLEDGES = 138,
    W_BOUNTY_AMOUNT = 139,
    W_ARMOURY_BUILD = 140,
    W_ENLIGHTENED = 141,
    W_CAMPAIGN_TIER = 142,
    W_CONT_ATT = 143,
    W_AYLEID_HEALTH = 144,
    W_SCRYING = 145,
    W_TANLORIN = 146,
    W_ZERITH = 147,
    W_MYTHIC = 148,
    W_ACHIEVEMENT_TRACKER = 149,
    W_GOLDEN_PURSUITS = 150,
    W_SERVER = 151
}

local BS = BarSteward

function BS.RegisterCallback(...)
    ---@diagnostic disable-next-line: undefined-field
    BS.CallbackManager:RegisterCallback(...)
end

function BS.FireCallbacks(...)
    ---@diagnostic disable-next-line: undefined-field
    BS.CallbackManager:FireCallbacks(...)
end

-- linefeed character
BS.LF = BS.LC.LF

BS.WRITS = {
    [CRAFTING_TYPE_ALCHEMY] = {
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
    [CRAFTING_TYPE_BLACKSMITHING] = { 119563, 119680, 121527, 121529 },
    [CRAFTING_TYPE_CLOTHIER] = { 119694, 119695, 121532, 121533 },
    [CRAFTING_TYPE_ENCHANTING] = { 119564, 121528 },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = { 138789, 138799, 153737, 153739 },
    [CRAFTING_TYPE_PROVISIONING] = { 119693 },
    [CRAFTING_TYPE_WOODWORKING] = { 119681, 119682, 121530, 121531 }
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

BS.CRAFTING_SCENES = { "alchemy", "enchanting", "provisioner", "smithing" }
BS.BANKING_SCENES = { "bank", "guildBank", "houseBank" }
BS.INVENTORY_SCENES = { "inventory" }
BS.MAIL_SCENES = { "mailInbox", "mailSend" }
BS.SIEGE_SCENES = { "siegeBar", "siegeBarUI" }
BS.MENU_SCENES = { "gameMenuInGame", "mainMenuGamepad" }
BS.INTERACTING_SCENES = { "interact" }
BS.GUILDSTORE_SCENES = { "tradinghouse" }
BS.DEFAULT_SCENES = { "hud", "hudui" }
BS.SCENES = { "banking", "crafting", "default", "guildstore", "interacting", "inventory", "mail", "menu", "siege" }

BS.CRAFTING_ACHIEVEMENT_IDS = {
    [1145] = true,
    [2225] = true
}

BS.CRAFTING_ACHIEVEMENT = {
    [CRAFTING_TYPE_ALCHEMY] = { achievementId = 1145, criterionIndex = 1, icon = "alchemist" },
    [CRAFTING_TYPE_BLACKSMITHING] = { achievementId = 1145, criterionIndex = 2, icon = "smithy" },
    [CRAFTING_TYPE_CLOTHIER] = { achievementId = 1145, criterionIndex = 3, icon = "clothier" },
    [CRAFTING_TYPE_ENCHANTING] = { achievementId = 1145, criterionIndex = 4, icon = "enchanter" },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = { achievementId = 2225, criterionIndex = 1, icon = "jewelrycrafting" },
    [CRAFTING_TYPE_PROVISIONING] = { achievementId = 1145, criterionIndex = 5, icon = "inn" },
    [CRAFTING_TYPE_WOODWORKING] = { achievementId = 1145, criterionIndex = 6, icon = "woodworker" }
}

BS.CRAFTING_DAILY = {
    [CRAFTING_TYPE_ALCHEMY] = GetString(BARSTEWARD_WRIT_ALCHEMY),
    [CRAFTING_TYPE_BLACKSMITHING] = GetString(BARSTEWARD_WRIT_BLACKSMITHING),
    [CRAFTING_TYPE_CLOTHIER] = GetString(BARSTEWARD_WRIT_CLOTHIER),
    [CRAFTING_TYPE_ENCHANTING] = GetString(BARSTEWARD_WRIT_ENCHANTING),
    [CRAFTING_TYPE_JEWELRYCRAFTING] = GetString(BARSTEWARD_WRIT_JEWELLERY),
    [CRAFTING_TYPE_PROVISIONING] = GetString(BARSTEWARD_WRIT_PROVISIONING),
    [CRAFTING_TYPE_WOODWORKING] = GetString(BARSTEWARD_WRIT_WOODWORKING)
}

BS.PERFECT_ROE = 64222
BS.POTENT_NIRNCRUX = 56863

-- these are in the game code but don't appear to be available anywhere
BS.IGNORE_RECIPE = {
    [64470] = true,  -- Recipe: Old Orsinium Bloop Soup
    [121098] = true, -- Blueprint: Common Campfire, Outdoor
    [126863] = true, -- Diagram: Dwarven Pipeline Cap, Sealed
    [132173] = true, -- Blueprint: Witches Brazier, Primitive Log
    [132179] = true  -- Blueprint: Witches Totem, Antler Charms
}

BS.COLLAPSE = "buttons/large_leftdoublearrow_up"
BS.EXPAND = "buttons/large_rightdoublearrow_up"

BS.FADE_IN_TIME = 250
BS.FADE_OUT_TIME = 750

BS.CLICK = "miscellaneous/icon_lmb"

BS.DUNGEON = {
    [LFG_ACTIVITY_DUNGEON] = "leveluprewards/levelup_dungeon_64",
    [LFG_ACTIVITY_MASTER_DUNGEON] = "leveluprewards/levelup_veteran_dungeon_64"
}

BS.INELIGIBLE_ICON = "castbar/forbiddenaction"
BS.NORMAL_ICON = "ava/ava_hud_emblem_neutral"
BS.MAGIC_ICON = "progression/stamina_points_frame"
BS.ARCANE_ICON = "scrying/crystal_on"
BS.ARTIFACT_ICON = "battlegrounds/battlegrounds_teamicon_purple_64"
BS.LEGENDARY_ICON = "market/keyboard/esoplus_chalice_gold2_64"

BS.ITEM_COLOUR_ICON = {
    [ITEM_DISPLAY_QUALITY_NORMAL] = BS.NORMAL_ICON,
    [ITEM_DISPLAY_QUALITY_MAGIC] = BS.MAGIC_ICON,
    [ITEM_DISPLAY_QUALITY_ARCANE] = BS.ARCANE_ICON,
    [ITEM_DISPLAY_QUALITY_ARTIFACT] = BS.ARTIFACT_ICON,
    [ITEM_DISPLAY_QUALITY_LEGENDARY] = BS.LEGENDARY_ICON,
    [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = BS.LEGENDARY_ICON
}

BS.BATTLEGROUND_ICON = {
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "icons/battleground_medal_murderballcarry_001",
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "icons/battleground_medal_murderballcarry_002",
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "icons/battleground_medal_murderballcarry_003"
}

BS.TRIBUTE_ICON = {
    [LFG_ACTIVITY_TRIBUTE_CASUAL] = "icons/u34_tribute_quest3",
    [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "icons/u34_tribute_pvedaily30"
}

BS.FRIENDS_ICON = "/esoui/art/chatwindow/chat_friendsonline_up.dds"

-- reflects the number of bindings setup in ui/bindings.xml
BS.MAX_BINDINGS = 20

-- info from Writ Worthy
BS.WRIT_ITEM_TYPES = {
    [ITEM_STYLE_CHAPTER_HELMETS] = { 26, 35, 44 },
    [ITEM_STYLE_CHAPTER_GLOVES] = { 34, 43, 52 },
    [ITEM_STYLE_CHAPTER_BOOTS] = { 32, 41, 50 },
    [ITEM_STYLE_CHAPTER_LEGS] = { 31, 40, 49 },
    [ITEM_STYLE_CHAPTER_CHESTS] = { 28, 37, 46, 75 },
    [ITEM_STYLE_CHAPTER_BELTS] = { 30, 39, 48 },
    [ITEM_STYLE_CHAPTER_SHOULDERS] = { 29, 38, 47 },
    [ITEM_STYLE_CHAPTER_SWORDS] = { 59, 67 },
    [ITEM_STYLE_CHAPTER_MACES] = { 56, 69 },
    [ITEM_STYLE_CHAPTER_AXES] = { 53, 68 },
    [ITEM_STYLE_CHAPTER_DAGGERS] = { 62 },
    [ITEM_STYLE_CHAPTER_STAVES] = { 71, 72, 73, 74 },
    [ITEM_STYLE_CHAPTER_SHIELDS] = { 65 },
    [ITEM_STYLE_CHAPTER_BOWS] = { 70 }
}

BS.VAMPIRE_STAGES = { [135397] = 1, [135399] = 2, [135400] = 3, [135402] = 4, [135412] = 5 }
BS.VAMPIRE_FEED = { [40359] = true }

BS.MAIN_BAR = 1
BS.BACK_BAR = 2
BS.BOTH = 3
BS.ACTIVE_BAR = 4

BS.CURRENCIES = {
    [CURT_MONEY] = { crownStore = false },
    [CURT_CROWNS] = { crownStore = true },
    [CURT_CROWN_GEMS] = { crownStore = true },
    [CURT_WRIT_VOUCHERS] = { crownStore = false },
    [CURT_TELVAR_STONES] = { crownStore = false },
    [CURT_EVENT_TICKETS] = { crownStore = false },
    [CURT_ENDEAVOR_SEALS] = { crownStore = true },
    [CURT_UNDAUNTED_KEYS] = { crownStore = false },
    [CURT_ALLIANCE_POINTS] = { crownStore = false },
    [CURT_CHAOTIC_CREATIA] = { crownStore = false },
    [CURT_ARCHIVAL_FORTUNES] = { crownStore = true },
    [CURT_IMPERIAL_FRAGMENTS] = { crownStore = true }
}

BS.FRAGMENT_TYPES = {
    SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
    SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
    SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
    SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT
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
    [BS.W_AZANDAR] = 9,
    [BS.W_TANLORIN] = 12,
    [BS.W_ZERITH] = 13
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
    InfiniteArchive = 14,
    PvP = 15
}

BS.CATEGORIES = {
    [BS.CATNAMES.Abilities] = { name = BARSTEWARD_CATEGORY_ABILITIES, icon = "actionbar/stateoverlay_wound" },
    [BS.CATNAMES.Activities] = { name = BARSTEWARD_CATEGORY_ACTIVITIES, icon = "crafting/designs_tabicon_up" },
    [BS.CATNAMES.Character] = {
        name = BARSTEWARD_CATEGORY_CHARACTER,
        icon = "charactercreate/charactercreate_bodyicon_up"
    },
    [BS.CATNAMES.Client] = { name = BARSTEWARD_CATEGORY_CLIENT, icon = "login/gamepad/loading-ouroboros" },
    [BS.CATNAMES.Companions] = {
        name = BARSTEWARD_CATEGORY_COMPANIONS,
        icon = "companion/keyboard/category_u30_allies_up"
    },
    [BS.CATNAMES.Crafting] = { name = BARSTEWARD_CATEGORY_CRAFTING, icon = "crafting/reconstruct_tabicon_up" },
    [BS.CATNAMES.Currency] = { name = BARSTEWARD_CATEGORY_CURRENCY, icon = "bank/bank_purchasenormal" },
    -- [BS.CATNAMES.Housing] =  {name=BARSTEWARD_CATEGORY_HOUSING,icon="icons/poi/poi_group_house_owned"},
    [BS.CATNAMES.Inventory] = {
        name = BARSTEWARD_CATEGORY_INVENTORY,
        icon = "collections/collections_tabicon_outfitstyles_up"
    },
    [BS.CATNAMES.Riding] = { name = BARSTEWARD_CATEGORY_RIDING, icon = "mounts/tabicon_ridingskills_up" },
    [BS.CATNAMES.Social] = { name = BARSTEWARD_CATEGORY_SOCIAL, icon = "friends/friends_tabicon_friends" },
    [BS.CATNAMES.Thievery] = { name = BARSTEWARD_CATEGORY_THIEVERY, icon = "icons/mapkey/mapkey_fence" },
    [BS.CATNAMES.Assistants] = { name = BARSTEWARD_ASSISTANTS, icon = "icons/assistant_premiumbanker_01" },
    [BS.CATNAMES.InfiniteArchive] = {
        name = SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE,
        icon = "icons/poi/poi_endlessdungeon_complete"
    },
    [BS.CATNAMES.PvP] = { name = SI_GROUPFINDERCATEGORY4, icon = "icons/u41_pvp_reward_container" }
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
    [BS.W_DRINWETH] = 11876,
    [BS.W_TZOZABRAR] = 11877,
    [BS.W_ERI] = 12413,
    [BS.W_XYN] = 12414
}

BS.ARMOURY_ASSISTANTS = {
    BS.ASSISTANTS[BS.W_DRINWETH],
    BS.ASSISTANTS[BS.W_GHRASHAROG],
    BS.ASSISTANTS[BS.W_ZUQOTH]
}

BS.INFINITE_ARCHIVE_NODE_INDEX = 550

BS.INFINITE_ARCHIVE_MAX_COUNTS = {
    [ENDLESS_DUNGEON_COUNTER_TYPE_STAGE] = 3,
    [ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE] = 3,
    [ENDLESS_DUNGEON_COUNTER_TYPE_ARC] = 5
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

BS.MAX_PLAYER_LEVEL = 50
BS.MAX_DAILY_QUESTS = 50
BS.MAX_TIMERS = 5

BS.ITEM_TYPE_ICON = {
    [ITEMTYPE_FISH] = {
        icon = "icons/fishing_salmon_variant_red",
        name = SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY4
    },
    [ITEMTYPE_COLLECTIBLE] = { icon = "icons/crafting_fishing_trophy_perch", name = SI_SPECIALIZEDITEMTYPE80 },
    [ITEMTYPE_TRASH] = { icon = "inventory/inventory_tabicon_trash_up", name = SI_ITEMTYPE48 },
    [ITEMTYPE_LURE] = { icon = "inventory/inventory_tabicon_bait_up", name = SI_FISHING_WHEEL_NARRATION },
    [ITEMTYPE_FURNISHING] = {
        icon = "inventory/inventory_tabicon_furnishing_material_up",
        name = SI_HOUSING_PREVIEW_TEMPLATE_FURNISHINGS
    },
    [ITEMTYPE_CONTAINER] = { icon = "icons/justice_stolen_wax_sealed_heavy_sack", name = SI_ITEMTYPE18 }
}

BS.CHAR = {
    alliance = GetUnitAlliance("player"),
    class = GetUnitClass("player"),
    classId = GetUnitClassId("player"),
    id = GetCurrentCharacterId(),
    gender = GetUnitGender("player"),
    name = GetUnitName("player"),
    race = GetUnitRace("player")
}

BS.CHAR.allianceColour = GetAllianceColor(BS.CHAR.alliance)
BS.CHAR.allianceIcon = ZO_GetAllianceIcon(BS.CHAR.alliance)
BS.CHAR.allianceName = GetAllianceName(BS.CHAR.alliance)
BS.CHAR.classIcon = GetClassIcon(BS.CHAR.classId)

BS.CONTINUOUS_ATTACK = { [39248] = true, [45614] = true, [45615] = true, [45616] = true, [45617] = true }
BS.AYLEID_HEALTH = { [21263] = true, [100862] = true }
BS.CRIMEQUESTS = {
    5532,
    5536,
    5540,
    5572,
    5573,
    5575,
    5577,
    5584,
    5586,
    5587,
    5588,
    5589,
    "5590,5594",
    "5616,5627",
    "5629,5647",
    "5649,5685",
    "5687,5711",
    5713,
    5714,
    5719,
    5726
}
