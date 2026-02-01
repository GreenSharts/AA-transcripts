local hours, minutes = string.match(game.Lighting.TimeOfDay, "^(%d%d):(%d%d)")
script.Parent.HourHand.CFrame = script.Parent.HandCenter.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, 0, math.rad(hours * 30)) * CFrame.new(0, 0.2, 0)
script.Parent.MinuteHand.CFrame = script.Parent.HandCenter.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, 0, math.rad(minutes * 6)) * CFrame.new(0, 0.3, 0)

game.Lighting.Changed:connect(function()
	local hours, minutes = string.match(game.Lighting.TimeOfDay, "^(%d%d):(%d%d)")
	script.Parent.HourHand.CFrame = script.Parent.HandCenter.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, 0, math.rad((hours * 30)+ (minutes * 0.5))) * CFrame.new(0, 0.2, 0)
	script.Parent.MinuteHand.CFrame = script.Parent.HandCenter.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, 0, math.rad(minutes * 6)) * CFrame.new(0, 0.3, 0)
end)
