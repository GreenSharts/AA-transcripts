local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")

return function(button: TextButton | ImageButton)
	button.MouseButton1Down:Connect(function()
		sounds.sfx.gui.buttonDown:Play()
	end)

	button.MouseButton1Up:Connect(function()
		sounds.sfx.gui.buttonUp:Play()
	end)

	button.MouseEnter:Connect(function()
		sounds.sfx.gui.buttonHover:Play()
	end)
end
