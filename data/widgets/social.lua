local BS = _G.BarSteward

local function addToTooltip(friendList, textureFunctions)
    local tt = ""

    for _, friend in ipairs(friendList) do
        local textColour = BS.ARGBConvert2(ZO_SocialList_GetRowColors(friend, false))
        local noChar = not friend.hasCharacter or (zo_strlen(friend.characterName) <= 0)

        if (BS.Vars.FriendAnnounce) then
            if (BS.Vars.FriendAnnounce[friend.displayName] and friend.online) then
                textColour = BS.ARGBConvert(BS.Vars.DefaultOkColour)
            end
        end

        tt = tt .. BS.LF .. zo_iconFormat(textureFunctions.playerStatusIcon(friend.status))
        tt = tt .. textColour
        tt = tt .. (noChar and "" or zo_iconFormat(textureFunctions.allianceIcon(friend.alliance)))
        tt = tt .. ZO_FormatUserFacingDisplayName(friend.displayName)
        tt = tt .. (noChar and "" or (" - " .. friend.formattedZone)) .. "|r"
    end

    return tt
end

BS.widgets[BS.W_FRIENDS] = {
    --v1.2.0
    name = "friends",
    update = function(widget, event, displayName, characterName, _, newStatus)
        local masterList = FRIENDS_LIST_MANAGER:GetMasterList()
        local offline, online, other = {}, {}, {}
        local tt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_SOCIAL_MENU_CONTACTS)) .. "|cffffff"
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

        tt = tt .. addToTooltip(online, textureFunctions)
        tt = tt .. addToTooltip(other, textureFunctions)

        if (not BS.Vars.Controls[BS.W_FRIENDS].OnlineOnly) then
            tt = tt .. addToTooltip(offline, textureFunctions)
        end

        widget.tooltip = tt .. "|r"
        widget:SetValue(#online .. "/" .. #masterList)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_FRIENDS].Colour or BS.Vars.DefaultColour))

        if (event == _G.EVENT_FRIEND_PLAYER_STATUS_CHANGED) then
            if (newStatus == _G.PLAYER_STATUS_ONLINE) then
                if (BS.Vars.Controls[BS.W_FRIENDS].Announce) then
                    if (BS.Vars.FriendAnnounce[displayName]) then
                        local announce = true
                        local previousTime = BS.Vars.PreviousFriendTime[displayName] or (os.time() - 3600)
                        local debounceTime = (BS.Vars.Controls[BS.W_FRIENDS].DebounceTime or 5) * 60

                        if (os.time() - previousTime <= debounceTime) then
                            announce = false
                        end

                        BS.Vars.PreviousFriendTime[displayName] = os.time()

                        if (announce == true) then
                            local dname = ZO_FormatUserFacingDisplayName(displayName) or displayName
                            if (BS.Vars.FriendAnnounce[dname]) then
                                local cname = ZO_FormatUserFacingCharacterName(characterName) or characterName

                                BS.Announce(
                                    GetString(_G.BARSTEWARD_FRIEND_ONLINE),
                                    zo_strformat(GetString(_G.BARSTEWARD_FRIEND_ONLINE_MESSAGE), cname, dname),
                                    BS.W_FRIENDS
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
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_SOCIAL_FOOTER_NUM_ONLINE)),
    icon = "/esoui/art/chatwindow/chat_friendsonline_up.dds",
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(_G.MENU_CATEGORY_CONTACTS)
        else
            SCENE_MANAGER:Show("gamepad_friends")
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {
            0,
            5,
            10,
            15,
            20,
            30,
            40,
            50,
            60
        },
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
    local friends = BS.Vars.GuildFriendAnnounce

    for member, _ in pairs(friends) do
        if (member == displayName) then
            return true
        end
    end

    return false
end

BS.widgets[BS.W_GUILD_FRIENDS] = {
    --v1.2.18
    name = "guildFriends",
    update = function(widget, _, guildId, displayName, _, newStatus)
        local masterList = BS.Vars.GuildFriendAnnounce
        local online, offline, other = {}, {}, {}
        local oCount, tCount = 0, 0
        local tt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.BARSTEWARD_GUILD_FRIENDS)) .. "|cffffff"
        local textureFunctions = ZO_SocialList_GetPlatformTextureFunctions()

        for member, gid in pairs(masterList) do
            local current = GUILD_ROSTER_MANAGER:GetGuildId()

            if (current ~= gid) then
                GUILD_ROSTER_MANAGER:SetGuildId(gid)
            end

            local info = GUILD_ROSTER_MANAGER:FindDataByDisplayName(member)

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

        tt = tt .. addToTooltip(online, textureFunctions)
        tt = tt .. addToTooltip(other, textureFunctions)

        if (not BS.Vars.Controls[BS.W_GUILD_FRIENDS].OnlineOnly) then
            tt = tt .. addToTooltip(offline, textureFunctions)
        end

        widget.tooltip = tt .. "|r"
        widget:SetValue(oCount .. "/" .. tCount)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_FRIENDS].Colour or BS.Vars.DefaultColour))

        if (newStatus == _G.PLAYER_STATUS_ONLINE) then
            if (BS.Vars.Controls[BS.W_GUILD_FRIENDS].Announce and isFriend(displayName)) then
                local announce = true
                local previousTime = BS.Vars.PreviousGuildFriendTime[displayName] or (os.time() - 3600)
                local debounceTime = (BS.Vars.Controls[BS.W_GUILD_FRIENDS].DebounceTime or 5) * 60

                if (os.time() - previousTime <= debounceTime) then
                    announce = false
                end

                BS.Vars.PreviousGuildFriendTime[displayName] = os.time()

                if (announce == true) then
                    GUILD_ROSTER_MANAGER:SetGuildId(guildId)
                    local info = GUILD_ROSTER_MANAGER:FindDataByDisplayName(displayName)
                    local dname = ZO_FormatUserFacingDisplayName(displayName) or displayName
                    local cname = ZO_FormatUserFacingCharacterName(info.characterName) or info.characterName

                    BS.Announce(
                        GetString(_G.BARSTEWARD_GUILD_FRIEND_ONLINE),
                        zo_strformat(GetString(_G.BARSTEWARD_FRIEND_ONLINE_MESSAGE), cname, dname),
                        BS.W_GUILD_FRIENDS
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
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.BARSTEWARD_GUILD_FRIENDS_ONLINE)),
    icon = "/esoui/art/guild/guildheraldry_indexicon_crest_up.dds",
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SYSTEMS:GetObject("mainMenu"):ToggleCategory(_G.MENU_CATEGORY_GUILDS)
        else
            SCENE_MANAGER:Show("gamepad_guilds")
        end
    end,
    customOptions = {
        name = GetString(_G.BARSTEWARD_DEBOUNCE),
        tooltip = GetString(_G.BARSTEWARD_DEBOUNCE_DESC),
        choices = {
            0,
            5,
            10,
            15,
            20,
            30,
            40,
            50,
            60
        },
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
