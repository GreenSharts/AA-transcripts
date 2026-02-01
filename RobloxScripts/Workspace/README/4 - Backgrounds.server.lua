--[[

- INTRODUCTION -
Now we have some characters onscreen, but they're talking in a blank void. Let's
add a background to give them some scenery!


- ADDING A BACKGROUND -
To add a background, execute the function vnm.setBackground(). Let's start with
the "baseplate" background.
Add this code at the top of your scene function:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.setBackground({backgroundName = "baseplate"})
---------------------------------------------------------------------------------
This will set the background image to the image specified in
vnSystem > images > backgrounds.
Now, the scene should have a baseplate background!


- CHANGING THE BACKGROUND -
To change the background, just run vnm.setBackground() again with a different
background name. You can also specify the "fadeTime" property if you would like
the new background to smoothly fade in.

Insert this code right before the line creating the Noob sprite:
-----------------------------------CODE SAMPLE-----------------------------------
vnm.dialog({subject = "Dummy", dialog = "This place is boring. Let's head somewhere new!"})
vnm.setBackground({backgroundName = "park", fadeTime = 0.5})
---------------------------------------------------------------------------------
Now, midway through the scene, the background will change to a park!

]]