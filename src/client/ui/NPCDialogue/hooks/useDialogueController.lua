local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local React = require(script.Parent.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("React"))

local player = Players.LocalPlayer

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

	warn("[useDialogueController] Timeout waiting for remote:", remoteName)
	return nil
end

local function useDialogueController()
	local npcInteractionRemote = waitForRemote("NPCInteraction", 10)

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
		local state = dialogueState
		if not state.npcId or not state.npcPosition then return end

		local character = player.Character
		if not character then return end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		local distance = (humanoidRootPart.Position - state.npcPosition).Magnitude

		if distance > 20 then
			print("[useDialogueController] Player too far from NPC, closing dialogue")
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
		local state = dialogueState
		if not state.npcId then return end

		if not npcInteractionRemote then return end

		local result = npcInteractionRemote:InvokeServer("advanceDialogue", {
			npcId = state.npcId,
			currentNode = state.currentNode,
			optionIndex = optionIndex,
		})

		if result then
			setDialogueState({
				isActive = true,
				npcId = state.npcId,
				npcName = result.npcName or state.npcName,
				faction = result.faction or "",
				currentNode = result.currentNode,
				text = result.text or "",
				options = result.options or {},
				hasChoices = result.hasChoices or false,
				npcPosition = state.npcPosition,
			})

			if result.endConversation then
				task.delay(2, closeDialogue)
			end
		end
	end, {npcInteractionRemote, closeDialogue})

	local startConversation = React.useCallback(function(npcId)
		if not npcInteractionRemote then
			warn("[useDialogueController] NPCInteraction remote not found")
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
	end, {npcInteractionRemote, closeDialogue, startProximityCheck})

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

return useDialogueController
