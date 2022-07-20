/// @description enemy_count--


GLOBALDATA.enemy_count--;
// if the player manages to eat the last enemy, immediately spawn a new one
if (game_active && GLOBALDATA.enemy_count == 0)
	SPAWNER.spawn_enemy();

// Inherit the parent event
event_inherited();
	
