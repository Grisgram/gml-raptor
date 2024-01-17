/// @description state ev:mouse_leave
if (protect_ui_events) GUI_EVENT;

if (__shall_forward_mouse_event("ev:mouse_leave")) {
	states.set_state("ev:mouse_leave");
	mouse_is_over = false;
}
