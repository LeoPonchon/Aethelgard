--!nonstrict
-- Player Data System for Aethelgard
-- Stores and manages player progression: level, race, class, currency, inventory

local PlayerDataSystem = {}

local playerData = {}

local DEFAULT_DATA = {
    level = 1,
    race = "Human",
    class = "Classless",
    experience = 0,
    gems = 0,
    shards = 0,
    pityRolls = 0,
    inventory = {
        auras = {},
        accessories = {},
    },
    ownedGamepassItems = {},
    equippedItems = {},
}

function PlayerDataSystem.getPlayerData(playerId)
	if not playerData[playerId] then
		playerData[playerId] = table.clone(DEFAULT_DATA)
	end
	return playerData[playerId]
end

function PlayerDataSystem.setLevel(playerId, level)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.level = math.max(1, level)
end

function PlayerDataSystem.setRace(playerId, race)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.race = race
end

function PlayerDataSystem.setClass(playerId, class)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.class = class
end

function PlayerDataSystem.addExperience(playerId, amount)
    local data = PlayerDataSystem.getPlayerData(playerId)
    data.experience = data.experience + amount
    local newLevel = math.floor(data.experience / 100) + 1
    if newLevel > data.level then
        data.level = newLevel
        return true, newLevel
    end
    return false, data.level
end

function PlayerDataSystem.getGems(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return data.gems
end

function PlayerDataSystem.addGems(playerId, amount)
    local data = PlayerDataSystem.getPlayerData(playerId)
    data.gems = data.gems + amount
    return data.gems
end

function PlayerDataSystem.spendGems(playerId, amount): (boolean, string?)
    local data = PlayerDataSystem.getPlayerData(playerId)
    if data.gems < amount then
        return false, "Insufficient gems"
    end
    data.gems = data.gems - amount
    return true, nil
end

function PlayerDataSystem.getShards(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return data.shards
end

function PlayerDataSystem.addShards(playerId, amount)
    local data = PlayerDataSystem.getPlayerData(playerId)
    data.shards = data.shards + amount
    return data.shards
end

function PlayerDataSystem.spendShards(playerId, amount): (boolean, string?)
    local data = PlayerDataSystem.getPlayerData(playerId)
    if data.shards < amount then
        return false, "Insufficient shards"
    end
    data.shards = data.shards - amount
    return true, nil
end

function PlayerDataSystem.getPityRolls(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return data.pityRolls
end

function PlayerDataSystem.setPityRolls(playerId, rolls)
    local data = PlayerDataSystem.getPlayerData(playerId)
    data.pityRolls = rolls
end

function PlayerDataSystem.getInventory(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return data.inventory
end

function PlayerDataSystem.addItem(playerId, itemType, itemData)
    local data = PlayerDataSystem.getPlayerData(playerId)
    local category = itemType .. "s"
    if not data.inventory[category] then
        data.inventory[category] = {}
    end
    
    for _, item in ipairs(data.inventory[category]) do
        if item.id == itemData.id then
            return false
        end
    end
    
    table.insert(data.inventory[category], itemData)
    return true
end

function PlayerDataSystem.hasItem(playerId, itemId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    for category, items in pairs(data.inventory) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                return true
            end
        end
    end
    return false
end

function PlayerDataSystem.equipItem(playerId, itemId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    
    for category, items in pairs(data.inventory) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                for _, i in ipairs(items) do
                    i.equipped = false
                end
                item.equipped = true
                return true
            end
        end
    end
    return false
end

function PlayerDataSystem.getOwnedGamepassItems(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return data.ownedGamepassItems
end

function PlayerDataSystem.ownsGamepassItem(playerId, itemId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    for _, id in ipairs(data.ownedGamepassItems) do
        if id == itemId then
            return true
        end
    end
    return false
end

function PlayerDataSystem.addOwnedGamepassItem(playerId, itemId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    if not PlayerDataSystem.ownsGamepassItem(playerId, itemId) then
        table.insert(data.ownedGamepassItems, itemId)
    end
end

function PlayerDataSystem.getCurrencyData(playerId)
    local data = PlayerDataSystem.getPlayerData(playerId)
    return {
        gems = data.gems,
        shards = data.shards,
    }
end

function PlayerDataSystem.clearPlayerData(playerId)
	playerData[playerId] = nil
end

print("[PlayerDataSystem] Module loaded")
return PlayerDataSystem
