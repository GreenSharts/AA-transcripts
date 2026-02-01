local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local vnSystem = workspace:WaitForChild("vnSystem")
local sounds = vnSystem:WaitForChild("sounds")
local configuration = vnSystem:WaitForChild("configuration")

local theme = require(script.Parent.Parent.theme)

local slider = {}

type props = {
	min: number,
	max: number,
	increment: number?,
	markers: number?,
	valueObject: NumberValue,
	knobReleasedCallback: (() -> ())?,
}
function slider.new(props: props)
	local min, max, increment, valueObject, markers = props.min, props.max, props.increment, props.valueObject, props.markers
	
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = "Slider"
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Size = UDim2.fromOffset(600, 30)

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.BackgroundColor3 = Color3.new(0, 0, 0)
	track.BorderSizePixel = 0
	track.Position = UDim2.fromScale(0, 0.5)
	track.Size = UDim2.new(1, 0, 0, 3)
	track.Parent = sliderFrame
	
	local minMarker = track:Clone()
	minMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	minMarker.Name = "MinMarker"
	minMarker.Size = UDim2.fromOffset(3, 10)
	minMarker.Position = UDim2.fromScale(0, 0.5)
	minMarker.Parent = track
	
	local minMarkerLabel = Instance.new("TextLabel")
	minMarkerLabel.Name = "MarkerLabel"
	minMarkerLabel.BackgroundTransparency = 1
	minMarkerLabel.Text = tostring(math.round(min * 100) / 100)
	minMarkerLabel.TextSize = 16
	minMarkerLabel.TextColor3 = Color3.new(1, 1, 1)
	minMarkerLabel.Font = Enum.Font.SourceSans
	minMarkerLabel.Size = UDim2.fromOffset(500, 20)
	minMarkerLabel.AnchorPoint = Vector2.new(0.5, 0)
	minMarkerLabel.Position = UDim2.fromScale(0.5, 1)
	minMarkerLabel.Parent = minMarker
	theme.applyThemeToInstance(minMarkerLabel)
	
	local maxMarker = minMarker:Clone()
	maxMarker.Position = UDim2.fromScale(1, 0.5)
	maxMarker.MarkerLabel.Text = tostring(math.round(max * 100) / 100)
	maxMarker.Parent = track
	
	if markers ~= nil and markers > 2 then
		for i=2, markers - 1 do
			local newMarker = minMarker:Clone()
			local rawMarkerValue = min + (i - 1) * ((max - min) / (markers - 1))
			local roundedMarkerValue = math.round(rawMarkerValue*100)/100
			local xScalePosition = (rawMarkerValue - min) / (max - min)
			
			newMarker.Position = UDim2.fromScale(xScalePosition, 0.5)
			newMarker.MarkerLabel.Text = tostring(roundedMarkerValue)
			newMarker.Parent = track
		end
	end
	
	local lastKnobXScalePosition = math.map(valueObject.Value, min, max, 0, 1)
	
	local knob = Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderColor3 = Color3.fromRGB(0, 0, 0)
	knob.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	knob.Position = UDim2.fromScale(lastKnobXScalePosition, 0.5)
	knob.Size = UDim2.new(0, 15, 0, 30)
	knob.Text = "||"
	knob.TextColor3 = Color3.fromRGB(0, 0, 0)
	knob.TextSize = 14
	knob.Parent = sliderFrame
	
	local knobHeld = false
	local knobMoveConnection
	
	local function knobDown()
		if knobHeld then
			return
		end
		knobHeld = true
		
		knobMoveConnection = mouse.Move:Connect(function()
			local pixelsFromStart = mouse.X - track.AbsolutePosition.X
			local rawXPercentage = math.clamp(pixelsFromStart / track.AbsoluteSize.X, 0, 1)
			
			local newXScalePosition
			if increment ~= nil then
				local incrementScale = increment / (max - min)
				newXScalePosition = math.round(rawXPercentage/incrementScale)*incrementScale
			else
				newXScalePosition = rawXPercentage
			end
			
			if lastKnobXScalePosition ~= newXScalePosition then
				if increment ~= nil then
					local clickSound = sounds.sfx.gui.click:Clone()
					clickSound.PlayOnRemove = true
					clickSound.PlaybackSpeed = 0.8 + 0.4*newXScalePosition
					clickSound.Parent = workspace
					clickSound:Destroy()
				end
				
				valueObject.Value = newXScalePosition * (max - min) + min
				
				lastKnobXScalePosition = newXScalePosition
			end
		end)
		
		sounds.sfx.gui.buttonDown:Play()
	end
	
	local function knobUp()
		if not knobHeld then
			return
		end
		knobHeld = false
		knobMoveConnection:Disconnect()
		
		sounds.sfx.gui.buttonUp:Play()
		
		if props.knobReleasedCallback ~= nil then
			props.knobReleasedCallback()
		end
	end
	
	local function valueObjectChanged()
		local newValue = valueObject.Value
		local percentage = math.map(newValue, min, max, 0, 1)
		knob.Position = UDim2.fromScale(percentage, 0.5)
	end
	
	knob.MouseButton1Down:Connect(knobDown)
	knob.MouseButton1Up:Connect(knobUp)
	mouse.Button1Up:Connect(knobUp)
	valueObject:GetPropertyChangedSignal("Value"):Connect(valueObjectChanged)
	
	return sliderFrame
end

return slider