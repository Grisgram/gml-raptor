/*
    RACE - The RAndom Content Engine
	
	A weightened rnd system for GameMaker
	(c)2022- coldrock.games, grisgram@github
*/

show_debug_message("RACE - The (RA)ndom (C)ontent (E)ngine loaded.");

#macro __RACE_CACHE				global.__race_cache
#macro __RACE_CACHE_CURRENT		__RACE_CACHE[$ __cache_name]

#macro ENSURE_RACE				if (!variable_global_exists("__race_cache"))  __RACE_CACHE  = {};
ENSURE_RACE;

#macro __RACE_NULL_ITEM			"<null>"

#macro __RACE_TEMP_TABLE_PREFIX	"##_racetemp_##."

/// @func Race(_filename_without_extension, _add_file_to_cache = false)
/// @desc Create a new random content engine
function Race(_filename = "", _add_file_to_cache = false) constructor {
	construct(Race);
	
	if (is_null(_filename)) return; // if we come from savegame, no file is given
	
	__filename = string_concat(RACE_ROOT_FOLDER, _filename, DATA_FILE_EXTENSION);
	
	tables = {}; // Holds the runtime tables for this Race
	
	if (!file_exists(__filename)) {
		elog($"*ERROR* race table file '{__filename}' not found!");
		return;
	}

	__cache_name	= string_replace(__filename, "/", "_");
	vsgetx(__RACE_CACHE,  __cache_name, {}); // ensure, the file is created in the cache
	
	var tablefile = file_read_struct(__filename, FILE_CRYPT_KEY, _add_file_to_cache);
	
	if (tablefile != undefined) {
		var names = struct_get_names(tablefile);
		var tablecnt = array_length(names);
			
		if (DEBUG_LOG_RACE)
			ilog($"Successfully loaded {tablecnt} table(s) from '{__filename}'");
		for (var i = 0; i < tablecnt; i++) {
			var name = names[@i];
			var table = struct_get(tablefile, name);
			__put_to_cache(name, table);
			add_table(__clone_from_cache(name));
		}
	} else
		elog($"*ERROR* Failed to load race table file '{__filename}'!")
	
	
	/// @func __is_in_cache(_name)
	static __is_in_cache = function(_name) {
		return vsget(__RACE_CACHE_CURRENT, _name) != undefined;
	}
	
	/// @func __put_to_cache(_name, _table)
	static __put_to_cache = function(_name, _table) {
		struct_set(__RACE_CACHE_CURRENT, _name, _table);
	}
	
	/// @func __clone_from_cache(_name)
	static __clone_from_cache = function(_name) {
		var cpy = SnapDeepCopy(vsget(__RACE_CACHE_CURRENT, _name));
		return new RaceTable(self, _name, cpy);
	}
	
	/// @func add_table( _race_loot_table, _overwrite_if_exists = true)
	/// @desc Add a class instance of type RaceLootTable to the tables of this Race
	static add_table = function( _race_loot_table, _overwrite_if_exists = true) {
		if (_overwrite_if_exists || vsget(tables, _race_loot_table.name) == undefined) {
			_race_loot_table.race = self;
			struct_set(tables, _race_loot_table.name, _race_loot_table);
		} else {
			elog($"*ERROR* add_table('{_race_loot_table.name}') failed. A table with that name already exists!");
		}
		return self;
	}
	
	/// @func get_table(_name)
	static get_table = function(_name) {
		return vsget(tables, _name);
	}
	
	/// @func remove_table(_name, _clear_global_cache = false)
	/// @desc Remove the specified table from this Race
	static remove_table = function(_name, _clear_global_cache = false) {
		if (table_exists(_name)) {
			tables[$ _name].race = undefined; // clear the circular pointer
			struct_remove(tables, _name);
			if (_clear_global_cache)
				struct_remove(__RACE_CACHE_CURRENT, _name);
			if (DEBUG_LOG_RACE)
				vlog($"Race table '{_name}' has been removed");
		}
		return self;
	}
	
	/// @func reset_table(_name, _recursive = true)
	/// @desc Reset the specified table to its original state it had, when it was loaded from the file
	static reset_table = function(_name, _recursive = true) {
		if (string_starts_with(_name, __RACE_TEMP_TABLE_PREFIX)) {
			elog($"*ERROR* Cloned temp race table '{_name}' can not be reset!");
			return self;
		}
		
		if (!__is_in_cache(_name)) {
			elog($"*ERROR* Manually added race table '{_name}' can not be reset!");
			return self;
		}

		var items = tables[$ _name].items;
		var names = struct_get_names(items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@ i];
			var typename = items[$ name].type;
			if (_recursive && string_starts_with(typename, "=")) 
				reset_table(string_skip_start(typename, 1), _recursive);
			if (string_starts_with(name, __RACE_TEMP_TABLE_PREFIX))
				struct_remove(tables, name);
		}
		
		add_table(__clone_from_cache(_name));
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{_name}' has been reset{(_recursive ? " (recursive)" : "")}");

		return self;
	}

	/// @func __get_unique_clone_name(_name)
	static __get_unique_clone_name = function(_name) {
		var i = 0;
		var newname;
		do {
			newname = string_concat(__RACE_TEMP_TABLE_PREFIX, _name, i);
			i++;
		} until (!table_exists(newname));
		return newname;
	}
	
	/// @func clone_table(_name)
	/// @desc Clones the specified table to a TEMP table with a unique name. 
	///		  This new table is returned and you can get the name from the .name property of the table.
	static clone_table = function(_name) {
		var newname = __get_unique_clone_name(_name);
		// remove the race pointer to avoid endless loop (circular reference)
		tables[$ _name].race = undefined;
		var cpy = SnapDeepCopy(tables[$ _name]);
		tables[$ _name].race = self;
		
		cpy.race = self;
		cpy.name = newname;
		add_table(cpy);
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{_name}' has been cloned into '{newname}'");
		return cpy;
	}
	
	/// @func table_exists(_name)
	/// @desc Checks whether a table with the specified name exists in this Race
	static table_exists = function(_name) {
		return vsget(tables, _name) != undefined;
	}
	
	/// @func clear(_clear_global_cache = false)
	/// @desc Removes all tables from this Race and, optionally, from the global cache
	static clear = function(_clear_global_cache = false) {
		var names = struct_get_names(tables);
		for (var i = 0, len = array_length(names); i < len; i++)
			remove_table(names[@ i], _clear_global_cache);
	}

	/// @func	query_table(_name, _layer_name_or_depth = undefined, _pool_name = "")
	/// @desc	Perform a loot query on the specified table
	/// @returns {array}	Returns the "loot". This is an array of RaceResult instances.
	///			It contains:
	///				name		= item name
	///				type		= objecttype (asset name)
	///				data		= race data_struct (enabled, chance, ...)
	///				attributes	= attributes of this item (= data.attributes)
	///				instance	= dropped instance (or undefined)
	///			All contained instances already exist on the layer.
	///			Their onCreate and onQueryHit events have already been executed.
	///			If no drop was generated, instance contains undefined.
	/// @param  {string} _name		The race table to query
	/// @param  {string=""} _layer_name_or_depth	Optional. 
	///			If not supplied, no items will be dropped by the query and all "instance"
	///			members of the returned RaceItems will be undefined.
	///			LOOT IS STILL GENERATED! There are just no items spawned.
	/// @param {string=""} pool_name	Optional. If supplied, objects will be attached to the
	///									specified ObjectPool, so less new instances are created.
	static query_table = function(_name, _layer_name_or_depth = undefined, _pool_name = "") {
		return tables[$ _name].query(_layer_name_or_depth, _pool_name);
	}
	
	toString = function() {
		return $"Race '{__filename}'";
	}
}