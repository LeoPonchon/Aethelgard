--!nonstrict
-- Debug UI for testing class, race, and team changes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ReactRoblox"))

local ClassData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ClassData"))
local RaceData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RaceData"))
local TeamData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TeamData"))

local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local playerDataRemote = ReplicatedStorage:WaitForChild("PlayerData")

local COLORS = {
	BACKGROUND = Color3.fromRGB(30, 30, 40),
	HEADER = Color3.fromRGB(50, 50, 70),
	TAB_INACTIVE = Color3.fromRGB(40, 40, 55),
	TAB_ACTIVE = Color3.fromRGB(70, 70, 100),
	BUTTON_DEFAULT = Color3.fromRGB(60, 60, 80),
	BUTTON_HOVER = Color3.fromRGB(80, 80, 120),
	BUTTON_SELECTED = Color3.fromRGB(80, 140, 80),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 180),
	SCROLLBAR = Color3.fromRGB(80, 80, 100),
}

local TABS = {"Class", "Race", "Team"}

local function flattenClasses()
	local flat = {}
	for _, category in ipairs(ClassData) do
		for _, classInfo in ipairs(category.classes) do
			table.insert(flat, classInfo)
		end
	end
	return flat
end

local function flattenRaces()
	local flat = {}
	for _, category in ipairs(RaceData) do
		for _, raceInfo in ipairs(category.races) do
			if raceInfo.playable then
				table.insert(flat, raceInfo)
			end
		end
	end
	return flat
end

local function flattenTeams()
	local flat = {}
	for _, category in ipairs(TeamData) do
		for _, teamInfo in ipairs(category.teams) do
			table.insert(flat, teamInfo)
		end
	end
	return flat
end

local ALL_CLASSES = flattenClasses()
local ALL_RACES = flattenRaces()
local ALL_TEAMS = flattenTeams()

local function TabButton(props)
	local label = props.label
	local isActive = props.isActive
	local onClick = props.onClick

	return e("TextButton", {
		Size = UDim2.new(1 / 3, -2, 1, 0),
		BackgroundColor3 = isActive and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		TextColor3 = COLORS.TEXT,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Text = label,
		[React.Event.Activated] = onClick,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})
end

local function ItemButton(props)
	local label = props.label
	local isSelected = props.isSelected
	local onClick = props.onClick
	local color = props.color

	local isHovered, setIsHovered = React.useState(false)

	local bgColor = COLORS.BUTTON_DEFAULT
	if isSelected then
		bgColor = COLORS.BUTTON_SELECTED
	elseif isHovered then
		bgColor = COLORS.BUTTON_HOVER
	end

	return e("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = bgColor,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		TextColor3 = COLORS.TEXT,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		Text = label,
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
		end,
		[React.Event.Activated] = onClick,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		ColorIndicator = color and e("Frame", {
			Size = UDim2.new(0, 8, 0, 8),
			Position = UDim2.new(1, -16, 0.5, -4),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
		}),
	})
end

local function ClassTab(props)
	local selectedClass = props.selectedClass
	local onSelect = props.onSelect

	local children = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}

	for i, classInfo in ipairs(ALL_CLASSES) do
		children["Class_" .. i] = e(ItemButton, {
			label = classInfo.displayName,
			isSelected = classInfo.id == selectedClass,
			onClick = function()
				onSelect(classInfo.id)
			end,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.SCROLLBAR,
		CanvasSize = UDim2.new(0, 0, 0, #ALL_CLASSES * 36),
	}, children)
end

local function RaceTab(props)
	local selectedRace = props.selectedRace
	local onSelect = props.onSelect

	local children = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}

	for i, raceInfo in ipairs(ALL_RACES) do
		children["Race_" .. i] = e(ItemButton, {
			label = raceInfo.displayName or raceInfo.name,
			isSelected = raceInfo.id == selectedRace,
			onClick = function()
				onSelect(raceInfo.id)
			end,
			color = raceInfo.color,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.SCROLLBAR,
		CanvasSize = UDim2.new(0, 0, 0, #ALL_RACES * 36),
	}, children)
end

local function TeamTab(props)
	local selectedTeam = props.selectedTeam
	local onSelect = props.onSelect

	local children = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	}

	for i, teamInfo in ipairs(ALL_TEAMS) do
		children["Team_" .. i] = e(ItemButton, {
			label = teamInfo.name,
			isSelected = teamInfo.name == selectedTeam,
			onClick = function()
				onSelect(teamInfo.name)
			end,
			color = teamInfo.color,
		})
	end

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.SCROLLBAR,
		CanvasSize = UDim2.new(0, 0, 0, #ALL_TEAMS * 36),
	}, children)
end

local function DebugApp()
	local isVisible, setIsVisible = React.useState(true)
	local activeTab, setActiveTab = React.useState(1)
	local currentClass, setCurrentClass = React.useState(nil)
	local currentRace, setCurrentRace = React.useState(nil)
	local currentTeam, setCurrentTeam = React.useState(nil)

	local function onClassSelect(classId)
		setCurrentClass(classId)
		print("[DebugUI] Class changed to:", classId)
		local success = playerDataRemote:InvokeServer("setClass", { class = classId })
		if success then
			print("[DebugUI] Server confirmed class change")
		else
			warn("[DebugUI] Server rejected class change")
		end
	end

	local function onRaceSelect(raceId)
		setCurrentRace(raceId)
		print("[DebugUI] Race changed to:", raceId)
		local success = playerDataRemote:InvokeServer("setRace", { race = raceId })
		if success then
			print("[DebugUI] Server confirmed race change")
		else
			warn("[DebugUI] Server rejected race change")
		end
	end

	local function onTeamSelect(teamName)
		setCurrentTeam(teamName)
		print("[DebugUI] Team changed to:", teamName)
		local success = playerDataRemote:InvokeServer("setTeam", { team = teamName })
		if success then
			print("[DebugUI] Server confirmed team change")
		else
			warn("[DebugUI] Server rejected team change")
		end
	end

	return e("ScreenGui", {
		Name = "DebugUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, {
		ToggleButton = e("TextButton", {
			Size = UDim2.new(0, 100, 0, 28),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = COLORS.HEADER,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			TextColor3 = COLORS.TEXT,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			Text = isVisible and "Hide Debug" or "Show Debug",
			[React.Event.Activated] = function()
				setIsVisible(not isVisible)
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
		}),

		Panel = isVisible and e("Frame", {
			Size = UDim2.new(0, 220, 0, 350),
			Position = UDim2.new(0, 10, 0, 45),
			BackgroundColor3 = COLORS.BACKGROUND,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			Stroke = e("UIStroke", {
				Color = COLORS.HEADER,
				Thickness = 1,
			}),

			TabContainer = e("Frame", {
				Size = UDim2.new(1, -16, 0, 36),
				Position = UDim2.new(0, 8, 0, 8),
				BackgroundTransparency = 1,
			}, {
				Layout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				Tab1 = e(TabButton, {
					label = "Class",
					isActive = activeTab == 1,
					onClick = function()
						setActiveTab(1)
					end,
				}),
				Tab2 = e(TabButton, {
					label = "Race",
					isActive = activeTab == 2,
					onClick = function()
						setActiveTab(2)
					end,
				}),
				Tab3 = e(TabButton, {
					label = "Team",
					isActive = activeTab == 3,
					onClick = function()
						setActiveTab(3)
					end,
				}),
			}),

			ContentContainer = e("Frame", {
				Size = UDim2.new(1, -16, 1, -56),
				Position = UDim2.new(0, 8, 0, 48),
				BackgroundTransparency = 1,
			}, {
				ClassTab = activeTab == 1 and e(ClassTab, {
					selectedClass = currentClass,
					onSelect = onClassSelect,
				}),
				RaceTab = activeTab == 2 and e(RaceTab, {
					selectedRace = currentRace,
					onSelect = onRaceSelect,
				}),
				TeamTab = activeTab == 3 and e(TeamTab, {
					selectedTeam = currentTeam,
					onSelect = onTeamSelect,
				}),
			}),
		}),
	})
end

local DebugUI = {}

local root = nil

function DebugUI.mount()
	if root then
		return
	end

	local targetContainer = Instance.new("ScreenGui")
	targetContainer.Name = "DebugUIRoot"
	targetContainer.ResetOnSpawn = false
	targetContainer.IgnoreGuiInset = true
	targetContainer.Parent = playerGui

	root = ReactRoblox.createRoot(targetContainer)
	root:render(React.createElement(DebugApp))

	print("[DebugUI] Mounted")
end

function DebugUI.unmount()
	if root then
		root:unmount()
		root = nil
		print("[DebugUI] Unmounted")
	end
end

return DebugUI
