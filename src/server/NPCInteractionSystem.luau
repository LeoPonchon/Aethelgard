--!nonstrict
-- NPC Interaction System for Aethelgard
-- Handles dialogue with villagers

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local DataHelpers = require(sharedFolder:WaitForChild("DataHelpers"))

local NPCInteractionSystem = {}

local NPC_DEFINITIONS = {
	["Village_Elder"] = {
		id = "Village_Elder",
		name = "Village Elder",
		title = "Guide of the Beginning",
		npcType = "VillageElder",
		description = "The wise elder of the village who welcomes newcomers.",
		location = "Village_Square",
		faction = nil,
	},
}

function NPCInteractionSystem.getNPC(npcId)
	return NPC_DEFINITIONS[npcId]
end

function NPCInteractionSystem.getAllNPCs()
	return NPC_DEFINITIONS
end

function NPCInteractionSystem.hasDialogue(npcId)
	return DataHelpers.hasDialogue(npcId)
end

function NPCInteractionSystem.startConversation(playerId, npcId)
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then return nil end

	if not DataHelpers.hasDialogue(npcId) then
		warn("[NPCInteractionSystem] No dialogue found for NPC:", npcId)
		return nil
	end

	local npcPosition = nil
	local npcModel = workspace:FindFirstChild(npcId)
	if not npcModel then
		npcModel = workspace:FindFirstChild(npcId .. "_NPC")
	end
	if not npcModel then
		local npcsFolder = workspace:FindFirstChild("NPCs")
		if npcsFolder then
			npcModel = npcsFolder:FindFirstChild(npcId)
		end
	end
	if npcModel then
		local rootPart = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Torso") or npcModel:FindFirstChild("Head")
		if rootPart then
			npcPosition = rootPart.Position
		end
	end

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = "start",
		playerData = { team = "Commoners", class = nil, race = nil },
		npcPosition = npcPosition,
	}
end

function NPCInteractionSystem.getCurrentDialogue(playerId, npcId, currentNode)
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then return nil end

	local playerData = { team = "Commoners", class = nil, race = nil }
	local rule = DataHelpers.getDialogueForPlayer(npcId, currentNode, playerData)

	if not rule then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = currentNode,
			text = "Le NPC n'a rien a dire.",
			options = {},
			hasChoices = false,
		}
	end

	local options = rule.options or {}
	local hasChoices = #options > 0

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = currentNode,
		text = rule.npcText,
		options = options,
		hasChoices = hasChoices,
	}
end

function NPCInteractionSystem.advanceDialogue(playerId, npcId, currentNode, optionIndex)
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then return nil end

	local playerData = { team = "Commoners", class = nil, race = nil }
	local currentRule = DataHelpers.getDialogueForPlayer(npcId, currentNode, playerData)

	if not currentRule or not currentRule.options or #currentRule.options == 0 then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = currentNode,
			text = nil,
			options = {},
			hasChoices = false,
			endConversation = true,
		}
	end

	local selectedOption = currentRule.options[optionIndex or 1]
	if not selectedOption or not selectedOption.nextNode then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = currentNode,
			text = nil,
			options = {},
			hasChoices = false,
			endConversation = true,
		}
	end

	local nextNode = selectedOption.nextNode
	local nextRule = DataHelpers.getDialogueForPlayer(npcId, nextNode, playerData)

	if not nextRule then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = nextNode,
			text = "Le NPC n'a rien a dire.",
			options = {},
			hasChoices = false,
			endConversation = true,
		}
	end

	local nextOptions = nextRule.options or {}
	local hasChoices = #nextOptions > 0

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = nextNode,
		text = nextRule.npcText,
		options = nextOptions,
		hasChoices = hasChoices,
		endConversation = not hasChoices,
	}
end

print("[NPCInteractionSystem] Module loaded")
return NPCInteractionSystem
