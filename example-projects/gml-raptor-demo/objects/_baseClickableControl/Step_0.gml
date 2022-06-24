/// @description align to view

event_inherited();
if (HIDDEN_BEHIND_POPUP) exit;

click_event_finished = false;
if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();
