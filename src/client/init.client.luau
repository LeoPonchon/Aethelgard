--!nonstrict
-- Client initialization script for Aethelgard
-- Minimal client - handles emote animations and action recording
-- NO UI - all progression happens through in-game actions

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Get remotes (with timeout and retry)
local function waitForRemote(remoteName: string, timeout: number): Instance?
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then return remote end
	
	-- Wait with timeout
	local startTime = tick()
	while tick() - startTime < timeout do
		remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote then return remote end
		task.wait(0.1)
	end
	
	warn("[Client] Timeout waiting for remote:", remoteName)
	return nil
end

local actionEvent = waitForRemote("PlayerAction", 10)
local emoteEvent = waitForRemote("PlayEmote", 10)
local npcInteractionRemote = waitForRemote("NPCInteraction", 10)
local getPlayerInfoRemote = waitForRemote("GetPlayerInfo", 10)
local npcDialogueEvent = waitForRemote("NPCDialogue", 10)

-- Import NPC Dialogue Client module
local NPCDialogueClient = script:FindFirstChild("NPCDialogueClient")
if NPCDialogueClient then
	NPCDialogueClient = require(NPCDialogueClient)
else
	-- Try to find it in parent
	local parent = script.Parent
	if parent then
		NPCDialogueClient = parent:FindFirstChild("NPCDialogueClient")
		if NPCDialogueClient then
			NPCDialogueClient = require(NPCDialogueClient)
		end
	end
end

-- ============================================
-- EMOTE ANIMATION HANDLING
-- ============================================

local currentAnimationTrack = nil
local currentEmoteId = nil

-- Play emote animation
local function playEmoteAnimation(emoteData)
    if not emoteData or not emoteData.animationId then
        return
    end
    
    -- Stop current animation
    if currentAnimationTrack then
        currentAnimationTrack:Stop()
        currentAnimationTrack = nil
    end
    
    -- Load and play new animation
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = emoteData.animationId
    
    currentAnimationTrack = animator:LoadAnimation(animation)
    currentAnimationTrack:Play()
    
    -- Set up end callback for non-looped animations
    if not emoteData.looped then
        currentAnimationTrack.Stopped:Once(function()
            currentAnimationTrack = nil
            currentEmoteId = nil
        end)
    end
    
    currentEmoteId = emoteData.emote and emoteData.emote.id
end

-- Stop current emote
local function stopCurrentEmote()
    if currentAnimationTrack then
        currentAnimationTrack:Stop()
        currentAnimationTrack = nil
        currentEmoteId = nil
    end
end

-- Listen for emote events from server
emoteEvent.OnClientEvent:Connect(function(sourcePlayer, emoteData)
    if sourcePlayer == player then
        -- This is our emote
        if emoteData.error then
            -- Show error feedback (could be a small toast)
            print("[Emote] Error:", emoteData.error)
        else
            playEmoteAnimation(emoteData)
        end
    else
        -- Another player's emote - play it on their character
        if emoteData and sourcePlayer.Character then
            local otherHumanoid = sourcePlayer.Character:FindFirstChild("Humanoid")
            if otherHumanoid then
                local animator = otherHumanoid:FindFirstChild("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = otherHumanoid
                end
                
                local animation = Instance.new("Animation")
                animation.AnimationId = emoteData.animationId
                
                local track = animator:LoadAnimation(animation)
                track:Play()
            end
        end
    end
end)

-- ============================================
-- ACTION RECORDING
-- ============================================

-- Track player actions and send to server
local actionTracking = {
    lastMeleeAttack = 0,
    lastSpellCast = 0,
    lastLocation = nil,
}

-- Record action to server
local function recordAction(actionType: string, target: string?, value: number?, metadata: any?)
    actionEvent:FireServer(actionType, {
        target = target,
        value = value,
        metadata = metadata,
    })
end

-- Track location changes for exploration
local function checkLocationChange()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- This would be expanded to check against named locations in the game world
    -- For now, we just track movement for future location-based triggers
end

-- Track combat actions
humanoid.StateChanged:Connect(function(oldState, newState)
    -- Could track combat states here
end)

-- Track tool usage (for combat/crafting)
local function setupToolTracking()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                child.Activated:Connect(function()
                    -- Record tool usage
                    local toolName = child.Name
                    if toolName:lower():find("sword") or toolName:lower():find("blade") then
                        recordAction("MeleeAttack", nil, 1, {weapon = toolName})
                    elseif toolName:lower():find("staff") or toolName:lower():find("wand") then
                        recordAction("CastSpell", nil, 1, {weapon = toolName})
                    elseif toolName:lower():find("bow") or toolName:lower():find("crossbow") then
                        recordAction("DefeatEnemy", nil, 1, {weapon = "bow"})
                    end
                end)
            end
        end)
    end
    
    -- Also track tools equipped in character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                child.Activated:Connect(function()
                    local toolName = child.Name
                    if toolName:lower():find("sword") or toolName:lower():find("blade") then
                        recordAction("MeleeAttack", nil, 1, {weapon = toolName})
                    end
                end)
            end
        end
        
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                child.Activated:Connect(function()
                    local toolName = child.Name
                    if toolName:lower():find("sword") or toolName:lower():find("blade") then
                        recordAction("MeleeAttack", nil, 1, {weapon = toolName})
                    elseif toolName:lower():find("staff") or toolName:lower():find("wand") then
                        recordAction("CastSpell", nil, 1, {weapon = toolName})
                    end
                end)
            end
        end)
    end
end

-- ============================================
-- NPC INTERACTION (Proximity-based)
-- ============================================

-- Handle NPC conversation from server (triggered by ProximityPrompt)
-- Dialogue system disabled - no dialogue shown on interaction
-- TODO: Reimplement dialogue system
if npcInteractionRemote then
	npcInteractionRemote.OnClientInvoke = function(action: string, data: any)
		-- Dialogue disabled
		return nil
	end
end

-- Check for nearby NPCs and show interaction prompt
local function checkNearbyNPCs()
	-- This would be implemented with actual NPC models in the game world
	-- For now, this is a placeholder for proximity detection
end

-- ============================================
-- KEYBIND HANDLING
-- ============================================

-- Handle keybinds for emotes and actions
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- ESC to stop current emote
    if input.KeyCode == Enum.KeyCode.Escape then
        stopCurrentEmote()
    end
    
    -- Number keys for quick emotes (1-5)
    local keyCode = input.KeyCode
    if keyCode == Enum.KeyCode.One or keyCode == Enum.KeyCode.Two or keyCode == Enum.KeyCode.Three or keyCode == Enum.KeyCode.Four or keyCode == Enum.KeyCode.Five then
    	local emotes = {"wave", "bow", "dance", "cheer", "clap"}
    	local indexMap = {
    		[Enum.KeyCode.One] = 1,
    		[Enum.KeyCode.Two] = 2,
    		[Enum.KeyCode.Three] = 3,
    		[Enum.KeyCode.Four] = 4,
    		[Enum.KeyCode.Five] = 5,
    	}
    	local index = indexMap[keyCode]
    	if index and emotes[index] then
    		emoteEvent:FireServer(emotes[index])
    	end
    end
end)

-- ============================================
-- ACTION FEEDBACK HANDLING
-- ============================================

-- Listen for action feedback from server
actionEvent.OnClientEvent:Connect(function(data)
    if data.events then
        for _, event in ipairs(data.events) do
            -- Show progression feedback
            print("[Progression]", event)
            
            -- Could show a small toast notification here
            -- For now, just print to console
        end
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    currentAnimationTrack = nil
    currentEmoteId = nil
    
    -- Re-setup tool tracking
    setupToolTracking()
end)

-- Initial setup
setupToolTracking()

print("[Client] Aethelgard client initialized - action-based progression active")

-- ============================================
-- NPC DIALOGUE HANDLING
-- ============================================

if npcDialogueEvent then
	npcDialogueEvent.OnClientEvent:Connect(function(data)
		if data.npcId and NPCDialogueClient then
			NPCDialogueClient.startConversation(data.npcId)
		end
	end)
end
