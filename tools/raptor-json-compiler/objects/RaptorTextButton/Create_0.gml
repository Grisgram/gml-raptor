/// @desc set image_index_default

event_inherited();

__set_default_image = function() {
	if (sprite_index != -1 && image_number >= image_index_default)
		image_index = image_index_default;
}

__set_over_image = function() {
	if (sprite_index != -1 && image_number >= image_index_mouse_over)
		image_index = image_index_mouse_over;
}

__set_down_image = function() {
	if (sprite_index != -1 && image_number >= image_index_mouse_down)
		image_index = image_index_mouse_down;
}

__set_default_image();

on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	integrate_skin_data(_skindata);
	animated_text_color = text_color;
	animated_draw_color = draw_color;
	set_startup_size();
	__set_default_image();
	update_startup_coordinates();
	force_redraw();
}
