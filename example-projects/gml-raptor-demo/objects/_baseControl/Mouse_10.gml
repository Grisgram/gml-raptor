/// @description mouse_is_over=true
GUI_EVENT;

if (!mouse_is_over) {
	vlog($"{MY_NAME}: onMouseEnter");
	mouse_is_over = true;
	force_redraw();
}
