doorOpen = script.Parent.Parent.DoorOpen
running = script.Parent.Parent.Running
locked = script.Parent.Parent.Locked
changingState = false

		
		function onClicked()
		if doorOpen.Value == true and changingState == false then
			changingState = true
			for i = 1, 18 do
				script.Parent:SetPrimaryPartCFrame(script.Parent.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(5.5), 0))
				wait()
			end
			changingState = false
			doorOpen.Value = false
		elseif changingState == false then
			doorOpen.Value = true
			running.Value = false
			changingState = true
			for i = 1, 18 do
				script.Parent:SetPrimaryPartCFrame(script.Parent.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-5.5), 0))
				wait()
			end
			changingState = false
		end
		wait()
		end
script.Parent.Keyhole.ClickDetector.MouseClick:connect(onClicked)
