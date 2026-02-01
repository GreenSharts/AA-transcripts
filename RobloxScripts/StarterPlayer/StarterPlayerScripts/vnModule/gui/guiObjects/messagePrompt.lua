local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local theme = require(script.Parent.Parent.theme)
local setUpButtonSounds = require(script.Parent.Parent.Parent.util.setUpButtonSounds)

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")

local message = {}

type props = {
	text: string,
}
function message.new(props: props)
	local messageFrame = Instance.new("Frame")
	messageFrame.Name = "Message"
	messageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	messageFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	messageFrame.BackgroundTransparency = 0.5
	messageFrame.BorderColor3 = Color3.new(1, 1, 1)
	messageFrame.BorderSizePixel = 2
	messageFrame.Position = UDim2.fromScale(0.5, 0.5)
	messageFrame.SelectionGroup = true
	messageFrame.Size = UDim2.fromOffset(500, 120)
	messageFrame.ZIndex = 3
	theme.applyThemeToInstance(messageFrame)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textLabel.Position = UDim2.new(0.5, 0, 0, 10)
	textLabel.Size = UDim2.new(1, -20, 0, 60)
	textLabel.Text = props.text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextSize = 28
	textLabel.TextWrapped = true
	textLabel.Parent = messageFrame
	theme.applyThemeToInstance(messageFrame)

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(0.5, 1)
	close.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	close.BackgroundTransparency = 0.5
	close.BorderColor3 = Color3.new(1, 1, 1)
	close.BorderSizePixel = 2
	close.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	close.LayoutOrder = 3
	close.Position = UDim2.new(0.5, 0, 1, -10)
	close.RichText = true
	close.Selectable = false
	close.Size = UDim2.new(0.4, 0, 0, 30)
	close.Text = "OK"
	close.TextColor3 = Color3.new(1, 1, 1)
	close.TextSize = 28
	close.Parent = messageFrame
	theme.applyThemeToInstance(messageFrame)
	
	close.Activated:Connect(function()
		sounds.sfx.gui.buttonConfirm:Play()
		messageFrame:Destroy()
	end)
	
	setUpButtonSounds(close)

	return messageFrame
end

return message