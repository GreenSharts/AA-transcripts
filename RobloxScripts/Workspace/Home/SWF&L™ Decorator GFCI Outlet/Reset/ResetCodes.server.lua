function onClicked()

if script.Parent.Parent.Tripped.Value == true then
script.Parent.Parent.Tripped.Value = false
script.Parent.Click:Play()
script.Parent.ClickDetector.MaxActivationDistance = 0
wait(2)
script.Parent.Power:Play()
script.Parent.Parent.Test.ClickDetector.MaxActivationDistance = 12


end
end
script.Parent.ClickDetector.MouseClick:connect(onClicked)
