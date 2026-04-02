local DialogueData = {}

export type DialogueRule = {
	team: string?,
	class: string?,
	race: string?,
	text: string,
	nextLine: string?,
}

export type DialogueNode = {
	rules: {DialogueRule},
}

export type NPCDialogueData = {
	npcName: string,
	[string]: DialogueNode,
}

local ALL_DIALOGUES: {[string]: NPCDialogueData} = {
	["Village_Elder"] = {
		npcName = "Village_Elder",

		start = {
			rules = {
				{ team = "Commoners", class = nil, race = "Human", 
				  text = "Ah, a new human arrival! Welcome to our village. Let me explain how to progress here.",
				  nextLine = "Village_Elder_Line_1" },
				{ team = "DemonKing", class = "Rogue", race = "Demon", 
				  text = "…A Demon King among us? I'll have to be careful.",
				  nextLine = "Village_Elder_Line_1" },
				{ team = "Hero", class = "Paladin", race = "Human", 
				  text = "Ah, the holy human hero! Listen well to the village rules.",
				  nextLine = "Village_Elder_Line_1" },
				{ team = "King", class = "Warrior", race = "Dwarf", 
				  text = "Your Dwarf Majesty! Welcome. Let me explain how the village works.",
				  nextLine = "Village_Elder_Line_1" },
			}
		},

		Village_Elder_Line_1 = {
			rules = {
				{ team = "Commoners", class = nil, race = "Human", 
				  text = "This village is a place where everyone can find their path. You can become a warrior, mage, artisan… it all depends on your actions.",
				  nextLine = "Village_Elder_Line_2" },
				{ team = "DemonKing", class = "Rogue", race = "Demon", 
				  text = "Here, each player has unique skills based on their race, class and faction. Observe carefully!",
				  nextLine = "Village_Elder_Line_2" },
				{ team = "Hero", class = "Paladin", race = "Human", 
				  text = "In this village, inhabitants have specific roles: warriors, mages, artisans… everyone finds their place.",
				  nextLine = "Village_Elder_Line_2" },
				{ team = "King", class = "Warrior", race = "Dwarf", 
				  text = "Each character can improve stats, learn skills and interact with other factions.",
				  nextLine = "Village_Elder_Line_2" },
			}
		},

		Village_Elder_Line_2 = {
			rules = {
				{ team = "Commoners", class = nil, race = "Human", 
				  text = "Go see the Guild Master to start your first quests. That's where everything begins!",
				  nextLine = nil },
				{ team = "DemonKing", class = "Rogue", race = "Demon", 
				  text = "Be careful with your actions: they influence your reputation and how others see you.",
				  nextLine = nil },
				{ team = "Hero", class = "Paladin", race = "Human", 
				  text = "The choices you make will impact the village and its inhabitants.",
				  nextLine = nil },
				{ team = "King", class = "Warrior", race = "Dwarf", 
				  text = "Some quests and dialogues will only be accessible with the right combinations of race, class and role.",
				  nextLine = nil },
			}
		},
	},
}

function DialogueData.getNPCDialogue(npcName: string): NPCDialogueData?
	return ALL_DIALOGUES[npcName]
end

function DialogueData.getDialogueNode(npcName: string, nodeName: string): DialogueNode?
	local npcDialogue = ALL_DIALOGUES[npcName]
	if not npcDialogue then
		return nil
	end
	return npcDialogue[nodeName]
end

function DialogueData.getDialogueText(npcName: string, nodeName: string, player: {team: string?, class: string?, race: string?}): string?
	local node = DialogueData.getDialogueNode(npcName, nodeName)
	if not node or not node.rules then
		return nil
	end

	for _, rule in ipairs(node.rules) do
		local teamMatch = not rule.team or rule.team == player.team
		local classMatch = not rule.class or rule.class == player.class
		local raceMatch = not rule.race or rule.race == player.race

		if teamMatch and classMatch and raceMatch then
			return rule.text
		end
	end

	return "The villager doesn't know what to say for this combination."
end

function DialogueData.getNextLine(npcName: string, nodeName: string, player: {team: string?, class: string?, race: string?}): string?
	local node = DialogueData.getDialogueNode(npcName, nodeName)
	if not node or not node.rules then
		return nil
	end

	for _, rule in ipairs(node.rules) do
		local teamMatch = not rule.team or rule.team == player.team
		local classMatch = not rule.class or rule.class == player.class
		local raceMatch = not rule.race or rule.race == player.race

		if teamMatch and classMatch and raceMatch then
			return rule.nextLine
		end
	end

	return nil
end

function DialogueData.hasDialogue(npcName: string): boolean
	return ALL_DIALOGUES[npcName] ~= nil
end

return DialogueData