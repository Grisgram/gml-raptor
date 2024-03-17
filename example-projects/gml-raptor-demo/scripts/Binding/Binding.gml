/*
    holds one single bound property and its state.
	
	Allow a callback to be invoked when the bound value changes.
	This callback receives 2 arguments: new_value, old_value
*/

function Binding(
	_myself, _my_property, 
	_source_instance, _source_property, 
	_converter = undefined,
	_on_value_changed = undefined) constructor {
	construct("Binding");

	key = $"{name_of(_myself)}.{_my_property}";
	
	target_instance  = _myself;
	target_property  = _my_property;
	source_instance  = _source_instance;
	source_property  = _source_property;

	converter		 = _converter;
	on_value_changed = _on_value_changed;

	BINDINGS.add(self);
	
	dlog($"Binding created: {name_of(target_instance)}.{target_property} is bound to {name_of(source_instance)}.{source_property}");
	
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
				on_value_changed(other.__new_value, other.__old_value);
		}
	}

	static unbind = function() {
		BINDINGS.remove(self);
		dlog($"Binding removed: {name_of(target_instance)}.{target_property} from {name_of(source_instance)}.{source_property}");
	}

}

