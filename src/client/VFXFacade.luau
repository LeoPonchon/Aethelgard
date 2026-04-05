--!nonstrict
-- VFXFacade: Renders particles in Workspace (outside ViewportFrame) and syncs position with camera
-- Since ParticleEmitters don't render in ViewportFrames, we use a "facade" model in Workspace

local VFXFacade = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local activeFacades = {}
local facadeIdCounter = 0

local function createFacadeModel(auraId)
	local aurasFolder = ReplicatedStorage:FindFirstChild("Auras")
	if not aurasFolder then 
		warn("[VFXFacade] Auras folder not found in ReplicatedStorage")
		return nil 
	end

	local auraVFX = aurasFolder:FindFirstChild(auraId)
	if not auraVFX then 
		warn("[VFXFacade] Aura not found:", auraId, "Available:", aurasFolder:GetChildren())
		return nil 
	end

	print("[VFXFacade] Creating facade for aura:", auraId, "Type:", auraVFX.ClassName)

	local facadePart = Instance.new("Part")
	facadePart.Name = "VFXFacade_" .. auraId
	facadePart.Anchored = true
	facadePart.CanCollide = false
	facadePart.CanQuery = false
	facadePart.CanTouch = false
	facadePart.Transparency = 1
	facadePart.Size = Vector3.new(1, 1, 1)

	local auraClone = auraVFX:Clone()
	auraClone.Parent = facadePart

	print("[VFXFacade] Aura cloned, children:", facadePart:GetChildren())

	local model = Instance.new("Model")
	model.Name = "VFXFacadeModel_" .. auraId
	facadePart.Parent = model

	return model, facadePart
end

function VFXFacade.create(auraId, offsetPosition)
	print("[VFXFacade] create() called with auraId:", auraId)
	facadeIdCounter = facadeIdCounter + 1
	local facadeId = "facade_" .. facadeIdCounter

	local model, facadePart = createFacadeModel(auraId)
	if not model then
		warn("[VFXFacade] Could not create facade for aura:", auraId)
		return nil
	end

	model.Parent = workspace
	print("[VFXFacade] Model parented to workspace at:", facadePart.CFrame)

	local facadeData = {
		id = facadeId,
		model = model,
		part = facadePart,
		auraId = auraId,
		offset = offsetPosition or Vector3.new(0, 0, -5),
		connection = nil,
	}

	local function updatePosition()
		if not facadePart or not facadePart.Parent then return end
		local cameraCFrame = camera.CFrame
		local targetCFrame = cameraCFrame * CFrame.new(facadeData.offset)
		facadePart.CFrame = targetCFrame
	end

	updatePosition()

	facadeData.connection = RunService.RenderStepped:Connect(updatePosition)

	activeFacades[facadeId] = facadeData
	print("[VFXFacade] Facade created successfully, ID:", facadeId)

	return facadeId
end

function VFXFacade.destroy(facadeId)
	local facadeData = activeFacades[facadeId]
	if not facadeData then return end

	if facadeData.connection then
		facadeData.connection:Disconnect()
	end

	if facadeData.model and facadeData.model.Parent then
		facadeData.model:Destroy()
	end

	activeFacades[facadeId] = nil
end

function VFXFacade.destroyAll()
	for facadeId, _ in pairs(activeFacades) do
		VFXFacade.destroy(facadeId)
	end
end

function VFXFacade.setOffset(facadeId, newOffset)
	local facadeData = activeFacades[facadeId]
	if not facadeData then return end
	facadeData.offset = newOffset
end

function VFXFacade.setRelativeCFrame(facadeId, relativeCFrame)
	local facadeData = activeFacades[facadeId]
	if not facadeData then return end

	if facadeData.connection then
		facadeData.connection:Disconnect()
	end

	facadeData.connection = RunService.RenderStepped:Connect(function()
		if not facadeData.part or not facadeData.part.Parent then return end
		local cameraCFrame = camera.CFrame
		facadeData.part.CFrame = cameraCFrame * relativeCFrame
	end)
end

function VFXFacade.getActiveCount()
	local count = 0
	for _ in pairs(activeFacades) do
		count = count + 1
	end
	return count
end

return VFXFacade
