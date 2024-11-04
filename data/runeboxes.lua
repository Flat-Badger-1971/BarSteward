local BS = _G.BarSteward

local RUNEBOX_FRAGMENTS = {
    [5887] = {cid = 5887, total = 10, fragments = {147659}}, --  Jester's Festival Joke Popper
    [6292] = {cid = 6292, total = 10, fragments = {147930}}, -- Peryite Skeevemaster
    [6381] = {cid = 6381, total = 10, fragments = {147929}}, -- Grisly Mummy Tabby
    [6643] = {cid = 6643, total = 10, fragments = {153535}}, -- Skeletal Marionette
    [124658] = {cid = 1232, fragments = {124660, 124661, 124662, 124663, 124664, 124665, 124666}}, -- Dwarven Theodolite Pet
    [124659] = {cid = 1230, fragments = {124673, 124672, 124667, 124668, 124669, 124670, 124671}}, -- Sixth House Robe Costume
    [138784] = {cid = 5019, total = 21, fragments = {138783, 138785}}, -- Arena Gladiator Helm
    [139464] = {cid = 4996, fragments = {139450, 139451, 139452, 139453, 139454, 139455, 139456}}, -- Big-Eared Ginger Kitten Pet
    [139465] = {cid = 5047, fragments = {139457, 139458, 139459, 139460, 139461, 139462, 139463}}, -- Psijic Glowglobe Emote
    [141749] = {cid = 5656, fragments = {141748, 141742, 141743, 141744, 141745, 141746, 141747}}, -- Swamp Jelly
    [141750] = {cid = 5589, total = 51, fragments = {138783, 141751}}, -- Arena Gladiator Costume
    [146041] = {cid = 5746, total = 31, fragments = {138783, 146042}}, -- Area Gladiator Emote
    [147286] = {cid = 6064, total = 41, fragments = {138783, 147285}}, -- Elinhir Arena Lion
    [147499] = {cid = 6197, fragments = {147492, 147493, 147494, 147495, 147496, 147497, 147498}}, -- Guar Stomp Emote
    [147658] = {cid = 5885, total = 5, fragments = {147658}}, -- Festive Noise Maker
    [151940] = {cid = 6438, total = 21, fragments = {151939, 151938}}, -- Siegemaster's Close Helm
    [153537] = {cid = 6665, total = 51, fragments = {151939, 153536}}, -- Siegemaster's Uniform
    [166468] = {cid = 7595, total = 21, fragments = {138783, 166469}}, -- Reach Mage Ceremonial Skullcap
    [166960] = {cid = "166960", total = 50, fragments = {166466}}, -- Target Stone Husk
    [167305] = {cid = 8043, total = 51, fragments = {151939, 167303}}, -- Timbercrow Wanderer Costume
    [171472] = {cid = 8198, total = 10, fragments = {171469}}, -- Daggerfall Breton Terrier Pet
    [183195] = {cid = 9718, total = 31, fragments = {138783, 183194}}, -- Siegestomper Emote
    [171533] = {cid = 8655, total = 31, fragments = {151939, 171532}}, -- Rage of the Reach Emote
}

local COLLECTIBLE_FRAGMENTS = {
    [8079] = 10, -- Throwing Bones
    [8186] = 10, -- Microtized Verminous Fabricant
    [8888] = 50, -- Thrafey Debutante Gown
    [9006] = 5, -- Playful Prankster's Surprise Box
    [9389] = 10, -- Witch-Tamed Bear-Dog
    [9523] = 50, -- Replica Zenithar Adytum Gate
    [9797] = 50, -- Coral Haj Mota (25 Lures and 25 Decoys)
    [10235] = 5, -- Cadwell's Surprise Box
    [10912] = 50 -- Graht-Oak Squirrel
}

function BS.GetCollectibleId(bagId, slotIndex)
    local collectibleId = GetItemLinkContainerCollectibleId(GetItemLink(bagId, slotIndex))
    local quantity = 1

    if (collectibleId == 0) then
        local itemId = GetItemId(bagId, slotIndex)

        for runeboxItemId, fragmentData in pairs(RUNEBOX_FRAGMENTS) do
            if (ZO_IsElementInNumericallyIndexedTable(fragmentData.fragments, itemId)) then
                collectibleId = fragmentData.cid or GetItemLinkContainerCollectibleId(BS.MakeItemLink(runeboxItemId))
                quantity = fragmentData.total or #fragmentData.fragments
                break
            end
        end
    else
        quantity = COLLECTIBLE_FRAGMENTS[collectibleId] or 0
    end

    return collectibleId, quantity
end

local availableIds = {}

local function getAvailableIds()
    for _, data in pairs(RUNEBOX_FRAGMENTS) do
        availableIds[data.cid] = data.total or #data.fragments
    end

    for id, qty in pairs(COLLECTIBLE_FRAGMENTS) do
        availableIds[id] = qty
    end
end

function BS.GetNoneCollected(collecting)
    local collectingIds = {}

    for id, _ in pairs(collecting) do
        table.insert(collectingIds, id)
    end

    local uncollected = {}

    if (#availableIds == 0) then
        getAvailableIds()
    end

    for id, qty in pairs(availableIds) do
        if (not ZO_IsElementInNumericallyIndexedTable(collectingIds, id)) then
            local icon, name, unlocked

            if (type(id) == "string") then
                local link = BS.LC.MakeItemLink(tonumber(id))

                icon = GetItemLinkIcon(link)
                name = GetItemLinkName(link)
                unlocked = false
            else
                local data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id)

                name, icon = data:GetName(), data:GetIcon()
                unlocked = data:IsUnlocked()
            end

            if (not unlocked) then
                table.insert(uncollected, {name = name, icon = icon, quantity = qty})
            end
        end
    end

    table.sort(
        uncollected,
        function(a, b)
            return a.name < b.name
        end
    )

    return uncollected
end