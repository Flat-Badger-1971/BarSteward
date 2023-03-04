-- luacheck: push ignore

if not Taneth then
    return
end

local BS = _G.BarSteward

Taneth("BarSteward", function()
    describe("Utilities", function()
        describe("SecondsToTime", function()
            it("should display days, hours, minutes and seconds", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds)

                assert.equals(result, "01:23:59:59")
            end)

            it("should display hours, minutes and seconds", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, true)

                assert.equals(result, "23:59:59")
            end)

            it("should display minutes and seconds", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, true, true)

                assert.equals(result, "59:59")
            end)

            it("should display hours and minutes", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, true, false, true)

                assert.equals(result, "23:59")
            end)

            it("should display days, hours and minutes", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, false, false, true)

                assert.equals(result, "01:23:59")
            end)

            it("should display hours and minutes (zero days)", function()
                local seconds = 86399
                local result = BS.SecondsToTime(seconds, false, false, true, nil, true)

                assert.equals(result, "23:59")
            end)

            local format = "<<1>>d <<2>>h <<3>>m"

            it("should display days, hours, minutes and seconds with formatting", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, false, false, false, format)

                assert.equals(result, "1d 23h 59m 59s")
            end)

            it("should display hours, minutes and seconds", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, true, false, false, format)

                assert.equals(result, "23h 59m 59s")
            end)

            it("should display days, hours and minutes with formatting", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, false, false, true, format)

                assert.equals(result, "1d 23h 59m")
            end)

            it("should display hours and minutes", function()
                local seconds = 172799
                local result = BS.SecondsToTime(seconds, true, false, true, format)

                assert.equals(result, "23h 59m")
            end)

        end)

        --describe("SetLockState", function()
            -- can't test this as not possible to read button textures
            -- need to figure out a mock button object
        --end)

    end)
end)

-- luacheck: pop