/// @description gain focus & cursor pos

if ((draw_on_gui && !gui_mouse.event_redirection_active) || HIDDEN_BEHIND_POPUP) exit;

event_inherited();
set_focus();
__set_cursor_pos_from_click();

