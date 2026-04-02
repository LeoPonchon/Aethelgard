local DialogueData = {}

export type DialogueOption = {
	text: string,
	nextNode: string?,
	team: string?,
	class: string?,
	race: string?,
}

export type DialogueRule = {
	team: string?,
	class: string?,
	race: string?,
	npcText: string,
	options: {DialogueOption}?,
}

export type DialogueNode = {
	rules: {DialogueRule}
}

export type NPCDialogueData = {
	npcName: string,
	[string]: DialogueNode
}

local ALL_DIALOGUES: {[string]: NPCDialogueData} = {
	["Village_Elder"] = {
		npcName = "Village_Elder",

		start = {
			rules = {
				{
					team = "Commoners", class = "Classless", race = "Human",
					npcText = "Ah, un nouveau villageois ! Bienvenue. Que souhaitez-vous savoir ?",
					options = {
						{ text = "Je veux apprendre les règles du village.", nextNode = "Village_Elder_Line_1" },
					}
				},
				{
					team = "Hero", class = "Paladin", race = "Human",
					npcText = "Ah, le héros humain ! Écoutez bien, voici les règles de notre village.",
					options = {
						{ text = "Je suis prêt à écouter.", nextNode = "Village_Elder_Line_1" },
					}
				},
				{
					team = "King", class = "Warrior", race = "Dwarf",
					npcText = "Votre Majesté naine ! Voici comment fonctionne le village.",
					options = {
						{ text = "Merci, je souhaite apprendre.", nextNode = "Village_Elder_Line_1" },
					}
				},
				{
					team = "DemonKing", class = "Rogue", race = "Demon",
					npcText = "…Un Roi Démon parmi nous ? Je dois faire attention.",
					options = {
						{ text = "Je suis ici pour observer.", nextNode = "Village_Elder_Line_1" },
					}
				},
			}
		},

		Village_Elder_Line_1 = {
			rules = {
				{
					team = "Commoners", class = "Classless", race = "Human",
					npcText = "Ici, chacun peut trouver sa voie : guerrier, mage, artisan… cela dépend de vos actions.",
					options = {
						{ text = "Où commencer ?", nextNode = "Village_Elder_Line_2" },
					}
				},
				{
					team = "Hero", class = "Paladin", race = "Human",
					npcText = "Chaque habitant a un rôle : guerrier, mage, artisan… chacun trouve sa place.",
					options = {
						{ text = "Quels rôles puis-je remplir ?", nextNode = "Village_Elder_Line_2" },
					}
				},
				{
					team = "King", class = "Warrior", race = "Dwarf",
					npcText = "Chaque personnage peut améliorer ses stats, apprendre des compétences et interagir avec les autres factions.",
					options = {
						{ text = "Comment interagir avec les autres ?", nextNode = "Village_Elder_Line_2" },
					}
				},
				{
					team = "DemonKing", class = "Rogue", race = "Demon",
					npcText = "Chaque joueur a des compétences uniques selon sa race, classe et faction. Observez bien !",
					options = {
						{ text = "Je vais observer attentivement.", nextNode = "Village_Elder_Line_2" },
					}
				},
			}
		},

		Village_Elder_Line_2 = {
			rules = {
				{
					team = "Commoners", class = "Classless", race = "Human",
					npcText = "Allez voir le Maître de Guilde pour commencer vos premières quêtes !",
					options = {}
				},
				{
					team = "Hero", class = "Paladin", race = "Human",
					npcText = "Vos choix auront un impact sur le village et ses habitants.",
					options = {}
				},
				{
					team = "King", class = "Warrior", race = "Dwarf",
					npcText = "Certaines quêtes et dialogues ne sont accessibles qu’avec la bonne combinaison de race, classe et rôle.",
					options = {}
				},
				{
					team = "DemonKing", class = "Rogue", race = "Demon",
					npcText = "Faites attention à vos actions : elles influencent votre réputation et la manière dont les autres vous voient.",
					options = {}
				},
			}
		},
	},
}

function DialogueData.getNPCDialogue(npcName: string): NPCDialogueData?
	return ALL_DIALOGUES[npcName]
end

function DialogueData.getDialogueNode(npcName: string, nodeName: string): DialogueNode?
	local npcDialogue = ALL_DIALOGUES[npcName]
	if not npcDialogue then return nil end
	return npcDialogue[nodeName]
end

function DialogueData.getDialogueForPlayer(npcName: string, nodeName: string, player: {team: string?, class: string?, race: string?}): DialogueRule?
	local node = DialogueData.getDialogueNode(npcName, nodeName)
	if not node then return nil end

	local playerClass = player.class or "Classless"
	local playerRace = player.race or "Human"

	for _, rule in ipairs(node.rules) do
		local teamMatch = not rule.team or rule.team == player.team
		local classMatch = not rule.class or rule.class == playerClass or playerClass == "Classless"
		local raceMatch = not rule.race or rule.race == playerRace

		if teamMatch and classMatch and raceMatch then
			return rule
		end
	end

	return nil
end

function DialogueData.hasDialogue(npcName: string): boolean
	return ALL_DIALOGUES[npcName] ~= nil
end

return DialogueData