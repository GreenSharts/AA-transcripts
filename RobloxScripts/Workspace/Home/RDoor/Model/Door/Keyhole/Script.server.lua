Closed = false
script.Parent.Touched:connect(function(P)
	if P ~= nil and P.Parent ~= nil and P.Parent:FindFirstChild("CardNumber") ~= nil  and P.Parent.CardNumber.Value == 1340 then
	if Closed == false then
		Closed = 1
script.Parent.Parent.Parent.Locked.Value = true
		wait(1)
		Closed = true
		return
	end
	if Closed == true then
		Closed = 1
script.Parent.Parent.Parent.Locked.Value = false
		wait(1)
		Closed = false
		return
	end
	
	end
end)