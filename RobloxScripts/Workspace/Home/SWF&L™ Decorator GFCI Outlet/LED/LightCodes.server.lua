function Active()
if script.Parent.Parent.Tripped.Value == false then
script.Parent.BrickColor = BrickColor.new("Really black")
script.Parent.Material = Enum.Material.SmoothPlastic
wait(2)
script.Parent.BrickColor = BrickColor.new("Lime green")
script.Parent.Material = Enum.Material.Neon
end

if script.Parent.Parent.Tripped.Value == true then
script.Parent.BrickColor = BrickColor.new("Really black")
script.Parent.Material = Enum.Material.SmoothPlastic
wait()
script.Parent.BrickColor = BrickColor.new("CGA brown")
script.Parent.Material = Enum.Material.Neon
wait()
script.Parent.BrickColor = BrickColor.new("Really black")
script.Parent.Material = Enum.Material.SmoothPlastic
wait()
script.Parent.BrickColor = BrickColor.new("CGA brown")
script.Parent.Material = Enum.Material.Neon
end
end

script.Parent.Parent.Tripped.Changed:connect(Active)