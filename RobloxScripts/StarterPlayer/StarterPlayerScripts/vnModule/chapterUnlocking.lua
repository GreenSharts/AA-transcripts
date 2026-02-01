local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerData = require("./playerData")

local remotes = ReplicatedStorage:WaitForChild("remotes")

type chapterUnlockedCallback = (chapterIndex: number) -> ()
local chapterUnlockedCallbacks: {chapterUnlockedCallback} = {}

local chapterUnlocking = {}

function chapterUnlocking.onChapterUnlocked(callback: chapterUnlockedCallback)
	table.insert(chapterUnlockedCallbacks, callback)
end

function chapterUnlocking.unlockChapter(chapterIndex: number)
	local chaptersUnlocked = playerData.get().chaptersUnlocked
	if table.find(chaptersUnlocked, chapterIndex) then
		-- Chapter is already unlocked
		return
	end
	
	table.insert(chaptersUnlocked, chapterIndex)
	remotes.unlockChapter:FireServer(chapterIndex)
	for _,callback in chapterUnlockedCallbacks do
		task.spawn(callback, chapterIndex)
	end
end

return chapterUnlocking