--!nonstrict
-- NPC Dialogue Client System for Aethelgard
-- React-based UI for talking to villagers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
	SPEAKER_NAME_COLOR = Color3.fromRGB(200, 200, 255),
	FACTION_LABEL_COLOR = Color3.fromRGB(180, 140, 220),
	BODY_TEXT_COLOR = Color3.fromRGB(255, 255, 255),
	TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0),
	BUTTON_DEFAULT_FILL = Color3.fromRGB(40, 40, 60),
	BUTTON_DEFAULT_BORDER = Color3.fromRGB(100, 100, 150),
	BUTTON_HOVER_FILL = Color3.fromRGB(60, 60, 100),
	BUTTON_HOVER_BORDER = Color3.fromRGB(120, 80, 150),
	BUTTON_HOVER_TEXT = Color3.fromRGB(200, 200, 255),
}

local DIALOGUE_WIDTH = 400
local CHOICES_WIDTH = 200
local BUTTON_HEIGHT = 28
local BUTTON_SPACING = 5
local MAX_CHOICES = 7

local function waitForRemote(remoteName, timeout)
	timeout = timeout or 10
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then return remote end

	local startTime = tick()
	while tick() - startTime < timeout do
		remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote then return remote end
		task.wait(0.1)
	end

	warn("[NPCDialogueClient] Timeout waiting for remote:", remoteName)
	return nil
end

local npcInteractionRemote = waitForRemote("NPCInteraction", 10)

local function ChoiceButton(props)
	local text = props.text
	local onClick = props.onClick
	local layoutOrder = props.layoutOrder

	local isHovered, setIsHovered = React.useState(false)

	local backgroundColor = isHovered and COLORS.BUTTON_HOVER_FILL or COLORS.BUTTON_DEFAULT_FILL
	local borderColor = isHovered and COLORS.BUTTON_HOVER_BORDER or COLORS.BUTTON_DEFAULT_BORDER
	local textColor = isHovered and COLORS.BUTTON_HOVER_TEXT or COLORS.BODY_TEXT_COLOR

	return e("TextButton", {
		Name = "ChoiceButton",
		Size = UDim2.new(0.95, 0, 0, BUTTON_HEIGHT),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		TextColor3 = textColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		Text = text,
		LayoutOrder = layoutOrder,
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
		end,
		[React.Event.Activated] = onClick,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Stroke = e("UIStroke", {
			Color = borderColor,
			Thickness = 1,
			Transparency = 0,
		}),
	})
end

local function DialogueBox(props)
	local npcName = props.npcName or "NPC"
	local faction = props.faction or ""
	local message = props.message or ""

	local titleHeight = 25
	local factionHeight = faction ~= "" and 20 or 0
	local titleSpacing = faction ~= "" and 8 or 0
	local baseHeight = titleHeight + factionHeight + titleSpacing + 10

	local textSize = TextService:GetTextSize(message, 18, Enum.Font.Gotham, Vector2.new(DIALOGUE_WIDTH, 1000))
	local messageHeight = textSize.Y + 10

	local padding = 20
	local dialogueBoxHeight = baseHeight + messageHeight + padding

	local children = {
		Title = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, titleHeight),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = npcName,
			TextColor3 = COLORS.SPEAKER_NAME_COLOR,
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = COLORS.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),

		Message = e("TextLabel", {
			Size = UDim2.new(0.95, 0, 0, messageHeight),
			Position = UDim2.new(0.025, 0, 0, baseHeight),
			BackgroundTransparency = 1,
			Text = message,
			TextColor3 = COLORS.BODY_TEXT_COLOR,
			TextSize = 18,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
		}, {
			Stroke = e("UIStroke", {
				Color = COLORS.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),
	}

	if faction ~= "" then
		children.Faction = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, factionHeight),
			Position = UDim2.new(0, 0, 0, titleHeight + titleSpacing),
			BackgroundTransparency = 1,
			Text = faction,
			TextColor3 = COLORS.FACTION_LABEL_COLOR,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = COLORS.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		})
	end

	return e("Frame", {
		Name = "DialogueBox",
		Size = UDim2.new(0, DIALOGUE_WIDTH + 40, 0, dialogueBoxHeight),
		Position = UDim2.new(0.5, -(DIALOGUE_WIDTH + 40) / 2, 1, -30),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
	}, children)
end

local function ChoicesPanel(props)
	local options = props.options or {}
	local hasChoices = props.hasChoices
	local onChoiceSelected = props.onChoiceSelected
	local onClose = props.onClose

	local maxButtons = MAX_CHOICES + 1
	local panelHeight = 22 + maxButtons * (BUTTON_HEIGHT + BUTTON_SPACING)

	local buttonsChildren = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, BUTTON_SPACING),
		}),
	}

	if hasChoices then
		for i, option in ipairs(options) do
			buttonsChildren["Choice_" .. i] = e(ChoiceButton, {
				text = option.text,
				onClick = function()
					onChoiceSelected(i)
				end,
				layoutOrder = i,
			})
		end
	end

	buttonsChildren.QuitButton = e(ChoiceButton, {
		text = "Quit",
		onClick = onClose,
		layoutOrder = 100,
	})

	return e("Frame", {
		Name = "ChoicesBox",
		Size = UDim2.new(0, CHOICES_WIDTH, 0, panelHeight),
		Position = UDim2.new(1, -CHOICES_WIDTH - 20, 1, -50),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
	}, {
		Title = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "Choices:",
			TextColor3 = COLORS.SPEAKER_NAME_COLOR,
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = COLORS.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),

		ButtonsContainer = e("Frame", {
			Size = UDim2.new(1, 0, 1, -27),
			Position = UDim2.new(0, 0, 0, 27),
			BackgroundTransparency = 1,
		}, buttonsChildren),
	})
end

local function useDialogueController()
	local dialogueState, setDialogueState = React.useState({
		isActive = false,
		npcId = nil,
		npcName = "",
		faction = "",
		currentNode = "start",
		text = "",
		options = {},
		hasChoices = false,
		npcPosition = nil,
	})

	local proximityConnectionRef = React.useRef(nil)

	local closeDialogue = React.useCallback(function()
		if proximityConnectionRef.current then
			proximityConnectionRef.current:Disconnect()
			proximityConnectionRef.current = nil
		end

		setDialogueState({
			isActive = false,
			npcId = nil,
			npcName = "",
			faction = "",
			currentNode = "start",
			text = "",
			options = {},
			hasChoices = false,
			npcPosition = nil,
		})
	end, {})

	local checkProximity = React.useCallback(function()
		if not dialogueState.isActive then return end
		if not dialogueState.npcId or not dialogueState.npcPosition then return end

		local character = player.Character
		if not character then return end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		local distance = (humanoidRootPart.Position - dialogueState.npcPosition).Magnitude

		if distance > 20 then
			print("[NPCDialogueClient] Player too far from NPC, closing dialogue")
			closeDialogue()
		end
	end, {closeDialogue})

	local startProximityCheck = React.useCallback(function(npcPosition)
		if proximityConnectionRef.current then
			proximityConnectionRef.current:Disconnect()
		end

		proximityConnectionRef.current = RunService.Heartbeat:Connect(checkProximity)
	end, {checkProximity})

	local advanceDialogue = React.useCallback(function(optionIndex)
		print("[NPCDialogueClient] advanceDialogue called with optionIndex:", optionIndex)
		
		local currentState = dialogueState
		if not currentState.npcId then 
			print("[NPCDialogueClient] No npcId in state")
			return 
		end
		if not npcInteractionRemote then 
			print("[NPCDialogueClient] No remote")
			return 
		end

		print("[NPCDialogueClient] Calling server with:", currentState.npcId, currentState.currentNode, optionIndex)
		
		local result = npcInteractionRemote:InvokeServer("advanceDialogue", {
			npcId = currentState.npcId,
			currentNode = currentState.currentNode,
			optionIndex = optionIndex,
		})

		print("[NPCDialogueClient] Server result:", result)

		if result then
			setDialogueState({
				isActive = true,
				npcId = currentState.npcId,
				npcName = result.npcName or currentState.npcName,
				faction = result.faction or "",
				currentNode = result.currentNode,
				text = result.text or "",
				options = result.options or {},
				hasChoices = result.hasChoices or false,
				npcPosition = currentState.npcPosition,
			})

			if result.endConversation then
				task.delay(2, closeDialogue)
			end
		end
	end, {closeDialogue, dialogueState})

	local startConversation = React.useCallback(function(npcId)
		if not npcInteractionRemote then
			warn("[NPCDialogueClient] NPCInteraction remote not found")
			return false
		end

		closeDialogue()

		local result = npcInteractionRemote:InvokeServer("startConversation", { npcId = npcId })

		if result then
			local dialogueResult = npcInteractionRemote:InvokeServer("getCurrentDialogue", {
				npcId = result.npcId,
				currentNode = result.currentNode or "start",
			})

			if dialogueResult then
				local npcPosition = result.npcPosition
				if npcPosition then
					startProximityCheck(npcPosition)
				end

				setDialogueState({
					isActive = true,
					npcId = result.npcId,
					npcName = result.npcName or "NPC",
					faction = result.faction or "",
					currentNode = result.currentNode or "start",
					text = dialogueResult.text or "",
					options = dialogueResult.options or {},
					hasChoices = dialogueResult.hasChoices or false,
					npcPosition = npcPosition,
				})

				if dialogueResult.endConversation then
					task.delay(2, closeDialogue)
				end

				return true
			end
		end

		return false
	end, {closeDialogue, startProximityCheck})

	local isInDialogue = React.useCallback(function()
		return dialogueState.isActive
	end, {})

	React.useEffect(function()
		return function()
			if proximityConnectionRef.current then
				proximityConnectionRef.current:Disconnect()
			end
		end
	end, {})

	return {
		dialogueState = dialogueState,
		startConversation = startConversation,
		advanceDialogue = advanceDialogue,
		closeDialogue = closeDialogue,
		isInDialogue = isInDialogue,
	}
end

local function NPCDialogueApp(props)
	local controller = useDialogueController()

	local dialogueState = controller.dialogueState

	React.useEffect(function()
		if props.setController then
			props.setController(controller)
		end
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

local root = nil
local controllerRef = nil

local function mountDialogueUI()
	if root then
		return
	end

	local targetContainer = Instance.new("ScreenGui")
	targetContainer.Name = "NPCDialogueRoot"
	targetContainer.ResetOnSpawn = false
	targetContainer.IgnoreGuiInset = true
	targetContainer.Parent = playerGui

	root = ReactRoblox.createRoot(targetContainer)

	root:render(React.createElement(NPCDialogueApp, {
		setController = function(controller)
			controllerRef = controller
		end,
	}))

	print("[NPCDialogueClient] React UI mounted")
end

local function unmountDialogueUI()
	if root then
		root:unmount()
		root = nil
		controllerRef = nil
		print("[NPCDialogueClient] React UI unmounted")
	end
end

local NPCDialogueClient = {}

function NPCDialogueClient.startConversation(npcId)
	if not controllerRef then
		mountDialogueUI()
		task.wait(0.1)
	end

	if controllerRef then
		return controllerRef.startConversation(npcId)
	end

	return false
end

function NPCDialogueClient.isInDialogue()
	if controllerRef then
		return controllerRef.isInDialogue()
	end
	return false
end

function NPCDialogueClient.close()
	if controllerRef then
		controllerRef.closeDialogue()
	end
end

function NPCDialogueClient.mount()
	mountDialogueUI()
end

function NPCDialogueClient.unmount()
	unmountDialogueUI()
end

print("[NPCDialogueClient] React-based module loaded")
return NPCDialogueClient
