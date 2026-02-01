local RunService = game:GetService("RunService")

local logging = RunService:IsStudio()

local vnDebug = {}

function vnDebug.print(...)
	if not logging then
		return
	end
	
	local formatString = string.rep("%*", select("#", ...))
	local sourceScript = debug.info(2, "s")
	local splitPath = string.split(sourceScript, ".")
	local outputString = `[{splitPath[#splitPath]}:{debug.info(2, "l")}] {string.format(formatString, ...)}`
	
	print(outputString)
end

return vnDebug