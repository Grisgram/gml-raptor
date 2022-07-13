/// @description set default_image_index

if (__SKIP_CONTROL_EVENT) exit;

event_inherited();
if (mouse_is_over) __set_over_image(); else __set_default_image();

