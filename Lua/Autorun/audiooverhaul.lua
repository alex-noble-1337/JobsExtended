local function ChangeJobByClientObj(ClientObj)
    player_job = (ClientObj.Character).JobIdentifier
    empty_arr = []
    player_UnlockedTalentsInTree = (ClientCharacterObj.CharacterInfo).GetUnlockedTalentsInTree
    (ClientCharacterObj.CharacterInfo).GetAvailableTalentPoints = #player_UnlockedTalentsInTree + (ClientCharacterObj.CharacterInfo).GetAvailableTalentPoints
    player_UnlockedTalentsInTree = empty_arr

if SERVER or (not Game.IsMultiplayer) then
    for _, player in pairs(Client.ClientList) do
        player_job = (player.Character).JobIdentifier
        print(type(player_job))
        if player_job == "captain" then
            player_job = "commanding_officer"
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