--[[

An object that contains an image.


- destroy -
Deletes the sprite.

CODE SAMPLE
sprite:destroy()


- onActivated -
Connects a function to be run when the sprite is clicked. Only works if interactable is set to true.

PARAMETERS
callback: function -- The callback to be run.

RETURNS
disconnect: function -- When run, the callback is disconnected.

CODE SAMPLE
local disconnect
disconnect = sprite.onActivated(function()
	print("Sprite activated!")
	disconnect()
end)


- onDestruction -
Connects a function to be run when the sprite is destroyed.

PARAMETERS
callback: function -- The callback to be run.

CODE SAMPLE
sprite.onDestruction(function()
	print("Sprite destroyed!")
end)


- hide -
Sets image transparency to 1.

PARAMETERS
fadeTime: number? -- The time it should take for the image to fade out.

CODE SAMPLE
sprite:hide(0.5)


- jump -
Bounces the sprite upwards.

CODE SAMPLE
sprite:jump()


- setImage -
Sets the current image.

PARAMETERS
imageName: string -- The name of the image to use.

CODE SAMPLE
sprite:setImage("carterAnnoyed")


- setPositionOffset -
Changes the positional offset of the sprite.

PARAMETERS
newOffset: UDim2 - The new positional offset.
tweenInfo: TweenInfo -- The TweenInfo to be used when tweening. If left blank, no tweening is performed.

CODE SAMPLE
sprite:setPositionOffset(UDim2.fromScale(0, -0.1), TweenInfo.new(0.3))


- setSizeOffset -
Changes the size offset of the sprite.

PARAMETERS
newOffset: UDim2 - The new size offset.
tweenInfo: TweenInfo -- The TweenInfo to be used when tweening. If left blank, no tweening is performed.

CODE SAMPLE
sprite:setSizeOffset(UDim2.fromOffset(50, 50), TweenInfo.new(0.3))


- shake -
Shakes the sprite left and right.

CODE SAMPLE
sprite:shake()


- reposition -
Repositions the sprite.

PARAMETERS
position: UDim2 -- The new position of the sprite.
tweenInfo: TweenInfo -- The TweenInfo to be used when tweening. If left blank, no tweening is performed.

CODE SAMPLE
sprite:reposition(UDim2.fromScale(0.8, 1), TweenInfo.new(0.3))


- resize -
Resizes the sprite.

PARAMETERS
size: UDim2 -- The new size of the sprite.
tweenInfo: TweenInfo -- The TweenInfo to be used when tweening. If left blank, no tweening is performed.

CODE SAMPLE
sprite:resize(UDim2.fromOffset(500, 600), TweenInfo.new(0.3))


- show -
Sets image transparency to 0.

PARAMETERS
fadeTime: number? -- The time it should take for the image to fade in.

CODE SAMPLE
sprite:show(0.5)


- tween -
Animates the sprite from its current properties to new properties specified by propertyTable.

PARAMETERS
propertyTable: {[string]: any}? -- A table of properties to tween. Index is the property name, value is the goal.
tweenInfo: TweenInfo? -- The TweenInfo to be used.

CODE SAMPLE
sprite:tween({Position = UDim2.fromScale(0.8, 1), Size = UDim2.fromOffset(500, 600)}, TweenInfo.new(0.3))

]]