--!nonstrict
-- Player Display System for Aethelgard
-- Shows player name, team, level, race and class above their character

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local DataHelpers = require(sharedFolder:WaitForChild("DataHelpers"))
local PlayerDataSystem = require(script.Parent:WaitForChild("PlayerDataSystem"))

local PlayerDisplaySystem = {}

local DISPLAY_CONFIG = {
	enabled = true,
	updateInterval = 2,
	offset = Vector3.new(0, 3.5, 0),
	maxDistance = 25,
}

local function createPlayerDisplay(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerDisplay"
	billboard.Adornee = head
	billboard.Size = UDim2.new(5, 0, 2.2, 0)
	billboard.StudsOffset = DISPLAY_CONFIG.offset
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false
	billboard.MaxDistance = DISPLAY_CONFIG.maxDistance

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 55)
	mainFrame.BackgroundTransparency = 0.2
	mainFrame.BorderSizePixel = 0
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Parent = billboard

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.1, 0)
	uiCorner.Parent = mainFrame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(120, 80, 150)
	uiStroke.Thickness = 1.5
	uiStroke.Parent = mainFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Text = player.DisplayName
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = mainFrame

	local teamLabel = Instance.new("TextLabel")
	teamLabel.Name = "TeamLabel"
	teamLabel.BackgroundTransparency = 1
	teamLabel.Size = UDim2.new(1, 0, 0.2, 0)
	teamLabel.Position = UDim2.new(0, 0, 0.25, 0)
	teamLabel.Font = Enum.Font.Gotham
	teamLabel.TextSize = 13
	teamLabel.TextColor3 = Color3.fromRGB(180, 140, 220)
	teamLabel.Text = "Commoners"
	teamLabel.TextStrokeTransparency = 0.5
	teamLabel.Parent = mainFrame

	local raceLabel = Instance.new("TextLabel")
	raceLabel.Name = "RaceLabel"
	raceLabel.BackgroundTransparency = 1
	raceLabel.Size = UDim2.new(1, 0, 0.2, 0)
	raceLabel.Position = UDim2.new(0, 0, 0.45, 0)
	raceLabel.Font = Enum.Font.Gotham
	raceLabel.TextSize = 12
	raceLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
	raceLabel.Text = "Human"
	raceLabel.TextStrokeTransparency = 0.5
	raceLabel.Parent = mainFrame

	local classLabel = Instance.new("TextLabel")
	classLabel.Name = "ClassLabel"
	classLabel.BackgroundTransparency = 1
	classLabel.Size = UDim2.new(1, 0, 0.2, 0)
	classLabel.Position = UDim2.new(0, 0, 0.65, 0)
	classLabel.Font = Enum.Font.Gotham
	classLabel.TextSize = 12
	classLabel.TextColor3 = Color3.fromRGB(200, 180, 100)
	classLabel.Text = "Classless"
	classLabel.TextStrokeTransparency = 0.5
	classLabel.Parent = mainFrame

	local levelBadge = Instance.new("Frame")
	levelBadge.Name = "LevelBadge"
	levelBadge.BackgroundColor3 = Color3.fromRGB(100, 60, 120)
	levelBadge.Size = UDim2.new(0, 35, 0, 22)
	levelBadge.Position = UDim2.new(1, -40, 0, 4)
	levelBadge.BorderSizePixel = 0
	levelBadge.ZIndex = 10
	levelBadge.Parent = mainFrame

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 6)
	badgeCorner.Parent = levelBadge

	local badgeStroke = Instance.new("UIStroke")
	badgeStroke.Color = Color3.fromRGB(180, 140, 220)
	badgeStroke.Thickness = 1.5
	badgeStroke.Parent = levelBadge

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.BackgroundTransparency = 1
	levelLabel.Size = UDim2.new(1, 0, 1, 0)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = 11
	levelLabel.TextColor3 = Color3.fromRGB(255, 230, 255)
	levelLabel.Text = "1"
	levelLabel.TextStrokeTransparency = 0.3
	levelLabel.ZIndex = 11
	levelLabel.Parent = levelBadge

	billboard.Parent = character

	return billboard
end

local function updatePlayerDisplay(player)
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
	local raceLabel = mainFrame:FindFirstChild("RaceLabel")
	local classLabel = mainFrame:FindFirstChild("ClassLabel")
	local levelBadge = mainFrame:FindFirstChild("LevelBadge")

	if nameLabel then
		nameLabel.Text = player.DisplayName
	end

	if teamLabel and player.Team then
		teamLabel.Text = player.Team.Name
		local teamData = DataHelpers.getTeamByName(player.Team.Name)
		if teamData and teamData.color then
			teamLabel.TextColor3 = teamData.color
		end
	end

	local playerData = PlayerDataSystem.getPlayerData(player.UserId)

	if raceLabel then
		local raceData = DataHelpers.getRaceById(playerData.race)
		raceLabel.Text = raceData and (raceData.displayName or raceData.name) or playerData.race
	end

	if classLabel then
		local classData = DataHelpers.getClassById(playerData.class)
		classLabel.Text = classData and (classData.displayName or classData.name) or playerData.class
	end

	if levelBadge then
		local levelLabel = levelBadge:FindFirstChild("LevelLabel")
		if levelLabel then
			levelLabel.Text = tostring(playerData.level)
		end
	end
end

local function onCharacterAdded(player)
	task.wait(0.5)
	if DISPLAY_CONFIG.enabled then
		updatePlayerDisplay(player)
	end
end

function PlayerDisplaySystem.init()
	print("[PlayerDisplaySystem] Initializing...")

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			onCharacterAdded(player)
		end)

		if player.Character then
			task.spawn(function()
				task.wait(0.5)
				onCharacterAdded(player)
			end)
		end
	end)

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

function PlayerDisplaySystem.updatePlayer(player)
	updatePlayerDisplay(player)
end

print("[PlayerDisplaySystem] Module loaded")
return PlayerDisplaySystem
