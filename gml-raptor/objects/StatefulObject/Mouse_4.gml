/// @description state ev:left_pressed
if (protect_ui_events) GUI_EVENT_MOUSE;

if (__shall_forward_mouse_event("ev:left_pressed"))
	states.set_state("ev:left_pressed");