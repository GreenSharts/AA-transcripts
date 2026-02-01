-- Manages save state and saving/loading.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("remotes")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)
local background = require(script.Parent.gui.background)
local storyVariables = require(script.Parent.storyVariables)
local sharedVariables = require(script.Parent.sharedVariables)
local story = require(script.Parent.story)
local playerData = require("./playerData")
local messagePrompts = require("./gui/messagePrompts")

local saveCooldown = false

local saveState: {background: string, chapterIndex: number, sceneIndex: number, storyVariables: {[string]: number | string | boolean}} = {}

type onSavedCallback = (saveIndex: number, saveData: {any}) -> ()
local onSavedCallbacks: onSavedCallback = {}

local storySaves = {}

-- Runs the provided callback when a save is created or updated.
function storySaves.onSaved(callback: onSavedCallback)
	table.insert(onSavedCallbacks, callback)
end

function storySaves.load(saveData)
	vnDebug.print(`Loading save`)
	local chapterIndex = saveData.chapterIndex
	local sceneIndex = saveData.sceneIndex
	local savedStoryVariables = saveData.storyVariables
	local background = saveData.background
	
	storyVariables.clear()
	for i,v in savedStoryVariables do
		storyVariables.set(i, v)
	end
	
	story.playChapter(chapterIndex, sceneIndex)
end

function storySaves.save(saveIndex: number)
	if saveCooldown then
		return
	end
	
	vnDebug.print(`Saving to slot {saveIndex}`)
	
	saveCooldown = true
	
	local success, result = remotes.storySave:InvokeServer(saveIndex, saveState.chapterIndex, saveState.sceneIndex, saveState.background, saveState.storyVariables)
	if not success then
		messagePrompts.showMessagePrompt(tostring(result))
	else
		playerData.get().saves[saveIndex] = result
		for _,callback in onSavedCallbacks do
			task.spawn(callback, saveIndex, result)
		end
	end
	
	saveCooldown = false
end

function storySaves.recordSaveState(autosave: boolean?)
	local currentChapterIndex = sharedVariables.currentChapterIndex
	local currentSceneIndex = sharedVariables.currentSceneIndex
	if currentChapterIndex == nil or currentSceneIndex == nil then
		warn(`Can't log story state; player is not in the story.`)
		return
	end
	local currentBackground = background.get()
	local currentStoryVariables = storyVariables.getAll()
	
	saveState = {
		background = currentBackground,
		chapterIndex = currentChapterIndex,
		sceneIndex = currentSceneIndex,
		storyVariables = currentStoryVariables,
	}
	vnDebug.print("Save state recorded")
	
	if autosave then
		storySaves.save(1)
	end
end

function storySaves.getSaveState()
	return saveState
end

function storySaves.init()
	story.onSceneStarted(function()
		-- Autosaving
		local currentChapterIndex = sharedVariables.currentChapterIndex
		local currentSceneIndex = sharedVariables.currentSceneIndex
		if currentChapterIndex == nil or currentSceneIndex == nil then
			warn(`Can't log story state; player is not in the story.`)
			return
		end
		
		local autosave = true
		if saveState.chapterIndex ~= nil and saveState.sceneIndex ~= nil then
			-- We only want to autosave if the player made progress
			if currentChapterIndex < saveState.chapterIndex then 
				autosave = false
			elseif currentChapterIndex == saveState.chapterIndex then
				if currentSceneIndex < saveState.sceneIndex then
					autosave = false
				end
			end
		end
		
		storySaves.recordSaveState(autosave)
	end)
	
	story.onNewGame(storySaves.recordSaveState)
end

return storySaves