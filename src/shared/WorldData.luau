--!nonstrict
-- World configuration data for Aethelgard
-- Contains world history, rules, factions, and political systems

export type FactionInfo = {
	name: string,
	capital: string?,
	villages: { string }?,
	forts: { string }?,
	pointsOfInterest: { string }?,
	description: string,
	alignment: "good" | "evil" | "neutral",
	ruler: string?,
}

export type MagicRule = {
	name: string,
	description: string,
	difficulty: "easy" | "medium" | "hard" | "legendary",
	elements: { string },
}

export type CreatureInfo = {
	name: string,
	type: string,
	dangerLevel: number,
	habitat: string,
	description: string,
}

export type WorldData = {
	name: string,
	history: string,
	genesis: string,
	age: string,
	rules: {
		magic: { MagicRule },
		technology: string,
		creatures: { CreatureInfo },
	},
	factions: { FactionInfo },
	politicalSystem: string,
	calendar: {
		daysInWeek: number,
		monthsInYear: number,
		eraName: string,
	},
}

-- ============================================
-- WORLD HISTORY
-- ============================================

local WORLD_HISTORY = [[
# L'Histoire d'Aethelgard

## L'ere des Origines (Age 0-500)
Au commencement, Aethelgard etait un monde de chaos ou les elements dechaines governaient sans ordre. Les Dieux Primordiaux creerent les premieres races: les Elfes anciens, gardiens de la magie pure, et les Nains, maitres de l'artisanat et de la pierre. Les deux races vecurent en harmonie pendant des siecles, construisant les fondations du monde moderne.

## La Guerre des Titans (Age 500-800)
Le Roi des Demons, Malachar l'Infini, surgit des Abysses et chercha a engloutir toute lumiere. Les Elfes et les Nains s'allierent pour la premiere fois, creant les Royaumes Unis d'Aethelgard. Cette alliance forgea les bases du systeme politique actuel.

## L'ere des Rois Humains (Age 800-2000)
Les humains emergerent comme une force dominante, fondant les grands royaumes. Le Royaume de Khiz s'etablit dans les terres fertiles de l'Est, tandis que la Theocratie de Jamluan worshipait les Dieux de l'Aube. Des tensions constantes entre les deux puissances definirent cette ere.

## La Chute des Anciens Royaumes (Age 2000-2200)
Une catastrophe mystique, connue sous le nom de "La Grande Fracture", dechira le tissu de la realite. Plusieurs royaumes tomberent dans les limbes, leurs terres devenues des zones corrompues. Les Elfes anciens se retirerent dans leurs forets sacrees, rompant contact avec les autres races.

## Le Reveil du Malachar (Age 2200-2250)
Apres des millenaires de sommeil, le Roi des Demons Malachar revint plus puissant que jamais. Il rassembla les legions demoniaques et commenca sa conquete. Les royaumes humains, divises, furent rapidement submerges.

## L'ere du Heros Legendaire (Age 2250-2280)
Un heros nomme Aldric le Pur emergea des rangs communs. Dote d'une benediction divine et d'une epee legendaire, il unit les factions restantes. Apres une guerre de trente ans, Aldric affronta Malachar dans la Bataille de l'Aube eternelle et le scella dans les Abysses.

## Le Retour de l'Ombre (Age 2280-Present)
Cinquante ans apres la defaite de Malachar, des signes avant-coureurs indiquent son retour imminent. Les barrieres entre les mondes s'affaiblissent, des creatures demoniaques apparaissent aux frontieres, et des propheties parlent d'un nouveau heros qui devra se lever. Les deux grandes puissances, le Royaume de Khiz et la Theocratie de Jamluan, se preparent a cette menace imminente.
]]

local GENESIS = [[
Au debut etait le Vide. Les Dieux Primordiaux - Aeloria deesse de la Lumiere, Malachar dieu des Tenebres, et les quatre elementaires - creerent Aethelgard a partir de leur essence combinee. 

La terre fut faconnee par les mains des Nains anciens, la magie coula dans les veines des Elfes, et lorsque les premiers humains ouvrirent les yeux, ils trouverent un monde deja riche en merveilles et en dangers.

Mais le prix de la creation fut eleve. Les Dieux s'endormirent, laissant leurs creations livre a elles-memes. Seul Malachar resta eveille, nourrit par les peurs et les conflits des mortels. Quand il se reveilla pleinement, ce fut pour apporter la destruction.

Le heros Aldric le Pur, beni par Aeloria dans son dernier souffle, parvint a sceller Malachar mais au prix de sa propre vie. Aujourd'hui, les barrieres faiblissent a nouveau...
]]

-- ============================================
-- MAGIC SYSTEM
-- ============================================

local MAGIC_RULES: { MagicRule } = {
	{
		name = "Magie elementaire",
		description = "La forme la plus commune de magie, manipulant les quatre elements: Feu, Eau, Terre, Air. Accessible a tous avec un entrainement approprie.",
		difficulty = "easy",
		elements = { "Feu", "Eau", "Terre", "Air" },
	},
	{
		name = "Magie Sacree",
		description = "Pouvoirs accordes par les divinites. Reserves aux pretres et fideles de la Theocratie de Jamluan. Permet guerison et protection.",
		difficulty = "medium",
		elements = { "Lumiere", "Guerison", "Protection" },
	},
	{
		name = "Magie Demoniaque",
		description = "Arts interdits puisant dans les Abysses. Puissants mais corruptifs. Utilises par les serviteurs de Malachar.",
		difficulty = "hard",
		elements = { "Tenebres", "Corruption", "Drain" },
	},
	{
		name = "Magie Elfique",
		description = "Magie ancienne des Elfes, intrinsequement liee a la nature. Requiert une connexion spirituelle avec le monde naturel.",
		difficulty = "medium",
		elements = { "Nature", "Plantes", "Animaux" },
	},
	{
		name = "Magieruniques",
		description = "Art de graver des sorts dans la pierre ou le metal. Developpe par les Nains, maintenant utilise dans tout Aethelgard.",
		difficulty = "medium",
		elements = { "Inscription", "Activation", "Stockage" },
	},
	{
		name = "Magie du Heros",
		description = "Pouvoirs legendaires accordes aux heros choisis par les dieux. Extremement rare, potentiellement unique.",
		difficulty = "legendary",
		elements = { "Benediction", "Force", "Destinee" },
	},
}

-- ============================================
-- CREATURES
-- ============================================

local CREATURES: { CreatureInfo } = {
	-- Animaux communs
	{
		name = "Loup d'Argent",
		type = "Animal",
		dangerLevel = 1,
		habitat = "Forets, Montagnes",
		description = "Loups majestueux au pelage argente, souvent domestiques par les Elfes.",
	},
	{
		name = "Cerf Sacre",
		type = "Animal",
		dangerLevel = 0,
		habitat = "Forets anciennes",
		description = "Creature sacree consideree comme messager des dieux.",
	},
	-- Monstres communs
	{
		name = "Gobelin",
		type = "Humanoide",
		dangerLevel = 2,
		habitat = "Caverne, Forets sombres",
		description = "Petites creatures malicieuses qui volent et pillent les voyageurs.",
	},
	{
		name = "Orc",
		type = "Humanoide",
		dangerLevel = 4,
		habitat = "Montagnes, Terres desolees",
		description = "Guerriers brutaux, certains servaient Malachar dans l'ancienne guerre.",
	},
	{
		name = "Squelette",
		type = "Mort-vivant",
		dangerLevel = 3,
		habitat = "Cimetieres, Ruines",
		description = "Restes animee par la magie noire, serviteurs courants des demons.",
	},
	-- Creatures magiques
	{
		name = "Dragon Ancien",
		type = "Dragon",
		dangerLevel = 10,
		habitat = "Montagnes lointaines",
		description = "Creatures legendaires dormants depuis l'ere des origines. Leur reveil annoncerait de grands changements.",
	},
	{
		name = "Griffon",
		type = "Creature hybride",
		dangerLevel = 6,
		habitat = "Hautes tours, Montagnes",
		description = "Creatures nobles mi-lion mi-aigle, souvent montures de chevaliers.",
	},
	{
		name = "Basilisk",
		type = "Creature magique",
		dangerLevel = 7,
		habitat = "Ruines, Grottes profondes",
		description = "Serpent geant dont le regard petrifie ses proies.",
	},
	-- Creatures demoniaques
	{
		name = "Demon de rang inferieur",
		type = "Demon",
		dangerLevel = 5,
		habitat = "Abysses, Portails",
		description = "Serviteurs de base de Malachar, recherches par les cultistes.",
	},
	{
		name = "Demon General",
		type = "Demon",
		dangerLevel = 9,
		habitat = "Territoire demoniaque",
		description = "Commandants des armees demoniaques, chacun avec des pouvoirs uniques.",
	},
	{
		name = "Malachar (Dormant)",
		type = "Demon Roi",
		dangerLevel = 10,
		habitat = "Abysses",
		description = "Le Roi des Demons scelle. Son reveil est prophetise.",
	},
}

-- ============================================
-- FACTIONS
-- ============================================

local FACTIONS: { FactionInfo } = {
	-- Base sur TeamData.luau et les informations fournies
	{
		name = "Royaume de Khiz",
		capital = "Khiz",
		villages = { "Doucebrise", "Kalmirn", "Hauterive" },
		forts = { "Serathat", "Fort Jamluan" },
		pointsOfInterest = {},
		description = "Un royaume humain puissant situe dans les terres fertiles de l'Est. Gouverne par un monarque hereditaire avec un systeme de noblesse structure. Connu pour son armee disciplinee et son commerce florissant.",
		alignment = "good",
		ruler = "Roi actuel: a determiner",
	},
	{
		name = "Theocratie de Jamluan",
		capital = "Jamluan",
		villages = { "Derratir", "Dirath", "Ostafar", "Tiquanar" },
		forts = {},
		pointsOfInterest = { "Temple de l'Aube", "Entree du Territoire Demoniaque", "Miroir Extra-dimensionnel" },
		description = "etat religieux gouverne par les pretres du culte de la Lumiere. Leur capitale est le centre spirituel d'Aethelgard. Ils maintiennent la surveillance du sceau de Malachar.",
		alignment = "good",
		ruler = "Grand Pretre: a determiner",
	},
	{
		name = "Faction Elfique",
		capital = nil,
		villages = {},
		forts = {},
		pointsOfInterest = { "Forets Sacrees", "Arbre Monde" },
		description = "Les Elfes anciens se sont retires du monde apres la Grande Fracture. Ils surveillent l'equilibre naturel et interviennent rarement dans les affaires des autres races.",
		alignment = "neutral",
		ruler = "Conseil des Anciens",
	},
	{
		name = "Lignees Libres",
		capital = nil,
		villages = {},
		forts = {},
		pointsOfInterest = {},
		description = "Mercenaires et aventuriers sans allegeance. Vendent leurs services au plus offrant. Populaires dans les zonesfrontalieres.",
		alignment = "neutral",
		ruler = "Aucun (structure horizontale)",
	},
	{
		name = "Faction Demoniaque",
		capital = "Les Abysses",
		villages = {},
		forts = {},
		pointsOfInterest = { "Portails demoniaques", "Terres corrompues" },
		description = "Les serviteurs de Malachar, dormant dans les Abysses en attente de son reveil. Certains cultistes humains les servent dans l'ombre.",
		alignment = "evil",
		ruler = "Malachar (Dormant)",
	},
	{
		name = "Academie Royale",
		capital = nil,
		villages = {},
		forts = {},
		pointsOfInterest = { "Bibliotheque Centrale", "Tour d'etude" },
		description = "Institution d'apprentissage neutre formant les jeunes de toutes les factions. Connue pour son enseignement de la magie et des arts martiaux.",
		alignment = "neutral",
		ruler = "Recteur: a determiner",
	},
}

-- ============================================
-- POLITICAL SYSTEM
-- ============================================

local POLITICAL_SYSTEM = [[
# Systeme Politique d'Aethelgard

## Royaumes Humains
Le systeme politique humain est base sur la monarchie hereditaire avec une structure feodale:

- **Monarque (Roi/Reine)**: Autorite supreme, gere les relations etrangeres et la guerre
- **Ducs**: Gerent les grandes regions, commandent les armees regionales
- **Comtes**: Administrent les territoires specifiques, collectent les impots
- **Maisons Mineures**: Nobles locaux au service des comtes
- **Roturiers**: Paysans, artisans, marchands - la base de l'economie

## Theocratie de Jamluan
Systeme religieux ou le Grand Pretre est a la fois chef spirituel et temporel:
- Les pretres interpretent la volonte des dieux
- Le Temple de l'Aube possede sa propre armee: les Chevaliers de l'Aube
- Decisions prises par consensus du conseil des pretres aines

## Relations Inter-factions
- **Khiz vs Jamluan**: Rivaux historiques, alliance fragile contre la menace demoniaque
- **Khiz vs Elfes**: Relations commerciales cordiales mais distantes
- **Jamluan vs Demons**: Ennemis jures, gardiens du sceau
- **Lignees Libres**: Neutres, vendent leurs services a tous
- **Academie**: Neutre, accepte les etudiants de toutes les factions
]]

-- ============================================
-- CALENDAR
-- ============================================

local CALENDAR = {
	daysInWeek = 7,
	monthsInYear = 12,
	eraName = "ere du Second Aube",
}

-- ============================================
-- EXPORT
-- ============================================

local WorldData = {}

function WorldData.getWorldName(): string
	return "Aethelgard"
end

function WorldData.getHistory(): string
	return WORLD_HISTORY
end

function WorldData.getGenesis(): string
	return GENESIS
end

function WorldData.getCurrentAge(): string
	return "2280+ (ere du Second Aube)"
end

function WorldData.getMagicRules(): { MagicRule }
	return MAGIC_RULES
end

function WorldData.getCreatures(): { CreatureInfo }
	return CREATURES
end

function WorldData.getFactions(): { FactionInfo }
	return FACTIONS
end

function WorldData.getPoliticalSystem(): string
	return POLITICAL_SYSTEM
end

function WorldData.getCalendar()
	return CALENDAR
end

function WorldData.getFactionByName(factionName: string): FactionInfo?
	for _, faction in ipairs(FACTIONS) do
		if faction.name == factionName then
			return faction
		end
	end
	return nil
end

function WorldData.getFactionsByAlignment(alignment: "good" | "evil" | "neutral"): { FactionInfo }
	local result = {}
	for _, faction in ipairs(FACTIONS) do
		if faction.alignment == alignment then
			table.insert(result, faction)
		end
	end
	return result
end

function WorldData.getCreatureByName(creatureName: string): CreatureInfo?
	for _, creature in ipairs(CREATURES) do
		if creature.name == creatureName then
			return creature
		end
	end
	return nil
end

function WorldData.getCreaturesByDangerLevel(maxDanger: number): { CreatureInfo }
	local result = {}
	for _, creature in ipairs(CREATURES) do
		if creature.dangerLevel <= maxDanger then
			table.insert(result, creature)
		end
	end
	return result
end

return WorldData
