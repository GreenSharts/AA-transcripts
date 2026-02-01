--[[

This is a list of every function vnModule has and what it does, sorted alphabetically.
More documentation is provided underneath this script.


- addColorCover -
Covers the screen with a solid color.

PARAMETERS
params: table
	color: Color3 -- The color the cover should be.
	fadeTime: number? -- How long it should take the cover to fade in.

CODE SAMPLE
vnm.addColorCover({color = Color3.new(0, 0, 0), fadeTime = 0.5})


- addImageCover -
Covers the screen with an image.

PARAMETERS
params: table
	coverName: string -- The name of the cover.
	fadeTime: number? -- How long it should take the cover to fade in.

CODE SAMPLE
vnm.addImageCover({coverName = "curtains", fadeTime = 0.5})


- autoRepositionSprites -
Automatically repositions all sprites with allowAutoPosition set to true.

PARAMETERS
params: table,
	tweenTime: number? -- The time it takes for sprites to reposition.
	spriteOrder: {string}? -- How sprites should be ordered.

CODE SAMPLE
vnm.dialog({subject = "Noob", dialog = "Square dance!"})
vnm.autoRepositionSprites({
	tweenTime = 0.5,
	spriteOrder = {"Noob", "Dummy"},
})
task.wait(0.5)
vnm.autoRepositionSprites({
	tweenTime = 0.5,
	spriteOrder = {"Dummy", "Noob"},
})


- createSprite -
Creates a sprite object. See the documentation for sprite under this script.

PARAMETERS
params: table
	name: string -- The name of the sprite.
	defaultImageName: string -- The default sprite to use.
	defaultPosition: UDim2? -- The default position. Takes priority over autoPosition.
	defaultSize: UDim2? -- The default size.
	interactable: boolean? -- Whether the sprite can be clicked to activate an event.
	allowAutoPosition: boolean? -- Whether the sprite should be moved during auto positioning of new sprites. Defaults to true.
	allowAutoEmphasize: boolean? -- Whether the sprite should be emphasized automatically when the subject of a dialog sequence matches the sprite name. Defaults to true.
	autoPosition: number? -- Automatically shifts existing sprites to make room, then positions the new sprite to the left (-1), center (0), or right (1).
	tweenTime: number? -- The time it takes for the tweens involved in the creation of this sprite. Defaults to DEFAULT_TWEEN_INFO.Time.
	transitionType: "slideFromLeft" | "slideFromRight" | "slideFromBottom" | "slideFromTop" | "fade" | nil -- How the sprite should transition into appearing onscreen.

CODE SAMPLE
local noobSprite = vnm.createSprite({
	name = "Noob",
	defaultImageName = "noob",
	autoPosition = -1,
	transitionType = "slideFromLeft",
})


- deemphasize -
De-emphasizes the current emphasized sprites.

CODE SAMPLE
vnm.deemphasize()


- destroyAllSprites -
Destroys all sprites.

CODE SAMPLE
vnm.destroyAllSprites()


- dialog -
Displays dialog.

PARAMETERS
params: table,
	subject: string? -- The person speaking. Leave blank for narration or inner monologues.
	spriteToEmphasize: string? -- The sprite to emphasize during this dialog. If left blank, subject is used instead. Set to "none" to emphasize nobody.
	portrait: string? -- The portrait to use.
	dialog: string -- The dialog being spoken.
	append: boolean? -- When true, the previous line of dialog will not be cleared.
	scrollSpeed: number? -- The speed multiplier for how fast text scrolls. Set to -1 to show text instantly.
	scrollSoundSetName: Folder? -- The set of scroll sounds to use. Set to "none" for no sound.
	waitForAdvanceInput: boolean? -- When set to false, dialog will continue immediately without the player's input.
	skippable: boolean? -- When set to false, the player cannot skip the text scrolling.

CODE SAMPLE
vnm.dialog({subject = "John Doe", dialog = "Hello, world!"})


- emphasize -
Emphasizes the specified sprites.

PARAMETERS
spritesToEmphasize: table -- A list of the names of the sprites that should be emphasized.

CODE SAMPLE
vnm.emphasize({"Noob", "Dummy"})


- enterRoaming -
Hides some components of the visual novel GUI to allow the player to see the map and grants the player control of their character.
Make sure to eventually return the player using exitRoaming!

IMPORTANT:
Changes you make to the game outside of SVNE will NOT automatically revert when the player exits roaming!
Make sure your script resets any external changes made before entering roaming mode!


CODE SAMPLE
vnm.enterRoaming()


- exitRoaming -
Returns the visiblity of the visual novel GUI and disables character control.

CODE SAMPLE
vnm.exitRoaming()


- exitStage -
Animates the specified sprite offscreen and destroys it.

PARAMETERS
params: table
	spriteName: string
	transitionType: "slideLeft" | "slideRight" | "slideUp" | "slideDown" | "fade" | nil

CODE SAMPLE
vnm.exitStage({spriteName = "Dummy", transitionType = "fade"})


- forceChoice -
Forces a choice to be selected. Only works during the "waitingForChoice" game state.

PARAMETERS
choice: number -- The choice to select.

CODE SAMPLE
vnm.forceChoice(2)


- getGameState -
Returns the current game state.

CODE SAMPLE
local gameState = vnm.getGameState()
print(gameState)


- getStoryVariable -
Returns the specified story variable.

PARAMETERS
variableName: string -- The name of the variable

CODE SAMPLE
vnm.setStoryVariable({name = "noobRelationship", data = 0})
local relationship = vnm.getStoryVariable("noobRelationship")
print(relationship)


- hideDialogBox -
Hides the dialog box.

CODE SAMPLE
vnm.hideDialogBox()


- hideSpritesFrame -
Hides the frame sprites are rendered on.

CODE SAMPLE
vnm.hideSpritesFrame()


- inRoamingMode -
Returns whether roaming mode is enabled.

CODE SAMPLE
if vnm.inRoamingMode() then
	print("In roaming mode!")
else
	print("Not in roaming mode!")
end


- linkSubjectToScrollSoundSet -
Links a subject to a scroll sound set, so that dialog lines with the given subject use the given scroll sound set by default.

PARAMETERS
params: table
	subject: string
	scrollSoundSetName: string?

CODE SAMPLE
vnm.linkSubjectToScrollSoundSet({subject = "Noob", scrollSoundSetName = "undertale"})
task.wait(3)
vnm.dialog({subject = "Noob", dialog = "Hello, world!"})


- linkSubjectToPortrait -
Links a subject to a portrait, so that dialog lines with the given subject will automatically change the portrait.

PARAMETERS
params: table
	subject: string
	portraitName: string?
	
CODE SAMPLE
vnm.linkSubjectToPortrait({subject = "Noob", portraitName = "noob"})
task.wait(3)
vnm.dialog({subject = "Noob", dialog = "Hello, world!"})


- playChapter -
Plays a chapter.

PARAMETERS
chapterIndex: number

CODE SAMPLE
vnm.playChapter(1)


- playSound -
Clones and plays a sound. Returns the cloned sound.

PARAMETERS
params: table
	soundPath: string -- The path to the sound, starting from vnSystem.sounds and separated by slashes.
	track: number? -- The audio track to use.
	fade: boolean? -- Whether the new audio should be faded in and the old audio faded out.

CODE SAMPLE
vnm.playSound({soundPath = "bgm/calm", track = 1})
task.wait(3)
vnm.playSound({soundPath = "sfx/story/punchLight"})
task.wait(3)
vnm.playSound({soundPath = "bgm/suspense", track = 1, fade = true})


- promptChoice -
Prompts the player with a set of choices.

PARAMETERS
params: table
	choices: {string} -- The list of choices.
	choicesUnlocked: {boolean}? -- Which choices are unlocked. Locked choices are greyed out and cannot be selected.
	lockedTexts: {string}? -- Optional replacement text for when an option is locked.
	variableName: string? -- The key to save this choice to. Leave blank if you don't want to save this choice.

CODE SAMPLE
local choice = vnm.promptChoice({
	choices = {"Red", "Green", "Blue", "Secret"},
	choicesUnlocked = {true, true, true, false},
	variableName = "favoriteColor"
})
if choice == 1 then
	vnm.dialog({subject = "You", dialog = "I like red."})
elseif choice == 2 then
	vnm.dialog({subject = "You", dialog = "I like green."})
elseif choice == 3 then
	vnm.dialog({subject = "You", dialog = "I like blue."})
elseif choice == 4 then
	vnm.dialog({subject = "You", dialog = "I like a secret fourth option!"})
end


- promptTextInput -
Prompts the player to input text.

PARAMETERS
params: table
	placeholderText: string? -- Optional placeholder text to put in the text box.
	maxCharacters: number? -- How many characters are permitted in this text input.
	variableName: string? -- THe key to save this input to. Leave blank if you don't want to save this input.

CODE SAMPLE
local playerName = vnm.promptTextInput({placeholderText = "Name", maxCharacters = 20, variableName = "playerName"})
vnm.dialog({subject = "John Doe", dialog = `Nice to meet you, {playerName}!`})


- registerChapter -
Registers a chapter, which is a group of scenes played in sequence.

PARAMETERS
params: table
	chapterIndex: number -- The chapter number.
	chapterName: string
	scenes: {string} -- The names of which scenes should be played, in order.
	nextChapterIndex: number? -- The chapter to go to after this chapter finishes. Defaults to chapterIndex + 1.

CODE SAMPLE
function scene1()
	vnm.dialog({dialog = "Hello, world!"})
end

function scene2()
	vnm.dialog({dialog = "Goodbye, world!"})
end

vnm.registerScene({
	sceneName = "scene1",
	sceneFunction = scene1,
})
vnm.registerScene({
	sceneName = "scene2",
	sceneFunction = scene2,
})
vnm.registerChapter({
	chapterIndex = 1,
	chapterName = "Test Chapter",
	scenes = {"scene1", "scene2"},
})


- registerScene -
Registers a scene, which is a function that plays a sequence of story events.

PARAMETERS
params: table
	sceneName: string
	sceneFunction: function

CODE SAMPLE
function myFirstScene()
	vnm.dialog({dialog = "Hello, world!"})
end

vnm.registerScene({
	sceneName = "myFirstScene",
	sceneFunction = myFirstScene,
})


- removeColorCover -
Removes the color cover.

PARAMETERS
fadeTime: number? -- How long it should take the cover to fade out.

CODE SAMPLE
vnm.removeColorCover(0.5)


- removeImageCover -
Removes the image cover.

PARAMETERS
fadeTime: number? -- How long it should take the cover to fade out.

CODE SAMPLE
vnm.removeImageCover(0.5)


- scheduleCue -
Schedules a function to be run the next time text matching the cue appears in the dialog box.
If the same cue is scheduled multiple times, functions are run in the order in which they were scheduled.
Scheduled cues are cleared at the end of every line of dialog.

PARAMETERS
cue: string, -- The cue to run the function on.
callback: function, -- The function to be run.

CODE SAMPLE
vnm.scheduleCue("Noob", function()
	print("Noob was mentioned the first time!")
end)
vnm.scheduleCue("Noob", function()
	print("Noob was mentioned the second time!")
end)


- setBackground -
Changes the current background.

PARAMETERS
params: table
	backgroundName: string -- The name of the background.
	fadeTime: number? -- How long the new background should take to fade in.

CODE SAMPLE
vnm.setBackground({backgroundName = "baseplate"})
task.wait(1)
vnm.setBackground({backgroundName = "park", fadeTime = 0.5})


- shake -
Shakes the dialog box.

PARAMETERS
params: table
	intensity: number -- How intense the shaking should be.
	duration: number -- How long the shaking should last.

CODE SAMPLE
vnm.shake({intensity = 10, duration = .2})


- showSpritesFrame -
Shows the frame sprites are rendered on.

CODE SAMPLE
vnm.showSpritesFrame()


- stopAudioTrack -
Stops the sound playing in an audio track.

PARAMETERS
params: table
	track: number -- The audio track to stop.
	fade: boolean -- Whether the audio should fade out.

CODE SAMPLE
vnm.stopAudioTrack({track = 1, fade = true})


- setStoryVariable -
Sets a story variable with the given name and value.

PARAMETERS
params: table
	name: string -- The name of the variable.
	data: string | number | boolean -- What to set the variable to.

CODE SAMPLE
vnm.setStoryVariable({name = "noobRelationship", data = 0})
vnm.setStoryVariable({name = "foundSecret", data = false})


- titleCard -
Displays a title card.
params: table
	text: string -- The text to display on the title card.
	duration: number -- How long to display the title card for.
	fadeInTime: number? -- How long it should take for the title card to fade in.
	fadeOutTime: number? -- How long it should take for the title card to fade out.

CODE SAMPLE
vnm.titleCard({
	text = "Hello, world!",
	duration = 5,
	fadeInTime = 0.5,
	fadeOutTIme = 0.5,
})


- unlockChapter -
Unlocks the chapter with the given number.

PARAMETERS
chapterIndex: number -- The chapter number.

CODE SAMPLE
vnm.unlockChapter(2)


- waitForAdvanceInput -
Waits for the player to click or tap the dialog box before continuing.

CODE SAMPLE
vnm.waitForAdvanceInput()

]]