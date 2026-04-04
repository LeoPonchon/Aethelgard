--!nonstrict
-- Aura System Client for Aethelgard
-- Clones VFX from ReplicatedStorage/Auras onto the character
-- Synchronizes with server for multiplayer visibility

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local AuraSystem = {}

local auraActive = false
local currentAuraId = nil
local currentRarity = nil
local currentAuraInstance = nil
local auraRemote = nil
local auraEvent = nil
local otherPlayerAuras = {}

local function getHumanoidRootPart(targetPlayer)
	if targetPlayer == player then
		local character = player.Character
		if not character then return nil end
		return character:FindFirstChild("HumanoidRootPart")
	else
		if not targetPlayer.Character then return nil end
		return targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	end
end

local function clearAura()
	if currentAuraInstance then
		currentAuraInstance:Destroy()
		currentAuraInstance = nil
	end
end

local function clearOtherPlayerAura(playerId)
	if otherPlayerAuras[playerId] then
		if otherPlayerAuras[playerId].instance then
			otherPlayerAuras[playerId].instance:Destroy()
		end
		otherPlayerAuras[playerId] = nil
	end
end

local function createAuraEffect(auraId, rarity, targetPlayer, isOtherPlayer)
	local hrp = getHumanoidRootPart(targetPlayer)
	if not hrp then
		warn("[AuraSystem] No HumanoidRootPart found")
		return
	end

	if isOtherPlayer then
		clearOtherPlayerAura(targetPlayer.UserId)
	else
		clearAura()
	end

	local aurasFolder = ReplicatedStorage:FindFirstChild("Auras")
	if not aurasFolder then
		warn("[AuraSystem] Auras folder not found in ReplicatedStorage")
		return
	end

	local auraVFX = aurasFolder:FindFirstChild(auraId)
	if not auraVFX then
		warn("[AuraSystem] Aura VFX not found:", auraId)
		return
	end

	local auraInstance = auraVFX:Clone()
	auraInstance.Parent = hrp

	if auraInstance:IsA("BasePart") then
		auraInstance.Position = hrp.Position
	end

	if isOtherPlayer then
		otherPlayerAuras[targetPlayer.UserId] = {
			instance = auraInstance,
			auraId = auraId,
		}
	else
		currentAuraInstance = auraInstance
	end

	print("[AuraSystem] Created aura effect:", auraId, rarity, "for", isOtherPlayer and targetPlayer.Name or "local")
end

function AuraSystem.setEquippedAura(auraId, rarity)
	print("[AuraSystem] setEquippedAura called:", auraId, rarity)
	currentAuraId = auraId
	currentRarity = rarity

	if auraRemote then
		pcall(function()
			auraRemote:InvokeServer("setAura", { auraId = auraId, rarity = rarity })
		end)
	end

	if auraActive and auraId then
		createAuraEffect(auraId, rarity or "common", player, false)
	elseif not auraId then
		clearAura()
	end
end

function AuraSystem.toggleAura()
	auraActive = not auraActive
	print("[AuraSystem] toggleAura called, now active:", auraActive, "currentAuraId:", currentAuraId)

	if auraRemote then
		pcall(function()
			auraRemote:InvokeServer("toggleAura", {})
		end)
	end

	if auraActive and currentAuraId then
		createAuraEffect(currentAuraId, currentRarity or "common", player, false)
	else
		clearAura()
	end

	return auraActive
end

function AuraSystem.isActive()
	return auraActive
end

function AuraSystem.getEquippedAura()
	return currentAuraId
end

local function syncWithServer()
	if not auraRemote then return end
	
	pcall(function()
		local allAuras = auraRemote:InvokeServer("requestSync", {})
		if allAuras then
			for _, auraData in ipairs(allAuras) do
				local targetPlayer = Players:GetPlayerByUserId(auraData.playerId)
				if targetPlayer and targetPlayer ~= player then
					createAuraEffect(auraData.auraId, auraData.rarity, targetPlayer, true)
				end
			end
		end
	end)
end

local function onAuraEventReceived(data)
	local targetPlayer = Players:GetPlayerByUserId(data.playerId)
	if not targetPlayer then return end

	if targetPlayer == player then return end

	if data.active then
		createAuraEffect(data.auraId, data.rarity, targetPlayer, true)
	else
		clearOtherPlayerAura(data.playerId)
	end
end

function AuraSystem.init(gachaRemote)
	auraRemote = ReplicatedStorage:FindFirstChild("AuraRemote")
	auraEvent = ReplicatedStorage:FindFirstChild("AuraEvent")

	if auraEvent then
		auraEvent.OnClientEvent:Connect(onAuraEventReceived)
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if auraActive and currentAuraId then
			createAuraEffect(currentAuraId, currentRarity or "common", player, false)
		end
		syncWithServer()
	end)

	if player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp and auraActive and currentAuraId then
			createAuraEffect(currentAuraId, currentRarity or "common", player, false)
		end
		syncWithServer()
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.P then
			AuraSystem.toggleAura()
		end
	end)

	if gachaRemote then
		task.spawn(function()
			local success, inventory = pcall(function()
				return gachaRemote:InvokeServer("getInventory")
			end)
			if success and inventory and inventory.auras then
				for _, aura in ipairs(inventory.auras) do
					if aura.equipped then
						currentAuraId = aura.id
						currentRarity = aura.rarity
						break
					end
				end
			end
		end)
	end

	Players.PlayerRemoving:Connect(function(leavingPlayer)
		clearOtherPlayerAura(leavingPlayer.UserId)
	end)

	print("[AuraSystem] Initialized")
end

return AuraSystem
