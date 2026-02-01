local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)

local entries = {}

local storyVariables = {}

function storyVariables.set(name: string, data: string | number | boolean)
	local dataType = typeof(data)
	if dataType ~= "string" and dataType ~= "number" and dataType ~= "boolean" then
		error(`Story variables can only be a string, number, or boolean. Received data type {dataType}.`)
	end
	vnDebug.print(`Setting {name} to {tostring(data)}`)
	entries[name] = data
end

-- Clears all story variables.
function storyVariables.clear()
	entries = {}
end

-- Returns a table of all the current story variables.
function storyVariables.getAll()
	return table.clone(entries)
end

function storyVariables.get(name: string)
	return entries[name]
end

return storyVariables