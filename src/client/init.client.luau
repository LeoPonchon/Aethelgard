--!nonstrict
-- Client initialization script for Aethelgard
-- Minimal version: emote animations and NPC dialogue

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function waitForRemote(remoteName, timeout)
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then return remote end

	local startTime = tick()
	while tick() - startTime < timeout do
		remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote then return remote end
		task.wait(0.1)
	end

	warn("[Client] Timeout waiting for remote:", remoteName)
	return nil
end

local emoteEvent = waitForRemote("PlayEmote", 10)
local npcInteractionRemote = waitForRemote("NPCInteraction", 10)

local NPCDialogueClient = script:FindFirstChild("NPCDialogueClient")
if NPCDialogueClient then
	NPCDialogueClient = require(NPCDialogueClient)
else
	local parent = script.Parent
	if parent then
		NPCDialogueClient = parent:FindFirstChild("NPCDialogueClient")
		if NPCDialogueClient then
			NPCDialogueClient = require(NPCDialogueClient)
		end
	end
end

-- Emote Animation Handling
local currentAnimationTrack = nil
local currentEmoteId = nil

local function playEmoteAnimation(emoteData)
	if not emoteData or not emoteData.animationId then return end

	if currentAnimationTrack then
		currentAnimationTrack:Stop()
		currentAnimationTrack = nil
	end

	local animator = humanoid:FindFirstChild("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = emoteData.animationId

	currentAnimationTrack = animator:LoadAnimation(animation)
	currentAnimationTrack:Play()

	if not emoteData.looped then
		currentAnimationTrack.Stopped:Once(function()
			currentAnimationTrack = nil
			currentEmoteId = nil
		end)
	end

	currentEmoteId = emoteData.emote and emoteData.emote.id
end

local function stopCurrentEmote()
	if currentAnimationTrack then
		currentAnimationTrack:Stop()
		currentAnimationTrack = nil
		currentEmoteId = nil
	end
end

-- Listen for emote events
emoteEvent.OnClientEvent:Connect(function(sourcePlayer, emoteData)
	if sourcePlayer == player then
		if emoteData.error then
			print("[Emote] Error:", emoteData.error)
		else
			playEmoteAnimation(emoteData)
		end
	else
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

-- Keybind handling for emotes
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Escape then
		stopCurrentEmote()
	end

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

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	currentAnimationTrack = nil
	currentEmoteId = nil
end)

print("[Client] Aethelgard client initialized - minimal version")

-- NPC Dialogue handling
local npcDialogueEvent = waitForRemote("NPCDialogue", 10)
if npcDialogueEvent then
	npcDialogueEvent.OnClientEvent:Connect(function(data)
		if data.npcId and NPCDialogueClient then
			NPCDialogueClient.startConversation(data.npcId)
		end
	end)
end
