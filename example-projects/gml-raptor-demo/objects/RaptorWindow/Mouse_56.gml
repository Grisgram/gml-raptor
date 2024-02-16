/// @description stop drag/resize (if movable/sizable)

if (__in_drag_mode) {
	vlog($"Window drag stopped.");
	__in_drag_mode = false;
}

if (__in_size_mode) {
	vlog($"Window resize stopped.");
	__in_size_mode = false;
}
