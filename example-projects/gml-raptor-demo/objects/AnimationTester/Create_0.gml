/// @description event

// Inherit the parent event
event_inherited();

move_anim = undefined;
rotate_anim = undefined;

stop_rotating = function() {
	if (rotate_anim != undefined)
		with(rotate_anim) abort();
	
	image_angle = 0;	
}

start_rotating = function() {
	stop_rotating();
	rotate_anim = animation_run(self, 0, 120, acLinearRotate, -1)
		.set_rotation_distance(-360);
}

start_running = function() {
	if (move_anim != undefined) 
		with(move_anim) abort();
	
	x = 128;
	var xdist = VIEW_WIDTH - sprite_width - 128;
	move_anim = animation_run(self, 0, 600, acLinearMove)
		.set_move_target(xdist, y);
}