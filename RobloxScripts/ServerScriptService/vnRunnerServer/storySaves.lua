local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_SAVES = 100

local vnSystem = workspace:WaitForChild("vnSystem")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local dataStores = require(script.Parent.dataStores)
local vnDebug = require(sharedFolder.vnDebug)

local remotes = ReplicatedStorage:WaitForChild("remotes")

local storySaves = {}

function storySaves.init()
	remotes.storySave.OnServerInvoke = function(player, saveIndex: number, chapterIndex: number, sceneIndex: number, background: string, storyVariables: {[string]: string | number | boolean})
		if typeof(saveIndex) ~= "number" or typeof(chapterIndex) ~= "number" or typeof(sceneIndex) ~= "number" then
			return
		end
		if typeof(background) ~= "string" then
			background = ""
		end
		if saveIndex < 1 or saveIndex > MAX_SAVES then
			return
		end
		if typeof(storyVariables) ~= "table" then
			return
		end
		for i,v in storyVariables do
			if typeof(i) ~= "string" then
				return
			end
			local valueType = typeof(v)
			if valueType ~= "number" and valueType ~= "string" and valueType ~= "boolean" then
				return
			end
		end

		-- [[ FIX STARTS HERE ]] --
		local backgroundImageId = ""

		-- 1. Check if it is a 3D background (starts with "3d_" or is a simple number)
		if string.sub(background, 1, 3) == "3d_" or string.match(background, "^%d+$") then
			-- It is 3D, so we use a blank placeholder since there is no ImageLabel to grab
			backgroundImageId = "rbxassetid://0"
		else
			-- 2. It is a 2D background, try to find the ImageLabel
			local backgroundLabel = vnSystem.images.backgrounds:FindFirstChild(background)

			if backgroundLabel then
				backgroundImageId = backgroundLabel.Image
			else
				-- 3. Background not found, check for ERROR_FALLBACK safely
				local fallback = vnSystem.images.backgrounds:FindFirstChild("ERROR_FALLBACK")
				if fallback then
					backgroundImageId = fallback.Image
				else
					-- 4. Even fallback is missing (because you deleted it), so use blank
					backgroundImageId = "rbxassetid://0"
				end
			end
		end
		-- [[ FIX ENDS HERE ]] --

		local playerData = dataStores.getPlayerData(player)
		playerData.saves[saveIndex] = {
			chapterIndex = chapterIndex,
			sceneIndex = sceneIndex,
			timestamp = os.time(),
			storyVariables = storyVariables,
			background = backgroundImageId, -- Use our safe variable
		}

		vnDebug.print(`Saved chapter {chapterIndex}, scene {sceneIndex} to slot {saveIndex}`)

		return true, playerData.saves[saveIndex]
	end
end

return storySaves