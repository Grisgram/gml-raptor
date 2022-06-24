/// @description suppress parent event if dragging

if (!gui_mouse.event_redirection_active) exit;

if (!__in_drag_mode)
	event_inherited();

