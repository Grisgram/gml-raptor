/// @description mouse_is_over=false

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

log(MY_NAME + ": onMouseLeave");
mouse_is_over = false;
force_redraw();

