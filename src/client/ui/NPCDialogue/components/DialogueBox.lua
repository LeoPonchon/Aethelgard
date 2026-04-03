local TextService = game:GetService("TextService")

local React = require(script.Parent.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("React"))
local constants = require(script.Parent.Parent.constants)

local e = React.createElement

local function DialogueBox(props)
	local npcName = props.npcName or "NPC"
	local faction = props.faction or ""
	local message = props.message or ""

	local titleHeight = 25
	local factionHeight = faction ~= "" and 20 or 0
	local titleSpacing = faction ~= "" and 8 or 0
	local baseHeight = titleHeight + factionHeight + titleSpacing + 10

	local availableWidth = constants.DIALOGUE_WIDTH
	local textSize = TextService:GetTextSize(message, 18, Enum.Font.Gotham, Vector2.new(availableWidth, 1000))
	local messageHeight = textSize.Y + 10

	local padding = 20
	local dialogueBoxHeight = baseHeight + messageHeight + padding

	local children = {
		Title = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, titleHeight),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = npcName,
			TextColor3 = constants.SPEAKER_NAME_COLOR,
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = constants.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),

		Message = e("TextLabel", {
			Size = UDim2.new(0.95, 0, 0, messageHeight),
			Position = UDim2.new(0.025, 0, 0, baseHeight),
			BackgroundTransparency = 1,
			Text = message,
			TextColor3 = constants.BODY_TEXT_COLOR,
			TextSize = 18,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
		}, {
			Stroke = e("UIStroke", {
				Color = constants.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),
	}

	if faction ~= "" then
		children.Faction = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, factionHeight),
			Position = UDim2.new(0, 0, 0, titleHeight + titleSpacing),
			BackgroundTransparency = 1,
			Text = faction,
			TextColor3 = constants.FACTION_LABEL_COLOR,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = constants.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		})
	end

	return e("Frame", {
		Name = "DialogueBox",
		Size = UDim2.new(0, availableWidth + 40, 0, dialogueBoxHeight),
		Position = UDim2.new(0.5, -(availableWidth + 40) / 2, 1, -30),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
	}, children)
end

return DialogueBox
