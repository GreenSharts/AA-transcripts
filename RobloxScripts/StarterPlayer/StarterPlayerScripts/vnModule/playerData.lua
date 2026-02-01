local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vnDebug = require(ReplicatedStorage:WaitForChild("shared").vnDebug)

local vnSystem = workspace:WaitForChild("vnSystem")
local settingsFolder = vnSystem:WaitForChild("settings")

local remotes = ReplicatedStorage:WaitForChild("remotes")

local data = nil

local playerData = {}

function playerData.get()
	return data
end

-- Yields until player data is loaded, then returns player data.
function playerData.getWait()
	while data == nil do
		task.wait()
	end
	return data
end

function playerData.init()
	task.spawn(function()
		local newData = remotes.getSaveData:InvokeServer()

		vnDebug.print(`Received save data.`)
		
		data = newData
		
		settingsFolder.sound.bgm.Value = data.settings.sound.bgm
		settingsFolder.sound.sfx.Value = data.settings.sound.sfx
		settingsFolder.visuals.scrollSpeed.Value = data.settings.visuals.scrollSpeed
	end)
end

return playerData