/// @description close if outside
event_inherited();

GUI_EVENT_UNTARGETTED;

// local event triggers before global event
if (!mouse_is_over && is_open)
	close_list();
