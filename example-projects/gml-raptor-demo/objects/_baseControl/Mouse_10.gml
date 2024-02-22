/// @description mouse_is_over=true

GUI_EVENT_MOUSE;

if (!mouse_is_over && !__mouse_events_locked) {
	vlog($"{MY_NAME}: onMouseEnter");
	mouse_is_over = true;
	force_redraw(false);
}
