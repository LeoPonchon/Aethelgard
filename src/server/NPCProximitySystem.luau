--!nonstrict
-- NPC Proximity System for Aethelgard
-- Adds ProximityPrompts to NPCs for interaction

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local NPCProximitySystem = {}

local CONFIG = {
	promptRange = 10,
	promptHoldDuration = 0.5,
}

local NPC_DEFINITIONS = {
	["Village_Elder"] = {
		id = "Village_Elder",
		name = "Village Elder",
		title = "Guide of the Beginning",
	},
}

local function createPrompt(npcModel, npcId, npcData)
	local humanoidRootPart = npcModel:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		humanoidRootPart = npcModel:FindFirstChild("Torso")
	end
	if not humanoidRootPart then
		humanoidRootPart = npcModel:FindFirstChild("Head")
	end
	if not humanoidRootPart then return nil end

	local existingPrompt = humanoidRootPart:FindFirstChild("InteractionPrompt")
	if existingPrompt then return existingPrompt end

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

	prompt.Triggered:Connect(function(player)
		local npcDialogueEvent = ReplicatedStorage:FindFirstChild("NPCDialogue")
		if npcDialogueEvent then
			npcDialogueEvent:FireClient(player, {
				npcId = npcId,
				npcName = npcData.name,
			})
		end
	end)

	return prompt
end

local function setupNPCPrompts()
	for npcId, npcData in pairs(NPC_DEFINITIONS) do
		local npcModel = workspace:FindFirstChild(npcId)
		if npcModel then
			createPrompt(npcModel, npcId, npcData)
		end

		local npcsFolder = workspace:FindFirstChild("NPCs")
		if npcsFolder then
			local npcInFolder = npcsFolder:FindFirstChild(npcId)
			if npcInFolder then
				createPrompt(npcInFolder, npcId, npcData)
			end
		end
	end

	workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			local npcData = NPC_DEFINITIONS[child.Name]
			if npcData then
				task.wait(0.5)
				createPrompt(child, child.Name, npcData)
			end
		end
	end)

	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		npcsFolder.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				local npcData = NPC_DEFINITIONS[child.Name]
				if npcData then
					task.wait(0.5)
					createPrompt(child, child.Name, npcData)
				end
			end
		end)
	end
end

function NPCProximitySystem.init()
	setupNPCPrompts()
	print("[NPCProximitySystem] Initialized")
end

print("[NPCProximitySystem] Module loaded")
return NPCProximitySystem
