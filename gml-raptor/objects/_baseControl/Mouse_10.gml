/// @description mouse_is_over=true

GUI_EVENT_MOUSE;

if (!mouse_is_over && !__mouse_events_locked) {
	vlog($"{MY_NAME}: onMouseEnter");
	mouse_is_over = true;
	__animate_draw_color(draw_color_mouse_over);
	__animate_text_color(text_color_mouse_over);
	force_redraw(false);
}
