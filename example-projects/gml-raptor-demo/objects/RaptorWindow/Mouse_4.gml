/// @description start drag/resize (if movable/sizable)

if (!gui_mouse.event_redirection_active || __LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (window_is_movable && mouse_is_over && __drag_rect.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {
	vlog($"Window drag started.");
	__in_drag_mode = true;
}
