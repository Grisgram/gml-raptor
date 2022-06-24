/// @description You MUST call this when inheriting!

event_inherited();

#region RACE-onQuery... callbacks
/*
	--- USAGE OF THE onQuery... FUNCTIONS ---
	To have this event triggered, a RaceTableObject must have set this instance in its
	"race_controller" variable.

	Whenever this table starts a query, it will invoke the onQueryStarted event on its controller.

	Whenever a query of a table hits (and instantiates) a RaceObject, 
	it will invoke the onQueryHit event on its controller.

	Treat this as kind of global watchdog event, where ALL tables 
	(that have set this RaceController as their controller) will report their query start.
	Can be used for centralized logging or counting up achievement states, whatever.
	The _table parameters MAY hold the same value, but in a recursive scenario, they might be different.
	
	NOTE: In recursive scenarios (tables containing subtables) this event gets invoked only ONCE for the
	topmost table of the tree. For subtables, no event is invoked.
*/

/// @function					onQueryStarted(first_query_table, current_query_table)
/// @description				A query started in one of the tables of this controller
/// @param {race_table} first_query_table		holds the struct of the topmost table, that started the current query
/// @param {race_table} current_query_table		holds the struct of the table where the dropped item here is contained in
onQueryStarted = function(first_query_table, current_query_table) {
	__race_log_onQueryStarted(first_query_table, current_query_table);
}

/// @function					onQueryHit(first_query_table, current_query_table, item_dropped)
/// @description				A query started in one of the tables of this controller
/// @param {race_table} first_query_table		holds the struct of the topmost table, that started the current query
/// @param {race_table} current_query_table		holds the struct of the table where the dropped item here is contained in
/// @param {race_item} 	item_dropped			holds the race struct (race_result_entry) that just dropped.
onQueryHit = function(first_query_table, current_query_table, item_dropped) {
	__race_log_onQueryHit(first_query_table, current_query_table, item_dropped);
}
#endregion

/// @function		set_table(race_table_name)
/// @description	Loads a race table from __RACE_GLOBAL.
///					This can also be achieved by setting the race_controller and race_table_name
///					variables of this object in the designer.
/// @param {string} table_name			The table to load from the controller
set_table = function(table_name) {
	if (!race_table_exists(table_name)) {
		log(MY_NAME + " could not find race table '" + table_name + "'. Make sure, it is loaded or check room instance creation order. RaceController must be instantiated first!");
		return;
	}
	
	log(MY_NAME + " received race table to use: raceTable='" + table_name + "';");
	race_table_name = table_name;
	race_table = race_get_table(table_name);
}

/// @function						query(drop_on_layer = "")
/// @description					Performs a loot drop on this table.
/// @returns {array}				Returns the "loot". This is a struct of type race_result_entry.
///									It contains:
///										name		= item name
///										type		= objecttype (asset name)
///										data		= race data_struct (enabled, chance, ...)
///										attributes	= attributes of this item (= data.attributes)
///										instance	= dropped instance (or undefined)
///									All contained instances already exist on the layer.
///									Their onCreate and onQueryHit events have already been executed.
///									If no drop was generated, instance contains undefined.
/// @param {string=""} drop_on_layer	Optional. If not supplied or if this is an empty string, the
///									instance variable race_drop_on_layer will be used to determine
///									on which layer to drop the loot. This parameter can override
///									this instance variable (without changing it!) for this one query,
///									in case, this time the items shall drop on another layer.
///									If this is an empty string, no instances will be dropped.
query = function(drop_on_layer = "") {
	var layername = drop_on_layer == "" ? race_drop_on_layer : drop_on_layer;
	return __race_query_internal(self, race_controller, race_table_name, layername);
}

// this variable holds the assigned table
race_table = undefined;

// if not table name assigned, we can not autoload. user must call set_table manually.
if (race_table_name != "")
	set_table(race_table_name);
