/// @description gain focus & cursor pos

if (HIDDEN_BEHIND_POPUP) exit;

event_inherited();
set_focus();
__set_cursor_pos_from_click();

