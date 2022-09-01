/// @description 

// Inherit the parent event
original_offset = undefined;
original_scale = undefined;

// Radio-style buttons behave differently! We need to control this
__auto_change_checked = true;

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
	} else
		unscaled = new SpriteDim(-1);
		
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
}

__set_default_image = function() {
	__image_index = (checked ? image_index_checked : image_index_unchecked);
}

__set_over_image = function() {
	__image_index = (checked ? mouse_over_image_index_checked : mouse_over_image_index_unchecked);
}

__set_down_image = function() {
	__image_index = (checked ? mouse_down_image_index_checked : mouse_down_image_index_unchecked);
}

update_graphics(false);
__set_default_image();

event_inherited();
force_redraw();
