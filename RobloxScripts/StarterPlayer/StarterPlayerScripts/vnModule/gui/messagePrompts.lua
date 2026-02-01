local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("remotes")

local guiVariables = require(script.Parent.guiVariables)
local vnGui = guiVariables.vnGui

local messagePrompt = require(script.Parent.guiObjects.messagePrompt)

local messagePrompts = {}

function messagePrompts.showMessagePrompt(text: string)
	local prompt = messagePrompt.new({text = text})
	prompt.Parent = vnGui
end

function messagePrompts.init()
	remotes.showMessagePrompt.OnClientEvent:Connect(function(text: string)
		messagePrompts.showMessagePrompt(text)
	end)
end

return messagePrompts