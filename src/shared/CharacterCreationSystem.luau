--!nonstrict
-- Character Creation System for Aethelgard
-- Handles race and class selection for isekai characters

local RaceSystem = require(script.Parent.RaceSystem)
local RPGSystem = require(script.Parent.RPGSystem)

export type OriginType = 
	"Student" | 
	"Salaryman" | 
	"Gamer" | 
	"Scientist" | 
	"Worker" | 
	"Soldier" | 
	"Artist" | 
	"Other"

export type ArrivalType = 
	"Invocation" | 
	"Reincarnation" | 
	"Portal" | 
	"Accident" | 
	"DivineChoice" | 
	"Curse"

export type CheatType = 
	"DivineBlessing" | 
	"GameUI" | 
	"ModernKnowledge" | 
	"UniqueSkill" | 
	"LegendaryItem" | 
	"None"

export type CharacterOrigin = {
	id: string,
	name: string,
	description: string,
	bonus: { string },
	recommendedClasses: { string },
}

export type ArrivalMethod = {
	id: string,
	name: string,
	description: string,
	narrativeHook: string,
	effects: { string },
}

export type CheatAbility = {
	id: string,
	name: string,
	description: string,
	power: "low" | "medium" | "high" | "legendary",
	effects: { string },
	required: boolean,
}

export type CharacterCreationData = {
	playerId: number,
	characterName: string,
	raceId: string,
	classId: string,
	origin: OriginType,
	arrival: ArrivalType,
	cheat: CheatType,
	backstory: string,
	motivation: string,
	createdAt: number,
}

export type CharacterCreationSystem = {
	-- Origins
	getOrigins: () -> { CharacterOrigin },
	getOriginById: (originId: string) -> CharacterOrigin?,
	
	-- Arrival methods
	getArrivalMethods: () -> { ArrivalMethod },
	getArrivalById: (arrivalId: string) -> ArrivalMethod?,
	
	-- Cheat abilities
	getCheatAbilities: () -> { CheatAbility },
	getCheatById: (cheatId: string) -> CheatAbility?,
	
	-- Character creation
	validateCharacterName: (name: string) -> boolean,
	validateRaceSelection: (raceId: string) -> boolean,
	validateClassSelection: (classId: string, raceId: string) -> boolean,
	calculateStartingStats: (raceId: string, classId: string) -> { [string]: number },
	createCharacter: (playerId: number, data: CharacterCreationData) -> boolean,
	
	-- Data access
	getCharacterData: (playerId: number) -> CharacterCreationData?,
	getAllCharacters: () -> { CharacterCreationData },
}

-- ============================================
-- ORIGINS (Isekai character backgrounds)
-- ============================================

local ORIGINS: { CharacterOrigin } = {
	{
		id = "Student",
		name = "etudiant Japonais",
		description = "Un etudiant ordinaire qui passait ses examens ou jouait a des jeux video.",
		bonus = { "Connaissance des jeux RPG", "Adaptation rapide", "Motivation a etudier" },
		recommendedClasses = { "Mage", "Archer", "Voleur" },
	},
	{
		id = "Salaryman",
		name = "Salaryman",
		description = "Un employe de bureau surmene qui a ete transporte apres une mort subite au travail.",
		bonus = { "Resistance au stress", "Competences sociales", "Travail acharne" },
		recommendedClasses = { "Guerrier", "Chevalier", "Paladin" },
	},
	{
		id = "Gamer",
		name = "Gamer Experimente",
		description = "Un joueur passionne de RPG qui connait parfaitement les mecaniques de jeu.",
		bonus = { "Connaissance des mecaniques RPG", "Strategie", "Optimisation" },
		recommendedClasses = { "Mage", "Archer", "Voleur" },
	},
	{
		id = "Scientist",
		name = "Scientifique",
		description = "Un scientifique ou ingenieur qui peut appliquer ses connaissances au monde fantastique.",
		bonus = { "Connaissance scientifique", "Analyse", "Innovation" },
		recommendedClasses = { "Mage", "Invocateur", "Alchimiste" },
	},
	{
		id = "Worker",
		name = "Travailleur",
		description = "Un ouvrier ou artisan avec des competences pratiques.",
		bonus = { "Competences manuelles", "Endurance", "Pragmatisme" },
		recommendedClasses = { "Guerrier", "Nain", "Chevalier" },
	},
	{
		id = "Soldier",
		name = "Soldat",
		description = "Un militaire ou ancien combattant avec de l'experience au combat.",
		bonus = { "Experience de combat", "Tactique", "Discipline" },
		recommendedClasses = { "Guerrier", "Chevalier", "Paladin", "Archer" },
	},
	{
		id = "Artist",
		name = "Artiste",
		description = "Un artiste, musicien ou createur avec une sensibilite unique.",
		bonus = { "Creativite", "Charisme", "Expression" },
		recommendedClasses = { "Barde", "Pretre", "Druide" },
	},
	{
		id = "Other",
		name = "Autre",
		description = "Une origine personnalisee a definir.",
		bonus = { "Personnalisable" },
		recommendedClasses = {},
	},
}

-- ============================================
-- ARRIVAL METHODS
-- ============================================

local ARRIVAL_METHODS: { ArrivalMethod } = {
	{
		id = "Invocation",
		name = "Invocation",
		description = "Vous avez ete invoque par des heros ou des mages pour les aider dans leur quete.",
		narrativeHook = "Les heros ont besoin d'un allie supplementaire pour affronter une menace imminente.",
		effects = { "Vous apparaissez avec un equipement de base", "Relations initiales avec les factions dependant de l'invocateur" },
	},
	{
		id = "Reincarnation",
		name = "Reincarnation",
		description = "Vous etes mort dans votre monde et avez ete reincarne dans un corps nouveau-ne.",
		narrativeHook = "Vous grandissez dans ce nouveau monde avec vos souvenirs intacts.",
		effects = { "Vous commencez au niveau 1", "Vous avez une connexion spirituelle unique" },
	},
	{
		id = "Portal",
		name = "Portail",
		description = "Vous avez traverse un portail magique reliant les deux mondes.",
		narrativeHook = "Le portail s'ouvre dans un lieu precis, vous devez trouver votre chemin.",
		effects = { "Vous gardez certains objets de votre monde", "Le portail peut se rouvrir..." },
	},
	{
		id = "Accident",
		name = "Accident",
		description = "Un accident etrange (foudre, accident de voiture, chute) vous a transporte.",
		narrativeHook = "Vous vous reveillez dans un monde etrange, desoriente.",
		effects = { "Vous perdez certains souvenirs", "Vous avez un objet de votre monde" },
	},
	{
		id = "DivineChoice",
		name = "Choix Divin",
		description = "Une divinite vous a choisi comme heros pour sauver ce monde.",
		narrativeHook = "Les dieux vous accordent leur benediction, mais aussi leur responsabilite.",
		effects = { "Vous recevez une benediction initiale", "Vous avez une mission sacree" },
	},
	{
		id = "Curse",
		name = "Malediction",
		description = "Une malediction vous a transporte dans ce monde comme prison.",
		narrativeHook = "Vous devez trouver qui vous a maudit et comment briser la malediction.",
		effects = { "Vous avez un handicap initial", "Vous avez une raison de chercher la liberation" },
	},
}

-- ============================================
-- CHEAT ABILITIES
-- ============================================

local CHEAT_ABILITIES: { CheatAbility } = {
	{
		id = "DivineBlessing",
		name = "Benediction Divine",
		description = "Vous etes beni par une divinite qui vous accorde des pouvoirs speciaux.",
		power = "high",
		effects = { "+20% a toutes les statistiques", "Competences divines accessibles", "Immunite a certaines maladies" },
		required = false,
	},
	{
		id = "GameUI",
		name = "Interface de Jeu",
		description = "Vous voyez une interface de jeu RPG (niveaux, competences, inventaire) comme dans un jeu video.",
		power = "medium",
		effects = { "Affichage des statistiques", "Menu de competences", "Inventaire visuel" },
		required = false,
	},
	{
		id = "ModernKnowledge",
		name = "Connaissance Moderne",
		description = "Vous pouvez appliquer vos connaissances du monde moderne (science, medecine, cuisine).",
		power = "medium",
		effects = { "Bonus en artisanat", "Connaissances medicales", "Recettes modernes" },
		required = false,
	},
	{
		id = "UniqueSkill",
		name = "Competence Unique",
		description = "Vous possedez une competence que personne d'autre n'a dans ce monde.",
		power = "high",
		effects = { "Une competence exclusive", "Avantage strategique", "Potentiel de decouverte" },
		required = false,
	},
	{
		id = "LegendaryItem",
		name = "Objet Legendaire",
		description = "Vous possedez un objet legendaire de votre monde d'origine.",
		power = "high",
		effects = { "Objet de depart puissant", "Proprietes uniques", "Valeur historique" },
		required = false,
	},
	{
		id = "None",
		name = "Aucun",
		description = "Vous n'avez pas de 'cheat' particulier. Vous devez vous debrouiller par vous-meme.",
		power = "low",
		effects = { "Defis plus grands", "Satisfaction de la progression", "Histoire plus realiste" },
		required = true,
	},
}

-- ============================================
-- CHARACTER DATA STORAGE (server-side)
-- ============================================

local characterDatabase: { [number]: CharacterCreationData } = {}

-- ============================================
-- VALIDATION FUNCTIONS
-- ============================================

local function validateCharacterName(name: string): boolean
	if not name or #name < 2 or #name > 30 then
		return false
	end
	-- Check for invalid characters (using %% to escape % in pattern matching)
	local invalidChars = {"%%", "%$", "@", "#", "%^", "&", "%*", "!", "~", "`"}
	for _, char in ipairs(invalidChars) do
		if string.find(name, char) then
			return false
		end
	end
	return true
end

local function validateRaceSelection(raceId: string): boolean
	local race = RaceSystem.getRaceById(raceId)
	return race ~= nil and race.playable
end

local function validateClassSelection(classId: string, raceId: string): boolean
	local class = RPGSystem.getClassByName(classId)
	if not class then
		return false
	end
	-- Check if race can use this class
	local race = RaceSystem.getRaceById(raceId)
	if not race then
		return false
	end
	-- Allow any class for tieflings (they're adaptable)
	if raceId == "tiefling" then
		return true
	end
	-- Check if class is in preferred classes
	for _, preferredClass in ipairs(race.preferredClasses) do
		if preferredClass == classId then
			return true
		end
	end
	return false
end

local function calculateStartingStats(raceId: string, classId: string): { [string]: number }
	local race = RaceSystem.getRaceById(raceId)
	local class = RPGSystem.getClassByName(classId)
	
	if not race or not class then
		return {}
	end
	
	local stats = {}
	
	-- Start with class base stats
	for statName, baseValue in pairs(class.baseStats) do
		stats[statName] = baseValue
	end
	
	-- Apply race bonuses
	for _, bonus in ipairs(race.bonus) do
		if bonus.stat == "Versatilite" then
			stats["Strength"] = (stats["Strength"] or 0) + bonus.amount
			stats["Agility"] = (stats["Agility"] or 0) + bonus.amount
			stats["Intelligence"] = (stats["Intelligence"] or 0) + bonus.amount
			stats["Wisdom"] = (stats["Wisdom"] or 0) + bonus.amount
			stats["Vitality"] = (stats["Vitality"] or 0) + bonus.amount
			stats["Luck"] = (stats["Luck"] or 0) + bonus.amount
		elseif bonus.stat == "Magie Naturelle" then
			stats["Intelligence"] = (stats["Intelligence"] or 0) + bonus.amount
			stats["Wisdom"] = (stats["Wisdom"] or 0) + bonus.amount
		elseif bonus.stat == "Resistance" then
			stats["Vitality"] = (stats["Vitality"] or 0) + bonus.amount
		elseif bonus.stat == "Force Brute" then
			stats["Strength"] = (stats["Strength"] or 0) + bonus.amount
		elseif bonus.stat == "Magie Sombre" then
			stats["Intelligence"] = (stats["Intelligence"] or 0) + bonus.amount
		elseif bonus.stat == "Resistance Sombre" then
			stats["Intelligence"] = (stats["Intelligence"] or 0) + bonus.amount
		elseif bonus.stat == "Chance" then
			stats["Luck"] = (stats["Luck"] or 0) + bonus.amount
		elseif bonus.stat == "Discretion" then
			stats["Agility"] = (stats["Agility"] or 0) + bonus.amount
		elseif bonus.stat == "Charme" then
			stats["Luck"] = (stats["Luck"] or 0) + bonus.amount
		else
			-- Generic stat bonus
			local statKey = string.gsub(bonus.stat, " ", "")
			stats[statKey] = (stats[statKey] or 0) + bonus.amount
		end
	end
	
	-- Apply race malus
	if race.malus then
		for _, malus in ipairs(race.malus) do
			local statKey = string.gsub(malus.stat, " ", "")
			if stats[statKey] then
				stats[statKey] = stats[statKey] - malus.amount
			end
		end
	end
	
	return stats
end

-- ============================================
-- EXPORT
-- ============================================

local CharacterCreationSystem = {}

-- Origins
function CharacterCreationSystem.getOrigins(): { CharacterOrigin }
	return ORIGINS
end

function CharacterCreationSystem.getOriginById(originId: string): CharacterOrigin?
	for _, origin in ipairs(ORIGINS) do
		if origin.id == originId then
			return origin
		end
	end
	return nil
end

-- Arrival methods
function CharacterCreationSystem.getArrivalMethods(): { ArrivalMethod }
	return ARRIVAL_METHODS
end

function CharacterCreationSystem.getArrivalById(arrivalId: string): ArrivalMethod?
	for _, arrival in ipairs(ARRIVAL_METHODS) do
		if arrival.id == arrivalId then
			return arrival
		end
	end
	return nil
end

-- Cheat abilities
function CharacterCreationSystem.getCheatAbilities(): { CheatAbility }
	return CHEAT_ABILITIES
end

function CharacterCreationSystem.getCheatById(cheatId: string): CheatAbility?
	for _, cheat in ipairs(CHEAT_ABILITIES) do
		if cheat.id == cheatId then
			return cheat
		end
	end
	return nil
end

-- Character creation
function CharacterCreationSystem.validateCharacterName(name: string): boolean
	return validateCharacterName(name)
end

function CharacterCreationSystem.validateRaceSelection(raceId: string): boolean
	return validateRaceSelection(raceId)
end

function CharacterCreationSystem.validateClassSelection(classId: string, raceId: string): boolean
	return validateClassSelection(classId, raceId)
end

function CharacterCreationSystem.calculateStartingStats(raceId: string, classId: string): { [string]: number }
	return calculateStartingStats(raceId, classId)
end

function CharacterCreationSystem.createCharacter(playerId: number, data: CharacterCreationData): boolean
	-- Validate all required fields
	if not validateCharacterName(data.characterName) then
		return false
	end
	if not validateRaceSelection(data.raceId) then
		return false
	end
	if not validateClassSelection(data.classId, data.raceId) then
		return false
	end
	
	-- Add timestamp
	data.createdAt = os.time()
	
	-- Store character
	characterDatabase[playerId] = data
	
	return true
end

-- Data access
function CharacterCreationSystem.getCharacterData(playerId: number): CharacterCreationData?
	return characterDatabase[playerId]
end

function CharacterCreationSystem.getAllCharacters(): { CharacterCreationData }
	local result = {}
	for playerId, data in pairs(characterDatabase) do
		table.insert(result, data)
	end
	return result
end

-- Get playable races (for UI)
function CharacterCreationSystem.getPlayableRaces()
	return RaceSystem.getPlayableRaces()
end

-- Get classes (for UI)
function CharacterCreationSystem.getClasses()
	return RPGSystem.getClasses()
end

-- Get classes available for a specific race
function CharacterCreationSystem.getClassesForRace(raceId: string)
	local race = RaceSystem.getRaceById(raceId)
	if not race then
		return {}
	end
	
	-- If tiefling, return all classes
	if raceId == "tiefling" then
		return RPGSystem.getClasses()
	end
	
	-- Return preferred classes
	local result = {}
	for _, className in ipairs(race.preferredClasses) do
		local classInfo = RPGSystem.getClassByName(className)
		if classInfo then
			table.insert(result, classInfo)
		end
	end
	return result
end

return CharacterCreationSystem
