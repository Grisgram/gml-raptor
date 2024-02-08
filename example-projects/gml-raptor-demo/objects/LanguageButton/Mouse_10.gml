/// @description set cursor
event_inherited();

if (!visible) exit;

if (MOUSE_CURSOR == undefined)
	window_set_cursor(cr_handpoint);

