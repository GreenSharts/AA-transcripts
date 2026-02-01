local story = require("../story")
local setUpButtonSounds = require("../util/setUpButtonSounds")
local currentMenu = require("./currentMenu")
local chapterUnlocking = require("../chapterUnlocking")
local playerData = require("../playerData")

local guiVariables = require("./guiVariables")
local chapterSelectFrame = guiVariables.chapterSelectFrame
local chapterSelectButton = guiVariables.chapterSelectButton
local chapterSelectList = chapterSelectFrame.List
local chapterButtonSource = chapterSelectList.UIListLayout.ChapterButtonSource

local closeButton = require("./guiObjects/closeButton")

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")

local chapterSelectGui = {}

function chapterSelectGui.init()
	task.delay(0.033333, function()
		local chapterButtons: {[number]: TextButton} = {}
		local chapters = story.getChapters()
		local chaptersUnlocked = playerData.getWait().chaptersUnlocked
		
		local function updateChapterButton(chapterIndex: number)
			local chapterData = chapters[chapterIndex]
			local button = chapterButtons[chapterIndex]
			
			if table.find(chaptersUnlocked, chapterIndex) then
				button.Text = `Chapter {chapterIndex}: {chapterData.chapterName}`
				button.TextTransparency = 0
			else
				button.Text = `Chapter {chapterIndex}: Locked`
				button.TextTransparency = 0.5
			end
		end
		
		chapterUnlocking.onChapterUnlocked(updateChapterButton)
		
		for i,v in chapters do
			local chapterButton = chapterButtonSource:Clone()
			chapterButton.Name = tostring(i)
			chapterButton.Parent = chapterSelectList
			
			chapterButton.Activated:Connect(function()
				if table.find(chaptersUnlocked, i) then
					story.playChapter(i)
					sounds.sfx.gui.buttonConfirm:Play()
					currentMenu.set(nil)
				end
			end)
			
			setUpButtonSounds(chapterButton)
			
			chapterButtons[i] = chapterButton
			
			updateChapterButton(i)
		end
	end)
	
	closeButton.new().Parent = chapterSelectFrame
end

return chapterSelectGui