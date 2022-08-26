/// @description emitter follow object

if (emitter_follow_object && (x != prev_x || y != prev_y)) {
	PARTSYS.emitter_move_range_to(emitter_name, x , y);
	prev_x = x;
	prev_y = y;
}
