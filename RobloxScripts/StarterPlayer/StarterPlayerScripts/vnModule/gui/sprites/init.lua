local sprite = require(script.sprite)

local DEFAULT_TWEEN_INFO = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local spriteLookup: {[string]: sprite.sprite} = {}
local emphasizedSprites: {sprite.sprite} = {}

local sprites = {}

local function getTotalSpriteCount()
	local count = 0
	for _,v in spriteLookup do
		count += 1
	end
	return count
end

-- Destroys all sprites onscreen.
function sprites.destroyAll()
	for _,v in spriteLookup do
		v:destroy()
	end
	spriteLookup = {}
end

-- De-emphasizes the current emphasized sprites.
function sprites.deemphasize()
	local shouldResize = configuration.sprites.emphasizeResizes.Value
	local shouldDarken = configuration.sprites.emphasizeDarkens.Value

	for _,sprite in emphasizedSprites do
		if sprite.Destroyed == true then
			continue
		end
		if shouldResize then
			sprite:setSizeOffset(UDim2.fromOffset(), DEFAULT_TWEEN_INFO)
		end
		if shouldDarken then
			sprite:tween({ImageColor3 = Color3.new(0.7, 0.7, 0.7)}, DEFAULT_TWEEN_INFO)
		end
		sprite.imageLabel.ZIndex = 1
	end

	emphasizedSprites = {}
end

-- Emphasizes the provided sprites.
function sprites.emphasize(spritesToEmphasize: {string})
	local shouldResize = configuration.sprites.emphasizeResizes.Value
	local shouldDarken = configuration.sprites.emphasizeDarkens.Value

	sprites.deemphasize()

	for _,spriteName in spritesToEmphasize do
		local sprite = spriteLookup[spriteName]
		if sprite == nil then
			warn(`Sprite "{spriteName}" does not exist`)
			continue
		end
		if shouldResize then
			sprite:setSizeOffset(UDim2.fromScale(sprite.originalSize.X.Scale*0.1, sprite.originalSize.Y.Scale*0.1), DEFAULT_TWEEN_INFO)
		end
		if shouldDarken then
			sprite:tween({ImageColor3 = Color3.new(1, 1, 1)}, DEFAULT_TWEEN_INFO)
		end
		sprite.imageLabel.ZIndex = 2
		table.insert(emphasizedSprites, sprite)
	end
end

-- Returns the sprite with the given name.
function sprites.get(spriteName: string): sprite.sprite?
	return spriteLookup[spriteName]
end

-- Automatically repositions all sprites with allowAutoPosition set to true.
function sprites.autoRepositionSprites(tweenTime: number?, spriteOrder: {string}?)
	if tweenTime == nil then
		tweenTime = DEFAULT_TWEEN_INFO.Time
	end

	local tweenInfo
	if tweenTime ~= nil and tweenTime > 0 then
		tweenInfo = TweenInfo.new(tweenTime, DEFAULT_TWEEN_INFO.EasingStyle, DEFAULT_TWEEN_INFO.EasingDirection)
	end

	local spriteCount = getTotalSpriteCount()

	local xScaleIncrement = 1 / (spriteCount+1)

	local spritesOrderedByXPosition: {sprite.sprite} = {}
	if spriteOrder ~= nil then
		for _, spriteName in spriteOrder do
			local sprite = spriteLookup[spriteName]
			if sprite ~= nil then
				table.insert(spritesOrderedByXPosition, sprite)
			end
		end
	else
		for _,sprite in spriteLookup do
			if sprite.allowAutoPosition == true then
				table.insert(spritesOrderedByXPosition, sprite)
			end
		end
		table.sort(spritesOrderedByXPosition, function(a, b)
			return a.imageLabel.AbsolutePosition.X < b.imageLabel.AbsolutePosition.X
		end)
	end

	local currentXScalePosition = 0
	for i=1, spriteCount do
		local sprite = spritesOrderedByXPosition[i]
		currentXScalePosition += xScaleIncrement
		task.spawn(function()
			sprite:reposition(UDim2.new(currentXScalePosition, 0, sprite.originalPosition.Y.Scale, sprite.originalPosition.Y.Offset), tweenInfo)
		end)
	end
end

-- Tweens the sprite offscreen and destroys it.
function sprites.exitStage(spriteName: string, transitionType: "slideLeft" | "slideRight" | "slideUp" | "slideDown" | "fade" | nil)
	local sprite = spriteLookup[spriteName]
	if sprite == nil then
		warn(`Sprite {spriteName} does not exist.`)
	end

	if transitionType == nil then
		transitionType = "fade"
	end

	task.spawn(function()
		if transitionType == "fade" then
			sprite:hide(0.5)
			task.wait(0.5)
		else
			local newPosition: UDim2 = sprite.originalPosition
			if transitionType == "slideLeft" then
				newPosition = UDim2.new(-1, newPosition.X.Offset, newPosition.Y.Scale, newPosition.Y.Offset)
			elseif transitionType == "slideRight" then
				newPosition = UDim2.new(2, newPosition.X.Offset, newPosition.Y.Scale, newPosition.Y.Offset)
			elseif transitionType == "slideUp" then
				newPosition = UDim2.new(newPosition.X.Scale, newPosition.X.Offset, -1, newPosition.Y.Offset)
			elseif transitionType == "slideDown" then
				newPosition = UDim2.new(newPosition.X.Scale, newPosition.X.Offset, 2, newPosition.Y.Offset)
			end
			sprite:tween(
				{Position = newPosition},
				TweenInfo.new(0.5, Enum.EasingStyle.Linear)
			)
			task.wait(0.5)
		end
		sprite:destroy()
		sprites.autoRepositionSprites()
	end)
end

export type createSpriteParams = {
	name: string, -- The name of the sprite.
	defaultImageName: string, -- The default sprite to use.
	defaultPosition: UDim2?, -- The default position. Takes priority over autoPosition.
	defaultSize: UDim2?, -- The default size.
	interactable: boolean?, -- Whether the sprite can be clicked to activate an event.
	allowAutoPosition: boolean?, -- Whether the sprite should be moved during auto positioning of new sprites. Defaults to true.
	allowAutoEmphasize: boolean?, -- Whether the sprite should be emphasized automatically when the subject of a dialog sequence matches the sprite name. Defaults to true.
	autoPosition: number?, -- Automatically shifts existing sprites to make room, then positions the new sprite to the left (-1), center (0), or right (1).
	tweenTime: number?, -- The time it takes for the tweens involved in the creation of this sprite. Defaults to DEFAULT_TWEEN_INFO.Time.
	transitionType: "slideFromLeft" | "slideFromRight" | "slideFromBottom" | "slideFromTop" | "fade" | nil, -- How the sprite should transition into appearing onscreen.
}
-- Creates a new sprite object.
function sprites.create(createSpriteParams: createSpriteParams): sprite.sprite
	if spriteLookup[createSpriteParams.name] ~= nil then
		error(`A sprite named "{createSpriteParams.name}" already exists. Please use a unique name.`)
	end

	local newSprite = sprite.new({
		name = createSpriteParams.name,
		defaultImageName = createSpriteParams.defaultImageName,
		defaultPosition = createSpriteParams.defaultPosition,
		defaultSize = createSpriteParams.defaultSize,
		interactable = createSpriteParams.interactable,
		allowAutoPosition = createSpriteParams.allowAutoPosition,
		allowAutoEmphasize = createSpriteParams.allowAutoEmphasize,
	})

	if createSpriteParams.tweenTime == nil then
		createSpriteParams.tweenTime = DEFAULT_TWEEN_INFO.Time
	end

	local tweenInfo
	if createSpriteParams.tweenTime > 0 then
		tweenInfo = TweenInfo.new(createSpriteParams.tweenTime, DEFAULT_TWEEN_INFO.EasingStyle, DEFAULT_TWEEN_INFO.EasingDirection)
	end

	local spriteCount = getTotalSpriteCount()
	if createSpriteParams.defaultPosition == nil and createSpriteParams.autoPosition ~= nil then
		local xScaleIncrement = 1 / (spriteCount+2)

		local spritesOrderedByXPosition: {sprite.sprite} = {}
		for _,sprite in spriteLookup do
			if sprite.allowAutoPosition == true then
				table.insert(spritesOrderedByXPosition, sprite)
			end
		end
		table.sort(spritesOrderedByXPosition, function(a, b)
			return a.imageLabel.AbsolutePosition.X < b.imageLabel.AbsolutePosition.X
		end)

		if createSpriteParams.autoPosition == -1 then
			-- Left
			local currentXScalePosition = xScaleIncrement
			for i=1, spriteCount do
				local sprite = spritesOrderedByXPosition[i]
				currentXScalePosition += xScaleIncrement
				task.spawn(function()
					sprite:reposition(UDim2.new(currentXScalePosition, 0, sprite.originalPosition.Y.Scale, sprite.originalPosition.Y.Offset), tweenInfo)
				end)
			end

			newSprite:reposition(UDim2.new(xScaleIncrement, newSprite.originalPosition.X.Offset, newSprite.originalPosition.Y.Scale, newSprite.originalPosition.Y.Offset))
		elseif createSpriteParams.autoPosition == 1 then
			-- Right
			local currentXScalePosition = 0
			for i=1, spriteCount do
				local sprite = spritesOrderedByXPosition[i]
				currentXScalePosition += xScaleIncrement
				task.spawn(function()
					sprite:reposition(UDim2.new(currentXScalePosition, 0, sprite.originalPosition.Y.Scale, sprite.originalPosition.Y.Offset), tweenInfo)
				end)
			end

			newSprite:reposition(UDim2.new(currentXScalePosition+xScaleIncrement, newSprite.originalPosition.X.Offset, newSprite.originalPosition.Y.Scale, newSprite.originalPosition.Y.Offset))
		elseif createSpriteParams.autoPosition == 0 then
			-- Center
			local center = math.floor(spriteCount / 2)
			local currentXScalePosition = 0
			local centerXScalePosition

			if spriteCount == 0 then
				centerXScalePosition = 0.5
			else
				for i=1, spriteCount do
					local sprite = spritesOrderedByXPosition[i]
					currentXScalePosition += xScaleIncrement
					if i == center then
						centerXScalePosition = currentXScalePosition
						currentXScalePosition += xScaleIncrement
					end
					task.spawn(function()
						sprite:reposition(UDim2.new(currentXScalePosition, 0, sprite.originalPosition.Y.Scale, sprite.originalPosition.Y.Offset), DEFAULT_TWEEN_INFO)
					end)
				end
			end

			newSprite:reposition(UDim2.new(centerXScalePosition, newSprite.originalPosition.X.Offset, newSprite.originalPosition.Y.Scale, newSprite.originalPosition.Y.Offset))
		end
	end

	if createSpriteParams.transitionType ~= nil then
		if createSpriteParams.transitionType == "fade" then
			newSprite:hide()
			newSprite:show(.3)
		else
			local function slideFrom(direction: Vector2)
				newSprite:setPositionOffset(UDim2.fromScale(direction.X, direction.Y))
				newSprite:setPositionOffset(UDim2.fromOffset(), tweenInfo)
			end
			if createSpriteParams.transitionType == "slideFromLeft" then
				slideFrom(Vector2.new(-1, 0))
			elseif createSpriteParams.transitionType == "slideFromRight" then
				slideFrom(Vector2.new(1, 0))
			elseif createSpriteParams.transitionType == "slideFromTop" then
				slideFrom(Vector2.new(0, -1))
			elseif createSpriteParams.transitionType == "slideFromBottom" then
				slideFrom(Vector2.new(0, 1))
			end
		end
	end

	local imageLabel = newSprite.imageLabel
	newSprite:onDestruction(function()
		spriteLookup[createSpriteParams.name] = nil
	end)
	spriteLookup[createSpriteParams.name] = newSprite

	return newSprite
end

return sprites