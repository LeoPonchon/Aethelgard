--!nonstrict
-- Gacha Client for Aethelgard
-- React-based UI for gacha rolls and inventory

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GachaData = require(sharedFolder:WaitForChild("GachaData"))

local gachaRemote = ReplicatedStorage:FindFirstChild("GachaRemote")

local COLORS = {
	BACKGROUND = Color3.fromRGB(15, 15, 25),
	BACKGROUND_GRADIENT = Color3.fromRGB(25, 20, 40),
	HEADER = Color3.fromRGB(35, 30, 55),
	TAB_INACTIVE = Color3.fromRGB(30, 25, 45),
	TAB_ACTIVE = Color3.fromRGB(255, 170, 0),
	BUTTON_DEFAULT = Color3.fromRGB(45, 40, 65),
	BUTTON_HOVER = Color3.fromRGB(65, 55, 90),
	BUTTON_ROLL_SINGLE = Color3.fromRGB(50, 120, 220),
	BUTTON_ROLL_SINGLE_HOVER = Color3.fromRGB(70, 150, 255),
	BUTTON_ROLL_TEN = Color3.fromRGB(220, 80, 40),
	BUTTON_ROLL_TEN_HOVER = Color3.fromRGB(255, 110, 60),
	BUTTON_EQUIP = Color3.fromRGB(60, 160, 80),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 190),
	GEMS = Color3.fromRGB(80, 200, 255),
	SHARDS = Color3.fromRGB(200, 140, 255),
	GOLD = Color3.fromRGB(255, 200, 50),
	CARD_BG = Color3.fromRGB(25, 22, 38),
	GLOW_LEGENDARY = Color3.fromRGB(255, 180, 50),
	GLOW_EPIC = Color3.fromRGB(180, 80, 255),
	GLOW_RARE = Color3.fromRGB(50, 130, 255),
}

local RARITY_COLORS = {
	common = Color3.fromRGB(160, 160, 170),
	rare = Color3.fromRGB(70, 140, 255),
	epic = Color3.fromRGB(200, 80, 255),
	legendary = Color3.fromRGB(255, 180, 50),
}

local RARITY_GRADIENTS = {
	legendary = {Color3.fromRGB(255, 150, 30), Color3.fromRGB(255, 200, 80)},
	epic = {Color3.fromRGB(150, 50, 255), Color3.fromRGB(220, 120, 255)},
	rare = {Color3.fromRGB(30, 100, 255), Color3.fromRGB(100, 180, 255)},
	common = {Color3.fromRGB(120, 120, 130), Color3.fromRGB(180, 180, 190)},
}

local function RollResultCard(props)
	local result = props.result
	local rarityColor = RARITY_COLORS[result.item.rarity] or Color3.new(1, 1, 1)
	local isLegendary = result.item.rarity == "legendary"
	local isEpic = result.item.rarity == "epic"
	local gradientColors = RARITY_GRADIENTS[result.item.rarity] or RARITY_GRADIENTS.common

	return e("Frame", {
		Size = UDim2.new(0, 120, 0, 150),
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
			Color = rarityColor,
			Thickness = isLegendary and 4 or 2,
		}),

		GlowOuter = (isLegendary or isEpic) and e("Frame", {
			Size = UDim2.new(1, 8, 1, 8),
			Position = UDim2.new(0, -4, 0, -4),
			BackgroundColor3 = isLegendary and COLORS.GLOW_LEGENDARY or COLORS.GLOW_EPIC,
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			ZIndex = -1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),
		}),

		RarityBadge = e("Frame", {
			Size = UDim2.new(1, -16, 0, 24),
			Position = UDim2.new(0, 8, 0, 8),
			BackgroundColor3 = rarityColor,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			Label = e("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = string.upper(result.item.rarity),
				TextColor3 = COLORS.TEXT,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
			}),
		}),

		ItemName = e("TextLabel", {
			Size = UDim2.new(1, -16, 0, 40),
			Position = UDim2.new(0, 8, 0, 40),
			BackgroundTransparency = 1,
			Text = result.item.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),

		StatusLabel = e("TextLabel", {
			Size = UDim2.new(1, -16, 0, 20),
			Position = UDim2.new(0, 8, 0, 85),
			BackgroundTransparency = 1,
			Text = result.isNew and "★ NEW!" or ("+" .. tostring(result.duplicateValue) .. " 🔷"),
			TextColor3 = result.isNew and Color3.fromRGB(100, 255, 150) or COLORS.SHARDS,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
		}),

		DescLabel = e("TextLabel", {
			Size = UDim2.new(1, -16, 0, 30),
			Position = UDim2.new(0, 8, 0, 110),
			BackgroundTransparency = 1,
			Text = result.item.description or "",
			TextColor3 = COLORS.TEXT_DIM,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
	})
end

local function InventoryItemCard(props)
	local item = props.item
	local onEquip = props.onEquip
	local isHovered, setIsHovered = React.useState(false)

	local rarityColor = RARITY_COLORS[item.rarity] or Color3.new(1, 1, 1)
	local gradientColors = RARITY_GRADIENTS[item.rarity] or RARITY_GRADIENTS.common
	local isLegendary = item.rarity == "legendary"

	return e("TextButton", {
		Size = UDim2.new(0, 100, 0, 130),
		BackgroundColor3 = item.equipped and Color3.fromRGB(40, 70, 50) or (isHovered and Color3.fromRGB(35, 30, 50) or COLORS.CARD_BG),
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
			CornerRadius = UDim.new(0, 10),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, gradientColors[1]),
				ColorSequenceKeypoint.new(1, gradientColors[2]),
			}),
			Rotation = 45,
		}),
		Stroke = e("UIStroke", {
			Color = item.equipped and Color3.fromRGB(80, 255, 120) or rarityColor,
			Thickness = item.equipped and 3 or 2,
		}),

		GlowOuter = isLegendary and e("Frame", {
			Size = UDim2.new(1, 6, 1, 6),
			Position = UDim2.new(0, -3, 0, -3),
			BackgroundColor3 = COLORS.GLOW_LEGENDARY,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			ZIndex = -1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
		}),

		RarityBadge = e("Frame", {
			Size = UDim2.new(1, -12, 0, 20),
			Position = UDim2.new(0, 6, 0, 6),
			BackgroundColor3 = rarityColor,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			Label = e("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = string.upper(item.rarity),
				TextColor3 = COLORS.TEXT,
				TextSize = 9,
				Font = Enum.Font.GothamBold,
			}),
		}),

		ItemName = e("TextLabel", {
			Size = UDim2.new(1, -12, 0, 36),
			Position = UDim2.new(0, 6, 0, 30),
			BackgroundTransparency = 1,
			Text = item.name,
			TextColor3 = COLORS.TEXT,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),

		EquippedBadge = item.equipped and e("Frame", {
			Size = UDim2.new(1, -12, 0, 22),
			Position = UDim2.new(0, 6, 1, -28),
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
				TextSize = 10,
				Font = Enum.Font.GothamBold,
			}),
		}),

		EquipHint = not item.equipped and isHovered and e("TextLabel", {
			Size = UDim2.new(1, -12, 0, 20),
			Position = UDim2.new(0, 6, 1, -26),
			BackgroundTransparency = 1,
			Text = "Click to equip",
			TextColor3 = COLORS.TEXT_DIM,
			TextSize = 9,
			Font = Enum.Font.Gotham,
		}),
	})
end

local function RollResultsModal(props)
	local results = props.results
	local onClose = props.onClose
	local hasLegendary = false
	local hasEpic = false
	for _, r in ipairs(results) do
		if r.item.rarity == "legendary" then hasLegendary = true end
		if r.item.rarity == "epic" then hasEpic = true end
	end

	local children = {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.new(0, 130, 0, 160),
			CellPadding = UDim2.new(0, 12, 0, 12),
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
			BackgroundTransparency = hasLegendary and 0.3 or 0.4,
			BorderSizePixel = 0,
		}, {
			Gradient = hasLegendary and e("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 50)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 50)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 50)),
				}),
				Rotation = 0,
			}),
		}),

		ModalFrame = e("Frame", {
			Size = UDim2.new(0.85, 0, 0.85, 0),
			Position = UDim2.new(0.075, 0, 0.075, 0),
			BackgroundColor3 = COLORS.BACKGROUND,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			Stroke = e("UIStroke", {
				Color = hasLegendary and COLORS.GLOW_LEGENDARY or (hasEpic and COLORS.GLOW_EPIC or Color3.fromRGB(80, 80, 100)),
				Thickness = hasLegendary and 4 or 2,
			}),

			HeaderFrame = e("Frame", {
				Size = UDim2.new(1, 0, 0.08, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = COLORS.HEADER,
				BorderSizePixel = 0,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 16),
				}),
				FixCorner = e("Frame", {
					Size = UDim2.new(1, 0, 0.5, 0),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = COLORS.HEADER,
					BorderSizePixel = 0,
				}),
				Title = e("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = hasLegendary and "★★★ LEGENDARY PULL! ★★★" or (hasEpic and "★ EPIC PULL! ★" or "ROLL RESULTS"),
					TextColor3 = hasLegendary and COLORS.GOLD or (hasEpic and COLORS.GLOW_EPIC or COLORS.TEXT),
					TextSize = hasLegendary and 32 or 26,
					Font = Enum.Font.GothamBold,
				}),
			}),

			ResultsContainer = e("ScrollingFrame", {
				Size = UDim2.new(1, -30, 0.82, 0),
				Position = UDim2.new(0, 15, 0.09, 10),
				BackgroundTransparency = 1,
				ScrollBarThickness = 8,
				ScrollBarImageColor3 = COLORS.GOLD,
				CanvasSize = UDim2.new(0, 0, 0, math.ceil(#results / 4) * 175),
			}, children),

			CloseButton = e("TextButton", {
				Size = UDim2.new(0.35, 0, 0, 50),
				Position = UDim2.new(0.325, 0, 0.93, 0),
				BackgroundColor3 = COLORS.BUTTON_ROLL_SINGLE,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 18,
				Font = Enum.Font.GothamBold,
				Text = "Continue",
				[React.Event.Activated] = onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 10),
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
			CellSize = UDim2.new(0, 105, 0, 140),
			CellPadding = UDim2.new(0, 12, 0, 12),
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
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
		}),

		ModalFrame = e("Frame", {
			Size = UDim2.new(0.65, 0, 0.75, 0),
			Position = UDim2.new(0.175, 0, 0.125, 0),
			BackgroundColor3 = COLORS.BACKGROUND,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			Stroke = e("UIStroke", {
				Color = COLORS.SHARDS,
				Thickness = 2,
			}),

			HeaderFrame = e("Frame", {
				Size = UDim2.new(1, 0, 0.1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = COLORS.HEADER,
				BorderSizePixel = 0,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 16),
				}),
				FixCorner = e("Frame", {
					Size = UDim2.new(1, 0, 0.5, 0),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = COLORS.HEADER,
					BorderSizePixel = 0,
				}),
				Title = e("TextLabel", {
					Size = UDim2.new(1, -50, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = "📦 INVENTORY",
					TextColor3 = COLORS.SHARDS,
					TextSize = 24,
					Font = Enum.Font.GothamBold,
				}),
				ItemCount = e("TextLabel", {
					Size = UDim2.new(0, 50, 1, 0),
					Position = UDim2.new(1, -55, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(#allItems),
					TextColor3 = COLORS.TEXT_DIM,
					TextSize = 18,
					Font = Enum.Font.Gotham,
				}),
			}),

			CloseButton = e("TextButton", {
				Size = UDim2.new(0, 36, 0, 36),
				Position = UDim2.new(1, -42, 0, 6),
				BackgroundColor3 = Color3.fromRGB(200, 60, 60),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				TextColor3 = COLORS.TEXT,
				TextSize = 20,
				Font = Enum.Font.GothamBold,
				Text = "✕",
				[React.Event.Activated] = onClose,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),

			ItemsContainer = e("ScrollingFrame", {
				Size = UDim2.new(1, -25, 0.85, 0),
				Position = UDim2.new(0, 12, 0.12, 10),
				BackgroundTransparency = 1,
				ScrollBarThickness = 8,
				ScrollBarImageColor3 = COLORS.SHARDS,
				CanvasSize = UDim2.new(0, 0, 0, math.ceil(#allItems / 4) * 155),
			}, children),
		}),
	})
end

local function AuraDescriptionCard(props)
	local bannerInfo = props.bannerInfo
	local layoutOrder = props.LayoutOrder

	local description = bannerInfo and bannerInfo.featuredItemDescription or "A mysterious aura awaits..."

	return e("TextLabel", {
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = COLORS.TEXT_DIM,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = layoutOrder,
	})
end

local previewModelInstance = nil
local previewAuraInstance = nil
local cameraConnection = nil

local function AuraPreviewViewport(props)
	local featuredItemId = props.featuredItemId
	local rarity = props.rarity

	React.useEffect(function()
		if previewModelInstance then
			previewModelInstance:Destroy()
			previewModelInstance = nil
		end
		if previewAuraInstance then
			previewAuraInstance:Destroy()
			previewAuraInstance = nil
		end
		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end

		local previewModel = ReplicatedStorage:FindFirstChild("PreviewModel")
		if not previewModel then
			warn("[GachaClient] PreviewModel not found in ReplicatedStorage")
			return
		end

		local camera = Workspace.CurrentCamera
		local player = Players.LocalPlayer
		local character = player.Character

		UserInputService.ModalEnabled = true

		local humanoid = nil
		if character then
			humanoid = character:FindFirstChild("Humanoid")
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
				end
			end
			local playerDisplay = character:FindFirstChild("PlayerDisplay")
			if playerDisplay then
				playerDisplay.Enabled = false
			end
			if humanoid then
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
			end
			local backpack = player:FindFirstChild("Backpack")
			if backpack then
				for _, tool in ipairs(backpack:GetChildren()) do
					if tool:IsA("Tool") then
						tool.Parent = backpack
					end
				end
			end
		end

		task.wait(0.1)

		local cameraCFrame = camera.CFrame
		local modelPosition = cameraCFrame * CFrame.new(3, .5, -6) * CFrame.Angles(0, math.rad(180), 0)

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = cameraCFrame

		cameraConnection = RunService.RenderStepped:Connect(function()
			camera.CFrame = cameraCFrame
		end)

		local clonedModel = previewModel:Clone()
		previewModelInstance = clonedModel

		clonedModel.Parent = Workspace
		clonedModel:PivotTo(modelPosition)

		local humanoidRootPart = clonedModel:FindFirstChild("HumanoidRootPart")
		if featuredItemId and humanoidRootPart then
			local aurasFolder = ReplicatedStorage:FindFirstChild("Auras")
			if aurasFolder then
				local auraVFX = aurasFolder:FindFirstChild(featuredItemId)
				if auraVFX then
					local auraInstance = auraVFX:Clone()
					auraInstance.Parent = humanoidRootPart
					if auraInstance:IsA("BasePart") then
						auraInstance.Position = humanoidRootPart.Position
					end
					previewAuraInstance = auraInstance
				else
					warn("[GachaClient] Aura VFX not found:", featuredItemId)
				end
			end
		end

		return function()
			if cameraConnection then
				cameraConnection:Disconnect()
				cameraConnection = nil
			end
			
			camera.CameraType = Enum.CameraType.Custom

			UserInputService.ModalEnabled = false

			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 0
					end
				end
				local playerDisplay = character:FindFirstChild("PlayerDisplay")
				if playerDisplay then
					playerDisplay.Enabled = true
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 16
					humanoid.JumpPower = 50
				end
			end

			if previewModelInstance then
				previewModelInstance:Destroy()
				previewModelInstance = nil
			end
			if previewAuraInstance then
				previewAuraInstance:Destroy()
				previewAuraInstance = nil
			end
		end
	end, {featuredItemId, rarity})

	return nil
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

	local bannerInfo = GachaData.getBannerById(currentBanner)

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

	local blurEffect = Lighting:FindFirstChild("GachaBlur")
	if not blurEffect then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "GachaBlur"
		blurEffect.Size = 0
		blurEffect.Parent = Lighting
	end

	React.useEffect(function()
		if isVisible then
			blurEffect.Size = 0
		else
			blurEffect.Size = 0
		end
	end, {isVisible})

	if not isVisible then
		return nil
	end

	local pityPercent = math.clamp(pityRolls / 80, 0, 1)

	local bannerIds = GachaData.getAllBannerIds()
	local bannerButtons = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 15),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	}

	for i, bannerId in ipairs(bannerIds) do
		local info = GachaData.getBannerById(bannerId)
		if info then
			local isActive = currentBanner == bannerId
			bannerButtons["Banner_" .. i] = e("TextButton", {
				Size = UDim2.new(0, 240, 1, 0),
				BackgroundColor3 = isActive and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(250, 250, 250),
				BorderSizePixel = 0,
				Text = "",
				ZIndex = 11,
				[React.Event.Activated] = function()
					setCurrentBanner(bannerId)
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}),
				Stroke = e("UIStroke", {
					Color = isActive and Color3.fromRGB(255, 150, 50) or Color3.fromRGB(255, 200, 50),
					Thickness = 1,
				}),
				Label = e("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = info.bannerName,
					TextColor3 = isActive and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(100, 100, 100),
					TextSize = 18,
					Font = Enum.Font.GothamBold,
					ZIndex = 13,
				}),
			})
		end
	end

	local bannerTabsFrame = e("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, bannerButtons)

	local mainUI = e("ScreenGui", {
		Name = "GachaUI",
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

			BannerTabsFrame = bannerTabsFrame,

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

	BannerDisplay = e("Frame", {
		Size = UDim2.new(0.35, 0, 0.55, 0),
		Position = UDim2.new(0.1, 0, 0.18, 0),
		BackgroundColor3 = Color3.fromRGB(250, 250, 250),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 20),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(255, 200, 50),
			Thickness = 2,
		}),
		UIPadding = e("UIPadding", {
			PaddingTop = UDim.new(0, 15),
			PaddingBottom = UDim.new(0, 15),
			PaddingLeft = UDim.new(0, 30),
			PaddingRight = UDim.new(0, 30),
		}),
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 40),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		AuraNameLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			Text = bannerInfo and bannerInfo.featuredItemName or "Unknown Aura",
			TextColor3 = RARITY_COLORS[bannerInfo and bannerInfo.featuredItemRarity or "legendary"],
			TextSize = 28,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 1,
		}),

		AuraDescription = e(AuraDescriptionCard, {
			bannerInfo = bannerInfo,
			LayoutOrder = 2,
		}),

		GuaranteeLabel = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = "Every 10 wishes guarantees at least one Epic or higher.",
			TextColor3 = Color3.fromRGB(100, 100, 100),
			TextSize = 18,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 3,
		}),

		TimeSection = e("Frame", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 4,
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
			TimeLabel = e("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = "Time remaining",
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 18,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 1,
			}),
			TimeValue = e("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = GachaData.formatTime(GachaData.getRemainingTime(currentBanner)),
				TextColor3 = Color3.fromRGB(80, 80, 80),
				TextSize = 18,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 2,
			}),
		}),
	}),

	AuraPreview = e(AuraPreviewViewport, {
		featuredItemId = bannerInfo and bannerInfo.featuredItems and bannerInfo.featuredItems[1],
		rarity = bannerInfo and bannerInfo.featuredItemRarity,
	}),

	RollButtonsContainer = e("Frame", {
				Size = UDim2.new(0, 320, 0, 70),
				Position = UDim2.new(1, -340, 1, -90),
				BackgroundTransparency = 1,
				ZIndex = 50,
			}, {
				Layout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 15),
				}),
				SingleRoll = e("TextButton", {
					Size = UDim2.new(0, 150, 0, 60),
					BackgroundColor3 = Color3.fromRGB(250, 250, 250),
					BorderSizePixel = 0,
					Text = "Roll x1 - 100",
					TextColor3 = Color3.fromRGB(100, 100, 100),
					TextSize = 18,
					Font = Enum.Font.GothamBold,
					[React.Event.Activated] = function()
						doRoll(1)
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 20),
					}),
				}),
				TenRoll = e("TextButton", {
					Size = UDim2.new(0, 150, 0, 60),
					BackgroundColor3 = Color3.fromRGB(250, 250, 250),
					BorderSizePixel = 0,
					Text = "Roll x10 - 900",
					TextColor3 = Color3.fromRGB(100, 100, 100),
					TextSize = 18,
					Font = Enum.Font.GothamBold,
					[React.Event.Activated] = function()
						doRoll(10)
					end,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 20),
					}),
				}),
			}),

			InventoryButton = e("TextButton", {
				Size = UDim2.new(0, 200, 0, 50),
				Position = UDim2.new(0, 20, 1, -70),
				BackgroundColor3 = Color3.fromRGB(250, 250, 250),
				BorderSizePixel = 0,
				Text = "Inventory",
				TextColor3 = Color3.fromRGB(100, 100, 100),
				TextSize = 16,
				Font = Enum.Font.GothamBold,
				ZIndex = 50,
				[React.Event.Activated] = function()
					setShowInventory(true)
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}),
			}),

			ShopButton = e("TextButton", {
				Size = UDim2.new(0, 200, 0, 50),
				Position = UDim2.new(0, 20, 1, -130),
				BackgroundColor3 = Color3.fromRGB(250, 250, 250),
				BorderSizePixel = 0,
				Text = "Buy Gems",
				TextColor3 = Color3.fromRGB(100, 100, 100),
				TextSize = 18,
				Font = Enum.Font.GothamBold,
				[React.Event.Activated] = props.onOpenShop,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
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
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
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
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
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
