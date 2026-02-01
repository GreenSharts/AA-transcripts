local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)

type gameState = "idle" | "waitingForAdvanceInput" | "waitingForChoice" | "waitingForTextInput" | "playingDialog" | "mainMenu"
local current: gameState = "idle"

local stateChangedCallbacks: {(state: gameState) -> ()} = {}

local gameState = {}

function gameState.canEnterState(newState: gameState)
	if newState == current then
		return false
	end
	
	if newState == "waitingForChoice" or newState == "waitingForTextInput" then
		return current ~= "waitingForChoice" and current ~= "waitingForTextInput"
	end
	
	return true
end

function gameState.set(newState: gameState)
	if not gameState.canEnterState(newState) then
		warn(`Can't enter game state {newState} from {current}.`)
		return false
	end
	
	current = newState
	vnDebug.print(`Game state: {newState}`)
	for _,v in stateChangedCallbacks do
		task.spawn(v, current)
	end
	
	return true
end

function gameState.get(): gameState
	return current
end

function gameState.onStateChanged(callback: (state: gameState) -> ())
	table.insert(stateChangedCallbacks, callback)
end

return gameState