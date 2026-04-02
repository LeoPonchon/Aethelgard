--!nonstrict
-- Server initialization script for Aethelgard
-- Handles action-based progression, quests, NPC interactions, and emotes
-- NO UI - progression happens through in-game actions only

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

-- Find the server scripts folder (could be in different locations)
local serverFolder = script.Parent
if serverFolder == nil then
	-- Script is directly in ServerScriptService
	serverFolder = ServerScriptService
end

-- Wait for Shared folder to be available
local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

-- Helper function to require a module (with fallback)
local function requireModule(moduleName: string): any
	-- Rojo puts modules as children of the script itself
	local module = script:FindFirstChild(moduleName)
	if module then
		return require(module)
	end
	-- Try in ServerScriptService directly (in case not using Rojo)
	module = ServerScriptService:FindFirstChild(moduleName)
	if module then
		return require(module)
	end
	-- Try in ReplicatedStorage.Shared
	module = sharedFolder:FindFirstChild(moduleName)
	if module then
		return require(module)
	end
	-- Create placeholder if not found
	warn("[Server] Module not found: " .. moduleName)
	return nil
end

-- Import new systems
local ActionBasedProgressionSystem = requireModule("ActionBasedProgressionSystem")
local QuestSystem = requireModule("QuestSystem")
local NPCInteractionSystem = requireModule("NPCInteractionSystem")
local EmoteSystem = requireModule("EmoteSystem")
local PlayerDisplaySystem = requireModule("PlayerDisplaySystem")
local ProximityPromptSystem = requireModule("ProximityPromptSystem")
local CharacterCreationSystem = requireModule("CharacterCreationSystem")

-- Initialize systems (check if they exist first)
if PlayerDisplaySystem then
	PlayerDisplaySystem.init()
else
	warn("[Server] PlayerDisplaySystem not found, skipping initialization")
end

if ProximityPromptSystem then
	ProximityPromptSystem.init()
else
	warn("[Server] ProximityPromptSystem not found, skipping initialization")
end

-- ============================================
-- DYNAMIC TEAM CREATION
-- ============================================

-- Function to create teams dynamically from TEAM_DATA
local function createTeamsFromData()
	if not ActionBasedProgressionSystem then
		warn("[Server] ActionBasedProgressionSystem not found, cannot create teams")
		return
	end
	
	local teamData = ActionBasedProgressionSystem.getTeamData()
	if not teamData then
		warn("[Server] Team data not found")
		return
	end
	
	local teamsCreated = 0
	local teamsUpdated = 0
	
	for teamId, data in pairs(teamData) do
		-- Check if team already exists
		local existingTeam = Teams:FindFirstChild(teamId)
		
		-- Convert Color3 to BrickColor if needed
		local teamColor = BrickColor.new("White")
		if data.color then
			-- Color3 to BrickColor conversion
			local c = data.color
			teamColor = BrickColor.new(Color3.new(c.R, c.G, c.B))
		end
		
		if not existingTeam then
			-- Create new team
			local newTeam = Instance.new("Team")
			newTeam.Name = teamId
			newTeam.TeamColor = teamColor
			newTeam.AutoAssignable = false
			
			-- Set description if available
			if data.description then
				local description = Instance.new("StringValue")
				description.Name = "Description"
				description.Value = data.description
				description.Parent = newTeam
			end
			
			-- Set category if available
			if data.category then
				local category = Instance.new("StringValue")
				category.Name = "Category"
				category.Value = data.category
				category.Parent = newTeam
			end
			
			newTeam.Parent = Teams
			teamsCreated = teamsCreated + 1
		else
			-- Update existing team color if needed
			if data.color then
				existingTeam.TeamColor = teamColor
				teamsUpdated = teamsUpdated + 1
			end
		end
	end
	
	print("[Server] Teams created:", teamsCreated, "updated:", teamsUpdated)
end

-- Create teams on server start
createTeamsFromData()

-- ============================================
-- REMOTE EVENTS/FUNCTIONS
-- ============================================

-- Create RemoteFunction for NPC interactions
local npcInteractionRemote = ReplicatedStorage:FindFirstChild("NPCInteraction")
if not npcInteractionRemote then
    npcInteractionRemote = Instance.new("RemoteFunction")
    npcInteractionRemote.Name = "NPCInteraction"
    npcInteractionRemote.Parent = ReplicatedStorage
end

-- Create RemoteEvent for actions
local actionEvent = ReplicatedStorage:FindFirstChild("PlayerAction")
if not actionEvent then
    actionEvent = Instance.new("RemoteEvent")
    actionEvent.Name = "PlayerAction"
    actionEvent.Parent = ReplicatedStorage
end

-- Create RemoteEvent for emotes
local emoteEvent = ReplicatedStorage:FindFirstChild("PlayEmote")
if not emoteEvent then
    emoteEvent = Instance.new("RemoteEvent")
    emoteEvent.Name = "PlayEmote"
    emoteEvent.Parent = ReplicatedStorage
end

-- Create RemoteEvent for chat commands
local chatEvent = ReplicatedStorage:FindFirstChild("ChatCommand")
if not chatEvent then
    chatEvent = Instance.new("RemoteEvent")
    chatEvent.Name = "ChatCommand"
    chatEvent.Parent = ReplicatedStorage
end

-- Create RemoteFunction for getting player info
local getPlayerInfoRemote = ReplicatedStorage:FindFirstChild("GetPlayerInfo")
if not getPlayerInfoRemote then
    getPlayerInfoRemote = Instance.new("RemoteFunction")
    getPlayerInfoRemote.Name = "GetPlayerInfo"
    getPlayerInfoRemote.Parent = ReplicatedStorage
end

-- ============================================
-- NPC INTERACTION HANDLING
-- ============================================

npcInteractionRemote.OnServerInvoke = function(player: Player, action: string, data: any)
    if action == "startConversation" then
        local npcId = data.npcId
        if not npcId then return nil end
        
        local result = NPCInteractionSystem.startConversation(player.UserId, npcId)
        return result
        
    elseif action == "getCurrentDialogue" then
        local npcId = data.npcId
        local currentNode = data.currentNode or "start"
        if not npcId then return nil end
        
        local result = NPCInteractionSystem.getCurrentDialogue(player.UserId, npcId, currentNode)
        return result
        
    elseif action == "advanceDialogue" then
        local npcId = data.npcId
        local currentNode = data.currentNode
        local optionIndex = data.optionIndex
        if not npcId or not currentNode then return nil end
        
        local result = NPCInteractionSystem.advanceDialogue(player.UserId, npcId, currentNode, optionIndex)
        return result
        
    elseif action == "getNPCInfo" then
        local npcId = data.npcId
        if not npcId then return nil end
        
        return NPCInteractionSystem.getNPC(npcId)
    end
    
    return nil
end

-- ============================================
-- ACTION HANDLING
-- ============================================

actionEvent.OnServerEvent:Connect(function(player: Player, actionType: string, data: any)
    -- Record action for progression
    local events = ActionBasedProgressionSystem.recordAction(player.UserId, {
        actionType = actionType,
        target = data.target,
        value = data.value,
        metadata = data.metadata,
    })
    
    -- Update quest objectives if applicable
    if data.target then
        QuestSystem.updateObjective(player.UserId, actionType, data.target, data.value or 1)
    end
    
    -- Update player display
    PlayerDisplaySystem.onProgressionChanged(player)
    
    -- Send events back to client for feedback
    if #events > 0 then
        actionEvent:FireClient(player, {
            events = events,
            progression = ActionBasedProgressionSystem.getDisplayInfo(player.UserId),
        })
    end
end)

-- ============================================
-- EMOTE HANDLING
-- ============================================

emoteEvent.OnServerEvent:Connect(function(player: Player, emoteId: string)
    -- Get player's class and faction for emote requirements
    local progression = ActionBasedProgressionSystem.getProgression(player.UserId)
    local playerClass = progression.activeClass
    local playerFaction = progression.primaryFaction
    
    -- Check if player can use emote
    local canUse, reason = EmoteSystem.canUseEmote(player.UserId, emoteId, playerClass, playerFaction)
    
    if canUse then
        local emoteData = EmoteSystem.playEmote(player.UserId, emoteId)
        if emoteData then
            -- Broadcast to all players nearby
            emoteEvent:FireAllClients(player, emoteData)
        end
    else
        -- Send error to player
        emoteEvent:FireClient(player, { error = reason })
    end
end)

-- ============================================
-- CHAT COMMAND HANDLING
-- ============================================

-- Listen to player chat for emote commands
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        -- Check if message is an emote command
        local emoteId = EmoteSystem.parseChatCommand(message)
        if emoteId then
            -- Get player's class and faction
            local progression = ActionBasedProgressionSystem.getProgression(player.UserId)
            local playerClass = progression.activeClass
            local playerFaction = progression.primaryFaction
            
            -- Check if player can use emote
            local canUse, reason = EmoteSystem.canUseEmote(player.UserId, emoteId, playerClass, playerFaction)
            
            if canUse then
                local emoteData = EmoteSystem.playEmote(player.UserId, emoteId)
                if emoteData then
                    emoteEvent:FireAllClients(player, emoteData)
                end
            end
        end
    end)
end)

-- ============================================
-- PLAYER INFO HANDLING
-- ============================================

getPlayerInfoRemote.OnServerInvoke = function(player: Player, infoType: string, data: any)
    if infoType == "progression" then
        return ActionBasedProgressionSystem.getProgression(player.UserId)
        
    elseif infoType == "displayInfo" then
        return ActionBasedProgressionSystem.getDisplayInfo(player.UserId)
        
    elseif infoType == "quests" then
        return QuestSystem.getPlayerQuests(player.UserId)
        
    elseif infoType == "questProgress" then
        local questId = data.questId
        return QuestSystem.getQuestProgress(player.UserId, questId)
        
    elseif infoType == "availableQuests" then
        local faction = data.faction
        return QuestSystem.getAvailableQuests(player.UserId, faction)
        
    elseif infoType == "availableEmotes" then
        local progression = ActionBasedProgressionSystem.getProgression(player.UserId)
        return EmoteSystem.getAvailableEmotes(progression.activeClass, progression.primaryFaction)
        
    elseif infoType == "npcList" then
        return NPCInteractionSystem.getAllNPCs()
    end
    
    return nil
end

-- ============================================
-- PLAYER JOIN/HANDLING
-- ============================================

-- Handle new players joining
Players.PlayerAdded:Connect(function(player: Player)
    -- Initialize progression for new player
    local progression = ActionBasedProgressionSystem.getProgression(player.UserId)

    -- Set default class to Classless
    progression.activeClass = "Classless"
    
    -- Join default team (Commoners)
    local success = ActionBasedProgressionSystem.joinTeam(player.UserId, "Commoners")
    
    -- Also set the player's actual team
    local commonersTeam = Teams:FindFirstChild("Commoners")
    if commonersTeam then
        player.Team = commonersTeam
    end
    
    -- Initialize character data with default race
    local characterData = CharacterCreationSystem.getCharacterData(player.UserId)
    if not characterData then
        CharacterCreationSystem.createCharacter(player.UserId, {
            playerId = player.UserId,
            race = "Human",
            appearance = nil,
            traits = {},
        })
    end

    print(string.format("[Server] %s joined the game (team: Commoners, class: Classless, race: Human)", player.Name))
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player: Player)
    print(string.format("[Server] %s left the game", player.Name))
end)

-- ============================================
-- DAY/NIGHT CYCLE SYSTEM
-- ============================================

local sky = Lighting:FindFirstChild("Sky")

-- Configuration
local CYCLE_DURATION = 60 -- seconds for a full 24h cycle
local ROTATION_SPEED = 5 -- degrees per second

-- Time settings: [clockTime] = { lighting properties }
local TIME_SETTINGS = {
    [0] = { -- Midnight
        Ambient = Color3.fromRGB(169, 49, 255),
        Brightness = 0,
        ColorShift_Bottom = Color3.new(),
        ColorShift_Top = Color3.fromRGB(100, 50, 150),
        OutdoorAmbient = Color3.fromRGB(0, 0, 50),
    },
    [6] = { -- Dawn
        Ambient = Color3.fromRGB(255, 200, 150),
        Brightness = 1,
        ColorShift_Bottom = Color3.fromRGB(255, 150, 100),
        ColorShift_Top = Color3.fromRGB(255, 200, 150),
        OutdoorAmbient = Color3.fromRGB(255, 180, 100),
    },
    [12] = { -- Noon
        Ambient = Color3.fromRGB(240, 167, 93),
        Brightness = 3,
        ColorShift_Bottom = Color3.new(),
        ColorShift_Top = Color3.fromRGB(213, 199, 0),
        OutdoorAmbient = Color3.fromRGB(251, 255, 0),
    },
    [18] = { -- Dusk
        Ambient = Color3.fromRGB(255, 130, 100),
        Brightness = 1,
        ColorShift_Bottom = Color3.fromRGB(180, 50, 50),
        ColorShift_Top = Color3.fromRGB(255, 150, 100),
        OutdoorAmbient = Color3.fromRGB(255, 100, 50),
    },
}

local function lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

local function lerpColor3(a: Color3, b: Color3, t: number): Color3
    return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function getSettings(clockTime: number)
    local times = table.create(4)
    for k in pairs(TIME_SETTINGS) do table.insert(times, k) end
    table.sort(times)

    local current, nextIdx = times[1], 1
    for i = 1, #times do
        if times[i] <= clockTime then
            current = times[i]
            nextIdx = i < #times and i + 1 or 1
        end
    end

    local next = times[nextIdx]
    local currentSettings = TIME_SETTINGS[current]
    local nextSettings = TIME_SETTINGS[next]

    local t = (clockTime - current) / (next - current)
    if t < 0 then t = t + 1 end

    return {
        Ambient = lerpColor3(currentSettings.Ambient, nextSettings.Ambient, t),
        Brightness = lerp(currentSettings.Brightness, nextSettings.Brightness, t),
        ColorShift_Bottom = lerpColor3(currentSettings.ColorShift_Bottom, nextSettings.ColorShift_Bottom, t),
        ColorShift_Top = lerpColor3(currentSettings.ColorShift_Top, nextSettings.ColorShift_Top, t),
        OutdoorAmbient = lerpColor3(currentSettings.OutdoorAmbient, nextSettings.OutdoorAmbient, t),
    }
end

-- Day/night cycle heartbeat
RunService.Heartbeat:Connect(function(deltaTime)
    local cycleProgress = (workspace:GetServerTimeNow() % CYCLE_DURATION) / CYCLE_DURATION
    local clockTime = (cycleProgress * 24) % 24
    Lighting.ClockTime = clockTime

    if sky then
        sky.SkyboxOrientation = Vector3.new(0, (sky.SkyboxOrientation.Y + ROTATION_SPEED * deltaTime) % 360, 0)
    end

    local settings = getSettings(clockTime)
    Lighting.Ambient = settings.Ambient
    Lighting.Brightness = settings.Brightness
    Lighting.ColorShift_Bottom = settings.ColorShift_Bottom
    Lighting.ColorShift_Top = settings.ColorShift_Top
    Lighting.OutdoorAmbient = settings.OutdoorAmbient
end)

Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

print("[Server] Aethelgard server initialized with action-based progression system")
