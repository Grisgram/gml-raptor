/*
	Utility methods to work with structs.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro __CONSTRUCTOR_NAME			"##_raptor_##.__constructor"
#macro __PARENT_CONSTRUCTOR_NAME	"##_raptor_##.__parent_constructor"
#macro __INTERFACES_NAME			"##_raptor_##.__interfaces"

#macro interface	() constructor

/// @function		construct(_class_name_or_asset)
/// @description	Register a class as a constructible class to raptor.
///					This is used by the file system when loading saved games or any other structures
///					that have been saved through raptor.
///					When loading the file, instead of just assigning the struct, it will invoke
///					the constructor and then perform a struct_join_into with the loaded data, so
///					all members receive their loaded values after the constructor executed.
function construct(_class_name_or_asset) {
	self[$ __PARENT_CONSTRUCTOR_NAME] = (variable_struct_exists(self, __CONSTRUCTOR_NAME) ?
		 self[$ __CONSTRUCTOR_NAME] : undefined);

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
	struct_join_into(self, i);
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
	var newname = prefix + basename;
	while (struct_exists(struct, newname)) {
		newname = string_concat(prefix, basename, i);
		i++;
	}
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
		struct_join_into(rv, argument[i]);
	return rv;
}

/// @function		struct_join_into(target, sources...)
/// @description	Integrate all source structs into the target struct by copying
///					all members from source to target.
///					NOTE: This is NOT a deep copy! If source contains other struct
///					references, they are simply copied, not recursively converted to new references!
///					ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_join_into(target, sources) {
	for (var i = 1; i < argument_count; i++) {
		var from = argument[i];
		var names = struct_get_names(from);
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

/// @function vsgetx(_struct, _key, _default_if_missing = undefined, _create_if_missing = true)
/// @description	Save-gets a struct member, returning a default if it does not exist,
///					and even allows you to create that member in the struct, if it is missing
function vsgetx(_struct, _key, _default_if_missing = undefined, _create_if_missing = true) {
	gml_pragma("forceinline");
	if (_create_if_missing)
		_struct[$ _key] ??= _default_if_missing;
	return _struct[$ _key] ?? _default_if_missing;
}

/// @function vsget(_struct, _key, _default_if_missing = undefined)
/// @description	Save-gets a struct member, returning a default if it does not exist,
///					but does not create the missing member in the struct
function vsget(_struct, _key, _default_if_missing = undefined) {
	gml_pragma("forceinline");
	return _struct[$ _key] ?? _default_if_missing;
}


#region virtual and override

// This is used by the "virtual" and "override" method pair
#macro __FUNCTION_INHERITANCE		global.__function_inheritance
__FUNCTION_INHERITANCE = {}

/// @function virtual(_object_type, _function_name, [_function])
/// @description You must declare a function as "virtual" to be able to "override" it later.
///				 This keeps track of the inheritance chain, and due to the way, how "events"
///				 work in GameMaker, you need to tell the engine, who you are, when you "virtualize"
///				 the function, by also supplying your object_type.
///	Example: 
///		virtual(_myBaseObject, "my_function", function() {...});
function virtual(_object_type, _function_name, _function = undefined) {
	var key = is_string(_object_type) ? _object_type : object_get_name(_object_type);
	var str = vsgetx(__FUNCTION_INHERITANCE, _function_name, {});
	var arr = vsgetx(str, key, []);
	if (!array_contains(arr, key)) {
		array_push(arr, key);
	}
	if (_function != undefined)
		self[$ _function_name] = method(self, _function);
}

/// @function override(_function_name, _new_function)
/// @description NOTE: WORKS FOR OBJECTS ONLY! NOT FOR STRUCTS!
///				 Allows a clean override of any function in an object instance and keeps
///				 the original function available under the parent objects' name + function_name
///	Example:
/// For 3 inheritance levels, lets call them mother, child and grandchild
/// mother defines a = function(...)
/// child does override("a", function(...))
/// grandchild does override("a", function(...)
/// Now child and grand_child may call mother_a and grandchild also has child_a available. 
function override(_object_type, _function_name, _new_function) {
	var str = vsget(__FUNCTION_INHERITANCE, _function_name);
	if (str != undefined) {
		var names = variable_struct_get_names(str);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var rootpar = names[@i];
			if (is_child_of(self, asset_get_index(rootpar))) {
				var arr = vsget(str, rootpar);
				var myname = is_string(_object_type) ? _object_type : object_get_name(_object_type);
				var newname = "";
				if (array_last(arr) != myname) {
					var par = array_last(arr);
					newname = $"{par}_{_function_name}";
					array_push(arr, myname);
				} else {
					var arrlen = array_length(arr);
					if (arrlen > 1) {
						var par = arr[@ arrlen - 2];
						newname = $"{par}_{_function_name}";
					}
				}
				if (newname != "") {
					self[$ newname] = method(self, self[$ _function_name]);
					self[$ _function_name] = method(self, _new_function);
					return;
				}
			}
		}
	}
	// This is a... runtime-compile-error?!?
	throw($"** ERROR ** Function '{_function_name}' can not be overridden as it has not been 'declared'");
}

#endregion
