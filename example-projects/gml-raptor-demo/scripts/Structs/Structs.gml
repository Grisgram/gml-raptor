/*
	Utility methods to work with structs.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro __CONSTRUCTOR_NAME		"##_raptor_##.__constructor"
#macro __INTERFACES_NAME		"##_raptor_##.__interfaces"

#macro interface				() constructor

/// @function		construct(_class_name_or_asset)
/// @description	Register a class as a constructible class to raptor.
///					This is used by the file system when loading saved games or any other structures
///					that have been saved through raptor.
///					When loading the file, instead of just assigning the struct, it will invoke
///					the constructor and then perform a struct_integrate with the loaded data, so
///					all members receive their loaded values after the constructor executed.
function construct(_class_name_or_asset) {
	self[$ __CONSTRUCTOR_NAME] = is_string(_class_name_or_asset) ? _class_name_or_asset : script_get_name(_class_name_or_asset);
}

/// @function		implement(_interface)
/// @description	Works like an interface implementation by copying all members
///					and re-binding all methods from "interface" to "self"
///					Creates a hidden member __raptor_interfaces in this struct which contains
///					all implemented interfaces, so you can always ask "if (implements(interface))..."
///					NOTE: "interface" MUST BE A PARAMETERLESS CONSTRUCTOR FUNCTION!
///					This function will create one instance and copy/rebind all elements to self.
function implement(_interface) {
	var sname, sclass;
	if (is_string(_interface)) {
		sname = _interface;
		sclass = asset_get_index(sname);
	} else {
		sname = script_get_name(_interface);
		sclass = _interface;
	}
	
	var i = new sclass();
	struct_integrate(self, i);
	if (!variable_struct_exists(self, __INTERFACES_NAME))
		self[$ __INTERFACES_NAME] = [];
	if (!array_contains(self[$ __INTERFACES_NAME], sname))
		array_push(self[$ __INTERFACES_NAME], sname);
}

/// @function		implements(struct, _interface)
/// @description	Asks the specified struct whether it implements the specified interface.
function implements(struct, _interface) {
	var sname = is_string(_interface) ? _interface : script_get_name(_interface);
	return variable_struct_exists(struct, __INTERFACES_NAME) && array_contains(struct[$ __INTERFACES_NAME], sname);
}

/// @function					struct_get_unique_key(struct, basename, prefix = "")
/// @description				get a free name for a key in a struct with an optional prefix
/// @param {struct} struct
/// @param {string} basename
/// @param {string=""} prefix
/// @returns {string} the new name	
function struct_get_unique_key(struct, basename, prefix = "") {
	var i = 0;
	var newname;
	do {
		newname = prefix + basename + string(i);
		i++;
	} until (!variable_struct_exists(struct, newname));
	return newname;
}

/// @function		struct_join(structs...)
/// @description	Joins two or more structs together into a new struct.
///					NOTE: This is NOT a deep copy! If any struct contains other struct
///					references, they are simply copied, not recursively converted to new references!
///					ATTENTION! No static members can be transferred! Best use this for data structs only!
/// @param {struct...} any number of structs to be joined together
function struct_join(structs) {
	var rv = {};
	for (var i = 0; i < argument_count; i++) 
		struct_integrate(rv, argument[i]);
	return rv;
}

/// @function		struct_integrate(target, sources...)
/// @description	Integrate all source structs into the target struct by copying
///					all members from source to target.
///					NOTE: This is NOT a deep copy! If source contains other struct
///					references, they are simply copied, not recursively converted to new references!
///					ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_integrate(target, sources) {
	for (var i = 1; i < argument_count; i++) {
		var from = argument[i];
		var names = variable_struct_get_names(from);
		with (target) {
			for (var i = 0; i < array_length(names); i++) {
				var name = names[i];
				var member = from[$ name];
				if (is_method(member))
					self[$ name] = method(self, member);
				else
					self[$ name] = from[$ name];
			}
		}
	}
	return target;
}

/// @function struct_get_ext(struct, key, default_if_missing, create_if_missing = true)
/// @description	Save-gets a struct member, returning a default if it does not exist,
///					and even allows you to create that member in the struct, if it is missing
function struct_get_ext(struct, key, default_if_missing, create_if_missing = true) {
	if (variable_struct_exists(struct, key))
		return struct[$ key];
		
	if (create_if_missing)
		struct[$ key] = default_if_missing;
	
	return default_if_missing;
}
