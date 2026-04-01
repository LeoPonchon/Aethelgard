--!nonstrict
-- Server-side role management module
-- Handles role validation, slot management, and player assignments

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeamData = require(ReplicatedStorage.Shared:WaitForChild("TeamData"))
local PlayerDisplaySystem = require(script.Parent:WaitForChild("PlayerDisplaySystem"))
local CharacterCreationSystem = require(ReplicatedStorage.Shared:WaitForChild("CharacterCreationSystem"))

-- Track current role assignments
local roleAssignments: { [string]: { Player } } = {}
local playerRoles: { [number]: string } = {}

-- Initialize role assignments table
local function initializeRoleAssignments()
	for _, category in ipairs(TeamData.getTeamData()) do
		for _, teamInfo in ipairs(category.teams) do
			roleAssignments[teamInfo.name] = {}
		end
	end
end

-- Count players in a specific role
local function countPlayersInRole(roleName: string): number
	local assignments = roleAssignments[roleName]
	if not assignments then
		return 0
	end
	return #assignments
end

-- Check if a player can join a specific role
local function canJoinRole(player: Player, roleName: string): (boolean, string?)
	-- Validate role exists
	if not TeamData.isValidRole(roleName) then
		return false, "Invalid role"
	end

	-- Check permission level
	local permissionLevel = TeamData.getRolePermission(roleName)
	
	if permissionLevel == 2 then
		-- Admin only - check if player has admin privileges
		-- For now, we'll use a simple check (can be expanded later)
		-- You could integrate with Roblox's built-in admin system or custom admin
		if player:GetRankInGroup(0) < 254 then -- Placeholder: replace with actual admin check
			-- For development, allow all players to join any role
			-- In production, uncomment the return below:
			-- return false, "This role requires admin privileges"
		end
	elseif permissionLevel == 1 then
		-- Requires permission - could check whitelist, group rank, etc.
		-- For now, allow all players (can be expanded)
	end

	-- Check slot availability
	local maxSlots = TeamData.getMaxSlots(roleName)
	if maxSlots > 0 then
		local currentCount = countPlayersInRole(roleName)
		if currentCount >= maxSlots then
			return false, "This role is full"
		end
	end

	-- Check if role is locked (slots = 0)
	if maxSlots == 0 then
		return false, "This role is currently locked"
	end

	return true, nil
end

-- Remove player from their current role
local function removeFromCurrentRole(player: Player)
	local currentRole = playerRoles[player.UserId]
	if not currentRole then
		return
	end

	local assignments = roleAssignments[currentRole]
	if assignments then
		for i, p in ipairs(assignments) do
			if p.UserId == player.UserId then
				table.remove(assignments, i)
				break
			end
		end
	end

	playerRoles[player.UserId] = nil
end

-- Add player to a new role
local function addToRole(player: Player, roleName: string)
	-- Remove from current role first
	removeFromCurrentRole(player)

	-- Add to new role
	local assignments = roleAssignments[roleName]
	if assignments then
		table.insert(assignments, player)
	end

	playerRoles[player.UserId] = roleName

	-- Assign the actual team
	local team = Teams:FindFirstChild(roleName)
	if team then
	player.Team = team
	-- Update player display
	local characterData = CharacterCreationSystem.getCharacterData(player.UserId)
	if characterData then
	PlayerDisplaySystem.setPlayerData(player, characterData.raceId, characterData.classId, 1)
	end
	end
	end

-- Validate and assign role to player
local function assignRole(player: Player, roleName: string): (boolean, string?)
	-- Validate the role
	local canJoin, reason = canJoinRole(player, roleName)
	if not canJoin then
		return false, reason
	end

	-- Assign the role
	addToRole(player, roleName)

	print(string.format("[RoleManager] %s assigned to role: %s", player.Name, roleName))
	return true, nil
end

-- Get player's current role
local function getPlayerRole(player: Player): string?
	return playerRoles[player.UserId]
end

-- Get available slots for a role
local function getAvailableSlots(roleName: string): number
	local maxSlots = TeamData.getMaxSlots(roleName)
	if maxSlots < 0 then
		return -1 -- Unlimited
	end
	if maxSlots == 0 then
		return 0 -- Locked
	end

	local currentCount = countPlayersInRole(roleName)
	return math.max(0, maxSlots - currentCount)
end

-- Anti-cheat: Validate player's current team
local function validatePlayerTeam(player: Player)
	local currentRole = playerRoles[player.UserId]
	local actualTeam = player.Team

	if actualTeam then
		if currentRole ~= actualTeam.Name then
			-- Player's team doesn't match recorded role
			-- This could indicate tampering
			warn(string.format("[RoleManager] Team mismatch for %s: expected %s, got %s", 
				player.Name, currentRole or "none", actualTeam.Name))
			
			-- Correct the assignment
			if currentRole then
			local team = Teams:FindFirstChild(currentRole)
			if team then
			player.Team = team
			-- Update player display
			local characterData = CharacterCreationSystem.getCharacterData(player.UserId)
			if characterData then
			PlayerDisplaySystem.setPlayerData(player, characterData.raceId, characterData.classId, 1)
			end
			end
			else
			-- Assign to default team
			local defaultTeam = Teams:FindFirstChild(TeamData.getDefaultTeam())
			if defaultTeam then
			player.Team = defaultTeam
			-- Update player display
			local characterData = CharacterCreationSystem.getCharacterData(player.UserId)
			if characterData then
			PlayerDisplaySystem.setPlayerData(player, characterData.raceId, characterData.classId, 1)
			end
			end
			end
			end
			end
			end

-- Handle player leaving
local function onPlayerRemoving(player: Player)
	removeFromCurrentRole(player)
end

-- Initialize teams in the game
local function initializeTeams()
	-- Generate unique colors for each team
	-- We use a hash of the team name to generate a unique color
	local teamColors = TeamData.getTeamColors()
	local usedColors = {}
	
	local function generateUniqueColor(teamName: string): BrickColor
		-- Generate a unique BrickColor based on team name
		-- This ensures each team has a distinct color
		local hash = 0
		for i = 1, #teamName do
			hash = (hash * 31 + string.byte(teamName, i)) % 1000
		end
		
		-- Map to available BrickColors (avoiding duplicates)
		local colorPalette = {
			BrickColor.new("Bright red"),
			BrickColor.new("Bright blue"),
			BrickColor.new("Bright green"),
			BrickColor.new("Bright yellow"),
			BrickColor.new("Bright orange"),
			BrickColor.new("Bright violet"),
			BrickColor.new("Bright red"),
			BrickColor.new("Cyan"),
			BrickColor.new("Magenta"),
			BrickColor.new("Lime green"),
			BrickColor.new("Teal"),
			BrickColor.new("Pink"),
			BrickColor.new("Br. yellowish orange"),
			BrickColor.new("Br. reddish orange"),
			BrickColor.new("Br. green"),
			BrickColor.new("Br. blue"),
			BrickColor.new("Br. violet"),
			BrickColor.new("Dark red"),
			BrickColor.new("Dark blue"),
			BrickColor.new("Dark green"),
			BrickColor.new("Dark orange"),
			BrickColor.new("Dark violet"),
			BrickColor.new("Navy blue"),
			BrickColor.new("Forest green"),
			BrickColor.new("Brown"),
			BrickColor.new("White"),
			BrickColor.new("Black"),
			BrickColor.new("Grey"),
			BrickColor.new("Light grey"),
			BrickColor.new("Dark grey"),
			BrickColor.new("Institutional white"),
			BrickColor.new("Institutional black"),
			BrickColor.new("Pastel yellow"),
			BrickColor.new("Pastel blue"),
			BrickColor.new("Pastel green"),
			BrickColor.new("Pastel orange"),
			BrickColor.new("Pastel violet"),
			BrickColor.new("Pastel red"),
			BrickColor.new("Dusty yellow"),
			BrickColor.new("Dusty blue"),
			BrickColor.new("Dusty green"),
			BrickColor.new("Dusty orange"),
			BrickColor.new("Dusty violet"),
			BrickColor.new("Dusty red"),
		}
		
		local colorIndex = (hash % #colorPalette) + 1
		return colorPalette[colorIndex]
	end

	for _, category in ipairs(TeamData.getTeamData()) do
		for _, teamInfo in ipairs(category.teams) do
			local team = Teams:FindFirstChild(teamInfo.name)
			if not team then
				team = Instance.new("Team")
				team.Name = teamInfo.name
				-- Each team gets a unique color so they are distinct in Roblox
				team.TeamColor = generateUniqueColor(teamInfo.name)
				team.AutoAssignable = false
				team.Parent = Teams
			else
				-- Update existing team's color if needed
				team.TeamColor = generateUniqueColor(teamInfo.name)
			end
		end
	end
end

-- Module export
local RoleManager = {}

function RoleManager.init()
	initializeRoleAssignments()
	initializeTeams()

	-- Set up player removal handler
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Anti-cheat: Periodically validate all players' teams
	task.spawn(function()
		while true do
			task.wait(30) -- Check every 30 seconds
			for _, player in ipairs(Players:GetPlayers()) do
				validatePlayerTeam(player)
			end
		end
	end)

	print("[RoleManager] Initialized")
end

-- Public methods
RoleManager.assignRole = assignRole
RoleManager.getPlayerRole = getPlayerRole
RoleManager.getAvailableSlots = getAvailableSlots
RoleManager.countPlayersInRole = countPlayersInRole
RoleManager.canJoinRole = canJoinRole
RoleManager.validatePlayerTeam = validatePlayerTeam

return RoleManager
