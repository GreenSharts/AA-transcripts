local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local theme = require(script.Parent.Parent.theme)
local setUpButtonSounds = require(script.Parent.Parent.Parent.util.setUpButtonSounds)

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")

local confirmationPrompt = {}

type props = {
	yesCallback: () -> (),
	noCallback: (() -> ())?,
}
function confirmationPrompt.new(props: props)
	local confirmationPromptFrame = Instance.new("Frame")
	confirmationPromptFrame.Name = "ConfirmationPrompt"
	confirmationPromptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	confirmationPromptFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	confirmationPromptFrame.BackgroundTransparency = 0.5
	confirmationPromptFrame.BorderColor3 = Color3.new(1, 1, 1)
	confirmationPromptFrame.BorderSizePixel = 2
	confirmationPromptFrame.Position = UDim2.fromScale(0.5, 0.5)
	confirmationPromptFrame.SelectionGroup = true
	confirmationPromptFrame.Size = UDim2.fromOffset(500, 120)
	confirmationPromptFrame.ZIndex = 3
	theme.applyThemeToInstance(confirmationPromptFrame)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textLabel.Position = UDim2.new(0.5, 0, 0, 10)
	textLabel.Size = UDim2.new(1, -20, 0, 60)
	textLabel.Text = ""
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextSize = 28
	textLabel.TextScaled = true
	textLabel.Parent = confirmationPromptFrame
	theme.applyThemeToInstance(textLabel)

	local yes = Instance.new("TextButton")
	yes.Name = "Yes"
	yes.AnchorPoint = Vector2.new(1, 1)
	yes.BackgroundTransparency = 0.5
	yes.BorderColor3 = Color3.new(1, 1, 1)
	yes.BorderSizePixel = 2
	yes.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	yes.LayoutOrder = 3
	yes.Position = UDim2.new(0.5, -10, 1, -10)
	yes.RichText = true
	yes.Selectable = false
	yes.Size = UDim2.new(0.4, 0, 0, 30)
	yes.Text = "Yes"
	yes.TextSize = 28
	yes.Parent = confirmationPromptFrame
	theme.applyThemeToInstance(yes)
	yes.TextColor3 = Color3.new(1, 1, 1)
	yes.BackgroundColor3 = Color3.fromRGB(0, 120, 0)

	local no = Instance.new("TextButton")
	no.Name = "No"
	no.AnchorPoint = Vector2.new(0, 1)
	no.BackgroundTransparency = 0.5
	no.BorderColor3 = Color3.new(1, 1, 1)
	no.BorderSizePixel = 2
	no.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	no.LayoutOrder = 3
	no.Position = UDim2.new(0.5, 10, 1, -10)
	no.RichText = true
	no.Selectable = false
	no.Size = UDim2.new(0.4, 0, 0, 30)
	no.Text = "No"
	no.TextSize = 28
	no.Parent = confirmationPromptFrame
	theme.applyThemeToInstance(no)
	no.TextColor3 = Color3.new(1, 1, 1)
	no.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

	yes.Activated:Connect(function()
		props.yesCallback()
		sounds.sfx.gui.buttonConfirm:Play()
		confirmationPromptFrame:Destroy()
	end)

	no.Activated:Connect(function()
		if props.noCallback ~= nil then
			props.noCallback()
		end
		confirmationPromptFrame:Destroy()
	end)

	setUpButtonSounds(yes)
	setUpButtonSounds(no)

	return confirmationPromptFrame
end

return confirmationPrompt