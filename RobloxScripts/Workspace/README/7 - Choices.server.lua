--[[

- INTRODUCTION -
One of the strengths offered by telling a story through the videogame medium is
the ability to influence the story. In this lesson, we'll learn how to prompt the
player with choices, change dialog and events based off the player's decisions,
and even save choices made during one scene to be referenced in a later scene!

We're starting to get pretty deep into the scripting side of things! This lesson
assumes you already know the basics covered in the previous lessons, so I'll be
starting to handhold you less from here on out.

This means we will no longer be explicitly building off of the example story
we've been writing; you should know enough by now to understand how to implement
this code into your scenes as needed.


- PROMPTING A CHOICE -
To prompt a choice, we can make use of the vnm.promptChoice() function.
-----------------------------------CODE SAMPLE-----------------------------------
vnm.promptChoice({choices = {"Choice 1", "Choice 2", "Choice 3"})
---------------------------------------------------------------------------------
This will prompt the player with the choices, "Choice 1", "Choice 2", and
"Choice 3". Simple as that!


- REACTING TO CHOICES -
However, this choice doesn't currently have any impact on the story. To do that,
we need to save the result from the promptChoice function:
-----------------------------------CODE SAMPLE-----------------------------------
local choiceResult = vnm.promptChoice({choices = {"Choice 1", "Choice 2", "Choice 3"})
---------------------------------------------------------------------------------
Whoa, what do these new words mean? It means we just saved a variable!
Specifically, we have saved the result from promptChoice to choiceResult.
This means that whenever we type choiceResult later on in that function, the
script will know that we are referring to the choice made by the player!

Let's make sure we did this correctly.
In the topbar of your Roblox Studio tab, click View, then make sure Output is
toggled on. You should see a window with some text in it appear on your screen.

The output is a critical feature for debugging code; it allows us to see all
messages that the code spits out, whether because the programmer explicitly wanted
a message to be shown in a specific scenario, or because something broke and we
need to know how it broke.

To print a message to the output, make use of the print() function:
-----------------------------------CODE SAMPLE-----------------------------------
local choiceResult = vnm.promptChoice({choices = {"Choice 1", "Choice 2", "Choice 3"})
print(choiceResult)
---------------------------------------------------------------------------------

Now, playtest your scene. Once you make your choice, you should see a number
corresponding to the choice made appear in the output.

At this point, you may be catching on to something: vnModule is no longer doing
all the work for you. Saving a variable and printing it isn't something built
into what I wrote, that's just part of the Luau scripting language.

That's right. This is a full-on scripting tutorial now!

Anyway, we've confirmed that promptChoice is executing properly, but now we want
to actually do something with that result. To do that, we're going to make use
of an if statement.

An if statement is a way for a script to branch off into different paths
depending on a condition or set of conditions. Here's a quick example:
-----------------------------------CODE SAMPLE-----------------------------------
local randomNumber = math.random(1, 3)
if coinFlip == 1 then
	print("Win")
elseif coinFlip == 2 then
	print("Lose")
else
	print("Tie")
end
---------------------------------------------------------------------------------
This will either print "Win", "Lose", or "Tie", based off the variable
randomNumber, which is a random number between 1 and 3.

In our case, we might want to show different dialog depending on the choice
that the player picked. For example:
-----------------------------------CODE SAMPLE-----------------------------------
local choiceResult = vnm.promptChoice({choices = {"Choice 1", "Choice 2", "Choice 3"})
if choiceResult == 1 then
	vnm.dialog({dialog = "You picked choice 1!"})
elseif choiceResult == 2 then
	vnm.dialog({dialog = "You picked choice 2!"})
elseif choiceResult == 3 then
	vnm.dialog({dialog = "You picked choice 3!"})
end
---------------------------------------------------------------------------------

Now, the dialog played will differ depending on the player's choice!


- STORY VARIABLES -
But let's say the player makes a choice early on in the story, and we want that
to influence the story later down the line, in the next scene, or the next
chapter. This is where story variables come in.

Story variables are similar to variables in that they store data to be used
later. Where story variables differ is that they are tied to save data, meaning
if you leave and rejoin, the story variables will still be the same as when you
left!

Story variables can be set through one of two ways. The first way is through
specifying the variableName parameter of promptChoice:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.promptChoice({choices = {"Vanilla", "Chocolate", "Mint"}, variableName = "favoriteFlavor"})
---------------------------------------------------------------------------------
This means that when the player is prompted with this choice, the choice they
make will be saved to the favoriteFlavor story variable as a number indicating
their choice.

The second way to set a story variable is to set it directly through the
setStoryVariable function:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.setStoryVariable({name = "favoriteFlavor", data = 1})
---------------------------------------------------------------------------------

It's important to note that if you set a story variable directly, the data
provided can only be a string (text), number, or boolean (true/false). For
example, this would NOT work:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.setStoryVariable({name = "lookVector", data = Vector3.new(0, 1, 0)})
---------------------------------------------------------------------------------

After we set a story variable, we can retrieve it at any time later in the
story by using getStoryVariable.
-----------------------------------CODE SAMPLE-----------------------------------
vnm.promptChoice({choices = {"Vanilla", "Chocolate", "Mint"}, variableName = "favoriteFlavor"})

local favoriteFlavor = vnm.getStoryVariable("favoriteFlavor")
if favoriteFlavor == 1 then
	vnm.dialog({dialog = "Your favorite flavor is vanilla!"})
elseif favoriteFlavor == 2 then
	vnm.dialog({dialog = "Your favorite flavor is chocolate!"})
elseif favoriteFlavor == 3 then
	vnm.dialog({dialog = "Your favorite flavor is mint!"})
end
---------------------------------------------------------------------------------

IMPORTANT:
To allow for New Game+ features, story variables are NOT reset when starting a
new game. For this reason, it is best practice to explicitly set a variable to
nil when it first comes into play.

]]