--!nonstrict
-- Currency System for Aethelgard
-- Manages premium currency (Robux purchases) and secondary currency (duplicate conversion)
-- Syncs with PlayerDataSystem for persistence

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local GachaData = require(sharedFolder:WaitForChild("GachaData"))

local CurrencySystem = {}

CurrencySystem.CURRENCY_NAME = "Gems"
CurrencySystem.SECONDARY_CURRENCY_NAME = "Shards"

CurrencySystem.ROBUX_PACKS = {
	{ id = "pack_100", name = "100 Gems", robux = 59, amount = 100, productId = 3569290937 },
	{ id = "pack_550", name = "550 Gems", robux = 249, amount = 550, productId = 3569291172 },
	{ id = "pack_1200", name = "1200 Gems", robux = 449, amount = 1200, productId = 3569291516 },
	{ id = "pack_2500", name = "2500 Gems", robux = 899, amount = 2500, productId = 3569291677 },
}

CurrencySystem.ROLL_COST = {
	single = 100,
	ten = 900,
}

local PlayerDataSystem = nil

CurrencySystem.CURRENCY_NAME = "Gems"
CurrencySystem.SECONDARY_CURRENCY_NAME = "Shards"

function CurrencySystem.setPlayerDataSystem(pds)
	PlayerDataSystem = pds
end

function CurrencySystem.getCurrency(playerId: number): number
	if PlayerDataSystem then
		return PlayerDataSystem.getGems(playerId)
	end
	return 0
end

function CurrencySystem.getSecondaryCurrency(playerId: number): number
	if PlayerDataSystem then
		return PlayerDataSystem.getShards(playerId)
	end
	return 0
end

function CurrencySystem.addCurrency(playerId: number, amount: number): number
	if PlayerDataSystem then
		return PlayerDataSystem.addGems(playerId, amount)
	end
	return 0
end

function CurrencySystem.addSecondaryCurrency(playerId: number, amount: number): number
	if PlayerDataSystem then
		return PlayerDataSystem.addShards(playerId, amount)
	end
	return 0
end

function CurrencySystem.spendCurrency(playerId: number, amount: number): (boolean, string?)
	if PlayerDataSystem then
		return PlayerDataSystem.spendGems(playerId, amount)
	end
	return false, "PlayerDataSystem not available"
end

function CurrencySystem.spendSecondaryCurrency(playerId: number, amount: number): (boolean, string?)
	if PlayerDataSystem then
		return PlayerDataSystem.spendShards(playerId, amount)
	end
	return false, "PlayerDataSystem not available"
end

function CurrencySystem.canAfford(playerId: number, amount: number): boolean
	return CurrencySystem.getCurrency(playerId) >= amount
end

function CurrencySystem.canAffordSecondary(playerId: number, amount: number): boolean
	return CurrencySystem.getSecondaryCurrency(playerId) >= amount
end

function CurrencySystem.convertDuplicateToCurrency(playerId: number, itemRarity: string): number
	local value = GachaData.DUPLICATE_VALUES[itemRarity] or 0
	if value > 0 then
		CurrencySystem.addSecondaryCurrency(playerId, value)
	end
	return value
end

function CurrencySystem.getPackByProductId(productId: number)
	for _, pack in ipairs(CurrencySystem.ROBUX_PACKS) do
		if pack.productId == productId then
			return pack
		end
	end
	return nil
end

function CurrencySystem.processRobuxPurchase(player: Player, productId: number): boolean
	local pack = CurrencySystem.getPackByProductId(productId)
	if not pack then
		return false
	end

	CurrencySystem.addCurrency(player.UserId, pack.amount)
	
	if PlayerDataSystem then
		PlayerDataSystem.recordPurchase(player.UserId, "gems", productId, pack.robux, pack.amount)
	end

	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		local notificationRemote = ReplicatedStorage:FindFirstChild("CurrencyNotification")
		if notificationRemote then
			notificationRemote:FireClient(player, {
				type = "purchase",
				amount = pack.amount,
				total = CurrencySystem.getCurrency(player.UserId),
			})
		end
	end

	return true
end

function CurrencySystem.init()
	print("[CurrencySystem] Initialized")
end

function CurrencySystem.getPlayerCurrencyData(playerId: number)
	return {
		gems = CurrencySystem.getCurrency(playerId),
		shards = CurrencySystem.getSecondaryCurrency(playerId),
	}
end

return CurrencySystem
