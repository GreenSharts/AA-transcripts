-- Handles the Ace Attorney style Court Record
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guiVariables = require(script.Parent.guiVariables)
local currentMenu = require(script.Parent.currentMenu)
local setUpButtonSounds = require(script.Parent.Parent.util.setUpButtonSounds)
local closeButton = require(script.Parent.guiObjects.closeButton)
local evidence = require(script.Parent.Parent.evidence) 

local vnGui = guiVariables.vnGui
local courtRecordFrame = guiVariables.courtRecordFrame
local evidenceList = courtRecordFrame.EvidenceList
local descriptionBox = courtRecordFrame.DescriptionBox
local presentButton = courtRecordFrame.PresentButton

local selectedEvidenceId = nil

local courtRecordGui = {}

function courtRecordGui.close()
	currentMenu.set(nil)
end

function courtRecordGui.open()
	currentMenu.set(courtRecordFrame)
	courtRecordGui.refresh()
end

function courtRecordGui.refresh()
	-- Clear list
	for _, child in evidenceList:GetChildren() do
		if child:IsA("ImageButton") then child:Destroy() end
	end

	-- Reset description
	descriptionBox.ItemName.Text = "Select an item"
	descriptionBox.Description.Text = ""
	descriptionBox.Icon.Image = ""
	presentButton.Visible = false 
	selectedEvidenceId = nil

	-- Populate items
	local ownedItems = evidence.getOwnedItems()

	for i, item in pairs(ownedItems) do
		local button = Instance.new("ImageButton")
		button.Name = item.id
		button.Image = item.icon
		button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		button.Size = UDim2.fromOffset(80, 80)
		button.Parent = evidenceList

		button.Activated:Connect(function()
			selectedEvidenceId = item.id
			descriptionBox.ItemName.Text = item.name
			descriptionBox.Description.Text = item.description
			descriptionBox.Icon.Image = item.icon
			presentButton.Visible = true
		end)
		setUpButtonSounds(button)
	end
end

function courtRecordGui.init()
	local closeBtn = closeButton.new()
	closeBtn.Parent = courtRecordFrame

	presentButton.Activated:Connect(function()
		if selectedEvidenceId then
			print("GUI: Presenting " .. selectedEvidenceId)

			-- 1. Find the Mailbox
			local signalFolder = ReplicatedStorage:FindFirstChild("EvidenceSignals")
			if not signalFolder then
				-- Create it if it's missing (failsafe)
				signalFolder = Instance.new("Folder")
				signalFolder.Name = "EvidenceSignals"
				signalFolder.Parent = ReplicatedStorage
			end

			-- 2. CREATE THE NAMED OBJECT
			-- If ID is "ATMReceipt", this creates an object named "ATMReceipt"
			local signal = Instance.new("StringValue")
			signal.Name = selectedEvidenceId 
			signal.Parent = signalFolder

			print("GUI: Created object named '" .. selectedEvidenceId .. "' in ReplicatedStorage")

			courtRecordGui.close()
		end
	end)
	setUpButtonSounds(presentButton)
end

return courtRecordGui