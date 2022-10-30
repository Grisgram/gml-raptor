/// @description debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
GAMECONTROLLER = self;

#macro BROADCASTER		global._BROADCASTER
BROADCASTER = new Sender();
