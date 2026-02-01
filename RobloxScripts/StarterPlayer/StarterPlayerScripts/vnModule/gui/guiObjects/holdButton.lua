local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local theme = require(script.Parent.Parent.theme)
local setUpButtonSounds = require(script.Parent.Parent.Parent.util.setUpButtonSounds)

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")

local holdButton = {}

type props = {
	holdTime: number,
	callback: () -> (),
}
function holdButton.new(props: props)
	local textButton = Instance.new("TextButton")
	textButton.Name = "HoldButton"
	textButton.AnchorPoint = Vector2.new(0, 1)
	textButton.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	textButton.BackgroundTransparency = 0.5
	textButton.BorderColor3 = Color3.new(1, 1, 1)
	textButton.BorderSizePixel = 2
	textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton.RichText = true
	textButton.Selectable = false
	textButton.TextScaled = true
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.TextSize = 28
	theme.applyThemeToInstance(textButton)
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	fill.BorderSizePixel = 0
	fill.BackgroundTransparency = 0.6
	fill.Parent = textButton
	
	local holdThread: thread? = nil
	
	local function buttonUp()
		if holdThread ~= nil then
			task.cancel(holdThread)
			holdThread = nil
		end
		fill.Size = UDim2.fromScale(0, 1)
	end
	
	local function buttonDown()
		if holdThread ~= nil then
			return
		end
		holdThread = task.spawn(function()
			local heldTime = 0
			while heldTime < props.holdTime do
				heldTime += task.wait()
				fill.Size = UDim2.fromScale(math.min(heldTime/props.holdTime, 1), 1)
			end
			sounds.sfx.gui.buttonConfirm:Play()
			props.callback()
			fill.Size = UDim2.fromScale(0, 1)
			holdThread = nil
		end)
	end
	
	textButton.MouseButton1Down:Connect(buttonDown)
	textButton.MouseButton1Up:Connect(buttonUp)
	textButton.MouseLeave:Connect(buttonUp)
	
	setUpButtonSounds(textButton)
	
	return textButton
end

return holdButton