local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") -- [[ NEW SERVICE ]]
local storyVariables = require(script.Parent.storyVariables)
local vnDebug = require(ReplicatedStorage.shared.vnDebug)

-- DATA BASE OF ALL ITEMS IN THE GAME
local evidenceDB = {
	["Badge"] = {
		name = "Attorney's Badge",
		description = "My prized possession. It shows I am a defense attorney.",
		icon = "rbxassetid://110479582730726", 
	},
	["AutopsyReport1"] = {
		name = "Autopsy Report",
		description = "Time of death: Between 12:45 PM and 1:15 PM. Cause: Blunt force trauma.",
		icon = "rbxassetid://92765090140251", 
	},
	["ATMReceipt"] = {
		name = "ATM Receipt",
		description = "Atm receipt that shows Robbie Withdrew money from an ATM at 1:00 PM",
		icon = "rbxassetid://80340460844876", 
	},
	["GoldStatue"] = {
		name = "Greased Gold Statue",
		description = "Heavy Gold Statue used to strike the victim. grease was left on the handle",
		icon = "rbxassetid://87813547510287", 
	},
	["BankSecurityManual"] = {
		name = "Bank Security Manual",
		description = "Bank Security Manual for Security Staff. Key Points: NEVER take your eyes off your task. Vault Auto-Lock engages at 12:55 PM.",
		icon = "rbxassetid://108835564691375", 
	}

}

local evidence = {}

-- [[ HELPER FUNCTION ]] 
-- Gets the inventory safely by decoding the saved string
local function getInventory()
	local data = storyVariables.get("Inventory")
	if data and typeof(data) == "string" then
		return HttpService:JSONDecode(data)
	end
	return {}
end

function evidence.add(id: string)
	local item = evidenceDB[id]
	if not item then
		warn("Evidence ID " .. id .. " does not exist in database.")
		return
	end

	local inventory = getInventory()

	-- Avoid duplicates
	for _, ownedId in pairs(inventory) do
		if ownedId == id then return end
	end

	table.insert(inventory, id)

	-- [[ FIX: ENCODE TABLE TO STRING ]]
	storyVariables.set("Inventory", HttpService:JSONEncode(inventory))

	vnDebug.print("Added evidence: " .. item.name)
end

function evidence.remove(id: string)
	local inventory = getInventory()
	for i, ownedId in pairs(inventory) do
		if ownedId == id then
			table.remove(inventory, i)
			break
		end
	end
	-- [[ FIX: ENCODE TABLE TO STRING ]]
	storyVariables.set("Inventory", HttpService:JSONEncode(inventory))
end

function evidence.getOwnedItems()
	local inventory = getInventory()
	local fullItems = {}

	for _, id in pairs(inventory) do
		if evidenceDB[id] then
			local data = evidenceDB[id]
			data.id = id
			table.insert(fullItems, data)
		end
	end

	return fullItems
end

return evidence