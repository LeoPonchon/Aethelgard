--!nonstrict
-- Action-Based Progression System for Aethelgard
-- Core system that handles progression through in-game actions
-- Players change teams, classes, and ranks by doing things, not by UI selection

local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type ActionType = 
    "VisitLocation" | 
    "TalkToNPC" | 
    "CompleteQuest" | 
    "DefeatEnemy" |
    "EscortPlayer" |
    "CraftItem" |
    "CastSpell" |
    "MeleeAttack" |
    "DefendLocation" |
    "JoinEvent" |
    "BetrayFaction" |
    "Diplomacy" |
    "TrainAtAcademy" |
    "Meditate" |
    "Pray" |
    "Explore" |
    "Socialize"

export type ProgressionAction = {
    actionType: ActionType,
    target: string?, -- NPC name, location name, faction name, etc.
    value: number?, -- Optional value (damage dealt, quest difficulty, etc.)
    metadata: {[string]: any}?, -- Additional context
}

export type FactionProgress = {
    factionId: string,
    reputation: number,
    rank: string,
    joinedAt: number,
    contributions: number,
}

export type ClassProgress = {
    classId: string,
    experience: number,
    level: number,
    unlockedAbilities: {string},
    trainedAt: string?, -- Academy location where trained
}

export type GuildRank = {
    rankId: string,
    rankName: string,
    experience: number,
    questsCompleted: number,
    questsRequired: number,
}

export type PlayerProgression = {
    playerId: number,
    
    -- Faction progress (can be part of multiple factions with different reputations)
    factions: {FactionProgress},
    primaryFaction: string?, -- Main faction the player identifies with
    
    -- Class progress (can unlock multiple classes through academy)
    classes: {ClassProgress},
    activeClass: string?, -- Currently active class
    
    -- Guild progress
    guildRank: GuildRank,
    
    -- Overall progression
    totalActions: number,
    playtimeSeconds: number,
    
    -- Track specific action counts for unlocking
    actionCounts: {[string]: number},
    
    -- Last progression events (for UI feedback on billboard)
    lastProgression: string?,
    lastProgressionTime: number,
}

-- ============================================
-- TEAM DEFINITIONS (EXACT TEAMS REQUESTED)
-- ============================================

-- Team data organized by category - EXACTLY as requested
local TEAM_DATA = {
    -- MONARCHIE
    ["King"] = {
        id = "King",
        name = "Roi",
        category = "Monarchie",
        description = "Souverain du royaume d'Aethelgard",
        color = Color3.fromRGB(255, 215, 0), -- Gold
        emoji = "👑",
        slots = 1,
        joinActions = {}, -- Special: admin only or special event
        special = true,
    },
    ["Queen"] = {
        id = "Queen",
        name = "Reine",
        category = "Monarchie",
        description = "Souveraine du royaume d'Aethelgard",
        color = Color3.fromRGB(255, 182, 193), -- Light pink
        emoji = "👸",
        slots = 1,
        joinActions = {}, -- Special: admin only or special event
        special = true,
    },
    ["Princes"] = {
        id = "Princes",
        name = "Princes",
        category = "Monarchie",
        description = "Héritiers du trône royal",
        color = Color3.fromRGB(70, 130, 180), -- Steel blue
        emoji = "👦",
        slots = 4,
        joinActions = {}, -- Special: appointed by King/Queen
        special = true,
    },
    ["Princesses"] = {
        id = "Princesses",
        name = "Princesses",
        category = "Monarchie",
        description = "Héritières du trône royal",
        color = Color3.fromRGB(255, 105, 180), -- Hot pink
        emoji = "👧",
        slots = 4,
        joinActions = {}, -- Special: appointed by King/Queen
        special = true,
    },
    
    -- NOBLESSE
    ["Dukes"] = {
        id = "Dukes",
        name = "Ducs",
        category = "Noblesse",
        description = "Nobles de haut rang, gestionnaires de régions",
        color = Color3.fromRGB(128, 0, 128), -- Purple
        emoji = "🏰",
        slots = 5,
        joinActions = {
            {action = "Diplomacy", count = 15},
            {action = "CompleteQuest", count = 10},
            {action = "DefendLocation", count = 5},
        },
    },
    ["Counts"] = {
        id = "Counts",
        name = "Comtes",
        category = "Noblesse",
        description = "Nobles gestionnaires de territoires",
        color = Color3.fromRGB(148, 0, 211), -- Dark violet
        emoji = "⚔️",
        slots = 10,
        joinActions = {
            {action = "Diplomacy", count = 10},
            {action = "CompleteQuest", count = 5},
        },
    },
    ["Minor Houses"] = {
        id = "Minor Houses",
        name = "Maisons Mineures",
        category = "Noblesse",
        description = "Petite noblesse et vassaux",
        color = Color3.fromRGB(186, 85, 211), -- Medium orchid
        emoji = "🛡️",
        slots = 20,
        joinActions = {
            {action = "Diplomacy", count = 5},
            {action = "CompleteQuest", count = 3},
        },
    },
    
    -- DÉMONS
    ["Demon King"] = {
        id = "Demon King",
        name = "Roi Démon",
        category = "Démons",
        description = "Souverain des forces démoniaques",
        color = Color3.fromRGB(139, 0, 0), -- Dark red
        emoji = "😈",
        slots = 1,
        joinActions = {}, -- Special: admin only or special event
        special = true,
    },
    ["Demon Queen"] = {
        id = "Demon Queen",
        name = "Reine Démon",
        category = "Démons",
        description = "Souveraine des forces démoniaques",
        color = Color3.fromRGB(178, 34, 34), -- Firebrick
        emoji = "👹",
        slots = 1,
        joinActions = {}, -- Special: admin only or special event
        special = true,
    },
    ["Demon Generals"] = {
        id = "Demon Generals",
        name = "Généraux Démons",
        category = "Démons",
        description = "Commandants des armées démoniaques",
        color = Color3.fromRGB(220, 20, 60), -- Crimson
        emoji = "👿",
        slots = 10,
        joinActions = {
            {action = "VisitLocation", count = 1, target = "Demon Portal"},
            {action = "Meditate", count = 10, target = "Demon Portal"},
            {action = "CompleteQuest", count = 5},
        },
    },
    ["Demon Servants"] = {
        id = "Demon Servants",
        name = "Serviteurs Démons",
        category = "Démons",
        description = "Serviteurs des forces démoniaques",
        color = Color3.fromRGB(255, 69, 0), -- Red orange
        emoji = "💀",
        slots = -1, -- Unlimited
        joinActions = {
            {action = "VisitLocation", count = 1, target = "Demon Portal"},
            {action = "Meditate", count = 3, target = "Demon Portal"},
        },
    },
    
    -- ACADÉMIE
    ["Academy Externals"] = {
        id = "Academy Externals",
        name = "Externes",
        category = "Académie",
        description = "Étudiants externes de l'Académie",
        color = Color3.fromRGB(192, 192, 192), -- Silver
        emoji = "🌍",
        slots = -1, -- Unlimited
        joinActions = {
            {action = "VisitLocation", count = 1, target = "Academy"},
        },
    },
    ["Academy Professors"] = {
        id = "Academy Professors",
        name = "Professeurs",
        category = "Académie",
        description = "Enseignants de l'Académie",
        color = Color3.fromRGB(255, 255, 255), -- White
        emoji = "📚",
        slots = -1,
        joinActions = {
            {action = "TrainAtAcademy", count = 30},
            {action = "CompleteQuest", count = 20},
        },
    },
    ["Academy Year 1"] = {
        id = "Academy Year 1",
        name = "1ère Année",
        category = "Académie",
        description = "Étudiants de première année",
        color = Color3.fromRGB(173, 216, 230), -- Light blue
        emoji = "🎒",
        slots = -1,
        joinActions = {
            {action = "VisitLocation", count = 1, target = "Academy"},
            {action = "TalkToNPC", count = 1, target = "Academy Headmaster"},
        },
    },
    ["Academy Year 2"] = {
        id = "Academy Year 2",
        name = "2ème Année",
        category = "Académie",
        description = "Étudiants de deuxième année",
        color = Color3.fromRGB(135, 206, 235), -- Sky blue
        emoji = "📖",
        slots = -1,
        joinActions = {
            {action = "TrainAtAcademy", count = 10},
            {action = "CompleteQuest", count = 5},
        },
        requiresTeam = "Academy Year 1",
    },
    ["Academy Year 3"] = {
    	id = "Academy Year 3",
    	name = "3ème Année",
    	category = "Académie",
    	description = "Étudiants avancés",
    	color = Color3.fromRGB(0, 191, 255), -- Deep sky blue
    	emoji = "🎓",
    	slots = -1,
    	joinActions = {
    		{action = "TrainAtAcademy", count = 25},
    		{action = "CompleteQuest", count = 15},
    	},
    	requiresTeam = "Academy Year 2",
    },
    
    -- HÉROS & SAINTS
    ["Hero"] = {
        id = "Hero",
        name = "Héros",
        category = "Héros & Saints",
        description = "Héros légendaire du royaume",
        color = Color3.fromRGB(255, 215, 0), -- Gold
        emoji = "⚡",
        slots = 1,
        joinActions = {}, -- Special: appointed or special quest
        special = true,
    },
    ["Saint"] = {
        id = "Saint",
        name = "Saint",
        category = "Héros & Saints",
        description = "Saint protecteur du royaume",
        color = Color3.fromRGB(255, 255, 224), -- Light yellow
        emoji = "✨",
        slots = 1,
        joinActions = {}, -- Special: appointed or special quest
        special = true,
    },
    
    -- AUTRES GROUPES
    ["Elves Faction"] = {
        id = "Elves Faction",
        name = "Elfes",
        category = "Autres groupes",
        description = "Le peuple ancien des forêts",
        color = Color3.fromRGB(34, 139, 34), -- Forest green
        emoji = "🧝",
        slots = -1,
        joinActions = {
            {action = "VisitLocation", count = 1, target = "Elven Forest"},
            {action = "Meditate", count = 5, target = "Sacred Tree"},
        },
    },
    ["Event Teams"] = {
        id = "Event Teams",
        name = "Événements",
        category = "Autres groupes",
        description = "Équipes temporaires pour événements",
        color = Color3.fromRGB(75, 0, 130), -- Indigo
        emoji = "🎭",
        slots = 0, -- Locked, event only
        joinActions = {},
        special = true,
    },
    ["Free Lineages"] = {
        id = "Free Lineages",
        name = "Lignées Libres",
        category = "Autres groupes",
        description = "Mercenaires et aventuriers indépendants",
        color = Color3.fromRGB(128, 128, 128), -- Gray
        emoji = "🗡️",
        slots = -1,
        joinActions = {
            {action = "CompleteQuest", count = 5},
        },
    },
    ["Commoners"] = {
        id = "Commoners",
        name = "Roturiers",
        category = "Autres groupes",
        description = "Citoyens libres du royaume",
        color = Color3.fromRGB(100, 149, 237), -- Cornflower blue
        emoji = "👤",
        slots = -1,
        joinActions = {}, -- Default team
        default = true,
    },
}

-- Team categories for organization
local TEAM_CATEGORIES = {
	{name = "Monarchie", teams = {"King", "Queen", "Princes", "Princesses"}},
	{name = "Noblesse", teams = {"Dukes", "Counts", "Minor Houses"}},
	{name = "Démons", teams = {"Demon King", "Demon Queen", "Demon Generals", "Demon Servants"}},
	{name = "Académie", teams = {"Academy Externals", "Academy Professors", "Academy Year 1", "Academy Year 2", "Academy Year 3"}},
	{name = "Héros & Saints", teams = {"Hero", "Saint"}},
	{name = "Autres groupes", teams = {"Elves Faction", "Event Teams", "Free Lineages", "Commoners"}},
}

-- Class definitions with unlock requirements
local CLASS_DATA = {
    ["Guerrier"] = {
        id = "Guerrier",
        name = "Guerrier",
        description = "Combattant au corps à corps",
        emoji = "⚔️",
        unlockActions = {
            {action = "MeleeAttack", count = 50},
            {action = "TrainAtAcademy", count = 5},
        },
        abilities = {"Power Strike", "Shield Block", "Battle Cry"},
    },
    ["Mage"] = {
        id = "Mage",
        name = "Mage",
        description = "Maître des arts magiques",
        emoji = "🔮",
        unlockActions = {
            {action = "CastSpell", count = 30},
            {action = "TrainAtAcademy", count = 10},
            {action = "Meditate", count = 5},
        },
        abilities = {"Fireball", "Ice Shard", "Teleport"},
    },
    ["Voleur"] = {
        id = "Voleur",
        name = "Voleur",
        description = "Expert en discrétion",
        emoji = "🗡️",
        unlockActions = {
            {action = "Explore", count = 20},
            {action = "TrainAtAcademy", count = 5},
        },
        abilities = {"Backstab", "Stealth", "Pick Lock"},
    },
    ["Archer"] = {
        id = "Archer",
        name = "Archer",
        description = "Tireur d'élite",
        emoji = "🏹",
        unlockActions = {
            {action = "DefeatEnemy", count = 30, metadata = {weapon = "bow"}},
            {action = "TrainAtAcademy", count = 5},
        },
        abilities = {"Precise Shot", "Multi-Shot", "Trap"},
    },
    ["Prêtre"] = {
        id = "Prêtre",
        name = "Prêtre",
        description = "Serviteur des dieux",
        emoji = "✨",
        unlockActions = {
            {action = "Pray", count = 20},
            {action = "TrainAtAcademy", count = 10},
        },
        abilities = {"Heal", "Blessing", "Resurrect"},
    },
    ["Paladin"] = {
        id = "Paladin",
        name = "Paladin",
        description = "Guerrier sacré",
        emoji = "⚜️",
        unlockActions = {
            {action = "MeleeAttack", count = 30},
            {action = "Pray", count = 15},
            {action = "TrainAtAcademy", count = 15},
        },
        abilities = {"Holy Strike", "Divine Shield", "Lay on Hands"},
        requiresClasses = {"Guerrier", "Prêtre"},
    },
    ["Nécromancien"] = {
        id = "Nécromancien",
        name = "Nécromancien",
        description = "Maître des morts",
        emoji = "💀",
        unlockActions = {
            {action = "CastSpell", count = 50},
            {action = "VisitLocation", count = 1, target = "Demon Portal"},
            {action = "Meditate", count = 10, target = "Demon Portal"},
        },
        abilities = {"Raise Dead", "Drain Life", "Curse"},
        special = true,
    },
    ["Barde"] = {
        id = "Barde",
        name = "Barde",
        description = "Artiste et diplomate",
        emoji = "🎵",
        unlockActions = {
            {action = "Socialize", count = 50},
            {action = "TrainAtAcademy", count = 5},
        },
        abilities = {"Inspiring Song", "Charm", "Disguise"},
    },
    ["Druide"] = {
        id = "Druide",
        name = "Druide",
        description = "Harmonie avec la nature",
        emoji = "🌿",
        unlockActions = {
            {action = "Meditate", count = 20, target = "Nature"},
            {action = "VisitLocation", count = 1, target = "Elven Forest"},
            {action = "TrainAtAcademy", count = 10},
        },
        abilities = {"Wild Shape", "Nature's Blessing", "Entangle"},
    },
    ["Chevalier"] = {
        id = "Chevalier",
        name = "Chevalier",
        description = "Guerrier blindé",
        emoji = "🛡️",
        unlockActions = {
            {action = "DefendLocation", count = 10},
            {action = "MeleeAttack", count = 40},
            {action = "TrainAtAcademy", count = 10},
        },
        abilities = {"Shield Wall", "Taunt", "Last Stand"},
    },
    ["Invocateur"] = {
        id = "Invocateur",
        name = "Invocateur",
        description = "Maître des invocations",
        emoji = "👁️",
        unlockActions = {
            {action = "CastSpell", count = 60},
            {action = "Meditate", count = 15},
            {action = "TrainAtAcademy", count = 20},
        },
        abilities = {"Summon Elemental", "Bind Demon", "Planar Gate"},
    },
    ["Moine"] = {
        id = "Moine",
        name = "Moine",
        description = "Maître des arts martiaux",
        emoji = "🥋",
        unlockActions = {
            {action = "MeleeAttack", count = 100},
            {action = "Meditate", count = 30},
        },
        abilities = {"Flurry of Blows", "Iron Skin", "Quivering Palm"},
    },
}

-- Guild rank definitions
local GUILD_RANKS = {
    {rankId = "recruit", rankName = "Recrue", questsRequired = 0, experienceRequired = 0},
    {rankId = "novice", rankName = "Novice", questsRequired = 5, experienceRequired = 100},
    {rankId = "apprentice", rankName = "Apprenti", questsRequired = 15, experienceRequired = 300},
    {rankId = "journeyman", rankName = "Compagnon", questsRequired = 30, experienceRequired = 700},
    {rankId = "expert", rankName = "Expert", questsRequired = 50, experienceRequired = 1500},
    {rankId = "master", rankName = "Maître", questsRequired = 80, experienceRequired = 3000},
    {rankId = "grandmaster", rankName = "Grand Maître", questsRequired = 120, experienceRequired = 6000},
}

-- Player progression storage
local playerProgressions: {[number]: PlayerProgression} = {}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function getPlayerProgression(playerId: number): PlayerProgression
    if not playerProgressions[playerId] then
        playerProgressions[playerId] = {
            playerId = playerId,
            factions = {},
            primaryFaction = nil,
            classes = {},
            activeClass = nil,
            guildRank = {
                rankId = "recruit",
                rankName = "Recrue",
                experience = 0,
                questsCompleted = 0,
                questsRequired = 0,
            },
            totalActions = 0,
            playtimeSeconds = 0,
            actionCounts = {},
            lastProgression = nil,
            lastProgressionTime = 0,
        }
    end
    return playerProgressions[playerId]
end

local function incrementActionCount(progression: PlayerProgression, actionType: string, count: number)
    progression.actionCounts[actionType] = (progression.actionCounts[actionType] or 0) + count
    progression.totalActions = progression.totalActions + count
end

local function checkActionRequirements(progression: PlayerProgression, requirements: {any}): boolean
    for _, req in ipairs(requirements) do
        local actionCount = progression.actionCounts[req.action] or 0
        if actionCount < req.count then
            return false
        end
        -- Check target if specified
        if req.target then
            local targetKey = req.action .. "_" .. req.target
            if (progression.actionCounts[targetKey] or 0) < req.count then
                return false
            end
        end
    end
    return true
end

-- ============================================
-- PROGRESSION CHECKS
-- ============================================

local function checkTeamUnlocks(progression: PlayerProgression): {string}
    local unlockedTeams = {}
    
    for teamId, teamData in pairs(TEAM_DATA) do
        -- Skip if already in team
        local alreadyJoined = false
        for _, faction in ipairs(progression.factions) do
            if faction.factionId == teamId then
                alreadyJoined = true
                break
            end
        end
        
        if not alreadyJoined and not teamData.special then
            -- Check prerequisite team if required
            if teamData.requiresTeam then
                local hasPrereq = false
                for _, faction in ipairs(progression.factions) do
                    if faction.factionId == teamData.requiresTeam then
                        hasPrereq = true
                        break
                    end
                end
                if not hasPrereq then
                    continue
                end
            end
            
            if checkActionRequirements(progression, teamData.joinActions) then
                table.insert(unlockedTeams, teamId)
            end
        end
    end
    
    return unlockedTeams
end

local function checkClassUnlocks(progression: PlayerProgression): {string}
    local unlockedClasses = {}
    
    for classId, classData in pairs(CLASS_DATA) do
        -- Skip if already unlocked
        local alreadyUnlocked = false
        for _, classProgress in ipairs(progression.classes) do
            if classProgress.classId == classId then
                alreadyUnlocked = true
                break
            end
        end
        
        if not alreadyUnlocked then
            -- Check prerequisite classes
            local hasPrerequisites = true
            if classData.requiresClasses then
                for _, requiredClass in ipairs(classData.requiresClasses) do
                    local hasClass = false
                    for _, classProgress in ipairs(progression.classes) do
                        if classProgress.classId == requiredClass then
                            hasClass = true
                            break
                        end
                    end
                    if not hasClass then
                        hasPrerequisites = false
                        break
                    end
                end
            end
            
            if hasPrerequisites and checkActionRequirements(progression, classData.unlockActions) then
                if not classData.special then
                    table.insert(unlockedClasses, classId)
                end
            end
        end
    end
    
    return unlockedClasses
end

local function checkGuildRankUp(progression: PlayerProgression): boolean
    local currentRank = progression.guildRank
    local currentRankIndex = 1
    for i, rank in ipairs(GUILD_RANKS) do
        if rank.rankId == currentRank.rankId then
            currentRankIndex = i
            break
        end
    end
    
    -- Check if can rank up
    if currentRankIndex < #GUILD_RANKS then
        local nextRank = GUILD_RANKS[currentRankIndex + 1]
        if currentRank.questsCompleted >= nextRank.questsRequired and 
           currentRank.experience >= nextRank.experienceRequired then
            return true
        end
    end
    
    return false
end

-- ============================================
-- PUBLIC API
-- ============================================

local ActionBasedProgressionSystem = {}

-- Get player's current progression
function ActionBasedProgressionSystem.getProgression(playerId: number): PlayerProgression
    return getPlayerProgression(playerId)
end

-- Get all team data
function ActionBasedProgressionSystem.getTeamData(): any
    return TEAM_DATA
end

-- Get team categories
function ActionBasedProgressionSystem.getTeamCategories(): any
    return TEAM_CATEGORIES
end

-- Get team info
function ActionBasedProgressionSystem.getTeamInfo(teamId: string): any
    return TEAM_DATA[teamId]
end

-- Record an action and check for progression
function ActionBasedProgressionSystem.recordAction(playerId: number, action: ProgressionAction): {string}
    local progression = getPlayerProgression(playerId)
    local events = {}
    
    -- Increment base action count
    incrementActionCount(progression, action.actionType, 1)
    
    -- Increment target-specific count if target specified
    if action.target then
        local targetKey = action.actionType .. "_" .. action.target
        incrementActionCount(progression, targetKey, 1)
    end
    
    -- Add experience to guild rank
    local expGain = action.value or 10
    progression.guildRank.experience = progression.guildRank.experience + expGain
    
    -- Check for team unlocks
    local unlockedTeams = checkTeamUnlocks(progression)
    for _, teamId in ipairs(unlockedTeams) do
        table.insert(events, "TEAM_UNLOCKED:" .. teamId)
        progression.lastProgression = "Unlocked team: " .. TEAM_DATA[teamId].name
        progression.lastProgressionTime = os.time()
    end
    
    -- Check for class unlocks
    local unlockedClasses = checkClassUnlocks(progression)
    for _, classId in ipairs(unlockedClasses) do
        table.insert(events, "CLASS_UNLOCKED:" .. classId)
        progression.lastProgression = "Unlocked class: " .. CLASS_DATA[classId].name
        progression.lastProgressionTime = os.time()
    end
    
    -- Check for guild rank up
    if checkGuildRankUp(progression) then
        local currentRankIndex = 1
        for i, rank in ipairs(GUILD_RANKS) do
            if rank.rankId == progression.guildRank.rankId then
                currentRankIndex = i
                break
            end
        end
        
        if currentRankIndex < #GUILD_RANKS then
            local nextRank = GUILD_RANKS[currentRankIndex + 1]
            progression.guildRank.rankId = nextRank.rankId
            progression.guildRank.rankName = nextRank.rankName
            progression.guildRank.questsRequired = nextRank.questsRequired
            table.insert(events, "GUILD_RANK_UP:" .. nextRank.rankId)
            progression.lastProgression = "Guild rank up: " .. nextRank.rankName
            progression.lastProgressionTime = os.time()
        end
    end
    
    return events
end

-- Join a team (after unlocking)
function ActionBasedProgressionSystem.joinTeam(playerId: number, teamId: string): boolean
    local progression = getPlayerProgression(playerId)
    local teamData = TEAM_DATA[teamId]
    
    if not teamData then
        return false
    end
    
    -- Check if already in team
    for _, faction in ipairs(progression.factions) do
        if faction.factionId == teamId then
            return false
        end
    end
    
    -- Check if requirements met (unless default or special)
    if not teamData.default and not teamData.special then
        if not checkActionRequirements(progression, teamData.joinActions) then
            return false
        end
    end
    
    -- Check prerequisite team if required
    if teamData.requiresTeam then
        local hasPrereq = false
        for _, faction in ipairs(progression.factions) do
            if faction.factionId == teamData.requiresTeam then
                hasPrereq = true
                break
            end
        end
        if not hasPrereq then
            return false
        end
    end
    
    -- Join team
    table.insert(progression.factions, {
        factionId = teamId,
        reputation = 0,
        rank = teamData.category or "Member",
        joinedAt = os.time(),
        contributions = 0,
    })
    
    -- Set as primary if first team or default
    if not progression.primaryFaction or teamData.default then
        progression.primaryFaction = teamId
    end
    
    return true
end

-- Unlock a class (after meeting requirements)
function ActionBasedProgressionSystem.unlockClass(playerId: number, classId: string): boolean
    local progression = getPlayerProgression(playerId)
    local classData = CLASS_DATA[classId]
    
    if not classData then
        return false
    end
    
    -- Check if already unlocked
    for _, classProgress in ipairs(progression.classes) do
        if classProgress.classId == classId then
            return false
        end
    end
    
    -- Check if requirements met
    if not checkActionRequirements(progression, classData.unlockActions) then
        return false
    end
    
    -- Check prerequisite classes
    if classData.requiresClasses then
        for _, requiredClass in ipairs(classData.requiresClasses) do
            local hasClass = false
            for _, classProgress in ipairs(progression.classes) do
                if classProgress.classId == requiredClass then
                    hasClass = true
                    break
                end
            end
            if not hasClass then
                return false
            end
        end
    end
    
    -- Unlock class
    table.insert(progression.classes, {
        classId = classId,
        experience = 0,
        level = 1,
        unlockedAbilities = {},
        trainedAt = nil,
    })
    
    -- Set as active if first class
    if not progression.activeClass then
        progression.activeClass = classId
    end
    
    return true
end

-- Set active class
function ActionBasedProgressionSystem.setActiveClass(playerId: number, classId: string): boolean
    local progression = getPlayerProgression(playerId)
    
    -- Check if class is unlocked
    for _, classProgress in ipairs(progression.classes) do
        if classProgress.classId == classId then
            progression.activeClass = classId
            return true
        end
    end
    
    return false
end

-- Set primary team
function ActionBasedProgressionSystem.setPrimaryTeam(playerId: number, teamId: string): boolean
    local progression = getPlayerProgression(playerId)
    
    -- Check if team is joined
    for _, faction in ipairs(progression.factions) do
        if faction.factionId == teamId then
            progression.primaryFaction = teamId
            return true
        end
    end
    
    return false
end

-- Add quest completion
function ActionBasedProgressionSystem.completeQuest(playerId: number, questDifficulty: number): boolean
    local progression = getPlayerProgression(playerId)
    progression.guildRank.questsCompleted = progression.guildRank.questsCompleted + 1
    
    -- Record the action
    return #ActionBasedProgressionSystem.recordAction(playerId, {
        actionType = "CompleteQuest",
        value = questDifficulty * 20,
    }) > 0
end

-- Get class data
function ActionBasedProgressionSystem.getClassData(classId: string): any
    return CLASS_DATA[classId]
end

-- Get all classes
function ActionBasedProgressionSystem.getAllClasses(): {[string]: any}
    return CLASS_DATA
end

-- Get guild ranks
function ActionBasedProgressionSystem.getGuildRanks(): any
    return GUILD_RANKS
end

-- Get player's display info for billboard
function ActionBasedProgressionSystem.getDisplayInfo(playerId: number): any
    local progression = getPlayerProgression(playerId)
    
    local primaryTeamData = progression.primaryFaction and TEAM_DATA[progression.primaryFaction]
    local activeClassData = progression.activeClass and CLASS_DATA[progression.activeClass]
    
    return {
        team = progression.primaryFaction or "Commoners",
        teamName = primaryTeamData and primaryTeamData.name or "Roturiers",
        teamCategory = primaryTeamData and primaryTeamData.category or "Autres groupes",
        teamEmoji = primaryTeamData and primaryTeamData.emoji or "👤",
        class = progression.activeClass or "None",
        className = activeClassData and activeClassData.name or "Sans Classe",
        classEmoji = activeClassData and activeClassData.emoji or "❓",
        guildRank = progression.guildRank.rankName,
        lastProgression = progression.lastProgression,
        totalActions = progression.totalActions,
    }
end

-- Get default team
function ActionBasedProgressionSystem.getDefaultTeam(): string
    return "Commoners"
end

-- Clear player data (for debugging/reset)
function ActionBasedProgressionSystem.clearPlayerData(playerId: number)
    playerProgressions[playerId] = nil
end

return ActionBasedProgressionSystem
