/// @function					is_between(val, lower_bound, upper_bound)
/// @description				test if a value is between lower and upper (both INCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between(val, lower_bound, upper_bound) {
	return val >= lower_bound && val <= upper_bound;
}

/// @function					is_between_ex(val, lower_bound, upper_bound)
/// @description				test if a value is between lower and upper (both EXCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between_ex(val, lower_bound, upper_bound) {
	return val > lower_bound && val < upper_bound;
}

/// @function					is_any_of(val)
/// @description				after val, specify any number of parameters.
///								determines if val is equal to any of them.
/// @param {any} val
/// @returns {bool}	y/n
function is_any_of(val) {
	for (var i = 1; i < argument_count; i++)
		if (val == argument[i]) return true;
	return false;
}

/// @function					percent(of, total)
/// @description				Gets, how many % "of" is of "total" (30,50 => 60%)
/// @param {real} of
/// @param {real} total
/// @returns {real}	percent value
function percent(of, total) {
	return (of/total) * 100;
}

/// @function					percent_mul(of, total)
/// @description				Gets, how many % "of" is of "total" as multiplier (30,50 => 0.6)
/// @param {real} of
/// @param {real} total
/// @returns {real}	percent value as multiplier (0..1)
function percent_mult(of, total) {
	return (of/total);
}

/// @function					is_child_of(child, parent)
/// @description				True, if the child is exactly parent type or derived from it
/// @param {object_index} child
/// @param {object} parent
/// @returns {bool}
function is_child_of(child, parent) {
	var ci;
	with(child) ci = object_index;
	
	return object_is_ancestor(ci, parent);
	//return child == parent || object_is_ancestor(child, parent);
}

