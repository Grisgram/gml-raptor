/// @description invoke on_left_click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

log(MY_NAME + ": onLeftClick");
await_click = false;
if (on_left_click != undefined) {
	__deactivate_tooltip();
	on_left_click(self);
	click_event_finished = true;
}
