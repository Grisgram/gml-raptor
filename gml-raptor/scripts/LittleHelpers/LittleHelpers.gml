
/// @func					is_between(val, lower_bound, upper_bound)
/// @desc				test if a value is between lower and upper (both INCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between(val, lower_bound, upper_bound) {
	gml_pragma("forceinline");
	return val >= lower_bound && val <= upper_bound;
}

/// @func					is_between_ex(val, lower_bound, upper_bound)
/// @desc				test if a value is between lower and upper (both EXCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between_ex(val, lower_bound, upper_bound) {
	gml_pragma("forceinline");
	return val > lower_bound && val < upper_bound;
}

/// @func					is_any_of(val, ...)
/// @desc				after val, specify any number of parameters.
///								determines if val is equal to any of them.
/// @param {any} val
/// @returns {bool}	y/n
function is_any_of(val) {
	for (var i = 1; i < argument_count; i++)
		if (val == argument[i]) return true;
	return false;
}

/// @func		percent(val, total)
/// @desc	Gets, how many % "val" is of "total"
/// @param {real} val	The value
/// @param {real} total	100%
/// @returns {real}	How many % of total is val. Example: val 30, total 50 -> returns 60(%)
function percent(val, total) {
	gml_pragma("forceinline");
	return (val/total) * 100;
}

/// @func					percent_mul(val, total)
/// @desc				Gets, how many % "val" is of "total" as multiplier (30,50 => 0.6)
/// @param {real} val
/// @param {real} total
/// @returns {real}	percent value as multiplier (0..1)
function percent_mult(val, total) {
	gml_pragma("forceinline");
	return (val/total);
}

/// @func					is_child_of(child, parent)
/// @desc				True, if the child is parent or derived anywhere from parent.
/// @param {object_index} child An object instance or object_index of the child to analyze
/// @param {object} parent		The object_index (just the type) of the parent to find
/// @returns {bool}
#macro __OBJECT_HAS_NO_PARENT	-100
#macro __OBJECT_DOES_NOT_EXIST	-1
function is_child_of(child, parent) {
	var to_find, to_find_parent;
	if (instance_exists(child)) {
		to_find = child.object_index;
		if (IS_HTML || !instance_exists(parent)) {
			if (object_get_name(to_find) == object_get_name(parent)) return true;
		} else
			if (to_find == parent.object_index) return true;
		to_find = child;
	} else {
		to_find = child;
		if (IS_HTML) {
			if (object_get_name(to_find) == object_get_name(parent)) return true;
		} else
			if (child == parent) return true;
	}
	
	try {
		while (to_find != __OBJECT_HAS_NO_PARENT && to_find != __OBJECT_DOES_NOT_EXIST && !object_is_ancestor(to_find.object_index, parent)) {
			to_find_parent = object_get_parent(to_find.object_index);
			if (to_find == to_find_parent)
				return false;
			else 
				to_find = to_find_parent;
		}
	} catch (_) {
		return false;
	}
	
	return to_find != __OBJECT_HAS_NO_PARENT && to_find != __OBJECT_DOES_NOT_EXIST;
}

/// @func					name_of(_instance)
/// @desc				If _instance is undefined, undefined is returned,
///								otherwise MY_NAME or object_get_name of the instance is returned,
///								depending on the _with_ref_id parameter.
///								To cover the undefined scenario, this function is normally used like this:
///								var instname = name_of(my_instance) ?? "my default";
/// @param {object_index} _instance	The instance to retrieve the name of.
function name_of(_instance, _with_ref_id = true) {
	if (!is_null(_instance)) {
		if (variable_struct_exists(_instance, "object_index"))
			with(_instance) return _with_ref_id ? MY_NAME : object_get_name(_instance.object_index);
		else {
			if (IS_HTML) {
				var hash = string_replace(sha1_string_unicode(string(_instance)), " ", "");
				return $"{(variable_struct_exists(_instance, __CONSTRUCTOR_NAME) ? $"{_instance[$ __CONSTRUCTOR_NAME]}{(_with_ref_id ? "-" : "")}" : "")}{(_with_ref_id ? hash : "")}";
			} else
				return $"{(variable_struct_exists(_instance, __CONSTRUCTOR_NAME) ? $"{_instance[$ __CONSTRUCTOR_NAME]}{(_with_ref_id ? "-" : "")}" : "")}{(_with_ref_id ? ptr(_instance) : "")}";
		}
	}
	
	return undefined;
}

/// @func					layer_of(_instance)
/// @desc				retrieve the layer name or depth of _instance
///								if instance is nullish, -1 is returned (gms default for "no layer")
function layer_of(_instance) {
	if (!is_null(_instance))
		with(_instance) return MY_LAYER_OR_DEPTH;
	return -1;
}

/// @func construct_or_invoke(_script, args...)
/// @desc	Now, that's an ugly one, I know, but at the moment of writing this, GameMaker
///					has no way to tell normal functions apart from constructors.
///					There's not other way, to find out, as to fall in a catch if constructing fails.
function construct_or_invoke(_script) {
	var res;
	try {
		switch (argument_count) {
			case  1: res = new _script(); break;
			case  2: res = new _script(argument[1]); break;
			case  3: res = new _script(argument[1],argument[2]); break;
			case  4: res = new _script(argument[1],argument[2],argument[3]); break;
			case  5: res = new _script(argument[1],argument[2],argument[3],argument[4]); break;
			case  6: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	} catch (_) {
		switch (argument_count) {
			case  1: res = _script(); break;
			case  2: res = _script(argument[1]); break;
			case  3: res = _script(argument[1],argument[2]); break;
			case  4: res = _script(argument[1],argument[2],argument[3]); break;
			case  5: res = _script(argument[1],argument[2],argument[3],argument[4]); break;
			case  6: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	return res;
}

function seconds_to_frames(_seconds) {
	gml_pragma("forceinline");
	return (_seconds * room_speed);
}

function ms_to_frames(_milliseconds) {
	gml_pragma("forceinline");
	return (_milliseconds / 1000 * room_speed);
}

function frames_to_ms(_frames) {
	gml_pragma("forceinline");
	return _frames / room_speed * 1000;
}

function frames_to_seconds(_frames) {
	gml_pragma("forceinline");
	return _frames / room_speed;
}

/// @func		run_delayed(owner, delay, func, data = undefined)
/// @desc	Executes a specified function in <delay> frames from now.
///					Behind the scenes this uses the __animation_empty function which
///					is part of the ANIMATIONS ListPool, so if you clear all animations,
///					or use animation_run_ex while this is waiting for launch, 
///					you will also abort this one here.
///					Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
/// @returns {Animation}	The animation processing the delay
function run_delayed(owner, delay, func, data = undefined) {
	var anim = __animation_empty(owner, delay, 0).add_finished_trigger(function(data) { data.func(data.args); });
	anim.data.func = func;
	anim.data.args = data;
	return anim;
}

/// @func		run_delayed_ex(owner, delay, func, data = undefined)
/// @desc	Executes a specified function EXCLUSIVELY in <delay> frames from now.
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
/// @returns {Animation}	The animation processing the delay
function run_delayed_ex(owner, delay, func, data = undefined) {
	animation_abort_all(owner);
	return run_delayed(owner, delay, func, data);
}

/// @func		run_delayed_exf(owner, delay, func, data = undefined)
/// @desc	Read _exf as "exclusive with finish"
///					Executes a specified function EXCLUSIVELY in <delay> frames from now.
///					Exclusively means in this case, animation_finish_all is invoked before
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
/// @returns {Animation}	The animation processing the delay
function run_delayed_exf(owner, delay, func, data = undefined) {
	animation_finish_all(owner);
	return run_delayed(owner, delay, func, data);
}

/// @func		if_null(value, value_if_null)
/// @desc	Tests if the specified value is undefined or noone, or,
///					if it is a string, is empty.
///					In any of those cases value_if_null is returned, otherwise
///					value is returned.
/// @param {any} value	The value to test
/// @param {any} value_if_null	the value to return, if value is null.
/// @returns {any}	value or value_if_null
function if_null(value, value_if_null) {
	if (value == undefined || value == noone)
		return value_if_null;
	if (is_string(value))
		return string_is_empty(value) ? value_if_null : value;
	return value;
}

/// @func		is_null(value)
/// @desc	Tests if the specified value is undefined or noone, or,
///					if it is a string, is empty.
///					In any of those cases true is returned, otherwise
///					false is returned.
/// @param {any} value	The value to test
/// @returns {bool}	value is nullish or not
function is_null(value) {
	if (value == undefined || value == noone)
		return true;
	if (is_string(value))
		return string_is_empty(value);
	return false;
}

/// @func		eq(inst1, inst2)
/// @desc	Compare, whether two object instances are the same instance
///					Due to a html bug you can not simply compare inst1==inst2,
///					but you have to compare their ids instead.
function eq(inst1, inst2) {
	try { return name_of(inst1) == name_of(inst2); } catch (_) { return false; }
}

/// @func with_tag(_tag, _func, _data = undefined)
/// @desc Executes the specified function for all object instances
///				 that are tagged with the specified tag.
///				 NOTE: The function is temporary bound to the instance, so
///				 the code IN the function will run in the scope of the instance!
///				 You may also specify any _data object to be sent into each of 
///				 the invoked functions
function with_tag(_tag, _func, _data = undefined) {
	var tagged = tag_get_asset_ids(_tag, asset_object);
	for (var i = 0, len = array_length(tagged); i < len; i++) {
		with(tagged[@i]) {
			var tmpfunc = method(self, _func);
			tmpfunc(_data);
		}
	}
}

/// @func method_exists(_instance, _method)
/// @desc Checks, whether a method with the specified name exists in _instance
/// @returns {bool}	True, if a method with that name exists, otherwise false
function method_exists(_instance, _method) {
	return is_callable(vsget(_instance, _method));
}

/// @func invoke_if_exists(_instance, _method, ...)
/// @desc Invoke the method, if it exists, with all arguments specified after the
///				 _instance and _method arguments.
///				 NOTE: GameMaker supports a maximum of 16 arguments, 2 are already used for
///				 _instance and _method, so this leaves a maximum of 14 arguments for your call.
/// @returns {any} The return value of the method or undefined, if the method does not exist
function invoke_if_exists(_instance, _method) {
	var meth = vsget(_instance, _method);
	if (is_callable(meth)) {
		switch (argument_count) {
			case  2: return meth(); break;
			case  3: return meth(argument[2]); break;
			case  4: return meth(argument[2],argument[3]); break;
			case  5: return meth(argument[2],argument[3],argument[4]); break;
			case  6: return meth(argument[2],argument[3],argument[4],argument[5]); break;
			case  7: return meth(argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	return undefined;
}