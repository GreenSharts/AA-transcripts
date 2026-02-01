function onClicked()

if script.Parent.Parent.Tripped.Value == false then
script.Parent.Click:Play()
script.Parent.ClickDetector.MaxActivationDistance = 0
script.Parent.Parent.Reset.ClickDetector.MaxActivationDistance = 12
script.Parent.Parent.Tripped.Value = true

end
end
script.Parent.ClickDetector.MouseClick:connect(onClicked)
