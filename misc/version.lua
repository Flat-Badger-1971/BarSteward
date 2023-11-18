local BS = _G.BarSteward

local function needsUpdate(version)
    if (not BS.Vars.Updates[version]) then
        return true
    end

    return false
end

function BS.VersionCheck()
    if (needsUpdate(2000)) then
        BS.Vars.Categories = true
        BS.Vars.CategoriesCount = true
        BS.Vars.Updates[2000] = true
    end

    if (needsUpdate(2006)) then
        local oldUpdates = {112,1222,1223,1224,1301,1304,1421,1504,1506}

        for _, ver in ipairs(oldUpdates) do
            BS.Vars.Updates[ver] = nil
        end

        BS.Vars.Updates[2006] = true
    end
end
