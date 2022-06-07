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
    ["SCENE_MANAGER"] = {
        fields = {
            GetCurrentScene = {read_only = true},
            GetScene = {read_only = true},
            GetSceneGroup = { read_only = true },
            RegisterCallback = { read_only = true },
            Show = { read_only = true }
        }
    },
    ["WINDOW_MANAGER"] = {
        fields = {
            CreateTopLevelWindow = {read_only = true},
            CreateControl = {read_only = true},
            CreateControlFromVirtual = {read_only = true}
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
    -- events
    "EVENT_ACTION_LAYER_POPPED",
    "EVENT_ACTION_LAYER_PUSHED",
    "EVENT_ACTIVE_COMPANION_STATE_CHANGED",
    "EVENT_ADD_ON_LOADED",
    "EVENT_COMPANION_ACTIVATED",
    "EVENT_COMPANION_DEACTIVATED",
    "EVENT_COMPANION_EXPERIENCE_GAIN",
    "EVENT_COMPANION_RAPPORT_UPDATE",
    "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
    "EVENT_PLAYER_ACTIVATED",
    "EVENT_POWER_UPDATE",
    "EVENT_UNIT_CREATED",
    "EVENT_UNIT_DESTROYED",
    "EVENT_ZONE_CHANGED",
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
    "GetNumBuffs",
    "GetNumChampionXPInChampionPoint",
    "GetNumExperiencePointsInCompanionLevel",
    "GetNumSmithingResearchLines",
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
    "GetTimedActivityMaxProgress",
    "GetTimedActivityName",
    "GetTimedActivityProgress",
    "GetTimedActivityType",
    "GetTimedActivityTypeLimit",
    "GetTimeString",
    "GetTimeUntilCanBeTrained",
    "GetUnitAlliance",
    "GetUnitBuffInfo",
    "GetUnitClass",
    "GetUnitClassId",
    "GetUnitName",
    "GetUnitPower",
    "GetUnitRace",
    "GetUnitZone",
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
    "PlaySound",
    "ReloadUI",
    "TriggerTutorial",
    "UseCollectible",
    -- Zenimax objects
    "HUD_SCENE",
    "ZO_CachedStrFormat",
    "ZO_CreateStringId",
    "ZO_GetAllianceIcon",
    "ZO_strformat",
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
    "ZO_PreHook",
    "ZO_Provisioner",
    "ZO_Dialogs_RegisterCustomDialog",
    ["ZO_SavedVars"] = {
        fields = {
            NewAccountWide = {read_only = true}
        }
    },
    "ZO_Dialogs_ShowDialog",
    "ZO_SmallGroupAnchorFrame",
    "ZO_TimerBar",
    "ZO_Tooltips_HideTextTooltip",
    "ZO_Tooltips_ShowTextTooltip",
    -- Zenimax functions
    "zo_callLater",
    "zo_roundToNearest",
    "zo_strformat",
    "zo_strsplit"
}