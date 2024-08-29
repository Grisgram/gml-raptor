/*
    Holds the data for one single ui skin.
	Creating a skin is very easy: Just assign the sprite you wish to use to each control
	in the list below.
	
	Activate/Switch skins through the UiSkinManager.
	NOTE: Unlike Themes, does NOT require a room_restart to become active!
*/

function UiSkin(_name = "default") constructor {
	construct(UiSkin);
	ENSURE_THEMES;
	
	name = _name;
	
	asset_skin = ds_map_create();
		
	asset_skin[? "CheckBox"]			= { sprite_index: sprDefaultCheckbox }
	asset_skin[? "InputBox"]			= { sprite_index: sprDefaultInputBox }
	asset_skin[? "Label"]				= { sprite_index: sprDefaultLabel	 }
	asset_skin[? "MouseCursor"]			= { 
 											sprite_index: sprDefaultMouseCursor,
											mouse_cursor_sprite: sprDefaultMouseCursor,
 											mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 										  }
	asset_skin[? "MouseCursorCompanion"]= { sprite_index: spr1pxTrans			}
	asset_skin[? "Panel"]				= { sprite_index: spr1pxTrans			}
	asset_skin[? "RadioButton"]			= { sprite_index: sprDefaultRadioButton	}
	asset_skin[? "Slider"]				= { 
											sprite_index: sprDefaultSliderRailH,
											rail_sprite_horizontal: sprDefaultSliderRailH,
											rail_sprite_vertical: sprDefaultSliderRailV,
											knob_sprite: sprDefaultSliderKnob
										  }
	asset_skin[? "Scrollbar"]			= { 
											sprite_index: sprDefaultScrollbarRailH,
											rail_sprite_horizontal: sprDefaultScrollbarRailH,
											rail_sprite_vertical: sprDefaultScrollbarRailV,
											knob_sprite: sprDefaultScrollbarKnob
										  }
	asset_skin[? "TextButton"]			= { sprite_index: sprDefaultButton	}
	asset_skin[? "ImageButton"]			= { sprite_index: sprDefaultButton	}
	asset_skin[? "Tooltip"]				= { sprite_index: sprDefaultTooltip	}
	asset_skin[? "Window"]				= { 
											sprite_index: sprDefaultWindow,
											window_x_button_object: WindowXButton,
											titlebar_height: 34
										  }
	asset_skin[? "WindowXButton"]		= { sprite_index: sprDefaultXButton	}
	asset_skin[? "MessageBoxWindow"]	= { 
											sprite_index: sprDefaultWindow,
											window_x_button_object: MessageBoxXButton,
											titlebar_height: 34
										  }
	asset_skin[? "MessageBoxXButton"]	= { sprite_index: sprDefaultXButton	}
	
	/// @func delete_map()
	static delete_map = function() {
		ds_map_destroy(asset_skin);
	}

	/// @func apply_skin(_instance)
	static apply_skin = function(_instance) {
		var key = object_get_name(_instance.object_index);
		if (ds_map_exists(asset_skin, key)) {
			var skindata = asset_skin[?key];
			with(_instance) {
				var upd = vsget(self, "on_skin_changed");
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

	/// @func inherit_skin(_skin_name)
	/// @desc Copy all values of the specified skin to the current skin
	static inherit_skin = function(_skin_name) {
		var src = UI_SKINS.get_skin(_skin_name);
		if (src != undefined) {
			var names = ds_map_keys_to_array(src.asset_skin);
			for (var i = 0, len = array_length(names); i < len; i++) {
				var key = names[@i];
				asset_skin[?key] = src.asset_skin[?key];
			}
		} else
			elog($"** ERROR ** UiSkin could not inherit skin '{_skin_name}' into '{name}' (SKIN-NOT-FOUND)");
	}

}