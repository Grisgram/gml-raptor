/// @description declare mouse_is_over

// Inherit the parent event
event_inherited();

mouse_is_over = false;

/// StatefulObject adds an "animation_end" memmber to data
if (states != undefined) 
	states.data.animation_end = false;

/// @function		set_state(name, enter_override = undefined, leave_override = undefined)
/// @description	Convenience shortcut to states.set_state (as this happens often accidently)
set_state = function(name, enter_override = undefined, leave_override = undefined) {
	return states.set_state(name, enter_override, leave_override);
}

/// @function		is_in_state(name)
/// @description	Convenience shortcut to states.active_state_name() == name
is_in_state = function(name) {
	return states.active_state_name() == name;
}


/// @function sprite_animate_once(_sprite_index, _sprite_index_after = undefined, _state_after = undefined, _finished_callback = undefined)
/// @description	Switch to the given sprite and let the animation run once.
///					When finished, the sprite is set to _sprite_index_after or
///					frozen at the last frame (if no _after is set).
///					Then the optional callback gets invoked.
/// @param {sprite}	_sprite_index		The sprite index to set
/// @param {bool}	_sprite_index_after	If set, the sprite_index to set when animation finished
///										NOTE: If this is not set, the _sprite_index will freeze
///											  with image_speed = 0 at the last frame!
/// @param {string} _state_after		The state to set on this object when the animation finished
///										NOTE: The state is set AFTER the finished_callback has been invoked to avoid
///										code in the "enter" event of the state interfering with the callback
/// @param {func}	_finished_callback	A function to call, when the animation is finished
sprite_animate_once = function(_sprite_index, _sprite_index_after = undefined, _state_after = undefined, _finished_callback = undefined) {
	vlog($"Running single animation of sprite '{sprite_get_name(_sprite_index)}'");
	__reset_single_sprite_animation();
	sprite_index = _sprite_index;
	image_index = 0;
	__single_sprite_animation_running		= true;
	__single_sprite_animation_sprite_after	= _sprite_index_after;
	__single_sprite_animation_state_after	= _state_after;
	__single_sprite_animation_callback		= _finished_callback;
	states.data.animation_end = false;
}

__single_sprite_animation_finished = function() {
	var after = __single_sprite_animation_sprite_after != undefined ? sprite_get_name(__single_sprite_animation_sprite_after) : "none";
	vlog($"Single animation of sprite '{sprite_get_name(sprite_index)}' finished: follow_up='{after}';");
	__single_sprite_animation_running = false;
	if (__single_sprite_animation_sprite_after != undefined) {
		sprite_index = __single_sprite_animation_sprite_after;
		image_index = 0;
		vlog($"Sprite set to '{sprite_get_name(sprite_index)}' at frame 0");
	} else {
		image_speed = 0;
		image_index = image_number - 1;
		vlog($"Sprite frozen at last frame at the end of single animation");
	}
	
	var sa = __single_sprite_animation_state_after;
	var cb = __single_sprite_animation_callback;
	__reset_single_sprite_animation();

	if (cb != undefined) {
		vlog($"Running single animation finish callback");
		cb();
	}
	if (sa != undefined) {
		vlog($"Setting single animation state after '{sa}'");
		set_state(sa);
	}
}

__reset_single_sprite_animation = function() {
	__single_sprite_animation_running		= false;
	__single_sprite_animation_sprite_after	= undefined;
	__single_sprite_animation_callback		= undefined;
	__single_sprite_animation_state_after	= undefined;
}

__reset_single_sprite_animation();

__shall_forward_mouse_event = function(_state) {
	if (mouse_events_are_unique) {
		with (StatefulObject) {
			if (mouse_events_are_unique && is_in_state(_state)) {
				vlog($"Interrupted mouse event {_state} for {MY_NAME}");
				return false;
			}
		}
	}
	
	return true;
}
