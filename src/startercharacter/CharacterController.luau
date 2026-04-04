--!strict
-- Character Controller for Aethelgard
-- Handles movement modes (walk/run/sprint), roll, and sprint after roll

local CharacterController = {}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local WALK_SPEED = 4
local RUN_SPEED = 20
local SPRINT_SPEED = 28 -- kept for reference, sprint mode removed
local ROLL_DURATION = 0.6
local ROLL_COOLDOWN = 0.5
local ROLL_SPEED = 10

local ANIMATION_IDS = {
	jump = "rbxassetid://108106429101245",
	idle = "rbxassetid://84086295990611",
	walk = "rbxassetid://136030979445483",
	run = "rbxassetid://102336932853638",
	sprint = "rbxassetid://83631981628798",
	roll = "rbxassetid://105365358558101",
	land = "rbxassetid://82760984285201",
}

local MovementMode = {
	Walk = "Walk",
	Run = "Run",
	Sprint = "Sprint",
}

local character: Model
local humanoid: Humanoid
local rootPart: BasePart

local currentMovementMode = MovementMode.Run
local isRolling = false
local lastRollTime = 0
local sprintActive = false
local wasMoving = false

local animationTracks = {}
local currentAnimation = nil
local isJumping = false

local function getAnimator()
	local animator = humanoid:FindFirstChildWhichIsA("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

local function loadAnimation(animator, animName, animationId)
	if animationId == "" then
		return nil
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	animation.Name = animName
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if success and track then
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = (animName ~= "jump" and animName ~= "land" and animName ~= "roll")
		return track
	else
		warn("[CharacterController] Failed to load animation:", animName, animationId)
		return nil
	end
end

local function loadAllAnimations()
	local animator = getAnimator()
	for animName, animId in pairs(ANIMATION_IDS) do
		local track = loadAnimation(animator, animName, animId)
		if track then
			animationTracks[animName] = track
		end
	end
end

local function stopCurrentAnimation(fadeTime)
	if currentAnimation and animationTracks[currentAnimation] then
		animationTracks[currentAnimation]:Stop(fadeTime)
	end
	currentAnimation = nil
end

local function playAnimation(animName, fadeTime)
	fadeTime = fadeTime or 0.1

	local track = animationTracks[animName]
	if not track then
		warn("[CharacterController] Track not found:", animName)
		return
	end

	if currentAnimation == animName then
		return
	end

	stopCurrentAnimation(fadeTime)
	track:Play(fadeTime)
	currentAnimation = animName
end

local function getMoveDirection(): Vector3
	return humanoid.MoveDirection
end

local function setWalkSpeed(speed: number)
	humanoid.WalkSpeed = speed
end

local function updateWalkSpeed()
	if isRolling then
		return
	end

	if currentMovementMode == MovementMode.Walk then
		setWalkSpeed(WALK_SPEED)
	elseif currentMovementMode == MovementMode.Run then
		setWalkSpeed(RUN_SPEED)
	elseif currentMovementMode == MovementMode.Sprint then
		setWalkSpeed(SPRINT_SPEED)
	end
end

local function toggleMovementMode()
	if currentMovementMode == MovementMode.Walk then
		currentMovementMode = MovementMode.Run
	else
		currentMovementMode = MovementMode.Walk
	end
	updateWalkSpeed()
end



local function roll()
	if isRolling then
		return
	end

	local currentTime = tick()
	if currentTime - lastRollTime < ROLL_COOLDOWN then
		return
	end

	isRolling = true
	lastRollTime = currentTime

	local moveDir = getMoveDirection()
	local rollDirection = if moveDir.Magnitude > 0.1 then moveDir.Unit else rootPart.CFrame.LookVector

	setWalkSpeed(ROLL_SPEED)

	task.delay(ROLL_DURATION, function()
		if isRolling then
			isRolling = false
			if moveDir.Magnitude > 0.1 then
				currentMovementMode = MovementMode.Sprint
			end
			updateWalkSpeed()
		end
	end)
end

local function onRollKeyBegin()
	if isRolling then
		return
	end

	roll()
end

local function onRollKeyEnd()
end

local function onLeftCtrlPress()
	toggleMovementMode()
end

local function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		onRollKeyBegin()
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		onLeftCtrlPress()
	end
end

local function onInputEnded(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		onRollKeyEnd()
	end
end

local function onStateChanged(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		isJumping = true
		playAnimation("jump", 0.1)
	elseif newState == Enum.HumanoidStateType.Freefall then
		if isJumping then
			playAnimation("jump", 0.1)
		end
	elseif newState == Enum.HumanoidStateType.Landed then
		if isJumping then
			isJumping = false
			playAnimation("land", 0.05)
			task.delay(0.2, function()
				if currentAnimation == "land" then
					playAnimation("idle", 0.2)
				end
			end)
		end
	elseif newState == Enum.HumanoidStateType.Running then
		isJumping = false
	end
end

local function updateAnimations()
	if isRolling then
		playAnimation("roll", 0.1)
		return
	end

	local state = humanoid:GetState()

	if state == Enum.HumanoidStateType.Running then
		local moveDirection = humanoid.MoveDirection
		local speed = moveDirection.Magnitude

		if speed > 0.5 then
			if currentMovementMode == MovementMode.Sprint then
				playAnimation("sprint", 0.15)
			elseif currentMovementMode == MovementMode.Run then
				playAnimation("run", 0.15)
			else
				playAnimation("walk", 0.15)
			end
		else
			if currentMovementMode == MovementMode.Sprint then
				currentMovementMode = MovementMode.Run
				updateWalkSpeed()
			end
			playAnimation("idle", 0.2)
		end
	elseif state == Enum.HumanoidStateType.Seated then
		playAnimation("idle", 0.2)
	elseif state ~= Enum.HumanoidStateType.Jumping
		and state ~= Enum.HumanoidStateType.Freefall
		and state ~= Enum.HumanoidStateType.Landed then
		playAnimation("idle", 0.2)
	end
end

local function onHeartbeat()
	if isRolling then
		local moveDir = getMoveDirection()
		if moveDir.Magnitude > 0.1 then
			rootPart.CFrame = rootPart.CFrame + moveDir.Unit * ROLL_SPEED * 0.016
		else
			rootPart.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * ROLL_SPEED * 0.016
		end
	end

	updateAnimations()
end

function CharacterController.init(newCharacter: Model)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	currentMovementMode = MovementMode.Run
	isRolling = false
	lastRollTime = 0

	loadAllAnimations()
	playAnimation("idle", 0)

	updateWalkSpeed()

	humanoid.StateChanged:Connect(onStateChanged)
	UserInputService.InputBegan:Connect(onInputBegan)
	UserInputService.InputEnded:Connect(onInputEnded)
	RunService.Heartbeat:Connect(onHeartbeat)

	print("[CharacterController] Initialized")
end

function CharacterController.getMovementMode(): string
	return currentMovementMode
end

function CharacterController.isRolling(): boolean
	return isRolling
end

function CharacterController.setMovementMode(mode: string)
	if mode == MovementMode.Walk or mode == MovementMode.Run or mode == MovementMode.Sprint then
		currentMovementMode = mode
		updateWalkSpeed()
	end
end

return CharacterController
