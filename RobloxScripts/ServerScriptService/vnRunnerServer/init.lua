local StarterPlayer = game:GetService("StarterPlayer")

local dataStores = require(script.dataStores)
local playerSettings = require(script.playerSettings)
local storySaves = require(script.storySaves)
local chapterUnlocking = require(script.chapterUnlocking)
local textFiltering = require(script.textFiltering)

dataStores.init()
playerSettings.init()
storySaves.init()
chapterUnlocking.init()
textFiltering.init()