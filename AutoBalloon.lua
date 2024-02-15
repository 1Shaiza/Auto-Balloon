_G.autoBalloon = true

local START_DELAY = 2 -- delay before starting
local SERVER_HOP = true -- server hop after popping balloons
local SERVER_HOP_DELAY = 3 -- delay before server hopping
local BALLOON_DELAY = 3 -- delay before popping next balloon (if there are multiple balloons in the server)
local GET_BALLOON_DELAY = 5 -- delay before getting balloons again if none are detected






task.wait(START_DELAY)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function serverHop()
    print("Server hopping in " .. SERVER_HOP_DELAY .. " seconds")
    task.wait(SERVER_HOP_DELAY)

    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local function tp()
        local Site;
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/8737899170/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/8737899170/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0;
        for i,v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _,Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            pcall(function()
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    task.wait()
                    pcall(function()
                        task.wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    task.wait(4)
                end
            end
        end
    end

    while task.wait() do
        pcall(function()
            tp()
            if foundAnything ~= "" then
                tp()
            end
        end)
    end
end

while _G.autoBalloon do
    local balloonIds = {}

    local getActiveBalloons = ReplicatedStorage.Network.BalloonGifts_GetActiveBalloons:InvokeServer()

    local allPopped = true
    for i, v in pairs(getActiveBalloons) do
        if not v.Popped then
            allPopped = false
            print("Unpopped balloon found in " .. v.ZoneId)
            balloonIds[i] = v
        end
    end

    if allPopped then
        print("No balloons detected, waiting " .. GET_BALLOON_DELAY .. " seconds")
        if SERVER_HOP then
            serverHop()
        end
        task.wait(GET_BALLOON_DELAY)
        continue
    end

    if not _G.autoBalloon then
        break
    end

    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    for balloonId, balloonData in pairs(balloonIds) do

        print("Popping balloon in " .. balloonData.ZoneId)

        local balloonPosition = balloonData.Position

        ReplicatedStorage.Network.Slingshot_Toggle:InvokeServer()

        task.wait()

        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(balloonPosition.X, balloonPosition.Y + 30, balloonPosition.Z)

        task.wait()

        local args = {
            [1] = Vector3.new(balloonPosition.X, balloonPosition.Y + 25, balloonPosition.Z),
            [2] = 0.5794160315249014,
            [3] = -0.8331117721691044,
            [4] = 200
        }

        ReplicatedStorage.Network.Slingshot_FireProjectile:InvokeServer(unpack(args))

        task.wait(0.1)

        local args = {
            [1] = balloonId
        }

        ReplicatedStorage.Network.BalloonGifts_BalloonHit:FireServer(unpack(args))

        task.wait()

        ReplicatedStorage.Network.Slingshot_Unequip:InvokeServer()

        print("Popped balloon, waiting " .. BALLOON_DELAY .. " seconds")
        task.wait(BALLOON_DELAY)
    end

    if SERVER_HOP then
        serverHop()
    end

    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
end















-- for i, v in pairs(game:GetService("ReplicatedStorage").Network.BalloonGifts_GetActiveBalloons:InvokeServer()) do
--     print(i,v.ZoneId)
--     for a = 1, 10 do
--         print(i)
--         local success, error = pcall(function()
--             game:GetService("ReplicatedStorage").Network.BalloonGifts_BalloonHit:FireServer(i)
--         end)
--         print(success, error)
--     end
-- end





-- warn('aosdhasiodhiuklashsduioahbsdnid')
-- for i,v in pairs(game:GetService("ReplicatedStorage").Network.BalloonGifts_GetActiveBalloons:InvokeServer()) do
--     print(v.ZoneId)
--     setclipboard(i)
--     break
-- end



-- -- anchor character
-- game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false



-- print(require(game.ReplicatedStorage:WaitForChild("ClientLibrary")).Network.Invoke("BalloonGifts_GetActiveBalloons"))

-- -- BALLOON DATA 

-- -- nilZoneId Mythic Dungeon
-- -- SpawnTime 1707798882.956788
-- -- Popped false
-- -- Position 1061.58984375, -8.773372650146484, 4263.65234375
-- -- LandPosition 1061.58984375, -36.773372650146484, 4263.65234375
-- -- BalloonType table: 0x6ddf26cfe2164634
-- -- Id 56cc709a42b1470ba1fb75d0b611936c
