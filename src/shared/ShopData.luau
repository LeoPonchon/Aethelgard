--!nonstrict
-- Shop Data for Aethelgard
-- Gamepasses and purchasable items

local SHOP_DATA = {}

SHOP_DATA.ALERT_PACKAGES = {
    {
        id = "throne_alert",
        name = "Throne Alert",
        description = "Get notified when King, Queen or other royal thrones become available",
        price = 59,
        type = "alert",
        category = "alerts",
        gamepassId = 0,
    },
    {
        id = "relic_alert",
        name = "Relic Alert",
        description = "Get notified when rare RP items appear (Excalibur, Avalon...)",
        price = 59,
        type = "alert",
        category = "alerts",
        gamepassId = 0,
    },
    {
        id = "slot_alert",
        name = "Slot Alert",
        description = "Get notified when RP slots open (Princes, Barons, Hero...)",
        price = 59,
        type = "alert",
        category = "alerts",
        gamepassId = 0,
    },
    {
        id = "alert_pack",
        name = "Alert Bundle",
        description = "All three alerts at a discount",
        price = 179,
        type = "alert",
        category = "alerts",
        gamepassId = 0,
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
        gamepassId = 0,
    },
    {
        id = "noble_identity",
        name = "Noble Identity Pack",
        description = "Silver chat color, 'Noble' tag, Silver Aura, Tiara accessory",
        price = 249,
        type = "identity",
        category = "identity",
        gamepassId = 0,
    },
    {
        id = "hero_identity",
        name = "Hero Identity Pack",
        description = "White chat color, 'Hero' tag, Light Aura, Halo accessory",
        price = 299,
        type = "identity",
        category = "identity",
        gamepassId = 0,
    },
}

SHOP_DATA.EMOTES = {
    {
        id = "royal_greeting",
        name = "Royal Greeting",
        description = "A majestic wave fit for royalty",
        price = 59,
        type = "emote",
        category = "emotes",
        gamepassId = 0,
    },
    {
        id = "victory_pose",
        name = "Victory Pose",
        description = "Strike a triumphant pose",
        price = 79,
        type = "emote",
        category = "emotes",
        gamepassId = 0,
    },
    {
        id = "dance_emote",
        name = "Celebration Dance",
        description = "Break into a joyful dance",
        price = 99,
        type = "emote",
        category = "emotes",
        gamepassId = 0,
    },
    {
        id = "laugh_emote",
        name = "Noble Laugh",
        description = "A sophisticated laugh",
        price = 39,
        type = "emote",
        category = "emotes",
        gamepassId = 0,
    },
    {
        id = "emote_pack",
        name = "Emote Bundle",
        description = "All emotes at a discount",
        price = 199,
        type = "emote",
        category = "emotes",
        gamepassId = 0,
    },
}

SHOP_DATA.RP_TOOLS = {
    {
        id = "rp_sword",
        name = "RP Sword",
        description = "A ceremonial sword for roleplay",
        price = 79,
        type = "tool",
        category = "tools",
        gamepassId = 0,
    },
    {
        id = "rp_scepter",
        name = "Royal Scepter",
        description = "A symbol of royal authority",
        price = 99,
        type = "tool",
        category = "tools",
        gamepassId = 0,
    },
    {
        id = "rp_grimoire",
        name = "Ancient Grimoire",
        description = "A magical tome for spellcasters",
        price = 89,
        type = "tool",
        category = "tools",
        gamepassId = 0,
    },
    {
        id = "rp_instrument",
        name = "Lute",
        description = "A musical instrument for bards",
        price = 59,
        type = "tool",
        category = "tools",
        gamepassId = 0,
    },
    {
        id = "rp_scroll",
        name = "Royal Decree Scroll",
        description = "Official scroll for announcements",
        price = 69,
        type = "tool",
        category = "tools",
        gamepassId = 0,
    },
}

SHOP_DATA.CATEGORIES = {
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
        id = "emotes",
        name = "Gestures & Emotes",
        description = "Express yourself with unique animations",
        items = SHOP_DATA.EMOTES,
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
