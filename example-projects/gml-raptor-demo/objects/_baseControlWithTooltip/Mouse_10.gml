/// @description activate_tooltip

event_inherited();

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;
__activate_tooltip();
