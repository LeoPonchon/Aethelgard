--!nonstrict
-- Client initialization script for Aethelgard
-- Full version: emote animations, NPC dialogue, gacha UI, notifications

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

local DebugUI = script:FindFirstChild("DebugUI")
if DebugUI then
    DebugUI = require(DebugUI)
else
    local parent = script.Parent
    if parent then
        DebugUI = parent:FindFirstChild("DebugUI")
        if DebugUI then
            DebugUI = require(DebugUI)
        end
    end
end

local GachaClient = script:FindFirstChild("GachaClient")
if GachaClient then
	GachaClient = require(GachaClient)
else
	local parent = script.Parent
	if parent then
		GachaClient = parent:FindFirstChild("GachaClient")
		if GachaClient then
			GachaClient = require(GachaClient)
		end
	end
end



local ShopClient = script:FindFirstChild("ShopClient")
if ShopClient then
	ShopClient = require(ShopClient)
else
	local parent = script.Parent
	if parent then
		ShopClient = parent:FindFirstChild("ShopClient")
		if ShopClient then
			ShopClient = require(ShopClient)
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

print("[Client] Aethelgard client initialized - full version")

if DebugUI then
    DebugUI.mount()
end

if GachaClient then
	GachaClient.init()

	if DebugUI and DebugUI.setGachaToggle then
		DebugUI.setGachaToggle(function(show)
			if show then
				GachaClient.show()
			else
				GachaClient.hide()
			end
		end)
	end

	if DebugUI and DebugUI.setGachaIsVisible then
		DebugUI.setGachaIsVisible(function()
			return GachaClient.isVisible()
		end)
	end

	GachaClient.setOnVisibilityChanged(function(visible)
		if DebugUI and DebugUI.forceUpdateGachaButton then
			DebugUI.forceUpdateGachaButton()
		end
	end)

	_G.GachaClient = GachaClient
end

if ShopClient then
	ShopClient.init()

	if DebugUI and DebugUI.setShopToggle then
		DebugUI.setShopToggle(function(show)
			if show then
				ShopClient.show()
			else
				ShopClient.hide()
			end
		end)
	end

	if DebugUI and DebugUI.setShopIsVisible then
		DebugUI.setShopIsVisible(function()
			return ShopClient.isVisible()
		end)
	end

	ShopClient.setOnVisibilityChanged(function(visible)
		if DebugUI and DebugUI.forceUpdateShopButton then
			DebugUI.forceUpdateShopButton()
		end
	end)

	_G.ShopClient = ShopClient
end

-- Notification handling
local notificationEvent = waitForRemote("NotificationEvent", 10)
if notificationEvent then
    notificationEvent.OnClientEvent:Connect(function(data)
        print(string.format("[Notification] %s: %s", data.type, data.message))
    end)
end

-- Currency notification handling
local currencyNotification = waitForRemote("CurrencyNotification", 10)
if currencyNotification then
    currencyNotification.OnClientEvent:Connect(function(data)
        if data.type == "purchase" then
            print(string.format("[Currency] Purchased %d gems! Total: %d", data.amount, data.total))
            if GachaClient then
                GachaClient.updateCurrencyDisplay()
            end
        end
    end)
end

	-- NPC Dialogue handling
	local npcDialogueEvent = waitForRemote("NPCDialogue", 10)
	if npcDialogueEvent then
		npcDialogueEvent.OnClientEvent:Connect(function(data)
			if data.npcId and NPCDialogueClient then
				NPCDialogueClient.startConversation(data.npcId)
			end
		end)
	end
