/// @description stop drag/resize (if movable/sizable)

if (!gui_mouse.event_redirection_active) exit;

if (__in_drag_mode) {
	log("Window drag stopped.");
	__in_drag_mode = false;
}
