--!nonstrict
-- Race System for Aethelgard
-- Contains playable races, their bonuses, culture, and inter-racial relations

export type RaceBonus = {
	stat: string,
	amount: number,
	description: string,
}

export type RaceMalus = {
	stat: string,
	amount: number,
	description: string,
}

export type RaceInfo = {
	id: string,
	name: string,
	displayName: string,
	description: string,
	history: string,
	appearance: string,
	bonus: { RaceBonus },
	malus: { RaceMalus }?,
	playable: boolean,
	alignment: "good" | "evil" | "neutral",
	preferredClasses: { string },
	uniqueAbilities: { string },
	culture: {
		values: string,
		religion: string,
		society: string,
		relationships: string,
	},
	relations: { [string]: "allied" | "neutral" | "hostile" | "complex" },
}

export type InterRaceRelation = {
	race1: string,
	race2: string,
	relation: "allied" | "neutral" | "hostile" | "complex",
	reason: string,
	history: string,
}

export type RaceSystem = {
	getRaces: () -> { RaceInfo },
	getRaceById: (raceId: string) -> RaceInfo?,
	getPlayableRaces: () -> { RaceInfo },
	getRacesByAlignment: (alignment: string) -> { RaceInfo },
	getRelations: () -> { InterRaceRelation },
	getRelationBetween: (race1: string, race2: string) -> InterRaceRelation?,
}

-- ============================================
-- RACES DEFINITION
-- ============================================

local RACES: { RaceInfo } = {
	{
		id = "human",
		name = "Humain",
		displayName = "Humain",
		description = "Les humains sont la race la plus nombreuse et adaptable d'Aethelgard. Originaires des royaumes de Khiz et de Jamluan, ils ont developpe une civilisation diverse et dynamique.",
		history = "Les humains sont apparus durant l'ere des Rois Humains (Age 800). Ils ont rapidement etabli les grands royaumes qui dominent aujourd'hui Aethelgard. Leur capacite d'adaptation leur a permis de prosperer malgre les guerres et les catastrophes.",
		appearance = "Peau variee (claire a foncee), cheveux de toutes couleurs, taille moyenne (1m60-1m90).",
		bonus = {
			{ stat = "Versatilite", amount = 1, description = "+1 a toutes les statistiques de base" },
			{ stat = "Ambition", amount = 1, description = "+10% experience gagnee" },
			{ stat = "Diplomatie", amount = 1, description = "+5% reputation avec toutes les factions" },
		},
		malus = {
			{ stat = "Longevite", amount = 1, description = "Duree de vie moyenne: 70-80 ans" },
		},
		playable = true,
		alignment = "neutral",
		preferredClasses = { "Guerrier", "Chevalier", "Paladin", "Mage", "Pretre", "Archer", "Barde" },
		uniqueAbilities = { "Inspiration", "Leadership Naturel" },
		culture = {
			values = "Gloire, famille, honor, reussite personnelle",
			religion = "Culte des Dieux de l'Aube (Theocratie), croyances locales (Royaume de Khiz)",
			society = "Monarchie feodale, classes sociales definies",
			relationships = "Mariage monogame dominant, famille elargie importante",
		},
		relations = {
			Elfe = "neutral",
			Nain = "allied",
			Demons = "hostile",
			Orc = "hostile",
			Halfelin = "allied",
		},
	},
	{
		id = "elf",
		name = "Elfe",
		displayName = "Elfe",
		description = "Les elfes sont une race ancienne et mystique, gardiens des forets sacrees. Ils vivent generalement isoles du monde des autres races, mais maintiennent des contacts diplomatiques.",
		history = "Les elfes sont les premieres races creees par les Dieux Primordiaux. Ils ont construit une civilisation avancee avant meme l'apparition des humains. Apres la Grande Fracture, ils se sont retires dans leurs forets sacrees.",
		appearance = "Peau pale ou legerement doree, oreilles pointues, cheveux blonds, noirs ou argentes. Grand et mince (1m80-2m10). Longue duree de vie (500+ ans).",
		bonus = {
			{ stat = "Magie Naturelle", amount = 2, description = "+2 Intelligence, +2 Sagesse" },
			{ stat = "Vue Percante", amount = 1, description = "+20% portee de vision, detection furtivite" },
			{ stat = "Longevite", amount = 1, description = "Duree de vie: 500-1000 ans" },
			{ stat = " grace", amount = 1, description = "+10% esquive" },
		},
		malus = {
			{ stat = "Reproduction", amount = 1, description = "Croissance tres lente, population limitee" },
			{ stat = "Adaptabilite", amount = 1, description = "-10% resistance aux maladies" },
		},
		playable = true,
		alignment = "good",
		preferredClasses = { "Druide", "Mage", "Archer", "Voleur", "Pretre" },
		uniqueAbilities = { "Connexion Naturelle", "Vue Elfique", "Pas Silencieux" },
		culture = {
			values = "Harmonie avec la nature, sagesse, art, tradition",
			religion = "Culte des Esprits de la Foret, veneration des ancetres",
			society = "Societe matriarcale, conseil des anciens",
			relationships = "Relations durables, peu de mariages, separation possible",
		},
		relations = {
			Humain = "neutral",
			Nain = "complex",
			Demons = "hostile",
			Orc = "hostile",
			Halfelin = "neutral",
		},
	},
	{
		id = "dwarf",
		name = "Nain",
		displayName = "Nain",
		description = "Les nains sont des artisans et guerriers legendaire, maitres de la forge et de la pierre. Ils vivent dans les montagnes et les forges souterraines.",
		history = "Crees par les Dieux Primordiaux, les nains ont faconne les montagnes d'Aethelgard. Leur alliance avec les elfes lors de la Guerre des Titans a pose les bases du monde moderne.",
		appearance = "Petits et compacts (1m20-1m50), barbe fournie (hommes), cheveux robustes. Peau mate, yeux percants.",
		bonus = {
			{ stat = "Resistance", amount = 2, description = "+2 Vitalite, +10% resistance aux degats physiques" },
			{ stat = "Artisanat", amount = 1, description = "+20% efficacite du craft, qualite superieure" },
			{ stat = "Endurance", amount = 1, description = "+50% resistance a la fatigue" },
			{ stat = "Forge", amount = 1, description = "Peut forger des equipements legendaires" },
		},
		malus = {
			{ stat = "Mobilite", amount = 1, description = "-10% vitesse de mouvement" },
			{ stat = "Magie", amount = 1, description = "-1 Intelligence, apprentissage magique difficile" },
		},
		playable = true,
		alignment = "good",
		preferredClasses = { "Guerrier", "Chevalier", "Paladin", "Necromancien" },
		uniqueAbilities = { "Resistance Naine", "Maitre Forgeron", "Vision dans le Noir" },
		culture = {
			values = "Honneur, famille, craft, bravoure, ale",
			religion = "Culte des Dieux de la Forge et de la Pierre",
			society = "Clans familiaux, roi elu parmi les chefs",
			relationships = "Mariage monogame, clan tres important",
		},
		relations = {
			Humain = "allied",
			Elfe = "complex",
			Demons = "hostile",
			Orc = "hostile",
			Halfelin = "allied",
		},
	},
	{
		id = "halfling",
		name = "Halfelin",
		displayName = "Halfelin",
		description = "Les halfelins sont une race petite mais chanceuse, connue pour leur amour de la vie, de la bonne chere et des aventures. Ils vivent souvent dans les regions temperees.",
		history = "Les halfelins descendent probablement d'une branche separee des humains. Ils ont developpe leur propre culture distincte, souvent trouvee dans les communautes rurales paisibles.",
		appearance = "Petits (1m-1m30), pieds poilus et larges, visage rond et souriant. Peau claire a mate.",
		bonus = {
			{ stat = "Chance", amount = 3, description = "+3 Chance, objets rares plus frequents" },
			{ stat = "Discretion", amount = 1, description = "+15% furtivite, difficile a reperer" },
			{ stat = "Chanceux", amount = 1, description = "evitement de mort therapeut 1x par combat" },
			{ stat = "Social", amount = 1, description = "+10% commerce, negociation avantageuse" },
		},
		malus = {
			{ stat = "Force", amount = 1, description = "-1 Force, portee d'arme reduite" },
			{ stat = "Taille", amount = 1,	description = "Cible plus petite pour les ennemis, -5% chance d'etre touche" },
		},
		playable = true,
		alignment = "good",
		preferredClasses = { "Voleur", "Barde", "Archer", "Rogue" },
		uniqueAbilities = { "Chance du Halfelin", "Pas de Lutin", "Resistance a la Magie" },
		culture = {
			values = "Famille, nourriture, aventure, chance, humour",
			religion = "Culte des esprits domestiques, croyances locales",
			society = "Chefs de famille, societe egalitaire",
			relationships = "Grandes familles, mariages frequents, hospitalite sacree",
		},
		relations = {
			Humain = "allied",
			Elfe = "neutral",
			Nain = "allied",
			Demons = "hostile",
			Orc = "neutral",
		},
	},
	{
		id = "orc",
		name = "Orc",
		displayName = "Orc",
		description = "Les orcs sont des guerriers puissants et redoutables. Longtemps consideres comme des monstres, certains clans ont developpe une civilisation complexe.",
		history = "Les orcs sont apparus dans les terres desolees apres la Grande Fracture. Certains ont servi Malachar pendant la guerre, mais d'autres ont choisi l'independance.",
		appearance = "Grands et massifs (1m80-2m20), peau verte ou grise, defenses, muscles developpes.",
		bonus = {
			{ stat = "Force Brute", amount = 3, description = "+3 Force, +10% degats physiques" },
			{ stat = "Resilience", amount = 2, description = "+2 Vitalite, regeneration acceleree" },
			{ stat = "Intimidation", amount = 1, description = "+20% chance de faire fuir les ennemis faibles" },
			{ stat = "Endurance", amount = 1,	description = "Peut combattre plus longtemps sans repos" },
		},
		malus = {
			{ stat = "Intelligence", amount = 1, description = "-1 Intelligence, apprentissage magique difficile" },
			{ stat = "Reputation", amount = 1, description = "-10% reputation avec la plupart des factions" },
		},
		playable = true,
		alignment = "neutral",
		preferredClasses = { "Guerrier", "Berserker", "Paladin Noir" },
		uniqueAbilities = { "Rage du Combat", "Peau epaisse", "Croissance Rapide" },
		culture = {
			values = "Force, honneur tribal, loyaute au clan, conqueste",
			religion = "Culte des ancetres guerriers, certains venerent Malachar",
			society = "Clans tribaux, chef le plus fort",
			relationships = "Mariages arranges, clan plus important que l'individu",
		},
		relations = {
			Humain = "hostile",
			Elfe = "hostile",
			Nain = "hostile",
			Demons = "complex",
			Halfelin = "neutral",
		},
	},
	{
		id = "demon",
		name = "Demon",
		displayName = "Demon",
		description = "Les demons sont des etres des Abysses, serviteurs de Malachar. Certains ont rompu avec leur roi et vivent caches parmi les mortels.",
		history = "Les demons existent depuis la creation d'Aethelgard. Ils ont mene la guerre contre les Royaumes Unis et ont ete scelles par le heros Aldric.",
		appearance = "Variable: forme humanoide avec cornes, ailes, queue, ou formes monstrueuses. Peau rouge, noire ou violacee.",
		bonus = {
			{ stat = "Magie Sombre", amount = 2, description = "+2 Intelligence, +10% degats magiques sombres" },
			{ stat = "Regeneration", amount = 1,	description = "Regeneration acceleree dans les tenebres" },
			{ stat = "Resistance", amount = 1, description = "Immunite au poison, +10% resistance magique" },
			{ stat = "Puissance", amount = 1, description = "+10% degats des competences demoniaques" },
		},
		malus = {
			{ stat = "Lumiere", amount = 1, description = "-20% efficacite sous la lumiere directe du soleil" },
			{ stat = "Saintete", amount = 1, description = "Vulnerabilite aux attaques sacrees" },
		},
		playable = true,
		alignment = "evil",
		preferredClasses = { "Necromancien", "Demoniste", "Moine Noir" },
		uniqueAbilities = { "Magie Demoniaque", "Metamorphose", "Peur" },
		culture = {
			values = "Pouvoir, hierarchie, loyaute au plus fort",
			religion = "Culte de Malachar, loi du plus fort",
			society = "Hierarchie stricte basee sur le pouvoir",
			relationships = "Relations de pouvoir, unions politiques",
		},
		relations = {
			Humain = "hostile",
			Elfe = "hostile",
			Nain = "hostile",
			Orc = "complex",
			Halfelin = "hostile",
		},
	},
	{
		id = "tiefling",
		name = "Tiefling",
		displayName = "Tiefling (Demi-Demon)",
		description = "Les tieflings sont des humains avec du sang demoniaque. Ils portent des signes subtils de leur heritage mais sont generalement neutres.",
		history = "Les tieflings sont apparus suite a des unions entre demons et mortels pendant la guerre. Leurs descendants vivent maintenant parmi les humains, souvent discrimines.",
		appearance = "Apparence humaine avec des signes subtils: cornes petites, queue, yeux inhabituels, legere pigmentation anormale.",
		bonus = {
			{ stat = "Resistance Sombre", amount = 2, description = "+2 Resistance magique, immunite a la peur" },
			{ stat = "Charme", amount = 1, description = "+10% resistance a l'enchantement" },
			{ stat = "Adaptabilite", amount = 1, description = "Peut apprendre n'importe quelle classe" },
			{ stat = "Magie", amount = 1, description = "+1 Intelligence, peut lancer un sort de mage noir" },
		},
		malus = {
			{ stat = "Reputation", amount = 1, description = "-10% reputation avec factions religieuses" },
			{ stat = "Lumiere", amount = 1, description = "-5% efficacite en plein jour" },
		},
		playable = true,
		alignment = "neutral",
		preferredClasses = { "Mage", "Necromancien", "Voleur", "Barde" },
		uniqueAbilities = { "Resistance aux Tenebres", "Magie Mineure", "Charme" },
		culture = {
			values = "Survie, discretion, prouver sa valeur",
			religion = "Variable, souvent athees ou pratiques secretes",
			society = "Minorite discriminee, communautes cachees",
			relationships = "Mariages mixtes acceptes, famille importante",
		},
		relations = {
			Humain = "neutral",
			Elfe = "neutral",
			Nain = "neutral",
			Demons = "complex",
			Orc = "neutral",
			Halfelin = "neutral",
		},
	},
}

-- ============================================
-- INTER-RACIAL RELATIONS
-- ============================================

local RELATIONS: { InterRaceRelation } = {
	{
		race1 = "Humain",
		race2 = "Elfe",
		relation = "neutral",
		reason = "Respect mutuel mais differences culturelles importantes",
		history = "Les humains et elfes ont des relations cordiales mais distantes. Les elfes considerent les humains comme jeunes et impulsifs, tandis que les humains trouvent les elfes froids et arrogants.",
	},
	{
		race1 = "Humain",
		race2 = "Nain",
		relation = "allied",
		reason = "Alliance historique contre les menaces communes",
		history = "Les humains et nains ont combattu ensemble lors de la Guerre des Titans. Cette alliance a cree des liens durables, et les nains fournissent armures et armes aux royaumes humains.",
	},
	{
		race1 = "Humain",
		race2 = "Orc",
		relation = "hostile",
		reason = "Conflits territoriaux et culturels",
		history = "Les orcs ont envahi les territoires humains a plusieurs reprises. Bien que certains clans soient pacifiques, la mefiance reste profonde.",
	},
	{
		race1 = "Humain",
		race2 = "Demon",
		relation = "hostile",
		reason = "Ennemis jures depuis la guerre contre Malachar",
		history = "Les demons ont cause d'immenses devastations pendant la guerre. La Theocratie de Jamluan considere tous les demons comme des ennemis.",
	},
	{
		race1 = "Elfe",
		race2 = "Nain",
		relation = "complex",
		reason = "Ancienne alliance mais divergences philosophiques",
		history = "Les elfes et nains ont forme les Royaumes Unis lors de la Guerre des Titans. Cependant, leurs philosophies differentes (nature vs industrie) creent des tensions.",
	},
	{
		race1 = "Elfe",
		race2 = "Orc",
		relation = "hostile",
		reason = "Les orcs ont detruit des forets elfiques",
		history = "Plusieurs clans orcs ont envahi les territoires elfiques pendant et apres la guerre contre Malachar. Les elfes considerent les orcs comme des destructeurs.",
	},
	{
		race1 = "Nain",
		race2 = "Orc",
		relation = "hostile",
		reason = "Conflits pour les territoires montagneux",
		history = "Les nains et orcs se battent pour le controle des montagnes depuis des siecles. Les nains meprisent les orcs comme des barbares.",
	},
	{
		race1 = "Nain",
		race2 = "Halfelin",
		relation = "allied",
		reason = "Relations commerciales et valeurs communes",
		history = "Les nains et halfelins ont developpe des liens etroits. Les halfelins fournissent de la nourriture et des biens, les nains offrent artisanat et protection.",
	},
	{
		race1 = "Humain",
		race2 = "Halfelin",
		relation = "allied",
		reason = "Coexistence pacifique et echanges culturels",
		history = "Les halfelins vivent souvent dans les territoires humains. Bien que parfois moques, ils sont acceptes et apprecies pour leur chance et leur jovialite.",
	},
	{
		race1 = "Demon",
		race2 = "Orc",
		relation = "complex",
		reason = "Anciens allies mais certains orcs ont rejete Malachar",
		history = "De nombreux orcs ont servi Malachar, mais certains clans ont choisi l'independance. Les demons meprisent les orcs comme des etres inferieurs.",
	},
	{
		race1 = "Tiefling",
		race2 = "Demon",
		relation = "complex",
		reason = "Lien sanguin mais souvent en conflit",
		history = "Les tieflings descendent de demons mais vivent parmi les mortels. Certains rejettent leur heritage demoniaque, d'autres l'acceptent.",
	},
}

-- ============================================
-- EXPORT
-- ============================================

local RaceSystem = {}

function RaceSystem.getRaces(): { RaceInfo }
	return RACES
end

function RaceSystem.getRaceById(raceId: string): RaceInfo?
	for _, race in ipairs(RACES) do
		if race.id == raceId then
			return race
		end
	end
	return nil
end

function RaceSystem.getPlayableRaces(): { RaceInfo }
	local result = {}
	for _, race in ipairs(RACES) do
		if race.playable then
			table.insert(result, race)
		end
	end
	return result
end

function RaceSystem.getRacesByAlignment(alignment: string): { RaceInfo }
	local result = {}
	for _, race in ipairs(RACES) do
		if race.alignment == alignment then
			table.insert(result, race)
		end
	end
	return result
end

function RaceSystem.getRelations(): { InterRaceRelation }
	return RELATIONS
end

function RaceSystem.getRelationBetween(race1: string, race2: string): InterRaceRelation?
	for _, relation in ipairs(RELATIONS) do
		if (relation.race1 == race1 and relation.race2 == race2) or 
		   (relation.race1 == race2 and relation.race2 == race1) then
			return relation
		end
	end
	return nil
end

return RaceSystem
