--!nonstrict
-- Shared race configuration data
-- This module contains all race definitions used by both client and server
-- Format similar to TeamData for UI compatibility

export type RaceInfo = {
	name: string,
	emoji: string,
	slots: number, -- -1 for unlimited
	description: string,
	perks: string,
}

export type CategoryData = {
	category: string,
	races: { RaceInfo },
}

-- Race data organized by category with emojis
local RACE_DATA: { CategoryData } = {
	{
		category = "Free Peoples",
		races = {
			{ name = "Human", emoji = "👤", slots = -1, description = "Adaptable and numerous race, from the kingdoms of Khiz and Jamluan", perks = "+1 all stats, +10% XP, +5% reputation" },
			{ name = "Elf", emoji = "🧝", slots = -1, description = "Ancient and mystical race, guardians of sacred forests", perks = "+2 INT/WIS, elven vision, +10% dodge" },
			{ name = "Dwarf", emoji = "⛏️", slots = -1, description = "Legendary artisans and warriors, masters of the forge", perks = "+2 VIT, +20% craft, darkvision" },
			{ name = "Halfling", emoji = "🧒", slots = -1, description = "Small discreet beings, experts in stealth and luck", perks = "+2 AGI/LCK, stealth, natural luck" },
		},
	},
	{
		category = "Warrior Peoples",
		races = {
			{ name = "Orc", emoji = "👹", slots = -1, description = "Fierce warriors from the wild lands", perks = "+3 STR, combat rage, physical resistance" },
		},
	},
	{
		category = "Magical Peoples",
		races = {
			{ name = "Tiefling", emoji = "😈", slots = -1, description = "Descendants of demons, marked by their infernal heritage", perks = "+2 INT, magical resistance, darkvision" },
		},
	},
	{
		category = "Demonic Faction",
		races = {
			{ name = "Demon", emoji = "👿", slots = -1, description = "Creatures of the abyss, powerful but feared", perks = "Demonic abilities, superhuman strength, fire immunity" },
		},
	},
}

-- Race colors by category
local RACE_COLORS: { [string]: BrickColor } = {
	["Free Peoples"] = BrickColor.new("Bright green"),
	["Warrior Peoples"] = BrickColor.new("Bright red"),
	["Magical Peoples"] = BrickColor.new("Bright violet"),
	["Demonic Faction"] = BrickColor.new("Dark red"),
}

-- Build a lookup table for quick race info access
local RACE_LOOKUP: { [string]: RaceInfo } = {}
for _, category in ipairs(RACE_DATA) do
	for _, raceInfo in ipairs(category.races) do
		RACE_LOOKUP[raceInfo.name] = raceInfo
	end
end

local RaceData = {}

-- Get all race data
function RaceData.getRaceData(): { CategoryData }
	return RACE_DATA
end

-- Get race colors mapping
function RaceData.getRaceColors(): { [string]: BrickColor }
	return RACE_COLORS
end

-- Get race info by name
function RaceData.getRaceInfo(raceName: string): RaceInfo?
	return RACE_LOOKUP[raceName]
end

-- Check if race name is valid
function RaceData.isValidRace(raceName: string): boolean
	return RACE_LOOKUP[raceName] ~= nil
end

-- Get all race names
function RaceData.getAllRaceNames(): { string }
	local names = {}
	for name, _ in pairs(RACE_LOOKUP) do
		table.insert(names, name)
	end
	return names
end

return RaceData