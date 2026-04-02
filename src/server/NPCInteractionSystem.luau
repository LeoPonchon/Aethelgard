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

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = "start",
		playerData = playerData,
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
		class = progression.activeClass or nil,
		race = characterData and characterData.race or nil,
	}

	local text = DialogueData.getDialogueText(npcId, currentNode, playerData)
	local nextLine = DialogueData.getNextLine(npcId, currentNode, playerData)

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = currentNode,
		text = text,
		nextLine = nextLine,
		hasChoices = nextLine ~= nil,
	}
end

function NPCInteractionSystem.advanceDialogue(playerId: number, npcId: string, currentNode: string): any
	local npc = NPC_DEFINITIONS[npcId]
	if not npc then
		return nil
	end

	local progression = ActionBasedProgressionSystem.getProgression(playerId)
	local characterData = CharacterCreationSystem.getCharacterData(playerId)
	
	local playerData = {
		team = progression.primaryFaction or "Commoners",
		class = progression.activeClass or nil,
		race = characterData and characterData.race or nil,
	}

	local nextLine = DialogueData.getNextLine(npcId, currentNode, playerData)

	if not nextLine then
		return {
			npcId = npcId,
			npcName = npc.name,
			faction = npc.faction,
			currentNode = currentNode,
			text = nil,
			nextLine = nil,
			hasChoices = false,
			endConversation = true,
		}
	end

	local text = DialogueData.getDialogueText(npcId, nextLine, playerData)
	local nextNextLine = DialogueData.getNextLine(npcId, nextLine, playerData)

	return {
		npcId = npcId,
		npcName = npc.name,
		faction = npc.faction,
		currentNode = nextLine,
		text = text,
		nextLine = nextNextLine,
		hasChoices = nextNextLine ~= nil,
		endConversation = nextNextLine == nil,
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