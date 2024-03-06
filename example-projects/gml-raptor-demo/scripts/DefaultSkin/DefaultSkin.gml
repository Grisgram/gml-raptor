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

function DefaultSkin(_name = "default") : UiSkin(_name) constructor {
	var window_def = function(xbutton) { 
		return {
			sprite_index: sprDefaultWindow,
			draw_color: APP_THEME_WHITE,
			draw_color_mouse_over: APP_THEME_WHITE,
			focus_border_color: APP_THEME_MAIN,
			window_x_button_object: xbutton,
			titlebar_height: 34
		};
	}

	var text_control = function(spr) {
		return {
			sprite_index: spr,
			text_color: APP_THEME_MAIN,
			text_color_mouse_over: APP_THEME_MAIN,
			draw_color: APP_THEME_WHITE,
			draw_color_mouse_over: APP_THEME_WHITE,
		};
	}

	control_skins[? "CheckBox"]				= text_control(sprDefaultCheckbox);
	control_skins[? "ImageButton"]			= { sprite_to_use: sprDefaultButton				}
	control_skins[? "InputBox"]				= text_control(sprDefaultInputBox);
	control_skins[? "Label"]				= text_control(sprDefaultLabel);
	control_skins[? "MouseCursor"]			= { 
 												sprite_index: sprDefaultMouseCursor,
												mouse_cursor_sprite: sprDefaultMouseCursor,
 												mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 											  }
	control_skins[? "MouseCursorCompanion"]	= { sprite_index: spr1pxTrans					}
	control_skins[? "Panel"]				= { sprite_index: spr1pxTrans					}
	control_skins[? "RadioButton"]			= text_control(sprDefaultRadioButton);
	control_skins[? "Slider"]				= { 
												sprite_index: sprDefaultSliderRail,
												rail_sprite: sprDefaultSliderRail,
												knob_sprite: sprDefaultSliderKnob
											  }
	control_skins[? "TextButton"]			= text_control(sprDefaultButton);
	control_skins[? "Tooltip"]				= text_control(sprDefaultTooltip);
	control_skins[? "Window"]				= window_def(WindowXButton);
	control_skins[? "WindowXButton"]		= { sprite_index: sprDefaultXButton				}
	control_skins[? "MessageBoxWindow"]		= window_def(MessageBoxXButton);
	control_skins[? "MessageBoxXButton"]	= { sprite_index: sprDefaultXButton				}

}

