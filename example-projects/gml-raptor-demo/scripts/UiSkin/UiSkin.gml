/*
    Holds the data for one single ui skin.
	Creating a skin is very easy: Just assign the sprite you wish to use to each control
	in the list below.
	
	Activate/Switch skins through the UiSkinManager.
	NOTE: Same as with Themes, requires a room_restart to become active, so the best 
*/

function UiSkin(_name = "default") constructor {
	construct("UiSkin");

	name = _name;
	
	control_skins = ds_map_create();
		
	control_skins[$ "CheckBox"]				= sprDefaultCheckbox;
	control_skins[$ "ImageButton"]			= sprDefaultButton;
	control_skins[$ "InputBox"]				= sprDefaultInputBox;
	control_skins[$ "Label"]				= sprDefaultLabel;
	control_skins[$ "MouseCursor"]			= sprDefaultMouseCursor;
	control_skins[$ "MouseCursor_Sizing"]	= sprDefaultMouseCursorSizing;
	control_skins[$ "MouseCursorCompanion"]	= spr1pxTrans;
	control_skins[$ "Panel"]				= spr1pxTrans;
	control_skins[$ "RadioButton"]			= sprDefaultRadioButton;
	control_skins[$ "Slider_Rail"]			= sprDefaultSliderRail;
	control_skins[$ "Slider_Knob"]			= sprDefaultSliderKnob;
	control_skins[$ "TextButton"]			= sprDefaultButton;
	control_skins[$ "Tooltip"]				= sprDefaultTooltip;
	control_skins[$ "Window"]				= sprDefaultWindow;
	control_skins[$ "WindowXButton"]		= sprDefaultXButton;
	control_skins[$ "MessageBoxWindow"]		= sprDefaultWindow;
	control_skins[$ "MessageBoxXButton"]	= sprDefaultXButton;
//object_set_sprite
}