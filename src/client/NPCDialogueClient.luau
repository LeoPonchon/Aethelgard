--!nonstrict
-- NPC Dialogue Client System for Aethelgard
-- Handles displaying NPC dialogues with cinematic subtitle style
-- Text floats directly on 3D render with black stroke for readability

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remotes with timeout
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

-- ============================================
-- COLOR DEFINITIONS (per design spec)
-- ============================================

-- Speaker name: Blue-violet light RGB(200, 200, 255)
local SPEAKER_NAME_COLOR = Color3.fromRGB(200, 200, 255)

-- Faction label: Violet light RGB(180, 140, 220)
local FACTION_LABEL_COLOR = Color3.fromRGB(180, 140, 220)

-- Body text: White RGB(255, 255, 255)
local BODY_TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- Text stroke: Black deep RGB(0, 0, 0) at 100% opacity
local TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)

-- Button default fill: Blue-gray dark RGB(40, 40, 60)
local BUTTON_DEFAULT_FILL = Color3.fromRGB(40, 40, 60)

-- Button default border: Violet-gray RGB(100, 100, 150)
local BUTTON_DEFAULT_BORDER = Color3.fromRGB(100, 100, 150)

-- Button hover fill: Violet medium RGB(60, 60, 100)
local BUTTON_HOVER_FILL = Color3.fromRGB(60, 60, 100)

-- Button hover border: Violet medium RGB(120, 80, 150)
local BUTTON_HOVER_BORDER = Color3.fromRGB(120, 80, 150)

-- Button hover text: Blue-violet light RGB(200, 200, 255)
local BUTTON_HOVER_TEXT = Color3.fromRGB(200, 200, 255)

-- Action indicator: Blue-violet light RGB(200, 200, 255)
local ACTION_INDICATOR_COLOR = Color3.fromRGB(200, 200, 255)

-- Back button colors
local BACK_BUTTON_FILL = Color3.fromRGB(60, 40, 40)
local BACK_BUTTON_BORDER = Color3.fromRGB(150, 100, 100)

-- ============================================
-- DIALOGUE STATE
-- ============================================

local currentDialogue = nil
local currentNPC = nil
local currentNPCName = nil
local currentFaction = nil
local currentResponses = {}
local dialogueTextGui = nil
local dialogueScreenGui = nil
local responseButtons = {}
local actionIndicator = nil
local actionIndicatorTween = nil
local keyboardConnection = nil

-- Dialogue history for back navigation
local dialogueHistory = {} -- Stack of {dialogueData, npcName, faction, responses}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Create a text label with black stroke for readability
local function createStrokeTextLabel(parent: Instance, props: {[string]: any}): TextLabel
	local label = Instance.new("TextLabel")
	
	-- Apply all provided properties
	for key, value in pairs(props) do
		label[key] = value
	end
	
	label.Parent = parent
	
	-- Add black text stroke for readability on any background
	local stroke = Instance.new("UIStroke")
	stroke.Color = TEXT_STROKE_COLOR
	stroke.Thickness = 3
	stroke.Transparency = 0 -- 100% opacity
	stroke.Parent = label
	
	return label
end

-- ============================================
-- DIALOGUE TEXT DISPLAY (Cinematic Subtitle Style)
-- ============================================

-- Update the dialogue text display (replaces existing text)
local function updateDialogueText(message: string)
	-- Get or create the dialogue text GUI
	local screenGui = dialogueTextGui
	
	if not screenGui or not screenGui.Parent then
		-- Create a ScreenGui for the dialogue display
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "NPCDialogueText"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
		dialogueTextGui = screenGui
	end
	
	-- Get or create the container
	local container = screenGui:FindFirstChild("DialogueContainer")
	
	if not container then
		-- Main container at bottom of screen (cinematic subtitle position)
		container = Instance.new("Frame")
		container.Name = "DialogueContainer"
		container.Size = UDim2.new(0.8, 0, 0, 150)
		container.Position = UDim2.new(0.1, 0, 1, -200)
		container.BackgroundTransparency = 1 -- No background, text floats directly
		container.Parent = screenGui
		
		-- Animate in
		container.Position = UDim2.new(0.1, 0, 1, -150)
		local tweenIn = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.1, 0, 1, -200)
		})
		tweenIn:Play()
	end
	
	-- Clear existing content (except the container itself)
	for _, child in ipairs(container:GetChildren()) do
		child:Destroy()
	end
	
	-- Speaker name (Blue-violet light with black stroke)
	local nameLabel = createStrokeTextLabel(container, {
		Size = UDim2.new(0, 300, 0, 30),
		Position = UDim2.new(0.5, -150, 0, 0),
		BackgroundTransparency = 1,
		Text = currentNPCName or "NPC",
		TextColor3 = SPEAKER_NAME_COLOR,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	
	-- Faction label if provided (Violet light with black stroke)
	if currentFaction and currentFaction ~= "" then
		local factionLabel = createStrokeTextLabel(container, {
			Size = UDim2.new(0, 200, 0, 20),
			Position = UDim2.new(0.5, -100, 0, 28),
			BackgroundTransparency = 1,
			Text = currentFaction,
			TextColor3 = FACTION_LABEL_COLOR,
			TextSize = 16,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end
	
	-- Message body (White with black stroke)
	local messageLabel = createStrokeTextLabel(container, {
		Size = UDim2.new(0.9, 0, 0, 60),
		Position = UDim2.new(0.05, 0, 0, currentFaction and currentFaction ~= "" and 55 or 35),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = BODY_TEXT_COLOR,
		TextSize = 20,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	})
	
	-- Also print to console for accessibility
	print(string.format("[NPC] %s: %s", currentNPCName or "NPC", message))
end

-- ============================================
-- ACTION INDICATOR (Blinking) - Under NPC Text
-- ============================================

-- Create blinking action indicator under the dialogue text
local function createActionIndicator()
	-- Remove existing indicator
	if actionIndicator then
		actionIndicator:Destroy()
		actionIndicator = nil
	end
	if actionIndicatorTween then
		actionIndicatorTween:Cancel()
		actionIndicatorTween = nil
	end
	
	-- Get the dialogue text container
	if not dialogueTextGui or not dialogueTextGui.Parent then
		return
	end
	
	local container = dialogueTextGui:FindFirstChild("DialogueContainer")
	if not container then
		return
	end
	
	-- Create indicator (small triangle/arrow) - positioned under the text
	local indicator = Instance.new("TextLabel")
	indicator.Name = "ActionIndicator"
	indicator.Size = UDim2.new(0, 30, 0, 30)
	indicator.Position = UDim2.new(0.5, -15, 1, 5) -- Just below the container
	indicator.BackgroundTransparency = 1
	indicator.Text = "▼"
	indicator.TextColor3 = ACTION_INDICATOR_COLOR
	indicator.TextSize = 24
	indicator.Font = Enum.Font.GothamBold
	indicator.Parent = container
	
	-- Add stroke for visibility
	local stroke = Instance.new("UIStroke")
	stroke.Color = TEXT_STROKE_COLOR
	stroke.Thickness = 2
	stroke.Transparency = 0
	stroke.Parent = indicator
	
	actionIndicator = indicator
	
	-- Create blinking effect
	local function blink()
		if not actionIndicator or not actionIndicator.Parent then return end
		
		actionIndicatorTween = TweenService:Create(actionIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			TextTransparency = 0.7
		})
		actionIndicatorTween:Play()
		actionIndicatorTween.Completed:Connect(function()
			if not actionIndicator or not actionIndicator.Parent then return end
			
			actionIndicatorTween = TweenService:Create(actionIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				TextTransparency = 0
			})
			actionIndicatorTween:Play()
			actionIndicatorTween.Completed:Connect(function()
				task.wait(0.1)
				blink()
			end)
		end)
	end
	
	blink()
end

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================

local function setupKeyboardShortcuts(numResponses: number, hasBackOption: boolean, indexMapping: {[number]: number})
	-- Disconnect previous connection
	if keyboardConnection then
		keyboardConnection:Disconnect()
		keyboardConnection = nil
	end

	-- Number keys 1-9 for responses
	keyboardConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Number keys
		local keyCode = input.KeyCode
		local keyMap = {
			[Enum.KeyCode.One] = 1,
			[Enum.KeyCode.Two] = 2,
			[Enum.KeyCode.Three] = 3,
			[Enum.KeyCode.Four] = 4,
			[Enum.KeyCode.Five] = 5,
			[Enum.KeyCode.Six] = 6,
			[Enum.KeyCode.Seven] = 7,
			[Enum.KeyCode.Eight] = 8,
			[Enum.KeyCode.Nine] = 9,
		}

		local displayIndex = keyMap[keyCode]
		if displayIndex and displayIndex <= numResponses then
			-- Map display index to original index for server communication
			local originalIndex = indexMapping and indexMapping[displayIndex] or displayIndex
			selectResponse(originalIndex)
		end

		-- Backspace for back navigation
		if input.KeyCode == Enum.KeyCode.Backspace and hasBackOption then
			goBackInDialogue()
		end

		-- Escape to close dialogue
		if input.KeyCode == Enum.KeyCode.Escape then
			closeDialogue()
		end
	end)
end

-- ============================================
-- DIALOGUE FLOW - Forward declarations
-- ============================================

-- Forward declarations for functions that reference each other
local selectResponse = nil
local closeDialogue = nil
local showDialogue = nil
local goBackInDialogue = nil

-- ============================================
-- RESPONSE BUTTONS (Cinematic Style)
-- ============================================

-- Create response buttons as clickable UI elements
-- Returns a mapping from display index to original index for proper server communication
local function createResponseButtons(responses: {any})
	-- Remove existing buttons UI
	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
		dialogueScreenGui = nil
	end
	responseButtons = {}

	if #responses == 0 then return end

	-- Check if we have history for back button
	local hasHistory = #dialogueHistory > 0

	-- Filter out server-side "Retour" responses if we have client-side history
	-- The client-side back button (red) is preferred for navigation
	-- Store mapping from display index to original index
	local filteredResponses = {}
	local indexMapping = {} -- displayIndex -> originalIndex
	for originalIndex, response in ipairs(responses) do
		-- Keep response unless it's a "Retour" response and we have history
		local isServerBack = response.text:match("^Retour$") or response.text:match("^← Retour$")
		if not (hasHistory and isServerBack) then
			local displayIndex = #filteredResponses + 1
			table.insert(filteredResponses, response)
			indexMapping[displayIndex] = originalIndex
		end
	end

	local totalButtons = #filteredResponses + (hasHistory and 1 or 0)
	
	-- Create a ScreenGui for the responses
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NPCDialogueResponses"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	
	-- Container for buttons (positioned above dialogue text)
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(0.6, 0, 0, totalButtons * 45)
	buttonContainer.Position = UDim2.new(0.2, 0, 0.5, -100)
	buttonContainer.BackgroundTransparency = 1 -- No background
	buttonContainer.Parent = screenGui
	
	-- Create response buttons
	for i, response in ipairs(filteredResponses) do
		local button = Instance.new("TextButton")
		button.Name = "Response_" .. i
		button.Size = UDim2.new(1, 0, 0, 40)
		button.Position = UDim2.new(0, 0, 0, (i - 1) * 45)

		-- Default state: Blue-gray dark fill
		button.BackgroundColor3 = BUTTON_DEFAULT_FILL
		button.BackgroundTransparency = 0 -- Solid fill
		button.BorderSizePixel = 0

		-- Text styling
		button.TextColor3 = BODY_TEXT_COLOR
		button.TextSize = 18
		button.Font = Enum.Font.Gotham
		button.Text = i .. ". " .. response.text

		button.Parent = buttonContainer

		-- Add corner radius
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button

		-- Add border stroke (Violet-gray)
		local borderStroke = Instance.new("UIStroke")
		borderStroke.Color = BUTTON_DEFAULT_BORDER
		borderStroke.Thickness = 2
		borderStroke.Transparency = 0
		borderStroke.Parent = button

		-- Add text stroke for readability
		local textStroke = Instance.new("UIStroke")
		textStroke.Color = TEXT_STROKE_COLOR
		textStroke.Thickness = 2
		textStroke.Transparency = 0
		textStroke.Parent = button

		-- Hover effect
		button.MouseEnter:Connect(function()
			-- Hover state: Violet medium fill
			button.BackgroundColor3 = BUTTON_HOVER_FILL
			-- Hover border: Violet medium
			borderStroke.Color = BUTTON_HOVER_BORDER
			-- Hover text: Blue-violet light
			button.TextColor3 = BUTTON_HOVER_TEXT
		end)

		button.MouseLeave:Connect(function()
			-- Reset to default state
			button.BackgroundColor3 = BUTTON_DEFAULT_FILL
			borderStroke.Color = BUTTON_DEFAULT_BORDER
			button.TextColor3 = BODY_TEXT_COLOR
		end)

		-- Click handler - use closure to capture display index and map to original
		button.MouseButton1Click:Connect(function()
			if selectResponse then
				-- Map display index to original index for server communication
				local originalIndex = indexMapping[i]
				if originalIndex then
					selectResponse(originalIndex)
				end
			end
		end)

		table.insert(responseButtons, button)
	end

	-- Add back button if we have history
	if hasHistory then
		local backButton = Instance.new("TextButton")
		backButton.Name = "BackButton"
		backButton.Size = UDim2.new(1, 0, 0, 40)
		backButton.Position = UDim2.new(0, 0, 0, #filteredResponses * 45)
		
		-- Back button styling (slightly different color)
		backButton.BackgroundColor3 = BACK_BUTTON_FILL
		backButton.BackgroundTransparency = 0
		backButton.BorderSizePixel = 0
		backButton.TextColor3 = BODY_TEXT_COLOR
		backButton.TextSize = 18
		backButton.Font = Enum.Font.Gotham
		backButton.Text = "← Retour"
		backButton.Parent = buttonContainer
		
		-- Add corner radius
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = backButton
		
		-- Add border stroke
		local borderStroke = Instance.new("UIStroke")
		borderStroke.Color = BACK_BUTTON_BORDER
		borderStroke.Thickness = 2
		borderStroke.Transparency = 0
		borderStroke.Parent = backButton
		
		-- Add text stroke
		local textStroke = Instance.new("UIStroke")
		textStroke.Color = TEXT_STROKE_COLOR
		textStroke.Thickness = 2
		textStroke.Transparency = 0
		textStroke.Parent = backButton
		
		-- Hover effect for back button
		backButton.MouseEnter:Connect(function()
			backButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
			borderStroke.Color = Color3.fromRGB(180, 120, 120)
			backButton.TextColor3 = BUTTON_HOVER_TEXT
		end)
		
		backButton.MouseLeave:Connect(function()
			backButton.BackgroundColor3 = BACK_BUTTON_FILL
			borderStroke.Color = BACK_BUTTON_BORDER
			backButton.TextColor3 = BODY_TEXT_COLOR
		end)
		
		-- Click handler for back button
		backButton.MouseButton1Click:Connect(function()
			if goBackInDialogue then
				goBackInDialogue()
			end
		end)
	end
	
	dialogueScreenGui = screenGui

	-- Setup keyboard shortcuts with index mapping
	setupKeyboardShortcuts(#filteredResponses, hasHistory, indexMapping)

	-- Create action indicator under NPC text
	createActionIndicator()
end

-- ============================================
-- DIALOGUE HISTORY MANAGEMENT
-- ============================================

-- Save current dialogue state to history
local function saveToHistory(dialogueData: any, npcName: string?, faction: string?, responses: {any})
	-- Deep copy the responses to preserve them
	local responsesCopy = {}
	for i, response in ipairs(responses) do
		responsesCopy[i] = {
			text = response.text,
			nextDialogue = response.nextDialogue
		}
	end
	
	-- Save to history stack
	table.insert(dialogueHistory, {
		dialogueData = dialogueData,
		npcName = npcName,
		faction = faction,
		responses = responsesCopy
	})
end

-- Go back to previous dialogue
goBackInDialogue = function()
	if #dialogueHistory == 0 then
		return
	end
	
	-- Pop the last state from history
	local previousState = dialogueHistory[#dialogueHistory]
	dialogueHistory[#dialogueHistory] = nil
	
	-- Restore the previous state
	currentDialogue = previousState.dialogueData.id
	currentNPCName = previousState.npcName
	currentFaction = previousState.faction
	currentResponses = previousState.responses
	
	-- Update the display
	updateDialogueText(previousState.dialogueData.text)
	createResponseButtons(previousState.responses)
	
	print("[NPCDialogueClient] Went back to previous dialogue")
end

-- ============================================
-- DIALOGUE FLOW - Implementations
-- ============================================

-- Select a response and send to server
selectResponse = function(index: number)
	if not currentDialogue or not currentResponses[index] then
		return
	end

	local response = currentResponses[index]

	-- Save current state to history before advancing
	saveToHistory({
		id = currentDialogue,
		text = dialogueTextGui and dialogueTextGui:FindFirstChild("DialogueContainer") 
			and dialogueTextGui.DialogueContainer:FindFirstChild("MessageLabel") 
			and dialogueTextGui.DialogueContainer.MessageLabel.Text or "",
		responses = currentResponses
	}, currentNPCName, currentFaction, currentResponses)

	-- Remove response buttons UI
	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
		dialogueScreenGui = nil
	end
	
	-- Remove action indicator
	if actionIndicator then
		actionIndicator:Destroy()
		actionIndicator = nil
	end
	if actionIndicatorTween then
		actionIndicatorTween:Cancel()
		actionIndicatorTween = nil
	end

	-- Disconnect keyboard
	if keyboardConnection then
		keyboardConnection:Disconnect()
		keyboardConnection = nil
	end

	-- Check if this ends the conversation (nextDialogue is nil)
	if response.nextDialogue == nil then
		closeDialogue()
		return
	end

	-- Request next dialogue from server
	if npcInteractionRemote then
		local result = npcInteractionRemote:InvokeServer("processResponse", {
			npcId = currentNPC,
			dialogueId = currentDialogue,
			responseIndex = index,
		})

		if result and result.dialogue then
			-- Update NPC name and faction if provided
			if result.npcName then
				currentNPCName = result.npcName
			end
			if result.faction then
				currentFaction = result.faction
			end
			
			-- Show the next dialogue (replaces text and choices)
			showDialogue(result.npcId, result.dialogue, result.npcName, result.faction)
		end
	end
end

-- Close the current dialogue
closeDialogue = function()
	currentDialogue = nil
	currentNPC = nil
	currentNPCName = nil
	currentFaction = nil
	currentResponses = {}
	dialogueHistory = {} -- Clear history when closing

	if dialogueScreenGui then
		dialogueScreenGui:Destroy()
		dialogueScreenGui = nil
	end
	
	-- Remove action indicator
	if actionIndicator then
		actionIndicator:Destroy()
		actionIndicator = nil
	end
	if actionIndicatorTween then
		actionIndicatorTween:Cancel()
		actionIndicatorTween = nil
	end

	if keyboardConnection then
		keyboardConnection:Disconnect()
		keyboardConnection = nil
	end

	-- Remove dialogue text GUI with animation
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

	print("[NPCDialogueClient] Dialogue closed")
end

-- Show a dialogue from an NPC
showDialogue = function(npcId: string, dialogueData: any, npcName: string?, faction: string?)
	currentDialogue = dialogueData.id
	currentNPC = npcId
	
	-- Store NPC name and faction for text display
	if npcName then
		currentNPCName = npcName
	end
	if faction then
		currentFaction = faction
	end

	-- Update the dialogue text (replaces existing text)
	updateDialogueText(dialogueData.text)

	-- Show response options if available
	if dialogueData.responses and #dialogueData.responses > 0 then
		currentResponses = dialogueData.responses
		createResponseButtons(dialogueData.responses)
	else
		-- No responses - this shouldn't happen in proper dialogue design
		-- But if it does, add a default close option
		currentResponses = {
			{ text = "Je vois, je vais y aller", nextDialogue = nil }
		}
		createResponseButtons(currentResponses)
	end
end

-- ============================================
-- PUBLIC API
-- ============================================

local NPCDialogueClient = {}

-- Start a conversation with an NPC
function NPCDialogueClient.startConversation(npcId: string): boolean
	if not npcInteractionRemote then
		warn("[NPCDialogueClient] NPCInteraction remote not found")
		return false
	end

	-- Close any existing dialogue
	closeDialogue()

	-- Request conversation from server
	local result = npcInteractionRemote:InvokeServer("startConversation", { npcId = npcId })

	if result and result.dialogue then
		showDialogue(npcId, result.dialogue, result.npcName, result.faction)
		return true
	end

	return false
end

-- Show conversation directly (called by server via init.client)
function NPCDialogueClient.showConversation(data: any): boolean
	if not data or not data.conversation then
		warn("[NPCDialogueClient] Invalid conversation data")
		return false
	end

	-- Close any existing dialogue
	closeDialogue()

	-- Extract conversation data
	local conversation = data.conversation
	local npcName = data.npcName or "NPC"
	local npcId = data.npcId
	local faction = data.faction

	-- The conversation structure is: {npc = NPCData, dialogue = DialogueData}
	-- NPCData has: name, dialogues, defaultDialogue
	-- DialogueData is the current dialogue to show

	if conversation.dialogue then
		-- Direct dialogue provided
		showDialogue(npcId, conversation.dialogue, npcName, faction)
		return true
	end

	-- Fallback: try to get dialogue from npc.dialogues
	if conversation.npc and conversation.npc.dialogues then
		local npc = conversation.npc
		local defaultId = npc.defaultDialogue
		if defaultId and npc.dialogues[defaultId] then
			showDialogue(npcId, npc.dialogues[defaultId], npcName, faction)
			return true
		end
		-- Try first dialogue
		for id, dialogue in pairs(npc.dialogues) do
			showDialogue(npcId, dialogue, npcName, faction)
			return true
		end
	end

	warn("[NPCDialogueClient] No dialogue found in conversation")
	return false
end

-- Get NPC info
function NPCDialogueClient.getNPCInfo(npcId: string): any
	if not npcInteractionRemote then return nil end

	return npcInteractionRemote:InvokeServer("getNPCInfo", { npcId = npcId })
end

-- Check if in dialogue
function NPCDialogueClient.isInDialogue(): boolean
	return currentDialogue ~= nil
end

-- Close current dialogue
function NPCDialogueClient.close()
	closeDialogue()
end

print("[NPCDialogueClient] Initialized")

return NPCDialogueClient
