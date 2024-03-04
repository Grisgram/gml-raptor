/*
    holds one single bound property and its state
*/

function Binding(
	_myself, _my_property, 
	_source_instance, _source_property, 
	_converter = undefined) constructor {
	construct("Binding");

	key = $"{name_of(_myself)}.{_my_property}";
	
	target_instance = _myself;
	target_property = _my_property;
	source_instance = _source_instance;
	source_property = _source_property;

	converter		= _converter;

	__dirty		= false;
	
	BINDINGS.add(self);
	
	static update_binding = function() {
		var _new_value = viget(source_instance, source_property);
		_new_value = (converter != undefined ? converter(_new_value) : _new_value);
		if (_new_value != viget(target_instance, target_property, _new_value)) {
			variable_instance_set(target_instance, target_property, _new_value);
			with(target_instance) force_redraw();
		}
	}

	static unbind = function() {
		BINDINGS.remove(self);
	}

}

