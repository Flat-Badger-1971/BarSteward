local BS = _G.BarSteward

BS.widgets[BS.W_FRIENDS] = {
    name = "friends",
    update = function(widget, event, displayName, characterName, _, newStatus)
        local masterList = FRIENDS_LIST_MANAGER:GetMasterList()
        local online = 0
        local tt = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_SOCIAL_MENU_CONTACTS)) .. "|cffffff"
        local textureFunctions = ZO_SocialList_GetPlatformTextureFunctions()

        for _, friend in ipairs(masterList) do
            local noChar = not friend.hasCharacter or (zo_strlen(friend.characterName) <= 0)

            if (friend.online) then
                online = online + 1
            end

            local textColour = ZO_SocialList_GetRowColors(friend, false)

            textColour = BS.ARGBConvert2(textColour)

            tt = tt .. BS.LF .. zo_iconFormat(textureFunctions.playerStatusIcon(friend.status))
            tt = tt .. textColour
            tt = tt .. (noChar and "" or zo_iconFormat(textureFunctions.allianceIcon(friend.alliance)))
            tt = tt .. ZO_FormatUserFacingDisplayName(friend.displayName)
            tt = tt .. (noChar and "" or (" - " .. friend.formattedZone)) .. "|r"
        end

        widget.tooltip = tt .. "|r"
        widget:SetValue(online .. "/" .. #masterList)
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
                            if (not BS.Vars.Controls[BS.W_FRIENDS].Exclude[dname:lower()]) then
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
    }
}
