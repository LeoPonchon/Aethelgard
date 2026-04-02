--!nonstrict
-- NPC Interaction System for Aethelgard
-- Simplified to use DialogueData as the single source of truth

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionBasedProgressionSystem = require(ReplicatedStorage.Shared:WaitForChild("ActionBasedProgressionSystem"))
local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))
local RaceData = require(ReplicatedStorage.Shared:WaitForChild("RaceData"))
local ClassData = require(ReplicatedStorage.Shared:WaitForChild("ClassData"))
local DialogueData = require(ReplicatedStorage.Shared:WaitForChild("DialogueData"))
local CharacterCreationSystem = require(ReplicatedStorage.Shared:WaitForChild("CharacterCreationSystem"))

export type NPCType = 
	"VillageElder" | 
	"GuildMaster" | 
	"AcademyHeadmaster" |
	"Trainer" |
	"Merchant" |
	"QuestGiver"

export type NPCDefinition = {
	id: string,
	name: string,
	title: string,
	npcType: NPCType,
	description: string,
	location: string,
	faction: string?,
	quests: {string}?,
	services: {string}?,
}

local NPC_DEFINITIONS: {[string]: NPCDefinition} = {
	["Village_Elder"] = {
		id = "Village_Elder",
		name = "Village Elder",
		title = "Guide of the Beginning",
		npcType = "VillageElder",
		description = "The wise elder of the village who welcomes newcomers.",
		location = "Village_Square",
		faction = nil,
		quests = {"explore_forest_1", "defeat_wolves_1"},
		services = {"guidance", "quest_giving"},
	},
	
	["Guild_Master"] = {
		id = "Guild_Master",
		name = "Guild Master",
		title = "Adventurers Leader",
		npcType = "GuildMaster",
		description = "The leader of the adventurers guild who distributes quests.",
		location = "Guild_Hall",
		faction = "Commoners",
		quests = {"escort_merchant_1", "explore_forest_1", "defeat_wolves_1", "socialize_guild_1"},
		services = {"quest_giving", "progress_check"},
	},
	
	["Academy_Headmaster"] = {
		id = "Academy_Headmaster",
		name = "Academy Headmaster",
		title = "Archmage",
		npcType = "AcademyHeadmaster",
		description = "The director of the Magic Academy who welcomes new students.",
		location = "Academy_Entrance",
		faction = "Academy",
		quests = {"train_magic_1", "train_combat_1"},
		services = {"enrollment", "training_info"},
	},
	
	["Combat_Instructor"] = {
		id = "Combat_Instructor",
		name = "Combat Instructor",
		title = "Weapon Master",
		npcType = "Trainer",
		description = "The Academy's weapons master who trains warriors.",
		location = "Training_Arena",
		faction = "Academy",
		quests = {"train_combat_1"},
		services = {"combat_training"},
	},
	
	["Magic_Instructor"] = {
		id = "Magic_Instructor",
		name = "Magic Instructor",
		title = "Senior Mage",
		npcType = "Trainer",
		description = "The senior mage who trains spellcasters.",
		location = "Mage_Tower",
		faction = "Academy",
		quests = {"train_magic_1"},
		services = {"magic_training"},
	},
}

local NPCInteractionSystem = {}

function NPCInteractionSystem.getNPC(npcId: string): NPCDefinition?
	return NPC_DEFINITIONS[npcId]
end

function NPCInteractionSystem.getAllNPCs(): {[string]: NPCDefinition}
	return NPC_DEFINITIONS
end

function NPCInteractionSystem.getNPCsAtLocation(location: string): {NPCDefinition}
	local npcs = {}
	for _, npc in pairs(NPC_DEFINITIONS) do
		if npc.location == location then
			table.insert(npcs, npc)
		end
	end
	return npcs
end

function NPCInteractionSystem.hasDialogue(npcId: string): boolean
	return DialogueData.hasDialogue(npcId)
end

function NPCInteractionSystem.startConversation(playerId: number, npcId: string): any
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then
		return nil
	end

	if not DialogueData.hasDialogue(npcId) then
		warn("[NPCInteractionSystem] No dialogue found for NPC:", npcId)
		return nil
	end

	local progression = ActionBasedProgressionSystem.getProgression(playerId)
	local characterData = CharacterCreationSystem.getCharacterData(playerId)
	
	local playerData = {
		team = progression.primaryFaction or "Commoners",
		class = progression.activeClass or nil,
		race = characterData and characterData.race or nil,
	}

	ActionBasedProgressionSystem.recordAction(playerId, {
		actionType = "TalkToNPC",
		target = npcId,
		value = 5,
	})

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
		playerData = playerData,
		npcPosition = npcPosition,
	}
end

function NPCInteractionSystem.getCurrentDialogue(playerId: number, npcId: string, currentNode: string): any
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then
		return nil
	end

	local progression = ActionBasedProgressionSystem.getProgression(playerId)
	local characterData = CharacterCreationSystem.getCharacterData(playerId)
	
	local playerData = {
		team = progression.primaryFaction or "Commoners",
		class = progression.activeClass or "Classless",
		race = characterData and characterData.race or "Human",
	}

	local rule = DialogueData.getDialogueForPlayer(npcId, currentNode, playerData)

	if not rule then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = currentNode,
			text = "Le NPC n'a rien à dire pour cette combinaison.",
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

function NPCInteractionSystem.advanceDialogue(playerId: number, npcId: string, currentNode: string, optionIndex: number?): any
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then
		return nil
	end

	local progression = ActionBasedProgressionSystem.getProgression(playerId)
	local characterData = CharacterCreationSystem.getCharacterData(playerId)
	
	local playerData = {
		team = progression.primaryFaction or "Commoners",
		class = progression.activeClass or "Classless",
		race = characterData and characterData.race or "Human",
	}

	local currentRule = DialogueData.getDialogueForPlayer(npcId, currentNode, playerData)
	
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
	local nextRule = DialogueData.getDialogueForPlayer(npcId, nextNode, playerData)
	
	if not nextRule then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = nextNode,
			text = "Le NPC n'a rien à dire pour cette combinaison.",
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

function NPCInteractionSystem.acceptQuest(playerId: number, npcId: string, questId: string): boolean
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then
		return false
	end

	local hasQuest = false
	if npc.quests then
		for _, id in ipairs(npc.quests) do
			if id == questId then
				hasQuest = true
				break
			end
		end
	end

	if not hasQuest then
		return false
	end

	return QuestSystem.acceptQuest(playerId, questId)
end

function NPCInteractionSystem.getNPCQuestsForPlayer(playerId: number, npcId: string): {any}
	local npc = NPC_DEFINITIONS[npcId]
	if not npc or not npc.quests then
		return {}
	end

	local availableQuests = {}
	for _, questId in ipairs(npc.quests) do
		local questDef = QuestSystem.getQuestDefinition(questId)
		if questDef then
			local isOnQuest = QuestSystem.isOnQuest(playerId, questId)
			table.insert(availableQuests, {
				questId = questId,
				name = questDef.name,
				description = questDef.description,
				difficulty = questDef.difficulty,
				isOnQuest = isOnQuest,
			})
		end
	end

	return availableQuests
end

return NPCInteractionSystem