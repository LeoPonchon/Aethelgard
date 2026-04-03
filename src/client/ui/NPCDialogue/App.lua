local React = require(script.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(script.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local DialogueBox = require(script.Parent.components.DialogueBox)
local ChoicesPanel = require(script.Parent.components.ChoicesPanel)
local useDialogueController = require(script.Parent.hooks.useDialogueController)

local e = React.createElement

local function NPCDialogueApp(props)
	local controller = useDialogueController()

	local dialogueState = controller.dialogueState

	React.useEffect(function()
		props.setController(controller)
	end, {controller})

	if not dialogueState.isActive then
		return nil
	end

	return e("ScreenGui", {
		Name = "NPCDialogueText",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, {
		DialogueBox = e(DialogueBox, {
			npcName = dialogueState.npcName,
			faction = dialogueState.faction,
			message = dialogueState.text,
		}),

		ChoicesPanel = e(ChoicesPanel, {
			options = dialogueState.options,
			hasChoices = dialogueState.hasChoices,
			onChoiceSelected = controller.advanceDialogue,
			onClose = controller.closeDialogue,
		}),
	})
end

return NPCDialogueApp
