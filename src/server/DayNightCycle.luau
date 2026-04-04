--!strict
-- Day/Night Cycle System for Aethelgard
-- Manages time progression, lighting, and skybox rotation

local DayNightCycle = {}

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local sky = Lighting:FindFirstChild("Sky")

local CYCLE_DURATION = 60
local ROTATION_SPEED = 5

local TIME_SETTINGS = {
	[0] = {
		Ambient = Color3.fromRGB(169, 49, 255),
		Brightness = 0,
		ColorShift_Bottom = Color3.new(),
		ColorShift_Top = Color3.fromRGB(100, 50, 150),
		OutdoorAmbient = Color3.fromRGB(0, 0, 50),
	},
	[6] = {
		Ambient = Color3.fromRGB(255, 200, 150),
		Brightness = 1,
		ColorShift_Bottom = Color3.fromRGB(255, 150, 100),
		ColorShift_Top = Color3.fromRGB(255, 200, 150),
		OutdoorAmbient = Color3.fromRGB(255, 180, 100),
	},
	[12] = {
		Ambient = Color3.fromRGB(240, 167, 93),
		Brightness = 3,
		ColorShift_Bottom = Color3.new(),
		ColorShift_Top = Color3.fromRGB(213, 199, 0),
		OutdoorAmbient = Color3.fromRGB(251, 255, 0),
	},
	[18] = {
		Ambient = Color3.fromRGB(255, 130, 100),
		Brightness = 1,
		ColorShift_Bottom = Color3.fromRGB(180, 50, 50),
		ColorShift_Top = Color3.fromRGB(255, 150, 100),
		OutdoorAmbient = Color3.fromRGB(255, 100, 50),
	},
}

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function lerpColor3(a: Color3, b: Color3, t: number): Color3
	return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function getSettings(clockTime: number)
	local times = table.create(4)
	for k in pairs(TIME_SETTINGS) do
		table.insert(times, k)
	end
	table.sort(times)

	local current, nextIdx = times[1], 1
	for i = 1, #times do
		if times[i] <= clockTime then
			current = times[i]
			nextIdx = i < #times and i + 1 or 1
		end
	end

	local next = times[nextIdx]
	local currentSettings = TIME_SETTINGS[current]
	local nextSettings = TIME_SETTINGS[next]

	local t = (clockTime - current) / (next - current)
	if t < 0 then
		t = t + 1
	end

	return {
		Ambient = lerpColor3(currentSettings.Ambient, nextSettings.Ambient, t),
		Brightness = lerp(currentSettings.Brightness, nextSettings.Brightness, t),
		ColorShift_Bottom = lerpColor3(currentSettings.ColorShift_Bottom, nextSettings.ColorShift_Bottom, t),
		ColorShift_Top = lerpColor3(currentSettings.ColorShift_Top, nextSettings.ColorShift_Top, t),
		OutdoorAmbient = lerpColor3(currentSettings.OutdoorAmbient, nextSettings.OutdoorAmbient, t),
	}
end

local function onHeartbeat(deltaTime: number)
	local cycleProgress = (workspace:GetServerTimeNow() % CYCLE_DURATION) / CYCLE_DURATION
	local clockTime = (cycleProgress * 24) % 24

	Lighting.ClockTime = clockTime

	if sky then
		sky.SkyboxOrientation = Vector3.new(0, (sky.SkyboxOrientation.Y + ROTATION_SPEED * deltaTime) % 360, 0)
	end

	local settings = getSettings(clockTime)
	Lighting.Ambient = settings.Ambient
	Lighting.Brightness = settings.Brightness
	Lighting.ColorShift_Bottom = settings.ColorShift_Bottom
	Lighting.ColorShift_Top = settings.ColorShift_Top
	Lighting.OutdoorAmbient = settings.OutdoorAmbient
end

function DayNightCycle.init()
	if not sky then
		sky = Instance.new("Sky")
		sky.Name = "Sky"
		sky.Parent = Lighting
	end

	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true

	RunService.Heartbeat:Connect(onHeartbeat)

	print("[DayNightCycle] Initialized with", CYCLE_DURATION, "second cycle")
end

function DayNightCycle.getTime(): number
	local cycleProgress = (workspace:GetServerTimeNow() % CYCLE_DURATION) / CYCLE_DURATION
	return (cycleProgress * 24) % 24
end

function DayNightCycle.getCycleDuration(): number
	return CYCLE_DURATION
end

return DayNightCycle
