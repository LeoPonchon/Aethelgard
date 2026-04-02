--!nonstrict
-- NPC Interaction System for Aethelgard
-- Handles NPC interactions that drive progression through dialogue and actions
-- NPCs provide quests, training, faction joining, and guidance

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ActionBasedProgressionSystem = require(ReplicatedStorage.Shared:WaitForChild("ActionBasedProgressionSystem"))
local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))

export type NPCType = 
    "VillageElder" | 
    "GuildMaster" | 
    "AcademyHeadmaster" | 
    "AcademyProfessor" |
    "CombatInstructor" |
    "MagicInstructor" |
    "NobleEnvoy" |
    "CastleCaptain" |
    "DemonPortalKeeper" |
    "ElvenElder" |
    "HighPriest" |
    "Merchant" |
    "Blacksmith" |
    "Innkeeper" |
    "QuestGiver" |
    "Trainer"

export type NPCDialogue = {
    id: string,
    text: string,
    responses: {NPCDialogueResponse}?,
    action: string?, -- Action to trigger when this dialogue is shown
    condition: (player: Player) -> boolean?,
}

export type NPCDialogueResponse = {
    text: string,
    nextDialogue: string?, -- ID of next dialogue
    action: string?, -- Action to perform
    requirement: string?, -- Requirement check
}

export type NPCDefinition = {
    id: string,
    name: string,
    title: string,
    npcType: NPCType,
    description: string,
    location: string,
    faction: string?,
    dialogues: {[string]: NPCDialogue},
    defaultDialogue: string,
    quests: {string}?, -- Quest IDs this NPC can give
    services: {string}?, -- Services this NPC provides
    trainingType: string?, -- Type of training if trainer
}

-- NPC Definitions
local NPC_DEFINITIONS: {[string]: NPCDefinition} = {
    -- === VILLAGE ELDER (Starting NPC) ===
    ["Village_Elder"] = {
        id = "Village_Elder",
        name = "Ancien du Village",
        title = "Guide du Commencement",
        npcType = "VillageElder",
        description = "Le sage ancien du village qui accueille les nouveaux arrivants.",
        location = "Village_Square",
        faction = nil,
        defaultDialogue = "welcome",
        dialogues = {
            ["welcome"] = {
                id = "welcome",
                text = "Bienvenue, étranger! Je suis l'Ancien du Village. Je vois que vous êtes nouveau dans notre royaume. Laissez-moi vous guider dans ce monde.",
                responses = {
                    {text = "Parlez-moi des factions du royaume", nextDialogue = "factions_explanation"},
                    {text = "Comment puis-je progresser?", nextDialogue = "progression_explanation"},
                    {text = "Y a-t-il des quêtes disponibles?", nextDialogue = "quests_intro"},
                    {text = "Merci, je vais explorer par moi-même", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["factions_explanation"] = {
                id = "factions_explanation",
                text = "Notre royaume abrite plusieurs factions:\n\n👑 Royauté: La famille royale et leur cour au château.\n⚔️ Noblesse: Les maisons nobles qui gèrent les terres.\n👤 Roturiers: Les citoyens libres comme vous.\n🧝 Elfes: Le peuple ancien des forêts.\n😈 Démons: Les créatures du portail démoniaque.\n📚 Académie: L'institution d'apprentissage magique.",
                responses = {
                    {text = "Comment rejoindre une faction?", nextDialogue = "join_faction"},
                    {text = "Retour", nextDialogue = "welcome"},
                },
            },
            ["join_faction"] = {
                id = "join_faction",
                text = "Pour rejoindre une faction, vous devez accomplir des actions spécifiques:\n\n• Visitez leurs lieux et parlez à leurs représentants.\n• Accomplissez des quêtes pour eux.\n• Gagnez leur confiance par vos actions.\n\nLe chemin que vous empruntez dépend de vos choix!",
                responses = {
                    {text = "Je comprends", nextDialogue = "welcome"},
                },
            },
            ["progression_explanation"] = {
                id = "progression_explanation",
                text = "Dans Aethelgard, tout se fait par l'action:\n\n⚔️ Combattez pour débloquer des classes de guerrier.\n🔮 Lancez des sorts pour débloquer des classes de mage.\n🤝 Socialisez pour débloquer des classes de barde.\n🙏 Priez pour débloquer des classes de prêtre.\n\nVisitez l'Académie pour suivre une formation formelle!",
                responses = {
                    {text = "Où est l'Académie?", nextDialogue = "academy_location"},
                    {text = "Retour", nextDialogue = "welcome"},
                },
            },
            ["academy_location"] = {
                id = "academy_location",
                text = "L'Académie se trouve au nord du village. Cherchez le grand bâtiment avec les tours magiques. Parlez au Directeur de l'Académie pour vous inscrire.",
                responses = {
                    {text = "J'irai voir", nextDialogue = "welcome", action = "mark_academy_location"},
                    {text = "Retour", nextDialogue = "progression_explanation"},
                },
            },
            ["quests_intro"] = {
                id = "quests_intro",
                text = "Les quêtes vous permettent de gagner de l'expérience et de la réputation. Allez voir le Maître de Guilde près de la place du village pour obtenir des quêtes.",
                responses = {
                    {text = "Montrez-moi les quêtes disponibles", nextDialogue = "show_quests", action = "show_available_quests"},
                    {text = "Retour", nextDialogue = "welcome"},
                },
            },
            ["show_quests"] = {
                id = "show_quests",
                text = "Voici les quêtes que je peux vous proposer:",
                responses = {
                    {text = "Retour", nextDialogue = "welcome"},
                },
                action = "display_quest_list",
            },
        },
        quests = {"explore_forest_1", "defeat_wolves_1"},
        services = {"guidance", "quest_giving"},
    },
    
    -- === GUILD MASTER ===
    ["Guild_Master"] = {
        id = "Guild_Master",
        name = "Maître de Guilde",
        title = "Chef des Aventuriers",
        npcType = "GuildMaster",
        description = "Le chef de la guilde des aventuriers qui distribue les quêtes.",
        location = "Guild_Hall",
        faction = "Commoners",
        defaultDialogue = "guild_welcome",
        dialogues = {
            ["guild_welcome"] = {
                id = "guild_welcome",
                text = "Bienvenue à la Guilde des Aventuriers! Ici, vous pouvez accepter des missions pour gagner en expérience et en réputation.",
                responses = {
                    {text = "Quelles missions sont disponibles?", nextDialogue = "available_quests", action = "show_available_quests"},
                    {text = "Parlez-moi de ma progression", nextDialogue = "check_progress"},
                    {text = "Au revoir", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["available_quests"] = {
                id = "available_quests",
                text = "Voici les missions disponibles pour vous:",
                action = "display_quest_list",
                responses = {
                    {text = "Retour", nextDialogue = "guild_welcome"},
                },
            },
            ["check_progress"] = {
                id = "check_progress",
                text = "Laissez-moi vérifier votre progression...",
                action = "show_player_progress",
                responses = {
                    {text = "Merci!", nextDialogue = "guild_welcome"},
                },
            },
        },
        quests = {"escort_merchant_1", "explore_forest_1", "defeat_wolves_1", "socialize_guild_1"},
        services = {"quest_giving", "progress_check"},
    },
    
    -- === ACADEMY HEADMASTER ===
    ["Academy_Headmaster"] = {
    	id = "Academy_Headmaster",
    	name = "Directeur de l'Académie",
    	title = "Archimage",
    	npcType = "AcademyHeadmaster",
    	description = "Le directeur de l'Académie de Magie qui accueille les nouveaux étudiants.",
    	location = "Academy_Entrance",
    	faction = "Académie",
        defaultDialogue = "academy_welcome",
        dialogues = {
            ["academy_welcome"] = {
                id = "academy_welcome",
                text = "Bienvenue à l'Académie de Magie d'Aethelgard! Ici, nous formons les futurs mages, guerriers et héros du royaume.",
                responses = {
                    {text = "Je souhaite m'inscrire", nextDialogue = "enrollment", action = "check_enrollment"},
                    {text = "Parlez-moi des formations", nextDialogue = "training_info"},
                    {text = "Au revoir", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["enrollment"] = {
                id = "enrollment",
                text = "Excellent! Pour rejoindre l'Académie, vous devez d'abord prouver votre détermination. Explorez le royaume et revenez quand vous aurez gagné en expérience.",
                responses = {
                    {text = "Je suis prêt à m'inscrire", nextDialogue = "enroll_confirm", action = "join_academy"},
                    {text = "Je reviendrai plus tard", nextDialogue = "academy_welcome"},
                },
            },
            ["enroll_confirm"] = {
                id = "enroll_confirm",
                text = "Félicitations! Vous êtes maintenant étudiant de l'Académie. Parlez à nos instructeurs pour commencer votre formation.",
                responses = {
                    {text = "Merci!", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["training_info"] = {
                id = "training_info",
                text = "Nous offrons plusieurs formations:\n\n⚔️ Combat - Pour devenir Guerrier, Chevalier ou Paladin.\n🔮 Magie - Pour devenir Mage, Prêtre ou Druide.\n🗡️ Discrétion - Pour devenir Voleur ou Archer.\n🎵 Arts - Pour devenir Barde.\n\nChaque formation nécessite de pratiquer les compétences correspondantes.",
                responses = {
                    {text = "Où sont les instructeurs?", nextDialogue = "instructors_location"},
                    {text = "Retour", nextDialogue = "academy_welcome"},
                },
            },
            ["instructors_location"] = {
                id = "instructors_location",
                text = "Les instructeurs se trouvent dans les différentes salles de l'Académie:\n\n• Instructeur de Combat - Arène d'entraînement\n• Instructeur de Magie - Tour des Mages\n• Instructeur de Discrétion - Quartiers des Ombres",
                responses = {
                    {text = "J'irai les voir", nextDialogue = "academy_welcome"},
                },
            },
        },
        quests = {"train_magic_1", "train_combat_1"},
        services = {"enrollment", "training_info"},
    },
    
    -- === COMBAT INSTRUCTOR ===
    ["Combat_Instructor"] = {
    	id = "Combat_Instructor",
    	name = "Instructeur de Combat",
    	title = "Maître d'Armes",
    	npcType = "CombatInstructor",
    	description = "Le maître d'armes de l'Académie qui forme les guerriers.",
    	location = "Training_Arena",
    	faction = "Académie",
        defaultDialogue = "combat_welcome",
        dialogues = {
            ["combat_welcome"] = {
                id = "combat_welcome",
                text = "Ah, un aspirant guerrier! Pour maîtriser le combat, vous devez pratiquer sans relâche.",
                responses = {
                    {text = "Je veux m'entraîner au combat", nextDialogue = "start_training", action = "start_combat_training"},
                    {text = "Quelles sont les exigences?", nextDialogue = "combat_requirements"},
                    {text = "Au revoir", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["start_training"] = {
                id = "start_training",
                text = "Très bien! Commencez par frapper les mannequins d'entraînement. Revenez me voir quand vous aurez terminé.",
                responses = {
                    {text = "Je commence!", nextDialogue = nil, action = "accept_training_quest"},
                },
            },
            ["combat_requirements"] = {
                id = "combat_requirements",
                text = "Pour devenir Guerrier, vous devez:\n\n• Avoir frappé 50 fois (attaques au corps à corps)\n• Avoir complété 5 sessions d'entraînement\n\nPour devenir Chevalier, vous devez en plus:\n\n• Avoir défendu des lieux 10 fois\n• Avoir frappé 40 fois de plus",
                responses = {
                    {text = "Je vais m'entraîner", nextDialogue = "combat_welcome"},
                },
            },
        },
        quests = {"train_combat_1"},
        services = {"combat_training"},
        trainingType = "MeleeAttack",
    },
    
    -- === MAGIC INSTRUCTOR ===
    ["Magic_Instructor"] = {
    	id = "Magic_Instructor",
    	name = "Instructeur de Magie",
    	title = "Mage Senior",
    	npcType = "MagicInstructor",
    	description = "Le mage senior qui forme les lanceurs de sorts.",
    	location = "Mage_Tower",
    	faction = "Académie",
        defaultDialogue = "magic_welcome",
        dialogues = {
            ["magic_welcome"] = {
                id = "magic_welcome",
                text = "Les arcanes vous intéressent? La magie est un art qui demande patience et pratique.",
                responses = {
                    {text = "Je veux apprendre la magie", nextDialogue = "start_magic_training", action = "start_magic_training"},
                    {text = "Quelles sont les exigences?", nextDialogue = "magic_requirements"},
                    {text = "Au revoir", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["start_magic_training"] = {
                id = "start_magic_training",
                text = "Excellent choix! Pratiquez vos sorts sur les cibles d'entraînement. La méditation vous aidera aussi à concentrer votre énergie.",
                responses = {
                    {text = "Je commence!", nextDialogue = nil, action = "accept_magic_quest"},
                },
            },
            ["magic_requirements"] = {
                id = "magic_requirements",
                text = "Pour devenir Mage, vous devez:\n\n• Avoir lancé 30 sorts\n• Avoir complété 10 sessions d'entraînement\n• Avoir médité 5 fois\n\nPour devenir Prêtre:\n\n• Avoir prié 20 fois\n• Avoir complété 10 sessions d'entraînement",
                responses = {
                    {text = "Je vais m'entraîner", nextDialogue = "magic_welcome"},
                },
            },
        },
        quests = {"train_magic_1"},
        services = {"magic_training"},
        trainingType = "CastSpell",
    },
    
    -- === DEMON PORTAL KEEPER ===
    ["Demon_Portal_Keeper"] = {
    	id = "Demon_Portal_Keeper",
    	name = "Gardien du Portail",
    	title = "Serviteur des Ténèbres",
    	npcType = "DemonPortalKeeper",
    	description = "Le gardien du portail démoniaque qui recrute pour la faction démon.",
    	location = "Demon_Portal",
    	faction = "Démons",
        defaultDialogue = "demon_welcome",
        dialogues = {
            ["demon_welcome"] = {
                id = "demon_welcome",
                text = "Un mortel ose s'approcher du portail... Êtes-vous ici pour vous soumettre aux ténèbres?",
                responses = {
                    {text = "Je souhaite rejoindre les démons", nextDialogue = "join_demons", action = "check_demon_join"},
                    {text = "Parlez-moi de votre faction", nextDialogue = "demon_info"},
                    {text = "Je pars d'ici!", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["join_demons"] = {
                id = "join_demons",
                text = "Pour rejoindre notre faction, vous devez prouver votre dévotion. Méditez devant le portail et ressentez l'appel des ténèbres.",
                responses = {
                    {text = "Je médite devant le portail", nextDialogue = nil, action = "start_demon_meditation"},
                    {text = "Je ne suis pas prêt", nextDialogue = "demon_welcome"},
                },
            },
            ["demon_info"] = {
                id = "demon_info",
                text = "Nous sommes les serviteurs des seigneurs démoniaques. Notre but est de répandre l'influence des ténèbres dans ce royaume.\n\nEn tant que démon, vous pourrez:\n\n• Corrompre des lieux sacrés\n• Infiltrer les factions ennemies\n• Accéder à des pouvoirs interdits",
                responses = {
                    {text = "Intéressant...", nextDialogue = "demon_welcome"},
                },
            },
        },
        quests = {"corrupt_shrine_1"},
        services = {"demon_recruitment"},
    },
    
    -- === ELVEN ELDER ===
    ["Elven_Elder"] = {
    	id = "Elven_Elder",
    	name = "Ancien Elfe",
    	title = "Gardien de la Forêt",
    	npcType = "ElvenElder",
    	description = "Le sage des elfes qui protège la forêt sacrée.",
    	location = "Elven_Forest",
    	faction = "Elves Faction",
        defaultDialogue = "elf_welcome",
        dialogues = {
            ["elf_welcome"] = {
                id = "elf_welcome",
                text = "Un voyageur dans notre forêt sacrée... Que cherchez-vous, mortel?",
                responses = {
                    {text = "Je souhaite me lier aux Elfes", nextDialogue = "join_elves"},
                    {text = "Parlez-moi de votre peuple", nextDialogue = "elf_info"},
                    {text = "Je ne veux que passer", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["join_elves"] = {
                id = "join_elves",
                text = "Pour devenir un allié des Elfes, vous devez prouver votre respect pour la nature. Méditez auprès de l'Arbre Sacré et montrez votre dévouement.",
                responses = {
                    {text = "Je médite auprès de l'Arbre Sacré", nextDialogue = nil, action = "start_elf_meditation"},
                    {text = "Je reviendrai plus tard", nextDialogue = "elf_welcome"},
                },
            },
            ["elf_info"] = {
                id = "elf_info",
                text = "Nous sommes les gardiens des forêts depuis des millénaires. Nous vivons en harmonie avec la nature et ses esprits.\n\nEn tant qu'allié elfe, vous pourrez:\n\n• Accéder à nos forêts sacrées\n• Apprendre la magie de la nature\n• Devenir Druide",
                responses = {
                    {text = "Je respecte la nature", nextDialogue = "elf_welcome"},
                },
            },
        },
        quests = {},
        services = {"elf_recruitment"},
    },
    
    -- === CASTLE CAPTAIN ===
    ["Castle_Captain"] = {
    	id = "Castle_Captain",
    	name = "Capitaine du Château",
    	title = "Commandant de la Garde",
    	npcType = "CastleCaptain",
    	description = "Le commandant de la garde du château.",
    	location = "Castle_Barracks",
    	faction = "Noblesse",
        defaultDialogue = "captain_welcome",
        dialogues = {
            ["captain_welcome"] = {
                id = "captain_welcome",
                text = "Soldat! Que faites-vous ici? Si vous cherchez à servir le royaume, nous avons besoin de défenseurs.",
                responses = {
                    {text = "Je veux défendre le château", nextDialogue = "defend_castle"},
                    {text = "Quelles missions sont disponibles?", nextDialogue = "noble_quests", action = "show_noble_quests"},
                    {text = "Au revoir, Capitaine", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["defend_castle"] = {
                id = "defend_castle",
                text = "Excellent! Allez aux remparts et tenez votre position. Défendez le château contre toute menace!",
                responses = {
                    {text = "J'y vais!", nextDialogue = nil, action = "start_defense_quest"},
                },
            },
            ["noble_quests"] = {
                id = "noble_quests",
                text = "Voici les missions disponibles pour les nobles:",
                action = "display_quest_list",
                responses = {
                    {text = "Retour", nextDialogue = "captain_welcome"},
                },
            },
        },
        quests = {"defend_castle_1", "diplomacy_elves_1"},
        services = {"defense_missions"},
    },
    
    -- === HIGH PRIEST ===
    ["High_Priest"] = {
    	id = "High_Priest",
    	name = "Grand Prêtre",
    	title = "Serviteur des Dieux",
    	npcType = "HighPriest",
    	description = "Le chef religieux du royaume.",
    	location = "Temple",
    	faction = "Monarchie",
        defaultDialogue = "priest_welcome",
        dialogues = {
            ["priest_welcome"] = {
                id = "priest_welcome",
                text = "Que la lumière vous guide, voyageur. Êtes-vous ici pour prier ou pour servir les dieux?",
                responses = {
                    {text = "Je veux devenir Prêtre", nextDialogue = "priest_training"},
                    {text = "Y a-t-il des missions sacrées?", nextDialogue = "holy_quests"},
                    {text = "Je juste prier", nextDialogue = nil, action = "start_prayer"},
                },
            },
            ["priest_training"] = {
                id = "priest_training",
                text = "Pour devenir Prêtre, vous devez prier régulièrement et compléter votre formation à l'Académie. Les dieux favorisent ceux qui sont dévoués.",
                responses = {
                    {text = "Je vais prier et m'entraîner", nextDialogue = nil, action = "end_conversation"},
                },
            },
            ["holy_quests"] = {
                id = "holy_quests",
                text = "Les dieux ont besoin de serviteurs pour purifier les corruptions et aider les fidèles.",
                action = "display_quest_list",
                responses = {
                    {text = "Retour", nextDialogue = "priest_welcome"},
                },
            },
        },
        quests = {"purify_corruption_1"},
        services = {"prayer", "holy_missions"},
    },
}

-- Player interaction tracking
local playerInteractions: {[number]: {[string]: number}} = {} -- playerId -> {npcId -> lastInteractionTime}
local playerCooldowns: {[number]: {[string]: number}} = {} -- playerId -> {actionType -> cooldownEndTime}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function getPlayerInteractions(playerId: number): {[string]: number}
    if not playerInteractions[playerId] then
        playerInteractions[playerId] = {}
    end
    return playerInteractions[playerId]
end

local function isOnCooldown(playerId: number, actionType: string): boolean
    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = {}
    end
    
    local cooldownEnd = playerCooldowns[playerId][actionType]
    if cooldownEnd and os.time() < cooldownEnd then
        return true
    end
    
    return false
end

local function setCooldown(playerId: number, actionType: string, duration: number)
    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = {}
    end
    playerCooldowns[playerId][actionType] = os.time() + duration
end

-- ============================================
-- PUBLIC API
-- ============================================

local NPCInteractionSystem = {}

-- Get NPC definition
function NPCInteractionSystem.getNPC(npcId: string): NPCDefinition?
    return NPC_DEFINITIONS[npcId]
end

-- Get all NPCs
function NPCInteractionSystem.getAllNPCs(): {[string]: NPCDefinition}
    return NPC_DEFINITIONS
end

-- Get NPCs at a location
function NPCInteractionSystem.getNPCsAtLocation(location: string): {NPCDefinition}
    local npcs = {}
    for _, npc in pairs(NPC_DEFINITIONS) do
        if npc.location == location then
            table.insert(npcs, npc)
        end
    end
    return npcs
end

-- Get NPC dialogue
function NPCInteractionSystem.getDialogue(npcId: string, dialogueId: string): NPCDialogue?
    local npc = NPC_DEFINITIONS[npcId]
    if not npc then
        return nil
    end
    return npc.dialogues[dialogueId]
end

-- Start conversation with NPC
function NPCInteractionSystem.startConversation(playerId: number, npcId: string): any
    local npc = NPC_DEFINITIONS[npcId]
    if not npc then
        return nil
    end
    
    -- Record interaction
    local interactions = getPlayerInteractions(playerId)
    interactions[npcId] = os.time()
    
    -- Record action for progression
    ActionBasedProgressionSystem.recordAction(playerId, {
        actionType = "TalkToNPC",
        target = npcId,
        value = 5,
    })
    
    -- Return initial dialogue
    return {
        npc = npc,
        dialogue = npc.dialogues[npc.defaultDialogue],
    }
end

-- Process dialogue response
function NPCInteractionSystem.processResponse(playerId: number, npcId: string, currentDialogueId: string, responseIndex: number): any
    local npc = NPC_DEFINITIONS[npcId]
    if not npc then
        return nil
    end
    
    local currentDialogue = npc.dialogues[currentDialogueId]
    if not currentDialogue or not currentDialogue.responses then
        return nil
    end
    
    local response = currentDialogue.responses[responseIndex]
    if not response then
        return nil
    end
    
    -- Process action if any
    local actionResult = nil
    if response.action then
        actionResult = NPCInteractionSystem.processAction(playerId, npcId, response.action)
    end
    
    -- Get next dialogue if specified
    local nextDialogue = nil
    if response.nextDialogue then
        nextDialogue = npc.dialogues[response.nextDialogue]
    end
    
    return {
        npc = npc,
        dialogue = nextDialogue,
        actionResult = actionResult,
        endConversation = response.nextDialogue == nil and not response.action,
    }
end

-- Process NPC action
function NPCInteractionSystem.processAction(playerId: number, npcId: string, action: string): any
    local npc = NPC_DEFINITIONS[npcId]
    
    if action == "end_conversation" then
        return {type = "end"}
        
    elseif action == "show_available_quests" then
        -- Get available quests from this NPC
        local availableQuests = {}
        if npc and npc.quests then
            for _, questId in ipairs(npc.quests) do
                table.insert(availableQuests, questId)
            end
        end
        return {type = "quest_list", quests = availableQuests}
        
    elseif action == "display_quest_list" then
        local availableQuests = {}
        if npc and npc.quests then
            for _, questId in ipairs(npc.quests) do
                table.insert(availableQuests, questId)
            end
        end
        return {type = "quest_list", quests = availableQuests}
        
    elseif action == "show_player_progress" then
        local progression = ActionBasedProgressionSystem.getProgression(playerId)
        return {type = "progress", progression = progression}
        
    elseif action == "join_academy" then
        local success = ActionBasedProgressionSystem.joinFaction(playerId, "Academy")
        return {type = "faction_join", success = success, faction = "Academy"}
        
    elseif action == "start_combat_training" or action == "accept_training_quest" then
        -- Start combat training quest
        local questId = "train_combat_1"
        local success = QuestSystem.acceptQuest(playerId, questId)
        return {type = "quest_accepted", success = success, questId = questId}
        
    elseif action == "start_magic_training" or action == "accept_magic_quest" then
        -- Start magic training quest
        local questId = "train_magic_1"
        local success = QuestSystem.acceptQuest(playerId, questId)
        return {type = "quest_accepted", success = success, questId = questId}
        
    elseif action == "start_demon_meditation" then
        -- Record meditation at demon portal
        ActionBasedProgressionSystem.recordAction(playerId, {
            actionType = "Meditate",
            target = "Demon_Portal",
            value = 20,
        })
        return {type = "meditation_started", location = "Demon_Portal"}
        
    elseif action == "start_elf_meditation" then
        -- Record meditation at sacred tree
        ActionBasedProgressionSystem.recordAction(playerId, {
            actionType = "Meditate",
            target = "Sacred_Tree",
            value = 20,
        })
        return {type = "meditation_started", location = "Sacred_Tree"}
        
    elseif action == "start_prayer" then
        ActionBasedProgressionSystem.recordAction(playerId, {
            actionType = "Pray",
            target = "Temple",
            value = 10,
        })
        return {type = "prayer_started"}
        
    elseif action == "start_defense_quest" then
        local questId = "defend_castle_1"
        local success = QuestSystem.acceptQuest(playerId, questId)
        return {type = "quest_accepted", success = success, questId = questId}
        
    elseif action == "mark_academy_location" then
        return {type = "location_marked", location = "Academy"}
        
    elseif action == "check_demon_join" then
        local progression = ActionBasedProgressionSystem.getProgression(playerId)
        local canJoin = (progression.actionCounts["Meditate_Demon_Portal"] or 0) >= 3
        return {type = "requirement_check", canJoin = canJoin, requirement = "Meditate at Demon Portal 3 times"}
    end
    
    return {type = "unknown"}
end

-- Accept quest from NPC
function NPCInteractionSystem.acceptQuest(playerId: number, npcId: string, questId: string): boolean
    local npc = NPC_DEFINITIONS[npcId]
    if not npc then
        return false
    end
    
    -- Check if NPC has this quest
    local hasQuest = false
    if npc.quests then
        for _, id in ipairs(npc.quests) do
            if id == questId then
                hasQuest = true
                break
            end
        end
    end
    
    if not hasQuest then
        return false
    end
    
    return QuestSystem.acceptQuest(playerId, questId)
end

-- Get NPC quests for player
function NPCInteractionSystem.getNPCQuestsForPlayer(playerId: number, npcId: string): {any}
    local npc = NPC_DEFINITIONS[npcId]
    if not npc or not npc.quests then
        return {}
    end
    
    local availableQuests = {}
    for _, questId in ipairs(npc.quests) do
        local questDef = QuestSystem.getQuestDefinition(questId)
        if questDef then
            local isOnQuest = QuestSystem.isOnQuest(playerId, questId)
            table.insert(availableQuests, {
                questId = questId,
                name = questDef.name,
                description = questDef.description,
                difficulty = questDef.difficulty,
                isOnQuest = isOnQuest,
            })
        end
    end
    
    return availableQuests
end

-- Check proximity to NPC (for triggering interactions)
function NPCInteractionSystem.checkProximity(playerId: number, position: Vector3): string?
    -- This would be implemented with actual NPC positions in the game world
    -- For now, return nil - this needs to be connected to actual NPC models
    return nil
end

return NPCInteractionSystem
