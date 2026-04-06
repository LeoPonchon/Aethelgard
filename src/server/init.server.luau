--!nonstrict
-- Server initialization script for Aethelgard
-- Orchestrates all server-side systems

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local MarketplaceService = game:GetService("MarketplaceService")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

local DataHelpers = require(sharedFolder:WaitForChild("DataHelpers"))
local EmoteSystem = require(sharedFolder:WaitForChild("EmoteSystem"))
local GachaData = require(sharedFolder:WaitForChild("GachaData"))
local ShopData = require(sharedFolder:WaitForChild("ShopData"))

local RemoteManager = require(script:WaitForChild("RemoteManager"))
local PlayerDisplaySystem = require(script:WaitForChild("PlayerDisplaySystem"))
local PlayerDataSystem = require(script:WaitForChild("PlayerDataSystem"))
local NPCInteractionSystem = require(script:WaitForChild("NPCInteractionSystem"))
local NPCProximitySystem = require(script:WaitForChild("NPCProximitySystem"))
local CurrencySystem = require(script:WaitForChild("CurrencySystem"))
local GachaSystem = require(script:WaitForChild("GachaSystem"))
local ShopSystem = require(script:WaitForChild("ShopSystem"))
local NotificationSystem = require(script:WaitForChild("NotificationSystem"))
local DayNightCycle = require(script:WaitForChild("DayNightCycle"))
local AuraServerSystem = require(script:WaitForChild("AuraServerSystem"))

PlayerDataSystem.init()
CurrencySystem.setPlayerDataSystem(PlayerDataSystem)

local systems = {
	DayNightCycle,
	PlayerDisplaySystem,
	NPCProximitySystem,
	CurrencySystem,
	GachaSystem,
	ShopSystem,
	NotificationSystem,
	AuraServerSystem,
}

for _, system in ipairs(systems) do
	system.init()
end

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

RemoteManager.init()
AuraServerSystem.initRemotes(RemoteManager)

local npcInteractionRemote = RemoteManager.get("NPCInteraction")
local emoteEvent = RemoteManager.get("PlayEmote")
local playerDataRemote = RemoteManager.get("PlayerData")
local gachaRemote = RemoteManager.get("GachaRemote")
local shopRemote = RemoteManager.get("ShopRemote")
local auraRemote = RemoteManager.get("AuraRemote")

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
	elseif action == "setTeam" then
		local teamName = data.team
		local team = Teams:FindFirstChild(teamName)
		if team then
			player.Team = team
			PlayerDisplaySystem.updatePlayer(player)
			return true
		end
		return false
	elseif action == "setLevel" then
		PlayerDataSystem.setLevel(player.UserId, data.level)
		PlayerDisplaySystem.updatePlayer(player)
		return true
	end
	return nil
end

gachaRemote.OnServerInvoke = function(player, action, data)
	if action == "roll" then
		return GachaSystem.roll(player.UserId, data.bannerId, data.count)
	elseif action == "getInventory" then
		return GachaSystem.getInventory(player.UserId)
	elseif action == "getCurrency" then
		return CurrencySystem.getPlayerCurrencyData(player.UserId)
	elseif action == "getPity" then
		return GachaSystem.getPityRolls(player.UserId)
	elseif action == "getBanners" then
		return GachaSystem.getActiveBanners()
	elseif action == "getBannerInfo" then
		return GachaSystem.getBannerInfo(data.bannerId)
	elseif action == "equipItem" then
		return GachaSystem.equipItem(player.UserId, data.itemId)
	elseif action == "unequipItem" then
		return GachaSystem.unequipItem(player.UserId, data.itemId)
	elseif action == "purchaseWithShards" then
		return GachaSystem.purchaseWithShards(player.UserId, data.itemId)
	end
	return nil
end

shopRemote.OnServerInvoke = function(player, action, data)
	if action == "getShopData" then
		return ShopData.CATEGORIES
	elseif action == "getOwnedItems" then
		return ShopSystem.getPlayerShopData(player.UserId)
	elseif action == "purchaseItem" then
		return ShopSystem.promptPurchase(player, data.itemId)
	elseif action == "equipItem" then
		return ShopSystem.equipItem(player.UserId, data.itemId)
	elseif action == "unequipItem" then
		return ShopSystem.unequipItem(player.UserId, data.itemId)
	elseif action == "processGamepassPurchase" then
		return ShopSystem.processGamepassPurchase(player, data.gamepassId)
	end
	return nil
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId

	local currencyPack = CurrencySystem.getPackByProductId(productId)
	if currencyPack then
		local success = CurrencySystem.processRobuxPurchase(player, productId)
		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success = ShopSystem.processGamepassPurchase(player, productId)
	if success then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

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

auraRemote.OnServerInvoke = function(player, action, data)
	return AuraServerSystem.handleRemoteInvoke(player, action, data)
end

local function onPlayerAdded(player)
		PlayerDataSystem.loadPlayerData(player)
		
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

	local defaultTeamName = DataHelpers.getDefaultTeam()
	local defaultTeam = Teams:FindFirstChild(defaultTeamName)
	if defaultTeam then
		player.Team = defaultTeam
	end

	local playerData = PlayerDataSystem.getPlayerData(player.UserId)
	local currencyData = CurrencySystem.getPlayerCurrencyData(player.UserId)
	print(string.format("[Server] %s joined as %s (Level %d, %s, %s) [Gems: %d, Shards: %d]",
		player.Name, defaultTeamName, playerData.level, playerData.race, playerData.class,
		currencyData.gems, currencyData.shards))
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(player)
	end)
end

print("[Server] Aethelgard server initialized")
