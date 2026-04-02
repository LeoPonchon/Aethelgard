--!nonstrict
-- NPC Dialogue Client System for Aethelgard
-- Simplified to use DialogueData as the single source of truth

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function waitForRemote(remoteName: string, timeout: number): Instance?
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

local function createStrokeTextLabel(parent: Instance, props: {[string]: any}): TextLabel
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

local function createButton(parent: Instance, text: string, yPos: number, callback: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Name = "ChoiceButton"
	button.Size = UDim2.new(0.9, 0, 0, 35)
	button.Position = UDim2.new(0.05, 0, 0, yPos)
	button.BackgroundColor3 = BUTTON_DEFAULT_FILL
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.TextColor3 = BODY_TEXT_COLOR
	button.TextSize = 15
	button.Font = Enum.Font.Gotham
	button.Text = text
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = BUTTON_DEFAULT_BORDER
	borderStroke.Thickness = 2
	borderStroke.Transparency = 0
	borderStroke.Parent = button

	local textStroke = Instance.new("UIStroke")
	textStroke.Color = TEXT_STROKE_COLOR
	textStroke.Thickness = 1
	textStroke.Transparency = 0
	textStroke.Parent = button

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

updateDialogueText = function(message: string)
	local screenGui = dialogueTextGui
	
	if not screenGui or not screenGui.Parent then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "NPCDialogueText"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
		dialogueTextGui = screenGui
	end
	
	local container = screenGui:FindFirstChild("DialogueContainer")
	
	if not container then
		container = Instance.new("Frame")
		container.Name = "DialogueContainer"
		container.Size = UDim2.new(0.8, 0, 0, 150)
		container.Position = UDim2.new(0.1, 0, 1, -200)
		container.BackgroundTransparency = 1
		container.Parent = screenGui
		
		container.Position = UDim2.new(0.1, 0, 1, -150)
		local tweenIn = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.1, 0, 1, -200)
		})
		tweenIn:Play()
	end
	
	for _, child in ipairs(container:GetChildren()) do
		child:Destroy()
	end
	
	local dialogueBox = Instance.new("Frame")
	dialogueBox.Name = "DialogueBox"
	dialogueBox.Size = UDim2.new(0.6, 0, 1, 0)
	dialogueBox.Position = UDim2.new(0, 0, 0, 0)
	dialogueBox.BackgroundTransparency = 1
	dialogueBox.Parent = container
	
	local choicesBox = Instance.new("Frame")
	choicesBox.Name = "ChoicesBox"
	choicesBox.Size = UDim2.new(0.35, 0, 1, 0)
	choicesBox.Position = UDim2.new(0.65, 0, 0, 0)
	choicesBox.BackgroundTransparency = 1
	choicesBox.Parent = container
	
	local dialogueTitle = createStrokeTextLabel(dialogueBox, {
		Size = UDim2.new(1, 0, 0, 25),
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
			Size = UDim2.new(0, 200, 0, 20),
			Position = UDim2.new(0.5, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = currentFaction,
			TextColor3 = FACTION_LABEL_COLOR,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end
	
	local messageLabel = createStrokeTextLabel(dialogueBox, {
		Size = UDim2.new(0.9, 0, 0, 70),
		Position = UDim2.new(0.05, 0, 0, currentFaction and currentFaction ~= "" and 55 or 40),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = BODY_TEXT_COLOR,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	})
	
	local choicesTitle = createStrokeTextLabel(choicesBox, {
		Size = UDim2.new(1, 0, 0, 25),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "Choix:",
		TextColor3 = SPEAKER_NAME_COLOR,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	
	local choicesStartY = 35
	
	if hasChoices and currentOptions then
		for i, option in ipairs(currentOptions) do
			createButton(choicesBox, option.text, choicesStartY, function()
				advanceDialogue(i)
			end)
			choicesStartY = choicesStartY + 45
		end
	end
	
	createButton(choicesBox, "Quitter", choicesStartY, function()
		closeDialogue()
	end)
	
	print(string.format("[NPC] %s: %s", currentNpcName, message))
end

advanceDialogue = function(optionIndex: number?)
	if not currentNpcId then
		return
	end

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
	if not currentNpcId or not currentNpcPosition then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

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

local function createChoiceButtons()
	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NPCDialogueResponses"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	dialogueScreenGui = screenGui

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(0.4, 0, 0, 60)
	buttonContainer.Position = UDim2.new(0.3, 0, 0.7, 0)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = screenGui

	local continueButton = Instance.new("TextButton")
	continueButton.Name = "ContinueButton"
	continueButton.Size = UDim2.new(1, 0, 0, 40)
	continueButton.Position = UDim2.new(0, 0, 0, 0)
	continueButton.BackgroundColor3 = BUTTON_DEFAULT_FILL
	continueButton.BackgroundTransparency = 0
	continueButton.BorderSizePixel = 0
	continueButton.TextColor3 = BODY_TEXT_COLOR
	continueButton.TextSize = 18
	continueButton.Font = Enum.Font.Gotham
	continueButton.Text = "Continuer"
	continueButton.Parent = buttonContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = continueButton

	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = BUTTON_DEFAULT_BORDER
	borderStroke.Thickness = 2
	borderStroke.Transparency = 0
	borderStroke.Parent = continueButton

	local textStroke = Instance.new("UIStroke")
	textStroke.Color = TEXT_STROKE_COLOR
	textStroke.Thickness = 2
	textStroke.Transparency = 0
	textStroke.Parent = continueButton

	continueButton.MouseEnter:Connect(function()
		continueButton.BackgroundColor3 = BUTTON_HOVER_FILL
		borderStroke.Color = BUTTON_HOVER_BORDER
		continueButton.TextColor3 = BUTTON_HOVER_TEXT
	end)

	continueButton.MouseLeave:Connect(function()
		continueButton.BackgroundColor3 = BUTTON_DEFAULT_FILL
		borderStroke.Color = BUTTON_DEFAULT_BORDER
		continueButton.TextColor3 = BODY_TEXT_COLOR
	end)

	continueButton.MouseButton1Click:Connect(function()
		advanceDialogue()
	end)

	local totalButtons = 1
	if #dialogueHistory > 0 then
		local backButton = Instance.new("TextButton")
		backButton.Name = "BackButton"
		backButton.Size = UDim2.new(1, 0, 0, 40)
		backButton.Position = UDim2.new(0, 0, 0, 45)
		backButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
		backButton.BackgroundTransparency = 0
		backButton.BorderSizePixel = 0
		backButton.TextColor3 = BODY_TEXT_COLOR
		backButton.TextSize = 18
		backButton.Font = Enum.Font.Gotham
		backButton.Text = "← Retour"
		backButton.Parent = buttonContainer

		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(0, 8)
		backCorner.Parent = backButton

		local backBorder = Instance.new("UIStroke")
		backBorder.Color = Color3.fromRGB(150, 100, 100)
		backBorder.Thickness = 2
		backBorder.Transparency = 0
		backBorder.Parent = backButton

		local backTextStroke = Instance.new("UIStroke")
		backTextStroke.Color = TEXT_STROKE_COLOR
		backTextStroke.Thickness = 2
		backTextStroke.Transparency = 0
		backTextStroke.Parent = backButton

		backButton.MouseEnter:Connect(function()
			backButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
			backBorder.Color = Color3.fromRGB(180, 120, 120)
			backButton.TextColor3 = BUTTON_HOVER_TEXT
		end)

		backButton.MouseLeave:Connect(function()
			backButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
			backBorder.Color = Color3.fromRGB(150, 100, 100)
			backButton.TextColor3 = BODY_TEXT_COLOR
		end)

		backButton.MouseButton1Click:Connect(function()
			if #dialogueHistory > 0 then
				local previousState = dialogueHistory[#dialogueHistory]
				dialogueHistory[#dialogueHistory] = nil

				currentNpcId = previousState.npcId
				currentNode = previousState.node
				currentText = previousState.text
				currentNpcName = previousState.npcName
				currentFaction = previousState.faction
				hasChoices = previousState.hasChoices

				cleanupUI()
				updateDialogueText(currentText)
				-- Buttons are now in the dialogue box
			end
		end)

		totalButtons = 2
		buttonContainer.Size = UDim2.new(0.4, 0, 0, totalButtons * 45)
	end

	keyboardConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
			if not hasChoices then
				closeDialogue()
			else
				advanceDialogue()
			end
		end

		if input.KeyCode == Enum.KeyCode.Backspace and #dialogueHistory > 0 then
			local previousState = dialogueHistory[#dialogueHistory]
			dialogueHistory[#dialogueHistory] = nil

			currentNpcId = previousState.npcId
			currentNode = previousState.node
			currentText = previousState.text
			currentNpcName = previousState.npcName
			currentFaction = previousState.faction
			hasChoices = previousState.hasChoices

			cleanupUI()
			updateDialogueText(currentText)
			-- Buttons are now in the dialogue box
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			closeDialogue()
		end
	end)
end

local NPCDialogueClient = {}

function NPCDialogueClient.startConversation(npcId: string): boolean
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
		if not currentNpcPosition then
			warn("[NPCDialogueClient] Warning: NPC position is nil, proximity check will not work")
		else
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

function NPCDialogueClient.isInDialogue(): boolean
	return currentNpcId ~= nil
end

function NPCDialogueClient.close()
	closeDialogue()
end

print("[NPCDialogueClient] Initialized")

return NPCDialogueClient