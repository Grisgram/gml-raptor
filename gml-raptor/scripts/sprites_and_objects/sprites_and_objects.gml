/*
    Helper functions for sprites and objects
*/

/// @function		instance_create(xp, yp, layer_name_or_depth, object, struct = undefined)
/// @description	Convenience function to avoid that nasty switching between 
///					instance_create_layer and instance_create_depth.
///					Should've been always like that... supply a string to create the instance
///					on a named layer or supply an integer to create it on a specified depth
function instance_create(xp, yp, layer_name_or_depth, object, struct = undefined) {
	if (struct == undefined)
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object) :
			instance_create_depth(xp, yp, layer_name_or_depth, object);
	else
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object, struct) :
			instance_create_depth(xp, yp, layer_name_or_depth, object, struct);
}

/// @function		scale_sprite_to(target_width, target_height)
/// @description	Scale an instances' sprite so that it has the desired dimensions.
function scale_sprite_to(target_width, target_height) {
	var w1 = sprite_get_width(sprite_index);
	var h1 = sprite_get_height(sprite_index);
	image_xscale = target_width / w1;
	image_yscale = target_height / h1;
}

/// @function		replace_sprite(on_object, replace_with, keep_size = true, keep_location = true)
/// @description	Replaces the current sprite with the specified one.
///					The method checks if "replace_with" is undefined or noone,
///					so you don't need to check - just call it.
///					It also takes care about the alignment and scaling by default
///					but this behavior can be turned off through the parameters.
/// @param {instance} on_object			The object to have the sprite changed
/// @param {sprite asset} replace_with	The asset to set as the sprite
/// @param {bool=true}	keep_size		if true, image scale will be calculated so the object has
///										has the same size as it had with the previous sprite
/// @param {bool=true}	keep_location	if true, x/y will be calculated based on the new sprite's
///										alignment, so the object has the same location as it had 
///										with the previous sprite
function replace_sprite(on_object, replace_with, keep_size = true, keep_location = true) {
	if (replace_with != noone && replace_with != undefined) {
		with (on_object) {
			if (sprite_index == -1) {
				sprite_index = replace_with;
				return;
			}
		
			var sw = sprite_width;
			var sh = sprite_height;
			if (keep_location) {
				x -= sprite_xoffset;
				y -= sprite_yoffset;
			}
			sprite_index = replace_with;
			if (keep_size) {
				image_xscale = sw / sprite_get_width(replace_with);
				image_yscale = sh / sprite_get_height(replace_with);
			}
			if (keep_location) {
				x += sprite_xoffset;
				y += sprite_yoffset;
			}
		}
	}
}

/// @function sprite_to_canvas(_sprite, _frame = -1, _bordersize = 0)
/// @description	Clones a sprite asset (either one single frame or all frames) into a canvas surface.
///					The bordersize tells, how many pixels around the sprite shall be transparent (for shaders, etc)
/// @returns		A new CanvasSprite object holding the sprite, frame sizes, animation speed, etc
function sprite_to_canvas(_sprite, _frame = -1, _bordersize = 0) {
	var __double_border		= 2 * _bordersize;
	var __subimage_count	= _frame == -1 ? sprite_get_number(_sprite) : 1;
	var __subimage_width	= sprite_get_width(_sprite) + __double_border;
	var __xoffset			= sprite_get_xoffset(_sprite);
	var __yoffset			= sprite_get_yoffset(_sprite);

	var canvas = new Canvas(__subimage_width * __subimage_count, sprite_get_height(_sprite) + __double_border);
	
	canvas.Start();
	
	var f = max(0, _frame); repeat(__subimage_count) {
		draw_sprite(_sprite, f, f * __subimage_width + __xoffset + _bordersize, __yoffset + _bordersize);
		f++;
	}
	
	canvas.Finish();
	
	var spd				= sprite_get_speed(_sprite);
	var spt				= sprite_get_speed_type(_sprite);
	var animation_fps	= spt == spritespeed_framespersecond ? spd : spd * game_get_speed(gamespeed_fps);
		
	return new CanvasSprite(canvas, __subimage_count, animation_fps, __xoffset, __yoffset);
}

/// @function		CanvasSprite(_canvas, _image_count, _fps, _xoffset, _yoffset)
/// @description	Holds render data for a cloned sprite (sprite->Canvas)
function CanvasSprite(_canvas, _image_count, _fps, _xoffset, _yoffset) constructor {
	canvas			= _canvas;
	image_count		= _image_count;
	animation_fps	= _fps;
	image_height	= canvas.GetHeight();
	image_width		= floor(canvas.GetWidth() / image_count);
	subimages		= []; // Holds the X of each subimage in the canvas (y is always 0 -- full height)
	xoffset			= _xoffset;
	yoffset			= _yoffset;

	sub_idx			= 0;
	sub_idx_prev	= 0;
	time			= 0;
	time_step		= 1000000 / animation_fps;

	var xp = 0; repeat(image_count) {
		array_push(subimages, xp);
		xp += image_width;
	}

	/// @function		draw_frame(frame, xp, yp)
	/// @description	Draws the current frame at the specified position
	static draw_frame = function(frame, xp, yp) {
		canvas.DrawPart(subimages[@ frame], 0, image_width, image_height, xp - xoffset, yp - yoffset);
	}

	/// @function		get_image_index = function(_elapsed, _image_speed)
	/// @description	Should be called every STEP to ensure continuous correct animation
	///					when you draw this sprite manually.
	///					Example (STEP event): 
	///					image_index = my_canvas_sprite.get_image_index(delta_time, image_speed);
	static get_image_index = function(_elapsed, _image_speed) {
		if (image_count == 1) return 0;

		time += (_elapsed * _image_speed);
		sub_idx_prev = sub_idx;
		sub_idx = floor(time / time_step) % image_count;

		if (sub_idx < sub_idx_prev)
			time = time % time_step;
		
		return sub_idx;
	}
		
	/// @function		free()
	/// @description	Release the underlying canvas
	static free = function() {
		canvas.Free();
	}
}