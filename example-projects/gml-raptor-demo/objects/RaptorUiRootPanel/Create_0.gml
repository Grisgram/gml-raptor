/// @description event
event_inherited();
depth = DEPTH_BOTTOM_MOST;

/// @function align_to_gui_layer()
align_to_gui_layer = function() {
	ilog($"{MY_NAME} aligned to gui size");
	x = 0;
	y = 0;
	set_client_area(UI_VIEW_WIDTH, UI_VIEW_HEIGHT);
	control_tree.layout();
}

__draw_self = function() {
	__draw_instance(__force_redraw);
}

__draw_instance = function(_force = false) {
	update_client_area();

	if (__first_draw || _force)
		control_tree.layout();

	control_tree.draw_children();
	__first_draw = false;
	__force_redraw = false;
}
