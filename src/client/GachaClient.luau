--!nonstrict
-- Gacha Client for Aethelgard
-- React-based UI for gacha rolls and inventory

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GachaData = require(sharedFolder:WaitForChild("GachaData"))

local gachaRemote = ReplicatedStorage:FindFirstChild("GachaRemote")

local COLORS = {
	BACKGROUND = Color3.fromRGB(30, 30, 40),
	HEADER = Color3.fromRGB(50, 50, 70),
	TAB_INACTIVE = Color3.fromRGB(40, 40, 55),
	TAB_ACTIVE = Color3.fromRGB(255, 170, 0),
	BUTTON_DEFAULT = Color3.fromRGB(60, 60, 80),
	BUTTON_HOVER = Color3.fromRGB(80, 80, 120),
	BUTTON_ROLL_SINGLE = Color3.fromRGB(70, 130, 200),
	BUTTON_ROLL_TEN = Color3.fromRGB(200, 100, 50),
	BUTTON_EQUIP = Color3.fromRGB(80, 140, 80),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 180),
	GEMS = Color3.fromRGB(100, 200, 255),
	SHARDS = Color3.fromRGB(200, 150, 255),
	GOLD = Color3.fromRGB(255, 215, 0),
}

local RARITY_COLORS = {
	common = Color3.fromRGB(150, 150, 150),
	rare = Color3.fromRGB(0, 100, 255),
	epic = Color3.fromRGB(163, 53, 238),
	legendary = Color3.fromRGB(255, 170, 0),
}

local function RollResultCard(props)
	local result = props.result
	local rarityColor = RARITY_COLORS[result.item.rarity] or Color3.new(1, 1, 1)

	return e("Frame", {
		Size = UDim2.new(0, 100, 0, 120),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Stroke = e("UIStroke", {
			Color = rarityColor,
			Thickness = 3,
		}),

		StatusLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.15, 0),
			Position = UDim2.new(0, 0, 0.45, 0),
			BackgroundTransparency = 1,
			Text = result.isNew and "NEW!" or ("+" .. tostring(result.duplicateValue) .. "🔷"),
			TextColor3 = result.isNew and Color3.fromRGB(100, 255, 100) or COLORS.SHARDS,
			TextSize = 10,
			Font = Enum.Font.GothamBold,
		}),

		ItemName = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.3, 0),
			Position = UDim2.new(0, 0, 0.6, 0),
			BackgroundTransparency = 1,
			Text = result.item.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
		}),

		RarityLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.2, 0),
			Position = UDim2.new(0, 0, 0.85, 0),
			BackgroundTransparency = 1,
			Text = string.upper(result.item.rarity),
			TextColor3 = rarityColor,
			TextSize = 10,
			Font = Enum.Font.GothamBold,
		}),
	})
end

local function InventoryItemCard(props)
	local item = props.item
	local onEquip = props.onEquip
	local isHovered, setIsHovered = React.useState(false)

	local rarityColor = RARITY_COLORS[item.rarity] or Color3.new(1, 1, 1)

	return e("TextButton", {
		Size = UDim2.new(0, 80, 0, 100),
		BackgroundColor3 = item.equipped and Color3.fromRGB(60, 80, 60) or (isHovered and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50)),
		BorderSizePixel = 0,
		Text = "",
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
		end,
		[React.Event.Activated] = function()
			onEquip(item)
		end,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Stroke = e("UIStroke", {
			Color = rarityColor,
			Thickness = item.equipped and 4 or 2,
		}),

		ItemName = e("TextLabel", {
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.4, 0),
			BackgroundTransparency = 1,
			Text = item.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
		}),

		EquippedLabel = item.equipped and e("TextLabel", {
			Size = UDim2.new(1, 0, 0.2, 0),
			Position = UDim2.new(0, 0, 0.85, 0),
			BackgroundTransparency = 1,
			Text = "EQUIPPED",
			TextColor3 = Color3.fromRGB(100, 255, 100),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
		}),
	})
end

local function RollResultsModal(props)
	local results = props.results
	local onClose = props.onClose

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 110, 0, 130),
			CellPadding = UDim2.new(0, 10, 0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	for i, result in ipairs(results) do
		children["Result_" .. i] = e(RollResultCard, {
			result = result,
		})
	end

	return e("ScreenGui", {
		Name = "RollResultsUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Overlay = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}),

		ModalFrame = e("Frame", {
			Size = UDim2.new(0.8, 0, 0.8, 0),
			Position = UDim2.new(0.1, 0, 0.1, 0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 30),
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0.1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "ROLL RESULTS",
				TextColor3 = COLORS.GOLD,
				TextSize = 28,
				Font = Enum.Font.GothamBold,
			}),

			ResultsContainer = e("ScrollingFrame", {
				Size = UDim2.new(1, -20, 0.8, 0),
				Position = UDim2.new(0, 10, 0.1, 10),
				BackgroundTransparency = 1,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 0, math.ceil(#results / 5) * 140),
			}, children),

			CloseButton = e("TextButton", {
				Size = UDim2.new(0.3, 0, 0, 40),
				Position = UDim2.new(0.35, 0, 0.92, 0),
				BackgroundColor3 = COLORS.BUTTON_ROLL_SINGLE,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 16,
				Font = Enum.Font.GothamBold,
				Text = "Close",
				[React.Event.Activated] = onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
		}),
	})
end

local function InventoryModal(props)
	local inventory = props.inventory
	local onClose = props.onClose
	local onEquipItem = props.onEquipItem

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 90, 0, 110),
			CellPadding = UDim2.new(0, 10, 0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	local allItems = {}
	for _, item in ipairs(inventory.auras or {}) do
		table.insert(allItems, item)
	end
	for _, item in ipairs(inventory.accessories or {}) do
		table.insert(allItems, item)
	end

	for i, item in ipairs(allItems) do
		children["Item_" .. i] = e(InventoryItemCard, {
			item = item,
			onEquip = onEquipItem,
		})
	end

	return e("ScreenGui", {
		Name = "InventoryUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Overlay = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}),

		ModalFrame = e("Frame", {
			Size = UDim2.new(0.6, 0, 0.7, 0),
			Position = UDim2.new(0.2, 0, 0.15, 0),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0.1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "INVENTORY",
				TextColor3 = COLORS.SHARDS,
				TextSize = 24,
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
				[React.Event.Activated] = onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),

			ItemsContainer = e("ScrollingFrame", {
				Size = UDim2.new(1, -20, 0.85, 0),
				Position = UDim2.new(0, 10, 0.1, 10),
				BackgroundTransparency = 1,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 0, math.ceil(#allItems / 4) * 120),
			}, children),
		}),
	})
end

local function GachaApp(props)
	local isVisible = props.isVisible
	local currentBanner, setCurrentBanner = React.useState("standard_aura")
	local currency, setCurrency = React.useState({ gems = 0, shards = 0 })
	local pityRolls, setPityRolls = React.useState(0)
	local inventory, setInventory = React.useState({ auras = {}, accessories = {} })
	local showResults, setShowResults = React.useState(false)
	local rollResults, setRollResults = React.useState({})
	local showInventory, setShowInventory = React.useState(false)
	local updateTrigger, setUpdateTrigger = React.useState(0)

	React.useEffect(function()
		if gachaRemote then
			local currencyData = gachaRemote:InvokeServer("getCurrency")
			if currencyData then
				setCurrency(currencyData)
			end

			local pityData = gachaRemote:InvokeServer("getPity")
			if pityData then
				setPityRolls(pityData)
			end

			local invData = gachaRemote:InvokeServer("getInventory")
			if invData then
				setInventory(invData)
			end
		end
	end, {isVisible, updateTrigger})

	local doRoll = function(count)
		if not gachaRemote then return end

		local result, err = gachaRemote:InvokeServer("roll", {
			bannerId = currentBanner,
			count = count,
		})

		if err then
			warn("[GachaClient] Roll failed:", err)
			return
		end

		if result then
			setRollResults(result.results)
			setPityRolls(result.pityRolls)
			if result.currency then
				setCurrency(result.currency)
			end
			setShowResults(true)
		end
	end

    local onEquipItem = function(item)
        if not gachaRemote then return end
        gachaRemote:InvokeServer("equipItem", { itemId = item.id })
        setUpdateTrigger(function(x)
            return x + 1
        end)
        print("[GachaClient] onEquipItem called for:", item.id, item.name, item.rarity)
        local cb = props.onItemEquipped
        print("[GachaClient] onItemEquipped prop exists:", cb ~= nil)
        if cb then
            print("[GachaClient] Calling onItemEquipped callback")
            cb(item)
        end
    end

	if not isVisible then
		return nil
	end

	local pityPercent = math.clamp(pityRolls / 80, 0, 1)

	local mainUI = e("ScreenGui", {
		Name = "GachaUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		MainFrame = e("Frame", {
			Size = UDim2.new(0.4, 0, 0.6, 0),
			Position = UDim2.new(0.3, 0, 0.2, 0),
			BackgroundColor3 = COLORS.BACKGROUND,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0.1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "GACHA",
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
				Size = UDim2.new(1, -20, 0.08, 0),
				Position = UDim2.new(0, 10, 0.1, 5),
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
					TextSize = 18,
					Font = Enum.Font.GothamBold,
				}),
				ShardsLabel = e("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "🔷 " .. tostring(currency.shards),
					TextColor3 = COLORS.SHARDS,
					TextSize = 18,
					Font = Enum.Font.GothamBold,
				}),
			}),

			BannerTabs = e("Frame", {
				Size = UDim2.new(1, -20, 0.08, 0),
				Position = UDim2.new(0, 10, 0.18, 0),
				BackgroundTransparency = 1,
			}, {
				Layout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
				}),
				AuraTab = e("TextButton", {
					Size = UDim2.new(0.48, 0, 1, 0),
					BackgroundColor3 = currentBanner == "standard_aura" and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					TextColor3 = COLORS.TEXT,
					TextSize = 14,
					Font = Enum.Font.GothamBold,
					Text = "Auras",
					[React.Event.Activated] = function()
						setCurrentBanner("standard_aura")
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
				AccessoryTab = e("TextButton", {
					Size = UDim2.new(0.48, 0, 1, 0),
					Position = UDim2.new(0.52, 0, 0, 0),
					BackgroundColor3 = currentBanner == "standard_accessory" and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					TextColor3 = COLORS.TEXT,
					TextSize = 14,
					Font = Enum.Font.GothamBold,
					Text = "Accessories",
					[React.Event.Activated] = function()
						setCurrentBanner("standard_accessory")
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
			}),

			BannerInfo = e("Frame", {
				Size = UDim2.new(1, -20, 0.25, 0),
				Position = UDim2.new(0, 10, 0.28, 5),
				BackgroundColor3 = Color3.fromRGB(50, 50, 60),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				BannerTitle = e("TextLabel", {
					Size = UDim2.new(1, 0, 0.4, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = currentBanner == "standard_aura" and "Standard Aura Banner" or "Standard Accessory Banner",
					TextColor3 = COLORS.TEXT,
					TextSize = 16,
					Font = Enum.Font.GothamBold,
				}),
				PityLabel = e("TextLabel", {
					Size = UDim2.new(1, 0, 0.3, 0),
					Position = UDim2.new(0, 0, 0.4, 0),
					BackgroundTransparency = 1,
					Text = "Pity: " .. tostring(pityRolls) .. "/80",
					TextColor3 = COLORS.GOLD,
					TextSize = 14,
					Font = Enum.Font.Gotham,
				}),
				PityBarBg = e("Frame", {
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.75, 0),
					BackgroundColor3 = Color3.fromRGB(60, 60, 70),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 4),
					}),
					PityFill = e("Frame", {
						Size = UDim2.new(pityPercent, 0, 1, 0),
						BackgroundColor3 = COLORS.TAB_ACTIVE,
						BackgroundTransparency = 0,
						BorderSizePixel = 0,
					}, {
						Corner = e("UICorner", {
							CornerRadius = UDim.new(0, 4),
						}),
					}),
				}),
			}),

			RollButtons = e("Frame", {
				Size = UDim2.new(1, -20, 0.12, 0),
				Position = UDim2.new(0, 10, 0.56, 0),
				BackgroundTransparency = 1,
			}, {
				Layout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
				}),
				SingleRoll = e("TextButton", {
					Size = UDim2.new(0.48, 0, 1, 0),
					BackgroundColor3 = COLORS.BUTTON_ROLL_SINGLE,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					TextColor3 = COLORS.TEXT,
					TextSize = 14,
					Font = Enum.Font.GothamBold,
					Text = "Roll x1 (100💎)",
					[React.Event.Activated] = function()
						doRoll(1)
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
				TenRoll = e("TextButton", {
					Size = UDim2.new(0.48, 0, 1, 0),
					Position = UDim2.new(0.52, 0, 0, 0),
					BackgroundColor3 = COLORS.BUTTON_ROLL_TEN,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					TextColor3 = COLORS.TEXT,
					TextSize = 14,
					Font = Enum.Font.GothamBold,
					Text = "Roll x10 (900💎)",
					[React.Event.Activated] = function()
						doRoll(10)
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
			}),

			InventoryButton = e("TextButton", {
				Size = UDim2.new(1, -20, 0.08, 0),
				Position = UDim2.new(0, 10, 0.7, 0),
				BackgroundColor3 = COLORS.BUTTON_DEFAULT,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 16,
				Font = Enum.Font.GothamBold,
				Text = "Inventory",
				[React.Event.Activated] = function()
					setShowInventory(true)
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),

			ShopButton = e("TextButton", {
				Size = UDim2.new(1, -20, 0.08, 0),
				Position = UDim2.new(0, 10, 0.8, 0),
				BackgroundColor3 = Color3.fromRGB(100, 50, 150),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 16,
				Font = Enum.Font.GothamBold,
				Text = "Buy Gems",
				[React.Event.Activated] = props.onOpenShop,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),
		}),
	})

	if showResults then
		return e("ScreenGui", {
			Name = "GachaResultsRoot",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
		}, {
			ResultsModal = e(RollResultsModal, {
				results = rollResults,
				onClose = function()
					setShowResults(false)
				end,
			}),
		})
	elseif showInventory then
		return e("ScreenGui", {
			Name = "GachaInventoryRoot",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
		}, {
			InventoryModal = e(InventoryModal, {
				inventory = inventory,
				onClose = function()
					setShowInventory(false)
				end,
				onEquipItem = onEquipItem,
			}),
		})
	else
		return mainUI
	end
end

local GachaClient = {}

local root = nil
local isVisibleState = false
local onVisibilityChanged = nil
local itemEquippedCallback = nil

function GachaClient.setOnVisibilityChanged(callback)
    onVisibilityChanged = callback
end

function GachaClient.setOnItemEquipped(callback)
    itemEquippedCallback = callback
end

function GachaClient.show()
	isVisibleState = true
	if root then
root:render(React.createElement(GachaApp, {
        isVisible = isVisibleState,
        onClose = function()
            GachaClient.hide()
        end,
        onOpenShop = function()
            GachaClient.hide()
            local ShopClient = _G.ShopClient
            if ShopClient then
                ShopClient.show()
            end
        end,
        onItemEquipped = itemEquippedCallback,
    }))
	end
	if onVisibilityChanged then
		onVisibilityChanged(true)
	end
end

function GachaClient.hide()
	isVisibleState = false
	if root then
root:render(React.createElement(GachaApp, {
        isVisible = isVisibleState,
        onClose = function() end,
        onOpenShop = function() end,
        onItemEquipped = itemEquippedCallback,
    }))
	end
	if onVisibilityChanged then
		onVisibilityChanged(false)
	end
end

function GachaClient.isVisible()
	return isVisibleState
end

function GachaClient.toggle()
	if isVisibleState then
		GachaClient.hide()
	else
		GachaClient.show()
	end
end

function GachaClient.updateCurrencyDisplay()
	GachaClient.show()
end

function GachaClient.init()
	local targetContainer = Instance.new("ScreenGui")
	targetContainer.Name = "GachaUIRoot"
	targetContainer.ResetOnSpawn = false
	targetContainer.IgnoreGuiInset = true
	targetContainer.Parent = playerGui

	root = ReactRoblox.createRoot(targetContainer)
	root:render(React.createElement(GachaApp, {
		isVisible = false,
		onClose = function() end,
		onOpenShop = function() end,
	}))

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.G then
			GachaClient.toggle()
		end
	end)

	_G.GachaClient = GachaClient

	print("[GachaClient] Initialized")
end

return GachaClient
