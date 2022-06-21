/// @description onQueryHit default implementation

event_inherited();

#region RACE-onQuery... callbacks
/*
	--- USAGE OF THE onQuery... FUNCTIONS ---
	When a query to a table hits this object, this event gets invoked after onCreate.
	By default, the item drops at the x/y position of the RaceTableObject 
	that started the query (a chest or something). 
	Use this event to correct the position, if you need it to appear anywhere else and 
	the logic of the object itself does not cover that.

	The _table parameters MAY hold the same value, but in a recursive scenario, they might be different.
*/

// data.race_data holds the entire data from the race table.
// will be assigned by the __race_dropItem function
// ATTENTION: THIS VALUE IS NOT AVAILABLE IN THE CREATE EVENT!
// (The object needs to be created before we can assign a value to data.race_data,
// but the value is already available when onQueryHit gets invoked)
data.race_data = undefined;

/// @function					onQueryHit(first_query_table, current_query_table, item_dropped)
/// @description				This item just got hit by a query
/// @param {race_table} first_query_table		holds the struct of the topmost table, that started the current query
/// @param {race_table} current_query_table		holds the struct of the table where the dropped item here is contained in
/// @param {race_item} 	item_dropped			holds the race struct (race_result_entry) that just dropped.
onQueryHit = function(first_query_table, current_query_table, item_dropped) {
	__race_log_onQueryHit(first_query_table, current_query_table, item_dropped);
}
#endregion
