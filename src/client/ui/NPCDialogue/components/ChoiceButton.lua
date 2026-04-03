local React = require(script.Parent.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("React"))
local constants = require(script.Parent.Parent.constants)

local e = React.createElement

local function ChoiceButton(props)
	local text = props.text
	local onClick = props.onClick
	local layoutOrder = props.layoutOrder

	local isHovered, setIsHovered = React.useState(false)

	local backgroundColor = isHovered and constants.BUTTON_HOVER_FILL or constants.BUTTON_DEFAULT_FILL
	local borderColor = isHovered and constants.BUTTON_HOVER_BORDER or constants.BUTTON_DEFAULT_BORDER
	local textColor = isHovered and constants.BUTTON_HOVER_TEXT or constants.BODY_TEXT_COLOR

	return e("TextButton", {
		Name = "ChoiceButton",
		Size = UDim2.new(0.95, 0, 0, constants.BUTTON_HEIGHT),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		TextColor3 = textColor,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		Text = text,
		LayoutOrder = layoutOrder,
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
		Stroke = e("UIStroke", {
			Color = borderColor,
			Thickness = 1,
			Transparency = 0,
		}),
	})
end

return ChoiceButton
