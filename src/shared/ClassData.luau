--!nonstrict
-- Class configuration data (data only, no functions)

export type ClassInfo = {
	id: string,
	name: string,
	displayName: string,
	description: string,
	baseStats: { [string]: number }?,
	primaryStat: string?,
	playstyle: string?,
}

export type ClassCategory = {
	category: string,
	classes: { ClassInfo },
}

local CLASS_DATA: { ClassCategory } = {
	{
		category = "Physical Combat",
		classes = {
			{ id = "warrior", name = "Warrior", displayName = "Guerrier", description = "Versatile fighter, master of melee combat", baseStats = {Strength = 10, Agility = 7, Intelligence = 5, Wisdom = 5, Vitality = 10, Luck = 3}, primaryStat = "Strength", playstyle = "Tank" },
			{ id = "knight", name = "Knight", displayName = "Chevalier", description = "Armored warrior, ally protection", baseStats = {Strength = 8, Agility = 5, Intelligence = 5, Wisdom = 7, Vitality = 12, Luck = 3}, primaryStat = "Vitality", playstyle = "Tank" },
			{ id = "rogue", name = "Rogue", displayName = "Voleur", description = "Expert in quick combat and stealth", baseStats = {Strength = 6, Agility = 12, Intelligence = 6, Wisdom = 5, Vitality = 5, Luck = 6}, primaryStat = "Agility", playstyle = "DPS" },
			{ id = "archer", name = "Archer", displayName = "Archer", description = "Ranged combat specialist", baseStats = {Strength = 7, Agility = 10, Intelligence = 6, Wisdom = 5, Vitality = 6, Luck = 6}, primaryStat = "Agility", playstyle = "DPS" },
		},
	},
	{
		category = "Magic",
		classes = {
			{ id = "mage", name = "Mage", displayName = "Mage", description = "Master of elemental magic", baseStats = {Strength = 3, Agility = 5, Intelligence = 12, Wisdom = 8, Vitality = 4, Luck = 3}, primaryStat = "Intelligence", playstyle = "Magic DPS" },
			{ id = "necromancer", name = "Necromancer", displayName = "Necromancien", description = "Master of dark arts", baseStats = {Strength = 4, Agility = 4, Intelligence = 10, Wisdom = 8, Vitality = 6, Luck = 3}, primaryStat = "Intelligence", playstyle = "Magic DPS" },
			{ id = "priest", name = "Priest", displayName = "Pretre", description = "Servant of the gods, healer", baseStats = {Strength = 4, Agility = 5, Intelligence = 8, Wisdom = 12, Vitality = 6, Luck = 5}, primaryStat = "Wisdom", playstyle = "Healer" },
			{ id = "druid", name = "Druid", displayName = "Druide", description = "Harmony with nature, shapeshifter", baseStats = {Strength = 5, Agility = 6, Intelligence = 8, Wisdom = 10, Vitality = 7, Luck = 4}, primaryStat = "Wisdom", playstyle = "Hybrid" },
		},
	},
	{
		category = "Hybrids",
		classes = {
			{ id = "paladin", name = "Paladin", displayName = "Paladin", description = "Holy warrior, combat and divine magic", baseStats = {Strength = 9, Agility = 5, Intelligence = 6, Wisdom = 8, Vitality = 10, Luck = 4}, primaryStat = "Strength", playstyle = "Hybrid" },
			{ id = "bard", name = "Bard", displayName = "Barde", description = "Traveling artist, support and charm", baseStats = {Strength = 5, Agility = 8, Intelligence = 8, Wisdom = 6, Vitality = 6, Luck = 9}, primaryStat = "Charisma", playstyle = "Support" },
			{ id = "monk", name = "Monk", displayName = "Moine", description = "Martial arts master", baseStats = {Strength = 8, Agility = 10, Intelligence = 6, Wisdom = 10, Vitality = 8, Luck = 4}, primaryStat = "Agility", playstyle = "DPS" },
		},
	},
}

return CLASS_DATA
