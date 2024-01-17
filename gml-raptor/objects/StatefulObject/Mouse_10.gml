/// @description state ev:mouse_enter
if (protect_ui_events) GUI_EVENT;

if (__shall_forward_mouse_event("ev:mouse_enter")) {
	mouse_is_over = true;
	states.set_state("ev:mouse_enter");
}
