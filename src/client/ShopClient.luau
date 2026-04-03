--!nonstrict
-- Shop Client for Aethelgard
-- React-based UI for purchasing gamepasses and gems

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ShopData = require(sharedFolder:WaitForChild("ShopData"))

local shopRemote = ReplicatedStorage:FindFirstChild("ShopRemote")
local gachaRemote = ReplicatedStorage:FindFirstChild("GachaRemote")

local COLORS = {
	BACKGROUND = Color3.fromRGB(25, 25, 35),
	TAB_INACTIVE = Color3.fromRGB(40, 40, 55),
	TAB_ACTIVE = Color3.fromRGB(255, 170, 0),
	BUTTON_PURCHASE = Color3.fromRGB(70, 130, 200),
	BUTTON_EQUIP = Color3.fromRGB(80, 140, 80),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 180),
	GEMS = Color3.fromRGB(100, 200, 255),
	SHARDS = Color3.fromRGB(200, 150, 255),
	GOLD = Color3.fromRGB(255, 215, 0),
}

local CATEGORIES = {"gems", "alerts", "identity", "emotes", "tools"}

local CATEGORY_ICONS = {
	gems = "💎",
	alerts = "🔔",
	identity = "👑",
	emotes = "🎭",
	tools = "⚔️",
}

local function TabButton(props)
	local label = props.label
	local isActive = props.isActive
	local onClick = props.onClick

	return e("TextButton", {
		Size = UDim2.new(1 / #CATEGORIES, -4, 1, 0),
		BackgroundColor3 = isActive and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		TextColor3 = COLORS.TEXT,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		Text = label,
		[React.Event.Activated] = onClick,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})
end

local function GemPackCard(props)
	local pack = props.pack
	local onPurchase = props.onPurchase
	local isHovered, setIsHovered = React.useState(false)

	return e("Frame", {
		Size = UDim2.new(0, 150, 0, 140),
		BackgroundColor3 = isHovered and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(40, 40, 60),
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		AmountLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.3, 0),
			Position = UDim2.new(0, 0, 0.1, 0),
			BackgroundTransparency = 1,
			Text = "💎 " .. tostring(pack.amount),
			TextColor3 = COLORS.GEMS,
			TextSize = 24,
			Font = Enum.Font.GothamBold,
		}),

		NameLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.2, 0),
			Position = UDim2.new(0, 0, 0.4, 0),
			BackgroundTransparency = 1,
			Text = pack.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 14,
			Font = Enum.Font.Gotham,
		}),

		BuyButton = e("TextButton", {
			Size = UDim2.new(1, -20, 0.25, 0),
			Position = UDim2.new(0, 10, 0.65, 0),
			BackgroundColor3 = COLORS.BUTTON_PURCHASE,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			TextColor3 = COLORS.TEXT,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			Text = tostring(pack.robux) .. " R$",
			[React.Event.MouseEnter] = function()
				setIsHovered(true)
			end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
			end,
			[React.Event.Activated] = function()
				onPurchase(pack)
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
		}),
	})
end

local function ShopItemCard(props)
	local item = props.item
	local isOwned = props.isOwned
	local onBuy = props.onBuy
	local onEquip = props.onEquip
	local isHovered, setIsHovered = React.useState(false)

	return e("Frame", {
		Size = UDim2.new(0, 150, 0, 180),
		BackgroundColor3 = isOwned and Color3.fromRGB(40, 80, 40) or (isHovered and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50)),
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		NameLabel = e("TextLabel", {
			Size = UDim2.new(1, -10, 0.25, 0),
			Position = UDim2.new(0, 5, 0.05, 0),
			BackgroundTransparency = 1,
			Text = item.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
		}),

		DescLabel = e("TextLabel", {
			Size = UDim2.new(1, -10, 0.35, 0),
			Position = UDim2.new(0, 5, 0.3, 0),
			BackgroundTransparency = 1,
			Text = item.description or "",
			TextColor3 = COLORS.TEXT_DIM,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
		}),

		PriceLabel = e("TextLabel", {
			Size = UDim2.new(1, -10, 0.15, 0),
			Position = UDim2.new(0, 5, 0.65, 0),
			BackgroundTransparency = 1,
			Text = isOwned and "OWNED" or (tostring(item.price) .. " R$"),
			TextColor3 = isOwned and Color3.fromRGB(100, 255, 100) or COLORS.GOLD,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
		}),

		ActionButton = e("TextButton", {
			Size = UDim2.new(1, -10, 0.15, 0),
			Position = UDim2.new(0, 5, 0.82, 0),
			BackgroundColor3 = isOwned and COLORS.BUTTON_EQUIP or COLORS.BUTTON_PURCHASE,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			TextColor3 = COLORS.TEXT,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			Text = isOwned and "EQUIP" or "BUY",
			[React.Event.MouseEnter] = function()
				setIsHovered(true)
			end,
			[React.Event.MouseLeave] = function()
				setIsHovered(false)
			end,
			[React.Event.Activated] = function()
				if isOwned then
					onEquip(item)
				else
					onBuy(item)
				end
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		}),
	})
end

local function GemsTab(props)
	local onPurchasePack = props.onPurchasePack

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 160, 0, 150),
			CellPadding = UDim2.new(0, 10, 0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	for i, pack in ipairs(ShopData.GEM_PACKS) do
		children["Pack_" .. i] = e(GemPackCard, {
			pack = pack,
			onPurchase = onPurchasePack,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
		CanvasSize = UDim2.new(0, 0, 0, 400),
	}, children)
end

local function CategoryTab(props)
	local category = props.category
	local ownedItems = props.ownedItems
	local onBuy = props.onBuy
	local onEquip = props.onEquip

	local items = ShopData.getItemsByCategory(category)

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 160, 0, 190),
			CellPadding = UDim2.new(0, 10, 0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	for i, item in ipairs(items) do
		local isOwned = table.find(ownedItems, item.id) ~= nil
		children["Item_" .. i] = e(ShopItemCard, {
			item = item,
			isOwned = isOwned,
			onBuy = onBuy,
			onEquip = onEquip,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100),
		CanvasSize = UDim2.new(0, 0, 0, math.ceil(#items / 3) * 200),
	}, children)
end

local function ShopApp(props)
	local isVisible = props.isVisible
	local activeTab, setActiveTab = React.useState(1)
	local currency, setCurrency = React.useState({ gems = 0, shards = 0 })
	local ownedItems, setOwnedItems = React.useState({})
	local updateTrigger, setUpdateTrigger = React.useState(0)

	React.useEffect(function()
		if gachaRemote then
			local currencyData = gachaRemote:InvokeServer("getCurrency")
			if currencyData then
				setCurrency(currencyData)
			end
		end

		if shopRemote then
			local playerData = shopRemote:InvokeServer("getOwnedItems")
			if playerData and playerData.owned then
				setOwnedItems(playerData.owned)
			end
		end
	end, {isVisible, updateTrigger})

	React.useEffect(function()
		local currencyNotification = ReplicatedStorage:FindFirstChild("CurrencyNotification")
		if currencyNotification then
			local connection = currencyNotification.OnClientEvent:Connect(function(data)
				if data.type == "purchase" then
					setUpdateTrigger(function(x)
						return x + 1
					end)
				end
			end)
			return function()
				connection:Disconnect()
			end
		end
		return nil
	end, {})

	local onPurchasePack = function(pack)
		if pack.productId and pack.productId > 0 then
			MarketplaceService:PromptProductPurchase(player, pack.productId)
		else
			print("[ShopClient] Product ID not set for pack:", pack.name)
		end
	end

	local onBuyItem = function(item)
		if item.gamepassId and item.gamepassId > 0 then
			MarketplaceService:PromptGamePassPurchase(player, item.gamepassId)
		else
			print("[ShopClient] No gamepass for item:", item.name)
		end
	end

	local onEquipItem = function(item)
		if shopRemote then
			shopRemote:InvokeServer("equipItem", { itemId = item.id })
			setUpdateTrigger(function(x)
				return x + 1
			end)
		end
	end

	if not isVisible then
		return nil
	end

	local tabChildren = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}
	for i, categoryId in ipairs(CATEGORIES) do
		tabChildren["Tab_" .. i] = e(TabButton, {
			label = (CATEGORY_ICONS[categoryId] or "") .. " " .. categoryId:upper(),
			isActive = activeTab == i,
			onClick = function()
				setActiveTab(i)
			end,
		})
	end

	return e("ScreenGui", {
		Name = "ShopUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		MainFrame = e("Frame", {
			Size = UDim2.new(0.5, 0, 0.7, 0),
			Position = UDim2.new(0.25, 0, 0.15, 0),
			BackgroundColor3 = COLORS.BACKGROUND,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0.08, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "SHOP",
				TextColor3 = COLORS.GOLD,
				TextSize = 28,
				Font = Enum.Font.GothamBold,
			}),

			CloseButton = e("TextButton", {
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(1, -35, 0, 5),
				BackgroundColor3 = Color3.fromRGB(200, 50, 50),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 18,
				Font = Enum.Font.GothamBold,
				Text = "X",
				[React.Event.Activated] = props.onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),

			CurrencyBar = e("Frame", {
				Size = UDim2.new(1, -20, 0.06, 0),
				Position = UDim2.new(0, 10, 0.08, 5),
				BackgroundColor3 = Color3.fromRGB(40, 40, 50),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				GemsLabel = e("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "💎 " .. tostring(currency.gems),
					TextColor3 = COLORS.GEMS,
					TextSize = 16,
					Font = Enum.Font.GothamBold,
				}),
				ShardsLabel = e("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "🔷 " .. tostring(currency.shards),
					TextColor3 = COLORS.SHARDS,
					TextSize = 16,
					Font = Enum.Font.GothamBold,
				}),
			}),

			TabContainer = e("Frame", {
				Size = UDim2.new(1, -20, 0.08, 0),
				Position = UDim2.new(0, 10, 0.15, 5),
				BackgroundTransparency = 1,
			}, tabChildren),

			ContentContainer = e("Frame", {
				Size = UDim2.new(1, -20, 0.67, 0),
				Position = UDim2.new(0, 10, 0.25, 10),
				BackgroundTransparency = 1,
			}, {
				GemsTab = activeTab == 1 and e(GemsTab, {
					onPurchasePack = onPurchasePack,
				}),
				AlertsTab = activeTab == 2 and e(CategoryTab, {
					category = "alerts",
					ownedItems = ownedItems,
					onBuy = onBuyItem,
					onEquip = onEquipItem,
				}),
				IdentityTab = activeTab == 3 and e(CategoryTab, {
					category = "identity",
					ownedItems = ownedItems,
					onBuy = onBuyItem,
					onEquip = onEquipItem,
				}),
				EmotesTab = activeTab == 4 and e(CategoryTab, {
					category = "emotes",
					ownedItems = ownedItems,
					onBuy = onBuyItem,
					onEquip = onEquipItem,
				}),
				ToolsTab = activeTab == 5 and e(CategoryTab, {
					category = "tools",
					ownedItems = ownedItems,
					onBuy = onBuyItem,
					onEquip = onEquipItem,
				}),
			}),
		}),
	})
end

local ShopClient = {}

local root = nil
local isVisibleState = false
local onVisibilityChanged = nil

function ShopClient.setOnVisibilityChanged(callback)
	onVisibilityChanged = callback
end

function ShopClient.show()
	isVisibleState = true
	if root then
		root:render(React.createElement(ShopApp, {
			isVisible = isVisibleState,
			onClose = function()
				ShopClient.hide()
			end,
		}))
	end
	if onVisibilityChanged then
		onVisibilityChanged(true)
	end
end

function ShopClient.hide()
	isVisibleState = false
	if root then
		root:render(React.createElement(ShopApp, {
			isVisible = isVisibleState,
			onClose = function() end,
		}))
	end
	if onVisibilityChanged then
		onVisibilityChanged(false)
	end
end

function ShopClient.isVisible()
	return isVisibleState
end

function ShopClient.toggle()
	if isVisibleState then
		ShopClient.hide()
	else
		ShopClient.show()
	end
end

function ShopClient.init()
	local targetContainer = Instance.new("ScreenGui")
	targetContainer.Name = "ShopUIRoot"
	targetContainer.ResetOnSpawn = false
	targetContainer.IgnoreGuiInset = true
	targetContainer.Parent = playerGui

	root = ReactRoblox.createRoot(targetContainer)
	root:render(React.createElement(ShopApp, {
		isVisible = false,
		onClose = function() end,
	}))

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchasingPlayer, gamepassId, wasPurchased)
		if purchasingPlayer == player and wasPurchased then
			task.wait(1)
			ShopClient.show()
		end
	end)

	_G.ShopClient = ShopClient

	print("[ShopClient] Initialized")
end

return ShopClient
