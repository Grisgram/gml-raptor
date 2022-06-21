/*
    The ListPool is a simple ds_list based class with an add and remove method.
	It is used by self-managing script classes like Animation and StateMachine
	that manage themselves in lists to be processed by controller objects, like
	the RoomController (which controls animations and state machines).
	
	NOTE: To avoid memory leaks, you MUST call the destroy() method when you no
	longer need this ListPool.
*/

function ListPool(_name = "listPool") constructor {
	name = _name;
	list = ds_list_create();

	static remove = function(obj) {
		var idx = ds_list_find_index(list, obj);
		if (idx != -1)
			ds_list_delete(list, idx);
	}
	
	static add = function(obj) {
		if (ds_list_find_index(list, obj) == -1) {
			ds_list_add(list, obj);
			log(sprintf("{0} item added: newSize={1};", name, size()));
		}
	}

	static size = function() {
		return ds_list_size(list);
	}
	
	static process_all = function(function_name = "step") {
		for (var i = 0; i < ds_list_size(list); i++) {
			with(list[| i]) self[$ function_name]();
		}
	}
	
	static clear = function() {
		ds_list_clear(list);
	}
	
	static destroy = function() {
		ds_list_destroy(list);
	}

}