/// @description debug_mode & GAMECONTROLLER
#macro HIDDEN_BEHIND_POPUP		(!visible || (GUI_POPUP_VISIBLE && !string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP)))

#macro SECONDS_TO_FRAMES		* room_speed
#macro FRAMES_TO_SECONDS		/ room_speed

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
GAMECONTROLLER = self;


