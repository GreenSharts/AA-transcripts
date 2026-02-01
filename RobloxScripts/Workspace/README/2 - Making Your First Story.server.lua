--[[

- INTRODUCTION -
In this tutorial, we're going to cover the very basics of how to use SVNE
through scripting. If you have zero scripting experience, don't worry! I'll walk
you through the process step-by-step.


- DISABLING THE DEMO -
First, you'll want to disable the demo script to make sure it doesn't interfere
with your script.

Select "demo" under StarterPlayer > StarterPlayerScripts, and set the
"Enabled" property to false.

You can also delete the script if you would prefer, but I advise against this,
as it may be useful to reference later.


- LOADING SVNE -
To start using SVNE, create a LocalScript and add it to StarterPlayerScripts.
Then, copy and paste the following code into your new script:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()
---------------------------------------------------------------------------------
This code is responsible for loading the vnModule script, which contains all the
tools used to create your story.


- MAKING YOUR FIRST SCENE -
SVNE organizes story sequences into scenes and chapters.

A scene is a sequence of story events. This includes dialog, background changes,
sound effects, sprite creation and modification, etc. A scene is represented by
a function.

A chapter is a sequence of scenes. When a chapter is played, each scene in the
chapter is played in order until the chapter finishes or the player exits to
the main menu.

To create a scene, first create a function by adding the following code to the
end of your script:
-----------------------------------CODE SAMPLE-----------------------------------
function myFirstScene()
	
end
---------------------------------------------------------------------------------

Inside your function is where we will place the code to control the scene. For
now, we're just going to play some dialog, using the vnm.dialog function.
-----------------------------------CODE SAMPLE-----------------------------------
function myFirstScene()
	vnm.dialog({dialog = "Hello, world!"})
end
---------------------------------------------------------------------------------

To confirm we've written our scene correctly, execute your function by typing
myFirstScene() at the end. Your code should now look something like this:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	vnm.dialog({dialog = "Hello, world!"})
end

myFirstScene()
---------------------------------------------------------------------------------

Now, run a quick playtest. You should see a dialog box appear, reading out the
text "Hello, world!"

If this doesn't work, double check to make sure you've typed everything
correctly. Make sure all letters that should be capital are capital, and all
letters that should be lowercase are lowercase.

IMPORTANT:
Connections created inside of a scene function will NOT be automatically
disconnected when exiting the story. You must log them using
vnm.logStoryConnection().


- MAKING YOUR FIRST CHAPTER -
Congratulations! You've created a function that serves as your first scene.

However, we're missing a lot of critical features. The "New game" button doesn't
work, the chapter select is empty, and you can't save and load!

To make use of these features, we're going to have to register this scene into
vnModule, then wrap it inside a chapter.
First, delete the line that executes the myFirstScene function.
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	vnm.dialog({dialog = "Hello, world!"})
end
---------------------------------------------------------------------------------

Then, at the end of your script, add the following code:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.registerScene({
	sceneName = "myFirstScene",
	sceneFunction = myFirstScene,
})
---------------------------------------------------------------------------------

Now, your scene is registered, but we have no way to play it!

To reach this scene, we're going to have to wrap it inside a chapter, then play
that chapter.

Register a chapter by adding the following code at the end of your script:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.registerChapter({
	chapterName = "My First Scene",
	chapterIndex = 1,
	scenes = {"myFirstScene"},
})
---------------------------------------------------------------------------------

Your script should now look like this:
-----------------------------------CODE SAMPLE-----------------------------------
local vnm = require(script.Parent.vnModule)
vnm.init()

function myFirstScene()
	vnm.dialog({dialog = "Hello, world!"})
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

Because we registered chapter 1, we can now use the "New game" button to play our
chapter, and all other features should now be functional!

Start a playtest, then click "New game" to begin chapter 1. Once you finish, you
will automatically be sent back to the menu.

IMPORTANT:
Saving and loading only works for the beginning of a scene. Saving will only save
from the moment the current scene began, and loading will only load from the
beginning of the latest scene. For this reason, you should avoid making scenes
excessively long!

Congratulations! You've technically made a complete visual novel, with a clear
start and end.

...Technically. Let's be honest, this is extremely boring, and it leaves us with
a lot to be desired.

If you're confident enough with scripting that you feel you could figure this
out from here, try reading through the demo and documentation scripts to get
your footing.

Otherwise, continue to lesson 3: Sprites.

]]