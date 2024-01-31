/// @description align to my coordinates

if (variable_global_exists("__room_particle_system") && !string_is_empty(__my_emitter)) {
	var ps = __get_partsys();
	ps.emitter_move_range_to(__my_emitter, x, y);
}

if (stream_on_create) {
	if (stream_start_delay > 0 && DEBUG_LOG_PARTICLES)
		log($"{MY_NAME}: Will start streaming in {stream_start_delay} frames");
	run_delayed(self, stream_start_delay, function() { stream(); });
}
