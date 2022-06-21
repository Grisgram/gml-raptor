/// @description mouse_is_over=true

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

log(MY_NAME + ": onMouseEnter");
mouse_is_over = true;
force_redraw();

