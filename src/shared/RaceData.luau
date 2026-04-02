--!nonstrict
-- Race configuration data (data only, no functions)

export type RaceInfo = {
	id: string,
	name: string,
	displayName: string?,
	description: string,
	playable: boolean?,
	preferredClasses: { string }?,
	color: Color3?,
}

export type RaceCategory = {
	category: string,
	races: { RaceInfo },
}

local RACE_DATA: { RaceCategory } = {
	{
		category = "Free Peoples",
		races = {
			{ id = "human", name = "Human", displayName = "Humain", description = "Adaptable and numerous race", playable = true, preferredClasses = {"Warrior", "Mage", "Rogue"}, color = Color3.fromRGB(210, 180, 140) },
			{ id = "elf", name = "Elf", displayName = "Elfe", description = "Ancient and mystical race", playable = true, preferredClasses = {"Mage", "Archer", "Druid"}, color = Color3.fromRGB(194, 178, 128) },
			{ id = "dwarf", name = "Dwarf", displayName = "Nain", description = "Legendary artisans and warriors", playable = true, preferredClasses = {"Warrior", "Knight"}, color = Color3.fromRGB(139, 90, 43) },
			{ id = "halfling", name = "Halfling", displayName = "Halfelin", description = "Small discreet beings, experts in stealth", playable = true, preferredClasses = {"Rogue", "Bard"}, color = Color3.fromRGB(205, 133, 63) },
			{ id = "gnome", name = "Gnome", displayName = "Gnome", description = "Inventors and scholars of the arcane", playable = true, preferredClasses = {"Mage", "Alchemist", "Bard"}, color = Color3.fromRGB(255, 218, 185) },
		},
	},
	{
		category = "Warrior Peoples",
		races = {
			{ id = "orc", name = "Orc", displayName = "Orc", description = "Fierce warriors from the wild lands", playable = true, preferredClasses = {"Warrior", "Knight"}, color = Color3.fromRGB(85, 107, 47) },
			{ id = "half-orc", name = "Half-Orc", displayName = "Demi-Orc", description = "Born of human and orc blood", playable = true, preferredClasses = {"Warrior", "Barbarian", "Ranger"}, color = Color3.fromRGB(107, 142, 35) },
		},
	},
	{
		category = "Magical Peoples",
		races = {
			{ id = "tiefling", name = "Tiefling", displayName = "Tiefling", description = "Descendants of demons", playable = true, preferredClasses = {"Mage", "Necromancer", "Bard"}, color = Color3.fromRGB(139, 0, 0) },
			{ id = "aasimar", name = "Aasimar", displayName = "Aasimar", description = "Blessed with celestial blood", playable = true, preferredClasses = {"Paladin", "Cleric", "Sorcerer"}, color = Color3.fromRGB(255, 250, 205) },
		},
	},
	{
		category = "Ancient Peoples",
		races = {
			{ id = "dragonborn", name = "Dragonborn", displayName = "Dracné", description = "Born of dragons, proud and powerful", playable = true, preferredClasses = {"Warrior", "Sorcerer", "Paladin"}, color = Color3.fromRGB(255, 140, 0) },
		},
	},
}

return RACE_DATA
