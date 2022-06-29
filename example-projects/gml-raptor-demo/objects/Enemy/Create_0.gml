/// @description Enemy StateMachine

// Inherit the parent event
event_inherited();

GLOBALDATA.enemy_count++;

// Look (and move) in the direction of the spawner when appearing
image_angle = SPAWNER.image_angle;
direction	= image_angle;
speed		= 1;


