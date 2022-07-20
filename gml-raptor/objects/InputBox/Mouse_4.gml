/// @description gain focus & cursor pos

if (__SKIP_CONTROL_EVENT) exit;

event_inherited();
set_focus();
__set_cursor_pos_from_click();

