/// @description mouse_is_over=true

if (__SKIP_CONTROL_EVENT) exit;

log(MY_NAME + ": onMouseEnter");
mouse_is_over = true;
force_redraw();

