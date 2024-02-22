/// @description state ev:middle_pressed
if (protect_ui_events) GUI_EVENT_MOUSE;

if (__shall_forward_mouse_event("ev:middle_pressed"))
	states.set_state("ev:middle_pressed");
