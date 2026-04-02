--!nonstrict
-- Quest System for Aethelgard
-- Handles guild quests that are RP-based: escort players, combat, exploration, diplomacy
-- Quests are accepted from NPCs and completed through in-game actions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionBasedProgressionSystem = require(ReplicatedStorage.Shared:WaitForChild("ActionBasedProgressionSystem"))

export type QuestType = 
    "Escort" |        -- Escort a player from point A to B
    "Defeat" |        -- Defeat enemies in a location
    "Explore" |       -- Explore a location
    "Diplomacy" |     -- Talk to an NPC from another faction
    "Defend" |        -- Defend a location for a duration
    "Gather" |        -- Gather items in a location
    "Deliver" |       -- Deliver an item to an NPC
    "Investigate" |   -- Investigate a mystery location
    "Rescue" |        -- Rescue an NPC or player
    "Assassinate" |   -- Eliminate a target (demon faction)
    "Corrupt" |       -- Corrupt a location (demon faction)
    "Purify" |        -- Purify a corrupted location (hero/saint)
    "Train" |         -- Complete training at academy
    "Socialize"       -- Interact with other players

export type QuestStatus = 
    "Available" | 
    "InProgress" | 
    "Completed" | 
    "Failed" | 
    "Abandoned"

export type QuestObjective = {
    objectiveId: string,
    description: string,
    type: string,
    target: string?, -- NPC name, location, player name, etc.
    currentProgress: number,
    requiredProgress: number,
    completed: boolean,
}

export type Quest = {
    questId: string,
    name: string,
    description: string,
    questType: QuestType,
    difficulty: number, -- 1-5, affects rewards
    factionRequired: string?, -- Faction required to take quest
    factionReputation: number?, -- Minimum reputation with faction
    objectives: {QuestObjective},
    rewards: {
        experience: number,
        reputation: number,
        factionReputation: {[string]: number}?,
        unlocks: {string}?,
    },
    timeLimit: number?, -- Seconds, nil = no limit
    playerLevel: number?, -- Minimum player level
    prerequisites: {string}?, -- Quest IDs that must be completed first
}

export type ActiveQuest = {
    questId: string,
    playerId: number,
    status: QuestStatus,
    startTime: number,
    endTime: number?,
    objectives: {QuestObjective},
    escortTarget: string?, -- Player being escorted (for Escort quests)
    escortStart: Vector3?,
    escortEnd: Vector3?,
    involvedPlayers: {string}?, -- Other players involved in quest
}

-- Quest definitions
local QUEST_DEFINITIONS: {[string]: Quest} = {
    -- === COMMONER GUILD QUESTS ===
    ["escort_merchant_1"] = {
        questId = "escort_merchant_1",
        name = "Merchant Escort",
        description = "Escort a merchant to the neighboring village.",
        questType = "Escort",
        difficulty = 1,
        factionRequired = nil, -- Anyone can take
        objectives = {
            {objectiveId = "meet_merchant", description = "Meet the merchant", type = "TalkToNPC", target = "Merchant_NPC", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "escort_to_village", description = "Escort to the village", type = "ReachLocation", target = "Village_Outskirts", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 50,
            reputation = 10,
            factionReputation = {["Commoners"] = 5},
        },
        timeLimit = 600, -- 10 minutes
    },
    
    ["explore_forest_1"] = {
        questId = "explore_forest_1",
        name = "Forest Exploration",
        description = "Explore the mysterious forest and discover its secrets.",
        questType = "Explore",
        difficulty = 1,
        objectives = {
            {objectiveId = "enter_forest", description = "Enter the forest", type = "VisitLocation", target = "Mystic_Forest", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "find_glade", description = "Find the glade", type = "VisitLocation", target = "Forest_Glade", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "return_report", description = "Return to report", type = "TalkToNPC", target = "Guild_Master", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 40,
            reputation = 8,
        },
    },
    
    ["defeat_wolves_1"] = {
        questId = "defeat_wolves_1",
        name = "Wolf Hunt",
        description = "Eliminate the wolves threatening the village.",
        questType = "Defeat",
        difficulty = 2,
        objectives = {
            {objectiveId = "find_wolves", description = "Find the wolves", type = "VisitLocation", target = "Wolf_Den", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "defeat_wolves", description = "Defeat the wolves", type = "DefeatEnemy", target = "Wolf", currentProgress = 0, requiredProgress = 5, completed = false},
            {objectiveId = "return_village", description = "Return to village", type = "TalkToNPC", target = "Village_Elder", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 80,
            reputation = 15,
            factionReputation = {["Commoners"] = 10},
        },
    },
    
    -- === NOBILITY QUESTS ===
    ["diplomacy_elves_1"] = {
    	questId = "diplomacy_elves_1",
    	name = "Elven Diplomacy",
    	description = "Carry a message to the Elves to establish diplomatic relations.",
    	questType = "Diplomacy",
    	difficulty = 2,
    	factionRequired = "Nobility",
        objectives = {
            {objectiveId = "get_message", description = "Receive the message", type = "TalkToNPC", target = "Noble_Envoy", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "travel_elves", description = "Travel to the Elves", type = "VisitLocation", target = "Elven_Forest", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "deliver_message", description = "Deliver the message", type = "TalkToNPC", target = "Elven_Elder", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "return_response", description = "Return with the response", type = "TalkToNPC", target = "Noble_Envoy", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 100,
        	reputation = 20,
        	factionReputation = {["Nobility"] = 15, ["Elves Faction"] = 10},
        },
       },
       
       ["defend_castle_1"] = {
        questId = "defend_castle_1",
        name = "Castle Defense",
        description = "Defend the castle against an imminent attack.",
        questType = "Defend",
        difficulty = 3,
        factionRequired = "Nobility",
        objectives = {
        	{objectiveId = "report_castle", description = "Report to the castle", type = "VisitLocation", target = "Castle_Gates", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defend_duration", description = "Defend for 5 minutes", type = "DefendLocation", target = "Castle", currentProgress = 0, requiredProgress = 300, completed = false},
        	{objectiveId = "report_success", description = "Report success", type = "TalkToNPC", target = "Castle_Captain", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 150,
        	reputation = 30,
        	factionReputation = {["Nobility"] = 25},
        },
        timeLimit = 900, -- 15 minutes
       },
       
       -- === DEMON QUESTS ===
       ["corrupt_shrine_1"] = {
        questId = "corrupt_shrine_1",
        name = "Shrine Corruption",
        description = "Corrupt a sacred shrine to weaken the forces of good.",
        questType = "Corrupt",
        difficulty = 3,
        factionRequired = "Demons",
        objectives = {
        	{objectiveId = "find_shrine", description = "Find the shrine", type = "VisitLocation", target = "Sacred_Shrine", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defenders", description = "Eliminate the defenders", type = "DefeatEnemy", target = "Temple_Guard", currentProgress = 0, requiredProgress = 3, completed = false},
        	{objectiveId = "corrupt_ritual", description = "Perform the ritual", type = "Meditate", target = "Sacred_Shrine", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "return_portal", description = "Return to the portal", type = "VisitLocation", target = "Demon_Portal", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 200,
        	reputation = 40,
        	factionReputation = {["Demons"] = 30},
        },
       },
       
       ["assassinate_noble_1"] = {
        questId = "assassinate_noble_1",
        name = "Noble Assassination",
        description = "Eliminate a target noble to sow chaos.",
        questType = "Assassinate",
        difficulty = 4,
        factionRequired = "Demons",
        factionReputation = 50,
        objectives = {
        	{objectiveId = "infiltrate", description = "Infiltrate the castle", type = "VisitLocation", target = "Castle_Interior", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "locate_target", description = "Locate the target", type = "TalkToNPC", target = "Target_Noble", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "eliminate", description = "Eliminate the target", type = "DefeatEnemy", target = "Target_Noble", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "escape", description = "Escape", type = "VisitLocation", target = "Demon_Portal", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 300,
        	reputation = 60,
        	factionReputation = {["Demons"] = 50},
        },
        timeLimit = 600,
       },
       
       -- === ACADEMY QUESTS ===
       ["train_magic_1"] = {
        questId = "train_magic_1",
        name = "Magic Training",
        description = "Complete your basic magical training at the academy.",
        questType = "Train",
        difficulty = 1,
        factionRequired = "Academy",
        objectives = {
        	{objectiveId = "enter_academy", description = "Enter the academy", type = "VisitLocation", target = "Academy", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "practice_spells", description = "Practice spells", type = "CastSpell", target = "Training_Dummy", currentProgress = 0, requiredProgress = 10, completed = false},
        	{objectiveId = "pass_test", description = "Pass the test", type = "TalkToNPC", target = "Academy_Professor", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 60,
        	reputation = 12,
        	factionReputation = {["Academy"] = 20},
        	unlocks = {"Mage"},
        },
       },
       
       ["train_combat_1"] = {
        questId = "train_combat_1",
        name = "Combat Training",
        description = "Complete your basic combat training.",
        questType = "Train",
        difficulty = 1,
        factionRequired = "Academy",
        objectives = {
        	{objectiveId = "enter_arena", description = "Enter the arena", type = "VisitLocation", target = "Training_Arena", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "practice_melee", description = "Practice combat", type = "MeleeAttack", target = "Training_Dummy", currentProgress = 0, requiredProgress = 20, completed = false},
        	{objectiveId = "pass_test", description = "Pass the test", type = "TalkToNPC", target = "Combat_Instructor", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 60,
        	reputation = 12,
        	factionReputation = {["Academy"] = 20},
        	unlocks = {"Warrior"},
        },
       },
       
       -- === SPECIAL QUESTS ===
       ["purify_corruption_1"] = {
        questId = "purify_corruption_1",
        name = "Purification",
        description = "Purify a zone corrupted by demons.",
        questType = "Purify",
        difficulty = 4,
        factionRequired = "Monarchy",
        objectives = {
        	{objectiveId = "find_corruption", description = "Find the corrupted zone", type = "VisitLocation", target = "Corrupted_Zone", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defeat_demons", description = "Defeat the demons", type = "DefeatEnemy", target = "Demon", currentProgress = 0, requiredProgress = 5, completed = false},
        	{objectiveId = "purify_ritual", description = "Perform the purification ritual", type = "Pray", target = "Corrupted_Zone", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "report_temple", description = "Report to the temple", type = "TalkToNPC", target = "High_Priest", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 250,
        	reputation = 50,
        	factionReputation = {["Monarchy"] = 40},
        },
        },
    
    ["rescue_prisoner_1"] = {
        questId = "rescue_prisoner_1",
        name = "Rescue Prisoner",
        description = "Save a prisoner held in the dungeons.",
        questType = "Rescue",
        difficulty = 3,
        objectives = {
            {objectiveId = "find_dungeon", description = "Find the dungeon", type = "VisitLocation", target = "Dungeon_Entrance", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "defeat_guards", description = "Defeat the guards", type = "DefeatEnemy", target = "Dungeon_Guard", currentProgress = 0, requiredProgress = 3, completed = false},
            {objectiveId = "find_prisoner", description = "Find the prisoner", type = "TalkToNPC", target = "Prisoner_NPC", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "escort_out", description = "Escort out", type = "ReachLocation", target = "Dungeon_Exit", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 150,
            reputation = 30,
        },
    },
    
    -- === SOCIAL QUESTS ===
    ["socialize_guild_1"] = {
        questId = "socialize_guild_1",
        name = "Networking",
        description = "Interact with other guild members.",
        questType = "Socialize",
        difficulty = 1,
        objectives = {
            {objectiveId = "talk_members", description = "Talk to 5 members", type = "Socialize", target = "Guild_Member", currentProgress = 0, requiredProgress = 5, completed = false},
            {objectiveId = "join_activity", description = "Join an activity", type = "JoinEvent", target = "Guild_Activity", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 30,
            reputation = 5,
        },
    },
}

-- Active quests storage
local activeQuests: {[number]: {[string]: ActiveQuest}} = {} -- playerId -> {questId -> ActiveQuest}
local completedQuests: {[number]: {string}} = {} -- playerId -> {questId}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function getPlayerActiveQuests(playerId: number): {[string]: ActiveQuest}
    if not activeQuests[playerId] then
        activeQuests[playerId] = {}
    end
    return activeQuests[playerId]
end

local function getPlayerCompletedQuests(playerId: number): {string}
    if not completedQuests[playerId] then
        completedQuests[playerId] = {}
    end
    return completedQuests[playerId]
end

local function canTakeQuest(playerId: number, quest: Quest): boolean
    local playerQuests = getPlayerCompletedQuests(playerId)
    
    -- Check prerequisites
    if quest.prerequisites then
        for _, prereqId in ipairs(quest.prerequisites) do
            local hasPrereq = false
            for _, completedId in ipairs(playerQuests) do
                if completedId == prereqId then
                    hasPrereq = true
                    break
                end
            end
            if not hasPrereq then
                return false
            end
        end
    end
    
    -- Check player level
    if quest.playerLevel then
        local progression = ActionBasedProgressionSystem.getProgression(playerId)
        if (progression.totalActions or 0) < quest.playerLevel then
            return false
        end
    end
    
    -- Check faction requirements
    if quest.factionRequired then
        local progression = ActionBasedProgressionSystem.getProgression(playerId)
        local hasFaction = false
        for _, faction in ipairs(progression.factions) do
            if faction.factionId == quest.factionRequired then
                hasFaction = true
                break
            end
        end
        if not hasFaction then
            return false
        end
    end
    
    return true
end

local function updateQuestProgress(playerId: number, actionType: string, target: string?, value: number)
    local playerQuests = getPlayerActiveQuests(playerId)
    local updated = false
    
    for questId, activeQuest in pairs(playerQuests) do
        if activeQuest.status == "InProgress" then
            for _, objective in ipairs(activeQuest.objectives) do
                if not objective.completed then
                    local matches = false
                    
                    -- Check if this action matches the objective
                    if objective.type == actionType then
                        if objective.target then
                            if target and string.find(target, objective.target) then
                                matches = true
                            end
                        else
                            matches = true
                        end
                    end
                    
                    if matches then
                        objective.currentProgress = objective.currentProgress + (value or 1)
                        if objective.currentProgress >= objective.requiredProgress then
                            objective.currentProgress = objective.requiredProgress
                            objective.completed = true
                        end
                        updated = true
                    end
                end
            end
        end
    end
    
    return updated
end

local function checkQuestCompletion(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest then
        return false
    end
    
    for _, objective in ipairs(activeQuest.objectives) do
        if not objective.completed then
            return false
        end
    end
    
    return true
end

-- ============================================
-- PUBLIC API
-- ============================================

local QuestSystem = {}

-- Get quest definition
function QuestSystem.getQuestDefinition(questId: string): Quest?
    return QUEST_DEFINITIONS[questId]
end

-- Get all quest definitions
function QuestSystem.getAllQuestDefinitions(): {[string]: Quest}
    return QUEST_DEFINITIONS
end

-- Get available quests for player
function QuestSystem.getAvailableQuests(playerId: number, faction: string?): {Quest}
    local available = {}
    
    for questId, quest in pairs(QUEST_DEFINITIONS) do
        -- Check if already completed
        local playerCompleted = getPlayerCompletedQuests(playerId)
        local alreadyCompleted = false
        for _, completedId in ipairs(playerCompleted) do
            if completedId == questId then
                alreadyCompleted = true
                break
            end
        end
        if alreadyCompleted then continue end
        
        -- Check if already active
        local playerQuests = getPlayerActiveQuests(playerId)
        if playerQuests[questId] then continue end
        
        -- Check requirements
        if not canTakeQuest(playerId, quest) then continue end
        
        -- Check faction filter
        if faction and quest.factionRequired then
            if quest.factionRequired ~= faction then
                continue
            end
        end
        
        table.insert(available, quest)
    end
    
    return available
end

-- Accept a quest
function QuestSystem.acceptQuest(playerId: number, questId: string): boolean
    local quest = QUEST_DEFINITIONS[questId]
    if not quest then
        return false
    end
    
    if not canTakeQuest(playerId, quest) then
        return false
    end
    
    local playerQuests = getPlayerActiveQuests(playerId)
    if playerQuests[questId] then
        return false -- Already active
    end
    
    -- Create active quest
    local activeQuest: ActiveQuest = {
        questId = questId,
        playerId = playerId,
        status = "InProgress",
        startTime = os.time(),
        objectives = {},
    }
    
    -- Copy objectives
    for _, obj in ipairs(quest.objectives) do
        table.insert(activeQuest.objectives, {
            objectiveId = obj.objectiveId,
            description = obj.description,
            type = obj.type,
            target = obj.target,
            currentProgress = 0,
            requiredProgress = obj.requiredProgress,
            completed = false,
        })
    end
    
    playerQuests[questId] = activeQuest
    
    return true
end

-- Check if player is on a quest
function QuestSystem.isOnQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    return playerQuests[questId] ~= nil
end

-- Get player's active quests
function QuestSystem.getPlayerQuests(playerId: number): {ActiveQuest}
    local playerQuests = getPlayerActiveQuests(playerId)
    local quests = {}
    
    for _, quest in pairs(playerQuests) do
        table.insert(quests, quest)
    end
    
    return quests
end

-- Get quest progress for a specific quest
function QuestSystem.getQuestProgress(playerId: number, questId: string): ActiveQuest?
    local playerQuests = getPlayerActiveQuests(playerId)
    return playerQuests[questId]
end

-- Update quest objective (called from action system)
function QuestSystem.updateObjective(playerId: number, actionType: string, target: string?, value: number)
    updateQuestProgress(playerId, actionType, target, value)
    
    -- Check for quest completion
    local playerQuests = getPlayerActiveQuests(playerId)
    for questId, activeQuest in pairs(playerQuests) do
        if activeQuest.status == "InProgress" then
            if checkQuestCompletion(playerId, questId) then
                QuestSystem.completeQuest(playerId, questId)
            end
        end
    end
end

-- Complete a quest
function QuestSystem.completeQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest then
        return false
    end
    
    local quest = QUEST_DEFINITIONS[questId]
    if not quest then
        return false
    end
    
    -- Mark as completed
    activeQuest.status = "Completed"
    activeQuest.endTime = os.time()
    
    -- Give rewards
    local progression = ActionBasedProgressionSystem.getProgression(playerId)
    
    -- Add experience
    progression.guildRank.experience = progression.guildRank.experience + quest.rewards.experience
    
    -- Add reputation
    progression.reputation = (progression.reputation or 0) + quest.rewards.reputation
    
    -- Add faction reputation
    if quest.rewards.factionReputation then
        for factionId, rep in pairs(quest.rewards.factionReputation) do
            for _, faction in ipairs(progression.factions) do
                if faction.factionId == factionId then
                    faction.reputation = faction.reputation + rep
                    break
                end
            end
        end
    end
    
    -- Track completed quest
    local playerCompleted = getPlayerCompletedQuests(playerId)
    table.insert(playerCompleted, questId)
    
    -- Check for unlocks
    if quest.rewards.unlocks then
        for _, classId in ipairs(quest.rewards.unlocks) do
            local classData = quest.rewards.unlocks[classId]
            if classData then
                local hasClass = false
                for _, c in ipairs(progression.classes) do
                    if c.classId == classId then
                        hasClass = true
                        break
                    end
                end
                if not hasClass then
                    table.insert(progression.classes, {
                        classId = classId,
                        unlocked = true,
                        experience = 0,
                    })
                end
            end
        end
    end
    
    -- Increment quests completed
    progression.guildRank.questsCompleted = progression.guildRank.questsCompleted + 1
    
    return true
end

-- Abandon a quest
function QuestSystem.abandonQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest then
        return false
    end
    
    activeQuest.status = "Abandoned"
    activeQuest.endTime = os.time()
    
    return true
end

-- Get quests by faction
function QuestSystem.getQuestsByFaction(faction: string): {Quest}
    local quests = {}
    
    for questId, quest in pairs(QUEST_DEFINITIONS) do
        if quest.factionRequired == faction then
            table.insert(quests, quest)
        end
    end
    
    return quests
end

return QuestSystem