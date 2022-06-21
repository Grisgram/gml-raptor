/// @function					override(method_name, new_function)
/// @description				Overrides a method in the current object and creates
///								an instance variable "base" that contains the original function.
///								So it is possible to call the "inherited" method via base.method(...)
/// @param {string} method_name
/// @returns {func}	new function
function override(method_name, new_function) {
	var current_base = variable_instance_get(self, "base");
	if (!variable_instance_exists(self, "base"))
		variable_instance_set(self, "base", {});

	variable_struct_set(base, "base", current_base);
	variable_struct_set(base, method_name, variable_instance_get(self, method_name));
	variable_instance_set(self, method_name, method(self, new_function));
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

