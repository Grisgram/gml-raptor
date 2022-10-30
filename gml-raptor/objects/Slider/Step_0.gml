/// @description check coordinates (GUI_EVENT)
event_inherited();

if (__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (MOUSE_HAS_MOVED && draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

check_mouse_over_knob();

if (__SLIDER_IN_FOCUS != self) exit;

if ((__knob_grabbed || mouse_is_over || __mouse_over_knob)) {
	if (mouse_check_button(mb_left)) {
		if (orientation_horizontal) {
			__tilesize = nine_slice_data.width / (max_value - min_value);
			set_value(min_value + round((xcheck - x - nine_slice_data.left) / __tilesize));
		} else {
			__tilesize = nine_slice_data.height / (max_value - min_value);
			set_value(min_value + round((y + nine_slice_data.top + nine_slice_data.bottom - ycheck) / __tilesize));
		}
	} else
		__knob_grabbed = false;
}
