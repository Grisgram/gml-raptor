/// @description perform drag/size change

event_inherited();
if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

if (__in_drag_mode) {
	x += GUI_MOUSE_DELTA_X;
	y += GUI_MOUSE_DELTA_Y;
} else if (__in_size_mode) {
	__do_sizing();
}

if (mouse_is_over && window_is_sizable) {
	__find_sizing_area();
}
