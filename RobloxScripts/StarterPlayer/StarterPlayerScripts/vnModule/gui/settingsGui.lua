local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("remotes")

local vnSystem = workspace:WaitForChild("vnSystem")
local settingsFolder = vnSystem:WaitForChild("settings")

local guiVariables = require(script.Parent.guiVariables)
local vnGui = guiVariables.vnGui
local settingsFrame = guiVariables.settingsFrame

local setUpButtonSounds = require(script.Parent.Parent.util.setUpButtonSounds)

local slider = require(script.Parent.guiObjects.slider)
local holdButton = require(script.Parent.guiObjects.holdButton)
local messagePrompt = require(script.Parent.guiObjects.messagePrompt)
local currentMenu = require(script.Parent.currentMenu)

local closeButton = require(script.Parent.guiObjects.closeButton)

local settingsGui = {}

function settingsGui.init()
	-- Sound
	local bgmSlider = slider.new({
		min = 0,
		max = 2,
		increment = 0.05,
		markers = 5,
		valueObject = settingsFolder.sound.bgm,
		knobReleasedCallback = function()
			remotes.setSetting:FireServer("sound", "bgm", settingsFolder.sound.bgm.Value)
		end,
	})
	bgmSlider.Size = UDim2.new(1, -150, 1, 0)
	bgmSlider.Position = UDim2.new(0, 150, 0, 0)
	bgmSlider.Parent = settingsFrame.List.Sound.BGM

	local sfxSlider = slider.new({
		min = 0,
		max = 2,
		increment = 0.05,
		markers = 5,
		valueObject = settingsFolder.sound.sfx,
		knobReleasedCallback = function()
			remotes.setSetting:FireServer("sound", "sfx", settingsFolder.sound.sfx.Value)
		end,
	})
	sfxSlider.Size = UDim2.new(1, -150, 1, 0)
	sfxSlider.Position = UDim2.new(0, 150, 0, 0)
	sfxSlider.Parent = settingsFrame.List.Sound.SFX
	
	-- Visuals
	local scrollSpeedSlider = slider.new({
		min = 0.5,
		max = 2,
		increment = 0.05,
		markers = 7,
		valueObject = settingsFolder.visuals.scrollSpeed,
		knobReleasedCallback = function()
			remotes.setSetting:FireServer("visuals", "scrollSpeed", settingsFolder.visuals.scrollSpeed.Value)
		end,
	})
	scrollSpeedSlider.Size = UDim2.new(1, -150, 1, 0)
	scrollSpeedSlider.Position = UDim2.new(0, 150, 0, 0)
	scrollSpeedSlider.Parent = settingsFrame.List.Visuals.ScrollSpeed

	-- Misc
	local deleteDataButton = holdButton.new({
		holdTime = if RunService:IsStudio() then 2 else 10,
		callback = function()
			remotes.deleteData:FireServer()
		end,
	})
	deleteDataButton.Text = "Hold to delete save data"
	deleteDataButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
	deleteDataButton.TextColor3 = Color3.new(1, 1, 1)
	deleteDataButton.Size = UDim2.fromOffset(300, 40)
	deleteDataButton.Position = UDim2.fromScale(0.5, 0)
	deleteDataButton.AnchorPoint = Vector2.new(0.5, 0)
	deleteDataButton.Parent = settingsFrame.List.Miscellaneous.DeleteData
	
	closeButton.new().Parent = settingsFrame
end

return settingsGui