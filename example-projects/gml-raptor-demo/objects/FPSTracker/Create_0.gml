/// @description event

// Inherit the parent event
event_inherited();
binder.bind("x", flying_chuck, "x");
total_frames = 0;
total_time = 0;

count_frame = function() {
	total_frames++;
	total_time += delta_time;

	if (total_time > 1000000) {
		text = $"{total_frames} FPS";
		total_frames = 0;
		total_time -= 1000000;
	}
}