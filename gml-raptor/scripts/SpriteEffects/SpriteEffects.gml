#macro __POOL_EFFECTS		"__sprite_effects_pool"

/// @function					effect_start_scaled_by(sprite, on_layer, xp, yp, _xscale, _yscale, rotation, speed_multiplier, finished_callback)
/// @description				start a pooled effect animation scaled by a factor
/// @param {asset} sprite
/// @param {string} on_layer
/// @param {real} xp optional x-position. if undefined, x of "self" will be used
/// @param {real} yp optional y-position. if undefined, x of "self" will be used
/// @param {real}	_xscale
/// @param {real}	_yscale
/// @param {real=0}	rotation
/// @param {real=1}	speed_multiplier
/// @param {func=undefined}	finished_callback
function effect_start_scaled_by(sprite, on_layer, xp = undefined, yp = undefined, xscale, yscale, rotation = 0, speed_multiplier = 1, finished_callback = undefined) {
	var rv = pool_get_instance(__POOL_EFFECTS, SpriteEffectRunner, on_layer);
	with (rv) {
		__finished_callback = finished_callback;
		layer = layer_get_id(on_layer);
		sprite_index = sprite;
		image_speed = speed_multiplier;
		image_xscale = xscale;
		image_yscale = yscale;
		image_angle = rotation;
		if (xp != undefined) x = xp;
		if (yp != undefined) y = yp;
		image_index = 0;
	}
	return rv;
}

/// @function					effect_start_scaled_to(sprite, on_layer, xp, yp scaled_width, scaled_height, rotation, speed_multiplier, finished_callback)
/// @description				start a pooled effect animation scaled to a desired end-size
/// @param {asset} sprite
/// @param {string} on_layer
/// @param {real} xp optional x-position. if undefined, x of "self" will be used
/// @param {real} yp optional y-position. if undefined, x of "self" will be used
/// @param {real}	scaled_width
/// @param {real}	scaled_height
/// @param {real=0}	rotation
/// @param {real=1}	speed_multiplier
/// @param {func=undefined}	finished_callback
function effect_start_scaled_to(sprite, on_layer, xp = undefined, yp = undefined, scaled_width, scaled_height, rotation = 0, speed_multiplier = 1, finished_callback = undefined) {
	return effect_start_scaled_by(sprite, on_layer, xp, yp, scaled_width/sprite_get_width(sprite), scaled_height/sprite_get_height(sprite), rotation, speed_multiplier, finished_callback);
}

/// @function					effect_start(sprite, on_layer, xp, yp, rotation, speed_multiplier, finished_callback)
/// @description				start a pooled effect animation
/// @param {asset} sprite
/// @param {string} on_layer
/// @param {real} xp optional x-position. if undefined, x of "self" will be used
/// @param {real} yp optional y-position. if undefined, x of "self" will be used
/// @param {real=0}	rotation
/// @param {real=1}	speed_multiplier
/// @param {func=undefined}	finished_callback
function effect_start(sprite, on_layer, xp = undefined, yp = undefined, rotation = 0, speed_multiplier = 1, finished_callback = undefined) {
	return effect_start_scaled_by(sprite, on_layer, xp, yp, 1, 1, rotation, speed_multiplier, finished_callback);
}
