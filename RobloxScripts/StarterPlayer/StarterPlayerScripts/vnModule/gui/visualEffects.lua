local TweenService = game:GetService("TweenService")

local vnSystem = workspace:WaitForChild("vnSystem")
local images = vnSystem:WaitForChild("images")

local currentMenu = require("./currentMenu")

local guiVariables = require(script.Parent.guiVariables)
local dialogBox = guiVariables.dialogBox
local colorCover = guiVariables.colorCover
local imageCover = guiVariables.imageCover

local titleCardFrame = guiVariables.titleCardFrame
local titleCardBackground = titleCardFrame.Background
local titleLabel = titleCardFrame.Title
local storyOptionsFrame = guiVariables.storyOptionsFrame

local originalDialogBoxPosition: UDim2

local effectThreads: {[string]: thread?} = {}

local rng = Random.new()

local visualEffects = {}

-- Covers the screen with a solid color.
function visualEffects.addColorCover(color: Color3, fadeTime: number?)
	colorCover.BackgroundColor3 = color
	if fadeTime ~= nil and fadeTime > 0 then
		TweenService:Create(colorCover, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
	else
		colorCover.BackgroundTransparency = 0
	end
end

-- Removes the screen cover.
function visualEffects.removeColorCover(fadeTime: number?)
	if fadeTime ~= nil and fadeTime > 0 then
		TweenService:Create(colorCover, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	else
		colorCover.BackgroundTransparency = 1
	end
end

-- Covers the screen with an image.
function visualEffects.addImageCover(coverName: string, fadeTime: number?)
	local coverSource = images.covers:FindFirstChild(coverName)
	if coverSource == nil then
		warn(`Cover "{coverName}" does not exist. Double check your spelling.`)
		return
	end
	if not coverSource:IsA("ImageLabel") then
		warn(`Incorrect object type for image cover. Please only use ImageLabels for image covers.`)
		return
	end
	
	imageCover.Image = coverSource.Image
	if fadeTime ~= nil and fadeTime > 0 then
		TweenService:Create(imageCover, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
	else
		imageCover.ImageTransparency = 0
	end
end

-- Removes the screen cover.
function visualEffects.removeImageCover(fadeTime: number?)
	if fadeTime ~= nil and fadeTime > 0 then
		TweenService:Create(imageCover, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	else
		imageCover.ImageTransparency = 1
	end
end

-- Shakes the dialog box.
function visualEffects.shake(intensity: number, duration: number)
	if effectThreads.shake ~= nil then
		task.cancel(effectThreads.shake)
	end
	
	effectThreads.shake = task.spawn(function()
		local timeLeft = duration
		while timeLeft > 0 do
			local intensityPercentage = timeLeft/duration
			local currentIntensity = intensityPercentage*intensity
			dialogBox.Position = originalDialogBoxPosition + UDim2.fromOffset(rng:NextNumber(-intensity, intensity), rng:NextNumber(-intensity, intensity))
			timeLeft -= task.wait()
		end
		dialogBox.Position = originalDialogBoxPosition
		effectThreads.shake = nil
	end)
end

local titleCardBackgroundProperties: {[string]: any} = {}
local titleLabelProperties: {[string]: any} = {}

local titleCardFadeOutTweens: {Tween} = {}
local titleCardThread: thread? = nil

-- Displays a title card.
function visualEffects.titleCard(text: string, duration: number, fadeInTime: number?, fadeOutTime: number?)
	if fadeOutTime == nil then
		fadeOutTime = 0.5
	end
	if fadeInTime == nil then
		fadeInTime = 0
	end
	
	currentMenu.set(nil)
	
	titleLabel.Text = text
	
	for _,tween in titleCardFadeOutTweens do
		tween:Cancel()
	end
	if titleCardThread ~= nil then
		task.cancel(titleCardThread)
	end
	
	titleCardThread = task.spawn(function()
		storyOptionsFrame.Visible = false
		titleCardFrame.Visible = true
		
		if fadeInTime > 0 then
			local tweenInfo = TweenInfo.new(fadeInTime, Enum.EasingStyle.Linear)
			
			titleCardBackground.ImageTransparency = 1
			titleCardBackground.BackgroundTransparency = 1
			titleLabel.TextTransparency = 1
			titleLabel.TextStrokeTransparency = 1
			titleLabel.BackgroundTransparency = 1
			
			TweenService:Create(titleCardBackground, tweenInfo, titleCardBackgroundProperties):Play()
			TweenService:Create(titleLabel, tweenInfo, titleLabelProperties):Play()
			
			task.wait(fadeInTime)
		else
			for propertyName,value in titleCardBackgroundProperties do
				titleCardBackground[propertyName] = value
			end
			for propertyName,value in titleLabelProperties do
				titleLabel[propertyName] = value
			end
		end
		
		task.wait(duration - fadeInTime - fadeOutTime)
		
		if fadeOutTime > 0 then
			local tweenInfo = TweenInfo.new(fadeOutTime, Enum.EasingStyle.Linear)
			
			titleCardFadeOutTweens = {}
			titleCardFadeOutTweens[1] = TweenService:Create(titleCardBackground, tweenInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
			titleCardFadeOutTweens[2] = TweenService:Create(titleLabel, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1}):Play()
			task.wait(fadeOutTime)
			titleCardFadeOutTweens = {}
		end
		titleCardFrame.Visible = false
		storyOptionsFrame.Visible = true
		
		titleCardThread = nil
	end)
end

-- Stops and reverts all visual effects.
function visualEffects.stopAll()
	for _,thread in effectThreads do
		task.cancel(thread)
	end
	visualEffects.removeColorCover()
	visualEffects.removeImageCover()
	dialogBox.Position = originalDialogBoxPosition
end

function visualEffects.init()
	originalDialogBoxPosition = dialogBox.Position
	titleCardBackgroundProperties = {
		ImageTransparency = titleCardBackground.ImageTransparency,
		BackgroundTransparency = titleCardBackground.BackgroundTransparency,
	}
	titleLabelProperties = {
		TextTransparency = titleLabel.TextTransparency,
		TextStrokeTransparency = titleLabel.TextStrokeTransparency,
		BackgroundTransparency = titleLabel.BackgroundTransparency,
	}
end

return visualEffects