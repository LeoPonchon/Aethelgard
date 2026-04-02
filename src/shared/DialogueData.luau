--!nonstrict
-- Dialogue configuration data (data only, no functions)

export type DialogueOption = {
	text: string,
	nextNode: string?,
}

export type DialogueRule = {
	team: string?,
	class: string?,
	race: string?,
	npcText: string,
	options: { DialogueOption }?,
}

export type DialogueNode = {
	rules: { DialogueRule }
}

export type NPCDialogueData = {
	npcName: string,
	[string]: DialogueNode
}

local DIALOGUE_DATA: { [string]: NPCDialogueData } = {
	["Village_Elder"] = {
		npcName = "Village Elder",

		start = {
			rules = {
				{
					npcText = "Welcome, newcomer! This game works through YOUR ACTIONS and YOUR INTERACTIONS with other players.",
					options = {
						{ text = "How does it work?", nextNode = "Village_Elder_Gameplay" },
					}
				},
			}
		},

		Village_Elder_Gameplay = {
			rules = {
				{
					npcText = "The game uses an ACTION-BASED progression system. Right-click on NPCs or locations to interact! Your actions define your CLASS, your TEAM, and your RACE.",
					options = {
						{ text = "How do I get a new class?", nextNode = "Village_Elder_Class" },
						{ text = "How do I change team?", nextNode = "Village_Elder_Team" },
						{ text = "Thank you!", nextNode = "Village_Elder_End" },
					}
				},
			}
		},

		Village_Elder_Class = {
			rules = {
				{
					npcText = "Your CLASS changes based on your actions: attacking = warrior/rogue, using magic = mage/necromancer, negotiating = bard, protecting = knight/paladin.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Gameplay" },
					}
				},
			}
		},

		Village_Elder_Team = {
			rules = {
				{
					npcText = "Your TEAM (faction) changes based on your actions and interactions: helping others = Hero/Saint, attacking = Demon, negotiating with nobility = Nobility.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Gameplay" },
					}
				},
			}
		},

		Village_Elder_End = {
			rules = {
				{
					npcText = "Good adventure! Right-click on NPCs and locations to interact. Your actions define who you are!",
					options = {}
				},
			}
		},
	},
}

return DIALOGUE_DATA
