local function ChangeJob(player_character, targetjobid)
    new_player_character = player_character
    new_player_character.JobIdentifier = targetjobid
    return new_player_character

local function ChangeTalents(player_CharacterInfo, targetjobid)
        new_player_CharacterInfo = player_CharacterInfo
        new_player_CharacterInfo.AdditionalTalentPoints = #(new_player_CharacterInfo.UnlockedTalentsInTree) + new_player_CharacterInfo.AdditionalTalentPoints
        return new_player_CharacterInfo

if SERVER or (not Game.IsMultiplayer) then
    for _, player in pairs(Client.ClientList) do
        player_character = player.Character
        player_CharacterInfo = player.CharacterInfo
        player_job = player_character.JobIdentifier
        print(type(player_job))
        if player_job == "captain" then
            (player.Character).JobIdentifier = "commanding_officer"
            ChangeJobByClientObj(player)
        end
        if player_job == "engineer" then
            player_job = "engineering"
            ChangeJobByClientObj(player)
        end
        if player_job == "mechanic" then
            player_job = "mechanical"
            ChangeJobByClientObj(player)
        end
        if player_job == "securityofficer" then
            player_job = "security"
            ChangeJobByClientObj(player)
        end
        if player_job == "medicaldoctor" then
            player_job = "medicalstaff"
            ChangeJobByClientObj(player)
        end
        if player_job == "assistant" then
            player_job = "passenger"
            ChangeJobByClientObj(player)
        end
    end
end