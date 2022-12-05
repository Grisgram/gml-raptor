/*
    The ListPool is a simple ds_list based class with an add and remove method.
	It is used by self-managing script classes like Animation and StateMachine
	that manage themselves in lists to be processed by controller objects, like
	the RoomController (which controls animations and state machines).
	
	NOTE: To avoid memory leaks, you MUST call the destroy() method when you no
	longer need this ListPool.
*/

/// @function			ListPool(_name = "listPool")
/// @description		Create a new ListPool. You must destroy this due to the use
///				of a ds_list internally or you risk a memory leak!
/// @param {string} _name	The name of the pool. For logging purposes only.
function ListPool(_name = "listPool") constructor {
	name = _name;
	list = ds_list_create();

	/// @function		remove(obj)
	/// @description	Removes an object from the pool
	/// @param {any} obj	The object to remove
	static remove = function(obj) {
		var idx = ds_list_find_index(list, obj);
		if (idx != -1)
			ds_list_delete(list, idx);
	}
	
	/// @function		add(obj)
	/// @description	Adds an object to the pool (if it is not already contained)
	/// @param {any} obj	The object to add
	static add = function(obj) {
		if (ds_list_find_index(list, obj) == -1) {
			ds_list_add(list, obj);
			if (DEBUG_LOG_LIST_POOLS)
				log(sprintf("{0} item added: newSize={1};", name, size()));
		}
	}

	/// @function		size()
	/// @description	Get the number of elements in the pool
	static size = function() {
		return ds_list_size(list);
	}
	
	/// @function		process_all(function_name = "step", ...)
	/// @description	Invokes the named function on each element in the pool
	///					and forwards any additional parameters specified.
	///					This is done via self[$ function_name]() and NOT through
	///					script_execute, which would be very slow.
	///					NOTE: The function is called SCOPED in a with(list[| i])
	///					statement, which means, "self" in the function is the owner
	///					of the function.
	/// @param {string} function_name The function to invoke on each element
	/// @param {any...} up to 15 additional parameters that will be forwarded to the invoked function.
	static process_all = function(function_name = "step") {
		switch (argument_count) {
			case  1: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](); break;
			case  2: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1]); break;
			case  3: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2]); break;
			case  4: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3]); break;
			case  5: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4]); break;
			case  6: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: for (var i = 0; i < ds_list_size(list); i++) with(list[| i]) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	
	/// @function		clear()
	/// @description	Remove all elements from the pool
	static clear = function() {
		ds_list_clear(list);
	}
	
	/// @function		destroy()
	/// @description	Destroy the ds_list that is used internally
	static destroy = function() {
		ds_list_destroy(list);
	}

	/// @function		dump()
	/// @description	For debugging purposes. Prints all objects to the console
	static dump = function() {
		var i = 0;
		log(sprintf("---- LIST POOL '{0}' DUMP START ----", name));
		repeat(ds_list_size(list)) {
			var item = ds_list_find_value(list, i);
			log(sprintf("#{0}: {1}", i, item));
			i++;
		}
		log(sprintf("---- LIST POOL '{0}' DUMP  END  ----", name));
	}

}

/// @function		__listpool_get_all_owner_objects(_listpool, owner)
/// @description	INTERNAL FUNCTION. Retrieves all objects from a listpool for
///					a specified owner. Crashes if the objects do not have an "owner" member!
function __listpool_get_all_owner_objects(_listpool, owner) {
	var rv = [];

	var lst = _listpool.list;
	for (var i = 0; i < ds_list_size(lst); i++) {
		var item = lst[| i];
		if (item.owner == owner)
			array_push(rv, item);
	}

	return rv;
}

