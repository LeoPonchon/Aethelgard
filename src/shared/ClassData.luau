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
		category = "Combat Physique",
		classes = {
			{ name = "Guerrier", emoji = "⚔️", slots = -1, description = "Combattant polyvalent, maître du corps à corps", perks = "Toutes armes, armure lourde, puissance" },
			{ name = "Chevalier", emoji = "🛡️", slots = -1, description = "Guerrier blindé, protection des alliés", perks = "Bouclier, défense, sainteté" },
			{ name = "Voleur", emoji = "🗡️", slots = -1, description = "Expert en combat rapide et discrétion", perks = "Backstab, furtivité, critiques" },
			{ name = "Archer", emoji = "🏹", slots = -1, description = "Spécialiste du combat à distance", perks = "Précision, pièges, vision" },
		},
	},
	{
		category = "Magie",
		classes = {
			{ name = "Mage", emoji = "🔮", slots = -1, description = "Maître des arts magiques élémentaires", perks = "Sorts de feu/glace/foudre, téléport" },
			{ name = "Nécromancien", emoji = "💀", slots = -1, description = "Maître des arts obscurs, invoque les morts", perks = "Invocation, drain de vie, magie noire" },
			{ name = "Prêtre", emoji = "✨", slots = -1, description = "Serviteur des dieux, guérisseur", perks = "Soins, bénédiction, résurrection" },
			{ name = "Druide", emoji = "🌿", slots = -1, description = "Harmonie avec la nature, métamorphose", perks = "Transformation, soins naturels, invocation" },
		},
	},
	{
		category = "Hybrides",
		classes = {
			{ name = "Paladin", emoji = "⚜️", slots = -1, description = "Guerrier sacré, combat et magie divine", perks = "Sainteté, bouclier divin, soins" },
			{ name = "Barde", emoji = "🎵", slots = -1, description = "Artiste voyageur, soutien et charme", perks = "Chants, buff, charisme" },
			{ name = "Moine", emoji = "🥋", slots = -1, description = "Maître des arts martiaux", perks = "Combat à mains nues, discipline, ki" },
			{ name = "Invocateur", emoji = "👁️", slots = -1, description = "Maître des invocations planaires", perks = "Invoque des créatures, contrats" },
		},
	},
}

-- Class colors by category
local CLASS_COLORS: { [string]: BrickColor } = {
	["Combat Physique"] = BrickColor.new("Bright red"),
	["Magie"] = BrickColor.new("Bright blue"),
	["Hybrides"] = BrickColor.new("Bright yellow"),
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
