local React = require(script.Parent.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("React"))
local constants = require(script.Parent.Parent.constants)
local ChoiceButton = require(script.Parent.ChoiceButton)

local e = React.createElement

local ChoicesPanel = {}

function ChoicesPanel.Component(props)
	local options = props.options or {}
	local hasChoices = props.hasChoices
	local onChoiceSelected = props.onChoiceSelected
	local onClose = props.onClose

	local maxButtons = constants.MAX_CHOICES + 1
	local panelHeight = 22 + maxButtons * (constants.BUTTON_HEIGHT + constants.BUTTON_SPACING)

	local children = {
		Title = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "Choices:",
			TextColor3 = constants.SPEAKER_NAME_COLOR,
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			Stroke = e("UIStroke", {
				Color = constants.TEXT_STROKE_COLOR,
				Thickness = 3,
				Transparency = 0,
			}),
		}),

		QuitButton = e(ChoiceButton, {
			text = "Quit",
			onClick = onClose,
			layoutOrder = 100,
		}),
	}

	if hasChoices then
		for i, option in ipairs(options) do
			children["Choice_" .. i] = e(ChoiceButton, {
				text = option.text,
				onClick = function()
					onChoiceSelected(i)
				end,
				layoutOrder = i,
			})
		end
	end

	return e("Frame", {
		Name = "ChoicesBox",
		Size = UDim2.new(0, constants.CHOICES_WIDTH, 0, panelHeight),
		Position = UDim2.new(1, -constants.CHOICES_WIDTH - 20, 1, -50),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
	}, children)
end

return ChoicesPanel.Component
