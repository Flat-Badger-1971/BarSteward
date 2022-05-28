local BS = _G.BarSteward

-- based on code from AI Research Timer
function BS.GetResearchTimer(craftType)
    local maxTimer = 2000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)
    local maxLines = GetNumSmithingResearchLines(craftType)

    for i = 1, maxLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftType, i)

        for j = 1, numTraits do
            local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j)

            if (duration ~= nil and timeRemaining ~= nil) then
                maxResearch = maxResearch - 1
                maxTimer = math.min(maxTimer, timeRemaining)
            end
        end
    end

    if (maxResearch > 0) then
        maxTimer = 0
    end
    return maxTimer
end

function BS.SecondsToTime(seconds, hideDays)
    local time = ""
    local days = math.floor(seconds / 86400)
    local remaining = seconds

    if (days > 0) then
        remaining = seconds - (days * 86400)
    end

    local hours = math.floor(remaining / 3600)

    if (hours > 0) then
        remaining = remaining - (hours * 3600)
    end

    local minutes = math.floor(remaining / 60)

    if (minutes > 0) then
        remaining = remaining - (minutes * 60)
    end

    if (not hideDays) then
        time = string.format("%02d", days) .. ":"
    end

    time =
        time ..
        string.format("%02d", hours) .. ":" .. string.format("%02d", minutes) .. ":" .. string.format("%02d", remaining)

    return time
end

function BS.SetLockState(frame, lock)
    local lockNormal = "/esoui/art/miscellaneous/unlocked_up.dds"
    local lockPressed = "/esoui/art/miscellaneous/unlocked_down.dds"
    local lockMouseOver = "/esoui/art/miscellaneous/unlocked_over.dds"

    if (lock) then
        lockNormal = "/esoui/art/miscellaneous/locked_up.dds"
        lockPressed = "/esoui/art/miscellaneous/locked_down.dds"
        lockMouseOver = "/esoui/art/miscellaneous/locked_over.dds"
    end

    frame.lock:SetNormalTexture(lockNormal)
    frame.lock:SetPressedTexture(lockPressed)
    frame.lock:SetMouseOverTexture(lockMouseOver)
end

-- from https://wowwiki-archive.fandom.com/wiki/USERAPI_ColorGradient
function BS.Gradient(perc, ...)
    if perc >= 1 then
        local r, g, b = select(select("#", ...) - 2, ...)
        return r, g, b
    elseif perc <= 0 then
        local r, g, b = ...
        return r, g, b
    end

    local num = select("#", ...) / 3

    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

-- Return a formatted time
-- from https://esoui.com/forums/showthread.php?t=4507
function BS.FormatTime(format, timeString)
    -- split up default timestamp
    timeString = timeString or GetTimeString()
    local hours, minutes, seconds = timeString:match("([^%:]+):([^%:]+):([^%:]+)")
    local hoursNoLead = tonumber(hours) -- hours without leading zero
    local hours12NoLead = (hoursNoLead - 1) % 12 + 1
    local hours12

    if (hours12NoLead < 10) then
        hours12 = "0" .. hours12NoLead
    else
        hours12 = hours12NoLead
    end

    local pUp = "AM"
    local pLow = "am"

    if (hoursNoLead >= 12) then
        pUp = "PM"
        pLow = "pm"
    end

    -- create new one
    local time = format
    time = time:gsub("HH", hours)
    time = time:gsub("H", hoursNoLead)
    time = time:gsub("hh", hours12)
    time = time:gsub("h", hours12NoLead)
    time = time:gsub("m", minutes)
    time = time:gsub("s", seconds)
    time = time:gsub("A", pUp)
    time = time:gsub("a", pLow)

    return time
end

function BS.ToPercent(qty, total)
    local pc = tonumber(qty) / tonumber(total)
    pc = math.floor(pc * 100)

    return pc
end
