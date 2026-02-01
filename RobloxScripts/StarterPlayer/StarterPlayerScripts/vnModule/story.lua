local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)
local sprites = require(script.Parent.gui.sprites)
local gameState = require(script.Parent.gameState)
local sharedVariables = require(script.Parent.sharedVariables)
local storyVariables = require(script.Parent.storyVariables)
local chapterUnlocking = require("./chapterUnlocking")
local guiVariables = require("./gui/guiVariables")
local visualEffects = require("./gui/visualEffects")
local sound = require("./sound")
local roaming = require("./roaming")

local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local menuFrame = guiVariables.menuFrame
local storyFrame = guiVariables.storyFrame
local dialogBox = guiVariables.dialogBox
local choicesFrame = guiVariables.choicesFrame
local textInputBox = guiVariables.textInputBox
local spritesFrame = guiVariables.spritesFrame

local sceneThread: thread? = nil
local chapterThread: thread? = nil

local scenes: {[string]: () -> ()} = {}
local chapters: {[number]: {chapterName: string, scenes: {string}, nextChapterIndex: number}} = {}

local sceneStartedCallbacks: {() -> ()} = {}
local newGameCallbacks: {() -> ()} = {}

local storyConnections: {RBXScriptConnection} = {}

local story = {}

-- Registers a scene to be played later.
function story.registerScene(sceneName: string, sceneFunction: () -> ())
	vnDebug.print(`Registering scene: {sceneName}`)
	if scenes[sceneName] ~= nil then
		warn(`Scene name "{sceneName}" is already in use. Please use a different scene name.`)
		return
	end
	scenes[sceneName] = sceneFunction
end

-- Logs a story connection, an RBXScriptConnection which will be automatically disconnected when the player exits the story.
function story.logStoryConnection(connection: RBXScriptConnection)
	table.insert(storyConnections, connection)
end

-- Stops the execution of the current scene.
function story.stopCurrentScene()
	if sceneThread ~= nil then
		vnDebug.print(`Stopping current scene`)
		task.cancel(sceneThread)
		sceneThread = nil
		sharedVariables.currentSceneIndex = nil
	end
end

-- Stops the execution of the current chapter.
function story.stopCurrentChapter()
	if chapterThread ~= nil then
		vnDebug.print(`Stopping current chapter`)
		task.cancel(chapterThread)
		chapterThread = nil
		sharedVariables.currentChapterIndex = nil
	end
end

-- Clears the stage, stops the execution of the current scene and chapter, and disconnects all logged story connections.
function story.cancelStoryExecution()
	story.clearStage()
	story.stopCurrentScene()
	story.stopCurrentChapter()
	roaming.disable()
	
	for _,connection in storyConnections do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	storyConnections = {}
end

-- Destroys all sprites, stops all sounds, and resets the visibility of various GUI elements.
function story.clearStage()
	vnDebug.print(`Clearing stage`)
	sprites.destroyAll()
	visualEffects.stopAll()
	sound.stopAll()
	
	choicesFrame.Visible = false
	textInputBox.Visible = false
	spritesFrame.Visible = true
end

-- Plays a scene.
function story.playScene(sceneName: string)
	vnDebug.print(`Playing scene: {sceneName}`)
	story.stopCurrentScene()
	story.clearStage()

	local sceneFunction = scenes[sceneName]
	sceneThread = task.spawn(function()
		sceneFunction()
		sceneThread = nil
	end)
	
	for _,callback in sceneStartedCallbacks do
		task.spawn(callback)
	end
end

-- Runs the provided callback every time a scene begins.
function story.onSceneStarted(callback: () -> ())
	table.insert(sceneStartedCallbacks, callback)
end

-- Runs the provided callback every time a new game is started.
function story.onNewGame(callback: () -> ())
	table.insert(newGameCallbacks, callback)
end

-- Registers a chapter, which is a grouping of scenes played in sequence.
function story.registerChapter(chapterIndex: number, chapterName: string, scenes: {string}, nextChapterIndex: number?)
	if chapters[chapterIndex] ~= nil then
		warn(`Chapter index {chapterIndex} is already in use. Please use a different chapter index.`)
		return
	end
	vnDebug.print(`Registering chapter {chapterIndex}: {chapterName}`)
	
	if nextChapterIndex == nil then
		nextChapterIndex = chapterIndex+1
	end
	
	chapters[chapterIndex] = {
		chapterName = chapterName,
		scenes = scenes,
		nextChapterIndex = nextChapterIndex,
	}
end

-- Returns all registered chapters.
function story.getChapters()
	return chapters
end

-- Plays a chapter. Once finished, automatically proceeds to the next chapter, if it exists.
function story.playChapter(chapterIndex: number, startingSceneIndex: number?)
	story.cancelStoryExecution()
	
	local chapterData = chapters[chapterIndex]
	if chapterData == nil then
		warn(`Chapter {chapterIndex} is not registered. Run story.registerChapter first.`)
		return
	end
	if startingSceneIndex == nil then
		startingSceneIndex = 1
	elseif startingSceneIndex < 1 or startingSceneIndex > #chapterData.scenes then
		warn(`Scene number {startingSceneIndex} of chapter {chapterIndex} does not exist.`)
		return
	end
	
	vnDebug.print(`Playing chapter {chapterIndex}`)
	chapterUnlocking.unlockChapter(chapterIndex)
	
	task.spawn(function()
		sharedVariables.currentChapterIndex = chapterIndex
		sharedVariables.currentSceneIndex = startingSceneIndex
		
		menuFrame.Visible = false
		dialogBox.Visible = false
		storyFrame.Visible = true
		
		if configuration.features.displayTitleCardEachChapter.Value == true and startingSceneIndex == 1 then
			story.clearStage()
			visualEffects.addColorCover(Color3.new(0, 0, 0))
			task.wait(0.5)
			visualEffects.titleCard(`Chapter {chapterIndex}: {chapterData.chapterName}`, 5, 0.5, 1)
			task.wait(4)
			visualEffects.removeColorCover(0.5)
		end
		
		chapterThread = task.spawn(function()
			for i=startingSceneIndex,#chapterData.scenes do
				sharedVariables.currentSceneIndex = i
				local sceneName = chapterData.scenes[i]
				story.playScene(sceneName)
				repeat task.wait()
				until sceneThread == nil
			end
			
			chapterThread = nil
			sharedVariables.currentChapterIndex = nil
			sharedVariables.currentSceneIndex = nil
			vnDebug.print(`Finished chapter {chapterIndex}`)
			
			local nextChapterIndex = chapterData.nextChapterIndex
			if nextChapterIndex ~= nil and chapters[nextChapterIndex] ~= nil then
				story.playChapter(nextChapterIndex)
			else
				gameState.set("mainMenu")
			end
		end)
	end)
end

-- Plays chapter 1.
function story.newGame()
	story.playChapter(1)
	for _,callback in newGameCallbacks do
		task.spawn(callback)
	end
end

return story