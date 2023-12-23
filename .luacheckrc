std = "min"
max_line_length = 160

-- globals used within addons
--globals = {"CF"}
read_globals = {
    ["ACHIEVEMENTS_MANAGER"] = {
        fields = {
            GetAchievementStatus = {read_only = true}
        }
    },
    ["CALLBACK_MANAGER"] = {
        fields = {
            FireCallbacks = {read_only = true},
            RegisterCallback = {read_only = true}
        }
    },
    ["CENTER_SCREEN_ANNOUNCE"] = {
        fields = {
            CreateMessageParams = {read_only = true},
            AddMessageWithParams = {read_only = true}
        }
    },
    ["CHAMPION_DATA_MANAGER"] = {
        fields = {
            FindChampionDisciplineDataById = {read_only = true},
            FindChampionDisciplineDataByType = {read_only = true}
        }
    },
    ["CHAMPION_PERKS"] = {
        fields = {
            GetChampionBar = {read_only = true}
        }
    },
    ["CHAT_ROUTER"] = {
        fields = {
            AddSystemMessage = {read_only = true}
        }
    },
    ["COLLECTIONS_BOOK"] = {
        fields = {
            BrowseToCollectible = {read_only = true}
        }
    },
    ["ENDLESS_DUNGEON_MANAGER"] = {
        fields = {
            GetAbilityStackCountTable = {read_only = true},
            GetAttemptsRemaining = {read_only = true},
            GetProgression = {read_only = true},
            GetScore = {read_only = true},
            IsPlayerInEndlessDungeon = {read_only = true},
            RegisterCallback = {read_only = true}
        }
    },
    ["EVENT_MANAGER"] = {
        fields = {
            AddFilterForEvent = {read_only = true},
            RegisterForEvent = {read_only = true},
            RegisterForUpdate = {read_only = true},
            UnregisterForEvent = {read_only = true},
            UnregisterForUpdate = {read_only = true}
        }
    },
    ["FENCE_MANAGER"] = {
        fields = {
            GetNumTotalTransactions = {read_only = true},
            GetNumTransactionsUsed = {read_only = true}
        }
    },
    ["FISHING_MANAGER"] = {
        fields = {
            StopInteraction = {read_only = true}
        }
    },
    ["FRIENDS_LIST_MANAGER"] = {
        fields = {
            GetMasterList = {read_only = true}
        }
    },
    ["GROUP_MENU_KEYBOARD"] = {
        fields = {
            ShowCategory = {read_only = true}
        }
    },
    ["GUILD_ROSTER_MANAGER"] = {
        fields = {
            SetGuildId = {read_only = true},
            FindDataByDisplayName = {read_only = true},
            GetGuildId = {read_only = true}
        }
    },
    ["MAIL_MANAGER_GAMEPAD"] = {
        fields = {
            GetSend = {read_only = true}
        }
    },
    ["MAIL_SEND"] = {
        fields = {
            ComposeMailTo = {read_only = true}
        }
    },
    ["MAIN_MENU_KEYBOARD"] = {
        fields = {
            ShowScene = {read_only = true}
        }
    },
    ["MAIN_MENU_GAMEPAD"] = {
        fields = {
            ShowScene = {read_only = true}
        }
    },
    ["PLAYER_EMOTE_MANAGER"] = {
        fields = {
            GetEmoteCategories = {read_only = true},
            GetEmoteListForType = {read_only = true}
        }
    },
    ["QUEST_JOURNAL_MANAGER"] = {
        fields = {
            GetQuestListData = {read_only = true},
            BuildTextForConditions = {read_only = true}
        }
    },
    ["REWARDS_MANAGER"] = {
        fields = {
            GetInfoForReward = {read_only = true}
        }
    },
    ["SCENE_MANAGER"] = {
        fields = {
            CallWhen = {read_only = true},
            GetCurrentScene = {read_only = true},
            GetScene = {read_only = true},
            GetSceneGroup = {read_only = true},
            Hide = {read_only = true},
            IsInUIMode = {read_only = true},
            IsShowing = {read_only = true},
            RegisterCallback = {read_only = true},
            SetInUIMode = {read_only = true},
            Show = {read_only = true}
        }
    },
    ["SHARED_INVENTORY"] = {
        fields = {
            GenerateFullSlotData = {read_only = true},
            bagCache = {read_only = true}
        }
    },
    ["STABLE_MANAGER"] = {
        fields = {
            GetStats = {read_only = true}
        }
    },
    ["SYSTEMS"] = {
        fields = {
            GetObject = {read_only = true}
        }
    },
    ["TIMED_ACTIVITIES_GAMEPAD"] = {
        fields = {
            GetCategoryData = {read_only = true}
        }
    },
    ["TIMED_ACTIVITIES_KEYBOARD"] = {
        fields = {
            SetCurrentActivityType = {read_only = true}
        }
    },
    ["TIMED_ACTIVITIES_MANAGER"] = {
        fields = {
            GetTimedActivityTypeTimeRemainingSeconds = {read_only = true}
        }
    },
    ["WINDOW_MANAGER"] = {
        fields = {
            CreateTopLevelWindow = {read_only = true},
            CreateControl = {read_only = true},
            CreateControlFromVirtual = {read_only = true},
            IsSecureRenderModeEnabled = {read_only = true}
        }
    },
    ["ZO_ACTIVITY_FINDER_ROOT_GAMEPAD"] = {
        fields = {
            ShowCategory = {read_only = true}
        }
    },
    ["ZO_ACTIVITY_FINDER_ROOT_MANAGER"] = {
        fields = {
            GetLocationsData = {read_only = true}
        }
    },
    ["ZO_COLLECTIBLE_DATA_MANAGER"] = {
        fields = {
            GetAllCollectibleDataObjects = {read_only = true},
            GetCategoryDataByIndicies = {read_only = true},
            GetCollectibleDataById = {read_only = true}
        }
    },
    -- constants
    "BOTTOM",
    "BOTTOMLEFT",
    "BOTTOMRIGHT",
    "BSTATE_NORMAL",
    "CD_TYPE_RADIAL",
    "CD_TYPE_VERTICAL",
    "CD_TYPE_VERTICAL_REVEAL",
    "CD_TIME_TYPE_TIME_UNTIL",
    "CENTER",
    "COLLECTIBLE_CATEGORY_TYPE_ASSISTANT",
    "COLLECTIBLE_CATEGORY_TYPE_COMPANION",
    "CT_BACKDROP",
    "CT_BUTTON",
    "CT_CONTROL",
    "CT_COOLDOWN",
    "CT_EDITBOX",
    "CT_LABEL",
    "CT_STATUSBAR",
    "CT_TEXTURE",
    "DT_HIGH",
    "LEFT",
    "POWERTYPE_HEALTH",
    "RETICLE",
    "RIGHT",
    "TEXT_ALIGN_CENTER",
    "TOP",
    "TOPLEFT",
    "TOPRIGHT",
    ["UNIT_FRAMES"] = {
        fields = {
            GetFrame = {read_only = true}
        }
    },
    -- lua
    "unpack",
    --API
    "CreateSimpleAnimation",
    "DoesAntiquityHaveLead",
    "DoesUnitExist",
    "EndInteraction",
    "EndPendingInteraction",
    "FastTravelToNode",
    "FormatIntegerWithDigitGrouping",
    "GetAbilityDescription",
    "GetAbilityEndlessDungeonBuffType",
    "GetAbilityIcon",
    "GetAbilityName",
    "GetAchievementCriterion",
    "GetAchievementInfo",
    "GetAchievementName",
    "GetAchievementNumCriteria",
    "GetActiveCollectibleByType",
    "GetActiveCompanionDefId",
    "GetActiveCompanionLevelInfo",
    "GetActiveCompanionRapport",
    "GetActiveCompanionRapportLevel",
    "GetActiveCompanionRapportLevelDescription",
    "GetActiveWeaponPairInfo",
    "GetAllianceColor",
    "GetAllianceName",
    "GetAnimationManager",
    "GetNumAntiquitiesRecovered",
    "GetAntiquityDifficulty",
    "GetAntiquityLeadIcon",
    "GetAntiquityLeadTimeRemainingSeconds",
    "GetAntiquityName",
    "GetAntiquityQuality",
    "GetAntiquityZoneId",
    "GetAvailableSkillPoints",
    "GetBagSize",
    "GetBankedCurrencyAmount",
    "GetCategoryInfoFromAchievementId",
    "GetChampionDisciplineId",
    "GetChampionDisciplineName",
    "GetChampionPointPoolForRank",
    "GetClassIcon",
    "GetCollectibleCategoryId",
    "GetCollectibleCategoryInfo",
    "GetCollectibleCooldownAndDuration",
    "GetCollectibleIcon",
    "GetCollectibleId",
    "GetCollectibleInfo",
    "GetCollectibleName",
    "GetCollectibleReferenceId",
    "GetCollectibleSubCategoryInfo",
    "GetCombinationUnlockedCollectible",
    "GetCompanionCollectibleId",
    "GetCompanionName",
    "GetCurrencyAmount",
    "GetCurrencyPlayerStoredLocation",
    "GetCurrentMapId",
    "GetCVar",
    "GetEarnedAchievementPoints",
    "GetEmoteInfo",
    "GetEndlessDungeonBuffSelectorBucketTypeChoice",
    "GetEndlessDungeonGroupType",
    "GetFenceLaunderTransactionInfo",
    "GetFishingLure",
    "GetFishingLureInfo",
    "GetFramerate",
    "GetFrameTimeMilliseconds",
    "GetFriendInfo",
    "GetGameCameraInteractableActionInfo",
    "GetGameCameraPickpocketingBonusInfo",
    "GetGameTimeMilliseconds",
    "GetGameTimeSeconds",
    "GetGuildId",
    "GetGuildMemberCharacterInfo",
    "GetGuildMemberInfo",
    "GetGuildName",
    "GetHouseFoundInZoneId",
    "GetLFGActivityRewardDescriptionOverride",
    "GetLFGActivityRewardUINodeInfo",
    "GetUIGlobalScale",
    "GetInteractionType",
    "GetInterfaceColor",
    "GetItemCondition",
    "GetItemDisplayQuality",
    "GetItemFilterTypeInfo",
    "GetItemId",
    "GetItemInfo",
    "GetItemLink",
    "GetItemLinkContainerCollectibleId",
    "GetItemLinkDisplayQuality",
    "GetItemLinkIcon",
    "GetItemLinkInfo",
    "GetItemLinkItemId",
    "GetItemLinkItemType",
    "GetItemLinkName",
    "GetItemLinkMaxEnchantCharges",
    "GetItemLinkNumEnchantCharges",
    "GetItemName",
    "GetItemPairedPoisonInfo",
    "GetItemQualityColor",
    "GetItemSellValueWithBonuses",
    "GetItemStyleName",
    "GetItemType",
    "GetJournalQuestConditionInfo",
    "GetJournalQuestInfo",
    "GetJournalQuestNumConditions",
    "GetJournalQuestRepeatType",
    "GetLatency",
    "GetLFGCooldownTimeRemainingSeconds",
    "GetLoreBookInfo",
    "GetLoreCategoryInfo",
    "GetLoreCollectionInfo",
    "GetMapContentType",
    "GetMaximumRapport",
    "GetMaxLevel",
    "GetMaxPossibleCurrency",
    "GetMaxRecipeIngredients",
    "GetMaxSimultaneousSmithingResearch",
    "GetMinimumRapport",
    "GetNextAntiquityId",
    "GetNonCombatBonus",
    "GetNumAntiquityDigSites",
    "GetNumBagUsedSlots",
    "GetNumBuffs",
    "GetNumChampionDisciplines",
    "GetNumChampionXPInChampionPoint",
    "GetNumCollectibleCategories",
    "GetNumExperiencePointsInCompanionLevel",
    "GetNumExperiencePointsInLevel",
    "GetNumFriends",
    "GetNumGuildMembers",
    "GetNumGuilds",
    "GetNumJournalQuests",
    "GetNumLFGActivityRewardUINodes",
    "GetNumLockpicksLeft",
    "GetNumLoreCategories",
    "GetNumRecipeLists",
    "GetNumSkyShards",
    "GetNumSkyshardsInZone",
    "GetNumSmithingResearchLines",
    "GetNumTimedActivityRewards",
    "GetParentZoneId",
    "GetPendingCompanionDefId",
    "GetPlayerChampionPointsEarned",
    "GetPlayerChampionXP",
    "GetPlayerGuildMemberIndex",
    "GetPlayerLocationName",
    "GetMapPlayerPosition",
    "GetPulseTimeline",
    "GetRecallCooldown",
    "GetRecipeInfo",
    "GetRecipeIngredientItemInfo",
    "GetRecipeListInfo",
    "GetRecipeResultItemLink",
    "GetRepairAllCost",
    "GetRequiredChampionDisciplineIdForSlot",
    "GetRidingStats",
    "GetSkillLineIndicesFromSkillLineId",
    "GetSkillLineInfo",
    "GetSkyshardDiscoveryStatus",
    "GetSlotStackSize",
    "GetSmithingResearchLineInfo",
    "GetSmithingResearchLineTraitInfo",
    "GetSmithingResearchLineTraitTimes",
    "GetSoulGemInfo",
    "GetString",
    "GetTimedActivityDescription",
    "GetTimedActivityMaxProgress",
    "GetTimedActivityName",
    "GetTimedActivityProgress",
    "GetTimedActivityRewardInfo",
    "GetTimedActivityType",
    "GetTimedActivityTypeLimit",
    "GetTimeStamp",
    "GetTimeString",
    "GetTimeToShadowyConnectionsResetInSeconds",
    "GetTimeUntilCanBeTrained",
    "GetTotalAchievementPoints",
    "GetTributePlayerClubRank",
    "GetTributePlayerExperienceInCurrentClubRank",
    "GetUnitAlliance",
    "GetUnitBuffInfo",
    "GetUnitClass",
    "GetUnitClassId",
    "GetUnitDisplayName",
    "GetUnitEffectiveLevel",
    "GetUnitLevel",
    "GetUnitName",
    "GetUnitPower",
    "GetUnitRace",
    "GetUnitRawWorldPosition",
    "GetUnitXP",
    "GetUnitZone",
    "GetUnitZoneIndex",
    "GetZoneId",
    "GetZoneNameById",
    "GetZoneSkyshardId",
    "GuiRoot",
    "HasActiveCompanion",
    "HasCraftBagAccess",
    "HasPendingCompanion",
    "IsCollectibleBlocked",
    "IsCollectibleUsable",
    "IsEndlessDungeonStarted",
    "IsESOPlusSubscriber",
    "IsInGamepadPreferredMode",
    "IsInstanceEndlessDungeon",
    "IsItemChargeable",
    "IsItemLinkRecipeKnown",
    "IsItemPlaceableFurniture",
    "IsItemRepairKit",
    "IsItemStolen",
    "IsUnitGrouped",
    "IsUnitInCombat",
    "IsUnitInDungeon",
    "IsUnitPvPFlagged",
    "JumpToSpecificHouse",
    "PlayEmoteByIndex",
    "PlaySound",
    "ReloadUI",
    "RequestJumpToHouse",
    "RequestTributeClubData",
    "SecurePostHook",
    "SetGameCameraUIMode",
    "TriggerTutorial",
    "UseCollectible",
    -- Zenimax objects
    "HUD_SCENE",
    "ZO_CachedStrFormat",
    "ZO_CallbackObject",
    "ZO_CheckButton_IsChecked",
    "ZO_CheckButton_SetCheckState",
    "ZO_CheckButton_SetLabelText",
    "ZO_CheckButton_SetToggleFunction",
    "ZO_CheckButtonLabel_SetTextColor",
    "ZO_ClearNumericallyIndexedTable",
    "ZO_ClearTable",
    ["ZO_ColorDef"] = {
        fields = {
            New = {read_only = true}
        }
    },
    ["ZO_ComboBox"] = {
        fields = {
            CreateItemEntry = {read_only = true}
        }
    },
    "ZO_CommaDelimitNumber",
    ["ZO_CompassFrame"] = {
        fields = {
            GetTop = {read_only = true},
            ClearAnchors = {read_only = true},
            SetAnchor = {read_only = true}
        }
    },
    "ZO_CreateStringId",
    "ZO_DeepTableCopy",
    "ZO_Dialogs_RegisterCustomDialog",
    "ZO_Dialogs_ShowDialog",
    "ZO_EndlessDungeonBuffSelector_Shared",
    "ZO_FastFormatDecimalNumber",
    "ZO_FormatUserFacingCharacterName",
    "ZO_FormatUserFacingDisplayName",
    "ZO_GetAllianceIcon",
    ["ZO_HiddenReasons"] = {
        fields = {
            New = {read_only = true}
        }
    },
    ["ZO_HUDFadeSceneFragment"] = {
        fields = {
            New = {read_only = true}
        }
    },
    "ZO_IsElementInNumericallyIndexedTable",
    "ZO_IsScryingUnlocked",
    "ZO_LinkHandler_CreateLink",
    "ZO_LinkHandler_ParseLink",
    "ZO_MailSendBodyField",
    "ZO_MailSendSubjectField",
    "ZO_MailSendToField",
    ["ZO_Object"] = {
        fields = {
            New = {read_only = true},
            Subclass = {read_only = true}
        }
    },
    ["ZO_ObjectPool"] = {
        fields = {
            New = {read_only = true}
        }
    },
    "ZO_PostHook",
    "ZO_PreHook",
    "ZO_PreHookHandler",
    "ZO_Provisioner",
    ["ZO_SavedVars"] = {
        fields = {
            NewAccountWide = {read_only = true}
        }
    },
    "ZO_SceneManager_ToggleHUDUIBinding",
    "ZO_ScrollList_AddDataType",
    "ZO_ScrollList_Clear",
    "ZO_ScrollList_Commit",
    "ZO_ScrollList_CreateDataEntry",
    "ZO_ScrollList_EnableSelection",
    "ZO_ScrollList_GetDataList",
    "ZO_ShowSealStore",
    "ZO_SmallGroupAnchorFrame",
    "ZO_SocialList_GetPlatformTextureFunctions",
    "ZO_SocialList_GetRowColors",
    "ZO_StatusBar_InitializeDefaultColors",
    ["ZO_TargetUnitFramereticleover"] = {
        fields = {
            ClearAnchors = {read_only = true},
            SetAnchor = {read_only = true}
        }
    },
    "ZO_TimerBar",
    "ZO_Tooltips_HideTextTooltip",
    "ZO_Tooltips_ShowTextTooltip",
    -- Zenimax functions
    "zo_callLater",
    "zo_floor",
    "zo_iconFormat",
    "zo_min",
    "zo_max",
    "zo_round",
    "zo_roundToNearest",
    "zo_strfind",
    "zo_strformat",
    "zo_strjoin",
    "zo_strlen",
    "zo_strsplit",
    "zo_strupper",
    -- luacheck misses these for some reason
    "math.log10",
    "math.pow"
}
