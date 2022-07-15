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

/// @function		percent(val, total)
/// @description	Gets, how many % "val" is of "total"
/// @param {real} val	The value
/// @param {real} total	100%
/// @returns {real}	How many % of total is val. Example: val 30, total 50 -> returns 60(%)
function percent(val, total) {
	return (val/total) * 100;
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

/// @function		run_delayed(owner, delay, func, data = undefined)
/// @description	Executes a specified function in <delay> frames from now.
///					Behind the scenes this uses the __animation_empty function which
///					is part of the ANIMATIONS ListPool, so if you clear all animations,
///					or use animation_run_ex while this is waiting for launch, 
///					you will also abort this one here.
///					Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
function run_delayed(owner, delay, func, data = undefined) {
	var anim = __animation_empty(owner, delay, 0).add_finished_trigger(function(data) { data.func(data.args); });
	anim.data.func = func;
	anim.data.args = data;
}

/// @function		run_delayed_ex(owner, delay, func, data = undefined)
/// @description	Executes a specified function EXCLUSIVELY in <delay> frames from now.
///					Exclusively means in this case, animation_abort_all is invoked before
///					starting the delayed waiter.
///					Behind the scenes this uses the __animation_empty function which
///					is part of the ANIMATIONS ListPool, so if you clear all animations,
///					or use animation_run_ex while this is waiting for launch, 
///					you will also abort this one here.
///					Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
function run_delayed_ex(owner, delay, func, data = undefined) {
	animation_abort_all(owner);
	run_delayed(owner, delay, func, data);
}