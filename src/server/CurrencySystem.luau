--!nonstrict
-- Currency System for Aethelgard
-- Manages premium currency (Robux purchases) and secondary currency (duplicate conversion)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local GachaData = require(sharedFolder:WaitForChild("GachaData"))

local CurrencySystem = {}

CurrencySystem.CURRENCY_NAME = "Gems"
CurrencySystem.SECONDARY_CURRENCY_NAME = "Shards"

CurrencySystem.ROBUX_PACKS = {
    { id = "pack_100", name = "100 Gems", robux = 59, amount = 100, productId = 0 },
    { id = "pack_550", name = "550 Gems", robux = 249, amount = 550, productId = 0 },
    { id = "pack_1200", name = "1200 Gems", robux = 449, amount = 1200, productId = 0 },
    { id = "pack_2500", name = "2500 Gems", robux = 899, amount = 2500, productId = 0 },
}

CurrencySystem.ROLL_COST = {
    single = 100,
    ten = 900,
}

local playerCurrency = {}
local playerSecondaryCurrency = {}

local DEFAULT_CURRENCY = 0
local DEFAULT_SECONDARY = 0

function CurrencySystem.getCurrency(playerId: number): number
    if not playerCurrency[playerId] then
        playerCurrency[playerId] = DEFAULT_CURRENCY
    end
    return playerCurrency[playerId]
end

function CurrencySystem.getSecondaryCurrency(playerId: number): number
    if not playerSecondaryCurrency[playerId] then
        playerSecondaryCurrency[playerId] = DEFAULT_SECONDARY
    end
    return playerSecondaryCurrency[playerId]
end

function CurrencySystem.addCurrency(playerId: number, amount: number): number
    local current = CurrencySystem.getCurrency(playerId)
    playerCurrency[playerId] = current + amount
    return playerCurrency[playerId]
end

function CurrencySystem.addSecondaryCurrency(playerId: number, amount: number): number
    local current = CurrencySystem.getSecondaryCurrency(playerId)
    playerSecondaryCurrency[playerId] = current + amount
    return playerSecondaryCurrency[playerId]
end

function CurrencySystem.spendCurrency(playerId: number, amount: number): (boolean, string?)
    local current = CurrencySystem.getCurrency(playerId)
    if current < amount then
        return false, "Insufficient " .. CurrencySystem.CURRENCY_NAME
    end
    playerCurrency[playerId] = current - amount
    return true, nil
end

function CurrencySystem.spendSecondaryCurrency(playerId: number, amount: number): (boolean, string?)
    local current = CurrencySystem.getSecondaryCurrency(playerId)
    if current < amount then
        return false, "Insufficient " .. CurrencySystem.SECONDARY_CURRENCY_NAME
    end
    playerSecondaryCurrency[playerId] = current - amount
    return true, nil
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
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductProcessingDecision.NotProcessedYet
        end
        
        local success = CurrencySystem.processRobuxPurchase(player, receiptInfo.ProductId)
        
        if success then
            return Enum.ProductProcessingDecision.PurchaseGranted
        else
            return Enum.ProductProcessingDecision.NotProcessedYet
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        playerCurrency[player.UserId] = DEFAULT_CURRENCY
        playerSecondaryCurrency[player.UserId] = DEFAULT_SECONDARY
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        playerCurrency[player.UserId] = nil
        playerSecondaryCurrency[player.UserId] = nil
    end)
    
    print("[CurrencySystem] Initialized")
end

function CurrencySystem.getPlayerCurrencyData(playerId: number)
    return {
        gems = CurrencySystem.getCurrency(playerId),
        shards = CurrencySystem.getSecondaryCurrency(playerId),
    }
end

return CurrencySystem
