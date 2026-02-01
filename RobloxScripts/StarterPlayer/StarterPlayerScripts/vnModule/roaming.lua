local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local guiVariables = require("./gui/guiVariables")
local storyFrame = guiVariables.storyFrame
local dialogBox = guiVariables.dialogBox
local optionsFrame = guiVariables.storyOptionsFrame
local hardBackground = guiVariables.hardBackground
local background = guiVariables.background

local controlModule

local inRoamingMode = false

type changedCallback = (newState: boolean) -> ()
local onChangedCallbacks: {changedCallback} = {}

local roaming = {}

function roaming.inRoamingMode()
	return inRoamingMode
end

function roaming.onChanged(callback: changedCallback)
	table.insert(onChangedCallbacks, callback)
end

function roaming.enable()
	if inRoamingMode then
		return
	end
	inRoamingMode = true
	for _,callback in onChangedCallbacks do
		task.spawn(callback, inRoamingMode)
	end
	
	dialogBox.Visible = false
	hardBackground.Visible = false
	background.Visible = false
	
	while controlModule == nil do
		task.wait()
	end
	controlModule:Enable()
end

function roaming.disable()
	if not inRoamingMode then
		return
	end
	inRoamingMode = false
	for _,callback in onChangedCallbacks do
		task.spawn(callback, inRoamingMode)
	end
	
	hardBackground.Visible = true
	background.Visible = true
	
	controlModule:Disable()
end

function roaming.init()
	task.spawn(function()
		controlModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
		controlModule:Disable()
	end)
end

return roaming