--!nonstrict
-- Player Data System for Aethelgard
-- Stores and manages player progression: level, race, class

local PlayerDataSystem = {}

local playerData = {}

local DEFAULT_DATA = {
	level = 1,
	race = "Human",
	class = "Classless",
	experience = 0,
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

function PlayerDataSystem.clearPlayerData(playerId)
	playerData[playerId] = nil
end

print("[PlayerDataSystem] Module loaded")
return PlayerDataSystem
