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

