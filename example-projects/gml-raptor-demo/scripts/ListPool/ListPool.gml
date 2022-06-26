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
	/// @description	Adds an object to the pool
	/// @param {any} obj	The object to add
	static add = function(obj) {
		if (ds_list_find_index(list, obj) == -1) {
			ds_list_add(list, obj);
			log(sprintf("{0} item added: newSize={1};", name, size()));
		}
	}

	/// @function		size()
	/// @description	Get the number of elements in the pool
	static size = function() {
		return ds_list_size(list);
	}
	
	/// @function		process_all(function_name = "step")
	/// @description	Invokes the named function on each element in the pool.
	///			This is done via self[$ function_name]() and NOT through.
	///			script_execute, which would be very slow.
	///			NOTE: The function is called SCOPED in a with(list[| i])
	///			statement, which means, "self" in the function is the owner
	///			of the function.
	/// @param {string} function_name The function to invoke on each element
	static process_all = function(function_name = "step") {
		for (var i = 0; i < ds_list_size(list); i++) {
			with(list[| i]) self[$ function_name]();
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

}

