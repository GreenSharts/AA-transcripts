local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)
local dataStores = require(script.Parent.dataStores)

local remotes = ReplicatedStorage:WaitForChild("remotes")

local playerSettings = {}

function playerSettings.init()
	remotes.setSetting.OnServerEvent:Connect(function(player, category: string, index: string, value: any)
		local playerData = dataStores.getPlayerData(player)
		if playerData == nil then
			return
		end
		
		if typeof(category) ~= "string" or typeof(index) ~= "string" then
			return
		end
		
		local valueType = typeof(value)
		if category == "sound" then
			if valueType ~= "number" then
				return
			end
			math.clamp(value, 0, 2)
			playerData.settings.sound[index] = value
		elseif category == "visuals" then
			if index == "scrollSpeed" then
				if typeof(value) ~= "number" then
					return
				end
				math.clamp(value, 0.5, 2)
				playerData.settings.visuals[index] = value
			end
		end
		
		vnDebug.print(`Set {player.Name}'s {category}.{index} to {value}`)
	end)
end

return playerSettings