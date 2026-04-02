--!nonstrict
-- Data helpers for Aethelgard
-- Functions to query data from RaceData, ClassData, TeamData, DialogueData

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")

local RACE_DATA = require(sharedFolder:WaitForChild("RaceData"))
local CLASS_DATA = require(sharedFolder:WaitForChild("ClassData"))
local TEAM_DATA = require(sharedFolder:WaitForChild("TeamData"))
local DIALOGUE_DATA = require(sharedFolder:WaitForChild("DialogueData"))

local DataHelpers = {}

-- Race functions
function DataHelpers.getRaceById(raceId)
	for _, category in ipairs(RACE_DATA) do
		for _, race in ipairs(category.races) do
			if race.id == raceId or race.name == raceId then
				return race
			end
		end
	end
	return nil
end

function DataHelpers.getPlayableRaces()
	local playable = {}
	for _, category in ipairs(RACE_DATA) do
		for _, race in ipairs(category.races) do
			if race.playable then
				table.insert(playable, race)
			end
		end
	end
	return playable
end

-- Class functions
function DataHelpers.getClassById(classId)
	for _, category in ipairs(CLASS_DATA) do
		for _, class in ipairs(category.classes) do
			if class.id == classId or class.name == classId then
				return class
			end
		end
	end
	return nil
end

function DataHelpers.getAllClasses()
	local classes = {}
	for _, category in ipairs(CLASS_DATA) do
		for _, class in ipairs(category.classes) do
			table.insert(classes, class)
		end
	end
	return classes
end

-- Team functions
function DataHelpers.getTeamByName(teamName)
	for _, category in ipairs(TEAM_DATA) do
		for _, team in ipairs(category.teams) do
			if team.name == teamName then
				return team
			end
		end
	end
	return nil
end

function DataHelpers.getDefaultTeam()
	for _, category in ipairs(TEAM_DATA) do
		for _, team in ipairs(category.teams) do
			if team.default then
				return team.name
			end
		end
	end
	return "Commoners"
end

function DataHelpers.getAllTeams()
	local teams = {}
	for _, category in ipairs(TEAM_DATA) do
		for _, team in ipairs(category.teams) do
			teams[team.name] = team
		end
	end
	return teams
end

-- Dialogue functions
function DataHelpers.getDialogueNode(npcId, nodeName)
	local npcDialogue = DIALOGUE_DATA[npcId]
	if not npcDialogue then return nil end
	return npcDialogue[nodeName]
end

function DataHelpers.getDialogueForPlayer(npcId, nodeName, playerData)
	local node = DataHelpers.getDialogueNode(npcId, nodeName)
	if not node then return nil end

	local playerTeam = playerData.team or "Commoners"
	local playerClass = playerData.class or "Classless"
	local playerRace = playerData.race or "Human"

	for _, rule in ipairs(node.rules) do
		local teamMatch = not rule.team or rule.team == playerTeam
		local classMatch = not rule.class or rule.class == playerClass
		local raceMatch = not rule.race or rule.race == playerRace

		if teamMatch and classMatch and raceMatch then
			return rule
		end
	end

	return nil
end

function DataHelpers.hasDialogue(npcId)
	return DIALOGUE_DATA[npcId] ~= nil
end

function DataHelpers.getNpcName(npcId)
	local npcDialogue = DIALOGUE_DATA[npcId]
	if npcDialogue then
		return npcDialogue.npcName
	end
	return nil
end

print("[DataHelpers] Module loaded")
return DataHelpers
