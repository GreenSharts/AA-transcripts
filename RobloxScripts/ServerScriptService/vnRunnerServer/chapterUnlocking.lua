local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)
local dataStores = require(script.Parent.dataStores)

local remotes = ReplicatedStorage:WaitForChild("remotes")

local playerSettings = {}

function playerSettings.init()
	remotes.unlockChapter.OnServerEvent:Connect(function(player, chapterIndex: number)
		local playerData = dataStores.getPlayerData(player)
		if playerData == nil then
			return
		end
		if typeof(chapterIndex) ~= "number" then
			return
		end
		if table.find(playerData.chaptersUnlocked, chapterIndex) then
			-- This chapter is already unlocked
			return
		end
		
		table.insert(playerData.chaptersUnlocked, chapterIndex)
		
		vnDebug.print(`Unlocked chapter {chapterIndex} for {player.Name}`)
	end)
end

return playerSettings