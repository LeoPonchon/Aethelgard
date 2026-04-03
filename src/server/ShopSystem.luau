--!nonstrict
-- Shop System for Aethelgard
-- Handles gamepass purchases and owned items

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local ShopData = require(sharedFolder:WaitForChild("ShopData"))

local ShopSystem = {}

local ownedItems = {}
local equippedItems = {}

local DEFAULT_OWNED = {}
local DEFAULT_EQUIPPED = {}

function ShopSystem.getOwnedItems(playerId)
    if not ownedItems[playerId] then
        ownedItems[playerId] = table.clone(DEFAULT_OWNED)
    end
    return ownedItems[playerId]
end

function ShopSystem.getEquippedItems(playerId)
    if not equippedItems[playerId] then
        equippedItems[playerId] = table.clone(DEFAULT_EQUIPPED)
    end
    return equippedItems[playerId]
end

function ShopSystem.ownsItem(playerId, itemId)
    local owned = ShopSystem.getOwnedItems(playerId)
    for _, id in ipairs(owned) do
        if id == itemId then
            return true
        end
    end
    return false
end

function ShopSystem.purchaseItem(playerId, itemId)
    local item = ShopData.getItemById(itemId)
    if not item then
        return false, "Item not found"
    end

    if ShopSystem.ownsItem(playerId, itemId) then
        return false, "Already owned"
    end

    local owned = ShopSystem.getOwnedItems(playerId)
    table.insert(owned, itemId)

    return true, nil
end

function ShopSystem.equipItem(playerId, itemId)
    local item = ShopData.getItemById(itemId)
    if not item then
        return false, "Item not found"
    end

    if not ShopSystem.ownsItem(playerId, itemId) then
        return false, "Item not owned"
    end

    local equipped = ShopSystem.getEquippedItems(playerId)

    for i, id in ipairs(equipped) do
        local equippedItem = ShopData.getItemById(id)
        if equippedItem and equippedItem.category == item.category then
            table.remove(equipped, i)
        end
    end

    table.insert(equipped, itemId)
    return true, nil
end

function ShopSystem.unequipItem(playerId, itemId)
    local equipped = ShopSystem.getEquippedItems(playerId)

    for i, id in ipairs(equipped) do
        if id == itemId then
            table.remove(equipped, i)
            return true, nil
        end
    end

    return false, "Item not equipped"
end

function ShopSystem.isEquipped(playerId, itemId)
    local equipped = ShopSystem.getEquippedItems(playerId)
    for _, id in ipairs(equipped) do
        if id == itemId then
            return true
        end
    end
    return false
end

function ShopSystem.getEquippedByCategory(playerId, categoryId)
    local equipped = ShopSystem.getEquippedItems(playerId)
    local result = nil

    for _, id in ipairs(equipped) do
        local item = ShopData.getItemById(id)
        if item and item.category == categoryId then
            result = item
            break
        end
    end

    return result
end

function ShopSystem.getPlayerShopData(playerId)
    return {
        owned = ShopSystem.getOwnedItems(playerId),
        equipped = ShopSystem.getEquippedItems(playerId),
    }
end

function ShopSystem.processGamepassPurchase(player, gamepassId)
    local foundItem = nil
    for _, item in ipairs(ShopData.getAllItems()) do
        if item.gamepassId == gamepassId then
            foundItem = item
            break
        end
    end

    if not foundItem then
        return false
    end

    local success, err = ShopSystem.purchaseItem(player.UserId, foundItem.id)
    return success
end

function ShopSystem.promptPurchase(player, itemId)
    local item = ShopData.getItemById(itemId)
    if not item then
        return false, "Item not found"
    end
    
    if ShopSystem.ownsItem(player.UserId, itemId) then
        return false, "Already owned"
    end
    
    if item.gamepassId and item.gamepassId > 0 then
        MarketplaceService:PromptGamePassPurchase(player, item.gamepassId)
        return true, nil
    end
    
    return false, "No gamepass associated"
end

function ShopSystem.init()
    Players.PlayerAdded:Connect(function(player)
        local function checkGamepasses()
            task.wait(1)
            for _, item in ipairs(ShopData.getAllItems()) do
                if item.gamepassId and item.gamepassId > 0 then
                    local success, result = pcall(function()
                        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, item.gamepassId)
                    end)
                    if success and result then
                        if not ShopSystem.ownsItem(player.UserId, item.id) then
                            ShopSystem.purchaseItem(player.UserId, item.id)
                        end
                    end
                end
            end
        end

        task.spawn(checkGamepasses)
    end)

    Players.PlayerRemoving:Connect(function(player)
        ownedItems[player.UserId] = nil
        equippedItems[player.UserId] = nil
    end)

    print("[ShopSystem] Initialized")
end

return ShopSystem
