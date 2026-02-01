-- Handles the visibility of whichever menu is currently open to ensure only one menu is visible at a time.
-- For example, opening the load screen while the settings menu is open will automatically close the settings.

local current: Frame | ScrollingFrame = nil

local currentMenu = {}

-- Set to nil to close current menu.
function currentMenu.set(new: Frame | ScrollingFrame | nil)
	if current then
		current.Visible = false
	end
	if new ~= nil then
		current = new
		current.Visible = true
	end
end

return currentMenu