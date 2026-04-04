--!nonstrict
-- Aura System Client for Aethelgard
-- Handles aura visual effects and activation with P key

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil

local AURA_CONFIG = {
    glow = {
        golden_aura = Color3.fromRGB(255, 215, 0),
        shadow_aura = Color3.fromRGB(60, 20, 80),
        flame_aura = Color3.fromRGB(255, 100, 0),
        ice_aura = Color3.fromRGB(150, 220, 255),
        nature_aura = Color3.fromRGB(100, 200, 100),
        water_aura = Color3.fromRGB(50, 150, 255),
        wind_aura = Color3.fromRGB(200, 220, 240),
        dust_aura = Color3.fromRGB(180, 160, 140),
    },
    particleCount = {
        legendary = 50,
        epic = 35,
        rare = 25,
        common = 15,
    }
}

local AuraSystem = {}

local auraActive = false
local currentAuraId = nil
local auraEffects = {}
local auraConnection = nil

local function getCharacter()
    if not character then
        character = player.Character
        if character then
            humanoidRootPart = character:WaitForChild("HumanoidRootPart", 2)
        end
    end
    return character, humanoidRootPart
end

local function clearAuraEffects()
    for _, effect in ipairs(auraEffects) do
        if effect then
            effect:Destroy()
        end
    end
    auraEffects = {}
    
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection = nil
    end
end

local function createGlowEffect(color)
    local char, hrp = getCharacter()
    if not hrp then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Name = "AuraAttachment"
    attachment.Position = Vector3.new(0, 0, 0)
    attachment.Parent = hrp
    table.insert(auraEffects, attachment)
    
    local glow = Instance.new("PointLight")
    glow.Name = "AuraGlow"
    glow.Color = color
    glow.Brightness = 2
    glow.Range = 10
    glow.Parent = attachment
    table.insert(auraEffects, glow)
    
    return attachment
end

local function createParticleEffect(color, rarity)
    local char, hrp = getCharacter()
    if not hrp then return end
    
    local particleCount = AURA_CONFIG.particleCount[rarity] or 15
    
    for i = 1, particleCount do
        local particle = Instance.new("Part")
        particle.Name = "AuraParticle_" .. i
        particle.Shape = Enum.PartType.Ball
        particle.Size = Vector3.new(0.2, 0.2, 0.2)
        particle.Color = color
        particle.Material = Enum.Material.Neon
        particle.Anchored = true
        particle.CanCollide = false
        particle.Transparency = 0.3
        particle.Parent = hrp
        table.insert(auraEffects, particle)
        
        local offset = Vector3.new(
            (math.random() - 0.5) * 4,
            (math.random() - 0.5) * 6,
            (math.random() - 0.5) * 4
        )
        
        local angle = math.random() * math.pi * 2
        local radius = 2 + math.random() * 2
        local height = math.random() * 4
        
        particle:SetAttribute("Angle", angle)
        particle:SetAttribute("Radius", radius)
        particle:SetAttribute("Height", height)
        particle:SetAttribute("Speed", 1 + math.random() * 2)
        particle:SetAttribute("YOffset", math.random() * math.pi * 2)
    end
    
    auraConnection = RunService.Heartbeat:Connect(function(dt)
        if not auraActive then return end
        
        local _, currentHrp = getCharacter()
        if not currentHrp then return end
        
        local time = tick()
        
        for _, effect in ipairs(auraEffects) do
            if effect:IsA("Part") and effect.Name:find("AuraParticle") then
                local angle = effect:GetAttribute("Angle") + effect:GetAttribute("Speed") * dt
                effect:SetAttribute("Angle", angle)
                
                local radius = effect:GetAttribute("Radius")
                local height = effect:GetAttribute("Height")
                local yOffset = effect:GetAttribute("YOffset")
                
                local x = math.cos(angle) * radius
                local z = math.sin(angle) * radius
                local y = height + math.sin(time * 2 + yOffset) * 0.5
                
                effect.CFrame = currentHrp.CFrame * CFrame.new(x, y - 2, z)
            end
        end
    end)
end

local function createAuraEffect(auraId, rarity)
    clearAuraEffects()
    
    local color = AURA_CONFIG.glow[auraId] or Color3.fromRGB(255, 255, 255)
    
    createGlowEffect(color)
    createParticleEffect(color, rarity or "common")
end

function AuraSystem.setEquippedAura(auraId, rarity)
    print("[AuraSystem] setEquippedAura called:", auraId, rarity)
    currentAuraId = auraId

    if auraActive then
        if auraId then
            createAuraEffect(auraId, rarity)
        else
            clearAuraEffects()
        end
    end
end

function AuraSystem.toggleAura()
    auraActive = not auraActive
    print("[AuraSystem] toggleAura called, now active:", auraActive, "currentAuraId:", currentAuraId)

    if auraActive and currentAuraId then
        local GachaData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GachaData"))
        local auraData = GachaData.getItemById(currentAuraId)
        createAuraEffect(currentAuraId, auraData and auraData.rarity or "common")
    else
        clearAuraEffects()
    end

    return auraActive
end

function AuraSystem.isActive()
    return auraActive
end

function AuraSystem.getEquippedAura()
    return currentAuraId
end

function AuraSystem.init(gachaRemote)
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 2)
        
        if auraActive and currentAuraId then
            local GachaData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GachaData"))
            local auraData = GachaData.getItemById(currentAuraId)
            task.delay(0.5, function()
                createAuraEffect(currentAuraId, auraData and auraData.rarity or "common")
            end)
        end
    end)
    
    if player.Character then
        character = player.Character
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.P then
            AuraSystem.toggleAura()
        end
    end)
    
    if gachaRemote then
        task.spawn(function()
            local inventory = gachaRemote:InvokeServer("getInventory")
            if inventory and inventory.auras then
                for _, aura in ipairs(inventory.auras) do
                    if aura.equipped then
                        currentAuraId = aura.id
                        break
                    end
                end
            end
        end)
    end
    
    print("[AuraSystem] Initialized")
end

return AuraSystem
