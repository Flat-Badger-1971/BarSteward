local BS = _G.BarSteward

BS.widgets[BS.W_FRIENDS] = {
    name = "friends",
    update = function(widget, event, playerName, characterName, _, newStatus)
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
                        if (not BS.Vars.Controls[BS.W_FRIENDS].Exclude[playerName:lower()]) then
                            BS.Announce(
                                GetString(_G.BARSTEWARD_FRIEND_ONLINE),
                                ZO_strformat(GetString(_G.BARSTEWARD_FRIEND_ONLINE_MESSAGE), characterName),
                                BS.W_FRIENDS
                            )
                        end
                    end
                end
            end
        end

        return online
    end,
    event = {_G.EVENT_PLAYER_ACTIVATED, _G.EVENT_FRIEND_PLAYER_STATUS_CHANGED, _G.EVENT_PLAYER_STATUS_CHANGED},
    tooltip = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_GAMEPAD_SOCIAL_FOOTER_NUM_ONLINE)),
    icon = "/esoui/art/chatwindow/chat_friendsonline_up.dds",
    onClick = function()
        if (not IsInGamepadPreferredMode()) then
            SCENE_MANAGER:Show("friendsList")
        else
            SCENE_MANAGER:Show("gamepad_friends")
        end
    end
}
