--!nonstrict
-- Team configuration data (data only, no functions)

export type TeamInfo = {
	name: string,
	slots: number,
	description: string,
	color: Color3?,
	default: boolean?,
	special: boolean?,
}

export type TeamCategory = {
	category: string,
	teams: { TeamInfo },
}

local TEAM_DATA: { TeamCategory } = {
	{
		category = "Royalty",
		teams = {
			{ name = "King", slots = 1, description = "Ruler of the realm, sits on the royal throne", color = Color3.fromRGB(255, 215, 0) },
			{ name = "Queen", slots = 1, description = "Consort of the King, joined through royal marriage", color = Color3.fromRGB(255, 182, 193) },
			{ name = "Princes", slots = 4, description = "Heirs to the throne, adopted by King and Queen", color = Color3.fromRGB(70, 130, 180) },
			{ name = "Princesses", slots = 4, description = "Heirs to the throne, adopted by King and Queen", color = Color3.fromRGB(255, 105, 180) },
		},
	},
	{
		category = "Nobility",
		teams = {
			{ name = "Dukes", slots = 5, description = "High nobility, appointed by the King", color = Color3.fromRGB(128, 0, 128) },
			{ name = "Barons", slots = 10, description = "Nobility, appointed by Dukes or King", color = Color3.fromRGB(139, 69, 19) },
			{ name = "Counts", slots = 15, description = "Lesser nobility, appointed by Dukes, Barons or King", color = Color3.fromRGB(0, 100, 0) },
			{ name = "Lords", slots = 20, description = "Landowners who purchased a fief", color = Color3.fromRGB(105, 105, 105) },
		},
	},
	{
		category = "Heroes",
		teams = {
			{ name = "Hero", slots = 1, description = "Wielder of Excalibur", color = Color3.fromRGB(255, 255, 255) },
			{ name = "Saint", slots = 1, description = "Bearer of Avalon", color = Color3.fromRGB(173, 216, 230) },
		},
	},
	{
		category = "DemonRealm",
		teams = {
			{ name = "Demon King", slots = 1, description = "Ruler of the demon realm, sits on the demonic throne", color = Color3.fromRGB(139, 0, 0) },
			{ name = "Demon Queen", slots = 1, description = "Consort of the Demon King", color = Color3.fromRGB(75, 0, 130) },
			{ name = "Demon Generals", slots = 10, description = "Military commanders, appointed by Demon King", color = Color3.fromRGB(178, 34, 34) },
			{ name = "Demon Servants", slots = -1, description = "Commoners who entered and stayed in the demon realm", color = Color3.fromRGB(48, 25, 52) },
		},
	},
	{
		category = "ElvenFaction",
		teams = {
			{ name = "Princess Sylvestre", slots = 1, description = "Elven ruler, sits on the elven throne", color = Color3.fromRGB(34, 139, 34) },
			{ name = "Elves Faction", slots = -1, description = "Members of the elven faction, appointed by Princess Sylvestre", color = Color3.fromRGB(50, 205, 50) },
		},
	},
	{
		category = "Exiles",
		teams = {
			{ name = "Free Lineages", slots = -1, description = "Exiled individuals, banished by the King", color = Color3.fromRGB(64, 64, 64) },
		},
	},
	{
		category = "Academy",
		teams = {
			{ name = "Academy Professors", slots = -1, description = "Teachers appointed by the King", color = Color3.fromRGB(0, 0, 139) },
			{ name = "Academy Year 1", slots = -1, description = "New students enrolled in the Academy", color = Color3.fromRGB(176, 196, 222) },
			{ name = "Academy Year 2", slots = -1, description = "Students who completed Year 1 (20 min)", color = Color3.fromRGB(152, 251, 152) },
			{ name = "Academy Year 3 Plus", slots = -1, description = "Advanced students who completed Year 2 (20 min)", color = Color3.fromRGB(240, 230, 140) },
			{ name = "Academy Externals", slots = -1, description = "External members appointed by Professors", color = Color3.fromRGB(255, 228, 181) },
		},
	},
	{
		category = "Default",
		teams = {
			{ name = "Commoners", slots = -1, description = "Trade, social networks, contracts", color = Color3.fromRGB(135, 206, 235), default = true },
		},
	},
}

return TEAM_DATA
