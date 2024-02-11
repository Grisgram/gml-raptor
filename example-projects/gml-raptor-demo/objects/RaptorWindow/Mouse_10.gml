/// @description suppress parent event if dragging

GUI_EVENT;
//if (!gui_mouse.event_redirection_active) exit;

if (!__in_drag_mode && !__in_size_mode) {
	event_inherited();
}

