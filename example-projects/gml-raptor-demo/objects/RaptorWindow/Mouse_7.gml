/// @description stop drag/resize (if movable/sizable)

if (!gui_mouse.event_redirection_active) exit;

if (__in_drag_mode) {
	vlog($"Window drag stopped.");
	__in_drag_mode = false;
}

if (__in_size_mode) {
	vlog($"Window resize stopped.");
	__in_size_mode = false;
}