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

function PropertyBinder(_myself = undefined) constructor {
	construct("PropertyBinder");
	
	__bindings = {};
	
	myself = _myself;
	
	/// @function bind(_my_property, _source_instance, _source_property, _converter = undefined, _on_value_changed = undefined)
	static bind = function(_my_property, _source_instance, _source_property, 
						   _converter = undefined, _on_value_changed = undefined) {
		var bnd = new Binding(
			myself, _my_property, 
			_source_instance, _source_property, 
			_converter,
			_on_value_changed);
			
		__bindings[$ bnd.key] = bnd;
	}
	
	/// @function unbind = function(_my_property)
	static unbind = function(_my_property) {
		var key = $"{name_of(myself)}.{_my_property}";
		var bnd = vsget(__bindings, key);
		if (bnd != undefined) {
			with(bnd) unbind();
			variable_struct_remove(__bindings, key);
		}
	}
	
	/// @function unbind_all = function()
	static unbind_all = function() {
		var names = variable_struct_get_names(__bindings);
		for (var i = 0, len = array_length(names); i < len; i++)
			unbind(__bindings[$ names[@i]].target_property);
	}
	
}