local BS = _G.BarSteward

local function addToTooltip(friendList, textureFunctions)
    local tt = ""

    for _, friend in ipairs(friendList) do
        local textColourDef = ZO_SocialList_GetRowColors(friend, false)

        local noChar = not friend.hasCharacter or (zo_strlen(friend.characterName) <= 0)

        if (BS.Vars:GetCommon("FriendAnnounce", friend.displayName) == true and (friend.online)) then
            textColourDef = BS.COLOURS.ZOSGreen
        end

        local colourise = noChar and "" or BS.Icon(textureFunctions.allianceIcon(friend.alliance))

        tt = string.format("%s%s%s", tt, BS.LF, BS.Icon(textureFunctions.playerStatusIcon(friend.status)))
        colourise = string.format("%s%s", colourise, ZO_FormatUserFacingDisplayName(friend.displayName))
        colourise = string.format("%s%s", colourise, noChar and "" or (" - " .. friend.formattedZone))

        tt = string.format("%s%s", tt, textColourDef:Colorize(colourise))
    end

    return tt
end

BS.widgets[BS.W_FRIENDS] = {
    --v1.2.0
    name = "friends",
    update = function(widget, event, displayName, characterName, _, newStatus)
        local this = BS.W_FRIENDS
        local masterList = FRIENDS_LIST_MANAGER:GetMasterList()
        local offline, online, other = {}, {}, {}
        local tt = BS.Format(_G.SI_SOCIAL_MENU_CONTACTS)
        local textureFunctions = ZO_SocialList_GetPlatformTextureFunctions()

        for _, friend in ipairs(masterList) do
            if (friend.online) then
                table.insert(online, friend)
            elseif (friend.status == _G.PLAYER_STATUS_OFFLINE) then
                table.insert(offline, friend)
            else
                table.insert(other, friend)
            end
        end

        local ttt = addToTooltip(online, textureFunctions)
        ttt = ttt .. addToTooltip(other, textureFunctions)

        if (not BS.GetVar("OnlineOnly", this)) then
            ttt = ttt .. addToTooltip(offline, textureFunctions)
        end

        widget:SetTooltip(tt .. BS.COLOURS.White:Colorize(ttt))
        widget:SetValue(#online .. (BS.GetVar("HideLimit", this) and "" or ("/" .. #masterList)))
        widget:SetColour(BS.GetColour(this, true))

        if (event == _G.EVENT_FRIEND_PLAYER_STATUS_CHANGED) then
            if (newStatus == _G.PLAYER_STATUS_ONLINE) then
                if (BS.GetVar("Announce", this)) then
                    if (BS.Vars:GetCommon("FriendAnnounce", displayName) == true) then
                        local announce = true
                        local previousTime = BS.Vars:GetCommon("PreviousFriendTime", displayName) or (os.time() - 3600)
                        local debounceTime = (BS.GetVar("DebounceTime", this) or 5) * 60

                        if (os.time() - previousTime <= debounceTime) then
                            announce = false
                        end

                        BS.Vars:SetCommon(os.time(), "PreviousFriendTime", displayName)

                        if (announce == true) then
                            local dname = ZO_FormatUserFacingDisplayName(displayName) or displayName
                            if (BS.Vars:GetCommon("FriendAnnounce", dname)) then
                                local cname = ZO_FormatUserFacingDisplayName(characterName) or characterName

                                BS.Announce(
                                    GetString(_G.BARSTEWARD_FRIEND_ONLINE),
                                    zo_strformat(GetString(_G.BARSTEWARD_FRIEND_ONLINE_MESSAGE), cname, dname),
                                    this
                                )
                            end
                        end
                    end
                end
            end
        end

        return online
    end,
    event = {
        _G.EVENT_PLAYER_ACTIVATED,
        _G.EVENT_FRIEND_PLAYER_STATUS_CHANGED,
        _G.EVENT_PLAYER_STATUS_CHANGED,
        _G.EVENT_FRIEND_CHARACTER_ZONE_CHANGED
    },
    tooltip = BS.Format(_G.SI_GAMEPAD_SOCIAL_FOOTER_NUM_ONLINE),
    icon = "chatwindow/chat_friendsonline_up",
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(_G.MENU_CATEGORY_CONTACTS)
        else
            SCENE_MANAGER:Show("gamepad_friends")
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {0, 5, 10, 15, 20, 30, 40, 50, 60},
        varName = "DebounceTime",
        refresh = false,
        default = 5
    },
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_ONLINE_ONLY),
            tooltip = GetString(_G.BARSTEWARD_ONLINE_ONLY_TOOLTIP),
            getFunc = function()
                return BS.Vars.Controls[BS.W_FRIENDS].OnlineOnly or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_FRIENDS].OnlineOnly = value
                BS.RefreshWidget(BS.W_FRIENDS)
            end,
            width = "full",
            default = false
        },
        [2] = {
            type = "button",
            name = GetString(_G.BARSTEWARD_ANNOUNCEMENTS),
            func = function()
                SCENE_MANAGER:Show("hudui")
                SetGameCameraUIMode(true)
                local friends = BS.w_friends_list or BS.CreateFriendsTool()
                friends.fragment:SetHiddenForReason("disabled", false)
            end,
            width = "half"
        }
    }
}

local function isFriend(displayName)
    local friends = BS.Vars:GetCommon("GuildFriendAnnounce")

    for member, _ in pairs(friends) do
        if (member == displayName) then
            return true
        end
    end

    return false
end

local guildMasterList = {}

local function getMasterList()
    BS.Clear(guildMasterList)

    local guildId = BS.guildId
    local localPlayerIndex = GetPlayerGuildMemberIndex(guildId)
    local numGuildMembers = GetNumGuildMembers(guildId)

    for guildMemberIndex = 1, numGuildMembers do
        local displayName, _, _, status, _ = GetGuildMemberInfo(guildId, guildMemberIndex)
        local online = (status ~= _G.PLAYER_STATUS_OFFLINE)
        local isLocalPlayer = guildMemberIndex == localPlayerIndex
        local hasCharacter, rawCharacterName, zone, _, alliance = GetGuildMemberCharacterInfo(guildId, guildMemberIndex)

        local data = {
            index = guildMemberIndex,
            displayName = displayName,
            hasCharacter = hasCharacter,
            isLocalPlayer = isLocalPlayer,
            characterName = ZO_CachedStrFormat(_G.SI_UNIT_NAME, rawCharacterName),
            formattedZone = ZO_CachedStrFormat(_G.SI_ZONE_NAME, zone),
            alliance = alliance,
            formattedAllianceName = ZO_CachedStrFormat(_G.SI_ALLIANCE_NAME, GetAllianceName(alliance)),
            status = status,
            online = online
        }

        guildMasterList[guildMemberIndex] = data
    end
end

local function setGuildId(guildId)
    BS.guildId = guildId
    getMasterList()
end

local function findDataByDisplayName(displayName)
    for i = 1, #guildMasterList do
        local data = guildMasterList[i]
        if data.displayName == displayName then
            return data
        end
    end
end

BS.widgets[BS.W_GUILD_FRIENDS] = {
    --v1.2.18
    name = "guildFriends",
    update = function(widget, _, guildId, displayName, _, newStatus)
        local this = BS.W_GUILD_FRIENDS
        local masterList = BS.Vars:GetCommon("GuildFriendAnnounce")
        local online, offline, other = {}, {}, {}
        local oCount, tCount = 0, 0
        local tt = BS.Format(_G.BARSTEWARD_GUILD_FRIENDS)
        local textureFunctions = ZO_SocialList_GetPlatformTextureFunctions()

        for member, gid in pairs(masterList) do
            local current = BS.guildId

            if (current ~= gid) then
                setGuildId(gid)
            end

            local info = findDataByDisplayName(member)

            if (info) then
                if (info.online) then
                    table.insert(online, info)
                    oCount = oCount + 1
                elseif (info.status == _G.PLAYER_STATUS_OFFLINE) then
                    table.insert(offline, info)
                else
                    table.insert(other, info)
                    oCount = oCount + 1
                end

                tCount = tCount + 1
            end

            tCount = tCount + 1
        end

        local ttt = addToTooltip(online, textureFunctions)
        ttt = ttt .. addToTooltip(other, textureFunctions)

        if (not BS.GetVar("OnlineOnly", this)) then
            ttt = ttt .. addToTooltip(offline, textureFunctions)
        end

        widget:SetTooltip(tt .. BS.COLOURS.White:Colorize(ttt))
        widget:SetValue(oCount .. (BS.GetVar("HideLimit", this) and "" or ("/" .. tCount)))
        widget:SetColour(BS.GetColour(this, true))

        if (newStatus == _G.PLAYER_STATUS_ONLINE) then
            if (BS.GetVar("Announce", this) and isFriend(displayName)) then
                local announce = true
                local previousTime = BS.Vars:GetCommon("PreviousGuildFriendTime", displayName) or (os.time() - 3600)
                local debounceTime = (BS.GetVar("DebounceTime", this) or 5) * 60

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                BS.Vars:SetCommon(os.time(), "PreviousGuildFriendTime", displayName)

                if (announce == true) then
                    setGuildId(guildId)
                    local info = findDataByDisplayName(displayName)
                    local dname = ZO_FormatUserFacingDisplayName(displayName) or displayName
                    local cname = ZO_FormatUserFacingDisplayName(info.characterName) or info.characterName

                    BS.Announce(
                        GetString(_G.BARSTEWARD_GUILD_FRIEND_ONLINE),
                        zo_strformat(GetString(_G.BARSTEWARD_FRIEND_ONLINE_MESSAGE), cname, dname),
                        this
                    )
                end
            end
        end

        return online
    end,
    event = {
        _G.EVENT_PLAYER_ACTIVATED,
        _G.EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
    },
    tooltip = BS.Format(_G.BARSTEWARD_GUILD_FRIENDS_ONLINE),
    icon = "guild/guildheraldry_indexicon_crest_up",
    onLeftClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(_G.MENU_CATEGORY_GUILDS)
        else
            SCENE_MANAGER:Show("gamepad_guilds")
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {0, 5, 10, 15, 20, 30, 40, 50, 60},
        varName = "DebounceTime",
        refresh = false,
        default = 5
    },
    customSettings = {
        [1] = {
            type = "checkbox",
            name = GetString(_G.BARSTEWARD_ONLINE_ONLY),
            tooltip = GetString(_G.BARSTEWARD_ONLINE_ONLY_TOOLTIP),
            getFunc = function()
                return BS.Vars.Controls[BS.W_GUILD_FRIENDS].OnlineOnly or false
            end,
            setFunc = function(value)
                BS.Vars.Controls[BS.W_GUILD_FRIENDS].OnlineOnly = value
                if (BS.Vars.Controls[BS.W_GUILD_FRIENDS].Bar ~= 0) then
                    BS.RefreshWidget(BS.W_GUILD_FRIENDS)
                end
            end,
            width = "full",
            default = false
        },
        [2] = {
            type = "button",
            name = GetString(_G.BARSTEWARD_CONFIGURE),
            func = function()
                SCENE_MANAGER:Show("hudui")
                SetGameCameraUIMode(true)
                local friends = BS.w_guildfriends_list or BS.CreateGuildFriendsTool()
                friends.fragment:SetHiddenForReason("disabled", false)
            end,
            width = "half"
        }
    }
}
