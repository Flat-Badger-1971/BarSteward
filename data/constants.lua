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
BS.W_TAL_VAR_STONES = 8
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

BS.WRITS = {
    [_G.CRAFTING_TYPE_ALCHEMY] = {119696, 110698, 119699, 119700, 119701, 119702, 119703, 119704, 119705, 119818, 119819, 119820},
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
