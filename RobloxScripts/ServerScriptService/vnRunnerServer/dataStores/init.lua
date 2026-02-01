local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AUTOSAVE_INTERVAL = 60 * 5

local sharedFolder = ReplicatedStorage:WaitForChild("shared")
local remotes = ReplicatedStorage:WaitForChild("remotes")

local vnDebug = require(sharedFolder.vnDebug)
local dataTemplate = require(script.template)
local getApiServicesEnabled = require(script.getApiServicesEnabled)

local dataStore

local dataStores = {}

local playerDataEntries: {[Player]: dataTemplate.playerData} = {}
local playersDeletingData: {[Player]: true?} = {}

-- Creates a blank player data table.
local function createBlankPlayerData(player: Player): dataTemplate.playerData
	local playerData = table.clone(dataTemplate)
	-- Apply any custom defaults here
	return playerData
end

-- Takes existing save data, checks for any missing fields and sets them to the default values.
local function reconcileData(playerData: {})
	local function recursiveReconcile(t: {}, currentPath: {string})
		for i,v in t do
			local counterpart = playerData
			for i=1, #currentPath do
				counterpart = counterpart[currentPath[i]]
			end
			
			if counterpart[i] == nil then
				warn(`Filling in missing data {table.concat(currentPath, ".")}.{tostring(i)} with {tostring(v)}`)
				counterpart[i] = v
			end
			
			if typeof(v) == "table" then
				local localPath = table.clone(currentPath)
				table.insert(localPath, i)
				recursiveReconcile(v, localPath)
			end
		end
	end
	
	recursiveReconcile(dataTemplate, {})
end

-- Retries a function until it succeeds or hits maxRetries.
local function retryPcall(maxRetries: number, func: () -> ()): (boolean, any)
	local success, result
	for i=1, maxRetries do
		success, result = pcall(func)
		if success then
			break
		else
			warn(result)
			if i < maxRetries then
				task.wait(math.min(i, 10))
			end
		end
	end
	
	return success, result
end

-- Saves the player's current data to the data store.
function dataStores.savePlayerData(player: Player): boolean
	vnDebug.print(`Saving {player.Name}'s data...`)
	
	local encodedPlayerData = HttpService:JSONEncode(playerDataEntries[player])
	local success, result = pcall(function()
		dataStore:SetAsync(tostring(player.UserId), encodedPlayerData)
	end)
	if not success then
		warn(result)
	end
	return success
end

function dataStores.getPlayerData(player: Player)
	return playerDataEntries[player]
end

function dataStores.deleteData(player: Player)
	local success, result = retryPcall(3, function()
		dataStore:RemoveAsync(tostring(player.UserId))
		playersDeletingData[player] = true
	end)
	if not success then
		remotes.showMessagePrompt:FireClient(player, "Failed to delete data. Please try again later.")
	else
		player:Kick("Data deleted successfully. Thanks for playing!")
	end
end

function dataStores.init()
	if getApiServicesEnabled() then
		dataStore = DataStoreService:GetDataStore("VisualNovel")
	end
	
	local function onPlayerAdded(player: Player)
		vnDebug.print(`Getting {player.Name}'s save data...`)

		local playerData
		if getApiServicesEnabled() then
			-- Get player data
			local encodedPlayerData = dataStore:GetAsync(tostring(player.UserId))
			if encodedPlayerData == nil or encodedPlayerData == "null" then
				vnDebug.print(`This is a new player. Creating blank save data...`)
				playerData = createBlankPlayerData(player)
				encodedPlayerData = HttpService:JSONEncode(playerData)
				local success, result = retryPcall(3, function()
					dataStore:SetAsync(tostring(player.UserId), encodedPlayerData)
				end)
				if not success then
					player:Kick("Unable to create save data. Please try again later.")
					return
				end
			else
				playerData = HttpService:JSONDecode(encodedPlayerData)
				reconcileData(playerData)
			end
		else
			-- We already know getting player data will fail; just create a blank player data table and use that
			playerData = createBlankPlayerData(player)
		end

		vnDebug.print(`Save data loaded!`)
		print(playerData)

		playerDataEntries[player] = playerData
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _,player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	
	Players.PlayerRemoving:Connect(function(player)
		if not getApiServicesEnabled() then
			return
		end
		
		if playersDeletingData[player] == true then
			vnDebug.print(`{player.Name} is disconnecting, but they're deleting their data. We're all good!`)
			playersDeletingData[player] = nil
			return
		end
		
		-- Attempt to save data up to three times
		vnDebug.print(`{player.Name} is disconnecting. Saving their data...`)
		
		print(playerDataEntries[player])
		
		retryPcall(3, function()
			local encodedPlayerData = HttpService:JSONEncode(playerDataEntries[player])
			dataStore:SetAsync(tostring(player.UserId), encodedPlayerData)
		end)
		
		playerDataEntries[player] = nil
	end)
	
	remotes.deleteData.OnServerEvent:Connect(function(player)
		dataStores.deleteData(player)
	end)
	
	remotes.getSaveData.OnServerInvoke = function(player)
		while playerDataEntries[player] == nil do
			task.wait()
		end
		return playerDataEntries[player]
	end
	
	-- Autosaving
	if getApiServicesEnabled() then
		task.spawn(function()
			while true do
				task.wait(AUTOSAVE_INTERVAL)
				for _,player in Players:GetPlayers() do
					dataStores.savePlayerData(player)
				end
			end
		end)
	end
end

return dataStores