/// @description mouse_is_over=false

if (__SKIP_CONTROL_EVENT) exit;

log(MY_NAME + ": onMouseLeave");
mouse_is_over = false;
force_redraw();

