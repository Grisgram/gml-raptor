/// @description word_wrap and sprite remove

__original_dim = new SpriteDim(sprite_index);

event_inherited();

if (remove_sprite_at_runtime) {
	var w = (startup_width  >= 0 ? startup_width  : sprite_width);
	var h = (startup_height >= 0 ? startup_height : sprite_height);
	sprite_index = spr1pxTrans;
	image_xscale = w;
	image_yscale = h;
	__startup_xscale = w;
	__startup_yscale = h;
}

on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	if (remove_sprite_at_runtime) return;
	integrate_skin_data(_skindata);
	update_startup_coordinates();
}

scribble_add_text_effects = function(scribbletext) {
	if (word_wrap)
		scribbletext.wrap(nine_slice_data.width);
}

__adopt_object_properties = function() {
	if (adopt_object_properties == adopt_properties.alpha ||
		adopt_object_properties == adopt_properties.full) {
		__scribble_text.blend(image_blend, image_alpha);
	}
	if (adopt_object_properties == adopt_properties.full) {
		if (remove_sprite_at_runtime) 
			__scribble_text.transform(
				sprite_width / __original_dim.width, 
				sprite_height / __original_dim.height, 
				image_angle
			);
		else
			__scribble_text.transform(image_xscale, image_yscale, image_angle);
	}
}

