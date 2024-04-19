/// @description check coordinates (GUI_EVENT_MOUSE)
event_inherited();

GUI_EVENT_UNTARGETTED;

if (draw_on_gui && CTL_MOUSE_HAS_MOVED)
	gui_mouse.check_gui_mouse_clicks();

check_mouse_over_knob();

if (__SLIDER_IN_FOCUS != self) exit;

if ((__knob_grabbed || mouse_is_over || __mouse_over_knob)) {
	if (mouse_check_button(mb_left)) {
		if (__knob_grabbed || __is_topmost) {
			if (orientation_horizontal) {
				//__tilesize = nine_slice_data.width / (max_value - min_value + 1);
				set_value(
					min_value 
					+ __knob_dims.center_x
					+ floor((xcheck - __knob_dims.center_x - x - nine_slice_data.left) / __tilesize)
					- __knob_dims.center_x
				);
			} else {
				//__tilesize = nine_slice_data.height / (max_value - min_value + 1);
				set_value(
					min_value 
					- __knob_dims.center_y
					+ floor((y + nine_slice_data.top + nine_slice_data.bottom - ycheck - __knob_dims.center_y) / __tilesize)
					+ __knob_dims.center_y
				);
				//set_value(min_value + floor((y + nine_slice_data.top + nine_slice_data.bottom - ycheck) / __tilesize));
			}
		}
	} else
		__knob_grabbed = false;
}
