local function ChangePlayerCharacterInfo(Client, targetJobId)
    -- local skills = {}
    -- skills.append(Client.Job.GetSkill("helm"))
    -- skills.append(Client.Job.GetSkill("weapons"))
    -- skills.append(Client.Job.GetSkill("mechanical"))
    -- skills.append(Client.Job.GetSkill("electrical"))
    -- skills.append(Client.Job.GetSkill("medical"))

    -- empty info kek
    -- local empty_info = CharacterInfo("human", "Robert")
    -- empty_info.Job = Job(JobPrefab.Get("assistant"))

    local new_player_CharacterInfo = Client.CharacterInfo
    -- ERROR cannot access this
    -- print(Client.CharacterInfo.GetUnlockedTalentsInTree)
    -- new_player_CharacterInfo.AdditionalTalentPoints = #(new_player_CharacterInfo.UnlockedTalentsInTree) + new_player_CharacterInfo.AdditionalTalentPoints
    -- new_player_CharacterInfo.UnlockedTalentsInTree = empty_info.UnlockedTalentsInTree
    -- replace old character info with new one that has job-specific talents 0'ed
    new_player_CharacterInfo.Job = Job(JobPrefab.Get(targetJobId))
    -- new_player_CharacterInfo.UnlockedTalents = Client.CharacterInfo.UnlockedTalents

    return new_player_CharacterInfo
end

local function CreateHumanJob(client, targetJobId)
    -- Note: If we plan only running this server-side, we could grab the CharacterInfo from client instead, which will have all their info already set, like name and hair style.
    local info = ChangePlayerCharacterInfo(client, targetJobId)
    -- info.Job = Job(JobPrefab.Get(targetJobId))

    local submarine = Submarine.MainSub
    -- This method takes a list of CharacterInfo that it will use to choose the correct spawn waypoint
    -- in this case we only have a single info, so we just create a table with just that info in it.
    -- local spawnPoint = WayPoint.SelectCrewSpawnPoints({info}, submarine)[1]
    local spawnPosition = (client.Character).WorldPosition
    -- local spawnPosition = nil
    -- if spawnPoint == nil then
        
    -- else
    --     spawnPosition = spawnPoint.WorldPosition
    -- end
    local character = Character.Create(info, spawnPosition, info.Name, 0, false, false, ((client.Character).AnimController).RagdollParams, false)
    character.TeamID = CharacterTeamType.Team1
    character.GiveJobItems()

    return character
end

local function ForceClientTo(client, newjobid)
    -- create an prisoner job
    local newcharacter = CreateHumanJob(client, newjobid)
    -- take controll to prisoner character
    local oldcharacter
    if CLIENT then
        oldcharacter = Character.Controlled
        Character.Controlled = newcharacter
    else
        oldcharacter = client.Character
        client.SetClientCharacter(newcharacter)
    end
    -- kill previous character
    oldcharacter.Kill(CauseOfDeathType.Unknown)
end

-- Hook.Add("chatMessage", "jobsextended.changerolecommand", function (message, client)
--     if SERVER or (not Game.IsMultiplayer) then
--         if client.HasPermission(ClientPermissions.Ban) then
--             local allClients = Player.GetAllClients()
--             for _, playerclient in pairs(allClients) do
--                 if message ~= nil then
--                     print(playerclient.Character.Name)
--                     if message == "!prisoner" .. " ".. playerclient.Character.Name then
--                         ForceClientTo(playerclient, "inmate")
--                     end
--                 end
--             end  
--         end

--         return true -- returning true allows us to hide the message
--     end
-- end)

Hook.Add("chatMessage", "jobsextended.imprisonment", function (message, client)
    if SERVER or (not Game.IsMultiplayer) then
        if client.HasPermission(ClientPermissions.Ban) then
            local allClients = Player.GetAllClients()
            for _, playerclient in pairs(allClients) do
                if message ~= nil then
                    print(playerclient.Character.Name)
                    if message == "!prisoner" .. " ".. playerclient.Character.Name then
                        ForceClientTo(playerclient, "inmate")
                    end
                end
            end  
        end

        return true -- returning true allows us to hide the message
    end
end)

local function ChangePlayerCharacter(Client, targetJobId)
    local player_character = Client.Character
    local new_player_character = player_character
    new_player_character.JobIdentifier = targetJobId
    -- spawn new_player_character
    -- change its name
    -- give control to player
    -- delete previous character
end

local function ChangePlayerJob(Client, newJobId)
    ChangePlayerCharacter(Client, newJobId)
    ChangePlayerCharacterInfo(Client)
end


if SERVER or (not Game.IsMultiplayer) then
    for _, player in pairs(Client.ClientList) do
        local player_character = player.Character
        local player_job = player_character.JobIdentifier
        print(type(player_job))
        if player_job == "captain" then
            ChangePlayerJob(player, "commanding_officer")
        end
        if player_job == "engineer" then
            ChangePlayerJob(player, "engineering")
        end
        if player_job == "mechanic" then
            ChangePlayerJob(player, "mechanical")
        end
        if player_job == "securityofficer" then
            ChangePlayerJob(player, "security")
        end
        if player_job == "medicaldoctor" then
            ChangePlayerJob(player, "medicalstaff")
        end
        if player_job == "assistant" then
            ChangePlayerJob(player, "passenger")
        end
    end
end