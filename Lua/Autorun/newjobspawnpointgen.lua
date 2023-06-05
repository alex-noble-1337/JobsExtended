local spawnpointSeparation = 40

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_AssignedJob")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_IdCardTags")


local function SpawnNewWaypoint_sub(jobID, position, cardPerms)
    -- get any spawnpoint as a "prefab"
    -- local oldSpawnpoint = WayPoint.SelectCrewSpawnPoints({((Client.ClientList)[1]).CharacterInfo}, submarine)[1]
    
    -- , position, SpawnType.Human,
    -- clone creates new waypoint
    -- local newWaypoint = WayPoint(WayPoint.Type.SpawnPoint, Rectangle(position.X, position.Y, 6, 6), submarine)
    local newWaypoint = WayPoint(position, SpawnType.Human, Submarine.MainSub)
    -- changing the newly created waypoint (unsure if changing oldSpawnpoint var would make changes to old waypoint in game)
    -- change the job Id
    newWaypoint.set_AssignedJob(JobPrefab.Get(jobID))
    -- hope it works, havent seen it defined inside Waypoint.cs
    -- IdCardTags is a string[] so if that does not work create a function that iterates over adn append one by one
    newWaypoint.set_IdCardTags(cardPerms)

    print("Created Spawnpoint for " .. newWaypoint.AssignedJob.Identifier.ToString() .. " with cardperms " .. table.concat(newWaypoint.IdCardTags).. " on coordinates " .. newWaypoint.WorldPosition.ToString() .. " in submarine on position " ..  Submarine.MainSub.WorldPosition.ToString())
    -- Networking.CreateEntityEvent(newWaypoint)

    -- local message = Networking.Start("syncwaypoints")
    -- message.WriteString(jobID)
    -- message.WriteSingle(position.X)
    -- message.WriteSingle(position.Y)

    -- local lengthNum = 0
    -- for k, v in pairs(cardPerms) do -- for every key in the table with a corresponding non-nil value 
    --     lengthNum = lengthNum + 1
    -- end

    -- message.WriteSingle(lengthNum)
    -- for _, cardPerm in ipairs(cardPerms) do
    --     message.WriteString(cardPerm)
    -- end
    -- -- message.Write
    -- Networking.Send(message)

    return newWaypoint
end

if CLIENT then
    Networking.Receive("syncwaypoints", function (message, client)
        local jobID = message.ReadString()
        local position = Vector2(message.ReadSingle(), message.ReadSingle())
        local cardPermsNum = message.ReadSingle()
        local cardPerms = {}
        if cardPermsNum >= 0 then
            for i = 1, cardPermsNum, 1 do
                table.insert(cardperms, message.ReadString())
            end
        end

        -- get any spawnpoint as a "prefab"
        -- local oldSpawnpoint = WayPoint.SelectCrewSpawnPoints({((Client.ClientList)[1]).CharacterInfo}, submarine)[1]
        
        -- , position, SpawnType.Human,
        -- clone creates new waypoint
        -- local newWaypoint = WayPoint(WayPoint.Type.SpawnPoint, Rectangle(position.X, position.Y, 6, 6), submarine)
        local newWaypoint = WayPoint(position, SpawnType.Human, Submarine.MainSub)
        -- changing the newly created waypoint (unsure if changing oldSpawnpoint var would make changes to old waypoint in game)
        -- change the job Id
        newWaypoint.set_AssignedJob(JobPrefab.Get(jobID))
        -- hope it works, havent seen it defined inside Waypoint.cs
        -- IdCardTags is a string[] so if that does not work create a function that iterates over adn append one by one
        newWaypoint.set_IdCardTags(cardPerms)

        print("Created Spawnpoint for " .. newWaypoint.AssignedJob.Identifier.ToString() .. " with cardperms " .. table.concat(newWaypoint.IdCardTags).. " on coordinates " .. newWaypoint.WorldPosition.ToString() .. " in submarine on position " ..  Submarine.MainSub.WorldPosition.ToString())
    end)
end

function SpawnNewSpawnpoint(vanillaSpawnPoint, targetJobId, offsetx, additionalcardperms)
    local cardperms = additionalcardperms

    -- TODO check if it requires comma between individual cardperm
    if vanillaSpawnPoint.IdCardTags ~= nil then
        for _, cardperm in pairs(vanillaSpawnPoint.IdCardTags) do
            table.insert(cardperms, cardperm)
        end
    end

    local positionofspawnpoint = vanillaSpawnPoint.Position
    positionofspawnpoint = Vector2(positionofspawnpoint.X + offsetx, positionofspawnpoint.Y)

    local cardpermtoadd = "id_" .. targetJobId
    local exists = false
    for _, cardperm in pairs(cardperms) do
        if cardpermtoadd == cardperm then
            exists = true
        end
    end
    if exists == false then
        table.insert(cardperms, cardpermtoadd)
    end

    SpawnNewWaypoint_sub(targetJobId, positionofspawnpoint, cardperms)
end


function SetPlayerCharacter(client)
    local character
    if client == nil then
        character = Character.Controlled
    else
        character = client.Character
    end

    return character
end

Hook.Add("chatMessage", "test.SpawnpointSpawning", function (message, client)
    if message == "!SpawnpointSpawning" then
        -- for testing
        local character = SetPlayerCharacter(client)

        -- requred values in function
        -- no default
        local vanillaSpawnPoint = WayPoint.SelectCrewSpawnPoints({character.Info}, character.Submarine)[1]

        SpawnNewSpawnpoint(vanillaSpawnPoint, "executive_officer", 20, {})
        return true -- returning true allows us to hide the message 
    end
end)

local function isInsidearray(argument, array)
    for _, element in pairs(array) do
        -- print(argument .. "to" .. element)
        if argument == element then
            return true
        end
    end
    return false
end


local newjobs = {"commanding_officer", "executive_officer", "navigator",
                 "chief", "engineering", "mechanical", "quartermaster", 
                 "head_of_security", "security", "diver", 
                 "chiefmedicaldoctor", "medicalstaff", 
                 "passenger", "janitor", "inmate"}


function SpawnNewSpawnpoint_noDups(vanillaSpawnPoint, targetJobId, offsetx, additionalcardperms, spawnPointsJE)
    local positionofspawnpoint = Vector2(vanillaSpawnPoint.Position.X + offsetx, vanillaSpawnPoint.Position.Y)
    if not isInsidearray(positionofspawnpoint, spawnPointsJE) then
        SpawnNewSpawnpoint(vanillaSpawnPoint, targetJobId, offsetx, additionalcardperms)
    end
end

function SpawnJobsExtendedWaypoints()
    local offsetx = spawnpointSeparation

    -- get all JobsExtended Spawnpoints in one list
    local spawnPointsJE = {}
    for _, WayPoint in pairs(WayPoint.WayPointList) do
        if WayPoint.AssignedJob ~= nil then
            if isInsidearray(WayPoint.AssignedJob.Identifier.ToString(), newjobs) then
                table.insert(spawnPointsJE, WayPoint.Position)
            end
        end
    end
    -- for _, element in pairs(spawnPointsJE) do
    --     print(element.AssignedJob.Identifier.ToString())
    -- end
    
    -- use this or SelectCrewSpawnPoints if that does not work
    for _, WayPoint in pairs(WayPoint.WayPointList) do
        -- job changing sheneanegans
        if WayPoint.AssignedJob ~= nil then
            if WayPoint.AssignedJob.Identifier.ToString() == "captain" then
                SpawnNewSpawnpoint_noDups(WayPoint, "commanding_officer", 0, {}, spawnPointsJE)
                -- create executive_officer spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "executive_officer", offsetx, {}, spawnPointsJE)
                -- create navigator spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "navigator", -1*offsetx, {}, spawnPointsJE)
            end
            if WayPoint.AssignedJob.Identifier.ToString() == "engineer" then
                SpawnNewSpawnpoint_noDups(WayPoint, "engineering", 0, {}, spawnPointsJE)
                -- create chief spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "chief", offsetx, {}, spawnPointsJE)
            end
            if WayPoint.AssignedJob.Identifier.ToString() == "mechanic" then
                SpawnNewSpawnpoint_noDups(WayPoint, "mechanical", 0, {}, spawnPointsJE)
                -- create quartermaster spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "quartermaster", offsetx, {}, spawnPointsJE)
            end
            if WayPoint.AssignedJob.Identifier.ToString() == "securityofficer" then
                SpawnNewSpawnpoint_noDups(WayPoint, "security", 0, {}, spawnPointsJE)
                -- create head_of_security spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "head_of_security", offsetx, {}, spawnPointsJE)
                -- create diver spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "diver", -1*offsetx, {}, spawnPointsJE)
            end
            if WayPoint.AssignedJob.Identifier.ToString() == "medicaldoctor" then
                SpawnNewSpawnpoint_noDups(WayPoint, "medicalstaff", 0, {}, spawnPointsJE)
                -- create chiefmedicaldoctor spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "chiefmedicaldoctor", offsetx, {}, spawnPointsJE)
                
            end
            if WayPoint.AssignedJob.Identifier.ToString() == "assistant" then
                SpawnNewSpawnpoint_noDups(WayPoint, "passenger", 0, {}, spawnPointsJE)
                -- create janitor spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "janitor", offsetx, {}, spawnPointsJE)
                -- create inmate spawnpoint with spawnpointSeparation 
                SpawnNewSpawnpoint_noDups(WayPoint, "inmate", -1*offsetx, {}, spawnPointsJE)
            end
        end
    end
end

-- Hook.Add("roundStart", "JobsExtendedSpawnWaypoints", function()
--     if SERVER or (not Game.IsMultiplayer) then
--         SpawnJobsExtendedWaypoints()
--     end
-- end)

Hook.Add("chatMessage", "JobsExtended.SpawnpointSpawning", function (message, client)
    local allowed = false
    if (not Game.IsMultiplayer) then
        allowed = true
    end
    if allowed == false then
        if client ~= nil then
            if client.HasPermission(ClientPermissions.Ban) then
                allowed = true
            end
        end
    end
    if allowed then
        if message == "!SpawnpointSpawning" then
            if SERVER or (not Game.IsMultiplayer) then
                SpawnJobsExtendedWaypoints()
                -- TODO this is stupid fix it, use per-waypoint messege instead of this, per waypoint is up
                local message = Networking.Start("syncwaypoints")
                -- message.Write
                Networking.Send(message)
                return false
            end
        end
    end
    
end)

if CLIENT then
    Networking.Receive("syncwaypoints", function (message, client)
        SpawnJobsExtendedWaypoints()
    end)
end