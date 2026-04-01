local React = require(game.ReplicatedStorage.Shared.React)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function RoleSelectionMenu(props)
	-- Selection step: 1 = team, 2 = race, 3 = class
	local currentStep, setCurrentStep = React.useState(1)
	
	-- Team selection state
	local currentTeamCategoryIndex, setCurrentTeamCategoryIndex = React.useState(0)
	local currentTeamIndex, setCurrentTeamIndex = React.useState(0)
	
	-- Race selection state
	local currentRaceCategoryIndex, setCurrentRaceCategoryIndex = React.useState(0)
	local currentRaceIndex, setCurrentRaceIndex = React.useState(0)
	
	-- Class selection state
	local currentClassCategoryIndex, setCurrentClassCategoryIndex = React.useState(0)
	local currentClassIndex, setCurrentClassIndex = React.useState(0)
	
	-- Props
	local onRoleSelected = props.onRoleSelected
	local onRaceSelected = props.onRaceSelected
	local onClassSelected = props.onClassSelected
	local visible = props.visible
	local onMenuClose = props.onMenuClose
	local onRebirth = props.onRebirth
	local teamData = props.teamData or {}
	local raceData = props.raceData or {}
	local classData = props.classData or {}
	
	-- State for slot counts from server
	local slotCounts, setSlotCounts = React.useState({})

	-- Get current selection based on step
	local currentCategory, currentItem, totalCategories, totalItemsInCategory, maxSlots
	
	if currentStep == 1 then
		currentCategory = teamData[currentTeamCategoryIndex + 1]
		currentItem = currentCategory and currentCategory.teams[currentTeamIndex + 1]
		totalCategories = #teamData
		totalItemsInCategory = currentCategory and #currentCategory.teams or 0
		maxSlots = currentItem and currentItem.slots or -1
	elseif currentStep == 2 then
		currentCategory = raceData[currentRaceCategoryIndex + 1]
		currentItem = currentCategory and currentCategory.races[currentRaceIndex + 1]
		totalCategories = #raceData
		totalItemsInCategory = currentCategory and #currentCategory.races or 0
		maxSlots = -1
	else
		currentCategory = classData[currentClassCategoryIndex + 1]
		currentItem = currentCategory and currentCategory.classes[currentClassIndex + 1]
		totalCategories = #classData
		totalItemsInCategory = currentCategory and #currentCategory.classes or 0
		maxSlots = -1
	end

	-- Fetch slot counts from server periodically
	React.useEffect(function()
		if not visible then return end

		local getSlotsRemote = ReplicatedStorage:FindFirstChild("GetRoleSlots")
		if not getSlotsRemote then return end

		local function updateSlotCounts()
			local success, result = pcall(function()
				return getSlotsRemote:InvokeServer()
			end)
			if success and result then
				setSlotCounts(result)
			end
		end

		-- Initial fetch
		updateSlotCounts()

		-- Update every 5 seconds
		task.spawn(function()
			while visible do
				task.wait(5)
				if visible then
					updateSlotCounts()
				end
			end
		end)
	end, { visible })

	-- Helper function to create toolbar buttons
	local function createToolbarButton(emoji, label, onClick)
		return React.createElement("TextButton", {
			Name = label .. "Button",
			BackgroundColor3 = Color3.fromRGB(45, 25, 60),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0, 38, 0, 28),
			Text = emoji,
			TextSize = 16,
			[React.Event.Activated] = onClick,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})
	end

	-- Navigation handlers
	local function handleCategoryChange(direction)
		if currentStep == 1 then
			local totalCats = #teamData
			local newIndex = currentTeamCategoryIndex + direction
			if newIndex < 0 then
				newIndex = totalCats - 1
			elseif newIndex >= totalCats then
				newIndex = 0
			end
			setCurrentTeamCategoryIndex(newIndex)
			setCurrentTeamIndex(0)
		elseif currentStep == 2 then
			local totalCats = #raceData
			local newIndex = currentRaceCategoryIndex + direction
			if newIndex < 0 then
				newIndex = totalCats - 1
			elseif newIndex >= totalCats then
				newIndex = 0
			end
			setCurrentRaceCategoryIndex(newIndex)
			setCurrentRaceIndex(0)
		else
			local totalCats = #classData
			local newIndex = currentClassCategoryIndex + direction
			if newIndex < 0 then
				newIndex = totalCats - 1
			elseif newIndex >= totalCats then
				newIndex = 0
			end
			setCurrentClassCategoryIndex(newIndex)
			setCurrentClassIndex(0)
		end
	end

	local function handleItemChange(direction)
		if currentStep == 1 then
			local category = teamData[currentTeamCategoryIndex + 1]
			local totalItems = category and #category.teams or 0
			local newIndex = currentTeamIndex + direction
			if newIndex < 0 then
				newIndex = totalItems - 1
			elseif newIndex >= totalItems then
				newIndex = 0
			end
			setCurrentTeamIndex(newIndex)
		elseif currentStep == 2 then
			local category = raceData[currentRaceCategoryIndex + 1]
			local totalItems = category and #category.races or 0
			local newIndex = currentRaceIndex + direction
			if newIndex < 0 then
				newIndex = totalItems - 1
			elseif newIndex >= totalItems then
				newIndex = 0
			end
			setCurrentRaceIndex(newIndex)
		else
			local category = classData[currentClassCategoryIndex + 1]
			local totalItems = category and #category.classes or 0
			local newIndex = currentClassIndex + direction
			if newIndex < 0 then
				newIndex = totalItems - 1
			elseif newIndex >= totalItems then
				newIndex = 0
			end
			setCurrentClassIndex(newIndex)
		end
	end

	local function handleNextClick()
	if currentStep == 1 then
		-- Team selected, move to race
		-- Get the current team directly from the state
		local teamCategory = teamData[currentTeamCategoryIndex + 1]
		local team = teamCategory and teamCategory.teams[currentTeamIndex + 1]
		if onRoleSelected and team then
			onRoleSelected(team.name)
		end
		setCurrentStep(2)
		setCurrentRaceCategoryIndex(0)
		setCurrentRaceIndex(0)
	elseif currentStep == 2 then
		-- Race selected, move to class
		-- Get the current race directly from the state
		local raceCategory = raceData[currentRaceCategoryIndex + 1]
		local race = raceCategory and raceCategory.races[currentRaceIndex + 1]
		if onRaceSelected and race then
			onRaceSelected(race.name)
		end
		setCurrentStep(3)
		setCurrentClassCategoryIndex(0)
		setCurrentClassIndex(0)
	else
		-- Class selected, close menu
		-- Get the current class directly from the state
		local classCategory = classData[currentClassCategoryIndex + 1]
		local classItem = classCategory and classCategory.classes[currentClassIndex + 1]
		if onClassSelected and classItem then
			onClassSelected(classItem.name)
		end
		if onMenuClose then
			onMenuClose()
		end
	end
	end

	local function handleBackClick()
		if currentStep > 1 then
			setCurrentStep(currentStep - 1)
		end
	end

	local function handleRebirthClick()
		if onRebirth then
			onRebirth()
		end
	end

	-- Handle toolbar button clicks
	local function handleInventoryClick()
		game:GetService("StarterGui"):SetCore("TopBarEnabled", true)
	end

	local function handlePlayerListClick()
		game:GetService("StarterGui"):SetCore("PlayerList", "Start")
	end

	local function handleAvatarClick()
		game:GetService("StarterGui"):SetCore("AvatarEditor", "Start")
	end

	local function handleRPInfoClick()
		print("RP Info clicked")
	end

	local function handleSettingsClick()
		game:GetService("StarterGui"):SetCore("GameSettings", "Start")
	end

	local function handleChatClick()
		game:GetService("StarterGui"):SetCore("Chat", "Start")
	end

	-- Get button text
	local function getButtonText()
		if currentStep == 1 then
			return "Suivant →"
		elseif currentStep == 2 then
			return "Suivant →"
		else
			return "Confirmer ✓"
		end
	end

	-- Get current slot info for display
	local itemSlotInfo = currentItem and slotCounts[currentItem.name] or { current = 0, max = maxSlots }
	local currentCount = itemSlotInfo.current or 0
	local displayMax = maxSlots == -1 and "∞" or tostring(maxSlots)
	local slotsText = "Slots: " .. currentCount .. "/" .. displayMax

	-- Show Rebirth button when menu is closed
	if not visible then
		return React.createElement("ScreenGui", {
			Name = "RoleSelectionMenu",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			-- Toolbar (always visible in top right, even when menu is closed)
			Toolbar = React.createElement("Frame", {
				Name = "Toolbar",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(35, 20, 50),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -10, 0, 10),
				Size = UDim2.new(0, 260, 0, 38),
			}, {
				Layout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 3),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
				}),
				Padding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingTop = UDim.new(0, 3),
					PaddingBottom = UDim.new(0, 3),
				}),

				InventoryBtn = createToolbarButton("🎒", "Inv", handleInventoryClick),
				PlayerListBtn = createToolbarButton("👥", "Players", handlePlayerListClick),
				AvatarBtn = createToolbarButton("👤", "Avatar", handleAvatarClick),
				RPInfoBtn = createToolbarButton("📜", "RP", handleRPInfoClick),
				SettingsBtn = createToolbarButton("⚙️", "Settings", handleSettingsClick),
				ChatBtn = createToolbarButton("💬", "Chat", handleChatClick),
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(100, 80, 130),
					Thickness = 1,
				}),
			}),

			RebirthButton = React.createElement("TextButton", {
				Name = "RebirthButton",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(70, 35, 90),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0, 20, 0.5, 0),
				Size = UDim2.new(0, 120, 0, 50),
				Text = "Rebirth",
				TextColor3 = Color3.fromRGB(235, 215, 255),
				TextSize = 18,
				[React.Event.Activated] = handleRebirthClick,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 2,
				}),
			}),
		})
	end

	-- Fantasy parchment UI
	return React.createElement("ScreenGui", {
		Name = "RoleSelectionMenu",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		-- Toolbar (always visible in top right)
		Toolbar = React.createElement("Frame", {
			Name = "Toolbar",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(35, 20, 50),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 10),
			Size = UDim2.new(0, 260, 0, 38),
		}, {
			Layout = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 3),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
			}),
			Padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 3),
				PaddingBottom = UDim.new(0, 3),
			}),

			InventoryBtn = createToolbarButton("🎒", "Inv", handleInventoryClick),
			PlayerListBtn = createToolbarButton("👥", "Players", handlePlayerListClick),
			AvatarBtn = createToolbarButton("👤", "Avatar", handleAvatarClick),
			RPInfoBtn = createToolbarButton("📜", "RP", handleRPInfoClick),
			SettingsBtn = createToolbarButton("⚙️", "Settings", handleSettingsClick),
			ChatBtn = createToolbarButton("💬", "Chat", handleChatClick),
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			UIStroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(100, 80, 130),
				Thickness = 1,
			}),
		}),

		MainFrame = React.createElement("Frame", {
			Name = "MainFrame",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(50, 30, 70),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 420, 0, 340),
		}, {
			-- Parchment texture overlay (top darker area)
			TextureOverlay = React.createElement("Frame", {
				Name = "TextureOverlay",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(60, 40, 80),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 55),
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 12),
				}),
			}),
	
			-- Category navigation
			CategoryNav = React.createElement("Frame", {
				Name = "CategoryNav",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 5),
				Size = UDim2.new(0.95, 0, 0, 45),
				ZIndex = 10,
			}, {
				PrevButton = React.createElement("TextButton", {
					Name = "PrevButton",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(110, 60, 140),
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0, 8, 0.5, 0),
					Size = UDim2.new(0, 35, 0, 35),
					Text = "◀",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 18,
					ZIndex = 10,
					[React.Event.Activated] = function()
						handleCategoryChange(-1)
					end,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
				CategoryTitle = React.createElement("TextLabel", {
					Name = "CategoryTitle",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					RichText = true,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.65, 0, 1, 0),
					Text = currentCategory and currentCategory.category or "",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 20,
					ZIndex = 10,
				}),
				NextButton = React.createElement("TextButton", {
					Name = "NextButton",
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(110, 60, 140),
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.new(0, 35, 0, 35),
					Text = "▶",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 18,
					ZIndex = 10,
					[React.Event.Activated] = function()
						handleCategoryChange(1)
					end,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
				}),
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),

			-- Item navigation arrows
			ItemNavLeft = React.createElement("TextButton", {
				Name = "ItemNavLeft",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(60, 40, 80),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.03, 0, 0.4, 0),
				Size = UDim2.new(0, 32, 0, 32),
				Text = "◀",
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 14,
				ZIndex = 5,
				[React.Event.Activated] = function()
					handleItemChange(-1)
				end,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 1,
				}),
			}),

			ItemNavRight = React.createElement("TextButton", {
				Name = "ItemNavRight",
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(60, 40, 80),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.97, 0, 0.4, 0),
				Size = UDim2.new(0, 32, 0, 32),
				Text = "▶",
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 14,
				ZIndex = 5,
				[React.Event.Activated] = function()
					handleItemChange(1)
				end,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 1,
				}),
			}),

			-- Item name (fantasy style)
			ItemName = React.createElement("TextLabel", {
				Name = "ItemName",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 55),
				Size = UDim2.new(0.75, 0, 0, 28),
				Text = currentItem and currentItem.name or "",
				TextColor3 = Color3.fromRGB(255, 180, 200),
				TextSize = 22,
			}),
		
			-- Emoji (decorative)
			ItemEmoji = React.createElement("TextLabel", {
				Name = "ItemEmoji",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 85),
				Size = UDim2.new(0.5, 0, 0, 40),
				Text = currentItem and currentItem.emoji or "",
				TextSize = 36,
			}),
		
			-- Next/Confirm button (fantasy style)
			NextButton = React.createElement("TextButton", {
				Name = "NextButton",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(70, 35, 90),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 130),
				Size = UDim2.new(0.55, 0, 0, 40),
				Text = getButtonText(),
				TextColor3 = Color3.fromRGB(235, 215, 255),
				TextSize = 18,
				[React.Event.Activated] = handleNextClick,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 1,
				}),
			}),
		
			-- Back button (if not on first step)
			BackButton = currentStep > 1 and React.createElement("TextButton", {
				Name = "BackButton",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(50, 30, 60),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 175),
				Size = UDim2.new(0.4, 0, 0, 30),
				Text = "← Retour",
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 14,
				[React.Event.Activated] = handleBackClick,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(100, 70, 130),
					Thickness = 1,
				}),
			}) or nil,
		
			-- Slots counter (fantasy style) - only for teams
			currentStep == 1 and React.createElement("TextLabel", {
				Name = "SlotsCounter",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0, 178),
				Size = UDim2.new(0.8, 0, 0, 22),
				Text = slotsText,
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 14,
			}) or nil,
		
			-- Description (styled as handwritten)
			DescriptionFrame = React.createElement("Frame", {
				Name = "DescriptionFrame",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(235, 215, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 208),
				Size = UDim2.new(0.85, 0, 0, 55),
			}, {
				Description = React.createElement("TextLabel", {
					Name = "Description",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.9, 0, 0.85, 0),
					Text = currentItem and currentItem.description or "",
					TextColor3 = Color3.fromRGB(80, 40, 100),
					TextSize = 13,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 1,
				}),
			}),

			-- Perks (styled differently - purple magical accent)
			PerksFrame = React.createElement("Frame", {
				Name = "PerksFrame",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(200, 170, 230),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 270),
				Size = UDim2.new(0.85, 0, 0, 32),
			}, {
				PerksLabel = React.createElement("TextLabel", {
					Name = "PerksLabel",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.02, 0, 0.5, 0),
					Size = UDim2.new(0.18, 0, 1, 0),
					Text = "Perks:",
					TextColor3 = Color3.fromRGB(120, 60, 160),
					TextSize = 11,
				}),
				PerksText = React.createElement("TextLabel", {
					Name = "PerksText",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.2, 0, 0.5, 0),
					Size = UDim2.new(0.78, 0, 1, 0),
					Text = currentItem and currentItem.perks or "",
					TextColor3 = Color3.fromRGB(120, 60, 160),
					TextSize = 11,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(80, 40, 100),
					Thickness = 1,
				}),
			}),

			-- Item counter (bottom)
			ItemCounter = React.createElement("TextLabel", {
				Name = "ItemCounter",
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 1, -12),
				Size = UDim2.new(0.9, 0, 0, 22),
				Text = (currentStep == 1 and currentTeamIndex or currentStep == 2 and currentRaceIndex or currentClassIndex) + 1 .. "/" .. totalItemsInCategory .. " · " .. (currentCategory and currentCategory.category or ""),
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 13,
			}),

			-- Main border
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),

			UIStroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(180, 140, 220),
				Thickness = 4,
			}),
		}),
	})
end

return RoleSelectionMenu
