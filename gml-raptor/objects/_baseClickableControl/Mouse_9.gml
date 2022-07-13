/// @description invoke on_middle_click

if (__SKIP_CONTROL_EVENT || click_event_finished || !await_click) exit;

log(MY_NAME + ": onMiddleClick");
await_click = false;
if (on_middle_click != undefined) {
	__deactivate_tooltip();
	on_middle_click(self);
	click_event_finished = true;
}
