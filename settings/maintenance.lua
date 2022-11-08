local BS = _G.BarSteward
BS.forDeletion = {}

function BS.GetMaintenanceSettings()
    local controls = {
        [1] = {
            type = "description",
            text = "|cff0000" .. GetString(_G.BARSTEWARD_DELETE) .. "|r"
        }
    }
    local characters = BS.Vars.CharacterList
    local thisCharacter = GetUnitName("player")

    for character, _ in pairs(characters) do
        if (character ~= thisCharacter) then
            controls[#controls + 1] = {
                type = "checkbox",
                name = ZO_FormatUserFacingCharacterName(character),
                getFunc = function()
                    return BS.forDeletion[character]
                end,
                setFunc = function(value)
                    BS.forDeletion[character] = value
                end,
                default = false,
                width = "full"
            }
        end
    end

    controls[#controls + 1] = {
        type = "button",
        name = ZO_CachedStrFormat("<<C:1>>", GetString(_G.SI_KEYCODE19)),
        func = function()
            local hasCharactersForDeletion = false

            for _, value in pairs(BS.forDeletion) do
                if (value) then
                    hasCharactersForDeletion = true
                    break
                end
            end

            if (hasCharactersForDeletion) then
                ZO_Dialogs_ShowDialog(BS.Name .. "Delete")
            end
        end,
        width = "full",
        requiresReload = true
    }

    BS.options[#BS.options + 1] = {
        type = "submenu",
        name = GetString(_G.BARSTEWARD_MAINTENANCE),
        controls = controls,
        reference = "Maintenance",
        icon = "/esoui/art/compass/ava_mine_daggerfall.dds"
    }
end

function BS.DeleteTrackedData()
    local other = BS.Vars.OtherCurrencies
    local trackers = BS.Vars.Trackers

    for character, delete in pairs(BS.forDeletion) do
        if (delete) then
            BS.Vars.CharacterList[character] = nil

            for _, chars in pairs(other) do
                if (chars[character]) then
                    chars[character] = nil
                end
            end

            for _, chars in pairs(trackers) do
                if (chars[character]) then
                    chars[character] = nil
                end
            end

            if (BS.Vars.Gold[character]) then
                BS.Vars.Gold[character] = nil
            end

            if (BS.Vars.dailyQuests[character]) then
                BS.Vars.dailyQuests[character] = nil
            end
        end
    end

    BS.forDeletion = {}

    zo_callLater(
        function()
            ZO_Dialogs_ShowDialog(BS.Name .. "Reload")
        end,
        500
    )
end
