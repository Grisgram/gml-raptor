/// @description word_wrap and sprite remove

event_inherited();

if (remove_sprite_at_runtime) {
	var w = sprite_width;
	var h = sprite_height;
	sprite_index = spr1pxTrans;
	image_xscale = w;
	image_yscale = h;
	__startup_xscale = w;
	__startup_yscale = h;
}

scribble_add_text_effects = function(scribbletext) {
	if (word_wrap)
		scribbletext.wrap(nine_slice_data.width);
}

