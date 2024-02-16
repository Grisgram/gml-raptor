/// @description suppress parent event if dragging

GUI_EVENT;

if (!__in_drag_mode && !__in_size_mode) {
	event_inherited();
}

