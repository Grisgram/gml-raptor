/// @description object debug frames

if (__ACTIVE_TRANSITION != undefined) {
	with (__ACTIVE_TRANSITION) {
		if (__ACTIVE_TRANSITION_STEP == 0) out_draw(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_draw();
	}
}

if (!global.__debug_shown) exit;

if (DEBUG_SHOW_OBJECT_FRAMES) {
	draw_set_color(c_green);
	var trans = new Coord2();
	for (var i = 0; i < instance_count; i++;) {
	    with (instance_id[i]) {
		
			if (!visible || sprite_index < 0)
				continue;

			draw_set_color(vsget(self, "__raptor_debug_frame_color", c_green));

			if (vsget(self, "draw_on_gui", false)) {
				translate_gui_to_world(x,y,trans);
				draw_rectangle(
					trans.x - sprite_xoffset, 
					trans.y - sprite_yoffset,			
					trans.x - sprite_xoffset + sprite_width - 1, 
					trans.y - sprite_yoffset + sprite_height - 1,
					true);
			} else {			
				draw_rectangle(
					x - sprite_xoffset, 
					y - sprite_yoffset,			
					x - sprite_xoffset + sprite_width - 1, 
					y - sprite_yoffset + sprite_height - 1,
					true);
			}
		}
	}
	draw_set_color(c_white);
}
