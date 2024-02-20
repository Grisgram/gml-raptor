/// @description invoke on_right_click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

perform_right_click();
