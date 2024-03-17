/*
    The binder is instantiated in every _raptorBase as "binder".
	You can bind *any* property or value of the instance to *any* source, even struct sources, not only instances!
	A binder can bind any number of properties, you do NOT need multiple instances per object.
	If the data-types do not match (like binding "text" to the x-position of some object),
	a "ValueConverter" function may be supplied.
	
	This function receives the value as argument and must return the converted/formatted value,
	so that the binding target can accept it.
*/

#macro BINDINGS	global.__BINDINGS
BINDINGS		= new ListPool("BINDINGS");

#macro STRING_TO_NUMBER_CONVERTER	function(_value) { return real(_value); }
#macro NUMBER_TO_STRING_CONVERTER	function(_value) { return string(_value); }

function PropertyBinder(_myself = undefined) constructor {
	construct("PropertyBinder");
	
	__source_bindings = {};
	__bindings = {};
	
	myself = _myself;
	
	/// @function bind_pull(_my_property, _source_instance, _source_property, _converter = undefined, _on_value_changed = undefined)
	/// @description Bind my property to RECEIVE the value from _source_instance._source_property
	///				 ("pull" the value)
	static bind_pull = function(_my_property, _source_instance, _source_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		var bnd = new Binding(
			myself, _my_property, 
			_source_instance, _source_property, 
			_converter,
			_on_value_changed);
		
		__bindings[$ bnd.key] = bnd;
		if (vsget(_source_instance, "binder") != undefined)
			_source_instance.binder.__source_bindings[$ bnd.key] = bnd;
	}
	
	/// @function bind_push(_my_property, _target_instance, _target_property, _converter = undefined, _on_value_changed = undefined)
	/// @description Bind my property to SET the value of _target_instance._target_property
	///				 ("push" the value).
	///				 This function is especially useful, if you want to push one of your instance
	///			     properties to a struct, that does not have a "binder" member and therefore can't
	///				 pull bindings.
	static bind_push = function(_my_property, _target_instance, _target_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		var bnd = new Binding(
			_target_instance, _target_property, 
			myself, _my_property, 
			_converter,
			_on_value_changed);
		
		__source_bindings[$ bnd.key] = bnd;
		if (vsget(_target_instance, "binder") != undefined)
			_target_instance.binder.__bindings[$ bnd.key] = bnd;
	}
	
	/// @function unbind(_my_property)
	static unbind = function(_my_property) {
		var key = $"{name_of(myself)}.{_my_property}";
		var bnd = vsget(__bindings, key);
		if (bnd != undefined) {
			if (vsget(bnd.source_instance, "binder") != undefined) {
				dlog($"Removing source-binding from {name_of(bnd.source_instance)}.{_my_property}");
				variable_struct_remove(bnd.source_instance.binder.__source_bindings, key);
			}
			variable_struct_remove(__bindings, key);
			with(bnd) unbind();
		}
	}
	
	/// @function unbind_source()
	/// @description Unbind me, where this is the SOURCE (inverse direction)
	static unbind_source = function() {
		var names = struct_get_names(__source_bindings);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var key = names[@i];
			var src = __source_bindings[$ key];
			if (vsget(src.target_instance, "binder") != undefined)
				with(src.target_instance)
					binder.unbind(binder.__bindings[$ key].target_property);
			else
				with(src) unbind(); // struct push binding
			variable_struct_remove(__source_bindings, key);
		}
	}
	
	/// @function unbind_all = function()
	static unbind_all = function() {
		unbind_source();
		var names = struct_get_names(__bindings);
		for (var i = 0, len = array_length(names); i < len; i++)
			unbind(__bindings[$ names[@i]].target_property);
	}
	
}