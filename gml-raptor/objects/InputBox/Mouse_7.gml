/// @description check for double-click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

if (double_click_counter == 2)
	select_word();

// Inherit the parent event
event_inherited();
