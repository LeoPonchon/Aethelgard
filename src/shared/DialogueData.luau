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
					npcText = "Social standing in our realm is a complex web of alliances and hierarchies. What path interests you?",
					options = {
						{ text = "Royalty Teams", nextNode = "Village_Elder_Team_Royalty" },
						{ text = "Nobility Teams", nextNode = "Village_Elder_Team_Nobility" },
						{ text = "Special Teams", nextNode = "Village_Elder_Team_Special" },
						{ text = "Demon Realm Teams", nextNode = "Village_Elder_Team_Demon" },
						{ text = "Other Teams", nextNode = "Village_Elder_Team_Other" },
						{ text = "Back", nextNode = "Village_Elder_Gameplay" },
					}
				},
			}
		},

		Village_Elder_Team_Royalty = {
			rules = {
				{
					npcText = "The Crown rules these lands! Which title interests you?",
					options = {
						{ text = "King", nextNode = "Village_Elder_Team_King" },
						{ text = "Queen", nextNode = "Village_Elder_Team_Queen" },
						{ text = "Prince/Princess", nextNode = "Village_Elder_Team_Prince" },
						{ text = "Back", nextNode = "Village_Elder_Team" },
					}
				},
			}
		},

		Village_Elder_Team_King = {
			rules = {
				{
					npcText = "King (1 slot): Sit on the royal throne to claim the crown. But be warned - if the slot is taken, the throne will reject you!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Royalty" },
					}
				},
			}
		},

		Village_Elder_Team_Queen = {
			rules = {
				{
					npcText = "Queen (1 slot): Your marriage proposal must be accepted by the King himself. Only one may wear the crown beside him - if the slot is filled, you must wait!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Royalty" },
					}
				},
			}
		},

		Village_Elder_Team_Prince = {
			rules = {
				{
					npcText = "Prince/Princess (4 slots each): Your adoption must be approved by BOTH the King and Queen. The royal family is small - if no slot remains, no adoption is possible!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Royalty" },
					}
				},
			}
		},

		Village_Elder_Team_Nobility = {
			rules = {
				{
					npcText = "Nobility serves crown and realm! Which title do you seek?",
					options = {
						{ text = "Duke", nextNode = "Village_Elder_Team_Duke" },
						{ text = "Baron", nextNode = "Village_Elder_Team_Baron" },
						{ text = "Count", nextNode = "Village_Elder_Team_Count" },
						{ text = "Lord", nextNode = "Village_Elder_Team_Lord" },
						{ text = "Back", nextNode = "Village_Elder_Team" },
					}
				},
			}
		},

		Village_Elder_Team_Duke = {
			rules = {
				{
					npcText = "Duke (5 slots): Appointed directly by the King. A position of great honor and responsibility! But only five may hold this title - if all slots are taken, wait for a vacancy.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
					}
				},
			}
		},

		Village_Elder_Team_Baron = {
			rules = {
				{
					npcText = "Baron (10 slots): Appointed by a Duke OR the King. Seek favor with the nobility! But remember - only ten may serve as Baron at once.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
					}
				},
			}
		},

		Village_Elder_Team_Count = {
			rules = {
				{
					npcText = "Count (15 slots): Appointed by Dukes, Barons, or the King. A lesser title, but still prestigious! Fifteen may hold this rank simultaneously.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
					}
				},
			}
		},

		Village_Elder_Team_Lord = {
			rules = {
				{
					npcText = "Lord (20 slots): Purchase an available fief to claim this title. Land and title go hand in hand! Up to twenty may hold land in the realm.",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
					}
				},
			}
		},

		Village_Elder_Team_Special = {
			rules = {
				{
					npcText = "Destiny touches few souls in this realm. Which path?",
					options = {
						{ text = "Hero", nextNode = "Village_Elder_Team_Hero" },
						{ text = "Saint", nextNode = "Village_Elder_Team_Saint" },
						{ text = "Free Lineage", nextNode = "Village_Elder_Team_Free" },
						{ text = "Back", nextNode = "Village_Elder_Team" },
					}
				},
			}
		},

		Village_Elder_Team_Hero = {
			rules = {
				{
					npcText = "Hero (1 slot): Purchase the legendary Excalibur to claim this destiny. Only ONE may wield its power - if the slot is taken, the sword will reject you!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Special" },
					}
				},
			}
		},

		Village_Elder_Team_Saint = {
			rules = {
				{
					npcText = "Saint (1 slot): Acquire Avalon itself through purchase. Divine favor is rare - only one may hold this sacred title at a time!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Special" },
					}
				},
			}
		},

		Village_Elder_Team_Free = {
			rules = {
				{
					npcText = "Free Lineage (unlimited): These are souls banished by royal decree. The King may cast out any who displease him. An outcast forever marked, wandering without master!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Special" },
					}
				},
			}
		},

		Village_Elder_Team_Demon = {
			rules = {
				{
					npcText = "Darkness holds its own order. Which shadow calls to you?",
					options = {
						{ text = "Demon King", nextNode = "Village_Elder_Team_DemonKing" },
						{ text = "Demon Queen", nextNode = "Village_Elder_Team_DemonQueen" },
						{ text = "Demon General", nextNode = "Village_Elder_Team_DemonGeneral" },
						{ text = "Demon Servant", nextNode = "Village_Elder_Team_DemonServant" },
						{ text = "Back", nextNode = "Village_Elder_Team" },
					}
				},
			}
		},

		Village_Elder_Team_DemonKing = {
			rules = {
				{
					npcText = "Demon King (1 slot): Sit on the demonic throne in the dark realm. Only ONE may rule the darkness - if the slot is claimed, you must wait!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
					}
				},
			}
		},

		Village_Elder_Team_DemonQueen = {
			rules = {
				{
					npcText = "Demon Queen (1 slot): Your marriage must be accepted by the Demon King. Rule beside darkness itself - but only one may hold this station!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
					}
				},
			}
		},

		Village_Elder_Team_DemonGeneral = {
			rules = {
				{
					npcText = "Demon General (10 slots): Appointed by the Demon King to lead his armies. Ten may serve at his pleasure - if all slots are filled, await an opening!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
					}
				},
			}
		},

		Village_Elder_Team_DemonServant = {
			rules = {
				{
					npcText = "Demon Servant (unlimited): As a Commoner, enter the demon realm and survive within for 5 minutes. The darkness will claim you!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
					}
				},
			}
		},

		Village_Elder_Team_Other = {
			rules = {
				{
					npcText = "Many paths wind through our world. Which calls to you?",
					options = {
						{ text = "Princess Sylvestre", nextNode = "Village_Elder_Team_Sylvestre" },
						{ text = "Elf Faction", nextNode = "Village_Elder_Team_Elf" },
						{ text = "Academy Students", nextNode = "Village_Elder_Team_Academy" },
						{ text = "Commoner", nextNode = "Village_Elder_Team_Commoner" },
						{ text = "Back", nextNode = "Village_Elder_Team" },
					}
				},
			}
		},

		Village_Elder_Team_Sylvestre = {
			rules = {
				{
					npcText = "Princess Sylvestre (1 slot): Sit on the elven throne in the forest realm. Only ONE may rule the elves - if the throne is occupied, seek another path!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Other" },
					}
				},
			}
		},

		Village_Elder_Team_Elf = {
			rules = {
				{
					npcText = "Elf Faction (unlimited): Be appointed by Princess Sylvestre herself. Serve the elven court with honor!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Other" },
					}
				},
			}
		},

		Village_Elder_Team_Academy = {
			rules = {
				{
					npcText = "The Academy trains the scholars of tomorrow! Which year interests you?",
					options = {
						{ text = "Year 1", nextNode = "Village_Elder_Team_Year1" },
						{ text = "Year 2", nextNode = "Village_Elder_Team_Year2" },
						{ text = "Year 3+", nextNode = "Village_Elder_Team_Year3" },
						{ text = "Professor", nextNode = "Village_Elder_Team_Professor" },
						{ text = "External", nextNode = "Village_Elder_Team_External" },
						{ text = "Back", nextNode = "Village_Elder_Team_Other" },
					}
				},
			}
		},

		Village_Elder_Team_Year1 = {
			rules = {
				{
					npcText = "Academy Year 1 (unlimited): Enroll at the Academy to begin your studies. All who seek knowledge are welcome!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
					}
				},
			}
		},

		Village_Elder_Team_Year2 = {
			rules = {
				{
					npcText = "Academy Year 2 (unlimited): Remain in Year 1 for 20 minutes, and you will advance. Patience and dedication are rewarded!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
					}
				},
			}
		},

		Village_Elder_Team_Year3 = {
			rules = {
				{
					npcText = "Academy Year 3+ (unlimited): Complete Year 2 (20 minutes) to reach the highest student rank. The path of wisdom awaits!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
					}
				},
			}
		},

		Village_Elder_Team_Professor = {
			rules = {
				{
					npcText = "Academy Professor (unlimited): Appointed by the King himself. BUT - you must first be Academy Year 3+ OR an External. The King chooses only the worthy!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
					}
				},
			}
		},

		Village_Elder_Team_External = {
			rules = {
				{
					npcText = "Academy External (unlimited): Appointed by any Academy Professor. A path to knowledge without enrollment!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
					}
				},
			}
		},

		Village_Elder_Team_Commoner = {
			rules = {
				{
					npcText = "Commoner (unlimited): All begin here upon entering the realm. This is the foundation of our society - the starting point of every journey!",
					options = {
						{ text = "Back", nextNode = "Village_Elder_Team_Other" },
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
