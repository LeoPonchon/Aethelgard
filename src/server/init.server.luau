--!nonstrict
-- Server initialization script
-- Handles day/night cycle, role management, and server-side game logic

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for Shared folder to be available
local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)

-- Import RoleManager
local RoleManager = require(script.Parent:WaitForChild("Server"):WaitForChild("RoleManager"))

-- Import PlayerDisplaySystem
local PlayerDisplaySystem = require(script.Parent:WaitForChild("Server"):WaitForChild("PlayerDisplaySystem"))

-- Initialize role system
RoleManager.init()

-- Initialize player display system
PlayerDisplaySystem.init()

-- Create RemoteEvent for role selection (if it doesn't exist)
local selectRoleRemote = ReplicatedStorage:FindFirstChild("SelectRole")
if not selectRoleRemote then
	selectRoleRemote = Instance.new("RemoteEvent")
	selectRoleRemote.Name = "SelectRole"
	selectRoleRemote.Parent = ReplicatedStorage
end

-- Create RemoteEvent for race selection (if it doesn't exist)
local selectRaceRemote = ReplicatedStorage:FindFirstChild("SelectRace")
if not selectRaceRemote then
	selectRaceRemote = Instance.new("RemoteEvent")
	selectRaceRemote.Name = "SelectRace"
	selectRaceRemote.Parent = ReplicatedStorage
end

-- Create RemoteEvent for class selection (if it doesn't exist)
local selectClassRemote = ReplicatedStorage:FindFirstChild("SelectClass")
if not selectClassRemote then
	selectClassRemote = Instance.new("RemoteEvent")
	selectClassRemote.Name = "SelectClass"
	selectClassRemote.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting slot counts (if it doesn't exist)
local getSlotsRemote = ReplicatedStorage:FindFirstChild("GetRoleSlots")
if not getSlotsRemote then
	getSlotsRemote = Instance.new("RemoteFunction")
	getSlotsRemote.Name = "GetRoleSlots"
	getSlotsRemote.Parent = ReplicatedStorage
end

-- Create RemoteEvent for character creation (if it doesn't exist)
local createCharacterRemote = ReplicatedStorage:FindFirstChild("CreateCharacter")
if not createCharacterRemote then
	createCharacterRemote = Instance.new("RemoteEvent")
	createCharacterRemote.Name = "CreateCharacter"
	createCharacterRemote.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting character data (if it doesn't exist)
local getCharacterDataRemote = ReplicatedStorage:FindFirstChild("GetCharacterData")
if not getCharacterDataRemote then
	getCharacterDataRemote = Instance.new("RemoteFunction")
	getCharacterDataRemote.Name = "GetCharacterData"
	getCharacterDataRemote.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting races/classes data (if it doesn't exist)
local getCreationDataRemote = ReplicatedStorage:FindFirstChild("GetCreationData")
if not getCreationDataRemote then
	getCreationDataRemote = Instance.new("RemoteFunction")
	getCreationDataRemote.Name = "GetCreationData"
	getCreationDataRemote.Parent = ReplicatedStorage
end

-- Create RemoteEvent for character creation (if it doesn't exist)
local createCharacterRemote = ReplicatedStorage:FindFirstChild("CreateCharacter")
if not createCharacterRemote then
	createCharacterRemote = Instance.new("RemoteEvent")
	createCharacterRemote.Name = "CreateCharacter"
	createCharacterRemote.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting character data (if it doesn't exist)
local getCharacterDataRemote = ReplicatedStorage:FindFirstChild("GetCharacterData")
if not getCharacterDataRemote then
	getCharacterDataRemote = Instance.new("RemoteFunction")
	getCharacterDataRemote.Name = "GetCharacterData"
	getCharacterDataRemote.Parent = ReplicatedStorage
end

-- Handle role selection requests from clients
selectRoleRemote.OnServerEvent:Connect(function(player: Player, roleName: string)
-- Validate input
if type(roleName) ~= "string" then
warn("[SelectRole] Invalid role name from " .. player.Name)
return
end

-- Attempt to assign the role
local success, reason = RoleManager.assignRole(player, roleName)

if success then
print(string.format("[SelectRole] %s successfully joined %s", player.Name, roleName))

-- Update player display after role change
local CharacterCreationSystem = require(sharedFolder:WaitForChild("CharacterCreationSystem"))
local characterData = CharacterCreationSystem.getCharacterData(player.UserId)
if characterData then
PlayerDisplaySystem.setPlayerData(player, characterData.raceId, characterData.classId, 1)
end
else
-- Send failure message back to client (could use a separate remote or chat message)
print(string.format("[SelectRole] %s failed to join %s: %s", player.Name, roleName, reason or "Unknown reason"))
end
end)

-- Handle race selection requests from clients
selectRaceRemote.OnServerEvent:Connect(function(player: Player, raceName: string)
-- Validate input
if type(raceName) ~= "string" then
warn("[SelectRace] Invalid race name from " .. player.Name)
return
end

-- Validate race exists
local RaceData = require(sharedFolder:WaitForChild("RaceData"))
if not RaceData.isValidRace(raceName) then
warn("[SelectRace] Invalid race: " .. raceName)
return
end

-- Set player's race attribute
player:SetAttribute("Race", raceName)
print(string.format("[SelectRace] %s selected race: %s", player.Name, raceName))
end)

-- Handle class selection requests from clients
selectClassRemote.OnServerEvent:Connect(function(player: Player, className: string)
-- Validate input
if type(className) ~= "string" then
warn("[SelectClass] Invalid class name from " .. player.Name)
return
end

-- Validate class exists
local ClassData = require(sharedFolder:WaitForChild("ClassData"))
if not ClassData.isValidClass(className) then
warn("[SelectClass] Invalid class: " .. className)
return
end

-- Set player's class attribute
player:SetAttribute("Class", className)
print(string.format("[SelectClass] %s selected class: %s", player.Name, className))

-- Update player display with the new race and class
local race = player:GetAttribute("Race") or "Humain"
PlayerDisplaySystem.setPlayerData(player, race, className, 1)
end)

-- Handle slot count requests
getSlotsRemote.OnServerInvoke = function(player: Player, roleName: string)
	if not roleName then
		-- Return all slot counts
		local slotCounts = {}
		for _, category in ipairs(require(sharedFolder:WaitForChild("TeamData")).getTeamData()) do
			for _, teamInfo in ipairs(category.teams) do
				local available = RoleManager.getAvailableSlots(teamInfo.name)
				local max = require(sharedFolder:WaitForChild("TeamData")).getMaxSlots(teamInfo.name)
				slotCounts[teamInfo.name] = {
					available = available,
					max = max,
					current = RoleManager.countPlayersInRole(teamInfo.name)
				}
			end
		end
		return slotCounts
	else
		-- Return specific role slot count
		local available = RoleManager.getAvailableSlots(roleName)
		local max = require(sharedFolder:WaitForChild("TeamData")).getMaxSlots(roleName)
		return {
			available = available,
			max = max,
			current = RoleManager.countPlayersInRole(roleName)
		}
	end
end

-- Handle character creation requests from clients
createCharacterRemote.OnServerEvent:Connect(function(player: Player, characterData: any)
	-- Validate input
	if type(characterData) ~= "table" then
		warn("[CreateCharacter] Invalid character data from " .. player.Name)
		return false
	end
	
	-- Import CharacterCreationSystem
	local CharacterCreationSystem
	local success, result = pcall(function()
		CharacterCreationSystem = require(sharedFolder:WaitForChild("CharacterCreationSystem"))
	end)
	
	if not success or not CharacterCreationSystem then
		warn("[CreateCharacter] Could not load CharacterCreationSystem")
		return false
	end
	
	-- Create character
	local createSuccess = CharacterCreationSystem.createCharacter(player.UserId, {
		playerId = player.UserId,
		characterName = characterData.characterName,
		raceId = characterData.raceId,
		classId = characterData.classId,
		origin = characterData.origin,
		arrival = characterData.arrival,
		cheat = characterData.cheat,
		backstory = characterData.backstory or "",
		motivation = characterData.motivation or "",
		createdAt = 0,
	})
	
	if createSuccess then
		print(string.format("[CreateCharacter] %s created character: %s (%s %s)",
			player.Name, characterData.characterName, characterData.raceId, characterData.classId))
		
		-- Apply character stats to player
		local stats = CharacterCreationSystem.calculateStartingStats(characterData.raceId, characterData.classId)
		-- Store stats in player (could be in a Leaderstats or other system)
		if player:FindFirstChild("leaderstats") then
			local statsFolder = player.leaderstats:FindFirstChild("Stats")
			if statsFolder then
				for statName, statValue in pairs(stats) do
					local statObj = statsFolder:FindFirstChild(statName)
					if statObj and statObj:IsA("IntValue") then
						statObj.Value = statValue
					end
				end
			end
		end
		
		-- Update player display
		PlayerDisplaySystem.setPlayerData(player, characterData.raceId, characterData.classId, 1)

		return true
	else
		warn(string.format("[CreateCharacter] %s failed to create character", player.Name))
		return false
	end
end)

-- Handle character data requests
getCharacterDataRemote.OnServerInvoke = function(player: Player)
	local CharacterCreationSystem
	local success, result = pcall(function()
		CharacterCreationSystem = require(sharedFolder:WaitForChild("CharacterCreationSystem"))
	end)
	
	if not success or not CharacterCreationSystem then
		return nil
	end
	
	return CharacterCreationSystem.getCharacterData(player.UserId)
end

-- Handle creation data requests (races, classes for UI)
getCreationDataRemote.OnServerInvoke = function(player: Player, requestType: string, raceId: string?)
	local CharacterCreationSystem
	local success = pcall(function()
		CharacterCreationSystem = require(sharedFolder:WaitForChild("CharacterCreationSystem"))
	end)
	
	if not success or not CharacterCreationSystem then
		return nil
	end
	
	if requestType == "races" then
		return CharacterCreationSystem.getPlayableRaces()
	elseif requestType == "classes" then
		return CharacterCreationSystem.getClasses()
	elseif requestType == "classesForRace" and raceId then
		return CharacterCreationSystem.getClassesForRace(raceId)
	elseif requestType == "origins" then
		return CharacterCreationSystem.getOrigins()
	elseif requestType == "arrivals" then
		return CharacterCreationSystem.getArrivalMethods()
	elseif requestType == "cheats" then
		return CharacterCreationSystem.getCheatAbilities()
	end
	
	return nil
end

-- Handle new players joining
Players.PlayerAdded:Connect(function(player: Player)
	-- Assign to default team (Commoners)
	local defaultRole = "Commoners"
	RoleManager.assignRole(player, defaultRole)
	print(string.format("[Server] %s joined and assigned to %s", player.Name, defaultRole))
end)

-- Handle players leaving (cleanup is done in RoleManager)
Players.PlayerRemoving:Connect(function(player: Player)
	print(string.format("[Server] %s left the game", player.Name))
end)

-- ============================================
-- Day/Night Cycle System
-- ============================================

local sky = Lighting:FindFirstChild("Sky")

-- Configuration
local CYCLE_DURATION = 60 -- seconds for a full 24h cycle
local ROTATION_SPEED = 5 -- degrees per second

-- Time settings: [clockTime] = { lighting properties }
local TIME_SETTINGS = {
	[0] = { -- Midnight
		Ambient = Color3.fromRGB(169, 49, 255),
		Brightness = 0,
		ColorShift_Bottom = Color3.new(),
		ColorShift_Top = Color3.fromRGB(100, 50, 150),
		OutdoorAmbient = Color3.fromRGB(0, 0, 50),
	},
	[6] = { -- Dawn
		Ambient = Color3.fromRGB(255, 200, 150),
		Brightness = 1,
		ColorShift_Bottom = Color3.fromRGB(255, 150, 100),
		ColorShift_Top = Color3.fromRGB(255, 200, 150),
		OutdoorAmbient = Color3.fromRGB(255, 180, 100),
	},
	[12] = { -- Noon
		Ambient = Color3.fromRGB(240, 167, 93),
		Brightness = 3,
		ColorShift_Bottom = Color3.new(),
		ColorShift_Top = Color3.fromRGB(213, 199, 0),
		OutdoorAmbient = Color3.fromRGB(251, 255, 0),
	},
	[18] = { -- Dusk
		Ambient = Color3.fromRGB(255, 130, 100),
		Brightness = 1,
		ColorShift_Bottom = Color3.fromRGB(180, 50, 50),
		ColorShift_Top = Color3.fromRGB(255, 150, 100),
		OutdoorAmbient = Color3.fromRGB(255, 100, 50),
	},
}

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function lerpColor3(a: Color3, b: Color3, t: number): Color3
	return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function getSettings(clockTime: number)
	local times = table.create(4)
	for k in pairs(TIME_SETTINGS) do table.insert(times, k) end
	table.sort(times)

	local current, nextIdx = times[1], 1
	for i = 1, #times do
		if times[i] <= clockTime then
			current = times[i]
			nextIdx = i < #times and i + 1 or 1
		end
	end

	local next = times[nextIdx]
	local currentSettings = TIME_SETTINGS[current]
	local nextSettings = TIME_SETTINGS[next]

	local t = (clockTime - current) / (next - current)
	if t < 0 then t = t + 1 end

	return {
		Ambient = lerpColor3(currentSettings.Ambient, nextSettings.Ambient, t),
		Brightness = lerp(currentSettings.Brightness, nextSettings.Brightness, t),
		ColorShift_Bottom = lerpColor3(currentSettings.ColorShift_Bottom, nextSettings.ColorShift_Bottom, t),
		ColorShift_Top = lerpColor3(currentSettings.ColorShift_Top, nextSettings.ColorShift_Top, t),
		OutdoorAmbient = lerpColor3(currentSettings.OutdoorAmbient, nextSettings.OutdoorAmbient, t),
	}
end

-- Day/night cycle heartbeat
RunService.Heartbeat:Connect(function(deltaTime)
	local cycleProgress = (workspace:GetServerTimeNow() % CYCLE_DURATION) / CYCLE_DURATION
	local clockTime = (cycleProgress * 24) % 24
	Lighting.ClockTime = clockTime

	if sky then
		sky.SkyboxOrientation = Vector3.new(0, (sky.SkyboxOrientation.Y + ROTATION_SPEED * deltaTime) % 360, 0)
	end

	local settings = getSettings(clockTime)
	Lighting.Ambient = settings.Ambient
	Lighting.Brightness = settings.Brightness
	Lighting.ColorShift_Bottom = settings.ColorShift_Bottom
	Lighting.ColorShift_Top = settings.ColorShift_Top
	Lighting.OutdoorAmbient = settings.OutdoorAmbient
end)

Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

print("[Server] Aethelgard server initialized")
