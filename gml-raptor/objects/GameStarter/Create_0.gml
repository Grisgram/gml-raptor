/// @description 

#macro GAMESTARTER		global._GAMESTARTER
GAMESTARTER				= self;

wait_for_async_tasks = false;
trampoline_done = false;

// Inherit the parent event
event_inherited();

