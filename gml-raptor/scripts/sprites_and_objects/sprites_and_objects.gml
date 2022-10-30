/*
    Helper functions for sprites and objects
*/

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
