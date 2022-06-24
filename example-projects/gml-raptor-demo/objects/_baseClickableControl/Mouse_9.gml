/// @description invoke on_middle_click

if ((draw_on_gui && !gui_mouse.event_redirection_active) || click_event_finished || !await_click || HIDDEN_BEHIND_POPUP) exit;

log(MY_NAME + ": onMiddleClick");
await_click = false;
if (on_middle_click != undefined) {
	__deactivate_tooltip();
	on_middle_click(self);
	click_event_finished = true;
}
