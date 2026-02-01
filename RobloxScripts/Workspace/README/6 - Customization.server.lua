--[[

- INTRODUCTION -
Now that you've learned how to create scenes and chapters, create and manipulate
sprites, set backgrounds, and play sounds, it's time to break away from these
presets and start making this story your own!


- ADDING NEW ASSETS -
As you may have inferred by now, assets used for your visual novel can be found
under the vnSystem > sounds and vnSystem > images folders.

To add a new asset, it's as simple as creating a new Sound or ImageLabel object,
naming it, setting its properties, and then placing it in the proper folder.


- REPLACING ASSETS -
Some assets don't require you to create a new object, and can just be edited by
changing the properties of an existing object.
This includes the gui sounds and the menu.

You can find those at the following locations:
Gui sounds - vnSystem > sounds > sfx > gui
Menu - vnGui > Menu


- THEMING -
The Gui can be easily customized by configuring the objects under
vnSystem > configuration > theme.

Edit the Value property of themePreset to the name of any folder under
vnSystem > themePresets to use any one of the theme presets. If you don't want
to use a theme preset, set the Value property to "none".

If you edit the background color of frameTemplate, it will change the color for
all Frame objects. If you edit the TextColor3 property of textTemplate, it will
change the text color for all text objects, and so on.

You can even add instances such as a UICorner to frameTemplate, and it will be
copied over into every frame!

Prefer not to use this system? Set the Value property of "useTheme" to false.

Want to disable theming for one specific Gui object? Create a new boolean
attribute on your object named "noTheme", and set it to true.

]]