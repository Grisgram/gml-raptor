/// @description set default_image_index

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

event_inherited();
if (mouse_is_over) __set_over_image(); else __set_default_image();

