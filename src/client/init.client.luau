local React = require(game.ReplicatedStorage.Shared.React)
local ReactRoblox = require(game.ReplicatedStorage.Shared.ReactRoblox)

local ClientFolder = script.Parent:WaitForChild("Client")
local RoleSelectionMenu = require(ClientFolder:WaitForChild("RoleSelectionMenu"))

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Get or create teams
local Teams = game:GetService("Teams")

-- Team data organized by category with emojis
local TEAM_DATA = {
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

-- Store team instances
local teamInstances = {}

-- Create all teams from data
local teamColors = {
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

for _, category in ipairs(TEAM_DATA) do
	for _, teamInfo in ipairs(category.teams) do
		local team = Teams:FindFirstChild(teamInfo.name)
		if not team then
			team = Instance.new("Team")
			team.Name = teamInfo.name
			team.TeamColor = teamColors[category.category] or BrickColor.new("Medium stone grey")
			team.AutoAssignable = false
			team.Parent = Teams
		end
		teamInstances[teamInfo.name] = team
	end
end

-- Assign player to Commoners team by default
local player = game.Players.LocalPlayer
local defaultTeam = teamInstances["Commoners"]
if defaultTeam then
	player.Team = defaultTeam
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReactRoot"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = ReactRoblox.createRoot(screenGui)

-- Create a wrapper component to manage state
local function App()
	local menuVisible, setMenuVisible = React.useState(true)

	local function handleRoleSelected(role)
		local player = game.Players.LocalPlayer
		local selectedTeam = teamInstances[role]
		if selectedTeam then
			player.Team = selectedTeam
			print("Player assigned to team: " .. role)
		end
	end

	local function handleMenuClose()
		setMenuVisible(false)
	end

	local function handleRebirth()
		setMenuVisible(true)
	end

	return React.createElement(RoleSelectionMenu, {
		visible = menuVisible,
		teamData = TEAM_DATA,
		onRoleSelected = handleRoleSelected,
		onMenuClose = handleMenuClose,
		onRebirth = handleRebirth,
	})
end

root:render(React.createElement(App))
