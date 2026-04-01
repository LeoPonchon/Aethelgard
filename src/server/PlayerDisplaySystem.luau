--!nonstrict
-- Player Display System
-- Shows player info (DisplayName, Team, Race, Class) above their character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDisplaySystem = {}

-- Configuration
local DISPLAY_CONFIG = {
	enabled = true,
	updateInterval = 2, -- seconds
	offset = Vector3.new(0, 3.5, 0), -- Height above player head
}

-- Colors for teams
local TEAM_COLORS = {
	["Royalty"] = Color3.fromRGB(255, 100, 100),
	["Nobility"] = Color3.fromRGB(180, 100, 255),
	["Special"] = Color3.fromRGB(255, 220, 100),
	["Demon Faction"] = Color3.fromRGB(200, 50, 50),
	["Commoners"] = Color3.fromRGB(100, 150, 255),
	["Elves"] = Color3.fromRGB(100, 200, 100),
	["Free Lineages"] = Color3.fromRGB(150, 150, 150),
	["Academy"] = Color3.fromRGB(255, 255, 255),
	["Events"] = Color3.fromRGB(50, 50, 50),
}

-- Race display names
local RACE_NAMES = {
	human = "Humain",
	elf = "Elfe",
	dwarf = "Nain",
	halfling = "Halfelin",
	orc = "Orc",
	demon = "Demon",
	tiefling = "Tiefling",
}

-- Create BillboardGui for a player
local function createPlayerDisplay(player: Player)
	local character = player.Character
	if not character then return end
	
	local head = character:FindFirstChild("Head")
	if not head then return end
	
	-- Create BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerDisplay"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 80)
	billboard.StudsOffset = DISPLAY_CONFIG.offset
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Main background
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 55)
	mainFrame.BackgroundTransparency = 0.3
	mainFrame.BorderSizePixel = 0
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Parent = billboard
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(120, 80, 150)
	uiStroke.Thickness = 1
	uiStroke.Parent = mainFrame
	
	-- Name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 25)
	nameLabel.Position = UDim2.new(0, 0, 0, 5)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Text = player.DisplayName
	nameLabel.Parent = mainFrame
	
	-- Team label
	local teamLabel = Instance.new("TextLabel")
	teamLabel.Name = "TeamLabel"
	teamLabel.BackgroundTransparency = 1
	teamLabel.Size = UDim2.new(1, 0, 0, 18)
	teamLabel.Position = UDim2.new(0, 0, 0, 30)
	teamLabel.Font = Enum.Font.Gotham
	teamLabel.TextSize = 12
	teamLabel.TextColor3 = Color3.fromRGB(180, 140, 220)
	teamLabel.Text = "Commoners"
	teamLabel.Parent = mainFrame
	
	-- Race and Class label
	local raceClassLabel = Instance.new("TextLabel")
	raceClassLabel.Name = "RaceClassLabel"
	raceClassLabel.BackgroundTransparency = 1
	raceClassLabel.Size = UDim2.new(1, 0, 0, 18)
	raceClassLabel.Position = UDim2.new(0, 0, 0, 48)
	raceClassLabel.Font = Enum.Font.Gotham
	raceClassLabel.TextSize = 11
	raceClassLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
	raceClassLabel.Text = "Humain - Guerrier"
	raceClassLabel.Parent = mainFrame
	
	-- Level indicator
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.BackgroundColor3 = Color3.fromRGB(80, 50, 100)
	levelLabel.Size = UDim2.new(0, 30, 0, 20)
	levelLabel.Position = UDim2.new(1, -35, 0, 5)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = 12
	levelLabel.TextColor3 = Color3.fromRGB(255, 220, 255)
	levelLabel.Text = "1"
	levelLabel.Parent = mainFrame
	
	local levelCorner = Instance.new("UICorner")
	levelCorner.CornerRadius = UDim.new(0, 4)
	levelCorner.Parent = levelLabel
	
	billboard.Parent = character
	
	return billboard
end

-- Update display for a player
local function updatePlayerDisplay(player: Player)
	local character = player.Character
	if not character then return end
	
	local display = character:FindFirstChild("PlayerDisplay")
	if not display then
		display = createPlayerDisplay(player)
		if not display then return end
	end
	
	local mainFrame = display:FindFirstChild("MainFrame")
	if not mainFrame then return end
	
	local nameLabel = mainFrame:FindFirstChild("NameLabel")
	local teamLabel = mainFrame:FindFirstChild("TeamLabel")
	local raceClassLabel = mainFrame:FindFirstChild("RaceClassLabel")
	local levelLabel = mainFrame:FindFirstChild("LevelLabel")
	
	-- Update name
	if nameLabel then
		nameLabel.Text = player.DisplayName
	end
	
	-- Get player team
	local playerTeam = player.Team
	if playerTeam and teamLabel then
		teamLabel.Text = playerTeam.Name
		
		-- Color based on team
		local teamColor = TEAM_COLORS[playerTeam.Name] or Color3.fromRGB(180, 140, 220)
		teamLabel.TextColor3 = teamColor
	end
	
	-- Get character data from attributes or leaderstats
	local race = "Humain"
	local className = "Guerrier"
	local level = 1
	
	-- Try to get from attributes
	if player:GetAttribute("Race") then
		race = RACE_NAMES[player:GetAttribute("Race")] or player:GetAttribute("Race")
	end
	if player:GetAttribute("Class") then
		className = player:GetAttribute("Class")
	end
	if player:GetAttribute("Level") then
		level = player:GetAttribute("Level")
	end
	
	-- Try to get from leaderstats
	if player:FindFirstChild("leaderstats") then
		local levelStat = player.leaderstats:FindFirstChild("Level")
		if levelStat and levelStat:IsA("IntValue") then
			level = levelStat.Value
		end
	end
	
	-- Update race/class label
	if raceClassLabel then
		raceClassLabel.Text = race .. " - " .. className
	end
	
	-- Update level
	if levelLabel then
		levelLabel.Text = tostring(level)
	end
end

-- Handle player character added
local function onCharacterAdded(player: Player)
	task.wait(0.5) -- Wait for character to fully load
	if DISPLAY_CONFIG.enabled then
		updatePlayerDisplay(player)
	end
end

-- Handle player team changed
local function onTeamChanged(player: Player)
	if DISPLAY_CONFIG.enabled then
		updatePlayerDisplay(player)
	end
end

-- Handle player attribute changed (for Race, Class, Level)
local function onAttributeChanged(player: Player, attributeName: string)
	if DISPLAY_CONFIG.enabled then
		updatePlayerDisplay(player)
	end
end

-- Initialize the system
function PlayerDisplaySystem.init()
	print("[PlayerDisplaySystem] Initializing...")

	-- Connect events
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			onCharacterAdded(player)
		end)
		player:GetPropertyChangedSignal("Team"):Connect(function()
			onTeamChanged(player)
		end)

		-- Listen for Race attribute changes
		player:GetAttributeChangedSignal("Race"):Connect(function()
			onAttributeChanged(player, "Race")
		end)

		-- Listen for Class attribute changes
		player:GetAttributeChangedSignal("Class"):Connect(function()
			onAttributeChanged(player, "Class")
		end)

		-- Listen for Level attribute changes
		player:GetAttributeChangedSignal("Level"):Connect(function()
			onAttributeChanged(player, "Level")
		end)

		-- If character already exists
		if player.Character then
			task.spawn(function()
				task.wait(0.5)
				onCharacterAdded(player)
			end)
		end
	end)
	
	-- Update all players periodically
	task.spawn(function()
		while DISPLAY_CONFIG.enabled do
			task.wait(DISPLAY_CONFIG.updateInterval)
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("Head") then
					pcall(updatePlayerDisplay, player)
				end
			end
		end
	end)
	
	print("[PlayerDisplaySystem] Initialized")
end

-- Set player character data
function PlayerDisplaySystem.setPlayerData(player: Player, race: string, className: string, level: number)
	player:SetAttribute("Race", race)
	player:SetAttribute("Class", className)
	player:SetAttribute("Level", level or 1)
	
	-- Update display immediately
	task.spawn(function()
		task.wait(0.1)
		updatePlayerDisplay(player)
	end)
end

-- Enable/disable system
function PlayerDisplaySystem.setEnabled(enabled: boolean)
	DISPLAY_CONFIG.enabled = enabled
end

return PlayerDisplaySystem