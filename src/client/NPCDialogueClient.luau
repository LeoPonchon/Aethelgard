--!nonstrict
-- NPC Dialogue Client System for Aethelgard
-- Handles dialogue UI for talking to villagers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function waitForRemote(remoteName, timeout)
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

local SPEAKER_NAME_COLOR = Color3.fromRGB(200, 200, 255)
local FACTION_LABEL_COLOR = Color3.fromRGB(180, 140, 220)
local BODY_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)
local BUTTON_DEFAULT_FILL = Color3.fromRGB(40, 40, 60)
local BUTTON_DEFAULT_BORDER = Color3.fromRGB(100, 100, 150)
local BUTTON_HOVER_FILL = Color3.fromRGB(60, 60, 100)
local BUTTON_HOVER_BORDER = Color3.fromRGB(120, 80, 150)
local BUTTON_HOVER_TEXT = Color3.fromRGB(200, 200, 255)

local currentNpcId = nil
local currentNode = "start"
local currentText = ""
local currentNpcName = ""
local currentFaction = ""
local hasChoices = false
local currentOptions = {}
local dialogueTextGui = nil
local dialogueScreenGui = nil
local keyboardConnection = nil
local dialogueHistory = {}
local currentNpcPosition = nil
local proximityCheckConnection = nil

local updateDialogueText = nil
local advanceDialogue = nil

local function closeDialogue()
	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
		dialogueScreenGui = nil
	end

	if keyboardConnection then
		keyboardConnection:Disconnect()
		keyboardConnection = nil
	end

	if proximityCheckConnection then
		proximityCheckConnection:Disconnect()
		proximityCheckConnection = nil
	end

	if dialogueTextGui then
		local container = dialogueTextGui:FindFirstChild("DialogueContainer")
		if container then
			local tweenOut = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.1, 0, 1, -150)
			})
			tweenOut:Play()
			tweenOut.Completed:Connect(function()
				if dialogueTextGui then
					dialogueTextGui:Destroy()
					dialogueTextGui = nil
				end
			end)
		else
			dialogueTextGui:Destroy()
			dialogueTextGui = nil
		end
	end

	currentNpcId = nil
	currentNode = "start"
	currentNpcPosition = nil
	currentOptions = {}
	print("[NPCDialogueClient] Dialogue closed")
end

local function createStrokeTextLabel(parent, props)
	local label = Instance.new("TextLabel")

	for key, value in pairs(props) do
		label[key] = value
	end

	label.Parent = parent

	local stroke = Instance.new("UIStroke")
	stroke.Color = TEXT_STROKE_COLOR
	stroke.Thickness = 3
	stroke.Transparency = 0
	stroke.Parent = label

	return label
end

local function createButton(parent, text, yPos, callback)
	local button = Instance.new("TextButton")
	button.Name = "ChoiceButton"
	button.Size = UDim2.new(0.95, 0, 0, 28)
	button.Position = UDim2.new(0.025, 0, 0, yPos)
	button.BackgroundColor3 = BUTTON_DEFAULT_FILL
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.TextColor3 = BODY_TEXT_COLOR
	button.TextSize = 14
	button.Font = Enum.Font.Gotham
	button.Text = text
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = BUTTON_DEFAULT_BORDER
	borderStroke.Thickness = 1
	borderStroke.Transparency = 0
	borderStroke.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = BUTTON_HOVER_FILL
		borderStroke.Color = BUTTON_HOVER_BORDER
		button.TextColor3 = BUTTON_HOVER_TEXT
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = BUTTON_DEFAULT_FILL
		borderStroke.Color = BUTTON_DEFAULT_BORDER
		button.TextColor3 = BODY_TEXT_COLOR
	end)

	button.MouseButton1Click:Connect(callback)

	return button
end

updateDialogueText = function(message)
	local screenGui = dialogueTextGui

	if not screenGui or not screenGui.Parent then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "NPCDialogueText"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
		dialogueTextGui = screenGui
	end

	local dialogueBox = screenGui:FindFirstChild("DialogueBox")
	local choicesBox = screenGui:FindFirstChild("ChoicesBox")

	if dialogueBox then dialogueBox:Destroy() end
	if choicesBox then choicesBox:Destroy() end

	local titleHeight = 25
	local factionHeight = currentFaction and currentFaction ~= "" and 20 or 0
	local titleSpacing = currentFaction and currentFaction ~= "" and 8 or 0
	local baseHeight = titleHeight + factionHeight + titleSpacing + 10

	local availableWidth = 400
	local textSize, textBounds = TextService:GetTextSize(message, 18, Enum.Font.Gotham, Vector2.new(availableWidth, 1000))
	local messageHeight = textSize.Y + 10

	local padding = 20
	local dialogueBoxHeight = baseHeight + messageHeight + padding

	dialogueBox = Instance.new("Frame")
	dialogueBox.Name = "DialogueBox"
	dialogueBox.Size = UDim2.new(0, availableWidth + 40, 0, dialogueBoxHeight)
	dialogueBox.Position = UDim2.new(0.5, -(availableWidth + 40) / 2, 1, -30)
	dialogueBox.AnchorPoint = Vector2.new(0, 1)
	dialogueBox.BackgroundTransparency = 1
	dialogueBox.Parent = screenGui

	local dialogueTitle = createStrokeTextLabel(dialogueBox, {
		Size = UDim2.new(1, 0, 0, titleHeight),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = currentNpcName,
		TextColor3 = SPEAKER_NAME_COLOR,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	if currentFaction and currentFaction ~= "" then
		local factionLabel = createStrokeTextLabel(dialogueBox, {
			Size = UDim2.new(1, 0, 0, factionHeight),
			Position = UDim2.new(0, 0, 0, titleHeight + titleSpacing),
			BackgroundTransparency = 1,
			Text = currentFaction,
			TextColor3 = FACTION_LABEL_COLOR,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	local messageLabel = createStrokeTextLabel(dialogueBox, {
		Size = UDim2.new(0.95, 0, 0, messageHeight),
		Position = UDim2.new(0.025, 0, 0, baseHeight),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = BODY_TEXT_COLOR,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	})

	local maxChoices = 7
	local buttonHeight = 28
	local buttonSpacing = 5
	local choicesTitleHeight = 22
	local quitButtonSpace = buttonHeight + buttonSpacing
	local choicesBoxWidth = 200
	local choicesBoxHeight = choicesTitleHeight + (maxChoices + 1) * (buttonHeight + buttonSpacing)

	choicesBox = Instance.new("Frame")
	choicesBox.Name = "ChoicesBox"
	choicesBox.Size = UDim2.new(0, choicesBoxWidth, 0, choicesBoxHeight)
	choicesBox.Position = UDim2.new(1, -choicesBoxWidth - 20, 1, -50)
	choicesBox.AnchorPoint = Vector2.new(0, 1)
	choicesBox.BackgroundTransparency = 1
	choicesBox.Parent = screenGui

	local choicesTitle = createStrokeTextLabel(choicesBox, {
		Size = UDim2.new(1, 0, 0, choicesTitleHeight),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "Choices:",
		TextColor3 = SPEAKER_NAME_COLOR,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local choicesStartY = choicesTitleHeight + 5

	if hasChoices and currentOptions then
		for i, option in ipairs(currentOptions) do
			createButton(choicesBox, option.text, choicesStartY, function()
				advanceDialogue(i)
			end)
			choicesStartY = choicesStartY + buttonHeight + buttonSpacing
		end
	end

	createButton(choicesBox, "Quit", choicesStartY, function()
		closeDialogue()
	end)

	print(string.format("[NPC] %s: %s", currentNpcName, message))
end

advanceDialogue = function(optionIndex)
	if not currentNpcId then return end

	table.insert(dialogueHistory, {
		npcId = currentNpcId,
		node = currentNode,
		text = currentText,
		npcName = currentNpcName,
		faction = currentFaction,
		hasChoices = hasChoices,
		options = currentOptions,
	})

	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
		dialogueScreenGui = nil
	end

	if keyboardConnection then
		keyboardConnection:Disconnect()
		keyboardConnection = nil
	end

	if npcInteractionRemote then
		local result = npcInteractionRemote:InvokeServer("advanceDialogue", {
			npcId = currentNpcId,
			currentNode = currentNode,
			optionIndex = optionIndex,
		})

		if result then
			currentNode = result.currentNode
			currentText = result.text or ""
			currentNpcName = result.npcName or currentNpcName
			currentFaction = result.faction or ""
			hasChoices = result.hasChoices or false
			currentOptions = result.options or {}

			updateDialogueText(currentText)

			if result.endConversation then
				task.delay(2, function()
					closeDialogue()
				end)
			end
		end
	end
end

local function checkProximity()
	if not currentNpcId or not currentNpcPosition then return end

	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local distance = (humanoidRootPart.Position - currentNpcPosition).Magnitude

	if distance > 20 then
		print("[NPCDialogueClient] Player too far from NPC, closing dialogue")
		closeDialogue()
	end
end

local function startProximityCheck()
	if proximityCheckConnection then
		proximityCheckConnection:Disconnect()
	end

	proximityCheckConnection = game:GetService("RunService").Heartbeat:Connect(checkProximity)
end

local NPCDialogueClient = {}

function NPCDialogueClient.startConversation(npcId)
	if not npcInteractionRemote then
		warn("[NPCDialogueClient] NPCInteraction remote not found")
		return false
	end

	closeDialogue()

	local result = npcInteractionRemote:InvokeServer("startConversation", { npcId = npcId })

	if result then
		currentNpcId = result.npcId
		currentNpcName = result.npcName or "NPC"
		currentFaction = result.faction or ""
		currentNode = result.currentNode or "start"
		currentNpcPosition = result.npcPosition

		print("[NPCDialogueClient] NPC position received:", currentNpcPosition)
		if currentNpcPosition then
			startProximityCheck()
		end

		local dialogueResult = npcInteractionRemote:InvokeServer("getCurrentDialogue", {
			npcId = currentNpcId,
			currentNode = currentNode,
		})

		if dialogueResult then
			currentText = dialogueResult.text or ""
			hasChoices = dialogueResult.hasChoices or false
			currentOptions = dialogueResult.options or {}

			print("[NPCDialogueClient] dialogueResult - hasChoices:", hasChoices, "options:", #currentOptions)

			updateDialogueText(currentText)

			if dialogueResult.endConversation then
				task.delay(2, function()
					closeDialogue()
				end)
			end

			return true
		end
	end

	return false
end

function NPCDialogueClient.isInDialogue()
	return currentNpcId ~= nil
end

function NPCDialogueClient.close()
	closeDialogue()
end

print("[NPCDialogueClient] Module loaded")
return NPCDialogueClient
