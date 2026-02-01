local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")
local vnSystem = workspace:FindFirstChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local guiVariables = require(script.Parent.Parent.guiVariables)
local vnDebug = require(sharedFolder.vnDebug)
local spritesFrame = guiVariables.spritesFrame

local sprite = {}
sprite.__index = sprite

type self = {
	name: string,
	imageLabel: ImageLabel,
	originalPosition: UDim2,
	originalSize: UDim2,
	positionOffset: UDim2,
	sizeOffset: UDim2,
	allowAutoPosition: boolean,
	allowAutoEmphasize: boolean,
	destructionCallbacks: {() -> ()},
	activatedCallbacks: {() -> ()},
}
export type sprite = typeof(setmetatable({} :: self, sprite))

local function getImageLabelSource(spriteName: string): ImageLabel
	local imageLabelSource = vnSystem.images.sprites:FindFirstChild(spriteName)
	if imageLabelSource == nil then
		warn(`sprite "{spriteName}" does not exist. Double check your spelling.`)
		return vnSystem.images.sprites.ERROR_FALLBACK
	end
	if not imageLabelSource:IsA("ImageLabel") then
		warn(`Incorrect object type for sprite. Please only use ImageLabels for sprites.`)
		return vnSystem.images.sprites.ERROR_FALLBACK
	end
	
	return imageLabelSource
end

type spriteParams = {
	name: string, -- The name of the sprite.
	defaultImageName: string, -- The default image to use.
	defaultPosition: UDim2?, -- The default position.
	defaultSize: UDim2?, -- The default size.
	interactable: boolean?, -- Whether the sprite can be activated by clicking on it.
	allowAutoPosition: boolean?, -- Whether the sprite should be moved during auto positioning of new sprites. Defaults to true.
	allowAutoEmphasize: boolean?, -- Whether the sprite should be emphasized automatically when the subject of a dialog sequence matches the sprite name. Defaults to true.
}
function sprite.new(spriteParams: spriteParams): sprite
	vnDebug.print(`Creating sprite {spriteParams.name}`)
	
	local self = setmetatable({} :: self, sprite)
	
	local imageLabelSource = getImageLabelSource(spriteParams.defaultImageName)
	
	local imageLabel = imageLabelSource:Clone()
	imageLabel.Name = spriteParams.name
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.95)
	imageLabel.Position = spriteParams.defaultPosition or UDim2.fromScale(0.5, 1)
	if spriteParams.defaultSize ~= nil then
		imageLabel.Size = spriteParams.defaultSize
	end
	imageLabel.Parent = guiVariables.spritesFrame
	
	if configuration.sprites.emphasizeDarkens.Value == true then
		imageLabel.ImageColor3 = Color3.new(0.7, 0.7, 0.7)
	end
	
	if spriteParams.interactable == true then
		local button = Instance.new("TextButton")
		button.Text = ""
		button.BackgroundTransparency = 1
		button.Size = UDim2.fromScale(1, 1)
		button.Name = "InteractButton"
		button.Parent = imageLabel
		button.Activated:Connect(function()
			for _, callback in self.activatedCallbacks do
				task.spawn(callback)
			end
		end)
	end
	
	local allowAutoPosition = if spriteParams.allowAutoPosition == nil then true else spriteParams.allowAutoPosition
	local allowAutoEmphasize = if spriteParams.allowAutoEmphasize == nil then true else spriteParams.allowAutoEmphasize
	
	self.name = spriteParams.name
	self.imageLabel = imageLabel
	self.originalPosition = imageLabel.Position
	self.originalSize = imageLabel.Size
	self.positionOffset = UDim2.fromOffset()
	self.sizeOffset = UDim2.fromOffset()
	self.allowAutoPosition = allowAutoPosition
	self.allowAutoEmphasize = allowAutoEmphasize
	self.destructionCallbacks = {}
	self.activatedCallbacks = {}
	
	return self
end

-- Repositions the sprite.
function sprite.reposition(self: sprite, position: UDim2, tweenInfo: TweenInfo?)
	self.originalPosition = position
	if tweenInfo ~= nil then
		self:tween(nil, tweenInfo)
		task.wait(tweenInfo.Time)
	end
	self.imageLabel.Position = position + self.positionOffset
end

-- Resizes the sprite.
function sprite.resize(self: sprite, size: UDim2, tweenInfo: TweenInfo?)
	self.originalSize = size
	if tweenInfo ~= nil then
		self:tween(nil, tweenInfo)
		task.wait(tweenInfo.Time)
	end
	self.imageLabel.Size = size + self.sizeOffset
end

-- Animates the sprite from its current properties to new properties specified by propertyTable.
function sprite.tween(self: sprite, propertyTable: {[string]: any}?, tweenInfo: TweenInfo?)
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
	if propertyTable == nil then
		propertyTable = {}
		propertyTable.Size = self.originalSize
		propertyTable.Position = self.originalPosition
	end
	
	if propertyTable.Size ~= nil then
		self.originalSize = propertyTable.Size
		propertyTable.Size += self.sizeOffset
	end
	if propertyTable.Position ~= nil then
		self.originalPosition = propertyTable.Position
		propertyTable.Position += self.positionOffset
	end
	
	local tween = TweenService:Create(self.imageLabel, tweenInfo, propertyTable)
	tween:Play()
end

-- Sets image transparency to 1.
function sprite.hide(self: sprite, fadeTime: number?)
	if fadeTime ~= nil and fadeTime > 0 then
		self:tween({ImageTransparency = 1}, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear))
		task.wait(fadeTime)
	end
	self.imageLabel.ImageTransparency = 1
end

-- Sets image transparency to 0.
function sprite.show(self: sprite, fadeTime: number?)
	if fadeTime ~= nil and fadeTime > 0 then
		self:tween({ImageTransparency = 0}, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear))
		task.wait(fadeTime)
	end
	self.imageLabel.ImageTransparency = 0
end

-- Changes the positional offset of the sprite.
function sprite.setPositionOffset(self: sprite, newOffset: UDim2, tweenInfo: TweenInfo?)
	task.spawn(function()
		self.positionOffset = newOffset
		if tweenInfo ~= nil then
			self:tween(nil, tweenInfo)
			task.wait(tweenInfo.Time)
		end
		self.imageLabel.Position = self.originalPosition + self.positionOffset
	end)
end

-- Changes the size offset of the sprite.
function sprite.setSizeOffset(self: sprite, newOffset: UDim2, tweenInfo: TweenInfo?)
	task.spawn(function()
		self.sizeOffset = newOffset
		if tweenInfo ~= nil then
			self:tween(nil, tweenInfo)
			task.wait(tweenInfo.Time)
		end
		self.imageLabel.Size = self.originalSize + self.sizeOffset
	end)
end

-- Sets the current image.
function sprite.setImage(self: sprite, imageName: string)
	local imageLabelSource = getImageLabelSource(imageName)
	
	local imageLabel = self.imageLabel
	imageLabel.Image = imageLabelSource.Image
	imageLabel.Size = imageLabelSource.Size + self.sizeOffset
	
	for _,v in imageLabel:GetChildren() do
		v:Destroy()
	end
	for _,v in imageLabelSource:GetChildren() do
		v:Clone().Parent = imageLabel
	end
end

-- Connects a function to be run when the sprite is destroyed.
function sprite.onDestruction(self: sprite, callback: () -> ())
	table.insert(self.destructionCallbacks, callback)
end

-- Connects a function to be run when the sprite is clicked. Only works if interactable is set to true.
function sprite.onActivated(self: sprite, callback: () -> ())
	table.insert(self.activatedCallbacks, callback)
	return function()
		table.remove(self.activatedCallbacks, table.find(self.activatedCallbacks, callback))
	end
end

-- Deletes the sprite.
function sprite.destroy(self: sprite)
	for _,callback in self.destructionCallbacks do
		task.spawn(callback)
	end
	self.imageLabel:Destroy()
	self.Destroyed = true
	setmetatable(self, nil)
	table.freeze(self)
end

-- Shakes the sprite left and right.
function sprite.shake(self: sprite)
	task.spawn(function()
		self:setPositionOffset(UDim2.fromOffset(-16, 0), TweenInfo.new(0.03, Enum.EasingStyle.Linear))
		task.wait(0.03)
		self:setPositionOffset(UDim2.fromOffset(13, 0), TweenInfo.new(0.15, Enum.EasingStyle.Linear))
		task.wait(0.15)
		self:setPositionOffset(UDim2.fromOffset(-10, 0), TweenInfo.new(0.1, Enum.EasingStyle.Linear))
		task.wait(0.1)
		self:setPositionOffset(UDim2.fromOffset(7, 0), TweenInfo.new(0.07, Enum.EasingStyle.Linear))
		task.wait(0.07)
		self:setPositionOffset(UDim2.fromOffset(0, 0), TweenInfo.new(0.05, Enum.EasingStyle.Linear))
	end)
end

-- Bounces the sprite upwards.
function sprite.jump(self: sprite)
	-- If this isn't delayed slightly, the TweenInfo time gets replaced with 0.3, for some reason??
	task.delay(0.01, function()
		self:setPositionOffset(UDim2.fromOffset(0, -40), TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
		task.wait(0.12)
		self:setPositionOffset(UDim2.fromOffset(0, 0), TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In))
	end)
end

return sprite