/*
    Use the Canvas library to turn a sprite into a surface by maintaining its animation settings.
*/

/// @function sprite_to_canvas(_sprite, _frame = -1, _bordersize = 0)
/// @description	Clones a sprite asset (either one single frame or all frames) into a canvas surface.
///					The bordersize tells, how many pixels around the sprite shall be transparent (for shaders, etc)
/// @returns		A new CanvasSprite object holding the sprite, frame sizes, animation speed, etc
function sprite_to_canvas(_sprite, _frame = -1, _bordersize = 0) {
	_bordersize += 2; // 1 pixel on each side as "reserve" to avoid low-alpha pre-rendering overlaps
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
		
	return new CanvasSprite(canvas, __subimage_count, animation_fps, __xoffset, __yoffset, _bordersize);
}

/// @function		CanvasSprite(_canvas, _image_count, _fps, _xoffset, _yoffset, _bordersize = 0)
/// @description	Holds render data for a cloned sprite (sprite->Canvas)
function CanvasSprite(_canvas, _image_count, _fps, _xoffset, _yoffset, _bordersize = 0) constructor {
	canvas			= _canvas;
	image_count		= _image_count;
	animation_fps	= _fps;
	image_height	= canvas.GetHeight();
	image_width		= floor(canvas.GetWidth() / image_count);
	subimages		= []; // Holds the X of each subimage in the canvas (y is always 0 -- full height)
	xoffset			= _xoffset;
	yoffset			= _yoffset;
	bordersize		= _bordersize;

	sub_idx			= 0;
	sub_idx_prev	= 0;
	time			= 0;
	time_step		= 1000000 / animation_fps;

	__matrix		= undefined;

	var xp = 0; repeat(image_count) {
		array_push(subimages, xp);
		xp += image_width;
	}

	/// @function		draw_frame(frame, xp, yp)
	/// @description	Draws the current frame at the specified position
	static draw_frame = function(frame, xp, yp) {
		canvas.DrawPart(subimages[@ frame], 0, image_width, image_height, xp - xoffset - bordersize, yp - yoffset - bordersize);
	}

	/// @function		draw_frame_ext(frame, xp, yp, draw_depth, xscale, yscale, rot, col, alpha)
	static draw_frame_ext = function(frame, xp, yp, draw_depth, xscale, yscale, rot, col, alpha) {
		__matrix = matrix_build(xp, yp, draw_depth, 0, 0, rot, xscale, yscale, 1);
		matrix_set(matrix_world, __matrix);
		canvas.DrawGeneral(subimages[@ frame], 0, image_width, image_height, -xoffset - bordersize, -yoffset - bordersize, 1, 1, 0, col, col, col, col, alpha);
		matrix_set(matrix_world, matrix_build_identity());
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