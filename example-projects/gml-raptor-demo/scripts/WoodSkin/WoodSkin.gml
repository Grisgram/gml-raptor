/*
    Raptor's default skin.
	
	This script is here for you, so you can see, how you can easily define your own skin:
	Just derive from "UiSkin", give it a name, and set the sprites you want, then add 
	the skin to the UiSkinManager by invoking "UI_SKINS.add_skin(new YourSkin());"
	
	While the sprites used for this default theme are placed in raptor core, I recommend, that
	you create a folder in "skins" for each skin and put your sprites for the skin directly there,
	so it's all in one place.
	
	D O   N O T   D E L E T E   T H I S   S K I N !
	It is set/added to the UiSkinManager in the raptor core when the game starts.
	You may adapt the sprite values in here at will, or simply derive your own skin and just use
	this file as a template. Whatever you do, just do not delete this one here!
	
	HOW TO EXTEND A SKIN WITH NEW OBJECTS
	It's as easy as adding the object's name as key and the sprite to use to the ds_map of the skin.
	Just add it. 
	When you activate a skin, raptor loops through the keys and uses object_set_sprite(...) on each of them!
*/

function WoodSkin(_name = "wood") : DefaultSkin(_name) constructor {

	var woodwindow = { 
		sprite_index: sprWoodWindow,
		draw_color: THEME_WHITE,
		draw_color_mouse_over: THEME_WHITE,
		focus_border_color: THEME_WHITE,
		titlebar_height: 38
	}

	var text_control = function(spr) {
		return {
			sprite_index: spr,
		};
	}

	asset_skin[? "Label"]				= text_control(sprWoodLabel);
	asset_skin[? "TextButton"]			= text_control(sprWoodButton);
	asset_skin[? "Tooltip"]				= { sprite_index: sprWoodTooltip }
	asset_skin[? "Window"]				= woodwindow;
	asset_skin[? "MessageBoxWindow"]	= woodwindow;
	asset_skin[? "DemoAlignmentWindow"]	= woodwindow;
	asset_skin[? "DemoAnchoringWindow"]	= woodwindow;
	asset_skin[? "DemoDockingWindow"]	= woodwindow;
	asset_skin[? "DemoLoginWindow"]		= woodwindow;

}

