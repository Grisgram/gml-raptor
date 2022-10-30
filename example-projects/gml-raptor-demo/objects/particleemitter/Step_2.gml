/// @description emitter follow object

if (follow_instance != undefined && instance_exists(follow_instance)) {
	if (__follow_offset != undefined) {
		x = follow_instance.x + __follow_offset.x * follow_instance.image_xscale;
		y = follow_instance.y + __follow_offset.y * follow_instance.image_yscale;
		if (x != xprevious || y != yprevious) {
			var ps = __get_partsys();		
			ps.emitter_move_range_to(emitter_name, x, y);
			var rmin = ps.emitter_get_range_min(emitter_name);
			var rmax = ps.emitter_get_range_max(emitter_name);
			var distx = rmax.x - rmin.x;
			var disty = rmax.y - rmin.y;
			rmax.x = rmin.x + (distx * follow_instance.image_xscale);
			rmax.y = rmin.y + (disty * follow_instance.image_yscale);
		}
	} else {
		__follow_offset = new Coord2(
			(x - follow_instance.x) / follow_instance.image_xscale, 
			(y - follow_instance.y) / follow_instance.image_yscale);
	}
}
