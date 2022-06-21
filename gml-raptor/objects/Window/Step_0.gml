/// @description perform drag/size change

event_inherited();
if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

if (__in_drag_mode) {
	x += GUI_MOUSE_DELTA_X;
	y += GUI_MOUSE_DELTA_Y;
}