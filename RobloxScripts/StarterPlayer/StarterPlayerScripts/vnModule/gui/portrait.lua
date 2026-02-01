local guiVariables = require("./guiVariables")

local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local portraitLabel = guiVariables.portraitLabel
local dialogLabel = guiVariables.dialogLabel

local portrait = {}

function portrait.set(newPortraitName: string?)
	if newPortraitName ~= nil then
		local sourceLabel = vnSystem.images.portraits:FindFirstChild(newPortraitName)
		if sourceLabel == nil then
			warn(`Portrait "{newPortraitName}" does not exist. Double check your spelling.`)
			return
		end
		
		portraitLabel.Image = sourceLabel.Image
		portraitLabel.ScaleType = sourceLabel.ScaleType
		portraitLabel.Visible = true
		
		if configuration.features.useNVL.Value then
			dialogLabel.Size = UDim2.new(1, -portraitLabel.AbsoluteSize.X-150, 1, -130)
		else
			dialogLabel.Size = UDim2.new(1, -portraitLabel.AbsoluteSize.X-10, 1, 0)
		end
	else
		portraitLabel.Visible = false
		
		if configuration.features.useNVL.Value then
			dialogLabel.Size = UDim2.new(1, -150, 1, -130)
		else
			dialogLabel.Size = UDim2.fromScale(1, 1)
		end
	end
end

return portrait