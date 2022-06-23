/// @description object debug frames

if (!global.__DEBUG_SHOWN) exit;

if (DEBUG_SHOW_OBJECT_FRAMES) {
	for (var i = 0; i < instance_count; i++;) {
		draw_set_color(c_green);
	    with (instance_id[i]) {
		
			if (!visible || sprite_index < 0)
				continue;
			
			draw_rectangle(
				x - sprite_xoffset, 
				y - sprite_yoffset,			
				x - sprite_xoffset + sprite_width, 
				y - sprite_yoffset + sprite_height,
				true);

		}
		draw_set_color(c_white);
	}
}

drawDebugInfo();
