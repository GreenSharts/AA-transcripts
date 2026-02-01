local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local clientToServer = remoteEvents:WaitForChild("ClientToServer")
local serverToClient = remoteEvents:WaitForChild("ServerToClient")

-- [[ 1. LIST OF MODELS TO CLEAN UP ]]
-- Define every character/model that appears in the cutscenes here
local SCENE_MODELS = {
	"JudgeV1",
	"Percy Petty",
	"Robbie Banks",
	"Clara Case",
	"Otto Lock",
	"PlayerModel_Cutscene",
	"Black BG"
}

-- ======================================
-- SERVER-SIDE MODEL CONTROL FUNCTIONS
-- ======================================

-- [[ NEW HELPER: CLEARS THE STAGE ]]
local function clearStage()
	print("[SERVER] Clearing Stage... Removing all scene models.")
	for _, modelName in pairs(SCENE_MODELS) do
		local model = workspace:FindFirstChild(modelName)
		if model then
			model:Destroy()
		end
	end
end

-- Helper function to find model in Workspace or spawn it from Storage
local function getOrSpawnModel(modelName: string)
	local existingModel = workspace:FindFirstChild(modelName)
	if existingModel then return existingModel end

	local charactersFolder = game.ReplicatedStorage:WaitForChild("Characters")
	local storedModel = charactersFolder:FindFirstChild(modelName)

	if storedModel then
		-- print("[SERVER] Spawning " .. modelName .. " from Characters folder...")
		local newModel = storedModel:Clone()
		newModel.Parent = workspace

		-- Look for [Name] Placeholder OR [Name] Case Placeholder
		local placeholder = workspace:FindFirstChild(modelName .. " Placeholder") or workspace:FindFirstChild(modelName .. " Case Placeholder")

		-- Fallback for specific mismatched names if needed
		if not placeholder and modelName == "Clara Case" then
			placeholder = workspace:FindFirstChild("Clara Placeholder")
		end

		if placeholder then
			newModel:PivotTo(placeholder:GetPivot())
		else
			warn("[SERVER] Warning: No placeholder found for " .. modelName)
		end

		return newModel
	else
		warn("[SERVER] Error: Model '" .. modelName .. "' not found in ReplicatedStorage/Characters")
		return nil
	end
end

-- Function to set transparency of all parts in a model
local function setModelTransparency(modelName: string, transparency: number)
	local model = getOrSpawnModel(modelName)
	if model then
		for _, part in model:GetDescendants() do
			if part.Name == "HumanoidRootPart" then
				part.Transparency = 1 
			elseif part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = transparency
			end
		end
	end
end

-- Function to smoothly fade model transparency
local function fadeModelTransparency(modelName: string, fromTransparency: number, toTransparency: number, duration: number)
	local model = getOrSpawnModel(modelName)
	if not model then return end

	local parts = {}
	for _, part in model:GetDescendants() do
		if part.Name ~= "HumanoidRootPart" and (part:IsA("BasePart") or part:IsA("Decal")) then
			table.insert(parts, part)
		elseif part.Name == "HumanoidRootPart" then
			part.Transparency = 1 
		end
	end

	local startTime = tick()
	local function updateTransparency()
		local elapsed = tick() - startTime
		local progress = math.min(elapsed / duration, 1)
		local currentTransparency = fromTransparency + (toTransparency - fromTransparency) * progress

		for _, part in parts do
			part.Transparency = currentTransparency
		end

		if progress < 1 then
			task.wait()
			updateTransparency()
		end
	end
	updateTransparency()
end

-- Function to play animation on a character model
local function playCharacterAnimation(modelName: string, animationId: string, shouldLoop: boolean)
	local model = getOrSpawnModel(modelName)
	if not model then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Refresh Animator to ensure replication
	local animator = humanoid:FindFirstChild("Animator")
	if animator then animator:Destroy() end
	animator = Instance.new("Animator")
	animator.Parent = humanoid

	-- Stop existing tracks
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0.1)
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. animationId

	local success, animationTrack = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if success then
		animationTrack.Looped = shouldLoop -- Uses the boolean passed to the function
		animationTrack.Priority = Enum.AnimationPriority.Action
		animationTrack:Play()
		print("[SERVER] Playing anim " .. animationId .. " on " .. modelName .. " (Loop: " .. tostring(shouldLoop) .. ")")
	end

	return animationTrack
end

-- Initialize models
local function initializeModels()
	local claraModel = workspace:FindFirstChild("Clara Case")
	local blackBgModel = workspace:FindFirstChild("Black BG")

	if not claraModel or not blackBgModel then
		task.wait(0.1)
		return initializeModels()
	end

	setModelTransparency("Clara Case", 1)
	setModelTransparency("Black BG", 1)
end

task.spawn(initializeModels)

-- ======================================
-- REMOTE EVENT HANDLING
-- ======================================
clientToServer.OnServerEvent:Connect(function(player, eventName, ...)
	print("[SERVER] Received event: " .. eventName)

	-- [[ NEW EVENT: CLEAR STAGE ]]
	if eventName == "ClearStage" then
		clearStage()

	elseif eventName == "ShowClara" then
		playCharacterAnimation("Clara Case", "98771209915249", true)
		setModelTransparency("Clara Case", 1)
		fadeModelTransparency("Clara Case", 1, 0, 1.5)
		task.wait(1.5)
		serverToClient:FireClient(player, "ClaraReady")

	elseif eventName == "ShowBlackBG" then
		setModelTransparency("Black BG", 1)
		fadeModelTransparency("Black BG", 1, 0, 1.0)
		task.wait(1.0)
		serverToClient:FireClient(player, "BlackBGReady")

	elseif eventName == "HideBlackBG" then
		fadeModelTransparency("Black BG", 0, 1, 1.0)
		task.wait(1.0)
		serverToClient:FireClient(player, "BlackBGHidden")

	elseif eventName == "HideClara" then
		fadeModelTransparency("Clara Case", 0, 1, 1.0)
		task.wait(1.0)
		serverToClient:FireClient(player, "ClaraHidden")

	elseif eventName == "ShowRobbie" then
		playCharacterAnimation("Robbie Banks", "130216044122355", true)
		setModelTransparency("Robbie Banks", 1)
		fadeModelTransparency("Robbie Banks", 1, 0, 1.5)
		task.wait(1.5)
		serverToClient:FireClient(player, "RobbieReady")

	elseif eventName == "HideRobbie" then
		fadeModelTransparency("Robbie Banks", 0, 1, 1.0)
		task.wait(1.0)
		serverToClient:FireClient(player, "RobbieHidden")

	elseif eventName == "PlayLoopAnim" then
		local modelName, animId = ...
		playCharacterAnimation(modelName, animId, true)

	elseif eventName == "PlayOneShotAnim" then
		local modelName, animId = ...
		playCharacterAnimation(modelName, animId, false) -- Loop is FALSE

	elseif eventName == "SetupCourtroom" then
		print("[SERVER] Setting up Courtroom...")

		-- [[ CRITICAL FIX: CLEAR STAGE FIRST ]]
		clearStage()

		-- Internal helper to force spawn at specific location
		local function spawnModelAt(modelName, placeholderName, animId, loopAnim)
			local model = getOrSpawnModel(modelName) -- Reuse helper

			local placeholder = workspace:FindFirstChild(placeholderName)
			if model and placeholder then
				model:PivotTo(placeholder:GetPivot())
				-- Force Visible
				for _, part in model:GetDescendants() do
					if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 0 end
					if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
				end
				-- Play Anim
				if animId then playCharacterAnimation(modelName, animId, loopAnim) end
			else
				warn("Failed to spawn " .. modelName .. " at " .. placeholderName)
			end
		end

		-- 1. Spawn Judge
		spawnModelAt("JudgeV1", "Judge Placeholder", "70819007264019", true)

		-- 2. Spawn Percy
		spawnModelAt("Percy Petty", "Pros Placeholder", "77996292648332", true)

		-- 3. Spawn Robbie (Witness)
		spawnModelAt("Robbie Banks", "Witness Placeholder", "107073225451274", true)

		-- 4. Spawn Clara (Side)
		spawnModelAt("Clara Case", "Side Placeholder", "107073225451274", true)

		-- 5. Spawn Player Clone
		if player.Character then
			player.Character.Archivable = true
			local playerModel = player.Character:Clone()
			playerModel.Name = "PlayerModel_Cutscene"
			playerModel.Parent = workspace

			local defSpot = workspace:FindFirstChild("Def Placeholder")
			if defSpot then playerModel:PivotTo(defSpot:GetPivot()) end

			-- Animate Player
			playCharacterAnimation("PlayerModel_Cutscene", "107073225451274", true)
		end

		task.wait(0.5)
		serverToClient:FireClient(player, "CourtroomReady")

	elseif eventName == "SetupCourtroom2" then
		print("[SERVER] Setting up Courtroom 2 (Otto)...")

		-- [[ CRITICAL FIX: CLEAR STAGE FIRST ]]
		clearStage()

		-- Internal helper (redefined here for scope safety or reuse logic)
		local function spawnModelAt(modelName, placeholderName, animId, loopAnim)
			local model = getOrSpawnModel(modelName)
			local placeholder = workspace:FindFirstChild(placeholderName)
			if model and placeholder then
				model:PivotTo(placeholder:GetPivot())
				for _, part in model:GetDescendants() do
					if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 0 end
					if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
				end
				if animId then playCharacterAnimation(modelName, animId, loopAnim) end
			end
		end

		-- 1. Standard Layout
		spawnModelAt("JudgeV1", "Judge Placeholder", "70819007264019", true)
		spawnModelAt("Percy Petty", "Pros Placeholder", "77996292648332", true)
		spawnModelAt("Clara Case", "Side Placeholder", "90090668626993", true)

		-- 2. Spawn Otto Lock (With requested Idle Anim)
		spawnModelAt("Otto Lock", "Witness Placeholder", "107073225451274", true) 

		-- 3. Player Spawn (Always respawn to be safe after clearStage)
		if player.Character then
			player.Character.Archivable = true
			local playerModel = player.Character:Clone()
			playerModel.Name = "PlayerModel_Cutscene"
			playerModel.Parent = workspace

			local defSpot = workspace:FindFirstChild("Def Placeholder")
			if defSpot then playerModel:PivotTo(defSpot:GetPivot()) end

			playCharacterAnimation("PlayerModel_Cutscene", "107073225451274", true)
		end

		task.wait(0.5)
		serverToClient:FireClient(player, "CourtroomReady2")
	end
end)