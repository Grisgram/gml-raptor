/*
    Holds the data for one single ui skin.
	Creating a skin is very easy: Just assign the sprite you wish to use to each control
	in the list below.
	
	Activate/Switch skins through the UiSkinManager.
	NOTE: Same as with Themes, requires a room_restart to become active, so the best 
*/

function UiSkin(_name = "default") constructor {
	construct("UiSkin");
	ENSURE_THEMES;
	
	name = _name;
	
	control_skins = ds_map_create();
		
	control_skins[? "CheckBox"]				= { sprite_index: sprDefaultCheckbox			}
	control_skins[? "ImageButton"]			= { sprite_to_use: sprDefaultButton				}
	control_skins[? "InputBox"]				= { sprite_index: sprDefaultInputBox			}
	control_skins[? "Label"]				= { sprite_index: sprDefaultLabel				}
	control_skins[? "MouseCursor"]			= { 
 												sprite_index: sprDefaultMouseCursor,
												mouse_cursor_sprite: sprDefaultMouseCursor,
 												mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 											  }
	control_skins[? "MouseCursorCompanion"]	= { sprite_index: spr1pxTrans					}
	control_skins[? "Panel"]				= { sprite_index: spr1pxTrans					}
	control_skins[? "RadioButton"]			= { sprite_index: sprDefaultRadioButton			}
	control_skins[? "Slider"]				= { 
												sprite_index: sprDefaultSliderRail,
												rail_sprite: sprDefaultSliderRail,
												knob_sprite: sprDefaultSliderKnob
											  }
	control_skins[? "TextButton"]			= { sprite_index: sprDefaultButton				}
	control_skins[? "Tooltip"]				= { sprite_index: sprDefaultTooltip				}
	control_skins[? "Window"]				= { 
												sprite_index: sprDefaultWindow,
												window_x_button_object: WindowXButton,
												titlebar_height: 34
											  }
	control_skins[? "WindowXButton"]		= { sprite_index: sprDefaultXButton				}
	control_skins[? "MessageBoxWindow"]		= { 
												sprite_index: sprDefaultWindow,
												window_x_button_object: MessageBoxXButton,
												titlebar_height: 34
											  }
	control_skins[? "MessageBoxXButton"]	= { sprite_index: sprDefaultXButton				}
	
	/// @function delete_map()
	static delete_map = function() {
		ds_map_destroy(control_skins);
	}

	/// @function apply_skin(_instance)
	static apply_skin = function(_instance) {
		var key = object_get_name(_instance.object_index);
		if (ds_map_exists(control_skins, key)) {
			var skindata = control_skins[?key];
			with(_instance) {
				var upd = viget(self, "on_skin_changed");
				if (upd != undefined) {
					upd(skindata);
				} else {
					if (vsget(skindata, "sprite_index") != undefined && sprite_index != -1) {
						replace_sprite(skindata.sprite_index);
					}
				}
			}
		}
	}

}