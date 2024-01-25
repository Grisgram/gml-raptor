/// @description event
event_inherited();

animation_run(self, 0, 180, acBouncyChuck_1)
	.set_move_distance(300, 200)
	.set_rotation_distance(-1080)
	.followed_by(0, 60, acBouncyChuck_2)
		.set_move_distance(-300, -200)
		.set_rotation_distance(-180)
		.loop_to_first();

burst_steam = function() {
	steamBurster.burst();
	run_delayed(self, 235, function() { burst_steam(); });
}

run_delayed(self, 175, function() {
	burst_steam();
});