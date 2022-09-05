/// @description align to my coordinates

if (variable_global_exists("__room_particle_system")) {
	var ps = __get_partsys();	
	ps.emitter_move_range_to(emitter_name, x, y);
}
