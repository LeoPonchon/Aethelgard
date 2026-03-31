local Lighting = game:GetService("Lighting")

-- Day/Night cycle configuration
local CYCLE_DURATION = 600 -- Total cycle duration in seconds (10 minutes)
local TRANSITION_SPEED = 0.01 -- How fast we interpolate between states

-- Night settings
local nightSettings = {
	Ambient = Color3.new(169/255, 49/255, 255/255),
	Brightness = 0,
	ColorShift_Bottom = Color3.new(0, 0, 0),
	ColorShift_Top = Color3.new(213/255, 206/255, 3/255),
	EnvironmentDiffuseScale = 1,
	EnvironmentSpecularScale = 1,
	GlobalShadows = true,
	OutdoorAmbient = Color3.new(0, 0, 0),
	PrioritizeLightingQuality = true,
}

-- Day settings
local daySettings = {
	Ambient = Color3.new(240/255, 167/255, 93/255),
	Brightness = 3,
	ColorShift_Bottom = Color3.new(0, 0, 0),
	ColorShift_Top = Color3.new(213/255, 199/255, 0/255),
	EnvironmentDiffuseScale = 1,
	EnvironmentSpecularScale = 1,
	GlobalShadows = true,
	OutdoorAmbient = Color3.new(251/255, 255/255, 0),
	PrioritizeLightingQuality = true,
}

-- Current target settings (starts at night)
local currentSettings = {}
local isDay = false

-- Initialize with night settings
for key, value in pairs(nightSettings) do
	Lighting[key] = value
	currentSettings[key] = value
end

local function lerpColor3(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function lerpNumber(a, b, t)
	return a + (b - a) * t
end

local function updateLighting(targetSettings, deltaTime)
	for key, targetValue in pairs(targetSettings) do
		local currentValue = currentSettings[key]
		
		if typeof(currentValue) == "Color3" then
			local newColor = lerpColor3(currentValue, targetValue, TRANSITION_SPEED)
			Lighting[key] = newColor
			currentSettings[key] = newColor
		elseif typeof(currentValue) == "number" then
			local newNumber = lerpNumber(currentValue, targetValue, TRANSITION_SPEED)
			Lighting[key] = newNumber
			currentSettings[key] = newNumber
		elseif typeof(currentValue) == "boolean" then
			Lighting[key] = targetValue
			currentSettings[key] = targetValue
		elseif typeof(currentValue) == "string" then
			Lighting[key] = targetValue
			currentSettings[key] = targetValue
		end
	end
end

local function getTimeOfDay(progress)
	-- progress is 0 to 1
	-- 0-0.5 is night, 0.5-1 is day (reversed from before)
	return progress < 0.5
end

local startTime = os.date("os.time")

-- Run the day/night cycle
task.spawn(function()
	while true do
		local elapsed = os.date("os.time") - startTime
		local cycleProgress = (elapsed % CYCLE_DURATION) / CYCLE_DURATION
		local shouldBeDay = getTimeOfDay(cycleProgress)
		
		-- If we switched phase, update target
		if shouldBeDay ~= isDay then
			isDay = shouldBeDay
			print(isDay and "☀️ Changing to Day" or "🌙 Changing to Night")
		end
		
		-- Apply lighting settings based on current phase
		local targetSettings = isDay and daySettings or nightSettings
		updateLighting(targetSettings, 0.016)
		
		task.wait(0.016) -- ~60 FPS
	end
end)

print("Day/Night cycle started!")