/// @desc 

var w = (startup_width  >= 0 ? startup_width  : sprite_width);
var h = (startup_height >= 0 ? startup_height : sprite_height);
sprite_index = if_null(sprite_to_use, sprite_index);
scale_sprite_to(w, h);

// Inherit the parent event
event_inherited();

on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	integrate_skin_data(_skindata);
	animated_text_color = text_color;
	animated_draw_color = draw_color;
	replace_sprite(sprite_to_use);
	update_startup_coordinates();
	force_redraw();
}

__apply_autosize_alignment = function() {
}

__apply_post_positioning = function() {
}
