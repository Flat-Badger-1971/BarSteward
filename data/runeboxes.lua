local BS = _G.BarSteward

local RUNEBOX_FRAGMENTS = {
    [124658] = {cid = 1232, fragments = {124660, 124661, 124662, 124663, 124664, 124665, 124666}},
    [124659] = {cid = 1230, fragments = {124673, 124672, 124667, 124668, 124669, 124670, 124671}},
    [139464] = {cid = 4996, fragments = {139450, 139451, 139452, 139453, 139454, 139455, 139456}},
    [139465] = {cid = 5047, fragments = {139457, 139458, 139459, 139460, 139461, 139462, 139463}},
    [141749] = {cid = 5656, fragments = {141748, 141742, 141743, 141744, 141745, 141746, 141747}},
    [147499] = {cid = 6197, fragments = {147492, 147493, 147494, 147495, 147496, 147497, 147498}},
    [166960] = {cid = "166960", total = 50, fragments = {166466}},
    [171472] = {cid = 8198, total = 10, fragments = {171469}}
}

local COLLECTIBLE_FRAGMENTS = {
    [5590] = 7,
    [5885] = 5,
    [5887] = 5,
    [6292] = 10,
    [6381] = 10,
    [6643] = 10,
    [6689] = 7,
    [6933] = 7,
    [7270] = 7,
    [7622] = 7,
    [8079] = 10,
    [8186] = 10,
    [8888] = 50,
    [9006] = 5,
    [9389] = 10,
    [9523] = 50,
    [9797] = 25,
    [10235] = 5
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
            local unlocked = select(5, GetCollectibleInfo(id))

            if (not unlocked) then
                uncollected[id] = qty
            end
        end
    end

    return uncollected
end
