SecurityClothingPlus = {}
SecurityClothingPlus.Path = table.pack(...)[1]

if SERVER then end
    -- no server code
if CLIENT or (not Game.IsMultiplayer) then
    dofile(SecurityClothingPlus.Path .. '/Lua/clothing_gun_holster.lua')
end