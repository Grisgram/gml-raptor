/// @description log event

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

log(MY_NAME + ": onLeftDown");
await_click = true;