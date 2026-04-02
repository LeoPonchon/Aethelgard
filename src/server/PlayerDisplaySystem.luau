--!nonstrict
-- Player Display System for Aethelgard
-- Shows player info (DisplayName, Team, Class, Guild Rank) above their character
-- This is the ONLY UI element - the billboard above players
-- All data comes from the ActionBasedProgressionSystem

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ActionBasedProgressionSystem = require(ReplicatedStorage.Shared:WaitForChild("ActionBasedProgressionSystem"))

local PlayerDisplaySystem = {}

-- Configuration
local DISPLAY_CONFIG = {
    enabled = true,
    updateInterval = 2, -- seconds
    offset = Vector3.new(0, 3.5, 0), -- Height above player head
    maxDistance = 25, -- Max distance to see billboard
}

-- Team colors by category (from ActionBasedProgressionSystem)
local TEAM_COLORS = {
    -- Monarchie
    ["King"] = Color3.fromRGB(255, 215, 0),
    ["Queen"] = Color3.fromRGB(255, 182, 193),
    ["Princes"] = Color3.fromRGB(70, 130, 180),
    ["Princesses"] = Color3.fromRGB(255, 105, 180),
    -- Noblesse
    ["Dukes"] = Color3.fromRGB(128, 0, 128),
    ["Counts"] = Color3.fromRGB(148, 0, 211),
    ["Minor Houses"] = Color3.fromRGB(186, 85, 211),
    -- Démons
    ["Demon King"] = Color3.fromRGB(139, 0, 0),
    ["Demon Queen"] = Color3.fromRGB(178, 34, 34),
    ["Demon Generals"] = Color3.fromRGB(220, 20, 60),
    ["Demon Servants"] = Color3.fromRGB(255, 69, 0),
    -- Académie
    ["Academy Externals"] = Color3.fromRGB(192, 192, 192),
    ["Academy Professors"] = Color3.fromRGB(255, 255, 255),
    ["Academy Year 1"] = Color3.fromRGB(173, 216, 230),
    ["Academy Year 2"] = Color3.fromRGB(135, 206, 235),
    ["Academy Year 3"] = Color3.fromRGB(0, 191, 255),
    -- Héros & Saints
    ["Hero"] = Color3.fromRGB(255, 215, 0),
    ["Saint"] = Color3.fromRGB(255, 255, 224),
    -- Autres groupes
    ["Elves Faction"] = Color3.fromRGB(34, 139, 34),
    ["Event Teams"] = Color3.fromRGB(75, 0, 130),
    ["Free Lineages"] = Color3.fromRGB(128, 128, 128),
    ["Commoners"] = Color3.fromRGB(100, 149, 237),
}

-- Class emojis for display
local CLASS_EMOJIS = {
    ["Guerrier"] = "⚔️",
    ["Mage"] = "🔮",
    ["Voleur"] = "🗡️",
    ["Archer"] = "🏹",
    ["Prêtre"] = "✨",
    ["Paladin"] = "⚜️",
    ["Nécromancien"] = "💀",
    ["Barde"] = "🎵",
    ["Druide"] = "🌿",
    ["Chevalier"] = "🛡️",
    ["Invocateur"] = "👁️",
    ["Moine"] = "🥋",
}

-- Create BillboardGui for a player
local function createPlayerDisplay(player: Player)
    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerDisplay"
    billboard.Adornee = head
    billboard.Size = UDim2.new(4, 0, 1.8, 0)
    billboard.StudsOffset = DISPLAY_CONFIG.offset
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.MaxDistance = DISPLAY_CONFIG.maxDistance

    -- Main background frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 25, 55)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Parent = billboard

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.1, 0)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(120, 80, 150)
    uiStroke.Thickness = 1.5
    uiStroke.Parent = mainFrame

    -- Player name label (top)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.28, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0.05)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Text = player.DisplayName
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = mainFrame

    -- Faction label (second line)
    local factionLabel = Instance.new("TextLabel")
    factionLabel.Name = "FactionLabel"
    factionLabel.BackgroundTransparency = 1
    factionLabel.Size = UDim2.new(1, 0, 0.22, 0)
    factionLabel.Position = UDim2.new(0, 0, 0.33, 0)
    factionLabel.Font = Enum.Font.Gotham
    factionLabel.TextSize = 13
    factionLabel.TextColor3 = Color3.fromRGB(180, 140, 220)
    factionLabel.Text = "Roturiers"
    factionLabel.TextStrokeTransparency = 0.5
    factionLabel.Parent = mainFrame

    -- Class label with emoji (third line)
    local classLabel = Instance.new("TextLabel")
    classLabel.Name = "ClassLabel"
    classLabel.BackgroundTransparency = 1
    classLabel.Size = UDim2.new(1, 0, 0.22, 0)
    classLabel.Position = UDim2.new(0, 0, 0.55, 0)
    classLabel.Font = Enum.Font.Gotham
    classLabel.TextSize = 12
    classLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
    classLabel.Text = "❓ Sans Classe"
    classLabel.TextStrokeTransparency = 0.5
    classLabel.Parent = mainFrame

    -- Guild rank label (fourth line)
    local guildLabel = Instance.new("TextLabel")
    guildLabel.Name = "GuildLabel"
    guildLabel.BackgroundTransparency = 1
    guildLabel.Size = UDim2.new(1, 0, 0.18, 0)
    guildLabel.Position = UDim2.new(0, 0, 0.77, 0)
    guildLabel.Font = Enum.Font.Gotham
    guildLabel.TextSize = 10
    guildLabel.TextColor3 = Color3.fromRGB(200, 180, 100)
    guildLabel.Text = "Recrue"
    guildLabel.TextStrokeTransparency = 0.5
    guildLabel.Parent = mainFrame

    -- Progression indicator (level badge in top-right corner)
    local progressBadge = Instance.new("Frame")
    progressBadge.Name = "ProgressBadge"
    progressBadge.BackgroundColor3 = Color3.fromRGB(100, 60, 120)
    progressBadge.Size = UDim2.new(0, 28, 0, 20)
    progressBadge.Position = UDim2.new(1, -32, 0, 4)
    progressBadge.AnchorPoint = Vector2.new(0, 0)
    progressBadge.BorderSizePixel = 0
    progressBadge.ZIndex = 10
    progressBadge.Parent = mainFrame
   
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 6)
    badgeCorner.Parent = progressBadge
   
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Color3.fromRGB(180, 140, 220)
    badgeStroke.Thickness = 1.5
    badgeStroke.Parent = progressBadge
   
    local badgeLabel = Instance.new("TextLabel")
    badgeLabel.Name = "BadgeLabel"
    badgeLabel.BackgroundTransparency = 1
    badgeLabel.Size = UDim2.new(1, 0, 1, 0)
    badgeLabel.Font = Enum.Font.GothamBold
    badgeLabel.TextSize = 11
    badgeLabel.TextColor3 = Color3.fromRGB(255, 230, 255)
    badgeLabel.Text = "1"
    badgeLabel.TextStrokeTransparency = 0.3
    badgeLabel.ZIndex = 11
    badgeLabel.Parent = progressBadge

    billboard.Parent = character

    return billboard
end

-- Update display for a player based on progression data
local function updatePlayerDisplay(player: Player)
    local character = player.Character
    if not character then return end

    local display = character:FindFirstChild("PlayerDisplay")
    if not display then
        display = createPlayerDisplay(player)
        if not display then return end
    end

    local mainFrame = display:FindFirstChild("MainFrame")
    if not mainFrame then return end

    local nameLabel = mainFrame:FindFirstChild("NameLabel")
    local factionLabel = mainFrame:FindFirstChild("FactionLabel")
    local classLabel = mainFrame:FindFirstChild("ClassLabel")
    local guildLabel = mainFrame:FindFirstChild("GuildLabel")
    local progressBadge = mainFrame:FindFirstChild("ProgressBadge")

    -- Update name
    if nameLabel then
        nameLabel.Text = player.DisplayName
    end

    -- Get progression data
    local displayInfo = ActionBasedProgressionSystem.getDisplayInfo(player.UserId)

    -- Update team
    if factionLabel and displayInfo then
        local teamText = displayInfo.teamEmoji .. " " .. displayInfo.teamName
        factionLabel.Text = teamText

        -- Color based on team
        local teamColor = TEAM_COLORS[displayInfo.team] or Color3.fromRGB(180, 140, 220)
        factionLabel.TextColor3 = teamColor
    end

    -- Update class
    if classLabel and displayInfo then
        classLabel.Text = displayInfo.classEmoji .. " " .. displayInfo.className
    end

    -- Update guild rank
    if guildLabel and displayInfo then
        guildLabel.Text = "Guild: " .. displayInfo.guildRank
    end

    -- Update progress badge (shows total actions / 100)
    if progressBadge and displayInfo then
        local badgeLabel = progressBadge:FindFirstChild("BadgeLabel")
        if badgeLabel then
            local level = math.floor(displayInfo.totalActions / 100) + 1
            badgeLabel.Text = tostring(level)
        end
    end
end

-- Handle player character added
local function onCharacterAdded(player: Player)
    task.wait(0.5) -- Wait for character to fully load
    if DISPLAY_CONFIG.enabled then
        updatePlayerDisplay(player)
    end
end

-- Initialize the system
function PlayerDisplaySystem.init()
    print("[PlayerDisplaySystem] Initializing...")

    -- Connect events
    Players.PlayerAdded:Connect(function(player)
        -- Initialize progression for new player
        ActionBasedProgressionSystem.getProgression(player.UserId)
        
        player.CharacterAdded:Connect(function()
            onCharacterAdded(player)
        end)

        -- If character already exists
        if player.Character then
            task.spawn(function()
                task.wait(0.5)
                onCharacterAdded(player)
            end)
        end
    end)

    -- Update all players periodically
    task.spawn(function()
        while DISPLAY_CONFIG.enabled do
            task.wait(DISPLAY_CONFIG.updateInterval)
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    pcall(updatePlayerDisplay, player)
                end
            end
        end
    end)

    print("[PlayerDisplaySystem] Initialized")
end

-- Force update a specific player's display
function PlayerDisplaySystem.updatePlayer(player: Player)
    updatePlayerDisplay(player)
end

-- Set player data (called when progression changes)
function PlayerDisplaySystem.onProgressionChanged(player: Player)
    task.spawn(function()
        task.wait(0.1)
        updatePlayerDisplay(player)
    end)
end

-- Enable/disable system
function PlayerDisplaySystem.setEnabled(enabled: boolean)
    DISPLAY_CONFIG.enabled = enabled
end

-- Get display info for a player (for client-side use)
function PlayerDisplaySystem.getDisplayInfo(playerId: number)
    return ActionBasedProgressionSystem.getDisplayInfo(playerId)
end

return PlayerDisplaySystem
