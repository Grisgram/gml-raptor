/// @description load table from file

event_inherited();

/*
	If race_table_file is set, this event will try to load the specified file
	(if not already loaded) and store the contents in the __RACE_GLOBAL struct.

	Using this object is totally optional!
	You may as well call race_load_file for yourself in the room creation code or on game start!
	It was made, to keep room creation code clean, maybe you need to adapt the loaded tables during runtime (step),
	so this object allows you runtime control of loot tables of the current room, but it is not *required* for race to work.
*/

if (race_table_file_name != "")
	race_load_file(race_table_file_name);

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
	__race_log_onQueryStarted(first_query_table, current_query_table, race_table_file_name);
}

/// @function					onQueryHit(first_query_table, current_query_table, item_dropped)
/// @description				A query started in one of the tables of this controller
/// @param {race_table} first_query_table		holds the struct of the topmost table, that started the current query
/// @param {race_table} current_query_table		holds the struct of the table where the dropped item here is contained in
/// @param {race_item} 	item_dropped			holds the race struct (race_result_entry) that just dropped.
onQueryHit = function(first_query_table, current_query_table, item_dropped) {
	__race_log_onQueryHit(first_query_table, current_query_table, item_dropped, race_table_file_name);
}
#endregion
