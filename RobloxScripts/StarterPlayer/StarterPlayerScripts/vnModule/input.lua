local Players = game:GetService("Players")

local guiVariables = require(script.Parent.gui.guiVariables)
local sharedVariables = require(script.Parent.sharedVariables)
local gameState = require(script.Parent.gameState)
local advanceInputIndicator = guiVariables.advanceInputIndicator

local localPlayer = Players.LocalPlayer
local dialogBox = guiVariables.dialogBox

local onInputCallbacks = {}

local input = {}

function input.onAdvanceInput(callback: () -> ())
	table.insert(onInputCallbacks, callback)
end

function input.waitForAdvanceInput()
	if sharedVariables.auto then
		task.wait(1.5)
		if sharedVariables.auto then
			return
		end
	end
	
	advanceInputIndicator.Visible = true

	gameState.set("waitingForAdvanceInput")
	repeat task.wait()
	until gameState.get() == "idle"

	advanceInputIndicator.Visible = false
end

function input.init()
	dialogBox.ContinueButton.Activated:Connect(function()
		for _, callback in onInputCallbacks do
			task.spawn(callback)
		end
	end)
end

return input