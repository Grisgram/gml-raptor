/*
		Outline shader drawer
		---------------------
		
		The shader itself is based on the selective-outline-shader by Juju Adams 
		(https://github.com/JujuAdams/selective-outline) and he also helped me tuning this shader.
		
		Use this class to draw any object with an outline effect based on the set parameters.
		See the DemoTank object in the Demo Project of the original repository at 
		https://github.com/Grisgram/gml-outline-shader-drawer
		
		(c)2022 Grisgram aka Haerion@GameMakerKitchen Discord
		Please respect the MIT License for this Library.
*/

/// @function			outline_drawer(_viewport = 0, _outline_color = c_black, _outline_alpha = 1, _outline_strength = 3, _alpha_fading = true)
/// @description				
/// @param {int=0}			_viewport
/// @param {color=c_white}	_outline_color
/// @param {real=1}			_outline_alpha
/// @param {int=3}			_outline_strength
/// @param {bool=true}		_alpha_fading
function outline_drawer(_viewport = 0, _outline_color = c_white, _outline_alpha = 1, _outline_strength = 3, _alpha_fading = true) constructor {
	__outline_surface_1 = -1;
	__outline_surface_2 = -1;

	// html flips the final surface vertically... hell knows, why.
	// so, on html we need to draw it upside down.
	__flip_vertical			= (os_browser != browser_not_a_browser);

	viewport			= _viewport;
	camera				= view_get_camera(_viewport);
	
	shader				= shd_outline;

//	outline_color		= _outline_color;
	outline_color		= make_color_rgb(color_get_red(_outline_color),color_get_green(_outline_color),color_get_blue(_outline_color));
	outline_alpha		= _outline_alpha;
	outline_strength	= _outline_strength;
	alpha_fading		= _alpha_fading;

	static __update_surfaces = function() {
		if (!surface_exists(__outline_surface_1)) __outline_surface_1 = surface_create(1, 1);
		if (!surface_exists(__outline_surface_2)) __outline_surface_2 = surface_create(1, 1);
	}

	static draw_sprite_outline = function(_obj, _index, _x, _y, _xscale = 1, _yscale = 1, _rotation = 0, _sprite_colour = c_white, _sprite_alpha = 1) {
		__update_surfaces();
		var _sprite = _obj.sprite_index;
		var bbox_w = _obj.bbox_right - _obj.bbox_left + 1;
		var bbox_h = _obj.bbox_bottom - _obj.bbox_top + 1;
		
		//Verify the two input surfaces
		if (!surface_exists(__outline_surface_1))
		{
		    show_debug_message("draw_sprite_selective_outline: Surface 1 does not exist!");
		    return false;
		}

		if (!surface_exists(__outline_surface_2))
		{
		    show_debug_message("draw_sprite_selective_outline: Surface 2 does not exist!");
		    return false;
		}

		var _surface_real_w = 2 + 2 * outline_strength + max(_xscale * sprite_get_width(_sprite), bbox_w);
		var _surface_real_h = 2 + 2 * outline_strength + max(_yscale * sprite_get_height(_sprite), bbox_h);

		if ((surface_get_width(__outline_surface_1) < _surface_real_w) || (surface_get_height(__outline_surface_1) < _surface_real_h))
		{
		    surface_resize(__outline_surface_1, _surface_real_w, _surface_real_h);
		}

		if ((surface_get_width(__outline_surface_2) < _surface_real_w) || (surface_get_height(__outline_surface_2) < _surface_real_h))
		{
		    surface_resize(__outline_surface_2, _surface_real_w, _surface_real_h);
		}

		//Find the top-left corner of the sprite's quad, correcting for the sprite's origin
		var _sprite_l = _x - 1 - _xscale*sprite_get_xoffset(_sprite);
		var _sprite_t = _y - 1 - _yscale*sprite_get_yoffset(_sprite);

		//Find the portion of the application surface that we want to borrow
		var _camera_xscale = 1;
		var _camera_yscale = 1;
		var _camera_x      = 0;
		var _camera_y      = 0;

		//Correct for the camera if it's been specified
		if (is_real(camera) && (camera >= 0))
		{
		    _camera_xscale = view_wport[viewport] / camera_get_view_width (camera);
		    _camera_yscale = view_hport[viewport] / camera_get_view_height(camera);
		    _camera_x      = camera_get_view_x(camera);
		    _camera_y      = camera_get_view_y(camera);
		}

		//Figure out what part of the application surface we need to chop out
		var _surface_l = max(0, _camera_xscale*(_obj.bbox_left - outline_strength - _camera_x));
		var _surface_t = max(0, _camera_yscale*(_obj.bbox_top  - outline_strength - _camera_y));
		var _surface_r = _surface_l + _camera_xscale*_surface_real_w;
		var _surface_b = _surface_t + _camera_yscale*_surface_real_h;

		//Draw the sprite to a temporary surface
		//It's possible to avoid using this particular surface if sprites are configured correctly...
		//...but using a surface means you don't need to configure sprites at all
		surface_set_target(__outline_surface_1);
		draw_clear_alpha(c_black, 0.0);

		draw_sprite_ext(_sprite, _index,
						_xscale*sprite_get_xoffset(_sprite) + 2 + outline_strength + _sprite_l - _obj.bbox_left,
						_yscale*sprite_get_yoffset(_sprite) + 2 + outline_strength + _sprite_t - _obj.bbox_top,
		                _xscale, _yscale, _rotation,
		                _sprite_colour, _sprite_alpha);

		surface_reset_target();

		//Now we draw to the second surface using our shader
		//The shader samples the sprite surface, looking for an edge
		//Once it finds an edge, it looks at the application surface
		//If the application surface is dark enough, it draws the outline
		//If the shader cannot find an edge, it'll draw the sprite as normal
		surface_set_target(__outline_surface_2);
		draw_clear_alpha(c_black, 0.0);

		shader_set(shader);
		var _texture = surface_get_texture(__outline_surface_1);
		texture_set_stage(shader_get_sampler_index(shader, "u_sSpriteSurface"), _texture);
		shader_set_uniform_f(shader_get_uniform(shader, "u_vTexel"), texture_get_texel_width(_texture), texture_get_texel_height(_texture));
		shader_set_uniform_f(shader_get_uniform(shader, "u_vOutlineColour"), outline_color, outline_alpha); //colour, alpha
		shader_set_uniform_f(shader_get_uniform(shader, "u_vThickness"), outline_strength, alpha_fading ? 1 : 0); // thickness x, y

		draw_surface_part_ext(application_surface,
			_surface_l, _surface_t,
			_surface_r, _surface_b,
			0, 0,
			1/_camera_xscale, 1/_camera_yscale,
			c_white, 1.0);

		shader_reset();
		surface_reset_target();

		//Draw surface 2
		if (__flip_vertical) {
			// as we increase the surface only when needed but never shrink (for performance)
			// we need the current_dimensions here for correct rendering in html (surface_get_height)
			draw_surface_ext(__outline_surface_2, 
				_obj.bbox_left - outline_strength - 1,
				_obj.bbox_top + surface_get_height(__outline_surface_2) - outline_strength - 1,
				1, -1, 0, c_white, 1);
		} else {
			draw_surface_ext(__outline_surface_2, 
				_obj.bbox_left - outline_strength - 1, 
				_obj.bbox_top  - outline_strength - 1,
				1, 1, 0, c_white, 1);
		}

		return true;

	}
	
	static draw_object_outline = function(object_to_draw = other) {
		with (object_to_draw) {
			if (is_child_of(self, OutlineObject)) {
				other.outline_color		= make_color_rgb(color_get_red(outline_color),color_get_green(outline_color),color_get_blue(outline_color));
				other.outline_alpha		= outline_alpha;
				other.outline_strength	= outline_strength;
				other.alpha_fading		= outline_alpha_fading;
			}
			other.draw_sprite_outline(self, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
		}
	}
	
}


