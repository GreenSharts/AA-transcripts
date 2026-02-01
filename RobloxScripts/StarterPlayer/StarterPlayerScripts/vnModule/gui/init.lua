local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")
local sounds = vnSystem:WaitForChild("sounds")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")

-- Sub-Modules
local messagePrompts = require(script.messagePrompts)
local savesGui = require(script.savesGui)
local settingsGui = require(script.settingsGui)
local chapterSelectGui = require(script.chapterSelectGui)
local visualEffects = require(script.visualEffects)
local theme = require(script.theme)
local currentMenu = require(script.currentMenu)
local confirmationPrompt = require(script.guiObjects.confirmationPrompt)
local courtRecordGui = require(script.courtRecordGui) -- [[ NEW ]]

-- Parent Modules
local roaming = require(script.Parent.roaming)
local input = require(script.Parent.input)
local gameState = require(script.Parent.gameState)
local sharedVariables = require(script.Parent.sharedVariables)
local setUpButtonSounds = require(script.Parent.util.setUpButtonSounds)
local playerData = require(script.Parent.playerData)
local story = require(script.Parent.story)

local vnDebug = require(sharedFolder.vnDebug)

-- GUI Variables
local guiVariables = require(script.guiVariables)
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
local portraitLabel = guiVariables.portraitLabel

-- Court Record Vars
local courtRecordButton = guiVariables.courtRecordButton
local courtRecordFrame = guiVariables.courtRecordFrame

local gui = {}

-- [[ EXPORT SUB-MODULES TO MAIN MODULE ]]
gui.courtRecordGui = courtRecordGui 
gui.sprites = require(script.sprites) -- Main module needs this to access sprites

function gui.init()
	-- NVL Mode Setup
	if configuration.features.useNVL.Value == true then
		dialogBox.UIAspectRatioConstraint:Destroy()
		dialogBox.UISizeConstraint:Destroy()
		dialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
		dialogBox.Position = UDim2.fromScale(0.5, 0.5)
		dialogBox.Size = UDim2.fromScale(1, 1)
		dialogBox.BackgroundTransparency = 0.8
		dialogBox:SetAttribute("noTheme", true)

		dialogLabel.AnchorPoint = Vector2.new(1, 1)
		dialogLabel.Position = UDim2.new(1, -130, 1, -20)
		dialogLabel.Size = UDim2.new(1, -150, 1, -130)

		subjectFrame.AnchorPoint = Vector2.new(0, 0)
		subjectFrame.Position = UDim2.fromOffset(20, 70)

		portraitLabel.AnchorPoint = Vector2.new(0, 0)
		portraitLabel.Position = UDim2.fromOffset(20, 110)
		portraitLabel.Size = UDim2.fromOffset(150, 150)
		portraitLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY

		storyOptionsFrame.AnchorPoint = Vector2.new(1, 1)
		storyOptionsFrame.Position = UDim2.new(1, -10, 1, -10)
		storyOptionsFrame.Size = UDim2.fromOffset(100, 190)
		storyOptionsFrame.UIGridLayout.CellPadding = UDim2.fromOffset(10, 10)
		storyOptionsFrame.UIGridLayout.CellSize = UDim2.new(1, 0, 0, 30)

		advanceInputIndicator.Position = UDim2.new(1, -130, 1, -20)
	end

	-- Theme Application
	if configuration.theme.useTheme.Value == true then
		theme.applyTheme()
	end

	-- Input Setup
	input.init()
	input.onAdvanceInput(function()
		if gameState.get() == "waitingForAdvanceInput" or gameState.get() == "playingDialog" then
			gameState.set("idle")
		end
	end)

	-- Auto Button
	autoButton.Activated:Connect(function()
		vnDebug.print("Activated")
		sharedVariables.auto = not sharedVariables.auto
		if sharedVariables.auto == true then
			autoButton.TextColor3 = Color3.new(0, 1, 0)
		else
			autoButton.TextColor3 = theme.getThemeFolder().textTemplate.TextColor3
		end
		sounds.sfx.gui.buttonConfirm:Play()
	end)

	-- [[ COURT RECORD BUTTON ]]
	if courtRecordButton then
		courtRecordButton.Activated:Connect(function()
			if courtRecordFrame.Visible then
				currentMenu.set(nil)
			else
				courtRecordGui.open()
			end
		end)
		setUpButtonSounds(courtRecordButton)
	end

	-- Settings Toggle
	local function toggleSettings()
		if settingsFrame.Visible then
			currentMenu.set(nil)
		else
			currentMenu.set(settingsFrame)
		end
	end

	-- Saves Toggle
	local function toggleSavesGui(saveMode)
		if savesFrame.Visible == true then
			savesGui.close()
		else
			savesGui.open(saveMode)
		end
	end

	-- Menu Confirmation
	local menuConfirmationPrompt = nil
	storyOptionsFrame.Menu.Activated:Connect(function()
		if menuConfirmationPrompt ~= nil and menuConfirmationPrompt.Parent ~= nil then
			return
		end

		menuConfirmationPrompt = confirmationPrompt.new({
			yesCallback = function()
				gameState.set("mainMenu")
			end,
		})
		menuConfirmationPrompt.Name = "ReturnToMenuConfirmation"
		menuConfirmationPrompt.TextLabel.Text = "Are you sure you want to return to the main menu?"
		menuConfirmationPrompt.Parent = vnGui
	end)

	storyOptionsFrame.Settings.Activated:Connect(toggleSettings)
	storyOptionsFrame.Load.Activated:Connect(function() toggleSavesGui("load") end)
	storyOptionsFrame.Save.Activated:Connect(function() toggleSavesGui("save") end)

	setUpButtonSounds(autoButton)
	setUpButtonSounds(storyOptionsFrame.Menu)
	setUpButtonSounds(storyOptionsFrame.Settings)
	setUpButtonSounds(storyOptionsFrame.Save)
	setUpButtonSounds(storyOptionsFrame.Load)

	-- Main Menu Buttons
	newGameButton.Activated:Connect(function()
		if playerData.get().saves[1] == nil then
			sounds.sfx.gui.buttonConfirm:Play()
			story.newGame()
		else
			local newGamePrompt = confirmationPrompt.new({
				yesCallback = function()
					story.newGame()
				end,
			})
			newGamePrompt.Name = "ConfirmNewGame"
			newGamePrompt.TextLabel.Text = `Are you sure you want to start a new game? This will overwrite your autosave slot.`
			newGamePrompt.Parent = vnGui
		end
	end)
	menuSettingsButton.Activated:Connect(toggleSettings)

	continueGameButton.Activated:Connect(function() toggleSavesGui("load") end)

	if configuration.features.chapterSelection.Value == true then
		chapterSelectButton.Activated:Connect(function()
			if chapterSelectFrame.Visible then
				currentMenu.set(nil)
			else
				currentMenu.set(chapterSelectFrame)
			end
		end)
		setUpButtonSounds(chapterSelectButton)
	else
		chapterSelectButton.Visible = false
	end

	setUpButtonSounds(menuSettingsButton)
	setUpButtonSounds(newGameButton)
	setUpButtonSounds(continueGameButton)

	-- Init Sub-Modules
	settingsGui.init()
	savesGui.init()
	chapterSelectGui.init()
	messagePrompts.init()
	visualEffects.init()
	courtRecordGui.init() 
end

return gui