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
					npcText = "Ah, you finally woke up! It's finally time for you to head outside of the village, but I'll answer your questions if any.",
					options = {
						{ text = "How does it work?", nextNode = "Village_Elder_Gameplay" },
					}
				},
			}
		},

Village_Elder_Gameplay = {
		rules = {
			{
				npcText = "The more you'll experience with other beings of this world, the better your experience will be. Talk with others, interact with them, become a part of the nobility, or join the elves. But be careful, as demons are still lurking...",
				options = {
					{ text = "How do I get a new class?", nextNode = "Village_Elder_Class" },
					{ text = "How do I get a new race?", nextNode = "Village_Elder_Race" },
					{ text = "How do I change team?", nextNode = "Village_Elder_Team" },
					{ text = "Thank you!", nextNode = "Village_Elder_End" },
				}
			},
		}
	},

	Village_Elder_Race = {
		rules = {
			{
				npcText = "The races of our world are diverse and ancient. Which transformation calls to your soul?",
				options = {
					{ text = "Free Peoples", nextNode = "Village_Elder_Race_Free" },
					{ text = "Warrior Peoples", nextNode = "Village_Elder_Race_Warrior" },
					{ text = "Magical Peoples", nextNode = "Village_Elder_Race_Magical" },
					{ text = "Ancient Peoples", nextNode = "Village_Elder_Race_Ancient" },
					{ text = "Back", nextNode = "Village_Elder_Gameplay" },
				}
			},
		}
	},

	Village_Elder_Race_Free = {
		rules = {
			{
				npcText = "The Free Peoples walk many paths. Which bloodline interests you?",
				options = {
					{ text = "Human", nextNode = "Village_Elder_Race_Human" },
					{ text = "Elf", nextNode = "Village_Elder_Race_Elf" },
					{ text = "Dwarf", nextNode = "Village_Elder_Race_Dwarf" },
					{ text = "Gnome", nextNode = "Village_Elder_Race_Gnome" },
					{ text = "Kemyns", nextNode = "Village_Elder_Race_Kemyns" },
					{ text = "Back", nextNode = "Village_Elder_Race" },
				}
			},
		}
	},

	Village_Elder_Race_Human = {
		rules = {
			{
				npcText = "All who enter the realm begin as Human. To return to this form, pray at the statue of the Goddess in the capital. Her blessing cleanses all transformations, restoring your original self!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Free" },
				}
			},
		}
	},

	Village_Elder_Race_Elf = {
		rules = {
			{
				npcText = "Ancient and mystical, the elves guard the forest secrets. Pray before Yggdrasil in the elven forest to receive their blessing!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Free" },
				}
			},
		}
	},

	Village_Elder_Race_Dwarf = {
		rules = {
			{
				npcText = "Legendary artisans and warriors of the deep. Undergo the Ritual of the Mountains in the dwarven halls!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Free" },
				}
			},
		}
	},

	Village_Elder_Race_Gnome = {
		rules = {
			{
				npcText = "Inventors and scholars of the arcane arts. Interact with the Legendary Garden Gnome statue to unlock its secrets!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Free" },
				}
			},
		}
	},

	Village_Elder_Race_Kemyns = {
		rules = {
			{
				npcText = "Beings blessed with animal ears and keen senses. Pray to Bastet in the forgotten temple to receive her gift!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Free" },
				}
			},
		}
	},

	Village_Elder_Race_Warrior = {
		rules = {
			{
				npcText = "The Warrior Peoples are born of blood and battle. Which path calls to you?",
				options = {
					{ text = "Orc", nextNode = "Village_Elder_Race_Orc" },
					{ text = "Oni", nextNode = "Village_Elder_Race_Oni" },
					{ text = "Back", nextNode = "Village_Elder_Race" },
				}
			},
		}
	},

	Village_Elder_Race_Orc = {
		rules = {
			{
				npcText = "Fierce warriors from the wild lands. Undergo the Ritual of the Demon Lands to be reborn in blood!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Warrior" },
				}
			},
		}
	},

	Village_Elder_Race_Oni = {
		rules = {
			{
				npcText = "Powerful horned beings, masters of strength and fury. Undergo the Oni ritual in the demon lands to grow your horns and claim your power!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Warrior" },
				}
			},
		}
	},

	Village_Elder_Race_Magical = {
		rules = {
			{
				npcText = "The Magical Peoples are touched by forces beyond mortal ken. Which fate calls to you?",
				options = {
					{ text = "Tiefling", nextNode = "Village_Elder_Race_Tiefling" },
					{ text = "Aasimar", nextNode = "Village_Elder_Race_Aasimar" },
					{ text = "Back", nextNode = "Village_Elder_Race" },
				}
			},
		}
	},

	Village_Elder_Race_Tiefling = {
		rules = {
			{
				npcText = "Descendants of demons, marked by infernal blood. Pray in the cursed temple to embrace your dark heritage!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Magical" },
				}
			},
		}
	},

	Village_Elder_Race_Aasimar = {
		rules = {
			{
				npcText = "Blessed with celestial blood, touched by the divine. Pray in the sacred temple to receive a celestial blessing!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Magical" },
				}
			},
		}
	},

	Village_Elder_Race_Ancient = {
		rules = {
			{
				npcText = "The Ancient Peoples carry the blood of legends. Which legacy calls to you?",
				options = {
					{ text = "Dragonborn", nextNode = "Village_Elder_Race_Dragonborn" },
					{ text = "Back", nextNode = "Village_Elder_Race" },
				}
			},
		}
	},

	Village_Elder_Race_Dragonborn = {
		rules = {
			{
				npcText = "Born of dragons, proud and powerful. Drink the blood of a dragon to awaken your draconic heritage!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Race_Ancient" },
				}
			},
		}
	},

	Village_Elder_Class = {
		rules = {
			{
				npcText = "The Academy is where all classes are learned. Speak with the Academy Director when you enroll as Year 1 to choose your path. Once you reach Year 3, your class will be granted automatically!",
				options = {
					{ text = "What classes are available?", nextNode = "Village_Elder_Class_List" },
					{ text = "Back", nextNode = "Village_Elder_Gameplay" },
				}
			},
		}
	},

	Village_Elder_Class_List = {
		rules = {
			{
				npcText = "The Academy teaches many paths. Warriors and Knights for battle. Mages and Sorcerers for the arcane. Rogues and Bards for subtlety. Rangers and Druids for nature. Clerics and Paladins for the divine!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Class" },
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
				npcText = "There can only be one King at a time. Sit on the royal throne to claim the crown. But beware - if the slot is taken, the throne will reject you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Royalty" },
				}
			},
		}
	},

Village_Elder_Team_Queen = {
		rules = {
			{
				npcText = "Only one may rule beside the King. Have your marriage proposal accepted by the King himself to wear the crown. However, if the slot is taken, you must wait!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Royalty" },
				}
			},
		}
	},

Village_Elder_Team_Prince = {
		rules = {
			{
				npcText = "Four seats exist for each heir title. Your adoption must be approved by BOTH the King and Queen. Should all slots be taken, no adoption is possible!",
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
				npcText = "Five may hold this prestigious title. You must first be a Lord, then be appointed directly by the King. When all slots are taken, you must await a vacancy!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
				}
			},
		}
	},

Village_Elder_Team_Baron = {
		rules = {
			{
				npcText = "Ten may serve as Baron in the realm. You must first be a Lord, then seek appointment from a Duke or the King. If no slot remains open, patience is your only path!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
				}
			},
		}
	},

Village_Elder_Team_Count = {
		rules = {
			{
				npcText = "Fifteen may hold this lesser noble title. You must first be a Lord, then seek appointment from Dukes, Barons, or the King. Alas, if all slots are taken, seek another path!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Nobility" },
				}
			},
		}
	},

Village_Elder_Team_Lord = {
		rules = {
			{
				npcText = "Twenty may hold land and title together. Purchase an available fief to claim your domain. Should no land remain unclaimed, wait for a vacancy!",
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
				npcText = "Only one may wield Excalibur's power. Purchase the legendary sword to claim this destiny. But if the slot is taken, the sword will reject you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Special" },
				}
			},
		}
	},

Village_Elder_Team_Saint = {
		rules = {
			{
				npcText = "Divine favor touches only one soul at a time. Acquire Avalon through purchase to claim this sacred title. However, if the slot is taken, the relic will reject you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Special" },
				}
			},
		}
	},

Village_Elder_Team_Free = {
		rules = {
			{
				npcText = "No limit exists for the banished. Be cast out by royal decree to wander without master. Forever marked as an outcast, shunned by society!",
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
				npcText = "Only one may rule the darkness. Sit on the demonic throne in the dark realm to claim your crown. But if the slot is taken, the throne will reject you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
				}
			},
		}
	},

Village_Elder_Team_DemonQueen = {
		rules = {
			{
				npcText = "Only one may rule beside the Demon King. Have your marriage accepted by the Demon King himself. Should the slot be taken, you must wait!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
				}
			},
		}
	},

Village_Elder_Team_DemonGeneral = {
		rules = {
			{
				npcText = "Ten may serve as commanders of the demonic armies. Be appointed by the Demon King to lead his forces. When all slots are filled, await an opening!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Demon" },
				}
			},
		}
	},

Village_Elder_Team_DemonServant = {
		rules = {
			{
				npcText = "The darkness claims all who enter. As a Commoner, survive 5 minutes in the demon realm to be bound to it forever. Your soul will belong to the darkness!",
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
				npcText = "Only one may rule the elven people. Sit on the elven throne in the forest realm to claim your crown. But if the slot is taken, the throne will reject you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Other" },
				}
			},
		}
	},

Village_Elder_Team_Elf = {
		rules = {
			{
				npcText = "The elven court welcomes all worthy souls. Be appointed by Princess Sylvestre herself to serve the forest realm. Yet, prove your worth first!",
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
				npcText = "All who seek knowledge may enroll at the Academy. Begin your studies as a Year 1 student. The path of wisdom awaits you!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
				}
			},
		}
	},

Village_Elder_Team_Year2 = {
		rules = {
			{
				npcText = "Patience and dedication are rewarded. Remain in Year 1 for 20 minutes to advance. The Academy recognizes those who persevere!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
				}
			},
		}
	},

Village_Elder_Team_Year3 = {
		rules = {
			{
				npcText = "The highest student rank awaits. Complete Year 2 (20 minutes) to reach the top. Your dedication will be recognized!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
				}
			},
		}
	},

Village_Elder_Team_Professor = {
		rules = {
			{
				npcText = "The King appoints only the worthy. To teach, you must first be Year 3+ OR an External. Yet, without royal approval, no professorship is possible!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
				}
			},
		}
	},

Village_Elder_Team_External = {
		rules = {
			{
				npcText = "A path to knowledge without enrollment. Be appointed by any Academy Professor to join the faculty. Yet, you must impress them first!",
				options = {
					{ text = "Back", nextNode = "Village_Elder_Team_Academy" },
				}
			},
		}
	},

Village_Elder_Team_Commoner = {
		rules = {
			{
				npcText = "All begin their journey here upon entering the realm. This is the foundation of society itself. Every noble, every hero, started as a Commoner!",
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
