/*
	RACE - The (Ra)ndom (C)ontent (E)ngine.
	Generic loot system.
	
	This script covers the loot drop of a table.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function					race_result_entry(item_name, data_struct, inst = undefined)
/// @description				holds one dropped item
/// @param {string} item_name	name of the item 			
/// @param {struct} data_struct	the race table struct of this item (contains unique, enabled, chance,...)
/// @param {instance=undefined} inst		dropped instance (if anything dropped)
function race_result_entry(item_name, data_struct, inst = undefined) constructor {
	name = item_name;
	type = data_struct.type;
	data = (RACE_LOOT_DATA_DEEP_COPY ? snap_deep_copy(data_struct) : data_struct);
	attributes = variable_struct_exists(data, "attributes") ? data.attributes : {};
	instance = inst;
}

function __race_get_unique_deepcopy_name(basename) {
	var i = 0;
	var newname;
	do {
		newname = __RACE_TEMP_TABLE_PREFIX + basename + string(i);
		i++;
	} until (!race_table_exists(newname));
	return newname;
}

function __race_is_in_unique_list(uniques, name) {
	for (var i = 0; i < array_length(uniques); i++;) {
		if (uniques[i] == name) 
			return true;
	}
	return false;
};

function __race_addToResult(race_table_object, race_controller, table, result, uniques, name) {
	if (race_is_unique(table, name))
		array_push(uniques, name);
	
	var item = race_table_get_item(table, name);
	var typename = race_item_get_type(item);
	if (string_starts_with(typename, "=")) {
		// go into recursion
		__race_queryRecursive(race_table_object, race_controller, race_get_table(string_skip_start(typename, 1)), result, uniques);
	} else if (string_starts_with(typename, "+")) {
		// deep copy, THEN go into recursion
		var tblname = string_skip_start(typename, 1);
		var deepcopy = snap_deep_copy(race_get_table(tblname));
		// find a free new name for the deep copy
		var newname = __race_get_unique_deepcopy_name(tblname);
		race_set_type(table, name, "=" + newname);
		variable_struct_set(__RACE_GLOBAL, newname, deepcopy);
		if (DEBUG_LOG_RACE)
			log("Added dynamic global race table: '" + newname + "'");
		__race_queryRecursive(race_table_object, race_controller, deepcopy, result, uniques);
	} else {
		if (typename != __RACE_NULL_ITEM)
			array_push(result, new race_result_entry(name, item, undefined));
	}
};

function __race_dropItem(race_controller, item_struct, layer_to_drop) {
	var itemtype = race_item_get_type(item_struct.data);
	if (DEBUG_LOG_RACE)
		log(sprintf("Dropping item: object='{0}'; layer='{1}';", itemtype, layer_to_drop));
	var dropx = variable_instance_exists(self, "x") ? x : 0;
	var dropy = variable_instance_exists(self, "y") ? y : 0;
	var drop = instance_create_layer(dropx ?? 0, dropy ?? 0, layer_to_drop, asset_get_index(itemtype));
	RACE_ITEM_DROPPED = item_struct;
	
	var instname;
	with (drop) {
		instname = MY_NAME;
		data.race_data = item_struct;
		onQueryHit(RACE_TABLE_QUERIED, RACE_TABLE_CURRENT, item_struct);
	}
	if (DEBUG_LOG_RACE)
		log(sprintf("Dropped item: instance='{0}'; object='{1}'; layer='{2}';", instname, itemtype, layer_to_drop));

	if (race_controller != noone) {
		with (race_controller)
			onQueryHit(RACE_TABLE_QUERIED, RACE_TABLE_CURRENT, item_struct);
	}
	RACE_ITEM_DROPPED = undefined;
	return drop;
};

function __race_queryRecursive(race_table_object, race_controller, table, result, uniques) {
	RACE_TABLE_CURRENT = table;
	// Push onQueryStarted only on the top level table (not in the recursions)
	if (RACE_TABLE_CURRENT == RACE_TABLE_QUERIED) {
		if (race_controller != noone) {
			with (race_controller)
				onQueryStarted(RACE_TABLE_QUERIED, RACE_TABLE_CURRENT);
		}
	
		if (race_table_object != noone) {
			with(race_table_object)
				onQueryStarted(RACE_TABLE_QUERIED, RACE_TABLE_CURRENT);
		}
	}
	
	// first, all enabled elements that are set to "always" will be part of the drop
	var names = race_table_get_item_names(table);
	var always_enabled_count = 0;
	for (var i = 0; i < array_length(names); i++;) {
		var name = names[i];
		if (race_is_enabled(table, name) && race_is_always(table, name)) {
			if (DEBUG_LOG_RACE)
				log("Adding always-enabled item to loot result: " + name);
			always_enabled_count++;
			__race_addToResult(race_table_object, race_controller, table, result, uniques, name);
		}
	}
	// calculate the real drop count 
	// (this is, the remaining items to drop after all always-enabled have been added)
	var real_drop_count = race_table_get_loot_count(table) - always_enabled_count;
	
	for (var drop_i = 0; drop_i < real_drop_count; drop_i++) {
		// Find all items that CAN drop now
		// (that are all those that are enabled but NOT always, have a chance > 0 and
		// are EITHER not unique OR unique but not already part of the uniques list)
		var dropables = [];
		var dropable_count = 0;
		for (var i = 0; i < array_length(names); i++;) {
			var name = names[i];
			if (race_is_enabled(table, name) && 
				(!race_is_always(table, name) || !race_is_unique(table, name)) && 
				race_get_chance(table, name) > 0 &&
				(!race_is_unique(table, name) || !__race_is_in_unique_list(uniques, name))) {
					dropables[dropable_count] = name;
					dropable_count++;
			}
		}
		
		// get the chance sum (that is the sum of all chances of all dropable items)
		var chance_sum = 0.0;
		for (var i = 0; i < array_length(dropables); i++;) {
			chance_sum += race_get_chance(table, dropables[i]);
		}
		
		// this value determines, which item will drop!
		var hit_value = random(chance_sum);
		var running_value = 0;
		for (var i = 0; i < array_length(dropables); i++;) {
			var name = dropables[i];
			running_value += race_get_chance(table, name);
			if (hit_value < running_value) {
				__race_addToResult(race_table_object, race_controller, table, result, uniques, name);
				break;
			}
		}
	}
}

function __race_query_internal(race_table_object, race_controller, table_name, drop_on_layer = "") {
	var rv = undefined;
	var drop_instances = drop_on_layer != "";
			
	// Start the query only if we have a valid table
	if (race_table_exists(table_name)) {
		var unique_drops = [];

		rv = [];

		RACE_TABLE_QUERIED = race_get_table(table_name);

		__race_queryRecursive(race_table_object, race_controller, RACE_TABLE_QUERIED, rv, unique_drops);
		if (drop_instances) {
			var i = 0; repeat(array_length(rv)) {
				rv[i].instance = __race_dropItem(race_controller, rv[i], drop_on_layer);
				i++;
			}
		}
	} else 
		if (DEBUG_LOG_RACE)
			log("*ERROR* Race table '" + table_name + "' not loaded or does not exist!");
		
	// query is done, reset globals
	RACE_TABLE_QUERIED = undefined;
	RACE_TABLE_CURRENT = undefined;
	RACE_ITEM_DROPPED = undefined;
	
	return rv;
}

function race_query(table_name, drop_on_layer = "") {
	return __race_query_internal(noone, noone, table_name, drop_on_layer);
}
	