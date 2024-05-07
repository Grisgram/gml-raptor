/*
	RACE - The (Ra)ndom (C)ontent (E)ngine.
	Generic loot system.
	
	This script loads race table files and provides getters and setters for
	the fields of loot tables.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// List of property names in the race table structs
#macro __RACE_FIELD_LOOT_COUNT	"loot_count"
#macro __RACE_FIELD_NAME		"name"
#macro __RACE_FIELD_TYPE		"type"
#macro __RACE_FIELD_ALWAYS		"always"
#macro __RACE_FIELD_UNIQUE		"unique"
#macro __RACE_FIELD_ENABLED		"enabled"
#macro __RACE_FIELD_CHANCE		"chance"
#macro __RACE_FIELD_VALUE		"value"
#macro __RACE_FIELD_ITEMS		"items"
#macro __RACE_FIELD_ATTRIBUTES	"attributes"

#macro __RACE_GLOBAL			global.__race_tables

// internal query-runtime macros
#macro RACE_TABLE_CURRENT		global.__race_table_current
#macro RACE_TABLE_QUERIED		global.__race_table_queried
#macro RACE_ITEM_DROPPED		global.__race_item_dropped



/// @func	race_load_file(filename_to_load, overwrite_existing = true)
/// @desc	Loads race tables from the specified file into __RACE_GLOBAL. 
///			NOTE: If you (re)load a file that has already been loaded, all tables
///			in memory that match tables in that file will be replaced by a new instance of the struct!
///			(in other words: reloading a file overwrites in-memory values and your pointers become invalid).
///			If you do not want that (if you want to preserve in-memory values, set the second
///			parameter of this function (overwrite_existing) to false.
/// @param  {string} filename_to_load	The file to load. RACE_ROOT_FOLDER will be used as prefix for the path
///										(default is "race/". See Race_Configuration script!). ".json" will be appended for you.
/// @param  {bool=true} overwrite_existing	Defaults to true. If true, any already loaded table in memory will be reset
///										to the values loaded from file. Set to false to preserve any existing in-memory states.
function race_load_file(filename_to_load, overwrite_existing = true) {
	ENSURE_RACE;
	
	var filename = string_concat(RACE_ROOT_FOLDER, filename_to_load, (string_ends_with(filename_to_load, ".json") ? "" : ".json"));
	if (!file_exists(filename)) {
		if (DEBUG_LOG_RACE)
			elog($"*ERROR* race table file '{filename}' not found!");
		return;
	}
	
	var tablefile = file_read_struct_plain(filename);
	
	if (tablefile != undefined) {
		var names = struct_get_names(tablefile);
		var tablecnt = array_length(names);
			
		if (DEBUG_LOG_RACE)
			ilog($"Successfully loaded {tablecnt} table(s) from '{filename}'{(overwrite_existing ? " WITH OVERWRITE" : "")}");
		for (var i = 0; i < tablecnt; i++) {
			var table = struct_get(tablefile, names[i]);
			race_add_table(names[i], table, overwrite_existing);
		}
	} else
		if (DEBUG_LOG_RACE)
			elog($"*ERROR* Failed to load race table file '{filename}'!")
}

/// @func	race_get_table(table_name)
/// @param   {string} table_name	The table to get
/// @returns {struct}	The race table struct.
/// @desc	Gets a race table from __RACE_GLOBAL.
///			If table_name is not found in the globals, undefined is returned.
///			NOTE: You can use this function to "export" a table from race, 
///			to persist it in the save game. It can be imported again through
///			race_add_table().
function race_get_table(table_name) {
	return is_string(table_name) ? struct_get(__RACE_GLOBAL, table_name) : table_name;
}

/// @func				race_get_table_names()
/// @returns {array}	An array of all known race table names.
/// @desc	Gets a list of currently loaded race table names.
///			This list also contains all names of dynamically created
///			tables through recursive queries.
///			Dynamically created table names always start with $
function race_get_table_names() {
	return struct_get_names(__RACE_GLOBAL);
}

/// @func	race_add_table(table_name, table_struct, overwrite_existing = true)
/// @param  {string} table_name			The name of the table to add.
/// @param  {struct} table_struct		The race table struct to add.
/// @param  {bool=true}	overwrite_existing	Default=true. Overwrite the table in race if it does already exist.
/// @desc	Adds a table to __RACE_GLOBAL.
///			This function can be used to import a table that has not been loaded
///			through a regular race file, but from somewhere else, maybe the savegame.
///			NOTE: Overwriting an existing table means: Another INSTANCE is assigned!
///			All your current pointers to table old table are 
///			now invalid/target the wrong struct!
///			Make sure to call set_table() on all object instances of the 
///			RaceTable object in your current room that use this table!
function race_add_table(table_name, table_struct, overwrite_existing = true) {
	if (overwrite_existing || !variable_struct_exists(__RACE_CACHE, table_name)) {
		race_table_set_name(table_struct, table_name);
		struct_set(__RACE_CACHE, table_name, table_struct);
		var dc = SnapDeepCopy(table_struct);
		struct_set(__RACE_GLOBAL, table_name, dc);					
		if (DEBUG_LOG_RACE)
			dlog($"Added global race table '{table_name}'");
	}
}

/// @func	race_table_exists(table_name)
/// @param  {string} table_name	The table to get
/// @returns {bool}				True, if that table exists and is loaded, otherwise false.
/// @desc	Test whether the specified table exists and is loaded.
function race_table_exists(table_name) {
	return variable_struct_exists(__RACE_GLOBAL, table_name);
}

/// @func	race_table_reset(table_name, recursive = false)
/// @param  {string} table_name	The table to reset
/// @param  {bool=false} recursive	(Default false). Set to true to have referenced sub tables reset also.
/// @returns {struct}			The reset race table struct.
/// @desc	Resets a table to the originl state when it was added or loaded from a file.
///			All temp-tables (clones from "+" types) are destroyed.
///			Referenced subtables ("=" types) are only reset if you set recursive to true.
///			If table_name is not found in the globals, undefined is returned.
function race_table_reset(table_name, recursive = false) {
	var cache = struct_get(__RACE_CACHE, table_name);
	if (cache != undefined) {
		var tbl = struct_get(__RACE_GLOBAL, table_name);
		var items = tbl.items;
		var names = struct_get_names(items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@ i];
			if (recursive && string_starts_with(name, "="))
				race_table_reset(string_skip_start(name, 1), recursive);
			if (string_starts_with(name, __RACE_TEMP_TABLE_PREFIX))
				__race_table_delete_temp(name);
		}
		var dc = SnapDeepCopy(cache);
		struct_set(__RACE_GLOBAL, table_name, dc);
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{table_name}' has been reset");
		return dc;
	} else 
		if (DEBUG_LOG_RACE)
			elog($"**ERROR** Race table '{table_name}' reset failed. Table not found!");
	return undefined;
}

/// @func	race_table_clone(table_name)
/// @desc	Clones a race table and returns the new name.
///			Use this function if specific objects need their own
///			private copy of a table. Make sure, to remember the return value
///			of this function. The new name is your only access point to the clone.
/// @param  {string} table_name	The name of the table to clone. If it does not exist, undefined is returned.
/// @returns {string}			The name of the clone or undefined, if table_name does not exist or is not loaded.
function race_table_clone(table_name) {
	if (race_table_exists(table_name)) {
		var deepcopy = SnapDeepCopy(race_get_table(table_name));
		// find a free new name for the deep copy
		var newname = __race_get_unique_deepcopy_name(table_name);
		race_add_table(newname, deepcopy);
		return newname;
	}
	return undefined;
}

/// @func	__race_table_delete_temp(table_name)
/// @desc	Deletes a temporary race_table (that is a table, created through "+" queries
///			or with race_table_clone(...).
///			NOTE: Only tables that start with "$" can be deleted!
/// @param  {string} table_name	The table to delete
function __race_table_delete_temp(table_name) {
	if (!string_starts_with(table_name, __RACE_TEMP_TABLE_PREFIX) || !race_table_exists(table_name))
		return;
	if (DEBUG_LOG_RACE)
		dlog($"Deleting temp race table '{table_name}'");
	variable_struct_remove(__RACE_GLOBAL, table_name);
}

/// @func	race_table_dump(table_name)
/// @param  {string|struct} table_name	The table to iterate over. Can be the name of the table OR the table struct.
/// @desc	Dumps the table and all items to the debug console.
function race_table_dump(table_name) {
	var tname = is_struct(table_name) ? race_table_get_name(table_name) : table_name;
	ilog($"[TABLE DUMP: {tname}]");
	race_table_foreach_item(table_name, function(name, item) {
		ilog($"{name}: {item}");
	});
	ilog($"[/TABLE DUMP]");
}

/// @func	race_table_foreach_item(table_name, func, args)
/// @param  {string|struct} table_name	The table to iterate over. Can be the name of the table OR the table struct.
/// @param  {function} func				The function to call for each item.
/// @param  {any=undefined} args	Optional. Provide any value or an array or a struct to be passed to the function.
///									This parameter allows you additionally send any parameter to the function while
///									iterating over the table.
/// @desc	Iterates over all items of a table, calling a specified function
///			on each of the items. This method is similar to juju's foreach from SNAP
///			but only sends the name and the struct to the callback.
///			The function will receive 2 parameters:
///			item_name   -> the name of the item
///			item		-> the struct of the item from the table
function race_table_foreach_item(table_name, func, args = undefined) {
	var table = is_struct(table_name) ? table_name : race_get_table(table_name);
    var names = race_table_get_item_names(table);
	var items = race_table_get_items(table);
	for (var i = 0, len = array_length(names); i < len; i++) {
        var name = names[i];
		func(name, struct_get(items, name), args);
	}
}


// ------------------- RACE ITEM GETTERS (TABLE) -------------------
#region item-getters (table)

/// @func	race_get_type(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to retrieve the type
/// @returns {string}			The type of the item.
/// @desc	Gets the type of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			If item_name is not found in the table, undefined is returned.
function race_get_type(table, item_name) {
	return struct_get(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_TYPE);
}

/// @func	race_is_always(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to retrieve the always state
/// @returns {bool}				True, if this item is set to "always", otherwise false.
/// @desc	Gets the always state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			If item_name is not found in the table, undefined is returned.
function race_is_always(table, item_name) {
	return struct_get(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_ALWAYS) == 1;
}

/// @func	race_is_unique(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to retrieve the unique state
/// @returns {bool}				True, if this item is set to "unique", otherwise false.
/// @desc	Gets the unique state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			If item_name is not found in the table, undefined is returned.
function race_is_unique(table, item_name) {
	return struct_get(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_UNIQUE) == 1;
}

/// @func	race_is_enabled(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to retrieve the enabled state
/// @returns {bool}				True, if this item is set to "enabled", otherwise false.
/// @desc	Gets the enabled state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			If item_name is not found in the table, undefined is returned.
function race_is_enabled(table, item_name) {
	return struct_get(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_ENABLED) == 1;
}

/// @func	race_get_chance(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to retrieve the drop chance
/// @returns {real}				The drop chance for this item.
/// @desc	Gets the drop chance of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			If item_name is not found in the table, undefined is returned.
function race_get_chance(table, item_name) {
	return struct_get(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_CHANCE);
}

/// @func	race_get_attribute(table, item_name, attribute_name)
/// @param  {struct} table			The table to search
/// @param  {string} item_name		The item to retrieve the attribute from
/// @param  {string} attribute_name	The attribute to get.
/// @returns {any}	any datatype, you must know what you get! 
///					Custom attributes are not restricted!
/// @desc	Gets a custom named attribute from an item.
///			If the attribute is not found, undefined is returned.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_get_attribute(table, item_name, attribute_name) {
	var item = race_table_get_item(table, item_name);
	if (!variable_struct_exists(item, __RACE_FIELD_ATTRIBUTES))
		return undefined;
	else
		return struct_get(struct_get(item, __RACE_FIELD_ATTRIBUTES), attribute_name);
}

#endregion

// ------------------- RACE ITEM SETTERS (TABLE) -------------------
#region item-setters (table)
/// @func	race_set_type(table, item_name, new_type)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to set the type
/// @param  {string} new_type	The new type to assign
/// @desc	Sets the type of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
///			You can change the type of item to drop at runtime. This might become handy,
///			if your game state requires stronger or simply other enemies to spawn (just an example).
function race_set_type(table, item_name, new_type) {
	struct_set(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_TYPE, new_type);
}

/// @func	race_set_always(table, item_name, new_always)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to set the always state
/// @param  {1|0} new_always		The new always state to assign.
/// @desc	Sets the always state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_set_always(table, item_name, new_always) {
	struct_set(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_ALWAYS, new_always);	
}

/// @func	race_set_unique(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to set the unique state
/// @param  {1|0} new_unique		The new unique state to assign.
/// @desc	Sets the unique state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_set_unique(table, item_name, new_unique) {
	struct_set(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_UNIQUE, new_unique);
}

/// @func	race_set_enabled(table, item_name, new_enabled)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to set the enabled state
/// @param  {1|0} new_enabled	The new enabled state to assign.
/// @desc	Sets the enabled state of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_set_enabled(table, item_name, new_enabled) {
	struct_set(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_ENABLED, new_enabled);
}

/// @func	race_set_chance(table, item_name, new_chance)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to set the drop chance
/// @param  {real} new_chance	The drop chance to set for this item.
/// @desc	Sets the drop chance of an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_set_chance(table, item_name, new_chance) {
	struct_set(struct_get(struct_get(table, __RACE_FIELD_ITEMS), item_name), __RACE_FIELD_CHANCE, new_chance);
}

/// @func	race_set_attribute(table, item_name, attribute_name, value)
/// @param  {struct} table			The table to search
/// @param  {string} item_name		The item to set the attribute
/// @param  {string} attribute_name	The attribute to set
/// @param  {any}    value			The value to assign to this attribute
/// @desc	Sets a custom named attribute on an item.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_set_attribute(table, item_name, attribute_name, value) {
	var item = race_table_get_item(table, item_name);
	var attr;
	if (!variable_struct_exists(item, __RACE_FIELD_ATTRIBUTES)) {
		attr = {};
		struct_set(item, __RACE_FIELD_ATTRIBUTES, attr);
	} else
		attr = struct_get(item, __RACE_FIELD_ATTRIBUTES);
	struct_set(attr, attribute_name, value);
}

#endregion

// ------------------- RACE ITEM GETTERS (ITEM) -------------------
#region item-getters (item)

/// @func	race_item_get_type(item_struct)
/// @param  {struct} item_struct	The item to retrieve the type
/// @returns {string}			The type of the item.
/// @desc	Gets the type of an item.
function race_item_get_type(item_struct) {
	return struct_get(item_struct, __RACE_FIELD_TYPE);
}

/// @func	race_item_is_always(item_struct)
/// @param  {struct} item_struct	The item to retrieve the always state
/// @returns {bool}				True, if this item is set to "always", otherwise false.
/// @desc	Gets the always state of an item.
function race_item_is_always(item_struct) {
	return struct_get(item_struct, __RACE_FIELD_ALWAYS) == 1;
}

/// @func	race_item_is_unique(item_struct)
/// @param  {struct} item_struct	The item to retrieve the unique state
/// @returns {bool}				True, if this item is set to "unique", otherwise false.
/// @desc	Gets the unique state of an item.
function race_item_is_unique(item_struct) {
	return struct_get(item_struct, __RACE_FIELD_UNIQUE) == 1;
}

/// @func	race_item_is_enabled(item_struct)
/// @param  {struct} item_struct	The item to retrieve the enabled state
/// @returns {bool}				True, if this item is set to "enabled", otherwise false.
/// @desc	Gets the enabled state of an item.
function race_item_is_enabled(item_struct) {
	return struct_get(item_struct, __RACE_FIELD_ENABLED) == 1;
}

/// @func	race_item_get_chance(item_struct)
/// @param  {struct} item_struct	The item to retrieve the drop chance
/// @returns {real}				The drop chance for this item.
/// @desc	Gets the drop chance of an item.
function race_item_get_chance(item_struct) {
	return struct_get(item_struct, __RACE_FIELD_CHANCE);
}

/// @func	race_item_get_attribute(item_struct, attribute_name)
/// @param  {struct} item_struct		The item to retrieve the attribute from
/// @param  {string} attribute_name	The attribute to get.
/// @returns {any}	{any} datatype, you must know what you get! 
///					Custom attributes are not restricted!
/// @desc	Gets a custom named attribute from an item.
///			If the attribute is not found, undefined is returned.
function race_item_get_attribute(item_struct, attribute_name) {
	if (!variable_struct_exists(item_struct, __RACE_FIELD_ATTRIBUTES))
		return undefined;
	else
		return struct_get(struct_get(item_struct, __RACE_FIELD_ATTRIBUTES), attribute_name);
}

#endregion

// ------------------- RACE ITEM SETTERS (ITEM) -------------------
#region item-setters (table)
/// @func	race_item_set_type(item_struct, new_type)
/// @param  {struct} item_struct	The item to set the type
/// @param  {string} new_type	The new type to assign
/// @desc	Sets the type of an item.
///			You can change the type of item to drop at runtime. This might become handy,
///			if your game state requires stronger or simply other enemies to spawn (just an example).
function race_item_set_type(item_struct, new_type) {
	struct_set(item_struct, __RACE_FIELD_TYPE, new_type);
}

/// @func	race_item_set_always(item_struct, new_always)
/// @param  {struct} item_struct	The item to set the always state
/// @param  {1|0} new_always		The new always state to assign.
/// @desc	Sets the always state of an item.
function race_item_set_always(item_struct, new_always) {
	struct_set(item_struct, __RACE_FIELD_ALWAYS, new_always);	
}

/// @func	race_item_set_unique(item_struct, new_unique)
/// @param  {struct} item_struct	The item to set the unique state
/// @param  {1|0} new_unique		The new unique state to assign.
/// @desc	Sets the unique state of an item.
function race_item_set_unique(item_struct, new_unique) {
	struct_set(item_struct, __RACE_FIELD_UNIQUE, new_unique);
}

/// @func	race_item_set_enabled(item_struct, new_enabled)
/// @param  {struct} item_struct	The item to set the enabled state
/// @param  {1|0} new_enabled	The new enabled state to assign.
/// @desc	Sets the enabled state of an item.
function race_item_set_enabled(item_struct, new_enabled) {
	struct_set(item_struct, __RACE_FIELD_ENABLED, new_enabled);
}

/// @func	race_item_set_chance(item_struct, new_chance)
/// @param  {struct} item_struct	The item to set the drop chance
/// @param  {real} new_chance	The drop chance to set for this item.
/// @desc	Sets the drop chance of an item.
function race_item_set_chance(item_struct, new_chance) {
	struct_set(item_struct, __RACE_FIELD_CHANCE, new_chance);
}

/// @func	race_item_set_attribute(item_struct, attribute_name, value)
/// @param  {struct} item_struct		The item to set the attribute
/// @param  {string} attribute_name	The attribute to set
/// @param  {any}    value			The value to assign to this attribute
/// @desc	Sets a custom named attribute on an item.
function race_item_set_attribute(item_struct, attribute_name, value) {
	var attr;
	if (!variable_struct_exists(item_struct, __RACE_FIELD_ATTRIBUTES)) {
		attr = {};
		struct_set(item_struct, __RACE_FIELD_ATTRIBUTES, attr);
	} else
		attr = struct_get(item_struct, __RACE_FIELD_ATTRIBUTES);
	struct_set(attr, attribute_name, value);
}

#endregion

// ------------------- RACE TABLE GETTERS -------------------
#region table-getters

/// @func	race_table_get_item(table, item_name)
/// @param  {struct} table		The table to search
/// @param  {string} item_name	The item to get
/// @returns {struct}			The sub-struct containing the item's properties
/// @desc	Gets a single item from the table.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_table_get_item(table, item_name) {
	return struct_get(struct_get(race_get_table(table), __RACE_FIELD_ITEMS), item_name);
}

/// @func	race_table_get_loot_count(table)
/// @param  {struct} table		The table to search
/// @returns {integer}			The loot count of this table.
/// @desc	Gets the loot count of a table.
///			If the table is not found, undefined is returned.
function race_table_get_loot_count(table) {
	return struct_get(race_get_table(table), __RACE_FIELD_LOOT_COUNT);
}

/// @func	race_table_get_items(table)
/// @param  {struct} table		The table to search
/// @returns {struct}			The items sub-struct of the table.
/// @desc	Gets the items contained in a table.
///			If the table is not found, undefined is returned.
function race_table_get_items(table) {
	return struct_get(race_get_table(table), __RACE_FIELD_ITEMS);
}

/// @func	race_table_get_item_names(table)
/// @param  {struct} table		The table to search
/// @returns {array}			A string array containing all item names.
/// @desc	Gets the names of the items contained in a table.
///			NOTE: This method may crash if table does not exist or is not loaded!
function race_table_get_item_names(table) {
	return struct_get_names(struct_get(race_get_table(table), __RACE_FIELD_ITEMS));
}

/// @func	race_table_get_name(table)
/// @param  {struct} table		The table to search
/// @returns {string}			The name of the table.
/// @desc	Gets the name of a table.
///			If the table is not found, undefined is returned.
function race_table_get_name(table) {
	return struct_get(race_get_table(table), __RACE_FIELD_NAME);
}

#endregion

// ------------------- RACE TABLE SETTERS -------------------
#region table-setters

/// @func	race_table_set_loot_count(table, new_loot_count)
/// @param  {string/struct} table		The table to search
/// @param  {int} new_loot_count	The new loot_count to assign.
/// @desc	Sets the loot count of a table.
function race_table_set_loot_count(table, new_loot_count) {
	struct_set(race_get_table(table), __RACE_FIELD_LOOT_COUNT, new_loot_count);
}

/// @func	race_table_set_name(table, new_name)
/// @param  {struct/string} table		The table to search
/// @param  {string} new_name	The new name to assign.
/// @desc	Sets the name of a table.
function race_table_set_name(table, new_name) {
	struct_set(race_get_table(table), __RACE_FIELD_NAME, new_name);
}

#endregion

#region Log-Helpers for callbacks
function __race_log_onQueryStarted(first_query_table, current_query_table, file_name = "") {
	if (!DEBUG_LOG_RACE)
		return;
		
	if (file_name == "")
		vlog($"{MY_NAME}: onQueryStarted: initial='{race_table_get_name(first_query_table)}'; current='{race_table_get_name(current_query_table)}';");
	else
		vlog($"{MY_NAME}: onQueryStarted: initial='{race_table_get_name(first_query_table)}'; current='{race_table_get_name(current_query_table)}'; file='{file_name}';");
}

function __race_log_onQueryHit(item_dropped, first_query_table, current_query_table, file_name = "") {
	if (!DEBUG_LOG_RACE)
		return;

	if (file_name == "")
		vlog($"{MY_NAME}: onQueryHit: item='{item_dropped.name}'; initial='{race_table_get_name(first_query_table)}'; current='{race_table_get_name(current_query_table)}';");
	else
		vlog($"{MY_NAME}: onQueryHit: item='{item_dropped.name}'; initial='{race_table_get_name(first_query_table)}'; current='{race_table_get_name(current_query_table)}'; file='{file_name}'");
}
#endregion

ENSURE_RACE;