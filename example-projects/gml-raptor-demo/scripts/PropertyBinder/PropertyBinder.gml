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

function PropertyBinder() constructor {
	construct("PropertyBinder");
	
	__bindings = {};
	
	static bind = function(_my_value, _to, _converter = undefined) {
	}
}