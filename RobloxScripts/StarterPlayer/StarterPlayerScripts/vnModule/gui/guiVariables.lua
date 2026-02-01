local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local vnGui = localPlayer.PlayerGui:WaitForChild("vnGui")

local storyFrame = vnGui.Story
local dialogBox = storyFrame.DialogBox
local dialogLabel = dialogBox.Dialog
local portraitLabel = dialogBox.Portrait
local subjectFrame = dialogBox.Subject
local subjectLabel = subjectFrame.TextLabel
local advanceInputIndicator = dialogBox.ContinueIndicator
local storyOptionsFrame = storyFrame.Options
local autoButton = storyOptionsFrame.Auto

-- [[ FIX: CHANGED PATH TO OPTIONS ]]
local courtRecordButton = storyOptionsFrame:WaitForChild("CourtRecordButton") 
-- [[ END FIX ]]

local colorCover = storyFrame.ColorCover
local imageCover = storyFrame.ImageCover

local choicesFrame = storyFrame.Choices

local background = storyFrame.Background

local loadingScreen = vnGui.LoadingScreen

local spritesFrame = storyFrame.Sprites

local menuFrame = vnGui.Menu
local newGameButton = menuFrame.Sidebar.Buttons.NewGame
local continueGameButton = menuFrame.Sidebar.Buttons.Continue
local menuSettingsButton = menuFrame.Sidebar.Buttons.Settings
local chapterSelectButton = menuFrame.Sidebar.Buttons.ChapterSelect

local savesFrame = vnGui.Saves
local savePageFrames = savesFrame.PageFrames
local savePageNavigator = savesFrame.PageNavigator

local chapterSelectFrame = vnGui.ChapterSelect

local settingsFrame = vnGui.Settings

-- [[ NEW: COURT RECORD FRAME ]]
-- Make sure you have a frame named "CourtRecord" directly inside vnGui
local courtRecordFrame = vnGui:WaitForChild("CourtRecord") 

local titleCardFrame = storyFrame.TitleCard

local textInputBox = storyFrame.TextInputBox

local guiVariables = {
	vnGui = vnGui,

	storyFrame = storyFrame,
	dialogBox = dialogBox,
	dialogLabel = dialogLabel,
	portraitLabel = portraitLabel,
	subjectFrame = subjectFrame,
	subjectLabel = subjectLabel,
	advanceInputIndicator = advanceInputIndicator,
	storyOptionsFrame = storyOptionsFrame,
	autoButton = autoButton,

	-- [[ EXPORTS ]]
	courtRecordButton = courtRecordButton,
	courtRecordFrame = courtRecordFrame,

	choicesFrame = choicesFrame,
	background = background,
	loadingScreen = loadingScreen,
	spritesFrame = spritesFrame,
	colorCover = colorCover,
	imageCover = imageCover,
	textInputBox = textInputBox,

	menuFrame = menuFrame,
	newGameButton = newGameButton,
	continueGameButton = continueGameButton,
	menuSettingsButton = menuSettingsButton,
	chapterSelectButton = chapterSelectButton,

	settingsFrame = settingsFrame,
	savesFrame = savesFrame,
	savePageFrames = savePageFrames,
	savePageNavigator = savePageNavigator,

	chapterSelectFrame = chapterSelectFrame,

	titleCardFrame = titleCardFrame,
}

return guiVariables