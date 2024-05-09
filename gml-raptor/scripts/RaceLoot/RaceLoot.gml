/*
	RACE - The (Ra)ndom (C)ontent (E)ngine.
	Generic loot system.
	
	This script covers the loot drop of a table.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @func					race_result_entry(item_name, data_struct, inst = undefined)
/// @desc				holds one dropped item
/// @param {string} item_name	name of the item 			
/// @param {struct} data_struct	the race table struct of this item (contains unique, enabled, chance,...)
/// @param {instance=undefined} inst		dropped instance (if anything dropped)
function race_result_entry(item_name, data_struct, inst = undefined) constructor {
	name = item_name;
	type = data_struct.type;
	data = (RACE_LOOT_DATA_DEEP_COPY ? SnapDeepCopy(data_struct) : data_struct);
	attributes = variable_struct_exists(data, "attributes") ? data.attributes : {};
	instance = inst;
}

function __race_get_unique_deepcopy_name(basename) {
	var i = 0;
	var newname;
	do {
		newname = string_concat(__RACE_TEMP_TABLE_PREFIX, basename, i);
		i++;
	} until (!race_table_exists(newname));
	return newname;
}

function __race_is_in_unique_list(uniques, table, name) {
	var look_for = string_concat(name, "@", table.name);
	for (var i = 0; i < array_length(uniques); i++;) {
		if (uniques[i] == look_for) 
			return true;
	}
	return false;
};

function __race_addToResult(race_table_object, race_controller, table, result, uniques, name) {
	if (race_is_unique(table, name))
		array_push(uniques, string_concat(name, "@", table.name));
	
	var item = race_table_get_item(table, name);
	var typename = race_item_get_type(item);
	if (string_starts_with(typename, "=")) {
		// go into recursion
		__race_queryRecursive(race_table_object, race_controller, race_get_table(string_skip_start(typename, 1)), result, uniques);
	} else if (string_starts_with(typename, "+")) {
		// deep copy, THEN go into recursion
		var tblname = string_skip_start(typename, 1);
		var deepcopy = SnapDeepCopy(race_get_table(tblname));
		// find a free new name for the deep copy
		var newname = __race_get_unique_deepcopy_name(tblname);
		race_set_type(table, name, "=" + newname);
		struct_set(__RACE_GLOBAL, newname, deepcopy);
		if (DEBUG_LOG_RACE)
			vlog($"Added dynamic global race table: '{newname}'");
		__race_queryRecursive(race_table_object, race_controller, deepcopy, result, uniques);
	} else {
		if (typename != RACE_NULL_ITEM) {
			array_push(result, new race_result_entry(name, item, undefined));
		}
	}
};

function __race_dropItem(race_controller, item_struct, layer_to_drop, pool_name) {
	var itemtype = race_item_get_type(item_struct.data);
	if (DEBUG_LOG_RACE)
		vlog($"Dropping item: object='{itemtype}'; layer='{layer_to_drop}'; pool='{pool_name};");
	var dropx = variable_instance_exists(self, "x") ? x : 0;
	var dropy = variable_instance_exists(self, "y") ? y : 0;
	var drop = undefined;
	if (string_is_empty(pool_name))
		drop = instance_create_layer(dropx ?? 0, dropy ?? 0, layer_to_drop, asset_get_index(itemtype));
	else {
		drop = pool_get_instance(pool_name, asset_get_index(itemtype), layer_to_drop);
		drop.x = dropx ?? 0;
		drop.y = dropy ?? 0;
	}
	RACE_ITEM_DROPPED = item_struct;
	
	var instname;
	with (drop) {
		instname = MY_NAME;
		data.race_data = item_struct;
		onQueryHit(item_struct, RACE_TABLE_QUERIED, RACE_TABLE_CURRENT);
	}
	if (DEBUG_LOG_RACE)
		dlog($"Dropped item: instance='{instname}'; object='{itemtype}'; layer='{layer_to_drop}';");

	if (race_controller != noone) {
		with (race_controller)
			onQueryHit(item_struct, RACE_TABLE_QUERIED, RACE_TABLE_CURRENT);
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
				vlog($"Adding always-enabled item to loot result: {name}");
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
				(!race_is_unique(table, name) || !__race_is_in_unique_list(uniques, table, name))) {
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

function __race_query_internal(race_table_object, race_controller, table_name, drop_on_layer = "", pool_name = "") {
	var rv = undefined;
	var drop_instances = drop_on_layer != "";
			
	// Start the query only if we have a valid table
	if ((is_string(table_name) && race_table_exists(table_name)) || is_struct(table_name)) {
		var unique_drops = [];

		rv = [];

		RACE_TABLE_QUERIED = race_get_table(table_name);

		__race_queryRecursive(race_table_object, race_controller, RACE_TABLE_QUERIED, rv, unique_drops);
		if (drop_instances) {
			var i = 0; repeat(array_length(rv)) {
				rv[i].instance = __race_dropItem(race_controller, rv[i], drop_on_layer, pool_name);
				i++;
			}
		}
	} else 
		if (DEBUG_LOG_RACE)
			elog($"**ERROR** Race table '{table_name}' not loaded or does not exist!");
		
	// query is done, reset globals
	RACE_TABLE_QUERIED = undefined;
	RACE_TABLE_CURRENT = undefined;
	RACE_ITEM_DROPPED = undefined;
	
	return rv;
}

/// @func	race_query(table_name, drop_on_layer = "", pool_name = "")
/// @desc	Perform a loot query on the specified table
/// @returns {array}	Returns the "loot". This is a struct of type race_result_entry.
///			It contains:
///				name		= item name
///				type		= objecttype (asset name)
///				data		= race data_struct (enabled, chance, ...)
///				attributes	= attributes of this item (= data.attributes)
///				instance	= dropped instance (or undefined)
///			All contained instances already exist on the layer.
///			Their onCreate and onQueryHit events have already been executed.
///			If no drop was generated, instance contains undefined.
/// @param  {string} table_name		The race table to query.
/// @param  {string=""} drop_on_layer	Optional. If not supplied or if this is an empty string, the
///			instance variable race_drop_on_layer will be used to determine
///			on which layer to drop the loot. This parameter can override
///			this instance variable (without changing it!) for this one query,
///			in case, this time the items shall drop on another layer.
///			If this is an empty string, no instances will be dropped.
/// @param {string=""} pool_name	Optional. If supplied, objects will be attached to the
///									specified ObjectPool, so less new instances are created.
function race_query(table_name, drop_on_layer = "", pool_name = "") {
	return __race_query_internal(noone, noone, table_name, drop_on_layer, pool_name);
}
	