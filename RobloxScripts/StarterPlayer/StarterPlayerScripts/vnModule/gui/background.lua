local TweenService = game:GetService("TweenService")

local guiVariables = require(script.Parent.guiVariables)
local backgroundLabel = guiVariables.background
local hardBackground = guiVariables.hardBackground
local storyFrame = guiVariables.storyFrame
local camera = require(script.Parent.camera)

local vnSystem = workspace:WaitForChild("vnSystem")

local currentBackground = nil
local is3DMode = false

local background = {}

function background.get()
	return currentBackground
end

function background.set(backgroundName: string, fadeTime: number?, cameraTransition: any?)
	-- Check if this is a 3D background (starts with "3d_" or is a camera name)
	if string.sub(backgroundName, 1, 3) == "3d_" or string.match(backgroundName, "^%d+$") then
		-- 3D background mode
		local cameraName = backgroundName
		if string.sub(backgroundName, 1, 3) == "3d_" then
			cameraName = string.sub(backgroundName, 4) -- Remove "3d_" prefix
		end

		-- Hide the 2D background
		if backgroundLabel then backgroundLabel.Visible = false end

		-- Also hide the hard background to show 3D view (Safety check added)
		if hardBackground then hardBackground.Visible = false end

		-- Make sure the story frame is visible for 3D view
		storyFrame.Visible = true
		storyFrame.BackgroundTransparency = 1

		-- Force game state to show story frame
		local gameState = require(script.Parent.gameState)
		gameState.set("idle")

		-- Set camera position
		local success = camera.setCamera(cameraName, cameraTransition)
		if success then
			currentBackground = backgroundName
			is3DMode = true
		end
		return
	end

	-- Regular 2D background mode
	if is3DMode then
		camera.disable3DMode()
		is3DMode = false
	end

	if backgroundLabel then backgroundLabel.Visible = true end
	if hardBackground then hardBackground.Visible = true end

	-- Make sure story frame is visible for 2D mode
	storyFrame.Visible = true
	storyFrame.BackgroundTransparency = 1

	local backgroundSource = vnSystem.images.backgrounds:FindFirstChild(backgroundName)
	if backgroundSource == nil then
		warn(`Background "{backgroundName}" does not exist. Double check your spelling.`)
		return
	end
	if not backgroundSource:IsA("ImageLabel") then
		warn(`Incorrect object type for background. Please only use ImageLabels for backgrounds.`)
		return
	end

	task.spawn(function()
		if fadeTime ~= nil and fadeTime > 0 and backgroundLabel then
			local tempBackground = backgroundLabel:Clone()
			tempBackground.ImageTransparency = 1
			tempBackground.ZIndex = backgroundLabel.ZIndex+1
			tempBackground.Image = backgroundSource.Image
			tempBackground.ImageColor3 = backgroundSource.ImageColor3
			tempBackground.Parent = backgroundLabel.Parent

			TweenService:Create(tempBackground, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {ImageTransparency = backgroundSource.ImageTransparency}):Play()
			task.wait(fadeTime)
			tempBackground:Destroy()
		end

		if backgroundLabel then
			backgroundLabel.Image = backgroundSource.Image
			backgroundLabel.ImageColor3 = backgroundSource.ImageColor3
			backgroundLabel.ImageTransparency = backgroundSource.ImageTransparency
		end

		currentBackground = backgroundName
	end)
end

-- [[ FIXED FUNCTION ]] --
-- Sets camera to a specific position (for 3D backgrounds)
function background.setCamera(cameraName: string, transitionInfo: any?): boolean
	local success = camera.setCamera(cameraName, transitionInfo)
	if success then
		-- CRITICAL FIX: We must update currentBackground so the Save System has something to save!
		currentBackground = "3d_" .. cameraName
		is3DMode = true

		-- Ensure 2D elements are hidden so we can see the 3D world
		if backgroundLabel then backgroundLabel.Visible = false end
		if hardBackground then hardBackground.Visible = false end
		storyFrame.BackgroundTransparency = 1
	end
	return success
end

-- Gets the current background name
function background.get()
	return currentBackground
end

-- Checks if currently in 3D mode
function background.is3DMode(): boolean
	return is3DMode
end

-- Disables 3D mode and returns to 2D
function background.disable3DMode()
	if is3DMode then
		camera.disable3DMode()
		is3DMode = false
		if backgroundLabel then backgroundLabel.Visible = true end
		if hardBackground then hardBackground.Visible = true end

		-- Make sure story frame is visible for 2D mode
		storyFrame.Visible = true
		storyFrame.BackgroundTransparency = 1
	end
end

return background