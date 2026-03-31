local React = require(game.ReplicatedStorage.Shared.React)

local function RoleSelectionMenu(props)
	local currentCategoryIndex, setCurrentCategoryIndex = React.useState(0)
	local currentTeamIndex, setCurrentTeamIndex = React.useState(0)
	local onRoleSelected = props.onRoleSelected
	local visible = props.visible
	local onMenuClose = props.onMenuClose
	local onRebirth = props.onRebirth
	local teamData = props.teamData

	local currentCategory = teamData[currentCategoryIndex + 1]
	local currentTeam = currentCategory.teams[currentTeamIndex + 1]
	local totalCategories = #teamData
	local totalTeamsInCategory = #currentCategory.teams

	local maxSlots = currentTeam.slots

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

	local function handleCategoryChange(direction)
		local newIndex = currentCategoryIndex + direction
		if newIndex < 0 then
			newIndex = totalCategories - 1
		elseif newIndex >= totalCategories then
			newIndex = 0
		end
		setCurrentCategoryIndex(newIndex)
		setCurrentTeamIndex(0)
	end

	local function handleTeamChange(direction)
		local newIndex = currentTeamIndex + direction
		if newIndex < 0 then
			newIndex = totalTeamsInCategory - 1
		elseif newIndex >= totalTeamsInCategory then
			newIndex = 0
		end
		setCurrentTeamIndex(newIndex)
	end

	local function handleJoinClick()
		if onRoleSelected and currentTeam then
			onRoleSelected(currentTeam.name)
		end
		if onMenuClose then
			onMenuClose()
		end
	end

	local function handleRebirthClick()
		if onRebirth then
			onRebirth()
		end
	end

	-- Handle toolbar button clicks
	local function handleInventoryClick()
		-- Open Roblox backpack/inventory
		local player = game.Players.LocalPlayer
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			-- The backpack is shown by default in Roblox
			-- This would need custom implementation or use of StarterGui
		end
		-- Alternative: toggle CoreGui
		game:GetService("StarterGui"):SetCore("TopBarEnabled", true)
	end

	local function handlePlayerListClick()
		-- Toggle player list
		game:GetService("StarterGui"):SetCore("PlayerList", "Start")
	end

	local function handleAvatarClick()
		-- Open avatar editor
		game:GetService("StarterGui"):SetCore("AvatarEditor", "Start")
	end

	local function handleRPInfoClick()
		-- This would open RP info panel (can be implemented later)
		print("RP Info clicked")
	end

	local function handleSettingsClick()
		-- Open settings menu
		game:GetService("StarterGui"):SetCore("GameSettings", "Start")
	end

	local function handleChatClick()
		-- Toggle chat
		game:GetService("StarterGui"):SetCore("Chat", "Start")
	end

	-- Show Rebirth button when menu is closed
	if not visible then
		return React.createElement("ScreenGui", {
			Name = "RoleSelectionMenu",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			RebirthButton = React.createElement("TextButton", {
				Name = "RebirthButton",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(70, 35, 90),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0, 20, 0.5, 0),
				Size = UDim2.new(0, 120, 0, 50),
				Text = "↺ Rebirth",
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
					Text = currentCategory.category,
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

			-- Team navigation arrows
			TeamNavLeft = React.createElement("TextButton", {
				Name = "TeamNavLeft",
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
					handleTeamChange(-1)
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

			TeamNavRight = React.createElement("TextButton", {
				Name = "TeamNavRight",
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
					handleTeamChange(1)
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

			-- Team name (fantasy style)
			TeamName = React.createElement("TextLabel", {
				Name = "TeamName",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 55),
				Size = UDim2.new(0.75, 0, 0, 28),
				Text = currentTeam.name,
				TextColor3 = Color3.fromRGB(255, 180, 200),
				TextSize = 22,
			}),

			-- Emoji (decorative)
			TeamEmoji = React.createElement("TextLabel", {
				Name = "TeamEmoji",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 85),
				Size = UDim2.new(0.5, 0, 0, 40),
				Text = currentTeam.emoji,
				TextSize = 36,
			}),

			-- Join button (fantasy style)
			JoinButton = React.createElement("TextButton", {
				Name = "JoinButton",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(70, 35, 90),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 130),
				Size = UDim2.new(0.55, 0, 0, 40),
				Text = "Join",
				TextColor3 = Color3.fromRGB(235, 215, 255),
				TextSize = 18,
				[React.Event.Activated] = handleJoinClick,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 140, 220),
					Thickness = 1,
				}),
			}),

			-- Slots counter (fantasy style)
			SlotsCounter = React.createElement("TextLabel", {
				Name = "SlotsCounter",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0, 178),
				Size = UDim2.new(0.8, 0, 0, 22),
				Text = "Slots: 0/" .. (maxSlots == -1 and "∞" or tostring(maxSlots)),
				TextColor3 = Color3.fromRGB(180, 140, 220),
				TextSize = 14,
			}),

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
					Text = currentTeam.description,
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
					Text = currentTeam.perks,
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

			-- Team counter (bottom)
			TeamCounter = React.createElement("TextLabel", {
				Name = "TeamCounter",
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 1, -12),
				Size = UDim2.new(0.9, 0, 0, 22),
				Text = (currentTeamIndex + 1) .. "/" .. totalTeamsInCategory .. " · " .. currentCategory.category,
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
