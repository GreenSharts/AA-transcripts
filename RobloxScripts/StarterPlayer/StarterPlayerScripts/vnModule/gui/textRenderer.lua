local TextService = game:GetService("TextService")

local PAUSE_LENGTHS = {
	default = 0.06,
	shortPause = 0.3,
	longPause = 0.6,
}

local SHORT_PAUSE_CHARACTERS = {
	",",
	";",
}

local LONG_PAUSE_CHARACTERS = {
	".",
	"!",
	"?",
	":",
}

local PITCH_MIN = 0.9
local PITCH_MAX = 1.1

local gameState = require(script.Parent.Parent.gameState)
local input = require(script.Parent.Parent.input)

local vnSystem = workspace:WaitForChild("vnSystem")
local settingsFolder = vnSystem:WaitForChild("settings")

local rng = Random.new()

local textRenderer = {}

function textRenderer.renderText(textObject: TextLabel | TextButton | TextBox, text: string, scrollSpeed: number?, skippable: boolean?, append: boolean?, scrollSoundSet: Folder?, scrollCallback: ((textObject: TextLabel | TextButton | TextBox) -> ())?)
	local startingCharacterIndex: number
	if not append then
		textObject.Text = ""
		startingCharacterIndex = 1
	else
		startingCharacterIndex = string.len(textObject.Text)
	end
	textObject.MaxVisibleGraphemes = startingCharacterIndex
	task.wait() -- Fixes a weird bug with bold becoming italics and vice versa
	
	if scrollSpeed == nil then
		scrollSpeed = 1
	elseif scrollSpeed == -1 then
		-- show this text instantly
		textObject.Text = textObject.Text .. text
		textObject.MaxVisibleGraphemes = -1
		return
	end
	
	scrollSpeed = scrollSpeed * settingsFolder.visuals.scrollSpeed.Value
	
	textObject.Text = textObject.Text .. text
	
	local contentText = textObject.ContentText
	
	local scrollSounds: {Sound} = {}
	
	if scrollSoundSet ~= nil then
		for _,v in scrollSoundSet:GetChildren() do
			if v:IsA("Sound") then
				table.insert(scrollSounds, v)
			end
		end
	end
	
	if scrollCallback ~= nil then
		scrollCallback(textObject)
	end
	
	for i=startingCharacterIndex, string.len(contentText) do
		textObject.MaxVisibleGraphemes += 1
		
		local lastCharacter = string.sub(contentText, i, i)
		local visibleText = string.sub(contentText, 1, i)
		
		local pauseLength: number
		if table.find(SHORT_PAUSE_CHARACTERS, lastCharacter) then
			pauseLength = PAUSE_LENGTHS.shortPause
		elseif table.find(LONG_PAUSE_CHARACTERS, lastCharacter) then
			pauseLength = PAUSE_LENGTHS.longPause
		else
			pauseLength = PAUSE_LENGTHS.default
		end
		
		local availableSpace = textObject.AbsoluteSize + Vector2.new(1, 0)
		local uiPadding = textObject:FindFirstChildOfClass("UIPadding")
		if uiPadding ~= nil then
			availableSpace -= Vector2.new(
				uiPadding.PaddingLeft.Offset + uiPadding.PaddingRight.Offset,
				uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset
			)
			availableSpace -= Vector2.new(
				(uiPadding.PaddingLeft.Scale + uiPadding.PaddingRight.Scale) * textObject.AbsoluteSize.X,
				(uiPadding.PaddingTop.Scale + uiPadding.PaddingBottom.Scale) * textObject.AbsoluteSize.Y
			)
		end
		
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Font = textObject.FontFace
		getTextBoundsParams.RichText = textObject.RichText
		getTextBoundsParams.Size = textObject.TextSize
		getTextBoundsParams.Text = visibleText
		getTextBoundsParams.Width = availableSpace.X
		local spaceUsed = TextService:GetTextBoundsAsync(getTextBoundsParams)
		if spaceUsed.Y > availableSpace.Y then
			-- Find the last space or punctuation mark we've passed
			local newStartingPoint = i
			while newStartingPoint > 1 do
				newStartingPoint -= 1
				local character = string.sub(text, newStartingPoint, newStartingPoint)
				if character == " " or table.find(SHORT_PAUSE_CHARACTERS, character) or table.find(LONG_PAUSE_CHARACTERS, character) then
					newStartingPoint += 1
					break
				end
			end
			
			if gameState.get() ~= "playingDialog" then
				textObject.MaxVisibleGraphemes -= 1
				input.waitForAdvanceInput()
				gameState.set("playingDialog")
			end
			
			-- Clear text before that point to make space and restart rendering
			text = string.sub(contentText, newStartingPoint, -1)
			textObject.MaxVisibleGraphemes = 0
			textRenderer.renderText(textObject, text, scrollSpeed, scrollSoundSet, scrollCallback)
			
			break
		end
		
		if gameState.get() == "playingDialog" or skippable == false then
			if #scrollSounds > 0 then
				local scrollSound = scrollSounds[rng:NextInteger(1, #scrollSounds)]
				local clonedScrollSound = scrollSound:Clone()
				clonedScrollSound.PlaybackSpeed = rng:NextNumber(PITCH_MIN, PITCH_MAX)
				clonedScrollSound.PlayOnRemove = true
				clonedScrollSound.Parent = workspace
				clonedScrollSound:Destroy()
			end
			
			if scrollCallback ~= nil then
				scrollCallback(textObject)
			end
			task.wait(pauseLength/scrollSpeed)
		end
	end
	textObject.MaxVisibleGraphemes = -1
end

return textRenderer