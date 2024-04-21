/// @description close if outside
event_inherited();

GUI_EVENT_UNTARGETTED;

// local event triggers before global event
if (is_open && !__mouse_is_over_me_or_panel())
	close_list();
