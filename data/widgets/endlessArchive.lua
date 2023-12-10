local BS = _G.BarSteward

BS.widgets[BS.W_ARCHIVE_PORT] = {
    -- v2.0.3
    name = "archivePort",
    update = function(widget)
        widget:SetValue(BS.Icon("ava/ava_ram_slot_green"), "___")

        return 0
    end,
    event = _G.EVENT_PLAYER_ACTIVATED,
    tooltip = GetString(_G.BARSTEWARD_ENDLESS_ARCHIVE_PORT),
    icon = "icons/poi/poi_endlessdungeon_complete",
    cooldown = true,
    onClick = function()
        FastTravelToNode(BS.ENDLESS_ARCHIVE_NODE_INDEX)
    end
}

local function wrap(value)
    return "|cf9f9f9" .. value .. "|r"
end

local function getBuffs()
    local buffTypes = {_G.ENDLESS_DUNGEON_BUFF_TYPE_VERSE, _G.ENDLESS_DUNGEON_BUFF_TYPE_VISION}
    local buffEntries = {}

    for _, buffTypeV in ipairs(buffTypes) do
        local buffTable = ENDLESS_DUNGEON_MANAGER:GetAbilityStackCountTable(buffTypeV)
        local buffTypeTable = {}

        if (buffTable and next(buffTable)) then
            for abilityId, stackCount in pairs(buffTable) do
                local buffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
                local buffData = {
                    abilityId = abilityId,
                    abilityName = GetAbilityName(abilityId),
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

local arc = BS.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. _G.ENDLESS_DUNGEON_COUNTER_TYPE_ARC])
local currentScore = 0

BS.widgets[BS.W_ENDLESS_ARCHIVE_PROGRESS] = {
    -- v2.0.9
    name = "endlessArchiveBar",
    update = function(widget, event, score)
        local this = BS.W_ENDLESS_ARCHIVE_PROGRESS
        if (not ENDLESS_DUNGEON_MANAGER:IsPlayerInEndlessDungeon()) then
            if (BS.GetVar("Progress", this)) then
                widget:SetProgress(0, 0, 1, "")
            else
                widget:SetValue("0%")
                widget:SetColour(unpack(BS.GetColour(this)))
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
            BS.ENDLESS_ARCHIVE_MAX_COUNTS[_G.ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE] *
            BS.ENDLESS_ARCHIVE_MAX_COUNTS[_G.ENDLESS_DUNGEON_COUNTER_TYPE_ARC]
        local currentProgress =
            (stageCounter - 1) +
            ((cycleCounter - 1) * BS.ENDLESS_ARCHIVE_MAX_COUNTS[_G.ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE])
        local pc = math.ceil((currentProgress / maxProgressPerArc) * 100)

        if (BS.GetVar("Progress", this)) then
            widget:SetProgress(currentProgress, 0, maxProgressPerArc, string.format("%s %d", arc, arcCounter))
        else
            widget:SetValue(string.format("%s %d: |c%s%d%%|r", arc, arcCounter, BS.COLOURS.YELLOW, pc))
            widget:SetColour(unpack(BS.GetColour(this)))
        end

        local ttt = GetString(_G.BARSTEWARD_ENDLESS_ARCHIVE_PROGRESS) .. BS.LF .. BS.LF

        local threads = ENDLESS_DUNGEON_MANAGER:GetAttemptsRemaining()
        ttt =
            ttt ..
            wrap(
                ZO_CachedStrFormat(
                    GetString(_G.SI_ENDLESS_DUNGEON_ATTEMPTS_REMAINING_CHANGED_ANNOUNCEMENT_SUBTITLE),
                    threads
                )
            )
        ttt = ttt .. BS.LF .. BS.LF
        ttt =
            ttt .. wrap(BS.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. _G.ENDLESS_DUNGEON_COUNTER_TYPE_STAGE]) .. ": ")
        ttt = ttt .. stageCounter .. BS.LF
        ttt =
            ttt .. wrap(BS.Format(_G["SI_ENDLESSDUNGEONCOUNTERTYPE" .. _G.ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE]) .. ": ")
        ttt = ttt .. cycleCounter .. BS.LF
        ttt = ttt .. wrap(arc .. ": ")
        ttt = ttt .. arcCounter .. " (" .. pc .. "%)" .. BS.LF
        ttt = ttt .. wrap(BS.Format(_G.SI_ENDLESS_DUNGEON_SUMMARY_SCORE_HEADER) .. ":") .. "  " .. currentScore .. BS.LF

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
            local visions = buffs[_G.ENDLESS_DUNGEON_BUFF_TYPE_VISION]
            local verses = buffs[_G.ENDLESS_DUNGEON_BUFF_TYPE_VERSE]

            if (#visions + #verses > 0) then
                ttt = ttt .. BS.LF
            end

            if (#visions > 0) then
                ttt = ttt .. BS.Format(_G.SI_ENDLESS_DUNGEON_SUMMARY_VISIONS_HEADER) .. BS.LF
                ttt = ttt .. addBuffs(visions) .. (#verses > 0 and BS.LF or "")
            end

            if (#verses > 0) then
                ttt = ttt .. BS.Format(_G.SI_ENDLESS_DUNGEON_SUMMARY_VERSES_HEADER) .. BS.LF
                ttt = ttt .. addBuffs(verses)
            end
        else
            -- remove the trailing LF
            ttt = ttt:sub(1, #ttt - 1)
        end

        widget.tooltip = ttt

        return false
    end,
    gradient = function()
        local startg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_START)}
        local endg = {GetInterfaceColor(_G.INTERFACE_COLOR_TYPE_GENERAL, _G.INTERFACE_GENERAL_COLOR_STATUS_BAR_END)}
        local s = BS.Vars.Controls[BS.W_ENDLESS_ARCHIVE_PROGRESS].GradientStart or startg
        local e = BS.Vars.Controls[BS.W_ENDLESS_ARCHIVE_PROGRESS].GradientEnd or endg

        return s, e
    end,
    events = _G.EVENT_PLAYER_ACTIVATED,
    callback = {
        [ENDLESS_DUNGEON_MANAGER] = {
            {event = "DungeonStarted", label = ""},
            {event = "AttemptsRemainingChanged", label = ""},
            {event = "ProgressionChanged", label = ""},
            {event = "BuffStackCountChanged", label = ""},
            {event = "ScoreChanged", label = "ScoreChanged"}
        }
    },
    icon = "endlessdungeon/icon_progression_arc",
    tooltip = GetString(_G.BARSTEWARD_ENDLESS_ARCHIVE_PROGRESS),
    hideWhenEqual = true,
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_USE_PROGRESS),
            getFunc = function()
                return BS.Vars.Controls[BS.W_ENDLESS_ARCHIVE_PROGRESS].Progress or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_ENDLESS_ARCHIVE_PROGRESS].Progress = value
            end,
            requiresReload = true,
            default = false,
            width = "full"
        }
    }
}

BS.widgets[BS.W_ENDLESS_ARCHIVE_SCORE] = {
    -- v2.0.10
    name = "endlessArchiveScore",
    update = function(widget, event, score)
        local this = BS.W_ENDLESS_ARCHIVE_SCORE
        local immediate = event ~= "ScoreChanged"

        if (not ENDLESS_DUNGEON_MANAGER:IsPlayerInEndlessDungeon()) then
            widget:SetValue(ENDLESS_DUNGEON_MANAGER:GetScore())
            widget:SetColour(unpack(BS.GetColour(this)))

            return true
        end

        if (event == "ScoreChanged") then
            currentScore = score
        elseif (currentScore == 0) then
            currentScore = ENDLESS_DUNGEON_MANAGER:GetScore()
        end

        widget:SetValue(currentScore, nil, immediate)
        widget:SetColour(unpack(BS.GetColour(this)))

        return false
    end,
    events = _G.EVENT_PLAYER_ACTIVATED,
    callback = {
        [ENDLESS_DUNGEON_MANAGER] = {
            {event = "ScoreChanged", label = "ScoreChanged"}
        }
    },
    icon = "campaign/overview_indexicon_scoring_up",
    tooltip = GetString(_G.BARSTEWARD_ENDLESS_ARCHIVE_SCORE),
    hideWhenEqual = true
}
