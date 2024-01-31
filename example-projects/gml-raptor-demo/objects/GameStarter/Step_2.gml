// spinner rotation and position
if (trampoline_done) exit;

spinner_frame_counter = (spinner_frame_counter + 1) % 48;
spinner_rotation = -45 * floor(spinner_frame_counter / 6);
spinner_x = VIEW_WIDTH - spinner_w - 16;
spinner_y = VIEW_HEIGHT - spinner_h - 16;

if (first_step) {
	first_step = false;
	window_center();
}

if (wait_for_async_tasks && async_wait_timeout > 0) {
	async_wait_counter++;
	if (async_wait_counter >= async_wait_timeout)
		wait_for_async_tasks = false;
	else
		exit;
}

if (!wait_for_async_tasks && !trampoline_done) {
	
	if (async_min_wait_time > 0 && async_wait_counter < async_min_wait_time) {
		draw_spinner = true;
		async_wait_counter++;
		exit;
	}
	
	visible = false; // turn off the draw event to save this now unneccesary funct
	draw_spinner = false;
	trampoline_done = true;
	log($"GameStarter trampoline to next room");
	pool_clear_all();
	if (fade_in_frames_first_room != 0) {
		var rc = instance_create_layer(0,0,layer,RoomController);
		rc.transit(new FadeTransition(goto_room_after_init,0,fade_in_frames_first_room));
	} else
		room_goto(goto_room_after_init);
}
