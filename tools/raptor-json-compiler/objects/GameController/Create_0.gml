/// @desc debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
#macro __FAKE_GAMECONTROLLER	if (!variable_global_exists("__game_controller")) GAMECONTROLLER=SnapFromJSON("{\"image_index\":0}");
GAMECONTROLLER = self;

#macro BROADCASTER		global.__broadcaster
BROADCASTER = new Sender();
