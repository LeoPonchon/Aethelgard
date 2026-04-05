--!nonstrict
-- Shop Data for Aethelgard
-- Gamepasses and purchasable items

local SHOP_DATA = {}

SHOP_DATA.GEM_PACKS = {
	{ id = "pack_100", name = "100 Gems", robux = 59, amount = 100, productId = 3569290937 },
	{ id = "pack_550", name = "550 Gems", robux = 249, amount = 550, productId = 3569291172 },
	{ id = "pack_1200", name = "1200 Gems", robux = 449, amount = 1200, productId = 3569291516 },
	{ id = "pack_2500", name = "2500 Gems", robux = 899, amount = 2500, productId = 3569291677 },
	{ id = "pack_5000", name = "5000 Gems", robux = 1699, amount = 5000, productId = 3570506269 },
	{ id = "pack_12000", name = "12000 Gems", robux = 3999, amount = 12000, productId = 0 },
}

SHOP_DATA.ALERT_PACKAGES = {
	{
		id = "throne_alert",
		name = "Throne Alert",
		description = "Get notified when King, Queen or other royal thrones become available",
		price = 59,
		type = "alert",
		category = "alerts",
		gamepassId = 1780720022,
	},
	{
		id = "relic_alert",
		name = "Relic Alert",
		description = "Get notified when rare RP items appear (Excalibur, Avalon...)",
		price = 59,
		type = "alert",
		category = "alerts",
		gamepassId = 1780186103,
	},
	{
		id = "slot_alert",
		name = "Slot Alert",
		description = "Get notified when RP slots open (Princes, Barons, Hero...)",
		price = 59,
		type = "alert",
		category = "alerts",
		gamepassId = 1781500097,
	},
	{
		id = "alert_pack",
		name = "Alert Bundle",
		description = "All three alerts at a discount",
		price = 179,
		type = "alert",
		category = "alerts",
		gamepassId = 1783658757,
	},
}

SHOP_DATA.IDENTITY_PACKS = {
	{
		id = "royal_identity",
		name = "Royal Identity Pack",
		description = "Golden chat color, 'Royal' tag, Golden Aura, Crown accessory",
		price = 349,
		type = "identity",
		category = "identity",
		gamepassId = 1779784081,
	},
	{
		id = "noble_identity",
		name = "Noble Identity Pack",
		description = "Silver chat color, 'Noble' tag, Silver Aura, Tiara accessory",
		price = 249,
		type = "identity",
		category = "identity",
		gamepassId = 1779988171,
	},
	{
		id = "hero_identity",
		name = "Hero Identity Pack",
		description = "White chat color, 'Hero' tag, Light Aura, Halo accessory",
		price = 299,
		type = "identity",
		category = "identity",
		gamepassId = 1783604665,
	},
}

SHOP_DATA.RP_TOOLS = {
	{
		id = "rp_sword",
		name = "Crystallized Sword",
		description = "A ceremonial sword for roleplay",
		price = 79,
		type = "tool",
		category = "tools",
		gamepassId = 1783772617,
	},
	{
		id = "rp_scepter",
		name = "Royal Scepter",
		description = "A symbol of royal authority",
		price = 99,
		type = "tool",
		category = "tools",
		gamepassId = 1783772623,
	},
	{
		id = "rp_grimoire",
		name = "Ancient Grimoire",
		description = "A magical tome for spellcasters",
		price = 89,
		type = "tool",
		category = "tools",
		gamepassId = 1780966156,
	},
	{
		id = "rp_instrument",
		name = "Lute",
		description = "A musical instrument for bards",
		price = 59,
		type = "tool",
		category = "tools",
		gamepassId = 1783220826,
	},
	{
		id = "rp_scroll",
		name = "Royal Decree Scroll",
		description = "Official scroll for announcements",
		price = 69,
		type = "tool",
		category = "tools",
		gamepassId = 1779490021,
	},
}

SHOP_DATA.CATEGORIES = {
	{
		id = "gems",
		name = "Gems",
		description = "Premium currency for gacha rolls",
		items = SHOP_DATA.GEM_PACKS,
	},
	{
		id = "alerts",
		name = "Alert Notifications",
		description = "Get notified when important events happen",
		items = SHOP_DATA.ALERT_PACKAGES,
	},
	{
		id = "identity",
		name = "Identity Packs",
		description = "Customize your appearance with exclusive tags and colors",
		items = SHOP_DATA.IDENTITY_PACKS,
	},
	{
		id = "tools",
		name = "RP Tools",
		description = "Interactive items for roleplay",
		items = SHOP_DATA.RP_TOOLS,
	},
}

function SHOP_DATA.getItemById(itemId)
    for _, category in ipairs(SHOP_DATA.CATEGORIES) do
        for _, item in ipairs(category.items) do
            if item.id == itemId then
                return item
            end
        end
    end
    return nil
end

function SHOP_DATA.getItemsByCategory(categoryId)
    for _, category in ipairs(SHOP_DATA.CATEGORIES) do
        if category.id == categoryId then
            return category.items
        end
    end
    return {}
end

function SHOP_DATA.getAllItems()
    local all = {}
    for _, category in ipairs(SHOP_DATA.CATEGORIES) do
        for _, item in ipairs(category.items) do
            table.insert(all, item)
        end
    end
    return all
end

return SHOP_DATA
