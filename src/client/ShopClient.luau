--!nonstrict
-- Shop Client for Aethelgard
-- React-based UI for purchasing gamepasses and gems
-- Redesigned to match GachaClient visual style

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

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
	BACKGROUND = Color3.fromRGB(15, 15, 25),
	BACKGROUND_GRADIENT = Color3.fromRGB(25, 20, 40),
	HEADER = Color3.fromRGB(35, 30, 55),
	TAB_INACTIVE = Color3.fromRGB(30, 25, 45),
	TAB_ACTIVE = Color3.fromRGB(255, 170, 0),
	BUTTON_DEFAULT = Color3.fromRGB(45, 40, 65),
	BUTTON_HOVER = Color3.fromRGB(65, 55, 90),
	BUTTON_PURCHASE = Color3.fromRGB(50, 120, 220),
	BUTTON_PURCHASE_HOVER = Color3.fromRGB(70, 150, 255),
	BUTTON_EQUIP = Color3.fromRGB(60, 160, 80),
	BUTTON_EQUIP_HOVER = Color3.fromRGB(80, 200, 100),
	BUTTON_UNEQUIP = Color3.fromRGB(180, 60, 60),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 190),
	GEMS = Color3.fromRGB(80, 200, 255),
	SHARDS = Color3.fromRGB(200, 140, 255),
	GOLD = Color3.fromRGB(255, 200, 50),
	CARD_BG = Color3.fromRGB(25, 22, 38),
	GLOW_GOLD = Color3.fromRGB(255, 180, 50),
	GLOW_PURPLE = Color3.fromRGB(180, 80, 255),
}

local CATEGORY_GRADIENTS = {
	gems = {Color3.fromRGB(30, 100, 255), Color3.fromRGB(100, 180, 255)},
	alerts = {Color3.fromRGB(200, 80, 255), Color3.fromRGB(255, 150, 255)},
	identity = {Color3.fromRGB(255, 150, 30), Color3.fromRGB(255, 200, 80)},
	tools = {Color3.fromRGB(80, 200, 100), Color3.fromRGB(150, 255, 150)},
}

local CATEGORIES = {"gems", "alerts", "identity", "tools"}

local CATEGORY_ICONS = {
	gems = "💎",
	alerts = "🔔",
	identity = "👑",
	tools = "⚔️",
}

local function CategoryButton(props)
	local label = props.label
	local isActive = props.isActive
	local onClick = props.onClick

	return e("TextButton", {
		Size = UDim2.new(1, 0, 0, 55),
		BackgroundColor3 = isActive and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(250, 250, 250),
		BorderSizePixel = 0,
		Text = "",
		[React.Event.Activated] = onClick,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),
		Stroke = e("UIStroke", {
			Color = isActive and Color3.fromRGB(255, 150, 50) or Color3.fromRGB(255, 200, 50),
			Thickness = 1,
		}),
		Label = e("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = label,
			TextColor3 = isActive and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(100, 100, 100),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
		}),
	})
end

local function GemPackCard(props)
	local pack = props.pack
	local onPurchase = props.onPurchase
	local isHovered, setIsHovered = React.useState(false)
	local gradientColors = CATEGORY_GRADIENTS.gems

	return e("Frame", {
		Size = UDim2.new(0, 140, 0, 170),
		BackgroundColor3 = COLORS.CARD_BG,
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, gradientColors[1]),
				ColorSequenceKeypoint.new(1, gradientColors[2]),
			}),
			Rotation = 45,
		}),
		Stroke = e("UIStroke", {
			Color = isHovered and COLORS.GLOW_GOLD or COLORS.GEMS,
			Thickness = isHovered and 3 or 2,
		}),

		GlowOuter = e("Frame", {
			Size = UDim2.new(1, 8, 1, 8),
			Position = UDim2.new(0, -4, 0, -4),
			BackgroundColor3 = COLORS.GEMS,
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			ZIndex = -1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),
		}),

		IconFrame = e("Frame", {
			Size = UDim2.new(1, -20, 0, 50),
			Position = UDim2.new(0, 10, 0, 15),
			BackgroundColor3 = Color3.fromRGB(40, 35, 60),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			AmountLabel = e("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "💎",
				TextColor3 = COLORS.GEMS,
				TextSize = 36,
				Font = Enum.Font.Gotham,
			}),
		}),

		AmountLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 70),
			BackgroundTransparency = 1,
			Text = tostring(pack.amount),
			TextColor3 = COLORS.TEXT,
			TextSize = 28,
			Font = Enum.Font.GothamBold,
		}),

		NameLabel = e("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 100),
			BackgroundTransparency = 1,
			Text = pack.name,
			TextColor3 = COLORS.TEXT_DIM,
			TextSize = 12,
			Font = Enum.Font.Gotham,
		}),

		BuyButton = e("TextButton", {
			Size = UDim2.new(1, -20, 0, 35),
			Position = UDim2.new(0, 10, 1, -45),
			BackgroundColor3 = isHovered and COLORS.BUTTON_PURCHASE_HOVER or COLORS.BUTTON_PURCHASE,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			TextColor3 = COLORS.TEXT,
			TextSize = 16,
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
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

local function ShopItemCard(props)
	local item = props.item
	local isOwned = props.isOwned
	local isEquipped = props.isEquipped
	local onBuy = props.onBuy
	local onEquip = props.onEquip
	local isHovered, setIsHovered = React.useState(false)
	local gradientColors = CATEGORY_GRADIENTS[item.category] or CATEGORY_GRADIENTS.tools

return e("Frame", {
 Size = UDim2.new(0, 140, 0, 170),
 BackgroundColor3 = COLORS.CARD_BG,
 BorderSizePixel = 0,
 }, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, gradientColors[1]),
				ColorSequenceKeypoint.new(1, gradientColors[2]),
			}),
			Rotation = 45,
		}),
		Stroke = e("UIStroke", {
			Color = isOwned and Color3.fromRGB(80, 255, 120) or (isHovered and COLORS.GLOW_GOLD or gradientColors[1]),
			Thickness = isOwned and 3 or 2,
		}),

		GlowOuter = isOwned and e("Frame", {
			Size = UDim2.new(1, 6, 1, 6),
			Position = UDim2.new(0, -3, 0, -3),
			BackgroundColor3 = Color3.fromRGB(80, 255, 120),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			ZIndex = -1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),
		}),

 CategoryBadge = e("Frame", {
 Size = UDim2.new(1, -12, 0, 18),
 Position = UDim2.new(0, 6, 0, 6),
 BackgroundColor3 = gradientColors[1],
 BackgroundTransparency = 0.2,
 BorderSizePixel = 0,
 }, {
 Corner = e("UICorner", {
 CornerRadius = UDim.new(0, 5),
 }),
 Label = e("TextLabel", {
 Size = UDim2.new(1, 0, 1, 0),
 BackgroundTransparency = 1,
 Text = (CATEGORY_ICONS[item.category] or "") .. " " .. string.upper(item.category or ""),
 TextColor3 = COLORS.TEXT,
 TextSize = 9,
 Font = Enum.Font.GothamBold,
 }),
 }),

 NameLabel = e("TextLabel", {
 Size = UDim2.new(1, -12, 0, 28),
 Position = UDim2.new(0, 6, 0, 26),
 BackgroundTransparency = 1,
 Text = item.name,
 TextColor3 = COLORS.TEXT,
 TextSize = 12,
 Font = Enum.Font.GothamBold,
 TextWrapped = true,
 }),

 DescLabel = e("TextLabel", {
 Size = UDim2.new(1, -12, 0, 40),
 Position = UDim2.new(0, 6, 0, 54),
 BackgroundTransparency = 1,
 Text = item.description or "",
 TextColor3 = COLORS.TEXT_DIM,
 TextSize = 9,
 Font = Enum.Font.Gotham,
 TextWrapped = true,
 }),

 PriceLabel = e("TextLabel", {
 Size = UDim2.new(1, -12, 0, 16),
 Position = UDim2.new(0, 6, 0, 96),
 BackgroundTransparency = 1,
 Text = isOwned and "✓ OWNED" or (tostring(item.price) .. " R$"),
 TextColor3 = isOwned and Color3.fromRGB(100, 255, 150) or COLORS.GOLD,
 TextSize = 11,
 Font = Enum.Font.GothamBold,
 }),

 EquippedBadge = isEquipped and e("Frame", {
 Size = UDim2.new(1, -12, 0, 18),
 Position = UDim2.new(0, 6, 1, -52),
 BackgroundColor3 = Color3.fromRGB(60, 200, 100),
 BackgroundTransparency = 0.2,
 BorderSizePixel = 0,
 }, {
 Corner = e("UICorner", {
 CornerRadius = UDim.new(0, 5),
 }),
 Label = e("TextLabel", {
 Size = UDim2.new(1, 0, 1, 0),
 BackgroundTransparency = 1,
 Text = "✓ EQUIPPED",
 TextColor3 = COLORS.TEXT,
 TextSize = 9,
 Font = Enum.Font.GothamBold,
 }),
 }),

 ActionButton = e("TextButton", {
 Size = UDim2.new(1, -12, 0, 28),
 Position = UDim2.new(0, 6, 1, -36),
			BackgroundColor3 = isEquipped and COLORS.BUTTON_UNEQUIP or (isOwned and COLORS.BUTTON_EQUIP or COLORS.BUTTON_PURCHASE),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			TextColor3 = COLORS.TEXT,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			Text = isOwned and (isEquipped and "UNEQUIP" or "EQUIP") or "BUY",
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
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

local function GemsTab(props)
	local onPurchasePack = props.onPurchasePack

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 150, 0, 180),
			CellPadding = UDim2.new(0, 40, 0, 40),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
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
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = COLORS.GOLD,
		CanvasSize = UDim2.new(0, 0, 0, math.ceil(#ShopData.GEM_PACKS / 3) * 200),
	}, children)
end

local function CategoryTab(props)
	local category = props.category
	local ownedItems = props.ownedItems
	local equippedItems = props.equippedItems
	local onBuy = props.onBuy
	local onEquip = props.onEquip

	local items = ShopData.getItemsByCategory(category)

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 150, 0, 180),
			CellPadding = UDim2.new(0, 40, 0, 40),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
		}),
	}

	for i, item in ipairs(items) do
		local isOwned = table.find(ownedItems, item.id) ~= nil
		local isEquipped = table.find(equippedItems, item.id) ~= nil
		children["Item_" .. i] = e(ShopItemCard, {
			item = item,
			isOwned = isOwned,
			isEquipped = isEquipped,
			onBuy = onBuy,
			onEquip = onEquip,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = COLORS.GOLD,
 CanvasSize = UDim2.new(0, 0, 0, math.ceil(#items / 3) * 200),
	}, children)
end

local function ShopApp(props)
	local isVisible = props.isVisible
	local activeTab, setActiveTab = React.useState(1)
	local currency, setCurrency = React.useState({ gems = 0, shards = 0 })
	local ownedItems, setOwnedItems = React.useState({})
	local equippedItems, setEquippedItems = React.useState({})
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
			if playerData and playerData.equipped then
				setEquippedItems(playerData.equipped)
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
			local isEquipped = table.find(equippedItems, item.id) ~= nil
			if isEquipped then
				shopRemote:InvokeServer("unequipItem", { itemId = item.id })
			else
				shopRemote:InvokeServer("equipItem", { itemId = item.id })
			end
			setUpdateTrigger(function(x)
				return x + 1
			end)
		end
	end

	local blurEffect = Lighting:FindFirstChild("ShopBlur")
	if not blurEffect then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "ShopBlur"
		blurEffect.Size = 0
		blurEffect.Parent = Lighting
	end

	React.useEffect(function()
		if isVisible then
			blurEffect.Size = 24
		else
			blurEffect.Size = 0
		end
	end, {isVisible})

	if not isVisible then
		return nil
	end

 local categoryButtonsChildren = {
 Layout = e("UIListLayout", {
 FillDirection = Enum.FillDirection.Vertical,
 SortOrder = Enum.SortOrder.LayoutOrder,
 Padding = UDim.new(0, 12),
 HorizontalAlignment = Enum.HorizontalAlignment.Center,
 VerticalAlignment = Enum.VerticalAlignment.Top,
 }),
 }

	for i, categoryId in ipairs(CATEGORIES) do
		categoryButtonsChildren["Cat_" .. i] = e(CategoryButton, {
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
	MainContainer = e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
 BorderSizePixel = 0,
 }, {
 CloseButton = e("TextButton", {
				Size = UDim2.new(0, 50, 0, 50),
				Position = UDim2.new(1, -70, 0, 20),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = Color3.fromRGB(100, 100, 100),
				TextSize = 24,
				Font = Enum.Font.GothamBold,
				Text = "✕",
				ZIndex = 100,
				[React.Event.Activated] = props.onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}),
			}),

			CurrencyTop = e("Frame", {
				Size = UDim2.new(0, 200, 0, 50),
				Position = UDim2.new(1, -290, 0, 20),
				BackgroundTransparency = 1,
			}, {
				GemsDisplay = e("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(80, 80, 80),
					BackgroundTransparency = 0.3,
					BorderSizePixel = 0,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 20),
					}),
					Icon = e("TextLabel", {
						Size = UDim2.new(0, 40, 1, 0),
						BackgroundTransparency = 1,
						Text = "💎",
						TextSize = 28,
						Font = Enum.Font.Gotham,
					}),
					Amount = e("TextLabel", {
						Size = UDim2.new(1, -50, 1, 0),
						Position = UDim2.new(0, 40, 0, 0),
						BackgroundTransparency = 1,
						Text = tostring(currency.gems),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 24,
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),
			}),

 CategoryColumn = e("Frame", {
 Size = UDim2.new(0, 220, 0.75, 0),
 Position = UDim2.new(0, 20, 0.125, 0),
 BackgroundColor3 = Color3.fromRGB(250, 250, 250),
 BorderSizePixel = 0,
 ZIndex = 10,
 }, {
 Corner = e("UICorner", {
 CornerRadius = UDim.new(0, 20),
 }),
 Stroke = e("UIStroke", {
 Color = Color3.fromRGB(255, 200, 50),
 Thickness = 1,
 }),
 Padding = e("UIPadding", {
 PaddingTop = UDim.new(0, 20),
 }),
 ShopTitle = e("TextLabel", {
 Size = UDim2.new(1, -20, 0, 40),
 Position = UDim2.new(0, 10, 0, 10),
 BackgroundTransparency = 1,
 Text = "SHOP",
 TextColor3 = COLORS.GOLD,
 TextSize = 28,
 Font = Enum.Font.GothamBold,
 }),
 Content = e("Frame", {
 Size = UDim2.new(1, -20, 1, -70),
 Position = UDim2.new(0, 10, 0, 60),
 BackgroundTransparency = 1,
 }, categoryButtonsChildren),
 }),

		ContentPanel = e("Frame", {
			Size = UDim2.new(1, -280, 0.75, 0),
			Position = UDim2.new(0, 250, 0.125, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5,
		}, {
		ContentContainer = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
		}, {
					GemsTab = activeTab == 1 and e(GemsTab, {
						onPurchasePack = onPurchasePack,
					}),
					AlertsTab = activeTab == 2 and e(CategoryTab, {
						category = "alerts",
						ownedItems = ownedItems,
						equippedItems = equippedItems,
						onBuy = onBuyItem,
						onEquip = onEquipItem,
					}),
					IdentityTab = activeTab == 3 and e(CategoryTab, {
						category = "identity",
						ownedItems = ownedItems,
						equippedItems = equippedItems,
						onBuy = onBuyItem,
						onEquip = onEquipItem,
					}),
					ToolsTab = activeTab == 4 and e(CategoryTab, {
						category = "tools",
						ownedItems = ownedItems,
						equippedItems = equippedItems,
						onBuy = onBuyItem,
						onEquip = onEquipItem,
					}),
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
			shopRemote:InvokeServer("processGamepassPurchase", { gamepassId = gamepassId })
			ShopClient.show()
		end
	end)

	_G.ShopClient = ShopClient

	print("[ShopClient] Initialized")
end

return ShopClient
