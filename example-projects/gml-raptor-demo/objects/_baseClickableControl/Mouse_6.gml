/// @description log event

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

log(MY_NAME + ": onMiddleDown");
await_click = true;