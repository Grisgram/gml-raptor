/*
    RACE - The RAndom Content Engine
	
	A weightened rnd system for GameMaker
	(c)2022- coldrock.games, grisgram@github
*/

show_debug_message("RACE - The (RA)ndom (C)ontent (E)ngine loaded.");

#macro ENSURE_RACE				if (!variable_global_exists("__race_tables")) __RACE_GLOBAL = {}; \
								if (!variable_global_exists("__race_cache"))  __RACE_CACHE  = {};
ENSURE_RACE;

#macro __RACE_TEMP_TABLE_PREFIX	"##_racetemp_##."

/// @func Race(_filename_without_extension)
/// @desc Create a new random content engine
function Race(_filename) constructor {
	construct(Race);
	
	__filename = string_concat(RACE_ROOT_FOLDER, _filename, GAME_FILE_EXTENSION);
	__table_cache = {}; // Holds the original structs from the file to be able to reset
	
	tables = {}; // Holds the runtime tables for this Race
	
	if (!file_exists(__filename)) {
		elog($"*ERROR* race table file '{__filename}' not found!");
		return;
	}
	
	var tablefile = file_read_struct(__filename, FILE_CRYPT_KEY, true);
	
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
	
	/// @func __put_to_cache(_name, _table)
	static __put_to_cache = function(_name, _table) {
		struct_set(__table_cache, _name, _table);
	}
	
	/// @func __clone_from_cache(_name)
	static __clone_from_cache = function(_name) {
		var cpy = SnapDeepCopy(vsget(__table_cache, _name));
		return new RaceLootTable(self, _name, cpy);
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
	
	/// @func remove_table(_name)
	/// @desc Remove the specified table from this Race
	static remove_table = function(_name) {
		if (table_exists(_name)) {
			struct_remove(tables, _name);
			struct_remove(__table_cache, _name);
			if (DEBUG_LOG_RACE)
				vlog($"Race table '{_name}' has been removed");
		}
		return self;
	}
	
	/// @func reset_table(_name, _recursive = false)
	/// @desc Reset the specified table to its original state it had, when it was loaded from the file
	static reset_table = function(_name, _recursive = false) {
		var items = tables[$ _name].data.items;
		var names = struct_get_names(items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@ i];
			if (_recursive && string_starts_with(name, "=")) 
				reset_table(string_skip_start(name, 1), _recursive);
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
	/// @desc Clones the specified table to a TEMP table with a unique name. This new name is returned.
	static clone_table = function(_name) {
		var newname = __get_unique_clone_name(_name);
		var cpy = SnapDeepCopy(tables[$ _name]);
		cpy.name = newname;
		add_table(cpy);
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{_name}' has been cloned into '{newname}'");
		return newname;
	}
	
	/// @func table_exists(_name)
	/// @desc Checks whether a table with the specified name exists in this Race
	static table_exists = function(_name) {
		return vsget(tables, _name) != undefined;
	}
	
	toString = function() {
		return $"Race '{__filename}'";
	}
}