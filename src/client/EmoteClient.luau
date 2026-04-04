--!nonstrict
-- Emote Client System for Aethelgard
-- Handles emote animations and keybinds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local EmoteClient = {}

local currentAnimationTrack = nil
local currentEmoteId = nil
local emoteEvent = nil
local humanoid = nil
local character = nil

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

local function playOtherPlayerEmote(sourcePlayer, emoteData)
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

local function setupKeybinds()
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
			if index and emotes[index] and emoteEvent then
				emoteEvent:FireServer(emotes[index])
			end
		end
	end)
end

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	currentAnimationTrack = nil
	currentEmoteId = nil
end

function EmoteClient.init(remote)
	emoteEvent = remote

	local currentCharacter = player.Character or player.CharacterAdded:Wait()
	onCharacterAdded(currentCharacter)

	player.CharacterAdded:Connect(onCharacterAdded)

	emoteEvent.OnClientEvent:Connect(function(sourcePlayer, emoteData)
		if sourcePlayer == player then
			if emoteData.error then
				print("[Emote] Error:", emoteData.error)
			else
				playEmoteAnimation(emoteData)
			end
		else
			playOtherPlayerEmote(sourcePlayer, emoteData)
		end
	end)

	setupKeybinds()
	print("[EmoteClient] Initialized")
end

function EmoteClient.stopCurrentEmote()
	stopCurrentEmote()
end

return EmoteClient
