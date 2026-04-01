--!nonstrict
-- Shared team configuration data
-- This module contains all role/team definitions used by both client and server

export type TeamInfo = {
	name: string,
	emoji: string,
	slots: number,
	description: string,
	perks: string,
}

export type CategoryData = {
	category: string,
	teams: { TeamInfo },
}

-- Team data organized by category with emojis
local TEAM_DATA: { CategoryData } = {
	{
		category = "Royalty",
		teams = {
			{ name = "King", emoji = "👑", slots = 1, description = "Political decisions, influence over Nobles & Commoners", perks = "global notifications, spawn commands" },
			{ name = "Queen", emoji = "👸", slots = 1, description = "Political decisions, diplomacy, ceremonial representation", perks = "global notifications" },
			{ name = "Princes", emoji = "👦", slots = 4, description = "Limited influence, diplomatic missions, RP learning", perks = "diplomatic chat" },
			{ name = "Princesses", emoji = "👧", slots = 4, description = "Limited influence, diplomatic missions, RP learning", perks = "diplomatic chat" },
		},
	},
	{
		category = "Nobility",
		teams = {
			{ name = "Dukes", emoji = "🏰", slots = 5, description = "Management of Counts / Minor Houses, diplomacy, alliances", perks = "region management, fast travel" },
			{ name = "Counts", emoji = "⚔️", slots = 10, description = "Regional RP organization, management of Minor Houses", perks = "region management" },
			{ name = "Minor Houses", emoji = "🛡️", slots = 20, description = "Intrigues, alliances, secondary missions", perks = "house chat" },
		},
	},
	{
		category = "Special",
		teams = {
			{ name = "Hero", emoji = "⚡", slots = 1, description = "Defense missions, morale influence, legends", perks = "spawn commands, hero abilities" },
			{ name = "Saint", emoji = "✨", slots = 1, description = "Moral / religious mediation, social influence", perks = "healing abilities" },
		},
	},
	{
		category = "Demon Faction",
		teams = {
			{ name = "Demon King", emoji = "😈", slots = 1, description = "Leadership of demon faction, mission planning", perks = "demon abilities, spawn commands" },
			{ name = "Demon Queen", emoji = "👹", slots = 1, description = "Demon diplomacy, influence over Generals", perks = "demon abilities" },
			{ name = "Demon Generals", emoji = "👿", slots = 10, description = "Command servants, infiltration/sabotage missions", perks = "stealth mode" },
			{ name = "Demon Servants", emoji = "💀", slots = -1, description = "Execute missions, espionage, corruption", perks = "stealth mode" },
		},
	},
	{
		category = "Commoners",
		teams = {
			{ name = "Commoners", emoji = "👤", slots = -1, description = "Trade, social networks, contracts, social progression", perks = "trade chat" },
		},
	},
	{
		category = "Elves",
		teams = {
			{ name = "Elves Faction", emoji = "🧝", slots = -1, description = "Surveillance, diplomatic tests, magical rituals", perks = "elf vision, nature abilities" },
		},
	},
	{
		category = "Free Lineages",
		teams = {
			{ name = "Free Lineages", emoji = "🗡️", slots = -1, description = "Commercial/military contracts, flexible loyalty", perks = "mercenary chat" },
		},
	},
	{
		category = "Academy",
		teams = {
			{ name = "Academy Professors", emoji = "📚", slots = -1, description = "Teach classes, supervise duels, mentorship, clubs", perks = "teaching tools, class management" },
			{ name = "Academy Year 1", emoji = "🎒", slots = -1, description = "Attend classes, participate in clubs, limited social RP", perks = "student abilities" },
			{ name = "Academy Year 2", emoji = "📖", slots = -1, description = "Attend classes, participate in clubs, intermediate missions", perks = "student abilities" },
			{ name = "Academy Year 3 Plus", emoji = "🎓", slots = -1, description = "Advanced courses, clubs, mentorship Year1/Year2, advanced duels", perks = "advanced abilities" },
			{ name = "Academy Externals", emoji = "🌍", slots = -1, description = "Limited access, learning and social RP", perks = "external access" },
		},
	},
	{
		category = "Events",
		teams = {
			{ name = "Event Teams", emoji = "🎭", slots = 0, description = "Temporary RP objectives, unstable alliances", perks = "event tools" },
		},
	},
}

-- Team colors by category
local TEAM_COLORS: { [string]: BrickColor } = {
	["Royalty"] = BrickColor.new("Bright red"),
	["Nobility"] = BrickColor.new("Bright violet"),
	["Special"] = BrickColor.new("Bright yellow"),
	["Demon Faction"] = BrickColor.new("Dark red"),
	["Commoners"] = BrickColor.new("Bright blue"),
	["Elves"] = BrickColor.new("Bright green"),
	["Free Lineages"] = BrickColor.new("Grey"),
	["Academy"] = BrickColor.new("White"),
	["Events"] = BrickColor.new("Black"),
}

-- Permission levels for roles (higher = more restrictions)
-- 0 = anyone can join, 1 = requires permission, 2 = admin only
local ROLE_PERMISSIONS: { [string]: number } = {
	-- Royalty (admin only)
	["King"] = 2,
	["Queen"] = 2,
	["Princes"] = 2,
	["Princesses"] = 2,
	-- Special roles (admin only)
	["Hero"] = 2,
	["Saint"] = 2,
	["Demon King"] = 2,
	["Demon Queen"] = 2,
	-- Nobility (requires permission)
	["Dukes"] = 1,
	["Counts"] = 1,
	["Minor Houses"] = 1,
	["Demon Generals"] = 1,
	-- Event teams (special handling)
	["Event Teams"] = 2,
	-- Open roles
	["Demon Servants"] = 0,
	["Commoners"] = 0,
	["Elves Faction"] = 0,
	["Free Lineages"] = 0,
	["Academy Professors"] = 1,
	["Academy Year 1"] = 0,
	["Academy Year 2"] = 0,
	["Academy Year 3 Plus"] = 0,
	["Academy Externals"] = 0,
}

-- Build a lookup table for quick team info access
local TEAM_LOOKUP: { [string]: TeamInfo } = {}
for _, category in ipairs(TEAM_DATA) do
	for _, teamInfo in ipairs(category.teams) do
		TEAM_LOOKUP[teamInfo.name] = teamInfo
	end
end

local TeamData = {}

-- Get all team data
function TeamData.getTeamData(): { CategoryData }
	return TEAM_DATA
end

-- Get team colors mapping
function TeamData.getTeamColors(): { [string]: BrickColor }
	return TEAM_COLORS
end

-- Get team info by name
function TeamData.getTeamInfo(teamName: string): TeamInfo?
	return TEAM_LOOKUP[teamName]
end

-- Get role permission level
function TeamData.getRolePermission(teamName: string): number
	return ROLE_PERMISSIONS[teamName] or 0
end

-- Check if a role has limited slots
function TeamData.hasLimitedSlots(teamName: string): boolean
	local teamInfo = TEAM_LOOKUP[teamName]
	if not teamInfo then
		return false
	end
	return teamInfo.slots > 0
end

-- Get max slots for a role (-1 means unlimited)
function TeamData.getMaxSlots(teamName: string): number
	local teamInfo = TEAM_LOOKUP[teamName]
	if not teamInfo then
		return 0
	end
	return teamInfo.slots
end

-- Check if role name is valid
function TeamData.isValidRole(teamName: string): boolean
	return TEAM_LOOKUP[teamName] ~= nil
end

-- Get default team for new players
function TeamData.getDefaultTeam(): string
	return "Commoners"
end

return TeamData

