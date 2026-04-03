--!nonstrict
-- Gacha Client for Aethelgard
-- UI for gacha rolls and inventory

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GachaClient = {}

local onVisibilityChanged = nil

function GachaClient.setOnVisibilityChanged(callback)
    onVisibilityChanged = callback
end

local gachaRemote = ReplicatedStorage:FindFirstChild("GachaRemote")
local gachaEvent = ReplicatedStorage:FindFirstChild("GachaEvent")

local screenGui = nil
local mainFrame = nil
local inventoryFrame = nil
local rollResultFrame = nil
local currentBanner = "standard_aura"

local function createMainUI()
    if screenGui then return end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GachaUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "GACHA"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = mainFrame
    closeButton.MouseButton1Click:Connect(function()
        GachaClient.hide()
    end)
    
    local currencyBar = Instance.new("Frame")
    currencyBar.Name = "CurrencyBar"
    currencyBar.Size = UDim2.new(1, -20, 0, 40)
    currencyBar.Position = UDim2.new(0, 10, 0.1, 5)
    currencyBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    currencyBar.Parent = mainFrame
    
    local gemsLabel = Instance.new("TextLabel")
    gemsLabel.Name = "GemsLabel"
    gemsLabel.Size = UDim2.new(0.5, 0, 1, 0)
    gemsLabel.Position = UDim2.new(0, 0, 0, 0)
    gemsLabel.BackgroundTransparency = 1
    gemsLabel.Text = "💎 0"
    gemsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    gemsLabel.TextSize = 18
    gemsLabel.Parent = currencyBar
    
    local shardsLabel = Instance.new("TextLabel")
    shardsLabel.Name = "ShardsLabel"
    shardsLabel.Size = UDim2.new(0.5, 0, 1, 0)
    shardsLabel.Position = UDim2.new(0.5, 0, 0, 0)
    shardsLabel.BackgroundTransparency = 1
    shardsLabel.Text = "🔷 0"
    shardsLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    shardsLabel.TextSize = 18
    shardsLabel.Parent = currencyBar

    local bannerTabsContainer = Instance.new("Frame")
    bannerTabsContainer.Name = "BannerTabsContainer"
    bannerTabsContainer.Size = UDim2.new(1, -20, 0, 32)
    bannerTabsContainer.Position = UDim2.new(0, 10, 0.18, 0)
    bannerTabsContainer.BackgroundTransparency = 1
    bannerTabsContainer.Parent = mainFrame

    local auraTabButton = Instance.new("TextButton")
    auraTabButton.Name = "AuraTabButton"
    auraTabButton.Size = UDim2.new(0.48, 0, 1, 0)
    auraTabButton.Position = UDim2.new(0, 0, 0, 0)
    auraTabButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    auraTabButton.Text = "Auras"
    auraTabButton.TextColor3 = Color3.new(1, 1, 1)
    auraTabButton.TextSize = 14
    auraTabButton.Font = Enum.Font.GothamBold
    auraTabButton.Parent = bannerTabsContainer

    local auraCorner = Instance.new("UICorner")
    auraCorner.CornerRadius = UDim.new(0, 6)
    auraCorner.Parent = auraTabButton

    local accessoryTabButton = Instance.new("TextButton")
    accessoryTabButton.Name = "AccessoryTabButton"
    accessoryTabButton.Size = UDim2.new(0.48, 0, 1, 0)
    accessoryTabButton.Position = UDim2.new(0.52, 0, 0, 0)
    accessoryTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    accessoryTabButton.Text = "Accessories"
    accessoryTabButton.TextColor3 = Color3.new(1, 1, 1)
    accessoryTabButton.TextSize = 14
    accessoryTabButton.Font = Enum.Font.GothamBold
    accessoryTabButton.Parent = bannerTabsContainer

    local accessoryCorner = Instance.new("UICorner")
    accessoryCorner.CornerRadius = UDim.new(0, 6)
    accessoryCorner.Parent = accessoryTabButton

    local function updateBannerTabs()
        if currentBanner == "standard_aura" then
            auraTabButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            accessoryTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        else
            auraTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            accessoryTabButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        end
    end

    auraTabButton.MouseButton1Click:Connect(function()
        currentBanner = "standard_aura"
        updateBannerTabs()
        local bannerTitle = mainFrame:FindFirstChild("BannerContainer"):FindFirstChild("BannerTitle")
        if bannerTitle then
            bannerTitle.Text = "Standard Aura Banner"
        end
    end)

    accessoryTabButton.MouseButton1Click:Connect(function()
        currentBanner = "standard_accessory"
        updateBannerTabs()
        local bannerTitle = mainFrame:FindFirstChild("BannerContainer"):FindFirstChild("BannerTitle")
        if bannerTitle then
            bannerTitle.Text = "Standard Accessory Banner"
        end
    end)

    local bannerContainer = Instance.new("Frame")
    bannerContainer.Name = "BannerContainer"
    bannerContainer.Size = UDim2.new(1, -20, 0.25, 0)
    bannerContainer.Position = UDim2.new(0, 10, 0.28, 5)
    bannerContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    bannerContainer.Parent = mainFrame
    
    local bannerTitle = Instance.new("TextLabel")
    bannerTitle.Name = "BannerTitle"
    bannerTitle.Size = UDim2.new(1, 0, 0.3, 0)
    bannerTitle.Position = UDim2.new(0, 0, 0, 0)
    bannerTitle.BackgroundTransparency = 1
    bannerTitle.Text = "Standard Aura Banner"
    bannerTitle.TextColor3 = Color3.new(1, 1, 1)
    bannerTitle.TextSize = 16
    bannerTitle.Parent = bannerContainer
    
    local pityLabel = Instance.new("TextLabel")
    pityLabel.Name = "PityLabel"
    pityLabel.Size = UDim2.new(1, 0, 0.3, 0)
    pityLabel.Position = UDim2.new(0, 0, 0.35, 0)
    pityLabel.BackgroundTransparency = 1
    pityLabel.Text = "Pity: 0/80"
    pityLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    pityLabel.TextSize = 14
    pityLabel.Parent = bannerContainer
    
    local pityBar = Instance.new("Frame")
    pityBar.Name = "PityBar"
    pityBar.Size = UDim2.new(0.8, 0, 0.2, 0)
    pityBar.Position = UDim2.new(0.1, 0, 0.7, 0)
    pityBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    pityBar.Parent = bannerContainer
    
    local pityFill = Instance.new("Frame")
    pityFill.Name = "PityFill"
    pityFill.Size = UDim2.new(0, 0, 1, 0)
    pityFill.Position = UDim2.new(0, 0, 0, 0)
    pityFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    pityFill.Parent = pityBar
    
    local buttonsContainer = Instance.new("Frame")
    buttonsContainer.Name = "ButtonsContainer"
    buttonsContainer.Size = UDim2.new(1, -20, 0.12, 0)
    buttonsContainer.Position = UDim2.new(0, 10, 0.56, 0)
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.Parent = mainFrame
    
    local singleRollButton = Instance.new("TextButton")
    singleRollButton.Name = "SingleRollButton"
    singleRollButton.Size = UDim2.new(0.48, 0, 1, 0)
    singleRollButton.Position = UDim2.new(0, 0, 0, 0)
    singleRollButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    singleRollButton.Text = "Roll x1 (100💎)"
    singleRollButton.TextColor3 = Color3.new(1, 1, 1)
    singleRollButton.TextSize = 14
    singleRollButton.Parent = buttonsContainer
    singleRollButton.MouseButton1Click:Connect(function()
        GachaClient.requestRoll(currentBanner, 1)
    end)
    
    local tenRollButton = Instance.new("TextButton")
    tenRollButton.Name = "TenRollButton"
    tenRollButton.Size = UDim2.new(0.48, 0, 1, 0)
    tenRollButton.Position = UDim2.new(0.52, 0, 0, 0)
    tenRollButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    tenRollButton.Text = "Roll x10 (900💎)"
    tenRollButton.TextColor3 = Color3.new(1, 1, 1)
    tenRollButton.TextSize = 14
    tenRollButton.Parent = buttonsContainer
    tenRollButton.MouseButton1Click:Connect(function()
        GachaClient.requestRoll(currentBanner, 10)
    end)
    
    local inventoryButton = Instance.new("TextButton")
    inventoryButton.Name = "InventoryButton"
    inventoryButton.Size = UDim2.new(1, -20, 0.08, 0)
    inventoryButton.Position = UDim2.new(0, 10, 0.7, 0)
    inventoryButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    inventoryButton.Text = "Inventory"
    inventoryButton.TextColor3 = Color3.new(1, 1, 1)
    inventoryButton.TextSize = 16
    inventoryButton.Parent = mainFrame
    inventoryButton.MouseButton1Click:Connect(function()
        GachaClient.showInventory()
    end)
    
    local shopButton = Instance.new("TextButton")
    shopButton.Name = "ShopButton"
    shopButton.Size = UDim2.new(1, -20, 0.08, 0)
    shopButton.Position = UDim2.new(0, 10, 0.8, 0)
    shopButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    shopButton.Text = "Buy Gems"
    shopButton.TextColor3 = Color3.new(1, 1, 1)
    shopButton.TextSize = 16
    shopButton.Parent = mainFrame
    shopButton.MouseButton1Click:Connect(function()
        GachaClient.showShop()
    end)
end

local function createRollResultUI()
    if rollResultFrame then return end
    
    rollResultFrame = Instance.new("Frame")
    rollResultFrame.Name = "RollResultFrame"
    rollResultFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    rollResultFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    rollResultFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    rollResultFrame.BorderSizePixel = 0
    rollResultFrame.Visible = false
    rollResultFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = rollResultFrame
    
    local resultsContainer = Instance.new("ScrollingFrame")
    resultsContainer.Name = "ResultsContainer"
    resultsContainer.Size = UDim2.new(1, -20, 0.85, 0)
    resultsContainer.Position = UDim2.new(0, 10, 0, 10)
    resultsContainer.BackgroundTransparency = 1
    resultsContainer.ScrollBarThickness = 6
    resultsContainer.Parent = rollResultFrame
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 100, 0, 120)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.Parent = resultsContainer
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.3, 0, 0, 40)
    closeButton.Position = UDim2.new(0.35, 0, 0.9, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = rollResultFrame
    closeButton.MouseButton1Click:Connect(function()
        rollResultFrame.Visible = false
    end)
end

local function createInventoryUI()
    if inventoryFrame then return end
    
    inventoryFrame = Instance.new("Frame")
    inventoryFrame.Name = "InventoryFrame"
    inventoryFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    inventoryFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    inventoryFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    inventoryFrame.BorderSizePixel = 0
    inventoryFrame.Visible = false
    inventoryFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = inventoryFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "INVENTORY"
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.TextSize = 24
    title.Parent = inventoryFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = inventoryFrame
    closeButton.MouseButton1Click:Connect(function()
        inventoryFrame.Visible = false
    end)
    
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -20, 0.08, 0)
    tabsContainer.Position = UDim2.new(0, 10, 0.1, 5)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = inventoryFrame
    
    local aurasTab = Instance.new("TextButton")
    aurasTab.Name = "AurasTab"
    aurasTab.Size = UDim2.new(0.48, 0, 1, 0)
    aurasTab.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    aurasTab.Text = "Auras"
    aurasTab.TextColor3 = Color3.new(1, 1, 1)
    aurasTab.Parent = tabsContainer
    
    local accessoriesTab = Instance.new("TextButton")
    accessoriesTab.Name = "AccessoriesTab"
    accessoriesTab.Size = UDim2.new(0.48, 0, 1, 0)
    accessoriesTab.Position = UDim2.new(0.52, 0, 0, 0)
    accessoriesTab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    accessoriesTab.Text = "Accessories"
    accessoriesTab.TextColor3 = Color3.new(1, 1, 1)
    accessoriesTab.Parent = tabsContainer
    
    local itemsContainer = Instance.new("ScrollingFrame")
    itemsContainer.Name = "ItemsContainer"
    itemsContainer.Size = UDim2.new(1, -20, 0.75, 0)
    itemsContainer.Position = UDim2.new(0, 10, 0.2, 0)
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.ScrollBarThickness = 6
    itemsContainer.Parent = inventoryFrame
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 80, 0, 100)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.Parent = itemsContainer
end

function GachaClient.show()
    createMainUI()
    mainFrame.Visible = true
    GachaClient.updateCurrencyDisplay()
    if onVisibilityChanged then
        onVisibilityChanged(true)
    end
end

function GachaClient.hide()
    if mainFrame then
        mainFrame.Visible = false
    end
    if onVisibilityChanged then
        onVisibilityChanged(false)
    end
end

function GachaClient.isVisible()
    return mainFrame and mainFrame.Visible or false
end

function GachaClient.toggle()
    if mainFrame and mainFrame.Visible then
        GachaClient.hide()
    else
        GachaClient.show()
    end
end

function GachaClient.updateCurrencyDisplay()
    if not mainFrame then return end
    
    local currencyBar = mainFrame:FindFirstChild("CurrencyBar")
    if not currencyBar then return end
    
    if gachaRemote then
        local currencyData = gachaRemote:InvokeServer("getCurrency")
        if currencyData then
            local gemsLabel = currencyBar:FindFirstChild("GemsLabel")
            local shardsLabel = currencyBar:FindFirstChild("ShardsLabel")
            if gemsLabel then
                gemsLabel.Text = "💎 " .. tostring(currencyData.gems)
            end
            if shardsLabel then
                shardsLabel.Text = "🔷 " .. tostring(currencyData.shards)
            end
        end
    end
end

function GachaClient.updatePityDisplay(pityRolls)
    if not mainFrame then return end
    
    local bannerContainer = mainFrame:FindFirstChild("BannerContainer")
    if not bannerContainer then return end
    
    local pityLabel = bannerContainer:FindFirstChild("PityLabel")
    if pityLabel then
        pityLabel.Text = "Pity: " .. tostring(pityRolls) .. "/80"
    end
    
    local pityFill = bannerContainer:FindFirstChild("PityBar"):FindFirstChild("PityFill")
    if pityFill then
        local fillPercent = math.clamp(pityRolls / 80, 0, 1)
        pityFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    end
end

function GachaClient.requestRoll(bannerId: string, count: number)
    if not gachaRemote then
        warn("[GachaClient] GachaRemote not found")
        return
    end
    
    local result, err = gachaRemote:InvokeServer("roll", { bannerId = bannerId, count = count })
    
    if err then
        warn("[GachaClient] Roll failed:", err)
        return
    end
    
    if result then
        GachaClient.showRollResults(result.results)
        GachaClient.updatePityDisplay(result.pityRolls)
        
        if result.currency then
            local currencyBar = mainFrame:FindFirstChild("CurrencyBar")
            if currencyBar then
                local gemsLabel = currencyBar:FindFirstChild("GemsLabel")
                local shardsLabel = currencyBar:FindFirstChild("ShardsLabel")
                if gemsLabel then
                    gemsLabel.Text = "💎 " .. tostring(result.currency.gems)
                end
                if shardsLabel then
                    shardsLabel.Text = "🔷 " .. tostring(result.currency.shards)
                end
            end
        end
    end
end

function GachaClient.showRollResults(results)
    createRollResultUI()
    
    local container = rollResultFrame:FindFirstChild("ResultsContainer")
    if not container then return end
    
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, result in ipairs(results) do
        local itemFrame = Instance.new("Frame")
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        itemFrame.Parent = container
        
        local itemData = result.item
        local rarityColors = {
            common = Color3.fromRGB(150, 150, 150),
            rare = Color3.fromRGB(0, 100, 255),
            epic = Color3.fromRGB(163, 53, 238),
            legendary = Color3.fromRGB(255, 170, 0),
        }
        
        local rarityBorder = Instance.new("UIStroke")
        rarityBorder.Color = rarityColors[itemData.rarity] or Color3.new(1, 1, 1)
        rarityBorder.Thickness = 3
        rarityBorder.Parent = itemFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0.6, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = itemData.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 12
        nameLabel.TextWrapped = true
        nameLabel.Parent = itemFrame
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0.2, 0)
        rarityLabel.Position = UDim2.new(0, 0, 0.85, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = string.upper(itemData.rarity)
        rarityLabel.TextColor3 = rarityColors[itemData.rarity]
        rarityLabel.TextSize = 10
        rarityLabel.Parent = itemFrame
        
        if not result.isNew then
            local dupeLabel = Instance.new("TextLabel")
            dupeLabel.Size = UDim2.new(1, 0, 0.15, 0)
            dupeLabel.Position = UDim2.new(0, 0, 0.45, 0)
            dupeLabel.BackgroundTransparency = 1
            dupeLabel.Text = "+" .. tostring(result.duplicateValue) .. "🔷"
            dupeLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
            dupeLabel.TextSize = 10
            dupeLabel.Parent = itemFrame
        else
            local newLabel = Instance.new("TextLabel")
            newLabel.Size = UDim2.new(1, 0, 0.15, 0)
            newLabel.Position = UDim2.new(0, 0, 0.45, 0)
            newLabel.BackgroundTransparency = 1
            newLabel.Text = "NEW!"
            newLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            newLabel.TextSize = 10
            newLabel.Parent = itemFrame
        end
    end
    
    rollResultFrame.Visible = true
end

function GachaClient.showInventory()
    createInventoryUI()
    
    if gachaRemote then
        local inventory = gachaRemote:InvokeServer("getInventory")
        if inventory then
            GachaClient.populateInventory(inventory)
        end
    end
    
    inventoryFrame.Visible = true
end

function GachaClient.populateInventory(inventory)
    local container = inventoryFrame:FindFirstChild("ItemsContainer")
    if not container then return end
    
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local rarityColors = {
        common = Color3.fromRGB(150, 150, 150),
        rare = Color3.fromRGB(0, 100, 255),
        epic = Color3.fromRGB(163, 53, 238),
        legendary = Color3.fromRGB(255, 170, 0),
    }
    
    local allItems = {}
    for _, item in ipairs(inventory.auras or {}) do
        table.insert(allItems, item)
    end
    for _, item in ipairs(inventory.accessories or {}) do
        table.insert(allItems, item)
    end
    
    for _, item in ipairs(allItems) do
        local itemFrame = Instance.new("Frame")
        itemFrame.BackgroundColor3 = item.equipped and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(40, 40, 50)
        itemFrame.Parent = container
        
        local rarityBorder = Instance.new("UIStroke")
        rarityBorder.Color = rarityColors[item.rarity] or Color3.new(1, 1, 1)
        rarityBorder.Thickness = item.equipped and 4 or 2
        rarityBorder.Parent = itemFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 11
        nameLabel.TextWrapped = true
        nameLabel.Parent = itemFrame
        
        if item.equipped then
            local equippedLabel = Instance.new("TextLabel")
            equippedLabel.Size = UDim2.new(1, 0, 0.2, 0)
            equippedLabel.Position = UDim2.new(0, 0, 0.85, 0)
            equippedLabel.BackgroundTransparency = 1
            equippedLabel.Text = "EQUIPPED"
            equippedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            equippedLabel.TextSize = 9
            equippedLabel.Parent = itemFrame
        end
        
        itemFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if gachaRemote then
                    gachaRemote:InvokeServer("equipItem", { itemId = item.id })
                end
            end
        end)
    end
end

function GachaClient.showShop()
    print("[GachaClient] Shop not implemented yet")
end

function GachaClient.init()
    createMainUI()
    createRollResultUI()
    createInventoryUI()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.G then
            GachaClient.toggle()
        end
    end)
    
    print("[GachaClient] Initialized - Press G or click Gacha button")
end

return GachaClient
