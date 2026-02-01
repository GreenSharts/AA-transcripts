local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")
local configuration = vnSystem:WaitForChild("configuration")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")
local remotes = ReplicatedStorage:WaitForChild("remotes")

local localPlayer = Players.LocalPlayer

-- GUI Variables
local guiVariables = require(script.gui.guiVariables)
local storyFrame = guiVariables.storyFrame
local vnGui = guiVariables.vnGui
local dialogBox = guiVariables.dialogBox
local dialogLabel = guiVariables.dialogLabel
local subjectFrame = guiVariables.subjectFrame
local subjectLabel = guiVariables.subjectLabel
local advanceInputIndicator = guiVariables.advanceInputIndicator
local storyOptionsFrame = guiVariables.storyOptionsFrame
local spritesFrame = guiVariables.spritesFrame
local autoButton = guiVariables.autoButton
local menuFrame = guiVariables.menuFrame
local settingsFrame = guiVariables.settingsFrame
local newGameButton = guiVariables.newGameButton
local continueGameButton = guiVariables.continueGameButton
local chapterSelectButton = guiVariables.chapterSelectButton
local menuSettingsButton = guiVariables.menuSettingsButton
local chapterSelectFrame = guiVariables.chapterSelectFrame
local savesFrame = guiVariables.savesFrame
local savePageFrames = guiVariables.savePageFrames
local savePageNavigator = guiVariables.savePageNavigator
local choicesFrame = guiVariables.choicesFrame
local choiceButtonSource = choicesFrame.UIListLayout.ChoiceButtonSource
local textInputBox = guiVariables.textInputBox

local originalSubjectFrameSize = subjectFrame.Size

local input = require(script.input)
local storyVariables = require(script.storyVariables)
local gameState = require(script.gameState)
local vnDebug = require(sharedFolder.vnDebug)

-- Sub-Modules
local guiModule = require(script.gui)
local theme = require(script.gui.theme)
local textRenderer = require(script.gui.textRenderer)
local background = require(script.gui.background)
local camera = require(script.gui.camera)
local sprites = require(script.gui.sprites)
local portrait = require(script.gui.portrait)
local messagePrompts = require(script.gui.messagePrompts)
local visualEffects = require(script.gui.visualEffects)
local currentMenu = require(script.gui.currentMenu)
local savesGui = require(script.gui.savesGui)

-- Evidence Module
local evidence = require(script.evidence)

local assetPreloader = require(script.assetPreloader)
local sound = require(script.sound)
local sharedVariables = require(script.sharedVariables)
local playerData = require(script.playerData)
local story = require(script.story)
local storySaves = require(script.storySaves)
local chapterUnlocking = require(script.chapterUnlocking)
local roaming = require(script.roaming)

local confirmationPrompt = require(script.gui.guiObjects.confirmationPrompt)

local chosenChoice = nil

local scheduledCues: {[string]: {() -> ()}} = {}
local scrollSoundSetLinks: {[string]: string} = {}
local portraitLinks: {[string]: string} = {}

local vnModule = {}

local setUpButtonSounds = require(script.util.setUpButtonSounds)

type dialogParams = {
	subject: string?,
	spriteToEmphasize: string?,
	portrait: string?,
	dialog: string,
	append: boolean?,
	scrollSpeed: number?,
	scrollSoundSetName: Folder?,
	waitForAdvanceInput: boolean?,
	skippable: boolean?,
}

-- Displays dialog.
function vnModule.dialog(dialogParams: dialogParams)
	assert(dialogParams.dialog, "Dialog must be specified")

	vnDebug.print(`Playing dialog: {dialogParams.dialog}`)

	gameState.set("playingDialog")

	dialogBox.Visible = true

	local subject = dialogParams.subject
	if subject ~= nil then
		subjectLabel.Text = subject

		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Font = subjectLabel.FontFace
		getTextBoundsParams.RichText = subjectLabel.RichText
		getTextBoundsParams.Size = subjectLabel.TextSize
		getTextBoundsParams.Text = subject
		getTextBoundsParams.Width = 9999999999
		local spaceUsed = TextService:GetTextBoundsAsync(getTextBoundsParams)
		if spaceUsed.X+20 > originalSubjectFrameSize.X.Offset then
			subjectFrame.Size = UDim2.new(
				0,
				spaceUsed.X + 20,
				originalSubjectFrameSize.Y.Scale,
				originalSubjectFrameSize.Y.Offset
			)
		else
			subjectFrame.Size = originalSubjectFrameSize
		end

		subjectFrame.Visible = true
	else
		subjectFrame.Visible = false
	end

	local spriteToEmphasize = dialogParams.spriteToEmphasize
	local emphasized = false
	if spriteToEmphasize == "none" then
		-- Do nothing
	elseif spriteToEmphasize ~= nil then
		sprites.emphasize({spriteToEmphasize})
		emphasized = true
	else
		spriteToEmphasize = subject
		if spriteToEmphasize ~= nil then
			local sprite = sprites.get(spriteToEmphasize)
			if sprite ~= nil and sprite.allowAutoEmphasize == true then
				sprites.emphasize({spriteToEmphasize})
				emphasized = true
			end
		end
	end
	if emphasized == false and spriteToEmphasize ~= "none" then
		sprites.deemphasize()
	end

	if dialogParams.scrollSoundSetName == nil then
		if subject ~= nil and scrollSoundSetLinks[subject] ~= nil then
			dialogParams.scrollSoundSetName = scrollSoundSetLinks[subject]
		else
			dialogParams.scrollSoundSetName = "default"
		end
	end
	local scrollSoundSet
	if dialogParams.scrollSoundSetName ~= nil and dialogParams.scrollSoundSetName ~= "none" then
		scrollSoundSet = vnSystem.sounds.sfx.scrollSounds:FindFirstChild(dialogParams.scrollSoundSetName)
		if scrollSoundSet == nil then
			warn(`Scroll sound pack "{dialogParams.scrollSoundSetName}" does not exist. Double check your spelling.`)
		end
	end

	if dialogParams.portrait ~= nil then
		portrait.set(dialogParams.portrait)
	elseif subject ~= nil and portraitLinks[subject] ~= nil then
		portrait.set(portraitLinks[subject])
	else
		portrait.set(nil)
	end

	local function checkForCue(textObject: TextLabel | TextButton | TextBox)
		local startPosition = textObject.MaxVisibleGraphemes
		local endPosition = startPosition
		local exactMatch = nil
		local noMatches = false
		local pattern: string
		repeat
			pattern = string.sub(textObject.ContentText, startPosition, endPosition)
			noMatches = true
			for cue,_ in scheduledCues do
				if pattern == cue then
					exactMatch = cue
					noMatches = false
					break
				elseif string.sub(cue, 1, string.len(pattern)) == pattern then
					noMatches = false
					break
				end
			end
			endPosition += 1
		until exactMatch ~= nil or noMatches == true or endPosition > string.len(textObject.ContentText)

		if exactMatch then
			local callbackQueue = scheduledCues[exactMatch]
			vnDebug.print(`Playing cue "{exactMatch}" for function: {tostring(callbackQueue[1])}`)
			task.spawn(callbackQueue[1])

			table.remove(callbackQueue, 1)

			if #callbackQueue == 0 then
				scheduledCues[exactMatch] = nil
			end
		end
	end

	textRenderer.renderText(dialogLabel, dialogParams.dialog, dialogParams.scrollSpeed, dialogParams.skippable, dialogParams.append, scrollSoundSet, checkForCue)

	scheduledCues = {}

	if dialogParams.waitForAdvanceInput == false then
		if gameState.get() == "idle" then
			task.wait(1.5)
		else
			gameState.set("idle")
		end
	else
		vnModule.waitForAdvanceInput()
	end
end

type linkSubjectToScrollSoundSetParams = {
	subject: string,
	scrollSoundSetName: string?,
}
function vnModule.linkSubjectToScrollSoundSet(linkSubjectToScrollSoundSetParams: linkSubjectToScrollSoundSetParams)
	local subject, scrollSoundSetName = linkSubjectToScrollSoundSetParams.subject, linkSubjectToScrollSoundSetParams.scrollSoundSetName

	if scrollSoundSetName ~= nil then
		local scrollSoundSet = vnSystem.sounds.sfx.scrollSounds:FindFirstChild(scrollSoundSetName)
		if scrollSoundSet == nil then
			warn(`Scroll sound set "{scrollSoundSetName}" does not exist. Double check your spelling.`)
			return
		end
	end

	scrollSoundSetLinks[subject] = scrollSoundSetName
end

type linkSubjectToPortraitParams = {
	subject: string,
	portraitName: string?,
}
function vnModule.linkSubjectToPortrait(linkSubjectToPortraitParams: linkSubjectToPortraitParams)
	local subject, portraitName = linkSubjectToPortraitParams.subject, linkSubjectToPortraitParams.portraitName

	if portraitName ~= nil then
		local portraitSource = vnSystem.images.portraits:FindFirstChild(portraitName)
		if portraitSource == nil then
			warn(`Portrait "{portraitName}" does not exist. Double check your spelling.`)
			return
		end
	end

	portraitLinks[subject] = portraitName
end

function vnModule.deemphasize()
	sprites.deemphasize()
end

function vnModule.emphasize(spritesToEmphasize: {string})
	sprites.emphasize(spritesToEmphasize)
end

function vnModule.destroyAllSprites()
	sprites.destroyAll()
end

function vnModule.hideDialogBox()
	dialogBox.Visible = false
end

function vnModule.hideSpritesFrame()
	spritesFrame.Visible = false
end

function vnModule.showSpritesFrame()
	spritesFrame.Visible = true
end

function vnModule.scheduleCue(cue: string, callback: () -> ())
	local queue = scheduledCues[cue]
	if queue == nil then
		queue = {}
		scheduledCues[cue] = queue
	end
	table.insert(queue, callback)
end

type promptChoiceParams = {
	choices: {string},
	choicesUnlocked: {boolean}?,
	lockedTexts: {string}?,
	variableName: string?
}
function vnModule.promptChoice(promptChoiceParams: promptChoiceParams): number
	local success = gameState.set("waitingForChoice")
	if not success then
		return
	end
	chosenChoice = nil

	choicesFrame.Visible = true

	for _,v in choicesFrame:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	local choicesUnlocked, lockedTexts, choiceTexts = promptChoiceParams.choicesUnlocked, promptChoiceParams.lockedTexts, promptChoiceParams.choices
	for i=1,#choiceTexts do

		local choiceButton = choiceButtonSource:Clone()
		choiceButton.Name = `Choice{i}`
		choiceButton.LayoutOrder = i
		choiceButton.Parent = choicesFrame

		local choiceText
		if choicesUnlocked == nil or choicesUnlocked[i] ~= false then
			choiceText = choiceTexts[i]
			setUpButtonSounds(choiceButton)
			choiceButton.Activated:Connect(function()
				if chosenChoice ~= nil then
					return
				end
				chosenChoice = i
				sounds.sfx.gui.buttonConfirm:Play()
			end)
		else
			if lockedTexts ~= nil and lockedTexts[i] ~= nil then
				choiceText = lockedTexts[i]
			else
				choiceText = "[LOCKED]"
			end
			choiceButton.TextTransparency = 0.5
			choiceButton.AutoButtonColor = false
		end

		choiceButton.Text = choiceText

		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Font = choiceButton.FontFace
		getTextBoundsParams.RichText = choiceButton.RichText
		getTextBoundsParams.Size = choiceButton.TextSize
		getTextBoundsParams.Text = choiceText
		getTextBoundsParams.Width = choiceButton.AbsoluteSize.X
		local spaceUsed = TextService:GetTextBoundsAsync(getTextBoundsParams)
		if spaceUsed.Y + 6 > choiceButton.AbsoluteSize.Y then
			choiceButton.Size = UDim2.new(choiceButton.Size.X.Scale, choiceButton.Size.X.Offset, 0, spaceUsed.Y + 6)
		end
	end

	repeat task.wait()
	until chosenChoice ~= nil or gameState.get() ~= "waitingForChoice"

	choicesFrame.Visible = false

	gameState.set("idle")

	if promptChoiceParams.variableName ~= nil then
		storyVariables.set(promptChoiceParams.variableName, chosenChoice)
	end

	vnDebug.print(`Choice selected: {chosenChoice} ({promptChoiceParams.choices[chosenChoice]})`)

	return chosenChoice
end

function vnModule.forceChoice(choice: number)
	if gameState.get() == "waitingForChoice" then
		chosenChoice = choice
	end
end

type promptTextInputParams = {
	placeholderText: string?,
	maxCharacters: number?,
	variableName: string?,
}
function vnModule.promptTextInput(promptTextInputParams: promptTextInputParams): string
	local success = gameState.set("waitingForTextInput")
	if not success then
		return
	end

	local placeholderText, maxCharacters, variableName = promptTextInputParams.placeholderText, promptTextInputParams.maxCharacters, promptTextInputParams.variableName

	if maxCharacters ~= nil and maxCharacters < 1 then
		warn(`maxCharacters cannot be lower than 1.`)
		return
	end

	if maxCharacters == nil then
		maxCharacters = 20
	end

	textInputBox.PlaceholderText = placeholderText or ""
	textInputBox.Text = ""
	textInputBox.Visible = true
	textInputBox:CaptureFocus()

	local connections: RBXScriptConnection = {}

	table.insert(connections, textInputBox:GetPropertyChangedSignal("Text"):Connect(function()
		if string.len(textInputBox.Text) > maxCharacters then
			textInputBox.Text = string.sub(textInputBox.Text, 1, maxCharacters)
		end
	end))

	local textInputResult: string?
	table.insert(connections, textInputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and string.len(textInputBox.Text) > 0 then
			textInputResult = textInputBox.Text
		end
	end))

	repeat task.wait()
	until textInputResult ~= nil or gameState.get() ~= "waitingForTextInput"

	if variableName ~= nil then
		textInputBox.TextEditable = false
		textInputBox.Text = ""
		textInputBox.PlaceholderText = "Filtering..."

		local success, filteredText = remotes.filterInput:InvokeServer(textInputResult)
		textInputResult = filteredText

		textInputBox.TextEditable = true
		if not success or string.match(filteredText, "^[#%s]+$") then
			if success then
				textInputBox.PlaceholderText = "Text was censored. Try a different input."
			else
				textInputBox.PlaceholderText = "Failed to filter text."
			end
			gameState.set("idle")
			promptTextInputParams.placeholderText = textInputBox.PlaceholderText
			return vnModule.promptTextInput(promptTextInputParams)
		else
			storyVariables.set(variableName, filteredText)
		end
	end

	textInputBox.Visible = false
	gameState.set("idle")
	return textInputResult
end

function vnModule.waitForAdvanceInput()
	input.waitForAdvanceInput()
end

function vnModule.createSprite(createSpriteParams: sprites.createSpriteParams)
	return sprites.create(createSpriteParams)
end

type autoRepositionSpritesParams = {
	tweenTime: number?,
	spriteOrder: {string}?,
}
function vnModule.autoRepositionSprites(autoRepositionSpritesParams: autoRepositionSpritesParams)
	sprites.autoRepositionSprites(autoRepositionSpritesParams.tweenTime, autoRepositionSpritesParams.spriteOrder)
end

type exitStageParams = {
	spriteName: string,
	transitionType: "slideLeft" | "slideRight" | "slideUp" | "slideDown" | "fade" | nil
}
function vnModule.exitStage(exitStageParams: exitStageParams)
	sprites.exitStage(exitStageParams.spriteName, exitStageParams.transitionType)
end

type playSoundParams = {
	soundPath: string,
	track: number?,
	fade: boolean?
}
function vnModule.playSound(playSoundParams: playSoundParams)
	return sound.play(playSoundParams.soundPath, playSoundParams.track, playSoundParams.fade)
end

type stopAudioTrackParams = {
	track: number,
	fade: boolean?
}
function vnModule.stopAudioTrack(stopAudioTrackParams: stopAudioTrackParams)
	return sound.stopTrack(stopAudioTrackParams.track, stopAudioTrackParams.fade)
end

type backgroundParams = {
	backgroundName: string,
	fadeTime: number?,
}
function vnModule.setBackground(backgroundParams: backgroundParams)
	background.set(backgroundParams.backgroundName, backgroundParams.fadeTime, backgroundParams.cameraTransition)
end

type setCameraParams = {
	cameraName: string,
	transitionInfo: any?,
}
function vnModule.setCamera(setCameraParams: setCameraParams): boolean
	return background.setCamera(setCameraParams.cameraName, setCameraParams.transitionInfo)
end

function vnModule.disable3DMode()
	background.disable3DMode()
end

function vnModule.is3DMode(): boolean
	return background.is3DMode()
end

function vnModule.getGameState()
	return gameState.get()
end

type setStoryVariable = {
	name: string,
	data: string | number | boolean,
}
function vnModule.setStoryVariable(setStoryVariable: setStoryVariable)
	return storyVariables.set(setStoryVariable.name, setStoryVariable.data)
end

function vnModule.getStoryVariable(variableName: string)
	return storyVariables.get(variableName)
end

type registerSceneParams = {
	sceneName: string,
	sceneFunction: () -> (),
}
function vnModule.registerScene(registerSceneParams: registerSceneParams)
	story.registerScene(registerSceneParams.sceneName, registerSceneParams.sceneFunction)
end

type registerChapterParams = {
	chapterIndex: number,
	chapterName: string,
	scenes: {string},
	nextChapterIndex: number?,
}
function vnModule.registerChapter(registerChapterParams: registerChapterParams)
	story.registerChapter(registerChapterParams.chapterIndex, registerChapterParams.chapterName, registerChapterParams.scenes, registerChapterParams.nextChapterIndex)
end

function vnModule.unlockChapter(chapterIndex: number)
	chapterUnlocking.unlockChapter(chapterIndex)
end

function vnModule.playChapter(chapterIndex: number)
	story.playChapter(chapterIndex)
end

type addColorCoverParams = {
	color: Color3,
	fadeTime: number?,
}
function vnModule.addColorCover(addColorCoverParams: addColorCoverParams)
	visualEffects.addColorCover(addColorCoverParams.color, addColorCoverParams.fadeTime)
end

function vnModule.removeColorCover(fadeTime: number?)
	visualEffects.removeColorCover(fadeTime)
end

type addImageCoverParams = {
	coverName: string,
	fadeTime: number?,
}
function vnModule.addImageCover(addImageCoverParams: addImageCoverParams)
	visualEffects.addImageCover(addImageCoverParams.coverName, addImageCoverParams.fadeTime)
end

function vnModule.removeImageCover(fadeTime: number?)
	visualEffects.removeImageCover(fadeTime)
end

type shakeParams = {
	intensity: number,
	duration: number,
}
function vnModule.shake(shakeParams: shakeParams)
	visualEffects.shake(shakeParams.intensity, shakeParams.duration)
end

type titleCardParams = {
	text: string,
	duration: number,
	fadeInTime: number?,
	fadeOutTime: number?,
}
function vnModule.titleCard(titleCardParams: titleCardParams)
	visualEffects.titleCard(titleCardParams.text, titleCardParams.duration, titleCardParams.fadeInTime, titleCardParams.fadeOutTime)
end

local stateBeforeRoaming: gameState = nil

function vnModule.enterRoaming()
	roaming.enable()
end

function vnModule.exitRoaming()
	roaming.disable()
end

function vnModule.inRoamingMode()
	return roaming.inRoamingMode()
end

function vnModule.logStoryConnection(connection: RBXScriptConnection)
	story.logStoryConnection(connection)
end

-- ==========================================
-- [[ NEW: EVIDENCE FUNCTIONS ]]
-- ==========================================

type evidenceParams = {
	id: string,
}
function vnModule.addEvidence(params: evidenceParams)
	evidence.add(params.id)
end

function vnModule.removeEvidence(params: evidenceParams)
	evidence.remove(params.id)
end

-- [[ FIXED PROMPT EVIDENCE: NAMED OBJECT METHOD ]] --
function vnModule.promptEvidence()
	print("DEBUG: vnModule.promptEvidence() Called")
	local gameState = require(script.gameState)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	gameState.set("waitingForChoice") 

	-- 1. Create the "Mailbox" Folder if it doesn't exist
	local signalFolder = ReplicatedStorage:FindFirstChild("EvidenceSignals")
	if not signalFolder then
		signalFolder = Instance.new("Folder")
		signalFolder.Name = "EvidenceSignals"
		signalFolder.Parent = ReplicatedStorage
	end

	-- 2. Clear out old signals
	signalFolder:ClearAllChildren()

	-- 3. Open GUI (Required here to avoid circular logic)
	local guiModule = require(script.gui) 
	local recordGui = guiModule.courtRecordGui
	recordGui.open() 

	print("DEBUG: Evidence Menu Opened. Watching 'EvidenceSignals' folder...")

	-- 4. WAIT FOR THE NAMED OBJECT
	-- This waits until ANYTHING is added to the folder
	local child = signalFolder.ChildAdded:Wait()

	local chosenId = child.Name -- <--- This will be "ATMReceipt" or "Badge"
	print("DEBUG: Object Received! Name: " .. chosenId)

	-- 5. Cleanup
	child:Destroy() 
	gameState.set("idle")

	-- 6. Hand it to the Story Script
	return chosenId
end
-- ==========================================

function vnModule.init()
	gameState.onStateChanged(function(newGameState)
		if newGameState == "mainMenu" then
			story.cancelStoryExecution()

			menuFrame.Visible = true
			storyFrame.Visible = false
			vnModule.playSound({soundPath = "bgm/menu", track = 1, fade = true})
		else
			menuFrame.Visible = false
			storyFrame.Visible = true
		end
	end)

	playerData.init()
	sound.init()
	guiModule.init()
	storySaves.init()
	roaming.init()

	vnGui.Enabled = true
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	task.spawn(function()
		gameState.set("mainMenu")
		assetPreloader.preload()
	end)
end

return vnModule