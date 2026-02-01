local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local vnSystem = workspace:WaitForChild("vnSystem")
local configuration = vnSystem:WaitForChild("configuration")

local camera = {}
local currentCameraPart: Part? = nil
local originalCameraType = nil
local originalCameraCFrame = nil
local is3DMode = false

-- Camera transition types
export type CameraTransitionInfo = {
	type: "cut" | "smooth" | "zoom",
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?
}

-- Gets a camera part by name
local function getCameraPart(cameraName: string): Part?
	local cameraPart = workspace:FindFirstChild(cameraName)
	if cameraPart and cameraPart:IsA("Part") then
		return cameraPart
	end
	
	-- Try with "cam" prefix if not found
	cameraPart = workspace:FindFirstChild("cam" .. cameraName)
	if cameraPart and cameraPart:IsA("Part") then
		return cameraPart
	end
	
	return nil
end

-- Enables 3D camera mode
function camera.enable3DMode()
	if is3DMode then return end
	
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	
	local camera = workspace.CurrentCamera
	originalCameraType = camera.CameraType
	originalCameraCFrame = camera.CFrame
	
	camera.CameraType = Enum.CameraType.Scriptable
	is3DMode = true
end

-- Disables 3D camera mode and returns to normal
function camera.disable3DMode()
	if not is3DMode then return end
	
	local camera = workspace.CurrentCamera
	if originalCameraType then
		camera.CameraType = originalCameraType
	end
	if originalCameraCFrame then
		camera.CFrame = originalCameraCFrame
	end
	
	is3DMode = false
	currentCameraPart = nil
end

-- Sets camera to a specific camera part
function camera.setCamera(cameraName: string, transitionInfo: CameraTransitionInfo?): boolean
	local cameraPart = getCameraPart(cameraName)
	if not cameraPart then
		warn(`Camera part "{cameraName}" or "cam{cameraName}" not found in workspace`)
		return false
	end
	
	
	camera.enable3DMode()
	
	local camera = workspace.CurrentCamera
	local targetCFrame = cameraPart.CFrame
	
	if not transitionInfo or transitionInfo.type == "cut" then
		-- Instant cut
		camera.CFrame = targetCFrame
	else
		-- Smooth transition
		local duration = transitionInfo.duration or 1.0
		local easingStyle = transitionInfo.easingStyle or Enum.EasingStyle.Sine
		local easingDirection = transitionInfo.easingDirection or Enum.EasingDirection.InOut
		
		local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
		local tween = TweenService:Create(camera, tweenInfo, {CFrame = targetCFrame})
		tween:Play()
	end
	
	currentCameraPart = cameraPart
	return true
end

-- Gets the current camera part
function camera.getCurrentCamera(): Part?
	return currentCameraPart
end

-- Checks if 3D mode is enabled
function camera.is3DModeEnabled(): boolean
	return is3DMode
end

-- Creates a smooth camera shake effect
function camera.shake(intensity: number?, duration: number?): ()
	if not is3DMode or not currentCameraPart then return function() end end
	
	intensity = intensity or 5
	duration = duration or 0.5
	
	local camera = workspace.CurrentCamera
	local originalCFrame = camera.CFrame
	local startTime = tick()
	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		if elapsed >= duration then
			connection:Disconnect()
			camera.CFrame = originalCFrame
			return
		end
		
		local randomOffset = Vector3.new(
			(math.random() - 0.5) * intensity,
			(math.random() - 0.5) * intensity,
			(math.random() - 0.5) * intensity
		)
		
		camera.CFrame = originalCFrame * CFrame.new(randomOffset)
	end)
	
	return function()
		if connection then connection:Disconnect() end
		camera.CFrame = originalCFrame
	end
end

return camera