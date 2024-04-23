/// @description event
event_inherited();

if (__SLIDER_IN_FOCUS == self || mouse_is_over)
	__change_value_with_arrow(wheel_value_change, true);
