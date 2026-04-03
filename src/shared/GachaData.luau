--!nonstrict
-- Gacha configuration data for Aethelgard

export type GachaRarity = {
    id: string,
    name: string,
    color: Color3,
    baseRate: number,
    pityThreshold: number?,
}

export type GachaItem = {
    id: string,
    name: string,
    type: string,
    rarity: string,
    description: string,
    iconId: string?,
}

export type GachaBanner = {
    id: string,
    name: string,
    description: string,
    type: string,
    featuredItems: { string },
    startTime: number,
    endTime: number,
    active: boolean,
}

export type PityConfig = {
    softPityStart: number,
    softPityIncrement: number,
    hardPity: number,
    carryOver: boolean,
}

local GACHA_DATA = {}

GACHA_DATA.RARITIES = {
    { id = "common", name = "Common", color = Color3.fromRGB(150, 150, 150), baseRate = 0.691 },
    { id = "rare", name = "Rare", color = Color3.fromRGB(0, 100, 255), baseRate = 0.253 },
    { id = "epic", name = "Epic", color = Color3.fromRGB(163, 53, 238), baseRate = 0.051 },
    { id = "legendary", name = "Legendary", color = Color3.fromRGB(255, 170, 0), baseRate = 0.005 },
}

GACHA_DATA.PITY_CONFIG = {
    softPityStart = 70,
    softPityIncrement = 0.01,
    hardPity = 80,
    carryOver = true,
}

GACHA_DATA.ROLL_PRICES = {
    single = 100,
    ten = 900,
}

GACHA_DATA.GUARANTEES = {
    firstRollMinRarity = "rare",
    tenRollMinRarity = "epic",
}

GACHA_DATA.BANNERS = {
    {
        id = "standard_aura",
        name = "Standard Aura Banner",
        description = "Roll for magical auras to customize your character",
        type = "aura",
        featuredItems = {"golden_aura", "shadow_aura", "flame_aura"},
        startTime = 0,
        endTime = math.huge,
        active = true,
    },
    {
        id = "standard_accessory",
        name = "Standard Accessory Banner",
        description = "Roll for cosmetic accessories",
        type = "accessory",
        featuredItems = {"crown", "wings", "halo"},
        startTime = 0,
        endTime = math.huge,
        active = true,
    },
}

GACHA_DATA.AURAS = {
    { id = "golden_aura", name = "Golden Aura", type = "aura", rarity = "legendary", description = "A majestic golden glow", iconId = "" },
    { id = "shadow_aura", name = "Shadow Aura", type = "aura", rarity = "legendary", description = "Dark wisps of shadow", iconId = "" },
    { id = "flame_aura", name = "Flame Aura", type = "aura", rarity = "epic", description = "Flickering flames surround you", iconId = "" },
    { id = "ice_aura", name = "Ice Aura", type = "aura", rarity = "epic", description = "Frost crystals float around", iconId = "" },
    { id = "nature_aura", name = "Nature Aura", type = "aura", rarity = "rare", description = "Gentle green glow", iconId = "" },
    { id = "water_aura", name = "Water Aura", type = "aura", rarity = "rare", description = "Flowing water particles", iconId = "" },
    { id = "wind_aura", name = "Wind Aura", type = "aura", rarity = "common", description = "Light breeze effect", iconId = "" },
    { id = "dust_aura", name = "Dust Aura", type = "aura", rarity = "common", description = "Subtle dust particles", iconId = "" },
}

GACHA_DATA.ACCESSORIES = {
    { id = "crown", name = "Royal Crown", type = "accessory", rarity = "legendary", description = "A crown fit for royalty", iconId = "" },
    { id = "wings", name = "Angel Wings", type = "accessory", rarity = "legendary", description = "Divine feathered wings", iconId = "" },
    { id = "halo", name = "Holy Halo", type = "accessory", rarity = "epic", description = "A glowing ring above your head", iconId = "" },
    { id = "horns", name = "Demonic Horns", type = "accessory", rarity = "epic", description = "Dark twisted horns", iconId = "" },
    { id = "cape", name = "Hero's Cape", type = "accessory", rarity = "rare", description = "A flowing cape", iconId = "" },
    { id = "tiara", name = "Silver Tiara", type = "accessory", rarity = "rare", description = "An elegant tiara", iconId = "" },
    { id = "earrings", name = "Gold Earrings", type = "accessory", rarity = "common", description = "Simple gold earrings", iconId = "" },
    { id = "necklace", name = "Silver Necklace", type = "accessory", rarity = "common", description = "A simple silver chain", iconId = "" },
}

GACHA_DATA.DUPLICATE_VALUES = {
    common = 10,
    rare = 30,
    epic = 100,
    legendary = 500,
}

function GACHA_DATA.getItemsByBannerType(bannerType)
    local items = {}
    if bannerType == "aura" then
        for _, item in ipairs(GACHA_DATA.AURAS) do
            table.insert(items, item)
        end
    elseif bannerType == "accessory" then
        for _, item in ipairs(GACHA_DATA.ACCESSORIES) do
            table.insert(items, item)
        end
    end
    return items
end

function GACHA_DATA.getItemsByRarity(items, rarityId)
    local filtered = {}
    for _, item in ipairs(items) do
        if item.rarity == rarityId then
            table.insert(filtered, item)
        end
    end
    return filtered
end

function GACHA_DATA.getRarityById(rarityId)
    for _, rarity in ipairs(GACHA_DATA.RARITIES) do
        if rarity.id == rarityId then
            return rarity
        end
    end
    return nil
end

function GACHA_DATA.getBannerById(bannerId)
    for _, banner in ipairs(GACHA_DATA.BANNERS) do
        if banner.id == bannerId then
            return banner
        end
    end
    return nil
end

function GACHA_DATA.getItemById(itemId)
    for _, item in ipairs(GACHA_DATA.AURAS) do
        if item.id == itemId then
            return item
        end
    end
    for _, item in ipairs(GACHA_DATA.ACCESSORIES) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

return GACHA_DATA
