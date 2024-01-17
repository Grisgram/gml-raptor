/// @description state ev:left_released
if (protect_ui_events) GUI_EVENT;

if (__shall_forward_mouse_event("ev:left_released"))
	states.set_state("ev:left_released");
