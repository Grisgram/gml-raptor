/// @description hotkey watcher
event_inherited();

var ks = keyboard_to_string();

if (is_null(ks) || (hotkey_only_when_topmost && !is_topmost_control(x,y))) exit;

check_for_hotkey(ks);
