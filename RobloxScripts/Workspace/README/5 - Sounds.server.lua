--[[

- INTRODUCTION -
What's a visual novel without sound? In this lesson, we'll learn how to
incorporate sound into your visual novel. This includes background music, sound
effects, and scroll sounds!


- PLAYING A SOUND -
To play a sound, you can use the vnm.playSound() function. Let's use the
"woosh" sound under vnSystem > sounds > sfx > story.
Place this code before the line executing exitStage:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.playSound({soundPath = "sfx/story/woosh"})
---------------------------------------------------------------------------------

For sound effects, it's as simple as that! Now, when the Dummy exits the stage,
it will be accompanied by a woosh sound.


- PLAYING MUSIC -
Music also uses the vnm.playSound() function, but it also uses an additional
feature: Audio tracks!

Audio tracks serve the simple function of making sure sounds of the same type
don't overlap. In this case, we only want one music track playing at a time.

To play a sound in an audio track, specify "track" as a number, like so.
Add this code to the beginning of your scene function:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.playSound({soundPath = "bgm/calm", track = 1})
---------------------------------------------------------------------------------

This means that if a sound is already playing in track 1, that sound will
automatically stop before playing the new sound.

By default, when this happens, the sounds will stop and start immediately. This
can sound a bit jarring in some cases, so let's use the "fade" property to make
sure music smoothly transitions from one track to another.
-----------------------------------CODE SAMPLE-----------------------------------
vnm.playSound({soundPath = "bgm/calm", track = 1, fade = true})
---------------------------------------------------------------------------------

Now your scene should be accompanied by some pleasant, calm music!


- SCROLL SOUNDS -
Scroll sounds are the sounds that play when dialog is appearing onscreen. This is
a common practice to convey a character's voice without requiring a unique voice
recording for every line of dialog, or just to spice up what would otherwise be
silent dialog.

To change the set of scroll sounds used for a line of dialog, specify the
property "scrollSoundSetName" in vnm.dialog().
For our example, we're going to use the "undertale" preset and apply it to the
line where the player is talking.
-----------------------------------CODE SAMPLE-----------------------------------
vnm.dialog({subject = "You", dialog = "Hi, how are you?", scrollSoundSetName = "undertale"})
---------------------------------------------------------------------------------

Now, when the line "Hi, how are you?" is played, you should hear a diifferent
scroll sound!

However, it can be rather tedious specifying scrollSoundSetName for every single
line spoken by one character. Instead, we can use linkSubjectToScrollSoundSet to
make it so that a subject always uses a specific scroll sound set automatically.

At the top of your scene function, add this code:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.linkSubjectToScrollSoundSet({subject = "Dummy", scrollSoundSetName = "oneshot"})
---------------------------------------------------------------------------------

Now, every time Dummy speaks, the scroll sound set used is the "oneshot" preset!

Don't want to use scroll sounds? You can disable scroll sounds for one line by
specifying it as "none", or make scroll sounds disabled by default by deleting
all the sounds inside vnSystem > sounds > sfx > scrollSounds > default.

Now, your script should look like this:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	vnm.linkSubjectToScrollSoundSet({subject = "Dummy", scrollSoundSetName = "oneshot"})
	vnm.setBackground({backgroundName = "baseplate"})
	vnm.playSound({soundPath = "bgm/calm", track = 1, fade = true})
	local dummySprite = vnm.createSprite({
		name = "Dummy",
		defaultImageName = "dummy",
	})
	vnm.dialog({subject = "Dummy", dialog = "Hello, world!"})
	vnm.dialog({subject = "You", dialog = "Hi, how are you?", scrollSoundSetName = "undertale"})
	vnm.dialog({subject = "Dummy", dialog = "Great, thanks!"})
	vnm.dialog({subject = "Dummy", dialog = "This place is boring. Let's head somewhere new!"})
	vnm.setBackground({backgroundName = "park", fadeTime = 0.5})
	local noobSprite = vnm.createSprite({
		name = "Noob",
		defaultImageName = "noob",
		autoPosition = -1,
		transitionType = "slideFromLeft",
	})
	vnm.dialog({subject = "Noob", dialog = "Hey, Dummy! Have you paid me back for those $50 yet?"})
	vnm.dialog({subject = "Dummy", dialog = "Uhhh..."})
	vnm.playSound({soundPath = "sfx/story/woosh"})
	vnm.exitStage({spriteName = "Dummy", transitionType = "slideRight"})
	task.wait(0.5)
	vnm.dialog({subject = "Noob", dialog = "Hey, get back here!"})
end

vnm.registerScene({
	sceneName = "myFirstScene",
	sceneFunction = myFirstScene,
})

vnm.registerChapter({
	chapterName = "My First Scene",
	chapterIndex = 1,
	scenes = {"myFirstScene"},
})
---------------------------------------------------------------------------------

And that's the last scripting lesson! The final lesson will teach you how to
customize the appearance of your visual novel to your liking.

]]