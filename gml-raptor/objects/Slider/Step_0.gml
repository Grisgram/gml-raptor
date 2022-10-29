/// @description check coordinates (GUI_EVENT)
event_inherited();

if (__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (MOUSE_HAS_MOVED && draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

check_mouse_over_knob();

if ((__knob_grabbed || mouse_is_over || __mouse_over_knob)) {
	if (mouse_check_button(mb_left)) {
		set_value(floor(
			(xcheck - (x - sprite_xoffset + nine_slice_data.left)) / nine_slice_data.width * 100
		));
	} else
		__knob_grabbed = false;
}
