local vnm = require(script.Parent.vnModule)
vnm.init()

-- ======================================
-- REMOTE EVENT COMMUNICATION
-- ======================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local clientToServer = remoteEvents:WaitForChild("ClientToServer")
local serverToClient = remoteEvents:WaitForChild("ServerToClient")

-- ======================================
-- SCENE 1: THE LOBBY
-- ======================================
function trial1Scene()
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})

	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "???", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})

	vnm.setCamera({ cameraName = "5", transitionInfo = { type = "cut" } })
	vnm.addEvidence({id = "Badge"})
	vnm.dialog({subject = "...", dialog = "September 10th, 9:47 AM"})
	vnm.dialog({subject = "...", dialog = "District Court"})
	vnm.dialog({subject = "...", dialog = "Defendant Lobby No.2"})

	vnm.playSound({soundPath = "bgm/DefenseLobby", track = 1})
	vnm.removeImageCover(1)

	vnm.dialog({subject = "Me", dialog = "Man, these nerves are making me forget my own name!"})
	vnm.dialog({subject = "Me", dialog = "Wait, Whats my name again?"})

	local playerName = vnm.promptTextInput({placeholderText = "Name", maxCharacters = 20, variableName = "playerName"})
	vnm.playSound({soundPath = "sfx/story/lightbulb"})
	vnm.dialog({subject = "Me", dialog = "Ok! I got this!"})
	vnm.dialog({subject = "Me", dialog = "First trial is always the easiest."})
	vnm.dialog({subject = "Me", dialog = "I think I'm about to feel sick..."})
	vnm.playSound({soundPath = "sfx/story/realization"})
	vnm.dialog({subject = "???", dialog = "You need to chill out!"})

	-- Show Clara
	print("[CLIENT] Requesting Clara...")
	clientToServer:FireServer("ShowClara")
	serverToClient.OnClientEvent:Wait() 

	vnm.dialog({subject = "Clara", dialog = "You aren't facing anyone too hard."})
	vnm.dialog({subject = "Clara", dialog = "You're facing Percy Petty."})

	-- Flashback (Black BG)
	clientToServer:FireServer("ShowBlackBG")
	serverToClient.OnClientEvent:Wait()

	vnm.dialog({subject = "Me", dialog = "Clara Case, my childhood friend."})
	vnm.dialog({subject = "Me", dialog = "She's my friendly neighborhood detective."})

	-- Hide Flashback
	clientToServer:FireServer("HideBlackBG")
	serverToClient.OnClientEvent:Wait()
	vnm.playSound({soundPath = "sfx/story/punch"})

	vnm.dialog({subject = "Me", dialog = "R-R-Rookie Crusher?"})
	vnm.dialog({subject = "Clara", dialog = "He’s been a prosecutor for ten years."})
	vnm.dialog({subject = "Clara", dialog = "You just need to play it cool"})
	vnm.playSound({soundPath = "sfx/story/lightbulb"})
	vnm.dialog({subject = "???", dialog = `U-Umm... Mister lawyer {playerName}...`})

	-- Switch to Robbie
	clientToServer:FireServer("HideClara")
	serverToClient.OnClientEvent:Wait()

	clientToServer:FireServer("ShowRobbie")
	serverToClient.OnClientEvent:Wait()

	vnm.dialog({subject = "Robbie", dialog = "Do you really think I'm innocent?"})
	local choice = vnm.promptChoice({choices = {"Of course!", "Uhhhh..."}, variableName = "Innocent"})

	if choice == 1 then
		vnm.dialog({subject = "Me", dialog = "Of course I do. I wouldn't defend you if I didn't."})
	elseif choice == 2 then
		vnm.dialog({subject = "Me", dialog = "Uhhh... Sure, I do I guess..."})
	end

	vnm.dialog({subject = "Robbie", dialog = "I-It looks bad huh."})
	vnm.dialog({subject = "Me", dialog = "The trial is about to start anyway."})
	vnm.dialog({subject = "Robbie", dialog = "Wait!"})
	vnm.dialog({subject = "Robbie", dialog = "T-Take this!"})
	vnm.playSound({soundPath = "sfx/story/evidence"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.linkSubjectToPortrait({subject = "...", portraitName = "GenericNote"})
	vnm.dialog({subject = "...", dialog = "[EVIDENCE PRESENTED: ATM RECEIPT]"})
	vnm.dialog({subject = "...", dialog = "(Atm receipt that shows Robbie Withdrew money from an ATM at 1:00 PM)"})
	vnm.dialog({subject = "Robbie", dialog = "I forgot to give this to you yesterday."})
	vnm.linkSubjectToPortrait({subject = "...", portraitName = nil})
	vnm.dialog({subject = "Me", dialog = "Oh, Thanks."})
	vnm.dialog({subject = "Me", dialog = "Alright, Lets do this!"})

	-- Hide Robbie
	clientToServer:FireServer("HideRobbie")
	serverToClient.OnClientEvent:Wait()
	vnm.stopAudioTrack({track = 1, fade = true})
	-- Transition to Black
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 1         -- How long the fade takes in seconds
	})
	vnm.dialog({subject = "Clara", dialog = "W-Wait for me!"})
end

-- ======================================
-- SCENE 2: THE COURTROOM
-- ======================================
function Courtroom()
	-- 1. Setup the Room (Models & Animations)
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})
	clientToServer:FireServer("SetupCourtroom")
	serverToClient.OnClientEvent:Wait() 
	local playerName = vnm.getStoryVariable("playerName")

	-- 2. Reveal
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "...", dialog = "September 10th, 10 AM"})
	vnm.dialog({subject = "...", dialog = "District Court"})
	vnm.dialog({subject = "...", dialog = "Courtroom No.2"})

	vnm.removeImageCover(1)

	-- 3. THE GAVEL SEQUENCE
	vnm.playSound({soundPath = "bgm/gallery", track = 1})	

	task.wait(2) 

	-- Cut to close up (Cam 8)
	vnm.setCamera({ cameraName = "8", transitionInfo = { type = "cut" } })
	clientToServer:FireServer("PlayOneShotAnim", "JudgeV1", "123089019725293")
	task.wait(.5)
	vnm.playSound({soundPath = "sfx/story/gavel"})
	task.wait(1)

	-- Cut back to wide shot (Cam 1)
	clientToServer:FireServer("PlayLoopAnim", "JudgeV1", "70819007264019")
	vnm.playSound({soundPath = "bgm/CourtStart", track = 1})	
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })


	-- 4. Dialogue
	vnm.dialog({subject = "Judge", dialog = "Court is now in session for the trial of Mr. Robbie Banks."})

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "The procescution is ready, Your Honor."})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Me", dialog = "..."})

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "Defense?"})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })

	-- Player Animation: Shocked (One Shot)
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "116697544329781")
	vnm.playSound({soundPath = "sfx/story/punch"})
	vnm.dialog({subject = "Me", dialog = "Ack!"})
	vnm.dialog({subject = "Me", dialog = "Yes!? Uhh, Your Honor?"})
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "Is the Defense ready?"})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	-- Player Animation: Back to Idle
	vnm.dialog({subject = "Me", dialog = "Yes! I am, Your Honor."})

	-- Player Animation: Sweat/Nervous (One Shot)

	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "125400831802996")
	vnm.playSound({soundPath = "sfx/story/sfx-whoops"}) 
	vnm.dialog({subject = "Me", dialog = "<b>(Oh man, I totally freaked!)</b>"})
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "This is your first trial, correct?"})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	-- Player Animation: Back to Idle
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
	vnm.dialog({subject = "Me", dialog = "Yes, Your Honor, this is my first trial."})

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "Taking on a murder trial for your first case is a big task."})
	vnm.dialog({subject = "Judge", dialog = "Are you sure ready?"})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	-- Player Animation: Sweat/Nervous (One Shot)
	vnm.playSound({soundPath = "sfx/story/supershock"})
	vnm.dialog({subject = "Me", dialog = "Yes!"})
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "125400831802996")
	vnm.playSound({soundPath = "sfx/story/sfx-whoops"}) 
	vnm.dialog({subject = "Me", dialog = "Erm, yes Your Honor."})
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.playSound({soundPath = "sfx/story/lightbulb"})
	vnm.dialog({subject = "Petty", dialog = "Hehehehe"})
	vnm.dialog({subject = "Petty", dialog = "The Prosecution has been ready since before this rookie passed the bar exam."})
	vnm.dialog({subject = "Petty", dialog = "Your Honor, I assume this will be quick?"})
	vnm.dialog({subject = "Petty", dialog = "I have a hair appointment at 3:00."})

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "This is a murder trial, Mr. Percy Petty. Treat it with respect."})
	vnm.dialog({subject = "Judge", dialog = "Your opening statement please."})

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "It is quite simple, really."})
	vnm.dialog({subject = "Petty", dialog = "The defendant, Mr. Banks, was found inside the vault standing over the body of the Bank Manager, Mr. Billions."})
	vnm.dialog({subject = "Petty", dialog = "The victim was struck by a heavy object."})
	vnm.dialog({subject = "Petty", dialog = "It is an open-and-shut case."})
	vnm.dialog({subject = "Petty", dialog = "I recommend the Defense plead guilty now and save us all the embarrassment."})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	vnm.playSound({soundPath = "sfx/story/sfx-whoops"}) 
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "125400831802996")
	vnm.dialog({subject = "Me", dialog = "(He's treating a murder like a parking ticket...)"})
	clientToServer:FireServer("PlayLoopAnim", "Clara Case", "90090668626993")
	vnm.setCamera({ cameraName = "4", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Clara", dialog = "Lets wipe that smile off his face!"})

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	clientToServer:FireServer("PlayLoopAnim", "Clara Case", "107073225451274")
	vnm.dialog({subject = "Petty", dialog = "The Prosecution calls the brave Bank Security Guard, Sgt. Otto Lock!"})

	vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 2         -- How long the fade takes in seconds
	})
	vnm.stopAudioTrack({track = 1, fade = true})
	wait(2)
end

-- ======================================
-- SCENE 3: THE COURTROOM2 (OTTO INTRO)
-- ======================================
function Courtroom2()
	-- 1. Setup the Room (Swaps Witness for Otto)
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	vnm.playSound({soundPath = "bgm/CourtStart", track = 1})
	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait() 

	local playerName = vnm.getStoryVariable("playerName")

	-- 2. Reveal
	vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	wait(2)
	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "May the Witness sate their Name and Profession?"})

	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })

	-- Otto Lock Animation: Salute (One Shot)
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "107073225451274")
	wait(1)
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
	vnm.stopAudioTrack({track = 1})
	vnm.playSound({soundPath = "sfx/story/supershock"})
	vnm.shake({intensity = 5, duration = 1})

	vnm.dialog({subject = "Lock", dialog = "Security Officer Lock reporting for duty!"})
	vnm.playSound({soundPath = "sfx/story/supershock"})
	vnm.dialog({subject = "Lock", dialog = "Sector 4 is secured!"})

	vnm.playSound({soundPath = "sfx/story/supershock"})
	vnm.shake({intensity = 5, duration = 1})

	vnm.dialog({subject = "Lock", dialog = "The target has been neutralized—er, I mean."})
	vnm.playSound({soundPath = "sfx/story/punch4"})
	vnm.shake({intensity = 5, duration = 1})

	vnm.dialog({subject = "Lock", dialog = "The victim was found! Over!"})	

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "Mr. Lock..."})
	vnm.dialog({subject = "Judge", dialog = "Please lower your hand."})

	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.playSound({soundPath = "sfx/story/punch4"})
	vnm.shake({intensity = 5, duration = 1})

	vnm.dialog({subject = "Lock", dialog = "Negative, Your Honor!"})
	vnm.dialog({subject = "Lock", dialog = "Constant vigilance is the key to survival!"})

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "As you can see, a dedicated professional."})
	vnm.dialog({subject = "Petty", dialog = "Sergeant, tell the court what you saw regarding the murder."})
	-- Fades out the music on Track 1 (BGM) over the default duration
	vnm.stopAudioTrack({track = 1, fade = true})
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 2         -- How long the fade takes in seconds
	})
	wait(2)
end

-- ======================================
-- SCENE 4: THE COURTROOM3 (TESTIMONY)
-- ======================================
function Courtroom3()
	-- 1. Ensure Room Logic
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})

	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait()
	local playerName = vnm.getStoryVariable("playerName")
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})

	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	wait(2)
	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[TESTIMONY START] Target Down"})
	wait(2)
	vnm.playSound({soundPath = "bgm/QuestioningModerato", track = 1})
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "107073225451274")
	vnm.dialog({subject = "Lock", dialog = "I was stationed at the Gold Zone guarding the VIP... er, the Manager"})
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
	vnm.dialog({subject = "Lock", dialog = "At 1300 hours (1:00 PM), I took a tactical hydration break."})
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "107073225451274")
	vnm.dialog({subject = "Lock", dialog = "I looked in and saw the hostile (Robbie) standing over the KIA holding the murder weapon!"})
	clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
	vnm.dialog({subject = "Lock", dialog = "I apprehended the suspect immediately! Threat neutralized!"})
	vnm.stopAudioTrack({track = 1, fade = true})
	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "We have cold, hard facts. Your Honor, I present the decisive evidence."})
	vnm.playSound({soundPath = "sfx/story/evidence"})
	vnm.addEvidence({id = "AutopsyReport1"}) -- Make sure ID matches evidence.lua
	vnm.linkSubjectToPortrait({subject = "...", portraitName = "Autopsy"})
	vnm.dialog({subject = "...", dialog = "[EVIDENCE PRESENTED: AUTOPSY REPORT]"})
	vnm.dialog({subject = "...", dialog = "(Time of death: Between 12:45 PM and 1:15 PM. Cause: Blunt force trauma)"})
	vnm.dialog({subject = "Petty", dialog = "The Bank also gave us a Bank Security Manual."})
	vnm.linkSubjectToPortrait({subject = "...", portraitName = nil})
	vnm.playSound({soundPath = "sfx/story/evidence"})
	vnm.addEvidence({id = "BankSecurityManual"}) -- Make sure ID matches evidence.lua
	vnm.linkSubjectToPortrait({subject = "...", portraitName = "BankSecurityManual"})
	vnm.dialog({subject = "...", dialog = "[EVIDENCE PRESENTED: Bank Security Manual]"})
	vnm.dialog({subject = "...", dialog = "(Manual for Bank Security staff. See Court Record for more info.)"})

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.linkSubjectToPortrait({subject = "...", portraitName = nil})
	vnm.dialog({subject = "Judge", dialog = "The Defense may begin their Cross-Examination."})

	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Me", dialog = "Cross-Examination?"})
	clientToServer:FireServer("PlayLoopAnim", "Clara Case", "90090668626993")
	vnm.setCamera({ cameraName = "4", transitionInfo = { type = "cut" } })
	vnm.playSound({soundPath = "sfx/story/punch4"})
	vnm.dialog({subject = "Clara", dialog = `{playerName}!`})
	vnm.dialog({subject = "Clara", dialog = "This is where you expose the lies in the testimony."})
	vnm.playSound({soundPath = "sfx/story/realization"})
	vnm.dialog({subject = "Me", dialog = "The Witness lied?"})
	vnm.dialog({subject = "Clara", dialog = "You do believe our client right?"})
	vnm.dialog({subject = "Me", dialog = "Of course!"})
	vnm.dialog({subject = "Clara", dialog = "So there has to be a lie some where."})
	vnm.dialog({subject = "Clara", dialog = "On each statement, Press them to get more information."})
	vnm.dialog({subject = "Clara", dialog = "Once you feel like you found a contradiction with the testimony,"})
	vnm.dialog({subject = "Clara", dialog = "Prove it with the evidence in the Court Record"})
	vnm.dialog({subject = "Me", dialog = "Alright I got this!"})
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 2         -- How long the fade takes in seconds
	})
	wait(2)
end

-- ======================================
-- SCENE 5: THE COURTROOM4 (CROSS EXAM)
-- ======================================
function Courtroom4()
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait()
	local favoriteColor = vnm.getStoryVariable("playerName")
	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	wait(2)
	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[CROSS EXAMINATION] Target Down"})
	wait(2)
	local crossExamining = true
	vnm.playSound({soundPath = "bgm/QuestioningModerato", track = 1})
	while crossExamining do
		-- [[ STATEMENT 1 ]]
		vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
		clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
		vnm.dialog({subject = "Lock", dialog = "I was stationed at the Gold Zone guarding the VIP... er, the Manager"})
		local choice1 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press1"})

		if choice1 == 1 then -- PRESS
			vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/objection"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
			vnm.dialog({subject = "Me", dialog = "Hold it!"})
			vnm.dialog({subject = "Me", dialog = "You were guarding Mr. Billions?"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "Affirmative! I was his shield!"})
		elseif choice1 == 2 then -- PRESENT (WRONG)
			local evidenceId = vnm.promptEvidence()
			-- WRONG EVIDENCE LOGIC
			vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/objection"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
			vnm.dialog({subject = "Me", dialog = "Take that!"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
			vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/punch"}) 
			vnm.dialog({subject = "Judge", dialog = "That evidence is irrelevant to this statement."})
		end

		-- [[ STATEMENT 2 (CRITICAL) ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "107073225451274")
			vnm.dialog({subject = "Lock", dialog = "At 1300 hours (1:00 PM), I took a tactical hydration break."})

			local choice2 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press2"})

			if choice2 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "You left your post?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "Even elite warriors need moisture!"})

			elseif choice2 == 2 then -- PRESENT
				local evidenceId = vnm.promptEvidence()

				-- [[ DEBUG PRINT ]]
				print("STORY SCRIPT: Received Evidence ID: ", evidenceId)

				if evidenceId == "ATMReceipt" then
					-- [[ SUCCESS SEQUENCE ]] --
					crossExamining = false -- Stop loop

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.stopAudioTrack({track=1}) 
					vnm.playSound({soundPath = "sfx/story/objection"})


					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
					vnm.dialog({subject = "Me", dialog = "Objection!"})


					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "79796415738081")
					vnm.playSound({soundPath = "sfx/story/deskslam"})


					vnm.dialog({subject = "Me", dialog = "You claim you saw Robbie at 1:00 PM?"})
					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Lock", dialog = "Affirmative!"})

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "106332758946656")
					vnm.playSound({soundPath = "bgm/Objection", track = 1})
					vnm.dialog({subject = "Me", dialog = "You’re lying. Take a look at this!"})

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/sfx-shooop"})
					vnm.linkSubjectToPortrait({subject = "Me", portraitName = "GenericNote"})
					vnm.linkSubjectToPortrait({subject = "Lock", portraitName = "GenericNote"})
					vnm.dialog({subject = "Me", dialog = "At 1:00 PM exactly, Robbie was using the ATM in the lobby!"})

					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "116697544329781")
					vnm.playSound({soundPath = "sfx/story/punch4"})
					vnm.dialog({subject = "Lock", dialog = "Ack!"})
					-- 3. THE GAVEL SEQUENCE
					vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/gallery"})	

					task.wait(2) 

					-- Cut to close up (Cam 8)
					vnm.setCamera({ cameraName = "8", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayOneShotAnim", "JudgeV1", "123089019725293")
					task.wait(.5)
					vnm.playSound({soundPath = "sfx/story/gavel"})
					task.wait(1)
					vnm.linkSubjectToPortrait({subject = "Me", portraitName = nil})
					vnm.linkSubjectToPortrait({subject = "Lock", portraitName = nil})
					clientToServer:FireServer("PlayLoopAnim", "JudgeV1", "70819007264019")
					vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })

					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
					vnm.shake({intensity = 5, duration = 1})
					vnm.playSound({soundPath = "sfx/story/punch4"})
					vnm.dialog({subject = "Judge", dialog = "Order! Order!"})
					vnm.dialog({subject = "Judge", dialog = "Witness, explain yourself!"})
					vnm.stopAudioTrack({track = 1, fade = true})
					vnm.addImageCover({
						coverName = "Black", -- Must match the name in vnSystem/images/covers
						fadeTime = 2         -- How long the fade takes in seconds
					})
					wait(2)
				else
					-- [[ WRONG EVIDENCE ]]
					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/objection"})
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
					vnm.dialog({subject = "Me", dialog = "Take that!"})
					task.wait(1)
					vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Judge", dialog = "Mr. Lawyer, how is that relevant?"})
					vnm.playSound({soundPath = "sfx/story/punch"}) 
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				end
			end
		end

		-- [[ STATEMENT 3 ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "I looked in and saw the hostile holding the murder weapon!"})
			local choice3 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press3"})

			if choice3 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "You saw him holding the weapon?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "Affirmative!"})
				vnm.dialog({subject = "Lock", dialog = "A heavy gold statue!"})
				vnm.dialog({subject = "Lock", dialog = "He looked ready to strike again!"})
			elseif choice3 == 2 then 
				vnm.promptEvidence()
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/punch"})
				vnm.dialog({subject = "Judge", dialog = "That evidence does not contradict this statement."})
			end
		end

		-- [[ STATEMENT 4 ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			clientToServer:FireServer("PlayOneShotAnim", "Otto Lock", "87519162270226")
			vnm.dialog({subject = "Lock", dialog = "I apprehended the suspect immediately! Threat neutralized!"})
			local choice4 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press4"})


			if choice4 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "Did he try to run?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "The target cried and asked why the nice man on the floor was sleeping."})
				vnm.dialog({subject = "Lock", dialog = "A pathetic attempt at psychological warfare!"})


			elseif choice4 == 2 then 
				vnm.promptEvidence()
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/punch"})
				vnm.dialog({subject = "Judge", dialog = "Please stop wasting the court's time."})
			end

			-- End of Statements loop
			vnm.setCamera({ cameraName = "4", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Clara", dialog = "Remember, check the Court Record!"})
		end
	end
end

-- ======================================
-- SCENE 6: THE COURTROOM5 (REVISED TESTIMONY)
-- ======================================
function Courtroom5()
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait() 
	local favoriteColor = vnm.getStoryVariable("playerName")
	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	wait(2)
	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[TESTIMONY START] What I actually saw"})
	wait(2)
	vnm.playSound({soundPath = "bgm/QuestioningAllegro", track = 1})
	vnm.dialog({subject = "Lock", dialog = "Correction! It was actually 13:10 (1:10 PM) when I spotted the target"})
	vnm.dialog({subject = "Lock", dialog = "The target walked right into the vault. He just strolled in like a civilian!"})
	vnm.dialog({subject = "Lock", dialog = "He must have struck the victim moments before I entered!"})
	vnm.stopAudioTrack({track = 1, fade = true})
	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "The Prosecution has evidence to prove the defendant was the killer, regardless of the time."})
	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Me", dialog = "Huh!?"})
	vnm.playSound({soundPath = "sfx/story/evidence"})
	vnm.addEvidence({id = "GoldStatue"}) -- Make sure ID matches evidence.lua
	vnm.linkSubjectToPortrait({subject = "...", portraitName = "GoldStatue"})
	vnm.dialog({subject = "...", dialog = "[EVIDENCE PRESENTED: GREASSED GOLD STATUE]"})
	vnm.dialog({subject = "...", dialog = "(Heavy Gold Statue used to strike the victim. grease was left on the handle.)"})
	vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
	clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "116697544329781")
	vnm.playSound({soundPath = "sfx/story/punch"})
	vnm.dialog({subject = "Me", dialog = "Ack!"})
	vnm.linkSubjectToPortrait({subject = "...", portraitName = nil})
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "Grease?"})
	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "Mechanic's grease."})
	vnm.dialog({subject = "Petty", dialog = "The defendant fixes motorcycles as a hobby."})
	vnm.dialog({subject = "Petty", dialog = "His hands were dirty. He grabbed the statue, killed the manager, and left his mark."})
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "The Defense may cross-examine."})
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 2         -- How long the fade takes in seconds
	})
	wait(2)
end

-- ======================================
-- SCENE 7: THE COURTROOM6 (CROSS EXAM)
-- ======================================

function Courtroom6()
	vnm.addImageCover({
		coverName = "Black", 
		fadeTime = 0 
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.addEvidence({id = "GoldStatue"})

	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait()

	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	task.wait(2)

	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[CROSS EXAMINATION] What I actually saw"})
	task.wait(2)

	local crossExamining = true
	vnm.playSound({soundPath = "bgm/QuestioningAllegro", track = 1})

	while crossExamining do
		-- [[ STATEMENT 1 ]]
		vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
		clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
		vnm.dialog({subject = "Lock", dialog = "Correction! It was actually 13:10 (1:10 PM) when I spotted the target."})
		local choice5 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press6_1"})

		if choice5 == 1 then -- PRESS
			vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/objection"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
			vnm.dialog({subject = "Me", dialog = "Hold it!"})
			vnm.dialog({subject = "Me", dialog = "Are you sure this time?"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "Affirmative! I cross-referenced with the sun's position!"})
		elseif choice5 == 2 then -- PRESENT
			local evidenceId = vnm.promptEvidence()

			print("STORY SCRIPT: Received Evidence ID: ", evidenceId)

			if evidenceId == "BankSecurityManual" then
				-- [[ SUCCESS SEQUENCE ]] --
				crossExamining = false -- Stop loop

				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.stopAudioTrack({track=1}) 
				vnm.playSound({soundPath = "sfx/story/objection"})

				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Objection!"})

				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "79796415738081")
				vnm.playSound({soundPath = "sfx/story/deskslam"})

				vnm.dialog({subject = "Me", dialog = "Sgt. Lock!"})
				vnm.dialog({subject = "Me", dialog = "You claim Robbie just walked in at 1:10 PM?"})
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "That is the current intel, yes!"})

				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "106332758946656")
				vnm.playSound({soundPath = "bgm/PressingPersuit", track = 1})
				vnm.dialog({subject = "Me", dialog = "Impossible!"})
				vnm.playSound({soundPath = "sfx/story/sfx-shooop"})
				vnm.linkSubjectToPortrait({subject = "Me", portraitName = "BankSecurityManual"})
				vnm.linkSubjectToPortrait({subject = "Lock", portraitName = "BankSecurityManual"})
				vnm.linkSubjectToPortrait({subject = "Petty", portraitName = "BankSecurityManual"})
				vnm.dialog({subject = "Me", dialog = "According to the Bank's own manual, the vault Auto-Lock engages at 12:55 PM!"})
				vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Petty", dialog = "W-What?!"})

				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Me", dialog = "After 12:55 PM, that door is sealed tight."})

				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				clientToServer:FireServer("PlayOneShotAnim", "Otto Lock", "133401649694034")
				clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "116697544329781")
				vnm.playSound({soundPath = "sfx/story/punch4"})
				vnm.dialog({subject = "Lock", dialog = "Mayday! Logic shields failing!"})
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Me", dialog = "The only way Robbie could get in..."})
				vnm.playSound({soundPath = "sfx/story/shock1"})
				vnm.dialog({subject = "Me", dialog = "Is if YOU unlocked it for him!"})
				vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/gallery"})	

				task.wait(2) 

				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.playSound({soundPath = "sfx/story/objection"})
				vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
				vnm.linkSubjectToPortrait({subject = "Me", portraitName = nil})
				vnm.linkSubjectToPortrait({subject = "Lock", portraitName = nil})
				vnm.linkSubjectToPortrait({subject = "Petty", portraitName = nil})
				vnm.dialog({subject = "Petty", dialog = "Objection!"})
				vnm.playSound({soundPath = "sfx/story/punch4"})
				vnm.dialog({subject = "Petty", dialog = "Why would the guard unlock the vault for a murderer?"})
				vnm.dialog({subject = "Petty", dialog = "That's absurd!"})
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/punch"})
				vnm.dialog({subject = "Lock", dialog = "A-Affirmative! Why would I aid the enemy?"})
				vnm.playSound({soundPath = "sfx/story/lightbulb"})
				vnm.dialog({subject = "Lock", dialog = "Wait... I remember now!"})
				vnm.dialog({subject = "Lock", dialog = "There was a maintenance issue!"})
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.dialog({subject = "Judge", dialog = "...A maintenance issue?"})
				vnm.dialog({subject = "Judge", dialog = "Witness, this is your last chance."})
				vnm.dialog({subject = "Judge", dialog = "Tell the truth!"})
				vnm.stopAudioTrack({track = 1, fade = true})
				vnm.addImageCover({
					coverName = "Black", 
					fadeTime = 2 
				})
				task.wait(2)
			else
				-- [[ WRONG EVIDENCE ]]
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Take that!"})
				task.wait(1)
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Judge", dialog = "Mr. Lawyer, how is that relevant?"})
				vnm.playSound({soundPath = "sfx/story/punch"}) 
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
			end
		end

		-- [[ STATEMENT 2 (CRITICAL) ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "107073225451274")
			vnm.dialog({subject = "Lock", dialog = "The target walked right into the vault. He just strolled in like a civilian!"})

			local choice6 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press6_2"})

			if choice6 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "You left your post?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "Even elite warriors need moisture!"})

			elseif choice6 == 2 then -- PRESENT
				local evidenceId = vnm.promptEvidence()

				print("STORY SCRIPT: Received Evidence ID: ", evidenceId)

				if evidenceId == "BankSecurityManual" then
					-- [[ SUCCESS SEQUENCE ]] --
					crossExamining = false -- Stop loop

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.stopAudioTrack({track=1}) 
					vnm.playSound({soundPath = "sfx/story/objection"})

					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
					vnm.dialog({subject = "Me", dialog = "Objection!"})

					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "79796415738081")
					vnm.playSound({soundPath = "sfx/story/deskslam"})

					vnm.dialog({subject = "Me", dialog = "Sgt. Lock!"})
					vnm.dialog({subject = "Me", dialog = "You claim Robbie just walked in at 1:10 PM?"})
					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Lock", dialog = "That is the current intel, yes!"})

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "106332758946656")
					vnm.playSound({soundPath = "bgm/PressingPersuit", track = 1})
					vnm.dialog({subject = "Me", dialog = "Impossible!"})
					vnm.playSound({soundPath = "sfx/story/sfx-shooop"})
					vnm.linkSubjectToPortrait({subject = "Me", portraitName = "BankSecurityManual"})
					vnm.linkSubjectToPortrait({subject = "Lock", portraitName = "BankSecurityManual"})
					vnm.linkSubjectToPortrait({subject = "Petty", portraitName = "BankSecurityManual"})
					vnm.dialog({subject = "Me", dialog = "According to the Bank's own manual, the vault Auto-Lock engages at 12:55 PM!"})
					vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Petty", dialog = "W-What?!"})

					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Me", dialog = "After 12:55 PM, that door is sealed tight."})

					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayOneShotAnim", "Otto Lock", "133401649694034")
					clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "116697544329781")
					vnm.playSound({soundPath = "sfx/story/punch4"})
					vnm.dialog({subject = "Lock", dialog = "Mayday! Logic shields failing!"})
					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Me", dialog = "The only way Robbie could get in..."})
					vnm.playSound({soundPath = "sfx/story/shock1"})
					vnm.dialog({subject = "Me", dialog = "Is if YOU unlocked it for him!"})
					vnm.playSound({soundPath = "sfx/story/objection"})
					vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
					vnm.linkSubjectToPortrait({subject = "Me", portraitName = nil})
					vnm.linkSubjectToPortrait({subject = "Lock", portraitName = nil})
					vnm.linkSubjectToPortrait({subject = "Petty", portraitName = nil})
					vnm.dialog({subject = "Petty", dialog = "Objection!"})
					vnm.playSound({soundPath = "sfx/story/punch"})
					vnm.dialog({subject = "Petty", dialog = "Why would the guard unlock the vault for a murderer?"})
					vnm.dialog({subject = "Petty", dialog = "That's absurd!"})
					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/punch2"})
					vnm.dialog({subject = "Lock", dialog = "A-Affirmative! Why would I aid the enemy?"})
					vnm.playSound({soundPath = "sfx/story/lightbulb"})
					vnm.dialog({subject = "Lock", dialog = "Wait... I remember now!"})
					vnm.dialog({subject = "Lock", dialog = "There was a maintenance issue!"})
					vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
					vnm.dialog({subject = "Judge", dialog = "...A maintenance issue?"})
					vnm.dialog({subject = "Judge", dialog = "Witness, this is your last chance."})
					vnm.dialog({subject = "Judge", dialog = "Tell the truth!"})
					vnm.stopAudioTrack({track = 1, fade = true})
					vnm.addImageCover({
						coverName = "Black", 
						fadeTime = 2 
					})
					task.wait(2)
				else
					-- [[ WRONG EVIDENCE ]]
					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/objection"})
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
					vnm.dialog({subject = "Me", dialog = "Take that!"})
					task.wait(1)
					vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Judge", dialog = "Mr. Lawyer, how is that relevant?"})
					vnm.playSound({soundPath = "sfx/story/punch"}) 
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				end
			end
		end

		-- [[ STATEMENT 3 ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "He must have struck the victim moments before I entered!"})
			local choice7 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press6_3"})

			if choice7 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "Are you sure you didn't hear anything?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "Negative! The vault is soundproof!"})
			elseif choice7 == 2 then -- PRESENT
				vnm.promptEvidence()
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/punch"})
				vnm.dialog({subject = "Judge", dialog = "That evidence does not contradict this statement."})
			end
		end

		-- [[ CLARA HINT ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "4", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Clara", dialog = "Check the times in the Bank Manual!"})
		end

	end -- Close 'while crossExamining'
end -- Close 'function Courtroom6'

-- ======================================
-- SCENE 6: THE COURTROOM7 (REVISED TESTIMONY)
-- ======================================
function Courtroom7() -- [[ FIXED: Was accidentally named Courtroom9 ]]
	vnm.addImageCover({
		coverName = "Black", 
		fadeTime = 0 
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.addEvidence({id = "GoldStatue"})

	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})

	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait() 

	local favoriteColor = vnm.getStoryVariable("playerName")
	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	task.wait(2)

	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[TESTIMONY START] The Maintenance"})
	task.wait(2)

	vnm.playSound({soundPath = "bgm/QuestioningAllegro", track = 1})
	vnm.dialog({subject = "Lock", dialog = "I didn't unlock it for him! I unlocked it to... inspect the hinges!"})
	vnm.dialog({subject = "Lock", dialog = "But I stayed strictly at the entrance! I never fully entered the 'Gold Zone'!"})
	vnm.dialog({subject = "Lock", dialog = "I was busy fixing the door, so I didn't see the body until it was too late!"})
	vnm.stopAudioTrack({track = 1, fade = true})

	vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Petty", dialog = "As you see, my client had nothing to do with the murder."})
	vnm.dialog({subject = "Petty", dialog = "He was simply doing his job as an esential worker."})

	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
	vnm.dialog({subject = "Judge", dialog = "The Defense may cross-examine."})

	vnm.addImageCover({
		coverName = "Black", 
		fadeTime = 2 
	})
	task.wait(2)
end

-- ======================================
-- SCENE 7: THE COURTROOM8 (FINAL CROSS EXAM)
-- ======================================

function Courtroom8()
	vnm.addImageCover({
		coverName = "Black", 
		fadeTime = 0 
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.addEvidence({id = "GoldStatue"})

	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	clientToServer:FireServer("SetupCourtroom2") 
	serverToClient.OnClientEvent:Wait()

	vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	task.wait(2)

	vnm.playSound({soundPath = "sfx/story/sfx-testimony2"}) 
	vnm.dialog({subject = "...", dialog = "[CROSS EXAMINATION] The Maintenance"})
	task.wait(2)

	local crossExamining = true
	local statement3Revised = false -- Logic variable to track the revised statement

	vnm.playSound({soundPath = "bgm/QuestioningAllegro", track = 1})

	while crossExamining do
		-- [[ STATEMENT 1 ]]
		vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
		clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843")
		vnm.dialog({subject = "Lock", dialog = "I didn't unlock it for him! I unlocked it to... inspect the hinges!"})
		local choice1 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press8_1"})

		if choice1 == 1 then -- PRESS
			vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/objection"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
			vnm.dialog({subject = "Me", dialog = "Hold it!"})
			vnm.dialog({subject = "Me", dialog = "Why inspect the hinges right then?"})
			clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "Standard protocol! A squeaky hinge is a security risk!"})
		elseif choice1 == 2 then -- PRESENT
			vnm.promptEvidence()
			vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
			vnm.playSound({soundPath = "sfx/story/punch"})
			vnm.dialog({subject = "Judge", dialog = "This evidence doesn't contradict the inspection."})
		end

		-- [[ STATEMENT 2 ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Lock", dialog = "But I stayed strictly at the entrance! I never fully entered the 'Gold Zone'!"})
			local choice2 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press8_2"})

			if choice2 == 1 then -- PRESS
				vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/objection"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
				vnm.dialog({subject = "Me", dialog = "Hold it!"})
				vnm.dialog({subject = "Me", dialog = "Are you sure you didn't step inside?"})
				clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
				vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
				vnm.dialog({subject = "Lock", dialog = "Negative! My boots remained on the threshold!"})
			elseif choice2 == 2 then -- PRESENT
				vnm.promptEvidence()
				vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
				vnm.playSound({soundPath = "sfx/story/punch"})
				vnm.dialog({subject = "Judge", dialog = "I don't see the contradiction here."})
			end
		end

		-- [[ STATEMENT 3 (Branching Logic) ]]
		if crossExamining then
			vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })

			if not statement3Revised then
				-- ORIGINAL STATEMENT
				vnm.dialog({subject = "Lock", dialog = "I was busy fixing the door, so I didn't see the body until it was too late!"})
				local choice3 = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press8_3"})

				if choice3 == 1 then -- PRESS
					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/objection"})
					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
					vnm.dialog({subject = "Me", dialog = "Hold it!"})
					vnm.dialog({subject = "Me", dialog = "What kind of tools were you using exactly?"})

					clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "107073225451274")
					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Lock", dialog = "Uh... standard issue... tactical wrench? And... lubricants?"})

					-- CHOICE: Press him on lubricants?
					local subChoice = vnm.promptChoice({choices = {"Press further on lubricants", "Let it go"}, variableName = "Press8_3_Sub"})

					if subChoice == 1 then
						-- CONTINUE PRESSING
						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Me", dialog = "Your Honor! The Defense would like the Witness to add what type of lubricant they used!"})

						vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
						vnm.playSound({soundPath = "sfx/story/objection"})
						clientToServer:FireServer("PlayOneShotAnim", "Percy Petty", "116697544329781")
						vnm.dialog({subject = "Petty", dialog = "Objection! Your Honor! There's no relevance!"})

						vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
						vnm.playSound({soundPath = "sfx/story/gavel"})
						vnm.dialog({subject = "Judge", dialog = "Does the Defense believe that this is relevant information?"})

						-- CHOICE: Is it relevant?
						local relChoice = vnm.promptChoice({choices = {"Yes, it's vital", "No, nevermind"}, variableName = "Press8_3_Rel"})

						if relChoice == 1 then
							-- SUCCESSFUL REVISION
							vnm.dialog({subject = "Judge", dialog = "Alright then! Witness, add it to your testimony."})

							vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
							vnm.playSound({soundPath = "sfx/story/lightbulb"})
							clientToServer:FireServer("PlayOneShotAnim", "Otto Lock", "100022269866843")
							vnm.dialog({subject = "Lock", dialog = "Sir, yes sir!"})

							statement3Revised = true -- THIS UPDATES THE STATEMENT
						else
							-- GAVE UP
							vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
							vnm.dialog({subject = "Me", dialog = "Actually... nevermind."})
						end
					else
						-- GAVE UP
						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Me", dialog = "(It's probably just standard oil...)"})
					end

				elseif choice3 == 2 then -- WRONG PRESENT
					vnm.promptEvidence()
					vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Judge", dialog = "The Defense is grasping at straws."})
				end

			else
				-- REVISED STATEMENT 3
				vnm.dialog({subject = "Lock", dialog = "I was busy fixing the door hinges with heavy-duty grease, so I didn't see the body until it was too late!"})
				local choice3Revised = vnm.promptChoice({choices = {"Press", "Present", "Continue"}, variableName = "Press8_3R"})

				if choice3Revised == 1 then -- PRESS REVISED
					vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
					vnm.playSound({soundPath = "sfx/story/objection"})
					vnm.dialog({subject = "Me", dialog = "Hold it!"})
					vnm.dialog({subject = "Me", dialog = "You're sure you just stayed at the hinges?"})
					vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
					vnm.dialog({subject = "Lock", dialog = "That is what I said, civilian!"})

				elseif choice3Revised == 2 then -- PRESENT EVIDENCE
					local evidenceId = vnm.promptEvidence()
					print("STORY SCRIPT: Received Evidence ID: ", evidenceId)

					if evidenceId == "GoldStatue" then
						-- [[ THE FINAL BLOW SEQUENCE ]] --
						crossExamining = false 

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.stopAudioTrack({track=1}) 
						vnm.playSound({soundPath = "sfx/story/objection"})

						clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358")
						vnm.dialog({subject = "Me", dialog = "Objection!"})


						vnm.dialog({subject = "Me", dialog = "Sgt. Lock! You claim you were fixing the door hinges and never went deeper into the vault?"})

						vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Lock", dialog = "Affirmative! I held the perimeter at the doorway! Leaving my post would be desertion!"})

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Me", dialog = "Then explain why there was grease on the murder weapon."})

						-- Re-Show Evidence
						vnm.playSound({soundPath = "sfx/story/evidence"})
						vnm.linkSubjectToPortrait({subject = "...", portraitName = "GoldStatue"})
						vnm.dialog({subject = "...", dialog = "[EVIDENCE PRESENTED: GREASED GOLD STATUE]"})
						vnm.linkSubjectToPortrait({subject = "...", portraitName = nil})

						vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
						vnm.playSound({soundPath = "sfx/story/objection"})
						vnm.dialog({subject = "Petty", dialog = "Objection!"})
						vnm.dialog({subject = "Petty", dialog = "So? What does the grease have to do with this?"})

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "79796415738081") -- Desk Slam
						vnm.playSound({soundPath = "sfx/story/deskslam"})

						vnm.dialog({subject = "Me", dialog = "Mr. Petty, you claimed earlier that the grease on the murder weapon belonged to the defendant because he's a mechanic."})

						vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Petty", dialog = "Correct!"})

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358") -- Point
						vnm.dialog({subject = "Me", dialog = "But Sgt. Lock just testified that HE was using heavy-duty grease to fix the hinges!"})
						vnm.playSound({soundPath = "bgm/PressingPersuitAlt", track = 1}) -- Final Pursuit Theme
						vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayOneShotAnim", "Otto Lock", "116697544329781") -- Shock
						vnm.playSound({soundPath = "sfx/story/punch4"})
						vnm.dialog({subject = "Lock", dialog = "Ack! ...Enemy radar... detected!"})
						clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "100022269866843") -- Sweating

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Me", dialog = "If you were only fixing the door hinges at the entrance, how did YOUR grease get on the murder weapon located 30 feet away on the back wall?!"})

						vnm.setCamera({ cameraName = "2", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayOneShotAnim", "Percy Petty", "116697544329781") 
						vnm.playSound({soundPath = "sfx/story/sfx-whoops"})
						vnm.dialog({subject = "Petty", dialog = "(Squeaks) M-Maybe the grease... flew through the air via tactical wind currents?"})

						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayLoopAnim", "PlayerModel_Cutscene", "83847709784358") -- Point
						vnm.dialog({subject = "Me", dialog = "No! The only way the grease got there is if Otto walked all the way to the back of the vault, picked up the statue, and struck Mr. Billions himself!"})

						-- BREAKDOWN ANIMATION
						vnm.setCamera({ cameraName = "7", transitionInfo = { type = "cut" } })
						clientToServer:FireServer("PlayLoopAnim", "Otto Lock", "133401649694034") 
						vnm.playSound({soundPath = "sfx/story/breakdown"}) 
						vnm.shake({intensity = 5, duration = 2})

						vnm.dialog({subject = "Lock", dialog = "FAILURE! FAILURE! FAILURE!"})
						vnm.dialog({subject = "Lock", dialog = "I... The door... it was fixed! But the Manager... he was going to cut the security budget!"})
						vnm.dialog({subject = "Lock", dialog = "It was a tactical elimination!"})
						vnm.playSound({soundPath = "sfx/story/damage2"})
						vnm.dialog({subject = "Lock", dialog = "CLEAN UP ON AISLE... FAILED."})

						vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
						vnm.stopAudioTrack({track=1, fade=true})
						vnm.playSound({soundPath = "sfx/story/gavel"})
						vnm.dialog({subject = "Judge", dialog = "Order! Bailiff, arrest this man for the murder of Mr. Billions!"})

						-- FADE OUT
						vnm.addImageCover({
							coverName = "Black", 
							fadeTime = 3 
						})
						task.wait(3)

					else
						-- WRONG EVIDENCE
						vnm.setCamera({ cameraName = "3", transitionInfo = { type = "cut" } })
						vnm.playSound({soundPath = "sfx/story/objection"})
						vnm.dialog({subject = "Me", dialog = "Take that!"})
						task.wait(1)
						vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })
						vnm.dialog({subject = "Judge", dialog = "Mr. Lawyer, how is that relevant?"})
						vnm.playSound({soundPath = "sfx/story/punch"}) 
					end
				end
			end
		end -- End Statement 3

		if crossExamining then
			vnm.setCamera({ cameraName = "4", transitionInfo = { type = "cut" } })
			vnm.dialog({subject = "Clara", dialog = "Something about his work doesn't add up... press him on the door!"})
		end

	end -- End While Loop
end

-- ======================================
-- SCENE 8: THE COURTROOM9 (POST-TRIAL)
-- ======================================
function Courtroom9()
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 0         -- How long the fade takes in seconds
	})
	vnm.addEvidence({id = "Badge"})
	vnm.addEvidence({id = "ATMReceipt"})
	vnm.addEvidence({id = "AutopsyReport1"})
	vnm.addEvidence({id = "BankSecurityManual"})
	vnm.addEvidence({id = "GoldStatue"})
	vnm.linkSubjectToScrollSoundSet({subject = "...", scrollSoundSetName = "typewriter"})
	vnm.linkSubjectToScrollSoundSet({subject = "Me", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Petty", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Clara", scrollSoundSetName = "female"})
	vnm.linkSubjectToScrollSoundSet({subject = "Robbie", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Lock", scrollSoundSetName = "male"})
	vnm.linkSubjectToScrollSoundSet({subject = "Judge", scrollSoundSetName = "male"})
	clientToServer:FireServer("SetupCourtroom") 
	serverToClient.OnClientEvent:Wait() 
	local favoriteColor = vnm.getStoryVariable("playerName")
	vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
	vnm.removeImageCover(1)
	wait(2)



	-- 3. THE GAVEL SEQUENCE
	vnm.playSound({soundPath = "bgm/gallery", track = 1})	

	task.wait(2) 

	-- Cut to close up (Cam 8)
	vnm.setCamera({ cameraName = "8", transitionInfo = { type = "cut" } })
	clientToServer:FireServer("PlayOneShotAnim", "JudgeV1", "123089019725293")
	task.wait(.5)
	vnm.playSound({soundPath = "sfx/story/gavel"})
	task.wait(1)

	-- Cut back to wide shot (Cam 1)
	clientToServer:FireServer("PlayLoopAnim", "JudgeV1", "70819007264019")
	vnm.playSound({soundPath = "bgm/CourtStart", track = 1})	
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })


	-- 4. Dialogue
	vnm.dialog({subject = "Judge", dialog = "It appears that Mr. Otto Lock was the one that killed Mr. Billions"})
	vnm.dialog({subject = "Judge", dialog = "With that, I shall present my verdict"})
	vnm.dialog({subject = "Judge", dialog = "The court finds the defendant, Mr. Robbie Banks..."})
	vnm.stopAudioTrack({track = 1})
	vnm.playSound({soundPath = "sfx/story/guilty"})
	vnm.dialog({subject = "Judge", dialog = "Not Guilty"})
	vnm.setCamera({ cameraName = "6", transitionInfo = { type = "cut" } })
	vnm.playSound({soundPath = "sfx/story/gallerycheer"})
	wait(4)
	-- Cut to close up (Cam 8)
	vnm.setCamera({ cameraName = "8", transitionInfo = { type = "cut" } })
	clientToServer:FireServer("PlayOneShotAnim", "JudgeV1", "123089019725293")
	task.wait(.5)
	vnm.playSound({soundPath = "sfx/story/gavel"})
	task.wait(1)

	-- Cut back to wide shot (Cam 1)
	clientToServer:FireServer("PlayLoopAnim", "JudgeV1", "70819007264019")	
	vnm.setCamera({ cameraName = "1", transitionInfo = { type = "cut" } })


	-- 4. Dialogue
	vnm.dialog({subject = "Judge", dialog = "And with that... This court is adjourned."})
	vnm.addImageCover({
		coverName = "Black", -- Must match the name in vnSystem/images/covers
		fadeTime = 2         -- How long the fade takes in seconds
	})
	wait(2)
	vnm.playSound({soundPath = "bgm/Won", track = 1})	
	vnm.dialog({subject = "Me", dialog = "And with that... My very first case is over with!"})
	vnm.dialog({subject = "Me", dialog = "And its all thanks to Clara and my client, Robbie!"})
	wait(3)
	vnm.dialog({subject = "Me", dialog = "Even though the case is done..."})
	vnm.dialog({subject = "Me", dialog = "I think the story is just getting started."})
	wait(1)
	vnm.playSound({soundPath = "sfx/story/lightbulb"})
	vnm.dialog({subject = "Me", dialog = "Well that settles it."})	
	vnm.dialog({subject = "Me", dialog = "It's time to take on another case!"})	
	vnm.stopAudioTrack({track = 1, fade = true})
	wait (2)
	vnm.dialog({subject = "...", dialog = "Thank you for playing the demo!"})	
	vnm.dialog({subject = "...", dialog = "This was just a little side project I made."})	
	vnm.dialog({subject = "...", dialog = "I hope enjoyed it."})	
	vnm.dialog({subject = "...", dialog = "My main stuff is music. I go by GreenArts. Check it out!"})	
	vnm.dialog({subject = "...", dialog = "Bye now!"})	
	wait (2)

end

-- ======================================
-- REGISTRATION
-- ======================================
vnm.registerScene({ sceneName = "trial1Scene", sceneFunction = trial1Scene })
vnm.registerScene({ sceneName = "Courtroom", sceneFunction = Courtroom })
vnm.registerScene({ sceneName = "Courtroom2", sceneFunction = Courtroom2 })
vnm.registerScene({ sceneName = "Courtroom3", sceneFunction = Courtroom3 })
vnm.registerScene({ sceneName = "Courtroom4", sceneFunction = Courtroom4 })
vnm.registerScene({ sceneName = "Courtroom5", sceneFunction = Courtroom5 })
vnm.registerScene({ sceneName = "Courtroom6", sceneFunction = Courtroom6 })
vnm.registerScene({ sceneName = "Courtroom7", sceneFunction = Courtroom7 })
vnm.registerScene({ sceneName = "Courtroom8", sceneFunction = Courtroom8 })
vnm.registerScene({ sceneName = "Courtroom9", sceneFunction = Courtroom9 })
vnm.registerChapter({
	chapterName = "The First Trial",
	chapterIndex = 1,
	scenes = {"trial1Scene", "Courtroom", "Courtroom2", "Courtroom3", "Courtroom4", "Courtroom5", "Courtroom6", "Courtroom7", "Courtroom8", "Courtroom9",}
})