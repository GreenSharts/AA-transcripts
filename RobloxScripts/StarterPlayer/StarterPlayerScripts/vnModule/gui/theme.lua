local guiVariables = require("./guiVariables")
local vnGui = guiVariables.vnGui

local vnSystem = workspace:WaitForChild("vnSystem")

local theme = {}

local function hasProperty(instance: Instance, propertyName: string)
	return pcall(function()
		local property = instance[propertyName]
		if typeof(property) == "Instance" then
			error()
		end
	end)
end

function theme.getThemeFolder()
	local themePreset = vnSystem.configuration.theme.themePreset.Value
	if themePreset == "none" then
		return vnSystem.configuration.theme
	else
		local themePresetFolder = vnSystem.themePresets:FindFirstChild(themePreset)
		if themePresetFolder == nil then
			error(`Theme preset "{themePreset}" does not exist.`)
		end
		return themePresetFolder
	end
end

function theme.applyTheme()
	for _,v in vnGui:GetDescendants() do
		if v:IsA("Frame") or v:IsA("ScrollingFrame") then
			theme.applyThemeToInstance(v)
		elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
			theme.applyThemeToInstance(v)
		elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
			theme.applyThemeToInstance(v)
		end
	end
end

function theme.applyThemeToInstance(guiInstance: GuiBase2d)
	if guiInstance == guiVariables.titleCardFrame then
		local themeFolder = theme.getThemeFolder()
		local template = themeFolder:FindFirstChild("titleCardTemplate")
		if template ~= nil then
			guiInstance.Background.Image = template.Background.Image
			guiInstance.Background.ImageColor3 = template.Background.ImageColor3
			guiInstance.Background.BorderColor3 = template.Background.BorderColor3
			guiInstance.Background.ScaleType = template.Background.ScaleType
			guiInstance.Background.TileSize = template.Background.TileSize
			guiInstance.Background.SliceCenter = template.Background.SliceCenter
			guiInstance.Background.SliceScale = template.Background.SliceScale
			guiInstance.Background.BackgroundColor3 = template.Background.BackgroundColor3
			guiInstance.Background.BorderSizePixel = template.Background.BorderSizePixel
			guiInstance.Background.BorderMode = template.Background.BorderMode
			guiInstance.Background.BackgroundTransparency = template.Background.BackgroundTransparency
			for _,v in template.Background:GetChildren() do
				v:Clone().Parent = guiInstance.Background
			end
			
			guiInstance.Title.TextColor3 = template.Title.TextColor3
			guiInstance.Title.TextStrokeColor3 = template.Title.TextStrokeColor3
			guiInstance.Title.BackgroundColor3 = template.Title.BackgroundColor3
			guiInstance.Title.BorderColor3 = template.Title.BorderColor3
			guiInstance.Title.BorderSizePixel = template.Title.BorderSizePixel
			guiInstance.Title.BorderMode = template.Title.BorderMode
			guiInstance.Title.TextTransparency = template.Title.TextTransparency
			guiInstance.Title.TextStrokeTransparency = template.Title.TextStrokeTransparency
			guiInstance.Title.BackgroundTransparency = template.Title.BackgroundTransparency
			guiInstance.Title.TextScaled = template.Title.TextScaled
			guiInstance.Title.TextWrapped = template.Title.TextWrapped
			guiInstance.Title.Size = template.Title.Size
			guiInstance.Title.Position = template.Title.Position
			guiInstance.Title.AnchorPoint = template.Title.AnchorPoint
			guiInstance.Title.FontFace = template.Title.FontFace
			guiInstance.Title.TextXAlignment = template.Title.TextXAlignment
			guiInstance.Title.TextYAlignment = template.Title.TextYAlignment
			for _,v in template.Title:GetChildren() do
				v:Clone().Parent = guiInstance.Title
			end
		end
	end
	
	if guiInstance:GetAttribute("noTheme") == true then
		return
	end
	
	local themeFolder = theme.getThemeFolder()
	local propertiesToCheck: {string}
	local template: GuiBase2d
	if guiInstance:IsA("Frame") or guiInstance:IsA("ScrollingFrame") then
		template = themeFolder.frameTemplate
		propertiesToCheck = {
			"BackgroundTransparency",
			"BackgroundColor3",
			"BorderColor3",
			"BorderMode",
			"BorderSizePixel",
		}
	elseif guiInstance:IsA("TextLabel") or guiInstance:IsA("TextButton") or guiInstance:IsA("TextBox") then
		template = themeFolder.textTemplate
		propertiesToCheck = {
			"BackgroundTransparency",
			"BackgroundColor3",
			"BorderColor3",
			"BorderMode",
			"BorderSizePixel",
			"TextColor3",
			"TextStrokeColor3",
			"TextTransparency",
			"TextStrokeTransparency",
			"Font",
		}
	elseif guiInstance:IsA("ImageLabel") or guiInstance:IsA("ImageButton") then
		template = themeFolder.imageTemplate
		propertiesToCheck = {
			"BackgroundTransparency",
			"BackgroundColor3",
			"BorderColor3",
			"BorderMode",
			"BorderSizePixel",
		}
	end
	
	local ignoreThemeProperties: {string} = {}
	local ignoreThemePropertiesAttribute = guiInstance:GetAttribute("ignoreThemeProperties")
	if ignoreThemePropertiesAttribute ~= nil then
		ignoreThemeProperties = string.split(ignoreThemePropertiesAttribute, ",")
	end
	
	local ignoreThemeChildren: {string} = {}
	local ignoreThemeChildrenAttribute = guiInstance:GetAttribute("ignoreThemeChildren")
	if ignoreThemeChildrenAttribute ~= nil then
		ignoreThemeChildren = string.split(ignoreThemeChildrenAttribute, ",")
	end
	
	local hasBackgroundTransparency = hasProperty(guiInstance, "BackgroundTransparency")
	
	for _,propertyName in propertiesToCheck do
		if table.find(ignoreThemeProperties, propertyName) then
			continue
		end
		
		if hasProperty(guiInstance, propertyName) then
			if hasBackgroundTransparency and guiInstance.BackgroundTransparency == 1 and propertyName == "BackgroundTransparency" then
				continue
			end
			
			guiInstance[propertyName] = template[propertyName]
		end
	end
	
	for _,child in template:GetChildren() do
		local ignoreChild = false
		for _,class in ignoreThemeChildren do
			if child:IsA(class) then
				ignoreChild = true
				break
			end
		end
		if ignoreChild then
			continue
		end
		
		if hasBackgroundTransparency and guiInstance.BackgroundTransparency == 1 then
			if child:IsA("UIStroke") then
				continue
			elseif child:IsA("UIGradient") then
				continue
			elseif hasProperty(child, "BackgroundTransparency") and child.BackgroundTransparency < 1 then
				continue
			elseif hasProperty(child, "ImageTransparency") and child.ImageTransparency < 1 then
				continue
			end
		end
		
		if guiInstance:FindFirstChild(child.Name) then
			guiInstance[child.Name]:Destroy()
		end
		child:Clone().Parent = guiInstance
	end
	
	if (guiInstance:IsA("ImageLabel") or guiInstance:IsA("ImageButton")) and guiInstance:GetAttribute("colorableImage") == true then
		guiInstance.ImageColor3 = themeFolder.frameTemplate.BorderColor3
	end
end

return theme