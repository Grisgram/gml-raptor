/// @description debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
GAMECONTROLLER = self;

#macro BROADCASTER		global.__broadcaster
BROADCASTER = new Sender();
