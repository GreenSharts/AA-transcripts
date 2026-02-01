--[[

- INTRODUCTION -
In SVNE, sprites are how you represent objects or people in the environment. For
this lesson, we'll be focusing primarily on using sprites as characters.


- CREATING A SPRITE -
Insert the following code at the top of your myFirstScene function:
-----------------------------------CODE SAMPLE-----------------------------------
local dummySprite = vnm.createSprite({
	name = "Dummy",
	defaultImageName = "dummy",
})
---------------------------------------------------------------------------------

This will create a new sprite object, named "Dummy", using the image named
"dummy" in Workspace > vnSystem > images > sprites, and store it as a variable
called "dummySprite".

IMPORTANT:
The size of the sprite will be based off the Size property of the image in
vnSystem > images > sprites. If you want to add a new sprite image, you'll want
to make sure you correctly set the Size property, as well as the AspectRatio
property of the UIAspectRatioConstraint object underneath the image.

Now, let's edit our dialog function so that we indicate "Dummy" is the character
speaking.
Edit the line where you execute vnm.dialog so that it looks like so:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.dialog({subject = "Dummy", dialog = "Hello, world!"})
---------------------------------------------------------------------------------

This will indicate to both the player and SVNE that this line is being spoken by
Dummy.

Let's add a few more lines of back-and-forth dialog.
Add this code after the line we just edited:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.dialog({subject = "You", dialog = "Hi, how are you?"})
vnm.dialog({subject = "Dummy", dialog = "Great, thanks!"})
---------------------------------------------------------------------------------

Your script should look like this:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	local dummySprite = vnm.createSprite({
		name = "Dummy",
		defaultImageName = "dummy",
	})
	vnm.dialog({subject = "Dummy", dialog = "Hello, world!"})
	vnm.dialog({subject = "You", dialog = "Hi, how are you?"})
	vnm.dialog({subject = "Dummy", dialog = "Great, thanks!"})
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

Playtest the game and click "New game". You should see three lines of dialog
spoken:
Dummy - Hello, world!
You - Hi, how are you?
Dummy - Great, thanks

When the dummy is the one speaking, you'll notice that the sprite of the same
name is emphasized by increasing the brightness and size!

If you don't like some of these behaviors, you can change the way sprites are
emphasized by going to vnSystem > configuration > sprites.


- ADDING MULTIPLE SPRITES -
But let's say we want more than just one character- say, another character
introduces themselves in the middle of a scene. How do we do that?

After the last line of dialog in myFirstScene, insert the following code:
-----------------------------------CODE SAMPLE-----------------------------------
local noobSprite = vnm.createSprite({
	name = "Noob",
	defaultImageName = "noob",
	autoPosition = -1,
	transitionType = "slideFromLeft",
})
---------------------------------------------------------------------------------

Whoa, we've got a lot more going on! Let's cover the new things we're using.

autoPosition: This value can be one of three numbers indicating where the new
sprite should be placed: -1 (left), 0 (center), or 1 (right). Since we specified
-1, this sprite will be positioned on the left.

transitionType: This value indicates how the sprite should appear onscreen.
Since we specified "slideFromLeft" as the transition type, the Noob sprite will
enter the scene by sliding in from the left. Compare this to our Dummy sprite:
We didn't have this value specified, so it appeared instantly, with no
transition.

Now, let's add a few more lines of dialog from our newly created pal Noob.
Insert this code after the noobSprite code you just inserted:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.dialog({subject = "Noob", dialog = "Hey, Dummy! Have you paid me back for those $50 yet?"})
vnm.dialog({subject = "Dummy", dialog = "Uhhh..."})
---------------------------------------------------------------------------------

Your code should now look like this:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	local dummySprite = vnm.createSprite({
		name = "Dummy",
		defaultImageName = "dummy",
	})
	vnm.dialog({subject = "Dummy", dialog = "Hello, world!"})
	vnm.dialog({subject = "You", dialog = "Hi, how are you?"})
	vnm.dialog({subject = "Dummy", dialog = "Great, thanks!"})
	local noobSprite = vnm.createSprite({
		name = "Noob",
		defaultImageName = "noob",
		autoPosition = -1,
		transitionType = "slideFromLeft",
	})
	vnm.dialog({subject = "Noob", dialog = "Hey, Dummy! Have you paid me back for those $50 yet?"})
	vnm.dialog({subject = "Dummy", dialog = "Uhhh..."})
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

Run a playtest once more, and notice how as Noob comes in from the left of the
screen, Dummy is automatically repositioned so they maintain equal spacing!


- EXITING SPRITES -
Not every sprite is going to stick around to the end of a scene.
To exit a sprite from the scene, we can use vnm.exitStage().
At the end of your myFirstScene function, add the following code:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.exitStage({spriteName = "Dummy", transitionType = "slideRight"})
task.wait(0.5)
---------------------------------------------------------------------------------

The "task.wait(0.5)" just waits 0.5 seconds.

Your function should now look like this:
-----------------------------------CODE SAMPLE-----------------------------------
function myFirstScene()
	local dummySprite = vnm.createSprite({
		name = "Dummy",
		defaultImageName = "dummy",
	})
	vnm.dialog({subject = "Dummy", dialog = "Hello, world!"})
	vnm.dialog({subject = "You", dialog = "Hi, how are you?"})
	vnm.dialog({subject = "Dummy", dialog = "Great, thanks!"})
	local noobSprite = vnm.createSprite({
		name = "Noob",
		defaultImageName = "noob",
		autoPosition = -1,
		transitionType = "slideFromLeft",
	})
	vnm.dialog({subject = "Noob", dialog = "Hey, Dummy! Have you paid me back for those $50 yet?"})
	vnm.dialog({subject = "Dummy", dialog = "Uhhh..."})
	vnm.exitStage({spriteName = "Dummy", transitionType = "slideRight"})
	task.wait(0.5)
	vnm.dialog({subject = "Noob", dialog = "Hey, get back here!"})
end
---------------------------------------------------------------------------------

Run another playtest and watch Dummy scurry off when questioned!

]]