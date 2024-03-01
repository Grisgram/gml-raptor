/// @description scribblelize text

event_inherited();
click_event_finished = false;
await_click = false;

double_click_counter = 0;
double_click_waiter = 0;

__set_await_click = function(_await) {
	await_click = _await;
	__mouse_text_scale = (_await ? text_scale_mouse_down : 1.0);
}

/// @function check_for_hotkey(_keystring)
check_for_hotkey = function(_keystring) {
	if (!is_null(hotkey_left_click) && hotkey_left_click == _keystring) perform_left_click();
	else if (!is_null(hotkey_right_click) && hotkey_right_click == _keystring) perform_right_click();
	else if (!is_null(hotkey_middle_click) && hotkey_middle_click == _keystring) perform_middle_click();
}

/// @function perform_left_click()
perform_left_click = function() {
	vlog($"{MY_NAME}: onLeftClick");
	__set_await_click(false);
	play_ui_sound(on_click_sound);

	if (on_left_click != undefined) {
		__deactivate_tooltip();
		on_left_click(self);
		click_event_finished = true;
	}
}

/// @function perform_middle_click()
perform_middle_click = function() {
	vlog($"{MY_NAME}: onMiddleClick");
	__set_await_click(false);
	play_ui_sound(on_click_sound);
	
	if (on_middle_click != undefined) {
		__deactivate_tooltip();
		on_middle_click(self);
		click_event_finished = true;
	}
}

/// @function perform_right_click()
perform_right_click = function() {
	vlog($"{MY_NAME}: onRightClick");
	__set_await_click(false);
	play_ui_sound(on_click_sound);
	
	if (on_right_click != undefined) {
		__deactivate_tooltip();
		on_right_click(self);
		click_event_finished = true;
	}
}

/// @function perform_double_click()
perform_double_click = function() {
	vlog($"{MY_NAME}: onDoubleClick");
	__set_await_click(false);
	play_ui_sound(on_click_sound);

	double_click_counter = 0;
	double_click_waiter = 0;
	if (on_double_click != undefined) {
		__deactivate_tooltip();
		on_double_click(self);
	}
}