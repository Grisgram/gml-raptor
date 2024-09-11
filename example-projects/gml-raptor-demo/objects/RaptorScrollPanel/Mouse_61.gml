/// @description event
event_inherited();

if ((mouse_drag_mode != mouse_drag.none || vertical_scrollbar) && __mouse_in_content()) 
	__update_scroller(__vscroll, wheel_value_change);
