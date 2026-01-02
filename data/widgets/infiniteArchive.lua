local BS = BarSteward

BS.widgets[BS.W_ARCHIVE_PORT] = {
    -- v2.0.3
    name = "archivePort",
    update = function(widget)
        widget:SetValue(BS.Icon("ava/ava_ram_slot_green"), "___")

        return 0
    end,
    event = EVENT_PLAYER_ACTIVATED,
    tooltip = GetString(BARSTEWARD_INFINITE_ARCHIVE_PORT),
    icon = "icons/poi/poi_endlessdungeon_complete",
    cooldown = true,
    onLeftClick = function()
        FastTravelToNode(BS.INFINITE_ARCHIVE_NODE_INDEX)
    end
}

local function wrap(value)
    return BS.COLOURS.White:Colorize(value)
end

local function getBuffs()
    local buffTypes = { ENDLESS_DUNGEON_BUFF_TYPE_VERSE, ENDLESS_DUNGEON_BUFF_TYPE_VISION }
    local buffEntries = {}

    for _, buffTypeV in ipairs(buffTypes) do
        local buffTable = ENDLESS_DUNGEON_MANAGER:GetAbilityStackCountTable(buffTypeV)
        local buffTypeTable = {}

        if (buffTable and next(buffTable)) then
            for abilityId, stackCount in pairs(buffTable) do
                local buffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
                local buffData = {
                    abilityId = abilityId,
                    abilityName = GetAbilityName(abilityId, "player"),
                    buffType = buffType,
                    iconTexture = GetAbilityIcon(abilityId),
                    isAvatarVision = isAvatarVision,
                    stackCount = stackCount
                }

                table.insert(buffTypeTable, buffData)
                table.sort(
                    buffTypeTable,
                    function(a, b)
                        return a.abilityName > b.abilityName
                    end
                )
            end
        end

        buffEntries[buffTypeV] = buffTypeTable
    end

    return buffEntries
end

local arc = BS.LC.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. ENDLESS_DUNGEON_COUNTER_TYPE_ARC])
local currentScore = 0
local arcIcon = "endlessdungeon/icon_progression_arc"
local cycleIcon = "endlessdungeon/icon_progression_cycle"
local stageIcon = "endlessdungeon/icon_progression_stage"

BS.widgets[BS.W_INFINITE_ARCHIVE_PROGRESS] = {
    -- v2.0.9
    name = "infiniteArchiveBar",
    update = function(widget, event, score)
        local this = BS.W_INFINITE_ARCHIVE_PROGRESS

        if (not ENDLESS_DUNGEON_MANAGER:IsPlayerInEndlessDungeon()) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(0, 0, 1, "")
            else
                widget:SetValue("0%")
                widget:SetColour(BS.GetColour(this, true))
            end

            return true
        end

        if (event == "ScoreChanged") then
            currentScore = score
        elseif (score == 0) then
            currentScore = ENDLESS_DUNGEON_MANAGER:GetScore()
        end

        local stageCounter, cycleCounter, arcCounter = ENDLESS_DUNGEON_MANAGER:GetProgression()
        local maxProgressPerArc =
            BS.INFINITE_ARCHIVE_MAX_COUNTS[ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE] *
            BS.INFINITE_ARCHIVE_MAX_COUNTS[ENDLESS_DUNGEON_COUNTER_TYPE_ARC]
        local currentProgress =
            (stageCounter - 1) +
            ((cycleCounter - 1) * BS.INFINITE_ARCHIVE_MAX_COUNTS[ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE])
        local pc = math.ceil((currentProgress / maxProgressPerArc) * 100)

        if (BS.GetVar("Progress", this)) then
            widget:SetProgress(currentProgress, 0, maxProgressPerArc, string.format("%s %d", arc, arcCounter))
        else
            if (BS.GetVar("UseIcons", this)) then
                widget:SetValue(
                    string.format(
                        "%s %d %s %d %s %d",
                        BS.Icon(arcIcon),
                        arcCounter,
                        BS.Icon(cycleIcon),
                        cycleCounter,
                        BS.Icon(stageIcon),
                        stageCounter
                    )
                )
            else
                widget:SetValue(
                    string.format("%s %d: %s", arc, arcCounter, BS.COLOURS.Yellow:Colorize(tostring(pc) .. "%"))
                )
            end

            widget:SetColour(BS.GetColour(this, true))
        end

        local ttt = GetString(BARSTEWARD_INFINITE_ARCHIVE_PROGRESS) .. BS.LF .. BS.LF

        local threads = ENDLESS_DUNGEON_MANAGER:GetAttemptsRemaining()
        ttt =
            ttt ..
            wrap(
                ZO_CachedStrFormat(
                    GetString(SI_ENDLESS_DUNGEON_ATTEMPTS_REMAINING_CHANGED_ANNOUNCEMENT_SUBTITLE),
                    threads
                )
            )
        ttt = ttt .. BS.LF .. BS.LF
        ttt =
            ttt .. wrap(BS.LC.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. ENDLESS_DUNGEON_COUNTER_TYPE_STAGE]) .. ": ")
        ttt = ttt .. stageCounter .. BS.LF
        ttt =
            ttt .. wrap(BS.LC.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE]) .. ": ")
        ttt = ttt .. cycleCounter .. BS.LF
        ttt = ttt .. wrap(arc .. ": ")
        ttt = ttt .. arcCounter .. " (" .. pc .. "%)" .. BS.LF
        ttt = ttt .. wrap(BS.LC.Format(SI_ENDLESS_DUNGEON_SUMMARY_SCORE_HEADER) .. ":") .. "  " .. currentScore .. BS.LF

        local buffs = getBuffs()
        local function addBuffs(buffData)
            local text = ""
            for _, buff in ipairs(buffData) do
                text = string.format("%s%s ", text, BS.Icon(buff.iconTexture))
                text = string.format("%s%s", text, wrap(buff.abilityName))

                if (buff.stackCount > 1) then
                    text = string.format("%s (%d)", text, buff.stackCount)
                end

                text = text .. BS.LF
            end

            -- remove the trailing LF
            return text:sub(1, #text - 1)
        end

        if (#buffs > 0) then
            local visions = buffs[ENDLESS_DUNGEON_BUFF_TYPE_VISION]
            local verses = buffs[ENDLESS_DUNGEON_BUFF_TYPE_VERSE]

            if (#visions + #verses > 0) then
                ttt = ttt .. BS.LF
            end

            if (#visions > 0) then
                ttt = ttt .. BS.LC.Format(SI_ENDLESS_DUNGEON_SUMMARY_VISIONS_HEADER) .. BS.LF
                ttt = ttt .. addBuffs(visions) .. (#verses > 0 and BS.LF or "")
            end

            if (#verses > 0) then
                ttt = ttt .. BS.LC.Format(SI_ENDLESS_DUNGEON_SUMMARY_VERSES_HEADER) .. BS.LF
                ttt = ttt .. addBuffs(verses)
            end
        else
            -- remove the trailing LF
            ttt = ttt:sub(1, #ttt - 1)
        end

        widget:SetTooltip(ttt)

        return false
    end,
    gradient = function()
        local startg = { GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_START) }
        local endg = { GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_STATUS_BAR_END) }
        local s = BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].GradientEnd or endg

        return s, e
    end,
    events = EVENT_PLAYER_ACTIVATED,
    callback = {
        [ENDLESS_DUNGEON_MANAGER] = {
            { event = "DungeonStarted",           label = "" },
            { event = "AttemptsRemainingChanged", label = "" },
            { event = "ProgressionChanged",       label = "" },
            { event = "BuffStackCountChanged",    label = "" },
            { event = "ScoreChanged",             label = "ScoreChanged" }
        }
    },
    icon = arcIcon,
    tooltip = GetString(BARSTEWARD_INFINITE_ARCHIVE_PROGRESS),
    hideWhenEqual = true,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(BARSTEWARD_USE_ICONS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].UseIcons or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].UseIcons = value
                BS.RefreshBar(BS.W_INFINITE_ARCHIVE_PROGRESS)
            end,
            disabled = function()
                return BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].Progress
            end,
            default = false,
            width = "full"
        },
        [3] = {
            name = BS.LC.Format(BARSTEWARD_INFINITE_ARCHIVE_SHOW),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].Autohide or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_PROGRESS].Autohide = value
                BS.RefreshBar(BS.W_INFINITE_ARCHIVE_PROGRESS)
            end,
            width = "full",
            default = false
        }
    }
}

BS.widgets[BS.W_INFINITE_ARCHIVE_SCORE] = {
    -- v2.0.10
    name = "infiniteArchiveScore",
    update = function(widget, event, score)
        if (type(BS.Vars.EndlessHighest) == "number") then
            BS.Vars.EndlessHighest = {
                [ENDLESS_DUNGEON_GROUP_TYPE_SOLO] = 0,
                [ENDLESS_DUNGEON_GROUP_TYPE_DUO] = BS.Vars.EndlessHighest
            }
        elseif (not BS.Vars.EndlessHighest) then
            BS.Vars.EndlessHighest = {}
        end

        local groupType = GetEndlessDungeonGroupType()
        local this = BS.W_INFINITE_ARCHIVE_SCORE

        if (not ENDLESS_DUNGEON_MANAGER:IsPlayerInEndlessDungeon()) then
            widget:SetValue(ENDLESS_DUNGEON_MANAGER:GetScore())
            widget:SetColour(BS.GetColour(this, true))

            return true
        end

        if (event == "ScoreChanged") then
            currentScore = score
        end

        if (currentScore < 2) then
            currentScore = ENDLESS_DUNGEON_MANAGER:GetScore()
        end

        widget:SetValue(currentScore)
        widget:SetColour(BS.GetColour(this, true))

        if (currentScore > (BS.Vars.EndlessHighest[groupType] or 0)) then
            BS.Vars.EndlessHighest[groupType] = currentScore
        end

        local solo = " " .. BS.LC.Format(SI_ENDLESSDUNGEONGROUPTYPE0) .. ""
        local duo = " " .. BS.LC.Format(SI_ENDLESSDUNGEONGROUPTYPE1) .. ""
        local soloScore = BS.Vars.EndlessHighest[ENDLESS_DUNGEON_GROUP_TYPE_SOLO] or 0
        local duoScore = BS.Vars.EndlessHighest[ENDLESS_DUNGEON_GROUP_TYPE_DUO] or 0
        local ttt = GetString(BARSTEWARD_INFINITE_ARCHIVE_SCORE) .. BS.LF
        local yellow = BS.COLOURS.Yellow

        ttt = ttt .. BS.COLOURS.White:Colorize(BS.LC.Format(BARSTEWARD_HIGHEST)) .. BS.LF
        ttt =
            string.format(
                "%s%s: %s%s%s: %s",
                ttt,
                solo,
                yellow:Colorize(soloScore),
                BS.LF,
                duo,
                yellow:Colorize(duoScore)
            )

        widget:SetTooltip(ttt)

        return false
    end,
    events = EVENT_PLAYER_ACTIVATED,
    callback = {
        [ENDLESS_DUNGEON_MANAGER] = {
            { event = "ScoreChanged", label = "ScoreChanged" },
            { event = "StateChanged", label = "StageChanged" }
        }
    },
    icon = "campaign/overview_indexicon_scoring_up",
    tooltip = GetString(BARSTEWARD_INFINITE_ARCHIVE_SCORE),
    hideWhenEqual = true,
    customSettings = {
        [1] = {
            name = BS.LC.Format(BARSTEWARD_INFINITE_ARCHIVE_SHOW),
            type = "checkbox",
            getFunc = function()
                return BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_SCORE].Autohide or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_INFINITE_ARCHIVE_SCORE].Autohide = value
                BS.RefreshBar(BS.W_INFINITE_ARCHIVE_SCORE)
            end,
            width = "full",
            default = false
        }
    }
}
