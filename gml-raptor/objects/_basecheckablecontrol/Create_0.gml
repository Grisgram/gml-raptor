/// @description 

// Inherit the parent event
original_offset = undefined;
original_scale	= undefined;
unscaled		= undefined;

// Radio-style buttons behave differently! We need to control this
__auto_change_checked = true;
__down_draw_offset = undefined;
__up_draw_offset = new Coord2();

set_checked = function(_checked) {
	checked = _checked;
	__set_default_image();
}

update_graphics = function(_force_redraw = true) {
	if (original_scale == undefined)
		original_scale = new Coord2(image_xscale, image_yscale);
	
	if (sprite_index != -1) {
		__sprite_index = sprite_index;
		unscaled = new SpriteDim(sprite_index);
		sprite_index = spr1pxTrans;
		image_xscale = unscaled.width * original_scale.x;
		image_yscale = unscaled.height * original_scale.y;
		__down_draw_offset = new Coord2(
			(sprite_width  - (sprite_width  * 0.9)) / 2,
			(sprite_height - (sprite_height * 0.9)) / 2
		);
	} else {
		unscaled = new SpriteDim(-1);
		__down_draw_offset = new Coord2();
	}
		
	if (original_offset == undefined)
		original_offset = new Coord2(text_xoffset, text_yoffset);
		
	if (draw_checkbox_on_the_left)
		text_xoffset = original_offset.x + unscaled.width + distance_to_text;
	else
		text_xoffset = original_offset.x - unscaled.width - distance_to_text;
	if (_force_redraw)
		force_redraw();
}

__draw_me = function() {
	__draw_self();
	__draw_x = (draw_checkbox_on_the_left ? x : x + sprite_width - unscaled.width);
	draw_sprite_ext(__sprite_index, __image_index, __draw_x, y, original_scale.x, original_scale.y, image_angle, (mouse_is_over ? draw_color_mouse_over : draw_color), image_alpha);
	if (checked)
		draw_sprite_ext(__sprite_index, image_index_checkmark, __draw_x + __draw_offset.x, y + __draw_offset.y, original_scale.x * __check_factor, original_scale.y * __check_factor, image_angle, checkmark_draw_color, image_alpha);
}

__set_default_image = function() {
	__image_index  = image_index_default;
	__check_factor = 1.0;
	__draw_offset  = __up_draw_offset;
}

__set_over_image = function() {
	__image_index  = image_index_mouse_over;
	__check_factor = 1.0;
	__draw_offset  = __up_draw_offset;
}

__set_down_image = function() {
	__image_index  = image_index_mouse_down;
	__check_factor = 0.9;
	__draw_offset  = __down_draw_offset;
}

update_graphics(false);
__set_default_image();

event_inherited();

__apply_autosize_alignment = function(distx, disty) {
	image_xscale = max(__startup_xscale, (max(min_width, __text_width)  + unscaled.width  + distx) / unscaled.width);
	image_yscale = max(__startup_yscale, (max(min_height,__text_height) + unscaled.height + disty) / unscaled.height);
}

__apply_post_positioning = function() {
	if (draw_checkbox_on_the_left) {
		__text_x = x + __text_width + text_xoffset;
		if		(string_contains(scribble_text_align, "[fa_left]"))   __text_x -= __text_width;
		else if	(string_contains(scribble_text_align, "[fa_center]")) __text_x -= __text_width / 2;
	} else {
		__text_x = x - __text_width - distance_to_text;
		if		(string_contains(scribble_text_align, "[fa_center]")) __text_x += __text_width / 2;
		else if (string_contains(scribble_text_align, "[fa_right]" )) __text_x += __text_width;
	}	
}

force_redraw();
