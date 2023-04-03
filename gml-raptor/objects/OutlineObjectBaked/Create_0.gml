/// @description bake on first draw
event_inherited();
canvas = undefined;

__free = function() {
	if (canvas != undefined)
		canvas.free();
}

/// @function bake()
bake = function() {
	if (canvas != undefined) canvas.free();
	log("Pre-Baking sprite '{0}' with {1} frames", sprite_get_name(sprite_index), image_number);
	var begintime = current_time;
	var shader				= shd_outline;
	var u_texel				= shader_get_uniform(shader, "u_vTexel");
	var u_outline_color		= shader_get_uniform(shader, "u_vOutlineColour");
	var u_thickness			= shader_get_uniform(shader, "u_vThickness");

	canvas = sprite_to_canvas(sprite_index, -1, outline_strength + TEXTURE_PAGE_BORDER_SIZE);
	// now bake it with the outliner
	var target = new Canvas(canvas.canvas.GetWidth(), canvas.canvas.GetHeight(), true);
	target.Start();

	shader_set(shader);
	var _texture = canvas.canvas.GetTexture();
	texture_set_stage(shader_get_sampler_index(shader, "u_sSpriteSurface"), _texture);
	shader_set_uniform_f(u_texel		, texture_get_texel_width(_texture), texture_get_texel_height(_texture));
	shader_set_uniform_f(u_outline_color, outliner.outline_color, outliner.outline_alpha); //colour, alpha
	shader_set_uniform_f(u_thickness	, outliner.outline_strength, outliner.alpha_fading ? 1 : 0); // thickness x, y

	draw_surface(canvas.canvas.GetSurfaceID(),outliner.outline_strength,outliner.outline_strength);

	shader_reset();
	target.Finish();			
	
	// Free the original canvas...
	canvas.canvas.Free();
	// ...and inject the pre-baked
	canvas.canvas = target;
	log("Pre-Baking took {0}ms", current_time - begintime);
}

__draw = function() {
	if (canvas == undefined) bake();
	image_index = canvas.get_image_index(delta_time, image_speed);
	if (outline_always || (outline_on_mouse_over && mouse_is_over))
		canvas.draw_frame(image_index, x - outline_strength - TEXTURE_PAGE_BORDER_SIZE, y - outline_strength - TEXTURE_PAGE_BORDER_SIZE);
	else
		draw_self();
}

if (sprite_index != -1) bake();