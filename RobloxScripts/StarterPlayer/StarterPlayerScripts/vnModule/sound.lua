local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_AUDIO_TRACKS = 10

local vnSystem = workspace:WaitForChild("vnSystem")
local settingsFolder = vnSystem:WaitForChild("settings")
local soundGroups = vnSystem:WaitForChild("soundGroups")
local sounds = vnSystem:WaitForChild("sounds")
local sharedFolder = ReplicatedStorage:WaitForChild("shared")

local vnDebug = require(sharedFolder.vnDebug)

local soundsPlayingInTracks: {[number]: Sound} = {}
local allClonedSoundsPlaying: {[Sound]: boolean?} = {}

local sound = {}

local function getSoundFromSoundPath(soundPath: string)
	local searchPoint = vnSystem.sounds
	local instanceNames = string.split(soundPath, "/")
	for _,name in instanceNames do
		searchPoint = searchPoint:FindFirstChild(name)
		if searchPoint == nil then
			warn(`Invalid sound path: "{soundPath}". Double check your spelling.`)
			return
		end
	end
	if not searchPoint:IsA("Sound") then
		warn(`Sound path "{soundPath}" does not lead to a sound.`)
		return
	end

	return searchPoint
end

local function getSoundPathFromSound(sound: Sound)
	assert(sound:IsDescendantOf(sounds), "Sound is not in vnSystem")
	local soundPath = sound.Name
	local parent = sound
	while true do
		parent = parent.Parent
		if parent == sounds then
			break
		end
		soundPath = parent.Name.."/"..soundPath
	end
	return soundPath
end

local function fadeOutSound(sound: Sound)
	TweenService:Create(sound, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Volume = 0}):Play()
	task.delay(.5, function()
		sound:Stop()
	end)
end

local function fadeInSound(sound: Sound)
	local tween = TweenService:Create(sound, TweenInfo.new(.5, Enum.EasingStyle.Linear), {Volume = sound.Volume})
	sound.Volume = 0
	tween:Play()
end

-- sound: The sound to be played.
-- track: Playing a sound in a track where a sound is already playing will stop the old sound. Useful for sounds that you don't want overlapping, such as voicelines or music.
-- fade: When set to true and used with a track, fades out the old sound and fades in the new sound.
function sound.play(soundPath: string, track: number?, fade: boolean?)
	local soundObject = getSoundFromSoundPath(soundPath)
	if soundObject == nil then
		return
	end
	
	vnDebug.print(`Playing sound {soundPath}`)
	
	local newSound = soundObject:Clone()
	
	if track ~= nil then
		if track < 1 or track > MAX_AUDIO_TRACKS then
			warn(`Track {track} is out of range. Clamping to nearest bound.`)
			track = math.clamp(track, 1, MAX_AUDIO_TRACKS)
		end
		
		local previousSound = soundsPlayingInTracks[track]
		if previousSound ~= nil then
			if fade then
				fadeOutSound(previousSound)
				fadeInSound(newSound)
			else
				previousSound:Stop()
			end
		end
		
		soundsPlayingInTracks[track] = newSound
	end
	
	newSound.Parent = workspace
	newSound:Play()
	
	allClonedSoundsPlaying[newSound] = true
	
	local function onClonedSoundStopped()
		if track ~= nil and soundsPlayingInTracks[track] == newSound then
			soundsPlayingInTracks[track] = nil
		end
		newSound:Destroy()
		allClonedSoundsPlaying[newSound] = nil
	end
	newSound.Stopped:Connect(onClonedSoundStopped)
	newSound.Ended:Connect(onClonedSoundStopped)
	
	return newSound
end

-- Stops all sounds.
function sound.stopAll()
	vnDebug.print(`Stopping all sounds`)
	for clonedSound,_ in pairs(allClonedSoundsPlaying) do
		clonedSound:Stop()
	end
end

-- Stops the sound playing in a track.
function sound.stopTrack(track: number, fade: boolean?)
	vnDebug.print(`Stopping track {track}`)
	local soundObject = soundsPlayingInTracks[track]
	if soundObject == nil then
		return
	end
	if fade then
		fadeOutSound(soundObject)
	else
		soundObject:Stop()
	end
end

function sound.init()
	local bgmValue = settingsFolder.sound.bgm
	local sfxValue = settingsFolder.sound.sfx
	
	bgmValue:GetPropertyChangedSignal("Value"):Connect(function()
		soundGroups.bgm.Volume = bgmValue.Value
	end)
	
	sfxValue:GetPropertyChangedSignal("Value"):Connect(function()
		soundGroups.sfx.Volume = sfxValue.Value
	end)
end

return sound