/*
    The binder is instantiated in every _baseControl as "binder".
	You can bind *any* property or value of the control to *any* source.
	A binder can bind any number of properties, you do NOT need multiple instances per object.
	If the data-types do not match (like binding "text" to the x-position of some object),
	a "ValueConverter" function may be supplied.
	
	Raptor offers two ValueConverters out-of-the-box:
	- NumberToStringConverter (accepts real numbers)
	- StringToNumberConverter (returns real numbers)
*/

#macro BINDINGS	global.__BINDINGS
BINDINGS		= new ListPool("BINDINGS");

function PropertyBinder(_myself = undefined) constructor {
	construct("PropertyBinder");
	
	__bindings = {};
	
	myself = _myself;
	
	/// @function bind(_my_property, _source_instance, _source_property, _converter = undefined)
	static bind = function(_my_property, _source_instance, _source_property, _converter = undefined) {
		var bnd = new Binding(
			myself, _my_property, 
			_source_instance, _source_property, 
			_converter);
			
		__bindings[$ bnd.key] = bnd;
	}
	
	static unbind = function(_my_property) {
		var key = $"{name_of(myself)}.{_my_property}";
		var bnd = vsget(__bindings, key);
		if (bnd != undefined) {
			with(bnd) unbind();
			variable_struct_remove(__bindings, key);
		}
	}
}