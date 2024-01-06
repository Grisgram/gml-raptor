/// @description mouse_is_over=false

if (!is_enabled) exit;
log(MY_NAME + ": onMouseLeave");
mouse_is_over = false;
force_redraw();

