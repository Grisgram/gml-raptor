/// @description suppress parent event if dragging

if (!gui_mouse.event_redirection_active) exit;

if (!__in_drag_mode && !__in_size_mode) {
	__size_direction = 0;
	__set_sizing_cursor();
	event_inherited();
}

