local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local IsStudio = RunService:IsStudio()

local result = nil

local function getApiServicesEnabled()
	local has_internet = true
	local api_services_enabled = true

	if IsStudio == true then
		local status, message = pcall(function()
			-- This will error if current instance has no Studio API access:
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)
		local no_internet_access = status == false and string.find(message, "ConnectFail", 1, true) ~= nil
		if no_internet_access == true then
			has_internet = false
		end
		if status == false and
			(string.find(message, "403", 1, true) ~= nil or -- Cannot write to DataStore from studio if API access is not enabled
				string.find(message, "must publish", 1, true) ~= nil or -- Game must be published to access live keys
				no_internet_access == true) then -- No internet access

			api_services_enabled = false
		end
	end
	-- Taken from post: https://devforum.roblox.com/t/how-would-i-verify-within-a-script-whether-access-to-api-services-is-enabled-or-not/1162142/6?u=steven_scripts

	if not api_services_enabled then
		warn(`Studio access to API services is disabled; data for this playtest will not save. You can enable this in Game Settings > Security.`)
	end

	return api_services_enabled
end

return function()
	if result == nil then
		result = getApiServicesEnabled()
	end
	return result
end