--!nonstrict
-- Client initialization script
-- Handles UI rendering and communication with server for role, race, and class selection

local React = require(game.ReplicatedStorage.Shared.React)
local ReactRoblox = require(game.ReplicatedStorage.Shared.ReactRoblox)
local TeamData = require(game.ReplicatedStorage.Shared.TeamData)
local RaceData = require(game.ReplicatedStorage.Shared.RaceData)
local ClassData = require(game.ReplicatedStorage.Shared.ClassData)

local ClientFolder = script.Parent:WaitForChild("Client")
local RoleSelectionMenu = require(ClientFolder:WaitForChild("RoleSelectionMenu"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Get RemoteEvent for role selection
local selectRoleRemote = ReplicatedStorage:WaitForChild("SelectRole")

-- Get RemoteEvent for race/class selection
local selectRaceRemote = ReplicatedStorage:FindFirstChild("SelectRace")
if not selectRaceRemote then
	selectRaceRemote = Instance.new("RemoteEvent")
	selectRaceRemote.Name = "SelectRace"
	selectRaceRemote.Parent = ReplicatedStorage
end

local selectClassRemote = ReplicatedStorage:FindFirstChild("SelectClass")
if not selectClassRemote then
	selectClassRemote = Instance.new("RemoteEvent")
	selectClassRemote.Name = "SelectClass"
	selectClassRemote.Parent = ReplicatedStorage
end

-- Get data from shared modules
local TEAM_DATA = TeamData.getTeamData()
local RACE_DATA = RaceData.getRaceData()
local CLASS_DATA = ClassData.getClassData()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReactRoot"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = ReactRoblox.createRoot(screenGui)

-- Create a wrapper component to manage state
local function App()
	local menuVisible, setMenuVisible = React.useState(true)

	-- Handle role (team) selection - sends request to server via RemoteEvent
	local function handleRoleSelected(roleName: string)
		-- Fire the RemoteEvent to request role change
		selectRoleRemote:FireServer(roleName)
		print("[Client] Requested role: " .. roleName)
	end

	-- Handle race selection - sends request to server via RemoteEvent
	local function handleRaceSelected(raceName: string)
		-- Fire the RemoteEvent to request race change
		selectRaceRemote:FireServer(raceName)
		print("[Client] Requested race: " .. raceName)
	end

	-- Handle class selection - sends request to server via RemoteEvent
	local function handleClassSelected(className: string)
		-- Fire the RemoteEvent to request class change
		selectClassRemote:FireServer(className)
		print("[Client] Requested class: " .. className)
	end

	local function handleMenuClose()
		setMenuVisible(false)
	end

	local function handleRebirth()
		setMenuVisible(true)
	end

	-- Show role selection menu with integrated race/class selection
	return React.createElement(RoleSelectionMenu, {
		visible = menuVisible,
		teamData = TEAM_DATA,
		raceData = RACE_DATA,
		classData = CLASS_DATA,
		onRoleSelected = handleRoleSelected,
		onRaceSelected = handleRaceSelected,
		onClassSelected = handleClassSelected,
		onMenuClose = handleMenuClose,
		onRebirth = handleRebirth,
	})
end

root:render(React.createElement(App))

print("[Client] Aethelgard client initialized")
