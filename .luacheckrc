std = "min"
max_line_length = 160

-- globals used within addons
--globals = {"CF"}
read_globals = {
    ["CALLBACK_MANAGER"] = {
        fields = {
            FireCallbacks = {read_only = true}
        }
    },
    ["CHAMPION_DATA_MANAGER"] = {
        fields = {
            FindChampionDisciplineDataById = {read_only = true},
            FindChampionDisciplineDataByType = {read_only = true}
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
	["FRIENDS_LIST_MANAGER"] = {
		fields = {
			GetMasterList = {read_only = true}
		}
	},
	["REWARDS_MANAGER"] = {
		fields = {
			GetInfoForReward = {read_only = true}
		}
	},
    ["SCENE_MANAGER"] = {
        fields = {
            GetCurrentScene = {read_only = true},
            GetScene = {read_only = true},
            GetSceneGroup = {read_only = true},
            IsInUIMode = {read_only = true},
            RegisterCallback = {read_only = true},
            SetInUIMode = {read_only = true},
            Show = {read_only = true}
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
    ["ZO_ComboBox"] = {
        fields = {
            CreateItemEntry = {read_only = true}
        }
    },
    ["ZO_CompassFrame"] = {
        fields = {
            GetTop = {read_only = true},
            ClearAnchors = {read_only = true},
            SetAnchor = {read_only = true}
        }
    },
    ["ZO_Object"] = {
        fields = {
            New = {read_only = true},
            Subclass = {read_only = true}
        }
    },
    ["ZO_TargetUnitFramereticleover"] = {
        fields = {
            ClearAnchors = {read_only = true},
            SetAnchor = {read_only = true}
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
    "FormatIntegerWithDigitGrouping",
    "GetBagSize",
    "GetNumBagUsedSlots",
    "GetCVar",
    "GetString",
    "GuiRoot",
    "unpack",
    --API
    "CreateSimpleAnimation",
    "DoesAntiquityHaveLead",
    "DoesUnitExist",
    "EndInteraction",
    "GetAbilityIcon",
    "GetAbilityName",
    "GetActiveCollectibleByType",
    "GetActiveCompanionDefId",
    "GetActiveCompanionLevelInfo",
    "GetActiveCompanionRapport",
    "GetActiveCompanionRapportLevel",
    "GetActiveCompanionRapportLevelDescription",
    "GetAllianceColor",
    "GetAllianceName",
    "GetAnimationManager",
    "GetAntiquityDifficulty",
    "GetAntiquityLeadIcon",
    "GetAntiquityLeadTimeRemainingSeconds",
    "GetAntiquityName",
    "GetAntiquityQuality",
    "GetAntiquityZoneId",
    "GetChampionDisciplineId",
    "GetChampionDisciplineName",
    "GetChampionPointPoolForRank",
    "GetClassIcon",
    "GetCollectibleCooldownAndDuration",
    "GetCollectibleInfo",
    "GetCompanionCollectibleId",
    "GetCompanionName",
    "GetCurrencyAmount",
    "GetFenceLaunderTransactionInfo",
    "GetFishingLure",
    "GetFishingLureInfo",
    "GetFramerate",
    "GetFrameTimeMilliseconds",
	"GetFriendInfo",
    "GetGameCameraInteractableActionInfo",
    "GetGameCameraPickpocketingBonusInfo",
    "GetInteractionType",
    "GetItemCondition",
    "GetItemLinkName",
    "GetItemName",
    "GetItemType",
    "GetLatency",
    "GetMapContentType",
    "GetMaximumRapport",
    "GetMaxRecipeIngredients",
    "GetMaxSimultaneousSmithingResearch",
    "GetMinimumRapport",
    "GetNextAntiquityId",
    "GetNonCombatBonus",
    "GetNumBuffs",
    "GetNumChampionDisciplines",
    "GetNumChampionXPInChampionPoint",
    "GetNumExperiencePointsInCompanionLevel",
	"GetNumFriends",
    "GetNumSmithingResearchLines",
	"GetNumTimedActivityRewards",
    "GetPendingCompanionDefId",
    "GetPlayerChampionPointsEarned",
    "GetPlayerChampionXP",
    "GetPulseTimeline",
    "GetRecallCooldown",
    "GetRecipeIngredientItemInfo",
    "GetRepairAllCost",
    "GetRidingStats",
    "GetSlotStackSize",
    "GetSmithingResearchLineInfo",
    "GetSmithingResearchLineTraitInfo",
    "GetSmithingResearchLineTraitTimes",
	"GetSoulGemInfo",
    "GetTimedActivityMaxProgress",
    "GetTimedActivityName",
    "GetTimedActivityProgress",
	"GetTimedActivityRewardInfo",
    "GetTimedActivityType",
    "GetTimedActivityTypeLimit",
    "GetTimeString",
    "GetTimeUntilCanBeTrained",
    "GetUnitAlliance",
    "GetUnitBuffInfo",
    "GetUnitClass",
    "GetUnitClassId",
	"GetUnitEffectiveLevel",
    "GetUnitName",
    "GetUnitPower",
    "GetUnitRace",
    "GetUnitZone",
    "GetZoneNameById",
    "HasActiveCompanion",
    "HasPendingCompanion",
    "IsCollectibleBlocked",
    "IsCollectibleUsable",
    "IsESOPlusSubscriber",
    "IsInGamepadPreferredMode",
    "IsItemRepairKit",
    "IsItemStolen",
    "IsUnitGrouped",
    "IsUnitPvPFlagged",
	"PlayEmoteByIndex",
    "PlaySound",
    "ReloadUI",
	"SetGameCameraUIMode",
    "TriggerTutorial",
    "UseCollectible",
    -- Zenimax objects
    "HUD_SCENE",
    "ZO_CachedStrFormat",
    "ZO_CreateStringId",
	"ZO_DeepTableCopy",
	"ZO_Dialogs_RegisterCustomDialog",
    "ZO_Dialogs_ShowDialog",
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
    "ZO_min",
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
    "ZO_SmallGroupAnchorFrame",
	"ZO_SocialList_GetPlatformTextureFunctions",
	"ZO_SocialList_GetRowColors",
	"ZO_strformat",
    "ZO_TimerBar",
    "ZO_Tooltips_HideTextTooltip",
    "ZO_Tooltips_ShowTextTooltip",
    -- Zenimax functions
    "zo_callLater",
    "zo_iconFormat",
    "zo_roundToNearest",
    "zo_strformat",
	"zo_strlen",
    "zo_strsplit",
    -- luacheck misses this one for some reason
    "math.log10"
}
