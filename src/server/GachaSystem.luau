--!nonstrict
-- Gacha System for Aethelgard
-- Handles gacha rolls, pity system, and duplicate management

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local GachaData = require(sharedFolder:WaitForChild("GachaData"))
local CurrencySystem = require(script.Parent:WaitForChild("CurrencySystem"))
local PlayerDataSystem = require(script.Parent:WaitForChild("PlayerDataSystem"))

local GachaSystem = {}

local playerPity = {}

local DEFAULT_PITY = {
    rolls = 0,
    softPityActive = false,
}

local function getPityData(playerId: number)
    if not playerPity[playerId] then
        playerPity[playerId] = table.clone(DEFAULT_PITY)
    end
    return playerPity[playerId]
end

local function getInventory(playerId: number)
    return PlayerDataSystem.getInventory(playerId)
end

local function calculateRarityRates(pityData)
    local rates = {}
    local pityMultiplier = 0
    
    if pityData.rolls >= GachaData.PITY_CONFIG.softPityStart then
        pityMultiplier = (pityData.rolls - GachaData.PITY_CONFIG.softPityStart + 1) * GachaData.PITY_CONFIG.softPityIncrement
    end
    
    for _, rarity in ipairs(GachaData.RARITIES) do
        rates[rarity.id] = rarity.baseRate
    end
    
    local legendaryBoost = pityMultiplier
    rates.legendary = rates.legendary + legendaryBoost
    
    local totalNonLegendary = 0
    for id, rate in pairs(rates) do
        if id ~= "legendary" then
            totalNonLegendary = totalNonLegendary + rate
        end
    end
    
    if totalNonLegendary + rates.legendary > 1 then
        local scale = (1 - rates.legendary) / totalNonLegendary
        for id, rate in pairs(rates) do
            if id ~= "legendary" then
                rates[id] = rate * scale
            end
        end
    end
    
    return rates
end

local function rollRarity(pityData)
    if pityData.rolls >= GachaData.PITY_CONFIG.hardPity - 1 then
        return "legendary"
    end
    
    local rates = calculateRarityRates(pityData)
    local roll = math.random()
    local cumulative = 0
    
    for _, rarity in ipairs(GachaData.RARITIES) do
        cumulative = cumulative + rates[rarity.id]
        if roll <= cumulative then
            return rarity.id
        end
    end
    
    return "common"
end

local function selectRandomItem(items, rarity)
    local filtered = GachaData.getItemsByRarity(items, rarity)
    if #filtered == 0 then
        return nil
    end
    return filtered[math.random(1, #filtered)]
end

local function addItemToInventory(playerId: number, item)
    local category = item.type .. "s"
    local itemData = {
        id = item.id,
        name = item.name,
        type = item.type,
        rarity = item.rarity,
        equipped = false,
    }

    if PlayerDataSystem.hasItem(playerId, item.id) then
        return false, item
    end

    PlayerDataSystem.addItem(playerId, item.type, itemData)

    return true, nil
end

function GachaSystem.roll(playerId: number, bannerId: string, count: number)
    local banner = GachaData.getBannerById(bannerId)
    if not banner then
        return nil, "Invalid banner"
    end
    
    local cost = count == 10 and CurrencySystem.ROLL_COST.ten or CurrencySystem.ROLL_COST.single
    if count ~= 1 and count ~= 10 then
        count = 1
    end
    
    if not CurrencySystem.canAfford(playerId, cost) then
        return nil, "Insufficient currency"
    end
    
    CurrencySystem.spendCurrency(playerId, cost)
    
    local pityData = getPityData(playerId)
    local items = GachaData.getItemsByBannerType(banner.type)
    local results = {}
    local isFirstRoll = pityData.rolls == 0
    
    for i = 1, count do
        local rarity
        local guaranteedLegendary = pityData.rolls >= GachaData.PITY_CONFIG.hardPity - 1
        
        if guaranteedLegendary then
            rarity = "legendary"
        elseif isFirstRoll and i == 1 then
            rarity = GachaData.GUARANTEES.firstRollMinRarity
            local roll = math.random()
            if roll < 0.7 then
                rarity = "rare"
            elseif roll < 0.95 then
                rarity = "epic"
            else
                rarity = "legendary"
            end
        elseif count == 10 and i == 10 then
            local minRarity = GachaData.GUARANTEES.tenRollMinRarity
            local currentRarity = rollRarity(pityData)
            local rarityOrder = {"common", "rare", "epic", "legendary"}
            local currentIndex = table.find(rarityOrder, currentRarity) or 1
            local minIndex = table.find(rarityOrder, minRarity) or 2
            
            if currentIndex < minIndex then
                rarity = minRarity
            else
                rarity = currentRarity
            end
        else
            rarity = rollRarity(pityData)
        end
        
        local item = selectRandomItem(items, rarity)
        if item then
            local isNew, duplicate = addItemToInventory(playerId, item)
            local duplicateValue = 0
            
            if duplicate then
                duplicateValue = CurrencySystem.convertDuplicateToCurrency(playerId, item.rarity)
            end
            
            table.insert(results, {
                item = item,
                isNew = isNew,
                duplicateValue = duplicateValue,
            })
        end
        
        pityData.rolls = pityData.rolls + 1
        
        if rarity == "legendary" then
            pityData.rolls = 0
        end
    end
    
    return {
        results = results,
        pityRolls = pityData.rolls,
        currency = CurrencySystem.getPlayerCurrencyData(playerId),
    }, nil
end

function GachaSystem.getInventory(playerId: number)
    return getInventory(playerId)
end

function GachaSystem.hasItem(playerId: number, itemId: string): boolean
    local inventory = getInventory(playerId)
    for _, category in pairs(inventory) do
        for _, item in ipairs(category) do
            if item.id == itemId then
                return true
            end
        end
    end
    return false
end

function GachaSystem.equipItem(playerId: number, itemId: string): (boolean, string?)
    local inventory = getInventory(playerId)
    local itemToEquip = nil
    local categoryType = nil
    
    for categoryName, category in pairs(inventory) do
        for _, item in ipairs(category) do
            if item.id == itemId then
                itemToEquip = item
                categoryType = categoryName
                break
            end
        end
        if itemToEquip then break end
    end
    
    if not itemToEquip then
        return false, "Item not found"
    end
    
    for _, item in ipairs(inventory[categoryType]) do
        item.equipped = false
    end
    
    itemToEquip.equipped = true
    return true, nil
end

function GachaSystem.unequipItem(playerId: number, itemId: string): (boolean, string?)
    local inventory = getInventory(playerId)
    
    for categoryName, category in pairs(inventory) do
        for _, item in ipairs(category) do
            if item.id == itemId then
                item.equipped = false
                return true, nil
            end
        end
    end
    
    return false, "Item not found"
end

function GachaSystem.getPityRolls(playerId: number): number
    local pityData = getPityData(playerId)
    return pityData.rolls
end

function GachaSystem.getBannerInfo(bannerId: string)
    local banner = GachaData.getBannerById(bannerId)
    if not banner then return nil end
    
    local items = GachaData.getItemsByBannerType(banner.type)
    return {
        banner = banner,
        items = items,
        pityConfig = GachaData.PITY_CONFIG,
        rollPrices = GachaData.ROLL_PRICES,
    }
end

function GachaSystem.getActiveBanners()
	local active = {}
	for _, banner in ipairs(GachaData.BANNERS) do
		if banner.active then
			table.insert(active, banner)
		end
	end
	return active
end

function GachaSystem.purchaseWithShards(playerId: number, itemId: string)
	local item = GachaData.getItemById(itemId)
	if not item then
		return nil, "Item not found"
	end

	if GachaSystem.hasItem(playerId, itemId) then
		return nil, "Already owned"
	end

	local price = GachaData.SHARD_PRICES[item.rarity]
	if not price then
		return nil, "Invalid rarity"
	end

	if not CurrencySystem.canAffordSecondary(playerId, price) then
		return nil, "Insufficient " .. CurrencySystem.SECONDARY_CURRENCY_NAME
	end

	CurrencySystem.spendSecondaryCurrency(playerId, price)

	local success = addItemToInventory(playerId, item)
	if not success then
		CurrencySystem.addSecondaryCurrency(playerId, price)
		return nil, "Failed to add item"
	end

	return {
		item = item,
		currency = CurrencySystem.getPlayerCurrencyData(playerId),
	}, nil
end

function GachaSystem.init()
    Players.PlayerRemoving:Connect(function(player)
        playerPity[player.UserId] = nil
        playerInventory[player.UserId] = nil
    end)
    
    print("[GachaSystem] Initialized")
end

return GachaSystem
