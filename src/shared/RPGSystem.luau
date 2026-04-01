--!nonstrict
-- RPG System for Aethelgard
-- Contains character classes, stats, skills, equipment, and combat rules

export type StatType = "Strength" | "Agility" | "Intelligence" | "Wisdom" | "Vitality" | "Luck"

export type StatInfo = {
	name: StatType,
	displayName: string,
	description: string,
}

export type SkillInfo = {
	id: string,
	name: string,
	description: string,
	category: string,
	maxLevel: number,
	prerequisites: { string }?,
	effects: { string },
}

export type ClassInfo = {
	name: string,
	description: string,
	baseStats: { [StatType]: number },
	primaryStat: StatType,
	availableSkills: { string },
	weaponProficiencies: { string },
	armorProficiencies: { string },
	playstyle: string,
}

export type ItemType = "Weapon" | "Armor" | "Accessory" | "Consumable" | "Material" | "Quest"

export type ItemRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic"

export type ItemInfo = {
	id: string,
	name: string,
	type: ItemType,
	rarity: ItemRarity,
	description: string,
	stats: { [string]: number }?,
	requirements: { [StatType]: number }?,
	effects: { string }?,
	value: number,
	icon: string,
}

export type EquipmentSlot = "Weapon" | "Head" | "Chest" | "Legs" | "Feet" | "Hands" | "Accessory1" | "Accessory2"

export type PlayerStats = {
	Strength: number,
	Agility: number,
	Intelligence: number,
	Wisdom: number,
	Vitality: number,
	Luck: number,
}

export type PlayerSkills = {
	[string]: number,
}

export type PlayerEquipment = {
	[EquipmentSlot]: string?,
}

export type RPGSystem = {
	-- Stats
	getStats: () -> { StatInfo },
	getStatByName: (statName: string) -> StatInfo?,
	
	-- Classes
	getClasses: () -> { ClassInfo },
	getClassByName: (className: string) -> ClassInfo?,
	getClassesByPlaystyle: (playstyle: string) -> { ClassInfo },
	
	-- Skills
	getSkills: () -> { SkillInfo },
	getSkillById: (skillId: string) -> SkillInfo?,
	getSkillsByCategory: (category: string) -> { SkillInfo },
	getSkillTree: (className: string) -> { SkillInfo },
	
	-- Items
	getItems: () -> { ItemInfo },
	getItemById: (itemId: string) -> ItemInfo?,
	getItemsByType: (itemType: ItemType) -> { ItemInfo },
	getItemsByRarity: (rarity: ItemRarity) -> { ItemInfo },
	getEquipmentSlots: () -> { EquipmentSlot },
	
	-- Leveling
	calculateExpForLevel: (level: number) -> number,
	calculateStatGrowth: (baseStat: number, level: number, statType: StatType) -> number,
	
	-- Combat
	calculateDamage: (attack: number, defense: number, weaponDamage: number, critical: boolean) -> number,
	calculateCriticalChance: (luck: number, agility: number) -> number,
	calculateDodgeChance: (agility: number) -> number,
	calculateBlockChance: (vitality: number) -> number,
	calculateHitChance: (agility: number, enemyAgility: number) -> number,
}

-- ============================================
-- STATS DEFINITION
-- ============================================

local STATS: { StatInfo } = {
	{
		name = "Strength",
		displayName = "Force",
		description = "Determine les dommages physiques et la capacite de port.",
	},
	{
		name = "Agility",
		displayName = "Agilite",
		description = "Affecte la vitesse d'attaque, l'esquive et les chances de coup critique.",
	},
	{
		name = "Intelligence",
		displayName = "Intelligence",
		description = "Determine les dommages magiques et la resistance magique.",
	},
	{
		name = "Wisdom",
		displayName = "Sagesse",
		description = "Affecte la regeneration de mana et l'efficacite des soins.",
	},
	{
		name = "Vitality",
		displayName = "Vitalite",
		description = "Determine les points de vie maximum et la defense physique.",
	},
	{
		name = "Luck",
		displayName = "Chance",
		description = "Affecte les chances de coup critique, les loot et les evenements aleatoires.",
	},
}

-- ============================================
-- CHARACTER CLASSES
-- ============================================

local CLASSES: { ClassInfo } = {
	-- Classes de combat physique
	{
		name = "Guerrier",
		description = "Combattant polyvalent maitrisant toutes les armes. Specialise dans le combat au corps a corps.",
		baseStats = {
			Strength = 10,
			Agility = 7,
			Intelligence = 5,
			Wisdom = 5,
			Vitality = 10,
			Luck = 3,
		},
		primaryStat = "Strength",
		availableSkills = { "power_strike", "shield_bash", "battle_cry", "armor_mastery", "second_wind" },
		weaponProficiencies = { "epee", "Hache", "Marteau", "Bouclier" },
		armorProficiencies = { "Lourd", "Moyen" },
		playstyle = "Tank",
	},
	{
		name = "Chevalier",
		description = "Guerrier blinde specialise dans la defense et la protection des allies.",
		baseStats = {
			Strength = 8,
			Agility = 5,
			Intelligence = 5,
			Wisdom = 7,
			Vitality = 12,
			Luck = 3,
		},
		primaryStat = "Vitality",
		availableSkills = { "shield_wall", "holy_strike", "defensive_stance", "intervene", "iron_skin" },
		weaponProficiencies = { "epee", "Lance", "Bouclier" },
		armorProficiencies = { "Lourd" },
		playstyle = "Tank",
	},
	{
		name = "Voleur",
		description = "Expert en combat rapide et subtilite. Utilise les attaques critiques et l'esquive.",
		baseStats = {
			Strength = 6,
			Agility = 12,
			Intelligence = 6,
			Wisdom = 5,
			Vitality = 5,
			Luck = 6,
		},
		primaryStat = "Agility",
		availableSkills = { "backstab", "stealth", "poison_blade", "shadow_step", "critical_strike" },
		weaponProficiencies = { "Dague", "Arc", "Shuriken" },
		armorProficiencies = { "Leger" },
		playstyle = "DPS",
	},
	{
		name = "Archer",
		description = "Specialiste du combat a distance. Expert en tir de precision et tactiques de groupe.",
		baseStats = {
			Strength = 7,
			Agility = 10,
			Intelligence = 6,
			Wisdom = 5,
			Vitality = 6,
			Luck = 6,
		},
		primaryStat = "Agility",
		availableSkills = { "precise_shot", "multi_shot", "trap_mastery", "eagle_eye", "evasion" },
		weaponProficiencies = { "Arc", "Arbalete" },
		armorProficiencies = { "Leger", "Moyen" },
		playstyle = "DPS",
	},
	
	-- Classes magiques
	{
		name = "Mage",
		description = "Maitre des arts magiques elementaires. Puissant mais fragile.",
		baseStats = {
			Strength = 3,
			Agility = 5,
			Intelligence = 12,
			Wisdom = 8,
			Vitality = 4,
			Luck = 3,
		},
		primaryStat = "Intelligence",
		availableSkills = { "fireball", "ice_storm", "lightning_bolt", "mana_shield", "teleport" },
		weaponProficiencies = { "Baton", "Sceptre" },
		armorProficiencies = { "Toge" },
		playstyle = "DPS Magique",
	},
	{
		name = "Necromancien",
		description = "Maitre des arts obscurs, invoque des serviteurs morts-vivants.",
		baseStats = {
			Strength = 4,
			Agility = 4,
			Intelligence = 10,
			Wisdom = 8,
			Vitality = 6,
			Luck = 3,
		},
		primaryStat = "Intelligence",
		availableSkills = { "raise_dead", "soul_drain", "dark_arrow", "death_coil", "life_transfer" },
		weaponProficiencies = { "Baton", "Dague" },
		armorProficiencies = { "Toge", "Leger" },
		playstyle = "Support",
	},
	{
		name = "Pretre",
		description = "Serviteur des dieux, specialise dans la guerison et la protection.",
		baseStats = {
			Strength = 5,
			Agility = 4,
			Intelligence = 8,
			Wisdom = 12,
			Vitality = 6,
			Luck = 5,
		},
		primaryStat = "Wisdom",
		availableSkills = { "heal", "holy_shield", "blessing", "resurrection", "purify" },
		weaponProficiencies = { "Baton", "Sceptre" },
		armorProficiencies = { "Toge", "Moyen" },
		playstyle = "Healer",
	},
	{
		name = "Druide",
		description = "Harmonie avec la nature, peut se transformer et invoquer des creatures naturelles.",
		baseStats = {
			Strength = 6,
			Agility = 6,
			Intelligence = 8,
			Wisdom = 10,
			Vitality = 7,
			Luck = 3,
		},
		primaryStat = "Wisdom",
		availableSkills = { "wild_shape", "nature_heal", "thorns", "animal_companion", "entangle" },
		weaponProficiencies = { "Baton", "Dague" },
		armorProficiencies = { "Leger", "Moyen" },
		playstyle = "Support",
	},
	
	-- Classes hybrides
	{
		name = "Paladin",
		description = "Guerrier sacre combinant combat physique et magie divine.",
		baseStats = {
			Strength = 9,
			Agility = 5,
			Intelligence = 6,
			Wisdom = 8,
			Vitality = 9,
			Luck = 3,
		},
		primaryStat = "Strength",
		availableSkills = { "holy_strike", "divine_shield", "lay_on_hands", "aura_protection", "smite" },
		weaponProficiencies = { "epee", "Marteau", "Bouclier" },
		armorProficiencies = { "Lourd", "Moyen" },
		playstyle = "Tank",
	},
	{
		name = "Barde",
		description = "Support musical qui renforce les allies et affaiblit les ennemis par des melodies magiques.",
		baseStats = {
			Strength = 4,
			Agility = 7,
			Intelligence = 8,
			Wisdom = 7,
			Vitality = 5,
			Luck = 9,
		},
		primaryStat = "Luck",
		availableSkills = { "inspiring_song", "lullaby", "charm", "battle_anthem", "counter_melody" },
		weaponProficiencies = { "Instrument", "Dague" },
		armorProficiencies = { "Leger", "Moyen" },
		playstyle = "Support",
	},
	{
		name = "Moine",
		description = "Art martial base sur l'energie interieure. Combat sans arme, rapide et precis.",
		baseStats = {
			Strength = 8,
			Agility = 10,
			Intelligence = 6,
			Wisdom = 7,
			Vitality = 7,
			Luck = 4,
		},
		primaryStat = "Agility",
		availableSkills = { "fist_fury", "chi_block", "healing_zen", "flurry", "inner_peace" },
		weaponProficiencies = { "Poings" },
		armorProficiencies = { "Leger" },
		playstyle = "DPS",
	},
	{
		name = "Invocateur",
		description = "Appelle des creatures magiques pour combattre a ses cotes.",
		baseStats = {
			Strength = 4,
			Agility = 5,
			Intelligence = 10,
			Wisdom = 9,
			Vitality = 5,
			Luck = 5,
		},
		primaryStat = "Intelligence",
		availableSkills = { "summon_spirit", "summon_beast", "summon_elemental", "bond_life", "master_summoner" },
		weaponProficiencies = { "Baton" },
		armorProficiencies = { "Toge", "Leger" },
		playstyle = "Support",
	},
}

-- ============================================
-- SKILLS
-- ============================================

local SKILLS: { SkillInfo } = {
	-- Competences de Guerrier
	{
		id = "power_strike",
		name = "Coup Puissant",
		description = "Attaque devastatrice utilisant toute la force.",
		category = "Combat",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Degats +20% par niveau", "Cout: 10 mana" },
	},
	{
		id = "shield_bash",
		name = "Coup de Bouclier",
		description = "Assomme l'ennemi avec le bouclier.",
		category = "Combat",
		maxLevel = 3,
		prerequisites = {},
		effects = { "etourdissement 2 secondes", "Degets physiques" },
	},
	{
		id = "battle_cry",
		name = "Cri de Bataille",
		description = "Rugit pour intimider les ennemis et renforcer les allies.",
		category = "Soutien",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Reduction defense ennemie -10%", "Force allies +5%" },
	},
	{
		id = "armor_mastery",
		name = "Maitrise de l'Armure",
		description = "Expertise dans le port des armures lourdes.",
		category = "Passif",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Defense +5% par niveau", "Penalite d'armure reduite" },
	},
	{
		id = "second_wind",
		name = "Second Souffle",
		description = "Ressource l'energie en situation critique.",
		category = "Passif",
		maxLevel = 1,
		prerequisites = { "Vitality 30" },
		effects = { "Restauration 30% PV une fois par combat" },
	},
	
	-- Competences de Voleur
	{
		id = "backstab",
		name = "Coup de Dague",
		description = "Attaque par derriere causant des dommages accrus.",
		category = "Combat",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Degats +50% par derriere", "Critique +10%" },
	},
	{
		id = "stealth",
		name = "Furtivite",
		description = "Devient invisible pour une duree limitee.",
		category = "Support",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Invisibilite 10 secondes", "Vitesse +20%" },
	},
	{
		id = "poison_blade",
		name = "Lame Empoisonnee",
		description = "Appliques un poison sur l'arme.",
		category = "Combat",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Degats de poison 5 secondes", "Reduction soins ennemi -50%" },
	},
	{
		id = "shadow_step",
		name = "Pas de l'Ombre",
		description = "Teleportation eclair vers une cible.",
		category = "Mouvement",
		maxLevel = 3,
		prerequisites = { "stealth:2" },
		effects = { "Teleportation 20 unites", "Degats instantanes a l'arrivee" },
	},
	{
		id = "critical_strike",
		name = "Frappe Critique",
		description = "Technique de combat augmentant les chances de critique.",
		category = "Passif",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Chance critique +3% par niveau", "Degats critiques +10%" },
	},
	
	-- Competences de Mage
	{
		id = "fireball",
		name = "Boule de Feu",
		description = "Projette une boule de feu explosive.",
		category = "Magie",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Degats de feu", "Zone d'effet 5 unites", "Cout: 20 mana" },
	},
	{
		id = "ice_storm",
		name = "Tempete de Glace",
		description = "Tempete de glace ralentissant les ennemis.",
		category = "Magie",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Deguts de glace", "Ralentissement 50% 3 secondes", "Cout: 30 mana" },
	},
	{
		id = "lightning_bolt",
		name = "eclair",
		description = "Foudre tombant sur la cible.",
		category = "Magie",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Deguts electriques", "Chaine jusqu'a 3 cibles", "Cout: 25 mana" },
	},
	{
		id = "mana_shield",
		name = "Bouclier de Mana",
		description = "Absorbe les degats avec le mana.",
		category = "Defense",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Absorbe 50% degats", "Convertit en mana", "Cout: 15 mana/sec" },
	},
	{
		id = "teleport",
		name = "Teleportation",
		description = "Se teleporte instantanement.",
		category = "Mouvement",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Teleportation 50 unites", "Cout: 30 mana" },
	},
	
	-- Competences de Pretre
	{
		id = "heal",
		name = "Soin",
		description = "Restaure les points de vie d'un allie.",
		category = "Soutien",
		maxLevel = 5,
		prerequisites = {},
		effects = { "Soin 50 + 10/niveau", "Cout: 20 mana" },
	},
	{
		id = "holy_shield",
		name = "Bouclier Sacre",
		description = "Protege contre les attaques demoniaques.",
		category = "Defense",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Invulnerabilite 3 secondes", "Deguts reflechis 50%", "Cout: 40 mana" },
	},
	{
		id = "blessing",
		name = "Benediction",
		description = "Augmente les statistiques d'un allie.",
		category = "Soutien",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Tous stats +10% 60 secondes", "Cout: 35 mana" },
	},
	{
		id = "resurrection",
		name = "Resurrection",
		description = "Ressuscite un allie mort.",
		category = "Soutien",
		maxLevel = 1,
		prerequisites = { "Wisdom 40" },
		effects = { "Ressuscite a 50% PV", "Cout: 100 mana", "Temps de cast 5 secondes" },
	},
	{
		id = "purify",
		name = "Purification",
		description = "Supprime les effets negatifs.",
		category = "Soutien",
		maxLevel = 3,
		prerequisites = {},
		effects = { "Supprime tous debuffs", "Soin poison/brulure", "Cout: 25 mana" },
	},
}

-- ============================================
-- ITEMS
-- ============================================

local ITEMS: { ItemInfo } = {
	-- Armes
	{
		id = "sword_iron",
		name = "epee de Fer",
		type = "Weapon",
		rarity = "Common",
		description = "Une epee en fer de qualite standard.",
		stats = { Damage = 10, AttackSpeed = 1.0 },
		requirements = { Strength = 5 },
		effects = {},
		value = 50,
		icon = "⚔️",
	},
	{
		id = "sword_steel",
		name = "epee d'Acier",
		type = "Weapon",
		rarity = "Uncommon",
		description = "Une epee en acier forgee par un artisan competent.",
		stats = { Damage = 18, AttackSpeed = 1.0 },
		requirements = { Strength = 10 },
		effects = {},
		value = 150,
		icon = "⚔️",
	},
	{
		id = "sword_legendary_aldric",
		name = "epee d'Aldric",
		type = "Weapon",
		rarity = "Mythic",
		description = "L'epee legendaire du heros qui a vaincu Malachar. Rayonne de lumiere sacree.",
		stats = { Damage = 100, AttackSpeed = 1.2, Strength = 20, Luck = 10 },
		requirements = { Strength = 50, Vitality = 30 },
		effects = { "Deguts supplementaires contre les demons", "Benediction de la lumiere" },
		value = 10000,
		icon = "✨⚔️✨",
	},
	{
		id = "staff_wood",
		name = "Baton de Bois",
		type = "Weapon",
		rarity = "Common",
		description = "Un baton simple pour les apprentis mages.",
		stats = { Damage = 5, MagicDamage = 10, AttackSpeed = 1.3 },
		requirements = { Intelligence = 5 },
		effects = {},
		value = 30,
		icon = "🪵",
	},
	{
		id = "staff_crystal",
		name = "Baton de Cristal",
		type = "Weapon",
		rarity = "Rare",
		description = "Un baton integrant un cristal magique.",
		stats = { Damage = 8, MagicDamage = 35, AttackSpeed = 1.3, Intelligence = 10 },
		requirements = { Intelligence = 20 },
		effects = { "Regeneration mana +5" },
		value = 500,
		icon = "🔮",
	},
	{
		id = "dagger_iron",
		name = "Dague de Fer",
		type = "Weapon",
		rarity = "Common",
		description = "Une dague legere pour les voleurs.",
		stats = { Damage = 8, AttackSpeed = 1.5 },
		requirements = { Agility = 5 },
		effects = {},
		value = 40,
		icon = "🗡️",
	},
	{
		id = "bow_hunter",
		name = "Arc de Chasseur",
		type = "Weapon",
		rarity = "Common",
		description = "Un arc robuste pour la chasse.",
		stats = { Damage = 12, AttackSpeed = 1.2, Range = 50 },
		requirements = { Agility = 5 },
		effects = {},
		value = 60,
		icon = "🏹",
	},
	{
		id = "shield_wood",
		name = "Bouclier de Bois",
		type = "Weapon",
		rarity = "Common",
		description = "Un bouclier basique en bois.",
		stats = { Defense = 10, BlockChance = 15 },
		requirements = { Vitality = 5 },
		effects = {},
		value = 35,
		icon = "🛡️",
	},
	{
		id = "shield_iron",
		name = "Bouclier de Fer",
		type = "Weapon",
		rarity = "Uncommon",
		description = "Un bouclier en fer offrant une bonne protection.",
		stats = { Defense = 20, BlockChance = 25 },
		requirements = { Vitality = 10 },
		effects = {},
		value = 120,
		icon = "🛡️",
	},
	
	-- Armures
	{
		id = "armor_leather",
		name = "Armure de Cuir",
		type = "Armor",
		rarity = "Common",
		description = "Une armure legere en cuir.",
		stats = { Defense = 8, Agility = 2 },
		requirements = {},
		effects = {},
		value = 45,
		icon = "🥋",
	},
	{
		id = "armor_chain",
		name = "Cotte de Mailles",
		type = "Armor",
		rarity = "Uncommon",
		description = "Une armure de mailles offrant un bon equilibre.",
		stats = { Defense = 18, Vitality = 5 },
		requirements = { Vitality = 10 },
		effects = {},
		value = 200,
		icon = "🕸️",
	},
	{
		id = "armor_plate",
		name = "Armure de Plates",
		type = "Armor",
		rarity = "Rare",
		description = "Une armure complete en metal.",
		stats = { Defense = 35, Vitality = 15, Strength = 5 },
		requirements = { Vitality = 25, Strength = 15 },
		effects = { "Reduction速度 -10%" },
		value = 800,
		icon = "🛡️",
	},
	{
		id = "robe_cloth",
		name = "Robe de Toge",
		type = "Armor",
		rarity = "Common",
		description = "Une robe confortable pour mages.",
		stats = { Defense = 5, MagicDefense = 10, Intelligence = 3 },
		requirements = {},
		effects = {},
		value = 40,
		icon = "👘",
	},
	{
		id = "robe_arcane",
		name = "Robe Arcanique",
		type = "Armor",
		rarity = "Epic",
		description = "Une robe enchantee augmentant les pouvoirs magiques.",
		stats = { Defense = 12, MagicDefense = 30, Intelligence = 15, Wisdom = 10 },
		requirements = { Intelligence = 30 },
		effects = { "Cout magie -10%" },
		value = 1500,
		icon = "🧙",
	},
	
	-- Accessoires
	{
		id = "ring_copper",
		name = "Anneau de Cuivre",
		type = "Accessory",
		rarity = "Common",
		description = "Un simple anneau en cuivre.",
		stats = { Luck = 2 },
		requirements = {},
		effects = {},
		value = 25,
		icon = "💍",
	},
	{
		id = "amulet_healing",
		name = "Amulette de Guerison",
		type = "Accessory",
		rarity = "Uncommon",
		description = "Une amulette permettant une regeneration plus rapide.",
		stats = { Vitality = 5, Wisdom = 5 },
		requirements = {},
		effects = { "Regeneration PV +2/sec" },
		value = 180,
		icon = "📿",
	},
	{
		id = "cloak_shadows",
		name = "Cape des Ombres",
		type = "Accessory",
		rarity = "Rare",
		description = "Une cape enchantee permettant de se fondre dans l'ombre.",
		stats = { Agility = 10, Luck = 5 },
		requirements = { Agility = 20 },
		effects = { "Furtivite +20%" },
		value = 600,
		icon = "🧥",
	},
	
	-- Consommables
	{
		id = "potion_health",
		name = "Potion de Vie",
		type = "Consumable",
		rarity = "Common",
		description = "Restaure 50 points de vie.",
		stats = {},
		requirements = {},
		effects = { "Soin 50 PV" },
		value = 20,
		icon = "❤️",
	},
	{
		id = "potion_mana",
		name = "Potion de Mana",
		type = "Consumable",
		rarity = "Common",
		description = "Restaure 50 points de mana.",
		stats = {},
		requirements = {},
		effects = { "Soin 50 mana" },
		value = 20,
		icon = "💙",
	},
	{
		id = "potion_health_large",
		name = "Grande Potion de Vie",
		type = "Consumable",
		rarity = "Uncommon",
		description = "Restaure 150 points de vie.",
		stats = {},
		requirements = {},
		effects = { "Soin 150 PV" },
		value = 60,
		icon = "💖",
	},
	{
		id = "antidote",
		name = "Antidote",
		type = "Consumable",
		rarity = "Common",
		description = "Guerit empoisonnement.",
		stats = {},
		requirements = {},
		effects = { "Supprime poison" },
		value = 15,
		icon = "💊",
	},
	
	-- Materiaux
	{
		id = "herb_healing",
		name = "Herbe Medicinale",
		type = "Material",
		rarity = "Common",
		description = "Une plante utilisee pour confectionner des potions.",
		stats = {},
		requirements = {},
		effects = {},
		value = 5,
		icon = "🌿",
	},
	{
		id = "ore_iron",
		name = "Minerai de Fer",
		type = "Material",
		rarity = "Common",
		description = "Du minerai de fer brut.",
		stats = {},
		requirements = {},
		effects = {},
		value = 10,
		icon = "🪨",
	},
	{
		id = "crystal_mana",
		name = "Cristal de Mana",
		type = "Material",
		rarity = "Uncommon",
		description = "Un cristal contenant de l'energie magique.",
		stats = {},
		requirements = {},
		effects = {},
		value = 50,
		icon = "💎",
	},
	{
		id = "scale_dragon",
		name = "ecailles de Dragon",
		type = "Material",
		rarity = "Legendary",
		description = "ecailles d'un dragon ancien, extremement precieuses.",
		stats = {},
		requirements = {},
		effects = { "Utilise pour forger equipements legendaires" },
		value = 5000,
		icon = "🐉",
	},
}

-- ============================================
-- EQUIPMENT SLOTS
-- ============================================

local EQUIPMENT_SLOTS: { EquipmentSlot } = {
	"Weapon",
	"Head",
	"Chest",
	"Legs",
	"Feet",
	"Hands",
	"Accessory1",
	"Accessory2",
}

-- ============================================
-- LEVELING FORMULAS
-- ============================================

-- Experience required for each level (exponential curve)
local function calculateExpForLevel(level: number): number
	-- Base: 100, increases by 50% each level
	return math.floor(100 * (1.5 ^ (level - 1)))
end

-- Stat growth based on level and base stat
local function calculateStatGrowth(baseStat: number, level: number, statType: StatType): number
	local growthRates: { [StatType]: number } = {
		Strength = 2.5,
		Agility = 2.5,
		Intelligence = 2.5,
		Wisdom = 2.5,
		Vitality = 3.0,
		Luck = 1.5,
	}
	
	local growth = growthRates[statType] or 2.0
	return math.floor(baseStat + (level * growth))
end

-- ============================================
-- COMBAT FORMULAS
-- ============================================

local function calculateDamage(attack: number, defense: number, weaponDamage: number, critical: boolean): number
	local baseDamage = attack + weaponDamage
	local mitigation = defense / (defense + 100) -- Diminishing returns
	local damage = baseDamage * (1 - mitigation)
	
	if critical then
		damage = damage * 1.5
	end
	
	return math.max(1, math.floor(damage))
end

local function calculateCriticalChance(luck: number, agility: number): number
	-- Base 5%, increases with luck and agility
	return math.min(50, 5 + (luck * 0.2) + (agility * 0.1))
end

local function calculateDodgeChance(agility: number): number
	-- Base 5%, increases with agility
	return math.min(40, 5 + (agility * 0.3))
end

local function calculateBlockChance(vitality: number): number
	-- Base 10%, increases with vitality
	return math.min(50, 10 + (vitality * 0.2))
end

local function calculateHitChance(agility: number, enemyAgility: number): number
	-- Base 85%, modified by agility difference
	local base = 85
	local modifier = (agility - enemyAgility) * 0.5
	return math.min(100, math.max(50, base + modifier))
end

-- ============================================
-- EXPORT
-- ============================================

local RPGSystem = {}

-- Stats
function RPGSystem.getStats(): { StatInfo }
	return STATS
end

function RPGSystem.getStatByName(statName: string): StatInfo?
	for _, stat in ipairs(STATS) do
		if stat.name == statName then
			return stat
		end
	end
	return nil
end

-- Classes
function RPGSystem.getClasses(): { ClassInfo }
	return CLASSES
end

function RPGSystem.getClassByName(className: string): ClassInfo?
	for _, class in ipairs(CLASSES) do
		if class.name == className then
			return class
		end
	end
	return nil
end

function RPGSystem.getClassesByPlaystyle(playstyle: string): { ClassInfo }
	local result = {}
	for _, class in ipairs(CLASSES) do
		if class.playstyle == playstyle then
			table.insert(result, class)
		end
	end
	return result
end

-- Skills
function RPGSystem.getSkills(): { SkillInfo }
	return SKILLS
end

function RPGSystem.getSkillById(skillId: string): SkillInfo?
	for _, skill in ipairs(SKILLS) do
		if skill.id == skillId then
			return skill
		end
	end
	return nil
end

function RPGSystem.getSkillsByCategory(category: string): { SkillInfo }
	local result = {}
	for _, skill in ipairs(SKILLS) do
		if skill.category == category then
			table.insert(result, skill)
		end
	end
	return result
end

function RPGSystem.getSkillTree(className: string): { SkillInfo }
	local classInfo = RPGSystem.getClassByName(className)
	if not classInfo then
		return {}
	end
	
	local result = {}
	for _, skillId in ipairs(classInfo.availableSkills) do
		local skill = RPGSystem.getSkillById(skillId)
		if skill then
			table.insert(result, skill)
		end
	end
	return result
end

-- Items
function RPGSystem.getItems(): { ItemInfo }
	return ITEMS
end

function RPGSystem.getItemById(itemId: string): ItemInfo?
	for _, item in ipairs(ITEMS) do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

function RPGSystem.getItemsByType(itemType: ItemType): { ItemInfo }
	local result = {}
	for _, item in ipairs(ITEMS) do
		if item.type == itemType then
			table.insert(result, item)
		end
	end
	return result
end

function RPGSystem.getItemsByRarity(rarity: ItemRarity): { ItemInfo }
	local result = {}
	for _, item in ipairs(ITEMS) do
		if item.rarity == rarity then
			table.insert(result, item)
		end
	end
	return result
end

function RPGSystem.getEquipmentSlots(): { EquipmentSlot }
	return EQUIPMENT_SLOTS
end

-- Leveling
function RPGSystem.calculateExpForLevel(level: number): number
	return calculateExpForLevel(level)
end

function RPGSystem.calculateStatGrowth(baseStat: number, level: number, statType: StatType): number
	return calculateStatGrowth(baseStat, level, statType)
end

-- Combat
function RPGSystem.calculateDamage(attack: number, defense: number, weaponDamage: number, critical: boolean): number
	return calculateDamage(attack, defense, weaponDamage, critical)
end

function RPGSystem.calculateCriticalChance(luck: number, agility: number): number
	return calculateCriticalChance(luck, agility)
end

function RPGSystem.calculateDodgeChance(agility: number): number
	return calculateDodgeChance(agility)
end

function RPGSystem.calculateBlockChance(vitality: number): number
	return calculateBlockChance(vitality)
end

function RPGSystem.calculateHitChance(agility: number, enemyAgility: number): number
	return calculateHitChance(agility, enemyAgility)
end

return RPGSystem
