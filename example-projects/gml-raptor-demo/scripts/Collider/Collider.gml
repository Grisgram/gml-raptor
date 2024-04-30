/*
    The Collider script is a set of functions that can help you determine,
	whether a collision event occurs for the first time or is ongoing.
	
	If the same collision appeared last frame, it is considered ongoing.
	The functions have no arguments, they use the keywords "self" and "other",
	as you would in a collision event, that's why they are global functions and
	not a constructor/class - to make sure, self and other point to the colliding 
	instances.
*/

#macro __COLLIDER_CACHE		global.__collider_cache
__COLLIDER_CACHE = {};

/// @function collider_first()
/// @description Checks, if this is the first collision between self and other
///				 (means: they has not been the same collision in the previous frame),
///				 and returns true, if that's the case
function collider_first() {
	var key  = $"{MY_NAME}_{name_of(other)}";
	var last = vsget(__COLLIDER_CACHE, key, -2);
	struct_set(__COLLIDER_CACHE, key, GAMEFRAME);
	return last < GAMEFRAME - 1;
}

/// @function collider_cleanup()
/// @description This function is called in the "Clean Up" event of _raptorBase.
///				 It removes all cached results for the instance getting destroyed.
function collider_cleanup() {
	var part = MY_NAME;
	var names = struct_get_names(__COLLIDER_CACHE);
	for (var i = 0, len = array_length(names); i < len; i++) {
		var member = names[@i];
		if (string_starts_with(member, part) || string_ends_with(member, part)) {
			struct_remove(__COLLIDER_CACHE, member);
		}
	}
}