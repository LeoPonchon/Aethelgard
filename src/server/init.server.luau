--!nonstrict
-- Server initialization script for Aethelgard
-- Minimal version: spawn as Commoner, dialogue with villagers, emotes, display above head

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

local DataHelpers = require(sharedFolder:WaitForChild("DataHelpers"))
local EmoteSystem = require(sharedFolder:WaitForChild("EmoteSystem"))
local PlayerDisplaySystem = require(script:WaitForChild("PlayerDisplaySystem"))
local PlayerDataSystem = require(script:WaitForChild("PlayerDataSystem"))
local NPCInteractionSystem = require(script:WaitForChild("NPCInteractionSystem"))
local NPCProximitySystem = require(script:WaitForChild("NPCProximitySystem"))

-- Initialize systems
PlayerDisplaySystem.init()
NPCProximitySystem.init()

-- Create teams
local function createTeams()
	local teams = DataHelpers.getAllTeams()
	for teamName, teamData in pairs(teams) do
		local existingTeam = Teams:FindFirstChild(teamName)
		if not existingTeam then
			local newTeam = Instance.new("Team")
			newTeam.Name = teamName
			newTeam.TeamColor = teamData.color and BrickColor.new(teamData.color) or BrickColor.new("White")
			newTeam.AutoAssignable = false
			newTeam.Parent = Teams
		end
	end
end
createTeams()

-- Remote events
local npcInteractionRemote = ReplicatedStorage:FindFirstChild("NPCInteraction")
if not npcInteractionRemote then
	npcInteractionRemote = Instance.new("RemoteFunction")
	npcInteractionRemote.Name = "NPCInteraction"
	npcInteractionRemote.Parent = ReplicatedStorage
end

local emoteEvent = ReplicatedStorage:FindFirstChild("PlayEmote")
if not emoteEvent then
	emoteEvent = Instance.new("RemoteEvent")
	emoteEvent.Name = "PlayEmote"
	emoteEvent.Parent = ReplicatedStorage
end

local npcDialogueEvent = ReplicatedStorage:FindFirstChild("NPCDialogue")
if not npcDialogueEvent then
	npcDialogueEvent = Instance.new("RemoteEvent")
	npcDialogueEvent.Name = "NPCDialogue"
	npcDialogueEvent.Parent = ReplicatedStorage
end

local playerDataRemote = ReplicatedStorage:FindFirstChild("PlayerData")
if not playerDataRemote then
	playerDataRemote = Instance.new("RemoteFunction")
	playerDataRemote.Name = "PlayerData"
	playerDataRemote.Parent = ReplicatedStorage
end

-- NPC Interaction handler
npcInteractionRemote.OnServerInvoke = function(player, action, data)
	if action == "startConversation" then
		return NPCInteractionSystem.startConversation(player.UserId, data.npcId)
	elseif action == "getCurrentDialogue" then
		return NPCInteractionSystem.getCurrentDialogue(player.UserId, data.npcId, data.currentNode or "start")
	elseif action == "advanceDialogue" then
		return NPCInteractionSystem.advanceDialogue(player.UserId, data.npcId, data.currentNode, data.optionIndex)
	elseif action == "getNPCInfo" then
		return NPCInteractionSystem.getNPC(data.npcId)
	end
	return nil
end

-- Player Data handler
playerDataRemote.OnServerInvoke = function(player, action, data)
	if action == "getData" then
		return PlayerDataSystem.getPlayerData(player.UserId)
	elseif action == "setRace" then
		PlayerDataSystem.setRace(player.UserId, data.race)
		PlayerDisplaySystem.updatePlayer(player)
		return true
	elseif action == "setClass" then
		PlayerDataSystem.setClass(player.UserId, data.class)
		PlayerDisplaySystem.updatePlayer(player)
		return true
	elseif action == "setLevel" then
		PlayerDataSystem.setLevel(player.UserId, data.level)
		PlayerDisplaySystem.updatePlayer(player)
		return true
	end
	return nil
end

-- Emote handler
emoteEvent.OnServerEvent:Connect(function(player, emoteId)
	local canUse, reason = EmoteSystem.canUseEmote(player.UserId, emoteId, nil, nil)
	if canUse then
		local emoteData = EmoteSystem.playEmote(player.UserId, emoteId)
		if emoteData then
			emoteEvent:FireAllClients(player, emoteData)
		end
	else
		emoteEvent:FireClient(player, { error = reason })
	end
end)

-- Chat command for emotes
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local emoteId = EmoteSystem.parseChatCommand(message)
		if emoteId then
			local canUse, reason = EmoteSystem.canUseEmote(player.UserId, emoteId, nil, nil)
			if canUse then
				local emoteData = EmoteSystem.playEmote(player.UserId, emoteId)
				if emoteData then
					emoteEvent:FireAllClients(player, emoteData)
				end
			end
		end
	end)
end)

-- Player join - set as Commoner
Players.PlayerAdded:Connect(function(player)
	local defaultTeamName = DataHelpers.getDefaultTeam()
	local defaultTeam = Teams:FindFirstChild(defaultTeamName)
	if defaultTeam then
		player.Team = defaultTeam
	end
	
	local playerData = PlayerDataSystem.getPlayerData(player.UserId)
	print(string.format("[Server] %s joined as %s (Level %d, %s, %s)", player.Name, defaultTeamName, playerData.level, playerData.race, playerData.class))
end)

print("[Server] Aethelgard server initialized - minimal version")
