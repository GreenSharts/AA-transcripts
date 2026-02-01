-- script located inside "Clara Case" model
-- Ensure RunContext is set to "Client" in Properties!

local model = script.Parent
local animationId = "rbxassetid://140020444079895" -- The ID from your previous script

-- Wait for the humanoid to exist
local humanoid = model:WaitForChild("Humanoid")

-- Safety Check: Ensure the Animator object exists
-- (Roblox needs this to replicate animations correctly)
local animator = humanoid:FindFirstChild("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

-- Create the animation object
local anim = Instance.new("Animation")
anim.AnimationId = animationId

-- Load and Play
local track = animator:LoadAnimation(anim)
track.Looped = true
track.Priority = Enum.AnimationPriority.Idle -- Lowest priority so other animations can override it
track:Play()

print("Clara idle animation started locally on client.")

-- OPTIONAL: Keep it playing if she is reset or refreshed
humanoid.Died:Connect(function()
	track:Stop()
end)