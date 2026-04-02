--!nonstrict
-- Proximity Prompt System for Aethelgard
-- Handles player interactions with NPCs and locations via ProximityPrompts
-- Players press E to interact and trigger actions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ActionBasedProgressionSystem = require(ReplicatedStorage.Shared:WaitForChild("ActionBasedProgressionSystem"))
local NPCInteractionSystem = require(script.Parent:WaitForChild("NPCInteractionSystem"))
local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))
local PlayerDisplaySystem = require(script.Parent:WaitForChild("PlayerDisplaySystem"))

local npcDialogueEvent = ReplicatedStorage:FindFirstChild("NPCDialogue")
if not npcDialogueEvent then
	npcDialogueEvent = Instance.new("RemoteEvent")
	npcDialogueEvent.Name = "NPCDialogue"
	npcDialogueEvent.Parent = ReplicatedStorage
end

local ProximityPromptSystem = {}

-- Configuration
local CONFIG = {
	promptRange = 10,
	promptHoldDuration = 0.5,
	showInteractionDistance = 8,
}

-- Location definitions with their actions
local LOCATION_DEFINITIONS = {
	-- Academy Locations
	["Academy_Entrance"] = {
		name = "Academy",
		actionType = "VisitLocation",
		target = "Academy",
		description = "Visit the Academy",
		unlockTeam = "Academy Externals",
	},
	["Training_Arena"] = {
		name = "Training Arena",
		actionType = "TrainAtAcademy",
		target = "Training_Arena",
		description = "Train in combat",
	},
	["Mage_Tower"] = {
		name = "Mage Tower",
		actionType = "TrainAtAcademy",
		target = "Mage_Tower",
		description = "Train in magic",
	},

	-- Demon Locations
	["Demon_Portal"] = {
		name = "Demonic Portal",
		actionType = "VisitLocation",
		target = "Demon Portal",
		description = "Approach the demonic portal",
		unlockTeam = "Demon Servants",
		meditationSpots = {
			{name = "Meditate at the portal", actionType = "Meditate", target = "Demon Portal"}
		},
	},

	-- Elven Locations
	["Elven_Forest"] = {
		name = "Elven Forest",
		actionType = "VisitLocation",
		target = "Elven Forest",
		description = "Explore the sacred forest",
		unlockTeam = "Elves Faction",
	},
	["Sacred_Tree"] = {
		name = "Sacred Tree",
		actionType = "Meditate",
		target = "Sacred Tree",
		description = "Meditate at the Sacred Tree",
	},

	-- Castle Locations
	["Castle_Gates"] = {
		name = "Castle Gates",
		actionType = "VisitLocation",
		target = "Castle",
		description = "Visit the castle",
	},
	["Throne_Room"] = {
		name = "Throne Room",
		actionType = "VisitLocation",
		target = "Throne Room",
		description = "Enter the throne room",
		special = "Throne", -- Special interaction for becoming King/Queen
	},

	-- Other Locations
	["Village_Square"] = {
		name = "Village Square",
		actionType = "VisitLocation",
		target = "Village",
		description = "Explore the village",
	},
	["Guild_Hall"] = {
		name = "Guild Hall",
		actionType = "VisitLocation",
		target = "Guild",
		description = "Visit the guild",
	},
	["Temple"] = {
		name = "Temple",
		actionType = "Pray",
		target = "Temple",
		description = "Pray at the temple",
	},
	["Corrupted_Zone"] = {
		name = "Corrupted Zone",
		actionType = "VisitLocation",
		target = "Corrupted_Zone",
		description = "Explore the corrupted zone",
	},
}

-- NPC definitions mapped to NPCInteractionSystem IDs
local NPC_PROMPT_DEFINITIONS = {
	["Village_Elder"] = {
		npcId = "Village_Elder",
		name = "Village Elder",
		title = "Guide of the Beginning",
	},
	["Guild_Master"] = {
		npcId = "Guild_Master",
		name = "Guild Master",
		title = "Adventurers Leader",
	},
	["Academy_Headmaster"] = {
		npcId = "Academy_Headmaster",
		name = "Academy Headmaster",
		title = "Archmage",
	},
	["Combat_Instructor"] = {
		npcId = "Combat_Instructor",
		name = "Combat Instructor",
		title = "Weapon Master",
	},
	["Magic_Instructor"] = {
		npcId = "Magic_Instructor",
		name = "Magic Instructor",
		title = "Senior Mage",
	},
	["Demon_Portal_Keeper"] = {
		npcId = "Demon_Portal_Keeper",
		name = "Portal Keeper",
		title = "Servant of Darkness",
	},
	["Elven_Elder"] = {
		npcId = "Elven_Elder",
		name = "Elven Elder",
		title = "Forest Guardian",
	},
	["Castle_Captain"] = {
		npcId = "Castle_Captain",
		name = "Castle Captain",
		title = "Guard Commander",
	},
	["High_Priest"] = {
		npcId = "High_Priest",
		name = "High Priest",
		title = "Servant of the Gods",
	},
}

-- Forward declarations for handler functions
local onNPCPromptTriggered
local onLocationPromptTriggered

-- Handle NPC prompt triggered
local function onNPCPromptTriggered(player: Player, npcKey: string)
	local npcData = NPC_PROMPT_DEFINITIONS[npcKey]
	if not npcData then return end

	-- Record the TalkToNPC action
	local events = ActionBasedProgressionSystem.recordAction(player.UserId, {
		actionType = "TalkToNPC",
		target = npcData.npcId,
	})

	-- Trigger dialogue on client
	npcDialogueEvent:FireClient(player, {
		npcId = npcData.npcId,
		npcName = npcData.name,
	})

	-- Update player display
	PlayerDisplaySystem.onProgressionChanged(player)
end

-- Handle location prompt triggered
local function onLocationPromptTriggered(player: Player, locationKey: string)
	local locationData = LOCATION_DEFINITIONS[locationKey]
	if not locationData then return end

	-- Record the action
	local events = ActionBasedProgressionSystem.recordAction(player.UserId, {
		actionType = locationData.actionType,
		target = locationData.target,
	})

	-- Check for team unlock
	if locationData.unlockTeam then
		local teamData = ActionBasedProgressionSystem.getTeamInfo(locationData.unlockTeam)
		if teamData then
			local success = ActionBasedProgressionSystem.joinTeam(player.UserId, locationData.unlockTeam)
			if success then
				table.insert(events, "TEAM_JOINED:" .. locationData.unlockTeam)
			end
		end
	end

	-- Update player display
	PlayerDisplaySystem.onProgressionChanged(player)

	-- Notify client of events
	local actionEvent = ReplicatedStorage:FindFirstChild("PlayerAction")
	if actionEvent and #events > 0 then
		actionEvent:FireClient(player, {
			events = events,
			location = locationData.name,
		})
	end
end

-- Create a ProximityPrompt for an NPC
local function createNPCPrompt(npcModel: Model, npcKey: string): ProximityPrompt?
	local npcData = NPC_PROMPT_DEFINITIONS[npcKey]
	if not npcData then return nil end

	-- Find or create the prompt attachment
	local humanoidRootPart = npcModel:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		humanoidRootPart = npcModel:FindFirstChild("Torso")
	end
	if not humanoidRootPart then return nil end

	-- Check if prompt already exists
	local existingPrompt = humanoidRootPart:FindFirstChild("InteractionPrompt")
	if existingPrompt then return existingPrompt end

	-- Create ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractionPrompt"
	prompt.ActionText = "Talk"
	prompt.ObjectText = npcData.name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = CONFIG.promptHoldDuration
	prompt.MaxActivationDistance = CONFIG.promptRange
	prompt.RequiresLineOfSight = false
	prompt.Parent = humanoidRootPart

	-- Connect the trigger event
	prompt.Triggered:Connect(function(player)
		onNPCPromptTriggered(player, npcKey)
	end)

	return prompt
end

-- Create a ProximityPrompt for a location
local function createLocationPrompt(part: BasePart, locationKey: string): ProximityPrompt?
	local locationData = LOCATION_DEFINITIONS[locationKey]
	if not locationData then return nil end

	-- Check if prompt already exists
	local existingPrompt = part:FindFirstChild("LocationPrompt")
	if existingPrompt then return existingPrompt end

	-- Create ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "LocationPrompt"
	prompt.ActionText = locationData.description or locationData.name
	prompt.ObjectText = locationData.name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = CONFIG.promptHoldDuration
	prompt.MaxActivationDistance = CONFIG.promptRange
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	-- Connect the trigger event
	prompt.Triggered:Connect(function(player)
		onLocationPromptTriggered(player, locationKey)
	end)

	return prompt
end

-- Setup prompts for all NPCs in workspace
function ProximityPromptSystem.setupNPCPrompts()
	-- Find NPCs anywhere in workspace (not just in NPCs folder)
	for npcKey, _ in pairs(NPC_PROMPT_DEFINITIONS) do
		local npcModel = workspace:FindFirstChild(npcKey)
		if npcModel then
			createNPCPrompt(npcModel, npcKey)
		end
	end

	-- Also check in NPCs folder if it exists
	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for npcKey, _ in pairs(NPC_PROMPT_DEFINITIONS) do
			local npcModel = npcsFolder:FindFirstChild(npcKey)
			if npcModel then
				createNPCPrompt(npcModel, npcKey)
			end
		end
	end

	-- Listen for new NPCs being added anywhere in workspace
	workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			local npcKey = child.Name
			if NPC_PROMPT_DEFINITIONS[npcKey] then
				createNPCPrompt(child, npcKey)
			end
		end
	end)

	-- Also listen in NPCs folder if it exists
	if npcsFolder then
		npcsFolder.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				local npcKey = child.Name
				if NPC_PROMPT_DEFINITIONS[npcKey] then
					createNPCPrompt(child, npcKey)
				end
			end
		end)
	end
end

-- Setup prompts for all locations in workspace
function ProximityPromptSystem.setupLocationPrompts()
	-- Find locations anywhere in workspace (not just in Locations folder)
	for locationKey, _ in pairs(LOCATION_DEFINITIONS) do
		local locationPart = workspace:FindFirstChild(locationKey)
		if locationPart and locationPart:IsA("BasePart") then
			createLocationPrompt(locationPart, locationKey)
		end
	end

	-- Also check in Locations folder if it exists
	local locationsFolder = workspace:FindFirstChild("Locations")
	if locationsFolder then
		for locationKey, _ in pairs(LOCATION_DEFINITIONS) do
			local locationPart = locationsFolder:FindFirstChild(locationKey)
			if locationPart and locationPart:IsA("BasePart") then
				createLocationPrompt(locationPart, locationKey)
			end
		end
	end

	-- Listen for new locations being added anywhere in workspace
	workspace.ChildAdded:Connect(function(child)
		if child:IsA("BasePart") then
			local locationKey = child.Name
			if LOCATION_DEFINITIONS[locationKey] then
				createLocationPrompt(child, locationKey)
			end
		end
	end)

	-- Also listen in Locations folder if it exists
	if locationsFolder then
		locationsFolder.ChildAdded:Connect(function(child)
			if child:IsA("BasePart") then
				local locationKey = child.Name
				if LOCATION_DEFINITIONS[locationKey] then
					createLocationPrompt(child, locationKey)
				end
			end
		end)
	end
end

-- Connect prompt triggers to handlers
function ProximityPromptSystem.init()
	-- Setup all prompts (events are connected in create functions)
	ProximityPromptSystem.setupNPCPrompts()
	ProximityPromptSystem.setupLocationPrompts()

	print("[ProximityPromptSystem] Initialized with NPC and location prompts")
end

-- Get location definitions for external use
function ProximityPromptSystem.getLocationDefinitions()
	return LOCATION_DEFINITIONS
end

-- Get NPC definitions for external use
function ProximityPromptSystem.getNPCDefinitions()
	return NPC_PROMPT_DEFINITIONS
end

return ProximityPromptSystem