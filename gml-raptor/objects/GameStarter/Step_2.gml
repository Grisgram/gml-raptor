if (!wait_for_async_tasks && !trampoline_done) {
	trampoline_done = true;
	log("GameStarter trampoline to next room.");
	pool_clear_all();
	if (fade_in_frames_first_room != 0) {
		var rc = instance_create_layer(0,0,layer,RoomController);
		rc.transit(new FadeTransition(goto_room_after_init,0,fade_in_frames_first_room));
	} else
		room_goto(goto_room_after_init);
}
