/// @description state ev:right_released
if (protect_ui_events) GUI_EVENT;

if (__shall_forward_mouse_event("ev:right_released"))
	states.set_state("ev:right_released");
