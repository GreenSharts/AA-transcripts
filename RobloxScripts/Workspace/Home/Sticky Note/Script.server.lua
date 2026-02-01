function onClick(click)
	for i,v in pairs (script.Parent:GetChildren()) do
		if v.ClassName == "ScreenGui" then
			local c = v:Clone()
			c.Parent = click.PlayerGui
		end
	end
end
script.Parent.ClickDetector.MouseClick:connect(onClick)