/// @description align to my coordinates

if (variable_global_exists("__room_particle_system") && !string_is_empty(__my_emitter)) {
	var ps = __get_partsys();	
	ps.emitter_move_range_to(__my_emitter, x, y);
}
