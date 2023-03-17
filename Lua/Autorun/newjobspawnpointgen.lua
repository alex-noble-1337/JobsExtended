local spawnpointSeparation = 20

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_AssignedJob")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_IdCardTags")

function SpawnNewWaypoint(jobID, position, cardPerms)
    -- get any spawnpoint as a "prefab"
    local oldSpawnpoint = WayPoint.SelectCrewSpawnPoints({((Client.ClientList)[1]).CharacterInfo}, submarine)[1]
    
    -- , position, SpawnType.Human,
    -- clone creates new waypoint
    local newWaypoint = WayPoint(WayPoint.Type.SpawnPoint, Rectangle(position.X, position.Y, 6, 6), submarine)

    -- changing the newly created waypoint (unsure if changing oldSpawnpoint var would make changes to old waypoint in game)
    -- change the job Id
    newWaypoint.set_AssignedJob(JobPrefab.Get(jobID))
    -- hope it works, havent seen it defined inside Waypoint.cs
    -- IdCardTags is a string[] so if that does not work create a function that iterates over adn append one by one
    newWaypoint.set_IdCardTags(cardPerms)
end

if CLIENT or (not Game.IsMultiplayer) then
    Networking.Receive("sync.SpawnNewWaypoint", function (msg)
        SpawnNewWaypoint(msg.ReadSingle(), msg.ReadSingle(), msg.ReadSingle())
    end)
end

Hook.Add("chatMessage", "test.SpawnpointSpawning", function (message, client)
    if message ~= "!SpawnpointSpawning" then return end
    
    if SERVER or (not Game.IsMultiplayer) then

        print(client)

        local targetJobId = "executive_officer"
        print((client.Character).Position)
        SpawnNewWaypoint(targetJobId, (client.Character).Position, {"id_executive_officer"})

        -- lets send a net message to all clients so they add our link
        local msg = Networking.Start("sync.SpawnNewWaypoint")
        msg.WriteSingle(targetJobId)
        msg.WriteSingle((client.Character).Position)
        msg.WriteSingle({"id_executive_officer"})

        return true -- returning true allows us to hide the message
    end
end)

if SERVER or (not Game.IsMultiplayer) then
    -- use this or SelectCrewSpawnPoints if that does not work
    for _, WayPoint in pairs(WayPoint.WayPointList) do
        -- job changing sheneanegans
        if WayPoint.AssignedJob == "captain" then
            WayPoint.AssignedJob = "commanding_officer"
            -- create executive_officer spawnpoint with spawnpointSeparation 
            -- create navigator spawnpoint with spawnpointSeparation 
        end
        if WayPoint.AssignedJob == "engineer" then
            WayPoint.AssignedJob = "engineering"
            -- create chief spawnpoint with spawnpointSeparation
        end
        if WayPoint.AssignedJob == "mechanic" then
            WayPoint.AssignedJob = "mechanical"
            -- create quartermaster spawnpoint with spawnpointSeparation 
        end
        if WayPoint.AssignedJob == "securityofficer" then
            WayPoint.AssignedJob = "security"
            -- create head_of_security spawnpoint with spawnpointSeparation 
            -- create diver spawnpoint with spawnpointSeparation 
        end
        if WayPoint.AssignedJob == "medicaldoctor" then
            WayPoint.AssignedJob = "medicalstaff"
            -- create chiefmedicaldoctor spawnpoint with spawnpointSeparation 
        end
        if WayPoint.AssignedJob == "assistant" then
            WayPoint.AssignedJob = "passenger"
            -- create janitor spawnpoint with spawnpointSeparation 
            -- create inmate spawnpoint with spawnpointSeparation 
        end
    end
end