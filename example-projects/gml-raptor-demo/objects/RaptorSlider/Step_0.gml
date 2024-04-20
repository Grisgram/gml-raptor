/// @description check coordinates (GUI_EVENT_MOUSE)
event_inherited();

GUI_EVENT_UNTARGETTED;

if (draw_on_gui && CTL_MOUSE_HAS_MOVED)
	gui_mouse.check_gui_mouse_clicks();

check_mouse_over_knob();

if (__SLIDER_IN_FOCUS != self) exit;

if (__knob_grabbed || mouse_is_over || __mouse_over_knob) {
	if (mouse_check_button(mb_left)) {
		if (__knob_grabbed || __is_topmost) {
			if (orientation_horizontal) {
				set_value(
					min_value 
					+ round((xcheck - (__knob_dims.width * knob_xscale) / 2 - x - nine_slice_data.left) / __tilesize)
				);
			} else {
				set_value(
					min_value 
					+ round((y + nine_slice_data.top + nine_slice_data.height - ycheck - (__knob_dims.height * knob_yscale) / 2) / __tilesize)
				);
			}
		}
	} else
		__knob_grabbed = false;
}
