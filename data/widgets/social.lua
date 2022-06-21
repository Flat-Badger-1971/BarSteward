local BS = _G.BarSteward

local function addToTooltip(friendList, textureFunctions)
    local tt = ""

    for _, friend in ipairs(friendList) do 
        local textColour = BS.ARGBConvert2(ZO_SocialList_GetRowColors(friend, false))
        local noChar = not friend.hasCharacter or (zo_strlen(friend.characterName) <= 0)

        tt = tt .. BS.LF .. zo_iconFormat(textureFunctions.playerStatusIcon(friend.status))
        tt = tt .. textColour
        tt = tt .. (noChar and "" or zo_iconFormat(textureFunctions.allianceIcon(friend.alliance)))
        tt = tt .. ZO_FormatUserFacingDisplayName(friend.displayName)
        tt = tt .. (noChar and "" or (" - " .. friend.formattedZone)) .. "|r"
    end

    return tt
end

BS.widgets[BS.W_FRIENDS] = {
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
        tt = tt .. addToTooltip(offline, textureFunctions)
        tt = tt .. addToTooltip(other, textureFunctions)

        widget.tooltip = tt .. "|r"
        widget:SetValue(#online .. "/" .. #masterList)
        widget:SetColour(unpack(BS.Vars.Controls[BS.W_FRIENDS].Colour or BS.Vars.DefaultColour))

        if (event == _G.EVENT_FRIEND_PLAYER_STATUS_CHANGED) then
            if (newStatus == _G.PLAYER_STATUS_ONLINE) then
                if (BS.Vars.Controls[BS.W_FRIENDS].Announce) then
                    if (BS.Vars.Controls[BS.W_FRIENDS].Exclude) then
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
    customSettings = function()
        local masterList = FRIENDS_LIST_MANAGER:GetMasterList()
        local settings = {
            [1] = {
                type = "description",
                title = GetString(_G.BARSTEWARD_ANNOUNCEMENT_FRIEND)
            }
        }
        local idx = 2

        for _, friend in ipairs(masterList) do
            local dname = ZO_FormatUserFacingDisplayName(friend.displayName)
            settings[idx] = {
                type = "checkbox",
                name = dname,
                getFunc = function()
                    return BS.Vars.FriendAnnounce[dname]
                end,
                setFunc = function(value)
                    BS.Vars.FriendAnnounce[dname] = value
                end
            }

            idx = idx + 1
        end

        return settings
    end
}
