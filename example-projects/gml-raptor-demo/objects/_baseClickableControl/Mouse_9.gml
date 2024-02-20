/// @description invoke on_middle_click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

perform_middle_click();
