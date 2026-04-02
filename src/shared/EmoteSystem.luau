--!nonstrict
-- Emote System for Aethelgard
-- Handles RP animations and emotes for social interaction
-- Emotes are triggered through chat commands or proximity prompts

export type EmoteCategory = 
    "Greeting" | 
    "Combat" | 
    "Magic" | 
    "Social" | 
    "Dance" | 
    "Gesture" | 
    "Reaction" | 
    "Roleplay"

export type EmoteDefinition = {
    id: string,
    name: string,
    description: string,
    category: EmoteCategory,
    animationId: string?, -- Roblox animation ID
    duration: number, -- Duration in seconds
    looped: boolean,
    canMoveWhilePlaying: boolean,
    cooldown: number, -- Cooldown in seconds
    requiredClass: string?, -- Class required to use (for magic emotes)
    requiredFaction: string?, -- Faction required to use
    effects: {string}?, -- Visual/audio effects
    chatCommand: string, -- Command to trigger in chat (e.g., "/wave")
}

-- Emote definitions
local EMOTE_DEFINITIONS: {[string]: EmoteDefinition} = {
    -- === GREETING EMOTES ===
    ["wave"] = {
        id = "wave",
        name = "Wave",
        description = "Give a friendly wave.",
        category = "Greeting",
        animationId = "rbxassetid://507776028", -- wave animation
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/wave",
    },
    ["bow"] = {
        id = "bow",
        name = "Bow",
        description = "Perform a respectful bow.",
        category = "Greeting",
        animationId = "rbxassetid://507770000", -- bow animation
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/bow",
    },
    ["curtsy"] = {
        id = "curtsy",
        name = "Curtsy",
        description = "Perform a noble curtsy.",
        category = "Greeting",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/curtsy",
    },
    ["salute"] = {
        id = "salute",
        name = "Military Salute",
        description = "Give a military salute.",
        category = "Greeting",
        animationId = "rbxassetid://507770000",
        duration = 1.5,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/salute",
    },
    
    -- === COMBAT EMOTES ===
    ["draw_sword"] = {
        id = "draw_sword",
        name = "Draw Sword",
        description = "Draw your sword threateningly.",
        category = "Combat",
        animationId = "rbxassetid://507771000",
        duration = 1.5,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 2,
        chatCommand = "/draw",
    },
    ["threaten"] = {
        id = "threaten",
        name = "Threaten",
        description = "Make a threatening gesture.",
        category = "Combat",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 2,
        chatCommand = "/threaten",
    },
    ["victory"] = {
        id = "victory",
        name = "Victory",
        description = "Celebrate your combat victory.",
        category = "Combat",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 5,
        chatCommand = "/victory",
    },
    ["defeat"] = {
        id = "defeat",
        name = "Defeat",
        description = "Show your defeat.",
        category = "Combat",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 3,
        chatCommand = "/defeat",
    },
    
    -- === MAGIC EMOTES ===
    ["cast_fire"] = {
        id = "cast_fire",
        name = "Fire Cast",
        description = "Cast a fire spell (visual only).",
        category = "Magic",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 3,
        requiredClass = "Mage",
        effects = {"fire_particles"},
        chatCommand = "/castfire",
    },
    ["cast_ice"] = {
        id = "cast_ice",
        name = "Ice Cast",
        description = "Cast an ice spell (visual only).",
        category = "Magic",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 3,
        requiredClass = "Mage",
        effects = {"ice_particles"},
        chatCommand = "/castice",
    },
    ["heal"] = {
        id = "heal",
        name = "Heal",
        description = "Channel healing energy.",
        category = "Magic",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 5,
        requiredClass = "Priest",
        effects = {"heal_particles"},
        chatCommand = "/heal",
    },
    ["pray"] = {
        id = "pray",
        name = "Pray",
        description = "Pray to the gods.",
        category = "Magic",
        animationId = "rbxassetid://507770000",
        duration = 5,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        effects = {"holy_glow"},
        chatCommand = "/pray",
    },
    ["meditate"] = {
        id = "meditate",
        name = "Meditate",
        description = "Meditate to focus your energy.",
        category = "Magic",
        animationId = "rbxassetid://507770000",
        duration = 10,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        effects = {"meditation_aura"},
        chatCommand = "/meditate",
    },
    
    -- === SOCIAL EMOTES ===
    ["cheer"] = {
        id = "cheer",
        name = "Cheer",
        description = "Cheer enthusiastically.",
        category = "Social",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 2,
        chatCommand = "/cheer",
    },
    ["clap"] = {
        id = "clap",
        name = "Clap",
        description = "Clap your hands.",
        category = "Social",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 2,
        chatCommand = "/clap",
    },
    ["laugh"] = {
        id = "laugh",
        name = "Laugh",
        description = "Laugh heartily.",
        category = "Social",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 2,
        chatCommand = "/laugh",
    },
    ["cry"] = {
        id = "cry",
        name = "Cry",
        description = "Cry in sadness.",
        category = "Social",
        animationId = "rbxassetid://507770000",
        duration = 4,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 3,
        chatCommand = "/cry",
    },
    ["hug"] = {
        id = "hug",
        name = "Hug",
        description = "Hug someone.",
        category = "Social",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 5,
        chatCommand = "/hug",
    },
    
    -- === DANCE EMOTES ===
    ["dance"] = {
        id = "dance",
        name = "Dance",
        description = "Dance joyfully.",
        category = "Dance",
        animationId = "rbxassetid://507771000", -- dance animation
        duration = 5,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/dance",
    },
    ["dance2"] = {
        id = "dance2",
        name = "Dance 2",
        description = "Another dance.",
        category = "Dance",
        animationId = "rbxassetid://507772000",
        duration = 5,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/dance2",
    },
    
    -- === GESTURE EMOTES ===
    ["point"] = {
        id = "point",
        name = "Point",
        description = "Point with your finger.",
        category = "Gesture",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 1,
        chatCommand = "/point",
    },
    ["nod"] = {
        id = "nod",
        name = "Nod",
        description = "Nod in agreement.",
        category = "Gesture",
        animationId = "rbxassetid://507770000",
        duration = 1,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 1,
        chatCommand = "/nod",
    },
    ["shake_head"] = {
        id = "shake_head",
        name = "Shake Head",
        description = "Shake your head in refusal.",
        category = "Gesture",
        animationId = "rbxassetid://507770000",
        duration = 1,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 1,
        chatCommand = "/no",
    },
    ["shrug"] = {
        id = "shrug",
        name = "Shrug",
        description = "Shrug your shoulders.",
        category = "Gesture",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 1,
        chatCommand = "/shrug",
    },
    ["think"] = {
        id = "think",
        name = "Think",
        description = "Show that you are thinking.",
        category = "Gesture",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 1,
        chatCommand = "/think",
    },
    
    -- === REACTION EMOTES ===
    ["sneeze"] = {
        id = "sneeze",
        name = "Sneeze",
        description = "Sneeze.",
        category = "Reaction",
        animationId = "rbxassetid://507770000",
        duration = 1,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 5,
        chatCommand = "/sneeze",
    },
    ["cough"] = {
        id = "cough",
        name = "Cough",
        description = "Cough.",
        category = "Reaction",
        animationId = "rbxassetid://507770000",
        duration = 1,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 3,
        chatCommand = "/cough",
    },
    ["yawn"] = {
        id = "yawn",
        name = "Yawn",
        description = "Yawn.",
        category = "Reaction",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = true,
        cooldown = 5,
        chatCommand = "/yawn",
    },
    ["stretch"] = {
        id = "stretch",
        name = "Stretch",
        description = "Stretch yourself.",
        category = "Reaction",
        animationId = "rbxassetid://507770000",
        duration = 2,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 3,
        chatCommand = "/stretch",
    },
    
    -- === ROLEPLAY EMOTES ===
    ["kneel"] = {
        id = "kneel",
        name = "Kneel",
        description = "Kneel on one knee.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 10,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/kneel",
    },
    ["sit"] = {
        id = "sit",
        name = "Sit",
        description = "Sit on the ground.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 60,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/sit",
    },
    ["sleep"] = {
        id = "sleep",
        name = "Sleep",
        description = "Lie down to sleep.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 60,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/sleep",
    },
    ["inspect"] = {
        id = "inspect",
        name = "Inspect",
        description = "Inspect something carefully.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/inspect",
    },
    ["write"] = {
        id = "write",
        name = "Write",
        description = "Write on a parchment.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 5,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/write",
    },
    ["read"] = {
        id = "read",
        name = "Read",
        description = "Read a book or parchment.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 5,
        looped = true,
        canMoveWhilePlaying = false,
        cooldown = 1,
        chatCommand = "/read",
    },
    ["drink"] = {
        id = "drink",
        name = "Drink",
        description = "Drink a beverage.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 3,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 2,
        chatCommand = "/drink",
    },
    ["eat"] = {
        id = "eat",
        name = "Eat",
        description = "Eat something.",
        category = "Roleplay",
        animationId = "rbxassetid://507770000",
        duration = 4,
        looped = false,
        canMoveWhilePlaying = false,
        cooldown = 2,
        chatCommand = "/eat",
    },
}

-- Player emote state tracking
local playerEmoteStates: {[number]: {
    currentEmote: string?,
    startTime: number,
    animationTrack: any,
}} = {}

-- Player cooldowns
local playerCooldowns: {[number]: {[string]: number}} = {}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function getPlayerCooldowns(playerId: number): {[string]: number}
    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = {}
    end
    return playerCooldowns[playerId]
end

local function isOnCooldown(playerId: number, emoteId: string): boolean
    local cooldowns = getPlayerCooldowns(playerId)
    local emote = EMOTE_DEFINITIONS[emoteId]
    if not emote then
        return false
    end
    
    local cooldownEnd = cooldowns[emoteId]
    if cooldownEnd and os.time() < cooldownEnd then
        return true
    end
    
    return false
end

local function setCooldown(playerId: number, emoteId: string, duration: number)
    local cooldowns = getPlayerCooldowns(playerId)
    cooldowns[emoteId] = os.time() + duration
end

-- ============================================
-- PUBLIC API
-- ============================================

local EmoteSystem = {}

-- Get emote definition
function EmoteSystem.getEmote(emoteId: string): EmoteDefinition?
    return EMOTE_DEFINITIONS[emoteId]
end

-- Get all emotes
function EmoteSystem.getAllEmotes(): {[string]: EmoteDefinition}
    return EMOTE_DEFINITIONS
end

-- Get emotes by category
function EmoteSystem.getEmotesByCategory(category: EmoteCategory): {EmoteDefinition}
    local emotes = {}
    for _, emote in pairs(EMOTE_DEFINITIONS) do
        if emote.category == category then
            table.insert(emotes, emote)
        end
    end
    return emotes
end

-- Get emotes available to player (considering class/faction requirements)
function EmoteSystem.getAvailableEmotes(playerClass: string?, playerFaction: string?): {EmoteDefinition}
    local available = {}
    for _, emote in pairs(EMOTE_DEFINITIONS) do
        local canUse = true
        
        -- Check class requirement
        if emote.requiredClass and emote.requiredClass ~= playerClass then
            canUse = false
        end
        
        -- Check faction requirement
        if emote.requiredFaction and emote.requiredFaction ~= playerFaction then
            canUse = false
        end
        
        if canUse then
            table.insert(available, emote)
        end
    end
    return available
end

-- Check if player can use emote
function EmoteSystem.canUseEmote(playerId: number, emoteId: string, playerClass: string?, playerFaction: string?): (boolean, string?)
    local emote = EMOTE_DEFINITIONS[emoteId]
    if not emote then
        return false, "Emote not found"
    end
    
    -- Check cooldown
    if isOnCooldown(playerId, emoteId) then
        return false, "On cooldown"
    end
    
    -- Check class requirement
    if emote.requiredClass and emote.requiredClass ~= playerClass then
        return false, "Requires class: " .. emote.requiredClass
    end
    
    -- Check faction requirement
    if emote.requiredFaction and emote.requiredFaction ~= playerFaction then
        return false, "Requires faction: " .. emote.requiredFaction
    end
    
    return true, nil
end

-- Play emote (returns animation info for client to play)
function EmoteSystem.playEmote(playerId: number, emoteId: string): any
    local emote = EMOTE_DEFINITIONS[emoteId]
    if not emote then
        return nil
    end
    
    -- Set cooldown
    setCooldown(playerId, emoteId, emote.cooldown)
    
    -- Track emote state
    playerEmoteStates[playerId] = {
        currentEmote = emoteId,
        startTime = os.time(),
        animationTrack = nil, -- Will be set by client
    }
    
    return {
        emote = emote,
        animationId = emote.animationId,
        duration = emote.duration,
        looped = emote.looped,
    }
end

-- Stop emote
function EmoteSystem.stopEmote(playerId: number): boolean
    local state = playerEmoteStates[playerId]
    if not state or not state.currentEmote then
        return false
    end
    
    playerEmoteStates[playerId] = {
        currentEmote = nil,
        startTime = 0,
        animationTrack = nil,
    }
    
    return true
end

-- Get player's current emote
function EmoteSystem.getCurrentEmote(playerId: number): string?
    local state = playerEmoteStates[playerId]
    if not state then
        return nil
    end
    
    -- Check if emote has expired
    local emote = EMOTE_DEFINITIONS[state.currentEmote or ""]
    if emote and not emote.looped then
        if os.time() - state.startTime > emote.duration then
            playerEmoteStates[playerId] = {
                currentEmote = nil,
                startTime = 0,
                animationTrack = nil,
            }
            return nil
        end
    end
    
    return state.currentEmote
end

-- Parse chat command to find emote
function EmoteSystem.parseChatCommand(message: string): string?
    -- Check if message starts with /
    if not message:sub(1, 1) == "/" then
        return nil
    end
    
    -- Find matching emote command
    for emoteId, emote in pairs(EMOTE_DEFINITIONS) do
        if message:lower() == emote.chatCommand:lower() then
            return emoteId
        end
    end
    
    return nil
end

-- Get emote info for display
function EmoteSystem.getEmoteInfo(emoteId: string): any
    local emote = EMOTE_DEFINITIONS[emoteId]
    if not emote then
        return nil
    end
    
    return {
        id = emote.id,
        name = emote.name,
        description = emote.description,
        category = emote.category,
        chatCommand = emote.chatCommand,
        duration = emote.duration,
        looped = emote.looped,
    }
end

-- Get all emote categories
function EmoteSystem.getCategories(): {EmoteCategory}
    return {
        "Greeting",
        "Combat",
        "Magic",
        "Social",
        "Dance",
        "Gesture",
        "Reaction",
        "Roleplay",
    }
end

return EmoteSystem
