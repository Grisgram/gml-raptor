/// @description perform drag/size change

event_inherited();
if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

if (__in_drag_mode) {
	x += CTL_MOUSE_DELTA_X;
	y += CTL_MOUSE_DELTA_Y;
	control_tree.move_children(CTL_MOUSE_DELTA_X, CTL_MOUSE_DELTA_Y);
} else if (__in_size_mode) {
	__do_sizing();
	control_tree.move_children_after_sizing(CTL_MOUSE_DELTA_X, CTL_MOUSE_DELTA_Y);
}

if (mouse_is_over && window_is_sizable) {
	__find_sizing_area();
}
