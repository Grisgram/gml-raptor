/// @function					override(method_name, _base_name, _new_function)
/// @description				Overrides a method in the current object and creates
///								an instance variable "base" that contains the original function.
///								So it is possible to call the "inherited" method via base.method(...)
/// @param {string} method_name
/// @returns {func}	new function
function override(_method_name, _base_name = undefined, _new_function) {
	_base_name ??= _method_name;
	if (!variable_instance_exists(self, "base"))
		self[$ "base"] = {};

	base[$ _base_name] = method(self, self[$ _method_name]);
	self[$ _method_name] = method(self, _new_function);
}


/// @function					override2(method_name, new_function)
/// @description				Overrides a method in the current object and creates
///								an instance variable "base" that contains the original function.
///								So it is possible to call the "inherited" method via base.method(...)
/// @param {string} method_name
/// @returns {func}	new function
//function override2(method_name, new_function) {
//    var _base;
//    if (!variable_instance_exists(self, "base")) {
//        self.base = {};
//        _base = self.base;
//    } else {
//        _base = self.base;
//        self.base = {base: _base};
//        _base = self.base;
//    }

//    _base[$ method_name] = self[$ method_name];
//   self[$ method_name] = new_function;
//}

