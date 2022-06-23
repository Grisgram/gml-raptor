/// @description Docs inside!

/*
	How to use the animated flag object
	
	To assign a new sprite during runtime DO NOT simply set sprite_index = xxx!
	Instead, use the method "assign_sprite"- below because it calculates all the
	required values for rendering.
	
	instance variables
	--------------------------------------------------------------------
	animation_fps		- how many frames shall be calculated?
	intensity			- how many waves are on the flag
	wave_speed			- how fast do the waves move
	wave_height			- how strong are the waves
	vertex_count		- if -1, then default of 10% of sprite width
	render_width		- if -1, then image_xscale as set in room editor
	render_height		- if -1, then image_yscale as set in room editor
	
*/

assign_sprite = function(new_sprite_index, new_image_index = 0) {
	sprite_index = new_sprite_index;
	image_index = new_image_index;
	texture	= sprite_get_texture(sprite_index, image_index);
	width  = sprite_get_width(sprite_index);
	height = sprite_get_height(sprite_index);
	texture_width = texture_get_width(texture);
	texture_height = texture_get_height(texture);
	running_vertices = vertex_count == -1 ? width / 10 : vertex_count;
	scale_x = (render_width != -1 ? render_width / width : image_xscale);
	scale_y = (render_height != -1 ? render_height / height : image_yscale);
}

assign_sprite(sprite_index);
