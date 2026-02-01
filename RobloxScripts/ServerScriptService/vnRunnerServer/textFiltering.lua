local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vnDebug = require(ReplicatedStorage:WaitForChild("shared").vnDebug)

local remotes = ReplicatedStorage.remotes

local textFiltering = {}

local function isValidUTF8(str)
	local success = pcall(function()
		for pos, codepoint in utf8.codes(str) do
			-- This loop only runs if UTF-8 decoding is valid
		end
	end)

	return success
end

function textFiltering.init()
	remotes.filterInput.OnServerInvoke = function(player, text: string)
		vnDebug.print(`Filtering "{tostring(text)}"`)
		
		if not isValidUTF8(text) then
			warn(`Text contains invalid UTF-8`)
			return false, nil
		end
		
		local success, filterResult
		local success, errorMessage = pcall(function()
			filterResult = TextService:FilterStringAsync(text, player.UserId)
		end)
		if not success then
			warn(`Error filtering text: {errorMessage}`)
			return false, nil
		end
		local filteredText = filterResult:GetNonChatStringForUserAsync(player.UserId)
		vnDebug.print(`Filtered text: "{filteredText}"`)
		return true, filteredText
	end
end

return textFiltering