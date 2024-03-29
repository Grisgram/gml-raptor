/*
    holds one single bound property and its state.
	
	Allow a callback to be invoked when the bound value changes.
	This callback receives 2 arguments: new_value, old_value
*/

function __Binding(
	_prefix				= "",
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined) constructor {
	construct(__Binding);

	key = $"{_prefix}_{name_of(_myself)}.{_my_property}";
	
	target_instance  = _myself;
	target_property  = _my_property;
	source_instance  = _source_instance;
	source_property  = _source_property;

	converter		 = _converter;
	on_value_changed = _on_value_changed;

	BINDINGS.add(self);

	if (DEBUG_LOG_BINDINGS)
		dlog($"{_prefix}_binding created: {name_of(target_instance ?? self)}.{target_property ?? source_property} is bound to {name_of(source_instance)}.{source_property}");
	
	__new_value = undefined;
	__old_value = undefined;
	static update_binding = function() {
		__new_value = (converter != undefined ? 
			converter(source_instance[$ source_property], source_instance) : 
			source_instance[$ source_property]);

		if (__new_value != __old_value) {
			target_instance[$ target_property] = __new_value;
			__old_value = __new_value;
			if (on_value_changed != undefined)
				on_value_changed(__new_value, __old_value);
		}
	}

	static unbind = function() {
		var cnt = BINDINGS.remove_where(function(bnd, key) { 
			return bnd.key == key; }, key);
		if (DEBUG_LOG_BINDINGS)
			dlog($"{cnt} Binding(s) removed: {name_of(target_instance ?? self)}.{target_property ?? source_property} from {name_of(source_instance)}.{source_property}");
	}
	
	toString = function() {
		return $"{name_of(source_instance)}.{source_property} -> {name_of(target_instance)}.{target_property}";
	}
}

function PushBinding(
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined) : __Binding(
		"push",	_myself, _my_property, _source_instance, _source_property, _converter, _on_value_changed) constructor {
	construct(PushBinding);
}
	
function PullBinding(
	_myself				= undefined, 
	_my_property		= "", 
	_source_instance	= undefined, 
	_source_property	= "", 
	_converter			= undefined,
	_on_value_changed	= undefined) : __Binding(
		"pull",
		_myself, _my_property, 
		_source_instance, _source_property, 
		_converter, _on_value_changed) constructor {
	construct(PullBinding);
}
	
function WatcherBinding(
	_source_instance	= undefined, 
	_source_property	= undefined, 
	_on_value_changed	= undefined) : 
	PushBinding(_source_instance, _source_property, _source_instance, _source_property,,_on_value_changed) constructor {
	construct("WatcherBinding");
		
	static update_binding = function() {
		__new_value = source_instance[$ source_property];

		if (__new_value != __old_value) {
			__old_value = __new_value;
			if (on_value_changed != undefined)
				on_value_changed(__new_value, __old_value);
		}
	}
}