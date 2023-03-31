print('clothing_gun_holster.lua')
-- local enabled = Game.GetEnabledContentPackages()
-- local isEnabled = false
-- for key, value in pairs(enabled) do
--     if value.Name == "Security clothing plus" then
--         isEnabled = true
--         break
--     end
-- end
-- if not isEnabled then return end


local config = dofile(SecurityClothingPlus.Path .. "/Lua/config.lua")


local list_ItemComponentType = LuaUserData.RegisterType("System.Collections.Generic.List`1[Barotrauma.Items.Components.ItemComponent]")
local xNameType = LuaUserData.RegisterType("System.Xml.Linq.XName")
local xElementType = LuaUserData.RegisterType("System.Xml.Linq.XElement")
local xAttributeType = LuaUserData.RegisterType("System.Xml.Linq.XAttribute")
local wearableSpriteType = LuaUserData.RegisterType("Barotrauma.WearableSprite")
local itemComponentType = LuaUserData.RegisterType("Barotrauma.Items.Components.ItemComponent")
local wearableType = LuaUserData.RegisterType("Barotrauma.Items.Components.Wearable")
local list_WearableSpriteType = LuaUserData.RegisterType("System.Collections.Generic.List`1[Barotrauma.WearableSprite]")
local ContentXElementType = LuaUserData.RegisterType("Barotrauma.ContentXElement")

local ItemComponent = LuaUserData.CreateStatic("Barotrauma.Items.Components.ItemComponent")
local Wearable = LuaUserData.CreateStatic("Barotrauma.Items.Components.Wearable")
local WearableSprite = LuaUserData.CreateStatic("Barotrauma.WearableSprite")
local XName = LuaUserData.CreateStatic("System.Xml.Linq.XName")
local XElement = LuaUserData.CreateStatic("System.Xml.Linq.XElement")
local XAttribute = LuaUserData.CreateStatic("System.Xml.Linq.XAttribute")
local List_ItemComponent = LuaUserData.CreateStatic("System.Collections.Generic.List`1[Barotrauma.Items.Components.ItemComponent]")
local List_WearableSprite = LuaUserData.CreateStatic("System.Collections.Generic.List`1[Barotrauma.WearableSprite]")
local ContentXElement = LuaUserData.CreateStatic("Barotrauma.ContentXElement")



local clothing_slot = 3
local gun_slot = 0
local hand_slots = { 6, 5 }

local sprite_names = {}
for gun,str in pairs(config.sprites) do
    local xElem = XElement.Parse(str)
    config.sprites[gun] = xElem
    sprite_names[gun] = xElem.Attribute(XName.Get("name")).Value
end


ctrl_itms = {
    items = {}
}
function _getGunType(self)
    -- get holster gun type
    local gun = self.item.OwnInventory.GetItemAt(gun_slot)
    local gunType = nil
    if gun ~= nil then gunType = gun.Prefab.Identifier
    else return nil end
    -- controlled gun type?
    for i,gn in pairs(config.guns) do
        if gunType == gn then return gunType end
    end
    return nil
end
function ctrl_itms.inferState(char)
    -- try get torso limb
    local torso = getCharTorso(char)
    if torso ~= nil then
        -- if torso exists search sprites
        local wSprites = torso.WearingItems
        for i = 0,#(wSprites)-1 do
            for gun,name in pairs(sprite_names) do
                if wSprites[i].Sprite.Name == name then return gun end
            end
        end
    end
    return 'default'
end
function ctrl_itms:get(char)
    if char.Inventory == nil then return nil end

    for i,itm in pairs(self.items) do
        if itm.char == char then return itm end
    end

    local cloth = char.Inventory.GetItemAt(clothing_slot)
    local itemEntry = {
        item = cloth,
        char = char,
        type = cloth.Prefab.Identifier,
        getGunType = _getGunType,
        state = ctrl_itms.inferState(char)
    }
    table.insert(self.items, itemEntry)
    return itemEntry
end
function ctrl_itms:contains(char)
    if char.Inventory == nil then return false end

    for i,itm in pairs(self.items) do
        if itm.char == char then return true end
    end

    return false
end
function ctrl_itms:remove(itemEntry)
    if itemEntry == nil then return end

    for i,itm in pairs(self.items) do
        if itm == itemEntry then
            table.remove(self.items, i)
            return
        end
    end
end

local holsterUpdateDelegate = {func = nil}
if CLIENT or (not Game.IsMultiplayer) then
    Hook.Add("think", "holsterLoop", function()
        if holsterUpdateDelegate.func ~= nil then holsterUpdateDelegate.func() end
    end)

    local holsterInit = function ()
        Timer.Wait(function()
            holsterUpdateDelegate.func = holsterUpdate
        end, 1000)
    end
    if Game.GameSession ~= nil and Game.GameSession.IsRunning then holsterInit() end
    Hook.Add("roundStart", "holsterStart", holsterInit)
    Hook.Add("roundEnd", "holsterStop", function()
        holsterUpdateDelegate.func = nil
    end)
end

local max_inv_idx = 16
function holsterUpdate()
    local chars, remChars = updateChars()

    -- remove handle
    for i,ch in pairs(remChars) do
        local itemEntry = ctrl_itms:get(ch)
        itemEntry.state = 'default'
        setHolsterVisual(ch, itemEntry, gunType)
        ctrl_itms:remove(itemEntry)
    end
    -- change handle
    for i,ch in pairs(chars) do
        local itemEntry = ctrl_itms:get(ch)

        -- print("Test1")
        if itemEntry ~= nil then
            -- toggle inventory 'q' button
            if ch.IsKeyHit(24) then
                print("q key pressed")
                local slotItem = itemEntry.item.OwnInventory.GetItemAt(gun_slot)
                local handItems = { ch.Inventory.GetItemAt(hand_slots[1]), ch.Inventory.GetItemAt(hand_slots[2]) }

                -- if hands are not empty
                if (handItems[1] ~= nil or handItems[2] ~= nil) then
                    local handitem = handItems[1]
                    if handitem == nil then handitem = handItems[2] end

                    if slotItem ~= nil then
                        -- holster slot and hands are not empty
                        local isHandsOnly = { true, true }
                        local slots = { 0, 0 }
                        str = ''
                        for i = 0,max_inv_idx do
                            if i ~= hand_slots[1] and i ~= hand_slots[2] then
                                if handItems[1] ~= nil and ch.Inventory.GetItemAt(i) == handItems[1] then
                                    slots[1] = i
                                    isHandsOnly[1] = false
                                end
                                if handItems[2] ~= nil and ch.Inventory.GetItemAt(i) == handItems[2] then
                                    slots[2] = i
                                    isHandsOnly[2] = false
                                end
                            end
                        end
                        if not isHandsOnly[1] then
                            handItems[1].Drop()
                            ch.Inventory.TryPutItem(handItems[1], slots[1], true, false, ch, true, true)
                            handItems[1] = nil
                        end
                        if not isHandsOnly[2] and handItems[2] ~= handItems[1] then
                            handItems[2].Drop()
                            ch.Inventory.TryPutItem(handItems[2], slots[2], true, false, ch, true, true)
                            handItems[2] = nil
                        end
                        if (handItems[1] ~= nil or handItems[2] ~= nil) then
                            handitem = handItems[1]
                            if handitem == nil then handitem = handItems[2] end
                            itemEntry.item.OwnInventory.TryPutItem(handitem, gun_slot, true, false, ch, true, true)
                            ch.Inventory.TryPutItem(slotItem, hand_slots[1], true, false, ch, true, true)
                        else
                            ch.Inventory.TryPutItem(slotItem, hand_slots[1], false, false, ch, true, true)
                        end
                    else
                        -- holster slot is empty but hands are not
                        itemEntry.item.OwnInventory.TryPutItem(handitem, gun_slot, false, false, ch, true, true)
                    end
                else
                    -- hands are empty
                    if slotItem ~= nil then
                        -- holster slot not empty but hands are
                        ch.Inventory.TryPutItem(slotItem, hand_slots[1], false, false, ch, true, true)
                    else
                        -- holster slot and hands are empty
                    end
                end
            end

            local gunType = itemEntry:getGunType()
            if gunType ~= nil and itemEntry.state ~= gunType then
                -- clothing and gun type are controlled => add visual
                itemEntry.state = gunType
                setHolsterVisual(ch, itemEntry, gunType)
            elseif gunType == nil and itemEntry.state ~= 'default' then
                -- clothing controlled and no gun type => remove visual
                itemEntry.state = 'default'
                setHolsterVisual(ch, itemEntry, gunType)
            end
        end
    end
end

function updateChars()
    local remCharacters = {}
    local characters = {}

    for i,character in pairs(Character.CharacterList) do
        --  if character has inventory
        if character.Inventory ~= nil then
            local clothing = character.Inventory.GetItemAt(clothing_slot)
            if ctrl_itms:contains(character) and clothing ~= ctrl_itms:get(character).item then
                -- controlled clothin removed
                table.insert(remCharacters, character)
            elseif clothing ~= nil then
                -- has clothing
                local clothingID = clothing.Prefab.Identifier

                for i,cloth in pairs(config.clothes) do
                    -- if character has controlled clothing
                    if clothingID == cloth then
                        table.insert(characters, character)
                        break
                    end
                end
            end
        end
    end

    return characters, remCharacters
end

function getCharTorso(char)
    for i,limb in pairs(char.AnimController.Limbs) do
        if limb.type == 12 then return limb end -- 'Torso'
    end
    return nil
end

function setHolsterVisual(char, itemEntry, gunType)
    print('setHolsterVisual')
    local clothing = itemEntry.item

    -- try get torso limb
    local torso = getCharTorso(char)

    if torso ~= nil then
        print(torso)
        -- if torso exists update sprites
        local wSprites = torso.WearingItems

        -- remove all additional sprites
        local i = 0
        local maxIdx = #(wSprites)
        while i < maxIdx do
            for _,name in pairs(sprite_names) do
                if wSprites[i].Sprite.Name == name then
                    wSprites.RemoveAt(i)
                    maxIdx = #(wSprites)
                    i = i - 1
                    break
                end
            end
            i = i + 1
        end
        -- add sprite if specified
        if gunType ~= nil then
            local wearable = nil
            for i = 0,#(clothing.Components)-1 do
                if clothing.Components[i].GetType() == Wearable then
                    wearable = clothing.Components[i]
                    break
                end
            end

            local sprite = nil
            for key,value in pairs(config.sprites) do
                if key == gunType then
                    sprite = value
                    break
                end
            end
            local cxelem = ContentXElement.__new(null, sprite)
            local gunSprite = WearableSprite.__new(cxelem, wearable, 0)
            gunSprite.Init(char)
            wSprites.Add(gunSprite)
        end
    end
end