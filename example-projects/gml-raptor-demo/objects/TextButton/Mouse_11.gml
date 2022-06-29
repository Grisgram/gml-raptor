/// @description set default_image_index

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

event_inherited();
__set_default_image();