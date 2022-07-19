/// @description debug_mode & GAMECONTROLLER

// Those macros define all situations that can lead to an invisible element on screen
#macro __LAYER_OR_OBJECT_HIDDEN	(!visible || (layer_get_name(layer) != -1 && !layer_get_visible(layer)))
#macro __HIDDEN_BEHIND_POPUP	(GUI_POPUP_VISIBLE && !string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP))
#macro __GUI_MOUSE_EVENT_LOCK	(variable_instance_exists(self, "draw_on_gui") && draw_on_gui && !gui_mouse.event_redirection_active)

// All controls skip their events, if this is true
#macro __SKIP_CONTROL_EVENT		(__GUI_MOUSE_EVENT_LOCK || __LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP)

#macro SECONDS_TO_FRAMES		* room_speed
#macro FRAMES_TO_SECONDS		/ room_speed

#macro MY_NAME object_get_name(object_index) + "(" + string(real(id)) + ")"

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
GAMECONTROLLER = self;
