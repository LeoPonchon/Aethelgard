local React = require(game.ReplicatedStorage.Shared.React)

local function CharacterCreationMenu(props)
	local visible = props.visible
	local races = props.races or {}
	local classes = props.classes or {}
	local currentRaceIndex = props.currentRaceIndex or 0
	local currentClassIndex = props.currentClassIndex or 0
	local currentStep = props.currentStep or 1
	local onRaceChange = props.onRaceChange
	local onClassChange = props.onClassChange
	local onRaceSelect = props.onRaceSelect
	local onClassSelect = props.onClassSelect
	local onBack = props.onBack
	local onConfirm = props.onConfirm
	
	-- Get current race and class
	local currentRace = races[currentRaceIndex + 1]
	local currentClass = classes[currentClassIndex + 1]
	
	-- If not visible, return nothing
	if not visible then
		return nil
	end
	
	-- Helper to create navigation button
	local function createNavButton(emoji, label, onClick, position)
		return React.createElement("TextButton", {
			Name = label .. "Button",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(70, 45, 90),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = position,
			Size = UDim2.new(0, 35, 0, 35),
			Text = emoji,
			TextColor3 = Color3.fromRGB(200, 160, 240),
			TextSize = 16,
			[React.Event.Activated] = onClick,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
		})
	end
	
	-- Format bonuses text
	local function formatBonuses(race)
		if not race or not race.bonus then
			return "Aucun bonus"
		end
		local bonusTexts = {}
		for _, bonus in ipairs(race.bonus) do
			table.insert(bonusTexts, bonus.description)
		end
		return table.concat(bonusTexts, " • ")
	end
	
	-- Format stats text
	local function formatStats(class)
		if not class or not class.baseStats then
			return ""
		end
		local statTexts = {}
		for statName, statValue in pairs(class.baseStats) do
			local shortNames = {
				Strength = "FOR",
				Agility = "AGI",
				Intelligence = "INT",
				Wisdom = "SAG",
				Vitality = "VIT",
				Luck = "LCK",
			}
			table.insert(statTexts, (shortNames[statName] or statName) .. ":" .. statValue)
		end
		return table.concat(statTexts, " ")
	end
	
	-- Get emoji for race
	local function getRaceEmoji(raceId)
		local emojis = {
			human = "H",
			elf = "E",
			dwarf = "D",
			halfling = "h",
			orc = "O",
			demon = "X",
			tiefling = "T",
		}
		return emojis[raceId] or "R"
	end
	
	-- Get emoji for class
	local function getClassEmoji(className)
		local emojis = {
			Guerrier = "S",
			Chevalier = "D",
			Voleur = "d",
			Archer = "B",
			Mage = "M",
			Necromancien = "N",
			Pretre = "P",
			Druide = "D",
			Paladin = "P",
			Barde = "B",
			Moine = "M",
			Invocateur = "I",
		}
		return emojis[className] or "C"
	end
	
	-- Step indicator text
	local step1Color = currentStep == 1 and Color3.fromRGB(180, 140, 220) or Color3.fromRGB(100, 80, 120)
	local step2Color = currentStep == 2 and Color3.fromRGB(180, 140, 220) or Color3.fromRGB(100, 80, 120)
	
	-- Main frame
	return React.createElement("ScreenGui", {
		Name = "CharacterCreationMenu",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		MainFrame = React.createElement("Frame", {
			Name = "MainFrame",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(40, 25, 55),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 500, 0, 450),
		}, {
			-- Title
			Title = React.createElement("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 10),
				Size = UDim2.new(0.9, 0, 0, 35),
				Text = "Création de Personnage",
				TextColor3 = Color3.fromRGB(255, 215, 255),
				TextSize = 24,
			}),
			
			-- Step indicator
			StepIndicator = React.createElement("Frame", {
				Name = "StepIndicator",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0, 50),
				Size = UDim2.new(0.8, 0, 0, 25),
			}, {
				Layout = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 20),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				
				Step1 = React.createElement("TextLabel", {
					Name = "Step1",
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Size = UDim2.new(0, 80, 1, 0),
					Text = "1. Race",
					TextColor3 = step1Color,
					TextSize = 14,
				}),
				
				Step2 = React.createElement("TextLabel", {
					Name = "Step2",
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Size = UDim2.new(0, 80, 1, 0),
					Text = "2. Classe",
					TextColor3 = step2Color,
					TextSize = 14,
				}),
			}),
			
			-- Race Selection Panel
			RacePanel = React.createElement("Frame", {
				Name = "RacePanel",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(50, 30, 65),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 85),
				Size = UDim2.new(0.95, 0, 0, 280),
				Visible = currentStep == 1,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
				
				-- Race navigation
				RaceNavLeft = createNavButton("◀", "RaceNavLeft", function()
					if onRaceChange then onRaceChange(-1) end
				end, UDim2.new(0.02, 0, 0.5, 0)),
				
				RaceNavRight = createNavButton("▶", "RaceNavRight", function()
					if onRaceChange then onRaceChange(1) end
				end, UDim2.new(0.98, 0, 0.5, 0)),
				
				-- Race name
				RaceName = React.createElement("TextLabel", {
					Name = "RaceName",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.05, 0),
					Size = UDim2.new(0.7, 0, 0, 30),
					Text = currentRace and currentRace.name or "Sélectionnez une race",
					TextColor3 = Color3.fromRGB(255, 200, 220),
					TextSize = 22,
				}),
				
				-- Race emoji
				RaceEmoji = React.createElement("TextLabel", {
					Name = "RaceEmoji",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.18, 0),
					Size = UDim2.new(0.5, 0, 0, 45),
					Text = currentRace and getRaceEmoji(currentRace.id) or "👤",
					TextSize = 40,
				}),
				
				-- Race description
				RaceDescription = React.createElement("Frame", {
					Name = "RaceDescription",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(60, 40, 75),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.35, 0),
					Size = UDim2.new(0.85, 0, 0, 60),
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Text = React.createElement("TextLabel", {
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.95, 0, 0.9, 0),
						Text = currentRace and currentRace.description or "",
						TextColor3 = Color3.fromRGB(200, 180, 220),
						TextSize = 12,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
				
				-- Race bonuses
				RaceBonuses = React.createElement("Frame", {
					Name = "RaceBonuses",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(70, 50, 90),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0.85, 0, 0, 50),
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Title = React.createElement("TextLabel", {
						Name = "Title",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.new(0.5, 0, 0, 3),
						Size = UDim2.new(0.9, 0, 0, 18),
						Text = "Bonus:",
						TextColor3 = Color3.fromRGB(150, 200, 150),
						TextSize = 12,
					}),
					Text = React.createElement("TextLabel", {
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(0.5, 0, 0.4, 0),
						Size = UDim2.new(0.9, 0, 0, 30),
						Text = currentRace and formatBonuses(currentRace) or "",
						TextColor3 = Color3.fromRGB(180, 220, 180),
						TextSize = 11,
						TextWrapped = true,
					}),
				}),
				
				-- Select Race button
				SelectRaceButton = React.createElement("TextButton", {
					Name = "SelectRaceButton",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(80, 50, 100),
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.85, 0),
					Size = UDim2.new(0.5, 0, 0, 35),
					Text = "Sélectionner cette Race",
					TextColor3 = Color3.fromRGB(255, 220, 255),
					TextSize = 14,
					[React.Event.Activated] = function()
						if onRaceSelect then onRaceSelect() end
					end,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					UIStroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(150, 100, 180),
						Thickness = 1,
					}),
				}),
			}),
			
			-- Class Selection Panel
			ClassPanel = React.createElement("Frame", {
				Name = "ClassPanel",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(50, 30, 65),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 85),
				Size = UDim2.new(0.95, 0, 0, 280),
				Visible = currentStep == 2,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
				
				-- Class navigation
				ClassNavLeft = createNavButton("◀", "ClassNavLeft", function()
					if onClassChange then onClassChange(-1) end
				end, UDim2.new(0.02, 0, 0.5, 0)),
				
				ClassNavRight = createNavButton("▶", "ClassNavRight", function()
					if onClassChange then onClassChange(1) end
				end, UDim2.new(0.98, 0, 0.5, 0)),
				
				-- Class name
				ClassName = React.createElement("TextLabel", {
					Name = "ClassName",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.05, 0),
					Size = UDim2.new(0.7, 0, 0, 30),
					Text = currentClass and currentClass.name or "Sélectionnez une classe",
					TextColor3 = Color3.fromRGB(255, 200, 220),
					TextSize = 22,
				}),
				
				-- Class emoji
				ClassEmoji = React.createElement("TextLabel", {
					Name = "ClassEmoji",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.18, 0),
					Size = UDim2.new(0.5, 0, 0, 45),
					Text = currentClass and getClassEmoji(currentClass.name) or "🎭",
					TextSize = 40,
				}),
				
				-- Class description
				ClassDescription = React.createElement("Frame", {
					Name = "ClassDescription",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(60, 40, 75),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.35, 0),
					Size = UDim2.new(0.85, 0, 0, 50),
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Text = React.createElement("TextLabel", {
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.95, 0, 0.9, 0),
						Text = currentClass and currentClass.description or "",
						TextColor3 = Color3.fromRGB(200, 180, 220),
						TextSize = 12,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
				
				-- Class stats
				ClassStats = React.createElement("Frame", {
					Name = "ClassStats",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(70, 50, 90),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.55, 0),
					Size = UDim2.new(0.85, 0, 0, 55),
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					Title = React.createElement("TextLabel", {
						Name = "Title",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.new(0.5, 0, 0, 3),
						Size = UDim2.new(0.9, 0, 0, 18),
						Text = "Statistiques de base:",
						TextColor3 = Color3.fromRGB(150, 180, 220),
						TextSize = 12,
					}),
					Text = React.createElement("TextLabel", {
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(0.5, 0, 0.4, 0),
						Size = UDim2.new(0.9, 0, 0, 35),
						Text = currentClass and formatStats(currentClass) or "",
						TextColor3 = Color3.fromRGB(180, 200, 220),
						TextSize = 11,
						TextWrapped = true,
					}),
				}),
				
				-- Select Class button
				SelectClassButton = React.createElement("TextButton", {
					Name = "SelectClassButton",
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(80, 50, 100),
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0.5, 0, 0.85, 0),
					Size = UDim2.new(0.5, 0, 0, 35),
					Text = "Sélectionner cette Classe",
					TextColor3 = Color3.fromRGB(255, 220, 255),
					TextSize = 14,
					[React.Event.Activated] = function()
						if onClassSelect then onClassSelect() end
					end,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 6),
					}),
					UIStroke = React.createElement("UIStroke", {
						Color = Color3.fromRGB(150, 100, 180),
						Thickness = 1,
					}),
				}),
			}),
			
			-- Back button
			BackButton = React.createElement("TextButton", {
				Name = "BackButton",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(60, 40, 70),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.02, 0, 0.5, 0),
				Size = UDim2.new(0, 80, 0, 30),
				Text = "← Retour",
				TextColor3 = Color3.fromRGB(180, 150, 200),
				TextSize = 12,
				[React.Event.Activated] = function()
					if onBack then onBack() end
				end,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),
			
			-- Confirm button (appears after class selection)
			ConfirmButton = React.createElement("TextButton", {
				Name = "ConfirmButton",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(100, 60, 120),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.5, 0, 0, 375),
				Size = UDim2.new(0.4, 0, 0, 40),
				Text = "Confirmer",
				TextColor3 = Color3.fromRGB(255, 230, 255),
				TextSize = 16,
				Visible = currentStep == 2,
				[React.Event.Activated] = function()
					if onConfirm then onConfirm() end
				end,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIStroke = React.createElement("UIStroke", {
					Color = Color3.fromRGB(180, 130, 200),
					Thickness = 2,
				}),
			}),
			
			-- Selected info display
			SelectedInfo = React.createElement("TextLabel", {
				Name = "SelectedInfo",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0, 420),
				Size = UDim2.new(0.8, 0, 0, 25),
				Text = currentRace and currentClass 
					and ("Sélection: " .. currentRace.name .. " - " .. currentClass.name) 
					or "",
				TextColor3 = Color3.fromRGB(150, 120, 180),
				TextSize = 14,
			}),
			
			-- Main UIStroke
			UIStroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(120, 80, 150),
				Thickness = 2,
			}),
		}),
	})
end

return CharacterCreationMenu