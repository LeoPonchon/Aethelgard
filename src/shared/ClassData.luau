--!nonstrict
-- Shared class configuration data
-- This module contains all class definitions used by both client and server
-- Format similar to TeamData for UI compatibility

export type ClassInfo = {
	name: string,
	emoji: string,
	slots: number, -- -1 for unlimited
	description: string,
	perks: string,
}

export type CategoryData = {
	category: string,
	classes: { ClassInfo },
}

-- Class data organized by category with emojis
local CLASS_DATA: { CategoryData } = {
	{
		category = "Physical Combat",
		classes = {
			{ name = "Warrior", emoji = "⚔️", slots = -1, description = "Versatile fighter, master of melee combat", perks = "All weapons, heavy armor, power" },
			{ name = "Knight", emoji = "🛡️", slots = -1, description = "Armored warrior, ally protection", perks = "Shield, defense, sanctity" },
			{ name = "Rogue", emoji = "🗡️", slots = -1, description = "Expert in quick combat and stealth", perks = "Backstab, stealth, crits" },
			{ name = "Archer", emoji = "🏹", slots = -1, description = "Ranged combat specialist", perks = "Precision, traps, vision" },
		},
	},
	{
		category = "Magic",
		classes = {
			{ name = "Mage", emoji = "🔮", slots = -1, description = "Master of elemental magic", perks = "Fire/ice/lightning spells, teleport" },
			{ name = "Necromancer", emoji = "💀", slots = -1, description = "Master of dark arts, summons the dead", perks = "Summoning, life drain, dark magic" },
			{ name = "Priest", emoji = "✨", slots = -1, description = "Servant of the gods, healer", perks = "Healing, blessing, resurrection" },
			{ name = "Druid", emoji = "🌿", slots = -1, description = "Harmony with nature, shapeshifter", perks = "Transformation, natural healing, summons" },
		},
	},
	{
		category = "Hybrids",
		classes = {
			{ name = "Paladin", emoji = "⚜️", slots = -1, description = "Holy warrior, combat and divine magic", perks = "Sanctity, divine shield, healing" },
			{ name = "Bard", emoji = "🎵", slots = -1, description = "Traveling artist, support and charm", perks = "Songs, buffs, charisma" },
			{ name = "Monk", emoji = "🥋", slots = -1, description = "Martial arts master", perks = "Unarmed combat, discipline, ki" },
			{ name = "Summoner", emoji = "👁️", slots = -1, description = "Master of planar summonings", perks = "Summons creatures, contracts" },
		},
	},
}

-- Class colors by category
local CLASS_COLORS: { [string]: BrickColor } = {
	["Physical Combat"] = BrickColor.new("Bright red"),
	["Magic"] = BrickColor.new("Bright blue"),
	["Hybrids"] = BrickColor.new("Bright yellow"),
}

-- Build a lookup table for quick class info access
local CLASS_LOOKUP: { [string]: ClassInfo } = {}
for _, category in ipairs(CLASS_DATA) do
	for _, classInfo in ipairs(category.classes) do
		CLASS_LOOKUP[classInfo.name] = classInfo
	end
end

local ClassData = {}

-- Get all class data
function ClassData.getClassData(): { CategoryData }
	return CLASS_DATA
end

-- Get class colors mapping
function ClassData.getClassColors(): { [string]: BrickColor }
	return CLASS_COLORS
end

-- Get class info by name
function ClassData.getClassInfo(className: string): ClassInfo?
	return CLASS_LOOKUP[className]
end

-- Check if class name is valid
function ClassData.isValidClass(className: string): boolean
	return CLASS_LOOKUP[className] ~= nil
end

-- Get all class names
function ClassData.getAllClassNames(): { string }
	local names = {}
	for name, _ in pairs(CLASS_LOOKUP) do
		table.insert(names, name)
	end
	return names
end

return ClassData