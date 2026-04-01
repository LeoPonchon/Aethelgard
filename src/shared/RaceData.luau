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
		category = "Peuples Libres",
		races = {
			{ name = "Humain", emoji = "👤", slots = -1, description = "Race adaptable et nombreuse, originaire des royaumes de Khiz et Jamluan", perks = "+1 toutes stats, +10% XP, +5% réputation" },
			{ name = "Elfe", emoji = "🧝", slots = -1, description = "Race ancienne et mystique, gardiens des forêts sacrées", perks = "+2 INT/SAG, vision elfique, +10% esquive" },
			{ name = "Nain", emoji = "⛏️", slots = -1, description = "Artisans et guerriers légendaires, maîtres de la forge", perks = "+2 VIT, +20% craft, vision nocturne" },
			{ name = "Halfelin", emoji = "🧒", slots = -1, description = "Petits êtres discrets, experts en discrétion et chance", perks = "+2 AGI/CHC, furtivité, chance naturelle" },
		},
	},
	{
		category = "Peuples Guerriers",
		races = {
			{ name = "Orc", emoji = "👹", slots = -1, description = "Guerriers féroces des terres sauvages", perks = "+3 FOR, rage de combat, résistance physique" },
		},
	},
	{
		category = "Peuples Magiques",
		races = {
			{ name = "Tiefling", emoji = "😈", slots = -1, description = "Descendants des démons, marqués par leur héritage infernal", perks = "+2 INT, résistance magique, vision dans le noir" },
		},
	},
	{
		category = "Faction Démoniaque",
		races = {
			{ name = "Démon", emoji = "👿", slots = -1, description = "Créatures des abysses, puissants mais craints", perks = "Abilités démoniaques, force surhumaine, immunité feu" },
		},
	},
}

-- Race colors by category
local RACE_COLORS: { [string]: BrickColor } = {
	["Peuples Libres"] = BrickColor.new("Bright green"),
	["Peuples Guerriers"] = BrickColor.new("Bright red"),
	["Peuples Magiques"] = BrickColor.new("Bright violet"),
	["Faction Démoniaque"] = BrickColor.new("Dark red"),
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
