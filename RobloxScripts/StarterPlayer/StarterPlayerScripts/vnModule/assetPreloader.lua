local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnSystem = workspace:WaitForChild("vnSystem")

local setUpButtonSounds = require(script.Parent.util.setUpButtonSounds)
local guiVariables = require(script.Parent.gui.guiVariables)
local vnDebug = require(sharedFolder.vnDebug)

local vnGui = guiVariables.vnGui
local loadingScreen = guiVariables.loadingScreen
local progressBar = loadingScreen.ProgressBar
local skipButton = loadingScreen.Skip

local assetPreloader = {}

function assetPreloader.preload()
	loadingScreen.Visible = true
	
	local preloaderImageLabel = Instance.new("ImageLabel")
	preloaderImageLabel.Name = "PreloaderImageLabel"
	preloaderImageLabel.BackgroundTransparency = 1
	preloaderImageLabel.ImageTransparency = 0.99
	preloaderImageLabel.Size = UDim2.fromOffset(1, 1)
	preloaderImageLabel.Parent = vnGui
	
	local imageTextures: {string} = {}
	local preloadList: {Instance} = {}
	for _,v in vnSystem:GetDescendants() do
		if v:IsA("Sound") then
			table.insert(preloadList, v)
		elseif v:IsA("ImageLabel") then
			table.insert(preloadList, v.Image)
			table.insert(imageTextures, v.Image)
		end
	end
	
	task.spawn(function()
		for _,texture in imageTextures do
			preloaderImageLabel.Image = texture
			task.wait()
		end
		preloaderImageLabel:Destroy()
	end)
	
	local totalAssetsToLoad = #preloadList
	local assetsLoaded = 0
	local function preloadCallback(assetId: number, assetFetchStatus: Enum.AssetFetchStatus)
		-- vnDebug.print(`Loading {assetId}`)
		assetsLoaded += 1
		progressBar.Fill.Size = UDim2.fromScale(assetsLoaded/totalAssetsToLoad, 1)
		loadingScreen.Status.Text = `Preloading assets... ({assetsLoaded}/{totalAssetsToLoad})`
	end
	
	local loaded, skipped = false, false
	
	setUpButtonSounds(skipButton)
	skipButton.Activated:Connect(function()
		skipped = true
	end)
	
	vnDebug.print("Preloading assets...")
	
	task.delay(10, function()
		skipButton.Visible = true
	end)
	
	task.spawn(function()
		ContentProvider:PreloadAsync(preloadList, preloadCallback)
		loaded = true
	end)
	
	while not loaded and not skipped do
		task.wait()
	end
	
	if loaded then
		vnDebug.print("Loaded!")
	else
		vnDebug.print("Loading skipped.")
	end
	
	loadingScreen.Visible = false
end

return assetPreloader