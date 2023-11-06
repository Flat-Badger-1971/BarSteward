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
end
