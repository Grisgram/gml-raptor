/// @description declare mouse_is_over

// Inherit the parent event
event_inherited();

mouse_is_over = false;

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