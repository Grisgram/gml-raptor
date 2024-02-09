/// @description start drag/resize (if movable/sizable)

if (!gui_mouse.event_redirection_active || __LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (mouse_is_over) {
	if (window_is_movable && __drag_rect.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {
		vlog($"Window drag started");
		__in_drag_mode = true;
		with(RaptorWindow)
			depth = __startup_depth;
		depth = __startup_depth - 1;
	} else if (__size_direction != 0) {
		vlog($"Window resize started");
		__in_size_mode = true;
	}
}
