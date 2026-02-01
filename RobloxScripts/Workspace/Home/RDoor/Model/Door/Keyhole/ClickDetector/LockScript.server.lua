while true do
if script.Parent.Parent.Parent.Parent.Locked.Value == true then
	script.Parent.MaxActivationDistance = 0
else
		script.Parent.MaxActivationDistance = 12
end
wait()
end