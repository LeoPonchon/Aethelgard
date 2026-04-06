--!nonstrict
-- Player Data System for Aethelgard
-- Stores and manages player progression with DataStore persistence

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerDataSystem = {}

local DATA_STORE_NAME = "PlayerData_v1"
local dataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)

local playerData = {}
local playerSessions = {}
local isSaving = {}

local DEFAULT_DATA = {
	version = 1,
	level = 1,
	race = "Human",
	class = "Classless",
	experience = 0,
	gems = 1000,
	shards = 100,
	pityRolls = 0,
	lastPosition = nil,
	lastCFrame = nil,
	inventory = {
		auras = {},
		accessories = {},
	},
	ownedGamepassItems = {},
	equippedItems = {},
	purchaseHistory = {},
	totalGemsPurchased = 0,
	totalRolls = 0,
	createdAt = nil,
	lastLoginAt = nil,
	playtimeSeconds = 0,
}

local function deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function validateData(data)
	if type(data) ~= "table" then
		return false
	end
	
	local requiredFields = {"level", "race", "class", "gems", "shards", "inventory"}
	for _, field in ipairs(requiredFields) do
		if data[field] == nil then
			return false
		end
	end
	
	return true
end

local function migrateData(data)
	if not data.version then
		data.version = 1
	end
	
	if data.inventory == nil then
		data.inventory = { auras = {}, accessories = {} }
	end
	if data.ownedGamepassItems == nil then
		data.ownedGamepassItems = {}
	end
	if data.equippedItems == nil then
		data.equippedItems = {}
	end
	if data.purchaseHistory == nil then
		data.purchaseHistory = {}
	end
	if data.totalGemsPurchased == nil then
		data.totalGemsPurchased = 0
	end
	if data.totalRolls == nil then
		data.totalRolls = 0
	end
	if data.lastPosition == nil then
		data.lastPosition = nil
	end
	if data.lastCFrame == nil then
		data.lastCFrame = nil
	end
	if data.pityRolls == nil then
		data.pityRolls = 0
	end
	if data.createdAt == nil then
		data.createdAt = os.time()
	end
	if data.lastLoginAt == nil then
		data.lastLoginAt = os.time()
	end
	if data.playtimeSeconds == nil then
		data.playtimeSeconds = 0
	end
	
	return data
end

function PlayerDataSystem.loadPlayerData(player)
	local playerId = player.UserId
	local key = tostring(playerId)
	
	if isSaving[playerId] then
		task.wait(1)
	end
	
	local success, result = pcall(function()
		return dataStore:GetAsync(key)
	end)
	
	if success then
		if result and validateData(result) then
			result = migrateData(result)
			result.lastLoginAt = os.time()
			playerData[playerId] = result
			playerSessions[playerId] = {
				loginTime = os.time(),
				lastSaveTime = os.time(),
			}
			print("[PlayerDataSystem] Loaded data for player:", player.Name, "Level:", result.level, "Gems:", result.gems)
		else
			local newData = deepCopy(DEFAULT_DATA)
			newData.createdAt = os.time()
			newData.lastLoginAt = os.time()
			playerData[playerId] = newData
			playerSessions[playerId] = {
				loginTime = os.time(),
				lastSaveTime = os.time(),
			}
			print("[PlayerDataSystem] Created new data for player:", player.Name)
		end
	else
		warn("[PlayerDataSystem] Failed to load data for player:", player.Name, result)
		playerData[playerId] = deepCopy(DEFAULT_DATA)
		playerData[playerId].createdAt = os.time()
		playerData[playerId].lastLoginAt = os.time()
		playerSessions[playerId] = {
			loginTime = os.time(),
			lastSaveTime = os.time(),
		}
	end
	
	return playerData[playerId]
end

function PlayerDataSystem.savePlayerData(player)
	local playerId = player.UserId
	local key = tostring(playerId)
	
	if isSaving[playerId] then
		return false, "Already saving"
	end
	
	local data = playerData[playerId]
	if not data then
		return false, "No data to save"
	end
	
	isSaving[playerId] = true
	
	local session = playerSessions[playerId]
	if session then
		local currentTime = os.time()
		data.playtimeSeconds = data.playtimeSeconds + (currentTime - session.lastSaveTime)
		session.lastSaveTime = currentTime
	end
	
	local dataToSave = deepCopy(data)
	
	local success, err = pcall(function()
		dataStore:SetAsync(key, dataToSave)
	end)
	
	isSaving[playerId] = false
	
	if success then
		print("[PlayerDataSystem] Saved data for player:", player.Name)
		return true
	else
		warn("[PlayerDataSystem] Failed to save data for player:", player.Name, err)
		return false, err
	end
end

function PlayerDataSystem.forceSaveAll()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
end

function PlayerDataSystem.getPlayerData(playerId)
	if not playerData[playerId] then
		playerData[playerId] = deepCopy(DEFAULT_DATA)
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
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
end

function PlayerDataSystem.setClass(playerId, class)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.class = class
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
end

function PlayerDataSystem.setPosition(playerId, position)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.lastPosition = {x = position.X, y = position.Y, z = position.Z}
end

function PlayerDataSystem.setCFrame(playerId, cframe)
	local data = PlayerDataSystem.getPlayerData(playerId)
	local x, y, z = cframe:GetComponents()
	data.lastCFrame = {x = x, y = y, z = z, rx = x, ry = y, rz = z, rx2 = x, ry2 = y, rz2 = z}
end

function PlayerDataSystem.getPosition(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	if data.lastPosition then
		return Vector3.new(data.lastPosition.x, data.lastPosition.y, data.lastPosition.z)
	end
	return nil
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
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
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
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
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

function PlayerDataSystem.recordPurchase(playerId, purchaseType, productId, amount, gemsGranted)
	local data = PlayerDataSystem.getPlayerData(playerId)
	local record = {
		timestamp = os.time(),
		type = purchaseType,
		productId = productId,
		amount = amount,
		gemsGranted = gemsGranted or 0,
	}
	table.insert(data.purchaseHistory, record)
	data.totalGemsPurchased = data.totalGemsPurchased + (gemsGranted or 0)
	print("[PlayerDataSystem] Recorded purchase for player:", playerId, "Type:", purchaseType, "Gems:", gemsGranted)
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		PlayerDataSystem.savePlayerData(player)
	end
end

function PlayerDataSystem.getPurchaseHistory(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	return data.purchaseHistory
end

function PlayerDataSystem.getTotalGemsPurchased(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	return data.totalGemsPurchased
end

function PlayerDataSystem.incrementRolls(playerId, count)
	local data = PlayerDataSystem.getPlayerData(playerId)
	data.totalRolls = data.totalRolls + (count or 1)
end

function PlayerDataSystem.getTotalRolls(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	return data.totalRolls
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
	local player = Players:GetPlayerByUserId(playerId)
	if player then
		task.spawn(function()
			PlayerDataSystem.savePlayerData(player)
		end)
	end
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
		local player = Players:GetPlayerByUserId(playerId)
		if player then
			task.spawn(function()
				PlayerDataSystem.savePlayerData(player)
			end)
		end
	end
end

function PlayerDataSystem.getCurrencyData(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	return {
		gems = data.gems,
		shards = data.shards,
	}
end

function PlayerDataSystem.getPlaytime(playerId)
	local data = PlayerDataSystem.getPlayerData(playerId)
	return data.playtimeSeconds
end

function PlayerDataSystem.clearPlayerData(playerId)
	playerData[playerId] = nil
	playerSessions[playerId] = nil
end

function PlayerDataSystem.init()
	print("[PlayerDataSystem] Initializing...")
	
	Players.PlayerAdded:Connect(function(player)
		PlayerDataSystem.loadPlayerData(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		PlayerDataSystem.savePlayerData(player)
		PlayerDataSystem.clearPlayerData(player.UserId)
	end)
	
	game:BindToClose(function()
		PlayerDataSystem.forceSaveAll()
		task.wait(2)
	end)
	
	task.spawn(function()
		while true do
			task.wait(60)
			PlayerDataSystem.forceSaveAll()
		end
	end)
	
	print("[PlayerDataSystem] Initialized")
end

print("[PlayerDataSystem] Module loaded")
return PlayerDataSystem
