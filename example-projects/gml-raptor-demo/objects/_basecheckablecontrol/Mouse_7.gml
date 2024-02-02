/// @description set default_image_index

GUI_EVENT;

if (__auto_change_checked) set_checked(!checked);
event_inherited();
if (mouse_is_over) __set_over_image(); else __set_default_image();

