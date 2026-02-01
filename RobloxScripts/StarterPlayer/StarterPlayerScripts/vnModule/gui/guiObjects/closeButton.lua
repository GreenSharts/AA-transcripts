local setUpButtonSounds = require(script.Parent.Parent.Parent.util.setUpButtonSounds)

local currentMenu = require(script.Parent.Parent.currentMenu)

local closeButton = {}

function closeButton.new()
	local closeLabel = Instance.new("TextButton")
	closeLabel.Name = "Close"
	closeLabel.AnchorPoint = Vector2.new(1, 0)
	closeLabel.BackgroundTransparency = 1
	closeLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	closeLabel.Position = UDim2.fromScale(1, 0)
	closeLabel.Size = UDim2.fromOffset(50, 50)
	closeLabel.RichText = true
	closeLabel.Text = "<b>X</b>"
	closeLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	closeLabel.TextScaled = true
	
	setUpButtonSounds(closeLabel)

	closeLabel.MouseEnter:Connect(function()
		closeLabel.TextColor3 = Color3.new(0.7, 0, 0)
	end)
	
	closeLabel.MouseLeave:Connect(function()
		closeLabel.TextColor3 = Color3.new(1, 0, 0)
	end)
	
	closeLabel.MouseButton1Down:Connect(function()
		closeLabel.TextColor3 = Color3.new(0.6, 0, 0)
	end)
	
	closeLabel.MouseButton1Up:Connect(function()
		closeLabel.TextColor3 = Color3.new(1, 0, 0)
	end)

	closeLabel.Activated:Connect(function()
		currentMenu.set(nil)
	end)
	
	return closeLabel
end

return closeButton