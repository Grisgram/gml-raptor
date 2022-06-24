/*
	Utility methods to work with structs.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function				vs_get_by_path(struct, path)
/// @description			Gets an entry from a variable_struct with the path syntax that
///							is used in LG() too.
///							In a hierachical struct, it gets cruel to cascade 5 variable_struct_get
///							calls to retrieve a single value.
///							This function allow you something like:
///							vs_get_by_path(mystruct, "enemies/dungeon23/bosses/1/name")
///							and you will receive, whatever is stored at this position in the struct.
/// @param {struct}	struct	The struct to search through
/// @param {string} path	The hierarchical path in the struct
///
/// @grisgram 2022-02-18
function vs_get_by_path(struct, path) {
	var key;
	var map = struct;
	var args = string_split(path, "/");
	var len = array_length(args);

	for (var i = 0; i < len - 1; i++) {
		key = args[i];
		map = variable_struct_get(map, key);
		if (map == undefined)
			break;
	}
	if (map != undefined) {
		key = args[len - 1];
		return variable_struct_get(map, key);
	}
	return undefined;
}

/// @function					vs_set_by_path(struct, path, value)
/// @description				Sets an entry from a variable_struct with the path syntax to a new value.
///								In a hierachical struct, it gets cruel to cascade 5 variable_struct_get
///								calls to set a single value.
///								This function allow you something like:
///								vs_set_by_path(mystruct, "enemies/dungeon23/bosses/1/name", "Ragnaros").
///								You can set whatever you want for the value, even create new structs
///								on the fly if you leave the last parameter at its default of true.
/// @param {struct}	struct		The struct to search through
/// @param {string} path		The hierarchical path in the struct
/// @param {any}    value		The value to assign
/// @param {bool=true}   create_path	Default=true. If true, missing elements in the path will be created as structs.
///
/// @grisgram 2022-02-18
function vs_set_by_path(struct, path, value, create_path = true) {
	var key;
	var map = struct;
	var args = string_split(path, "/");
	var len = array_length(args);

	for (var i = 0; i < len - 1; i++) {
		key = args[i];
		var current = map;
		map = variable_struct_get(map, key);
		if (map == undefined) {
			if (create_path) {
				map = {};
				variable_struct_set(current,key,map);
			} else
				break;
		}
	}
	if (map != undefined) {
		key = args[len - 1];
		variable_struct_set(map, key, value);
	}
	return undefined;
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


