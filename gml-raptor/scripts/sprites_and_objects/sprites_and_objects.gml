/*
    Helper functions for sprites and objects
*/

/// @function		instance_create(xp, yp, layer_name_or_depth, object, struct = undefined)
/// @description	Convenience function to avoid that nasty switching between 
///					instance_create_layer and instance_create_depth.
///					Should've been always like that... supply a string to create the instance
///					on a named layer or supply an integer to create it on a specified depth
function instance_create(xp, yp, layer_name_or_depth, object, struct = undefined) {
	layer_name_or_depth = if_null(layer_name_or_depth, 0);
	if (struct == undefined)
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object) :
			instance_create_depth(xp, yp, layer_name_or_depth, object);
	else
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object, struct) :
			instance_create_depth(xp, yp, layer_name_or_depth, object, struct);
}

/// @function		instance_clone(_instance = self, layer_name_or_depth = undefined, struct = undefined)
/// @description	Clones an instance and returns the clone.
///					"Cloning" for this function means:
///					* A new instance of the same type is created at the same position and layer/depth
///					* The Create event will run normally on the clone
///					* "green" variables (x,y,scale,rotation,blend,alpha,...) are copied to the clone
///					* All other variable values are *not* copied
function instance_clone(_instance = self, layer_name_or_depth = undefined, struct = undefined) {
	var rv;
	with (_instance) {
		var myname = object_get_name(object_index);
		var idx = asset_get_index(myname);
		rv = instance_create(x, y, layer_name_or_depth ?? (layer != -1 ? layer_get_name(layer) : depth), idx, struct);
		rv.sprite_index = sprite_index;
		rv.image_alpha  = image_alpha;
		rv.image_angle  = image_angle;
		rv.image_blend  = image_blend;
		rv.image_index  = image_index;
		rv.image_speed  = image_speed;
		rv.image_xscale = image_xscale;
		rv.image_yscale = image_yscale;
		rv.direction	= direction;
		rv.speed		= speed;
	}
	return rv;
}

/// @function		is_object_instance(_inst)
/// @description	Checks whether a variable holds a living (not deactivated) object instance
function is_object_instance(_inst) {
	return	!is_null(_inst) && 
			!is_string(_inst) &&
			typeof(_inst) == "ref" &&
			(is_struct(_inst) || instance_exists(_inst)) &&
			vsget(_inst, "id") && 
			vsget(_inst, "object_index") && 
			!is_null(object_get_name(vsget(_inst, "object_index")));
}
	
/// @function		scale_sprite_to(target_width, target_height)
/// @description	Scale an instances' sprite so that it has the desired dimensions.
function scale_sprite_to(target_width, target_height) {
	var w1 = sprite_get_width(sprite_index);
	var h1 = sprite_get_height(sprite_index);
	image_xscale = target_width / w1;
	image_yscale = target_height / h1;
}

/// @function is_mouse_over(_instance)
/// @description	Checks whether the current mouse position in the world (_is_gui = false) or
///					in the GUI coordinate space (_is_gui = true) is within the bounds of _instance
///					_is_gui defaults to false, because all controls have their "mouse_is_over" anyway
///					and in normal situations you want to know whether the mouse touches a specific
///					game object, not a control
function is_mouse_over(_instance, _is_gui = false) {
	var xcheck = _is_gui ? GUI_MOUSE_X : MOUSE_X;
	var ycheck = _is_gui ? GUI_MOUSE_Y : MOUSE_Y;
	return position_meeting(xcheck, ycheck, _instance);
}

/// @function		replace_sprite(replace_with, target_width = -1, target_height = -1, keep_empty = true, keep_size = true, keep_location = true)
/// @description	Replaces the current sprite with the specified one.
///					The method checks if "replace_with" is undefined or noone,
///					so you don't need to check - just call it.
///					It also takes care about the alignment and scaling by default
///					but this behavior can be turned off through the parameters.
/// @param {sprite_asset} replace_with	The asset to set as the sprite
/// @param {real=-1}	target_width	If set, force a new width after replacing
/// @param {real=-1}	target_height	If set, force a new height after replacing
/// @param {bool=true}	keep_empty		if true, sprite will not be replaced, if current
///										sprite_index == -1
/// @param {bool=true}	keep_size		if true, image scale will be calculated so the object has
///										has the same size as it had with the previous sprite
/// @param {bool=true}	keep_location	if true, x/y will be calculated based on the new sprite's
///										alignment, so the object has the same location as it had 
///										with the previous sprite
function replace_sprite(replace_with, target_width = -1, target_height = -1, 
						keep_empty = true, keep_size = true, keep_location = true) {
							
	if (is_null(replace_with) || (sprite_index == -1 && keep_empty)) {
		sprite_index = -1;
		return;
	}
	
	var sw = 0;
	var sh = 0;
	if (sprite_index != -1) {
		sw = (target_width  >= 0 ? target_width  : sprite_width);
		sh = (target_height >= 0 ? target_height : sprite_height);
	}
		
	if (keep_location) {
		x -= sprite_xoffset;
		y -= sprite_yoffset;
	}
	sprite_index = replace_with;
		
	if (keep_size || target_width  != -1) image_xscale = sw / sprite_get_width(replace_with);
	if (keep_size || target_height != -1) image_yscale = sh / sprite_get_height(replace_with);
			
	if (keep_location) {
		x += sprite_xoffset;
		y += sprite_yoffset;
	}
}

