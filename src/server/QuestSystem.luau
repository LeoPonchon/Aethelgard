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
        name = "Escorte Marchand",
        description = "Escortez un marchand jusqu'au village voisin.",
        questType = "Escort",
        difficulty = 1,
        factionRequired = nil, -- Anyone can take
        objectives = {
            {objectiveId = "meet_merchant", description = "Rencontrer le marchand", type = "TalkToNPC", target = "Merchant_NPC", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "escort_to_village", description = "Escorter jusqu'au village", type = "ReachLocation", target = "Village_Outskirts", currentProgress = 0, requiredProgress = 1, completed = false},
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
        name = "Exploration de la Forêt",
        description = "Explorez la forêt mystérieuse et découvrez ses secrets.",
        questType = "Explore",
        difficulty = 1,
        objectives = {
            {objectiveId = "enter_forest", description = "Entrer dans la forêt", type = "VisitLocation", target = "Mystic_Forest", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "find_glade", description = "Trouver la clairière", type = "VisitLocation", target = "Forest_Glade", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "return_report", description = "Retourner faire rapport", type = "TalkToNPC", target = "Guild_Master", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 40,
            reputation = 8,
        },
    },
    
    ["defeat_wolves_1"] = {
        questId = "defeat_wolves_1",
        name = "Loups Garous",
        description = "Éliminez les loups qui menacent le village.",
        questType = "Defeat",
        difficulty = 2,
        objectives = {
            {objectiveId = "find_wolves", description = "Trouver les loups", type = "VisitLocation", target = "Wolf_Den", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "defeat_wolves", description = "Vaincre les loups", type = "DefeatEnemy", target = "Wolf", currentProgress = 0, requiredProgress = 5, completed = false},
            {objectiveId = "return_village", description = "Retourner au village", type = "TalkToNPC", target = "Village_Elder", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
            experience = 80,
            reputation = 15,
            factionReputation = {["Commoners"] = 10},
        },
    },
    
    -- === NOBLESSE QUESTS ===
    ["diplomacy_elves_1"] = {
    	questId = "diplomacy_elves_1",
    	name = "Diplomatie Elfique",
    	description = "Portez un message aux Elfes pour établir des relations diplomatiques.",
    	questType = "Diplomacy",
    	difficulty = 2,
    	factionRequired = "Noblesse",
        objectives = {
            {objectiveId = "get_message", description = "Recevoir le message", type = "TalkToNPC", target = "Noble_Envoy", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "travel_elves", description = "Voyager vers les Elfes", type = "VisitLocation", target = "Elven_Forest", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "deliver_message", description = "Livrer le message", type = "TalkToNPC", target = "Elven_Elder", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "return_response", description = "Retourner avec la réponse", type = "TalkToNPC", target = "Noble_Envoy", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 100,
        	reputation = 20,
        	factionReputation = {["Noblesse"] = 15, ["Elves Faction"] = 10},
        },
       },
      
       ["defend_castle_1"] = {
        questId = "defend_castle_1",
        name = "Défense du Château",
        description = "Défendez le château contre une attaque imminente.",
        questType = "Defend",
        difficulty = 3,
        factionRequired = "Noblesse",
        objectives = {
        	{objectiveId = "report_castle", description = "Se présenter au château", type = "VisitLocation", target = "Castle_Gates", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defend_duration", description = "Défendre pendant 5 minutes", type = "DefendLocation", target = "Castle", currentProgress = 0, requiredProgress = 300, completed = false},
        	{objectiveId = "report_success", description = "Rapporter le succès", type = "TalkToNPC", target = "Castle_Captain", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 150,
        	reputation = 30,
        	factionReputation = {["Noblesse"] = 25},
        },
        timeLimit = 900, -- 15 minutes
       },
      
       -- === DÉMONS QUESTS ===
       ["corrupt_shrine_1"] = {
        questId = "corrupt_shrine_1",
        name = "Corruption du Sanctuaire",
        description = "Corrompez un sanctuaire sacré pour affaiblir les forces du bien.",
        questType = "Corrupt",
        difficulty = 3,
        factionRequired = "Démons",
        objectives = {
        	{objectiveId = "find_shrine", description = "Trouver le sanctuaire", type = "VisitLocation", target = "Sacred_Shrine", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defenders", description = "Éliminer les défenseurs", type = "DefeatEnemy", target = "Temple_Guard", currentProgress = 0, requiredProgress = 3, completed = false},
        	{objectiveId = "corrupt_ritual", description = "Effectuer le rituel", type = "Meditate", target = "Sacred_Shrine", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "return_portal", description = "Retourner au portail", type = "VisitLocation", target = "Demon_Portal", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 200,
        	reputation = 40,
        	factionReputation = {["Démons"] = 30},
        },
       },
      
       ["assassinate_noble_1"] = {
        questId = "assassinate_noble_1",
        name = "Assassinat Noble",
        description = "Éliminez un noble cible pour semer le chaos.",
        questType = "Assassinate",
        difficulty = 4,
        factionRequired = "Démons",
        factionReputation = 50,
        objectives = {
        	{objectiveId = "infiltrate", description = "Infiltrer le château", type = "VisitLocation", target = "Castle_Interior", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "locate_target", description = "Localiser la cible", type = "TalkToNPC", target = "Target_Noble", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "eliminate", description = "Éliminer la cible", type = "DefeatEnemy", target = "Target_Noble", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "escape", description = "S'échapper", type = "VisitLocation", target = "Demon_Portal", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 300,
        	reputation = 60,
        	factionReputation = {["Démons"] = 50},
        },
        timeLimit = 600,
       },
      
       -- === ACADÉMIE QUESTS ===
       ["train_magic_1"] = {
        questId = "train_magic_1",
        name = "Entraînement Magique",
        description = "Complétez votre entraînement magique de base à l'académie.",
        questType = "Train",
        difficulty = 1,
        factionRequired = "Académie",
        objectives = {
        	{objectiveId = "enter_academy", description = "Entrer à l'académie", type = "VisitLocation", target = "Academy", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "practice_spells", description = "Pratiquer les sorts", type = "CastSpell", target = "Training_Dummy", currentProgress = 0, requiredProgress = 10, completed = false},
        	{objectiveId = "pass_test", description = "Réussir le test", type = "TalkToNPC", target = "Academy_Professor", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 60,
        	reputation = 12,
        	factionReputation = {["Académie"] = 20},
        	unlocks = {"Mage"},
        },
       },
      
       ["train_combat_1"] = {
        questId = "train_combat_1",
        name = "Entraînement au Combat",
        description = "Complétez votre entraînement au combat de base.",
        questType = "Train",
        difficulty = 1,
        factionRequired = "Académie",
        objectives = {
        	{objectiveId = "enter_arena", description = "Entrer dans l'arène", type = "VisitLocation", target = "Training_Arena", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "practice_melee", description = "Pratiquer le combat", type = "MeleeAttack", target = "Training_Dummy", currentProgress = 0, requiredProgress = 20, completed = false},
        	{objectiveId = "pass_test", description = "Réussir le test", type = "TalkToNPC", target = "Combat_Instructor", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 60,
        	reputation = 12,
        	factionReputation = {["Académie"] = 20},
        	unlocks = {"Guerrier"},
        },
       },
      
       -- === SPECIAL QUESTS ===
       ["purify_corruption_1"] = {
        questId = "purify_corruption_1",
        name = "Purification",
        description = "Purifiez une zone corrompue par les démons.",
        questType = "Purify",
        difficulty = 4,
        factionRequired = "Monarchie",
        objectives = {
        	{objectiveId = "find_corruption", description = "Trouver la zone corrompue", type = "VisitLocation", target = "Corrupted_Zone", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "defeat_demons", description = "Vaincre les démons", type = "DefeatEnemy", target = "Demon", currentProgress = 0, requiredProgress = 5, completed = false},
        	{objectiveId = "purify_ritual", description = "Effectuer le rituel de purification", type = "Pray", target = "Corrupted_Zone", currentProgress = 0, requiredProgress = 1, completed = false},
        	{objectiveId = "report_temple", description = "Rapporter au temple", type = "TalkToNPC", target = "High_Priest", currentProgress = 0, requiredProgress = 1, completed = false},
        },
        rewards = {
        	experience = 250,
        	reputation = 50,
        	factionReputation = {["Monarchie"] = 40},
        },
       },
    
    ["rescue_prisoner_1"] = {
        questId = "rescue_prisoner_1",
        name = "Rescue Prisoner",
        description = "Sauvez un prisonnier retenu dans les donjons.",
        questType = "Rescue",
        difficulty = 3,
        objectives = {
            {objectiveId = "find_dungeon", description = "Trouver le donjon", type = "VisitLocation", target = "Dungeon_Entrance", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "defeat_guards", description = "Vaincre les gardes", type = "DefeatEnemy", target = "Dungeon_Guard", currentProgress = 0, requiredProgress = 3, completed = false},
            {objectiveId = "find_prisoner", description = "Trouver le prisonnier", type = "TalkToNPC", target = "Prisoner_NPC", currentProgress = 0, requiredProgress = 1, completed = false},
            {objectiveId = "escort_out", description = "Escorter dehors", type = "ReachLocation", target = "Dungeon_Exit", currentProgress = 0, requiredProgress = 1, completed = false},
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
        description = "Interagissez avec d'autres membres de la guilde.",
        questType = "Socialize",
        difficulty = 1,
        objectives = {
            {objectiveId = "talk_members", description = "Parler à 5 membres", type = "Socialize", target = "Guild_Member", currentProgress = 0, requiredProgress = 5, completed = false},
            {objectiveId = "join_activity", description = "Participer à une activité", type = "JoinEvent", target = "Guild_Activity", currentProgress = 0, requiredProgress = 1, completed = false},
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

local function getCompletedQuests(playerId: number): {string}
    if not completedQuests[playerId] then
        completedQuests[playerId] = {}
    end
    return completedQuests[playerId]
end

local function hasCompletedQuest(playerId: number, questId: string): boolean
    for _, completedId in ipairs(getCompletedQuests(playerId)) do
        if completedId == questId then
            return true
        end
    end
    return false
end

local function hasPrerequisiteQuests(playerId: number, prerequisites: {string}?): boolean
    if not prerequisites then
        return true
    end
    
    for _, prereqId in ipairs(prerequisites) do
        if not hasCompletedQuest(playerId, prereqId) then
            return false
        end
    end
    return true
end

local function cloneObjectives(objectives: {QuestObjective}): {QuestObjective}
    local cloned = {}
    for _, obj in ipairs(objectives) do
        table.insert(cloned, {
            objectiveId = obj.objectiveId,
            description = obj.description,
            type = obj.type,
            target = obj.target,
            currentProgress = 0,
            requiredProgress = obj.requiredProgress,
            completed = false,
        })
    end
    return cloned
end

-- ============================================
-- PUBLIC API
-- ============================================

local QuestSystem = {}

-- Get available quests for a player
function QuestSystem.getAvailableQuests(playerId: number, faction: string?): {Quest}
	local available = {}
	local progression = ActionBasedProgressionSystem.getProgression(playerId)
	local teamData = ActionBasedProgressionSystem.getTeamData()

	for questId, quest in pairs(QUEST_DEFINITIONS) do
		-- Skip if already completed (unless repeatable)
		if not hasCompletedQuest(playerId, questId) then
			-- Check faction requirement (now checks team category)
			local meetsFactionReq = true
			if quest.factionRequired then
				meetsFactionReq = false
				-- Check if player has any team in the required category
				for _, factionProgress in ipairs(progression.factions) do
					local teamInfo = teamData[factionProgress.factionId]
					if teamInfo and teamInfo.category == quest.factionRequired then
						meetsFactionReq = true
						break
					end
				end
			end

			if meetsFactionReq then
				-- Check prerequisite quests
				if hasPrerequisiteQuests(playerId, quest.prerequisites) then
					-- Check faction reputation if required
					if quest.factionReputation then
						local hasReputation = false
						for _, factionProgress in ipairs(progression.factions) do
							local teamInfo = teamData[factionProgress.factionId]
							if teamInfo and teamInfo.category == quest.factionRequired then
								if factionProgress.reputation >= quest.factionReputation then
									hasReputation = true
								end
								break
							end
						end
						if not hasReputation then
							continue
						end
					end
					table.insert(available, quest)
				end
			end
		end
	end

	return available
end

-- Accept a quest
function QuestSystem.acceptQuest(playerId: number, questId: string): boolean
    local quest = QUEST_DEFINITIONS[questId]
    if not quest then
        return false
    end
    
    local playerQuests = getPlayerActiveQuests(playerId)
    
    -- Check if already on this quest
    if playerQuests[questId] then
        return false
    end
    
    -- Create active quest
    local activeQuest: ActiveQuest = {
        questId = questId,
        playerId = playerId,
        status = "InProgress",
        startTime = os.time(),
        endTime = quest.timeLimit and (os.time() + quest.timeLimit) or nil,
        objectives = cloneObjectives(quest.objectives),
        escortTarget = nil,
        escortStart = nil,
        escortEnd = nil,
        involvedPlayers = nil,
    }
    
    playerQuests[questId] = activeQuest
    
    -- Record action for progression
    ActionBasedProgressionSystem.recordAction(playerId, {
        actionType = "JoinEvent",
        target = questId,
        value = quest.difficulty * 10,
    })
    
    return true
end

-- Update quest objective progress
function QuestSystem.updateObjective(playerId: number, objectiveType: string, target: string, amount: number): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local questCompleted = false
    local completedQuestId = nil
    
    for questId, activeQuest in pairs(playerQuests) do
        if activeQuest.status == "InProgress" then
            -- Check time limit
            if activeQuest.endTime and os.time() > activeQuest.endTime then
                activeQuest.status = "Failed"
            else
                -- Update matching objectives
                for _, objective in ipairs(activeQuest.objectives) do
                    if not objective.completed and objective.type == objectiveType then
                        -- Check if target matches (or no target specified)
                        if not objective.target or objective.target == target then
                            objective.currentProgress = math.min(
                                objective.currentProgress + amount,
                                objective.requiredProgress
                            )
                            
                            if objective.currentProgress >= objective.requiredProgress then
                                objective.completed = true
                            end
                        end
                    end
                end
                
                -- Check if all objectives completed
                local allCompleted = true
                for _, objective in ipairs(activeQuest.objectives) do
                    if not objective.completed then
                        allCompleted = false
                        break
                    end
                end
                
                if allCompleted then
                    activeQuest.status = "Completed"
                    questCompleted = true
                    completedQuestId = questId
                end
            end
        end
    end
    
    -- Handle quest completion
    if questCompleted and completedQuestId then
        QuestSystem.completeQuest(playerId, completedQuestId)
    end
    
    return questCompleted
end

-- Complete a quest
function QuestSystem.completeQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest or activeQuest.status ~= "Completed" then
        return false
    end
    
    local quest = QUEST_DEFINITIONS[questId]
    if not quest then
        return false
    end
    
    -- Add to completed quests
    table.insert(getCompletedQuests(playerId), questId)
    
    -- Grant rewards through progression system
    ActionBasedProgressionSystem.completeQuest(playerId, quest.difficulty)
    
    -- Record specific action
    ActionBasedProgressionSystem.recordAction(playerId, {
        actionType = "CompleteQuest",
        target = questId,
        value = quest.rewards.experience,
    })
    
    -- Remove from active quests
    playerQuests[questId] = nil
    
    return true
end

-- Abandon a quest
function QuestSystem.abandonQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    
    if not playerQuests[questId] then
        return false
    end
    
    playerQuests[questId].status = "Abandoned"
    playerQuests[questId] = nil
    
    return true
end

-- Get player's active quests
function QuestSystem.getPlayerQuests(playerId: number): {ActiveQuest}
    local quests = {}
    for _, activeQuest in pairs(getPlayerActiveQuests(playerId)) do
        table.insert(quests, activeQuest)
    end
    return quests
end

-- Get quest definition
function QuestSystem.getQuestDefinition(questId: string): Quest?
    return QUEST_DEFINITIONS[questId]
end

-- Check if player is on a specific quest
function QuestSystem.isOnQuest(playerId: number, questId: string): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    return playerQuests[questId] ~= nil and playerQuests[questId].status == "InProgress"
end

-- Get quest progress for display
function QuestSystem.getQuestProgress(playerId: number, questId: string): any?
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest then
        return nil
    end
    
    local quest = QUEST_DEFINITIONS[questId]
    local objectives = {}
    local completedCount = 0
    
    for _, obj in ipairs(activeQuest.objectives) do
        table.insert(objectives, {
            description = obj.description,
            progress = obj.currentProgress,
            required = obj.requiredProgress,
            completed = obj.completed,
        })
        if obj.completed then
            completedCount = completedCount + 1
        end
    end
    
    return {
        name = quest.name,
        description = quest.description,
        objectives = objectives,
        progress = completedCount / #activeQuest.objectives,
        timeRemaining = activeQuest.endTime and math.max(0, activeQuest.endTime - os.time()) or nil,
    }
end

-- Setup escort quest (for when a player accepts being escorted)
function QuestSystem.setupEscortQuest(playerId: number, questId: string, targetPlayerId: number, startPos: Vector3, endPos: Vector3): boolean
    local playerQuests = getPlayerActiveQuests(playerId)
    local activeQuest = playerQuests[questId]
    
    if not activeQuest then
        return false
    end
    
    activeQuest.escortTarget = Players:GetNameFromUserIdAsync(targetPlayerId)
    activeQuest.escortStart = startPos
    activeQuest.escortEnd = endPos
    
    return true
end

-- Get all quest definitions (for admin/debug)
function QuestSystem.getAllQuestDefinitions(): {[string]: Quest}
    return QUEST_DEFINITIONS
end

return QuestSystem
