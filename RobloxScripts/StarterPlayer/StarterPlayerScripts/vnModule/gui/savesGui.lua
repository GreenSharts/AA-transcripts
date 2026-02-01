local MAX_SAVES = 100
local SAVES_PER_PAGE = 6

local playerData = require(script.Parent.Parent.playerData)
local guiVariables = require(script.Parent.guiVariables)
local currentMenu = require(script.Parent.currentMenu)
local storySaves = require(script.Parent.Parent.storySaves)
local sharedVariables = require("../sharedVariables")

local setUpButtonSounds = require(script.Parent.Parent.util.setUpButtonSounds)

local confirmationPrompt = require(script.Parent.guiObjects.confirmationPrompt)
local messagePrompts = require("./messagePrompts")
local closeButton = require(script.Parent.guiObjects.closeButton)

export type saveMode = "save" | "load"
local saveMode: saveMode = "load"

local vnGui = guiVariables.vnGui
local savesFrame = guiVariables.savesFrame
local pageFrames = guiVariables.savePageFrames
local pageNavigator = guiVariables.savePageNavigator

local currentPageIndex = 1
local currentPrompt = nil

local savesGui = {}

function savesGui.close()
	currentMenu.set(nil)
end

function savesGui.open(newSaveMode: saveMode)
	saveMode = newSaveMode
	if newSaveMode == "save" then
		savesFrame.Title.Text = "Save Game"
	else
		savesFrame.Title.Text = "Load Save"
	end
	currentMenu.set(savesFrame)
end

function savesGui.init()
	task.spawn(function()
		local playerData = playerData.getWait()
		
		-- Create UI
		local pageList: {Frame} = {}
		local pageLookup: {[number]: number} = {}
		
		local function updateSaveFrame(saveIndex: number)
			local pageFrame = pageList[pageLookup[saveIndex]]
			local saveFrame = pageFrame[tostring(saveIndex)]
			local textLabel = saveFrame.TextLabel
			local backgroundLabel = saveFrame.Background
			
			local slotNameString = if saveIndex == 1 then "Auto" else tostring(saveIndex)
			
			local saveData = playerData.saves[saveIndex]
			if saveData == nil then
				textLabel.Text = `{slotNameString} - Empty`
			else
				local chapterIndex: number = saveData.chapterIndex
				local sceneIndex: number = saveData.sceneIndex
				local timestamp: number = saveData.timestamp
				local background: string = saveData.background
				textLabel.Text = `{slotNameString} - Chapter {chapterIndex}, scene {sceneIndex} {os.date("%x", timestamp)} {os.date("%X", timestamp)}`
				backgroundLabel.Image = background
			end
		end
		
		local currentPageFrame
		local savesUntilNextPage = 0
		for i=1, MAX_SAVES do
			if savesUntilNextPage == 0 then
				-- Create page
				savesUntilNextPage = SAVES_PER_PAGE
				
				local newPageIndex = #pageList + 1
				currentPageFrame = pageFrames.PageSource:Clone()
				currentPageFrame.Name = `Page{newPageIndex}`
				currentPageFrame.Parent = pageFrames

				pageList[newPageIndex] = currentPageFrame
			end
			
			local saveFrame = pageFrames.SaveFrameSource:Clone()
			local backgroundLabel = saveFrame.Background
			local textLabel = saveFrame.TextLabel
			saveFrame.Name = tostring(i)
			saveFrame.Visible = true
			saveFrame.Parent = currentPageFrame
			
			pageLookup[i] = #pageList
			updateSaveFrame(i)
			setUpButtonSounds(backgroundLabel)
			
			backgroundLabel.MouseEnter:Connect(function()
				backgroundLabel.ImageColor3 = Color3.new(0.7, 0.7, 0.7)
			end)
			
			backgroundLabel.MouseLeave:Connect(function()
				backgroundLabel.ImageColor3 = Color3.new(1, 1, 1)
			end)
			
			backgroundLabel.MouseButton1Down:Connect(function()
				backgroundLabel.ImageColor3 = Color3.new(0.6, 0.6, 0.6)
			end)
			
			backgroundLabel.MouseButton1Up:Connect(function()
				backgroundLabel.ImageColor3 = Color3.new(1, 1, 1)
			end)
			
			backgroundLabel.Activated:Connect(function()
				local saveData = playerData.saves[i]
				
				if saveMode == "load" then
					if saveData == nil then
						-- Can't load an empty save
						return
					end
					
					if currentPrompt == nil then
						currentPrompt = confirmationPrompt.new({
							yesCallback = function()
								storySaves.load(saveData)
								savesGui.close()
								currentPrompt = nil
							end,
							noCallback = function()
								currentPrompt = nil
							end,
						})
						currentPrompt.Name = "ConfirmLoad"
						currentPrompt.TextLabel.Text = `Are you sure you want to load slot {i}? You'll lose any unsaved progress!`
						currentPrompt.Parent = vnGui
					end
				elseif saveMode == "save" then
					if i==1 then
						messagePrompts.showMessagePrompt("You can't overwrite the autosave slot.")
						return
					end
					
					if saveData ~= nil then
						-- This will overwrite an existing save; confirm with the player
						if currentPrompt == nil then
							currentPrompt = confirmationPrompt.new({
								yesCallback = function()
									storySaves.save(i)
									currentPrompt = nil
								end,
								noCallback = function()
									currentPrompt = nil
								end,
							})
							currentPrompt.Name = "ConfirmOverwriteSave"
							currentPrompt.TextLabel.Text = `Are you sure you want to overwrite slot {i}?`
							currentPrompt.Parent = vnGui
						end
					else
						storySaves.save(i)
					end
				end
			end)
			
			savesUntilNextPage -= 1
		end
		
		pageList[1].Visible = true
		
		local nextButton, previousButton = pageNavigator.Next, pageNavigator.Previous
		
		previousButton.Visible = false
		
		local function goToPage(newPageIndex: number)
			pageList[currentPageIndex].Visible = false
			pageList[newPageIndex].Visible = true
			
			pageNavigator.PageNumber.Text = `Page {newPageIndex}`
			
			currentPageIndex = newPageIndex
			
			if newPageIndex == #pageList then
				nextButton.Visible = false
			else
				nextButton.Visible = true
			end
			if newPageIndex == 1 then
				previousButton.Visible = false
			else
				previousButton.Visible = true
			end
		end
		
		nextButton.MouseEnter:Connect(function()
			nextButton.ImageColor3 = Color3.new(0.7, 0.7, 0.7)
		end)

		nextButton.MouseLeave:Connect(function()
			nextButton.ImageColor3 = Color3.new(1, 1, 1)
		end)

		nextButton.MouseButton1Down:Connect(function()
			nextButton.ImageColor3 = Color3.new(0.6, 0.6, 0.6)
		end)

		nextButton.MouseButton1Up:Connect(function()
			nextButton.ImageColor3 = Color3.new(1, 1, 1)
		end)
		
		nextButton.Activated:Connect(function()
			local newPageIndex = currentPageIndex + 1
			goToPage(newPageIndex)
		end)
		
		previousButton.MouseEnter:Connect(function()
			previousButton.ImageColor3 = Color3.new(0.7, 0.7, 0.7)
		end)

		previousButton.MouseLeave:Connect(function()
			previousButton.ImageColor3 = Color3.new(1, 1, 1)
		end)

		previousButton.MouseButton1Down:Connect(function()
			previousButton.ImageColor3 = Color3.new(0.6, 0.6, 0.6)
		end)

		previousButton.MouseButton1Up:Connect(function()
			previousButton.ImageColor3 = Color3.new(1, 1, 1)
		end)

		previousButton.Activated:Connect(function()
			local newPageIndex = currentPageIndex - 1
			goToPage(newPageIndex)
		end)
		
		storySaves.onSaved(function(saveIndex: number, saveData: {any})
			updateSaveFrame(saveIndex)
		end)
		
		closeButton.new().Parent = savesFrame
	end)
end

return savesGui