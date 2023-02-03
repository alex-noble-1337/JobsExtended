AudioOverhaul = {}

AudioOverhaul.Path = ...
for package in ContentPackageManager.AllPackages do
    if tostring(package.UgcId) == "2868921484" then
        AudioOverhaul.Package = package
        break
    end
end

AudioOverhaul.Patching = loadfile(AudioOverhaul.Path .. "/Lua/xmlpatching.lua")(AudioOverhaul.Path)


if AudioOverhaul.Settings.PatchDoorSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_doors.lua")
end
if AudioOverhaul.Settings.PatchOxygenGenearatorSounds == false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_oxygenerator.lua")
end
if AudioOverhaul.Settings.PatchPumpSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_pump.lua")
end
if AudioOverhaul.Settings.PatchSonarSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_sonar.lua")
end
if AudioOverhaul.Settings.PatchEngineSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_engine.lua")
end
if AudioOverhaul.Settings.PatchReactorSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_reactor.lua")
end
if AudioOverhaul.Settings.PatchAlarmSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_alarm.lua")
end
if AudioOverhaul.Settings.PatchButtonSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_button.lua")
end
if AudioOverhaul.Settings.PatchFabricatorSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_fabricators.lua")
end
if AudioOverhaul.Settings.PatchShipGunSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_shipguns.lua")
end
if AudioOverhaul.Settings.PatchWeaponSounds ~= false then
    dofile(AudioOverhaul.Path .. "/Lua/patch_weapons.lua")
end

dofile(AudioOverhaul.Path .. "/Lua/patch_sounds.lua")
dofile(AudioOverhaul.Path .. "/Lua/flowsoundvolume.lua")
dofile(AudioOverhaul.Path .. "/Lua/playervolume.lua")
