--!nonstrict
-- Aura Server System for Aethelgard
-- Synchronizes aura effects across all clients

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AuraServerSystem = {}

local playerAuras = {}

local auraRemote = nil
local auraEvent = nil

local function getPlayerAura(player)
	if not playerAuras[player.UserId] then
		playerAuras[player.UserId] = {
			auraId = nil,
			rarity = nil,
			active = false,
		}
	end
	return playerAuras[player.UserId]
end

local function broadcastAuraState(player, auraId, rarity, active)
	if not auraEvent then return end

	auraEvent:FireAllClients({
		playerId = player.UserId,
		auraId = auraId,
		rarity = rarity,
		active = active,
	})
end

local function onCharacterAdded(player)
	task.wait(0.5)

	local auraData = getPlayerAura(player)
	if auraData and auraData.auraId and auraData.active then
		broadcastAuraState(player, auraData.auraId, auraData.rarity, true)
	end
end

local function onPlayerRemoving(player)
	playerAuras[player.UserId] = nil
end

function AuraServerSystem.setPlayerAura(playerId, auraId, rarity)
	local player = Players:GetPlayerByUserId(playerId)
	if not player then return end

	local auraData = getPlayerAura(player)
	auraData.auraId = auraId
	auraData.rarity = rarity

	if auraData.active and auraId then
		broadcastAuraState(player, auraId, rarity, true)
	end
end

function AuraServerSystem.togglePlayerAura(playerId)
	local player = Players:GetPlayerByUserId(playerId)
	if not player then return false end

	local auraData = getPlayerAura(player)
	auraData.active = not auraData.active

	if auraData.active and auraData.auraId then
		broadcastAuraState(player, auraData.auraId, auraData.rarity, true)
	else
		broadcastAuraState(player, auraData.auraId, auraData.rarity, false)
	end

	return auraData.active
end

function AuraServerSystem.handleRemoteInvoke(player, action, data)
	if action == "setAura" then
		AuraServerSystem.setPlayerAura(player.UserId, data.auraId, data.rarity)
		return true
	elseif action == "toggleAura" then
		local active = AuraServerSystem.togglePlayerAura(player.UserId)
		return { active = active }
	elseif action == "getAuraState" then
		local auraData = getPlayerAura(player)
		return {
			auraId = auraData.auraId,
			rarity = auraData.rarity,
			active = auraData.active,
		}
	elseif action == "requestSync" then
		local allAuras = {}
		for userId, auraData in pairs(playerAuras) do
			if auraData.active and auraData.auraId then
				table.insert(allAuras, {
					playerId = userId,
					auraId = auraData.auraId,
					rarity = auraData.rarity,
				})
			end
		end
		return allAuras
	end

	return nil
end

function AuraServerSystem.init()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			onCharacterAdded(player)
		end)

		if player.Character then
			task.spawn(function()
				onCharacterAdded(player)
			end)
		end
	end)

	Players.PlayerRemoving:Connect(onPlayerRemoving)

	print("[AuraServerSystem] Initialized")
end

function AuraServerSystem.initRemotes(remoteManager)
	auraRemote = remoteManager.get("AuraRemote")
	auraEvent = remoteManager.get("AuraEvent")

	print("[AuraServerSystem] Remotes initialized")
end

return AuraServerSystem
