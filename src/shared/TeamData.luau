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
		category = "Default",
		teams = {
			{ name = "Commoners", slots = -1, description = "Trade, social networks, contracts", color = Color3.fromRGB(135, 206, 235), default = true },
		},
	},
}

return TEAM_DATA
