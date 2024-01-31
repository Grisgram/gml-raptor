/// @description invoke on_left_click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

log($"{MY_NAME}: onLeftClick");
await_click = false;
if (double_click_counter < 2)
	play_ui_sound(on_click_sound);
if (on_left_click != undefined) {
	__deactivate_tooltip();
	on_left_click(self);
	click_event_finished = true;
}

if (double_click_counter >= 2) {
	log($"{MY_NAME}: onDoubleClick");
	double_click_counter = 0;
	double_click_waiter = 0;
	if (on_double_click != undefined) {
		__deactivate_tooltip();
		on_double_click(self);
	}
}