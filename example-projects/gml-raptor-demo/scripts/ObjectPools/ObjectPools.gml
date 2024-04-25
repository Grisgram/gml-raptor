/*

	Object pools are a way to avoid creating hundreds or even thousands of objects over
	and over again.
	You request an object from a pool and return it to the pool when you no longer need it.
	So, new instances are only created, when no free instances in the pool exist.
	
	You create a pool by simply specifying (or using the first time) a name.
	Each pool can in theory hold any object, but it is recommended that you set up "theme pools",
	like "Bullets", "Explosions", ... because you then have a finer control over destroyed objects
	when you clear/delete a pool.

	Activation/Deactivation events (callbacks)
	------------------------------------------
	If you want your pooled instances to get informed when they got activated or are about
	to become deactivated, you can declare these instance variable functions:
	onPoolActivate   = function() {...}
	onPoolDeactivate = function() {...}
	
	The object pool will invoke those members, if they exist after activation and
	before deactivation respectively.

	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
	
*/

#macro __POOL_SOURCE_NAME				"__object_pool_name"
#macro __POOL_ACTIVATE_RAPTOR_NAME		"__raptor_onPoolActivate"
#macro __POOL_DEACTIVATE_RAPTOR_NAME	"__raptor_onPoolDeactivate"
#macro __POOL_ACTIVATE_NAME				"onPoolActivate"
#macro __POOL_DEACTIVATE_NAME			"onPoolDeactivate"

#macro __OBJECT_POOLS					global.__object_pools
__OBJECT_POOLS = ds_map_create();

function __get_pool_list(pool_name) {
	if (!ds_map_exists(__OBJECT_POOLS, pool_name)) {
		if (DEBUG_LOG_OBJECT_POOLS)
			dlog($"Creating new object pool '{pool_name}'");
		ds_map_add_list(__OBJECT_POOLS, pool_name, ds_list_create());
	}
	
	return __OBJECT_POOLS[? pool_name];
}

/// @function					pool_get_instance(pool_name, object, layer_name_or_depth_if_new)
/// @description				Gets (or creates) an instance for the specified pool.
///								NOTE: To store an instance later in a pool, it must have been
///								created with this function! You can not blindly add "anything" to a pool!
///								In the rare case, you need to manually assign an already existing instance
///								to a pool, use the function pool_assign_instance(...)
///								NOTE: You may supply a numeric value for at_layer_if_new if you want the
///								object to be created on a specific depth instead of a specific layer(name)!
/// @param {string} pool_name
/// @param {object_type} object type to retrieve or create
/// @param {string|layer_id} layer_name_or_depth_if_new layer to send this instance to (only for NEW instances!)
/// @returns {instance}
function pool_get_instance(pool_name, object, layer_name_or_depth_if_new) {
	var pool = __get_pool_list(pool_name);
	var i = 0; repeat(ds_list_size(pool)) {
		var rv = pool[| i];
		if (rv.object_index == object) {
			if (DEBUG_LOG_OBJECT_POOLS)
				vlog($"Found instance of '{object_get_name(object)}' in pool '{pool_name}'");
			instance_activate_object(rv);
			var xp = vsget(self, "x", 0) ?? 0;
			var yp = vsget(self, "y", 0) ?? 0;
			with(rv) {
				x = xp;
				y = yp;
			}
			ds_list_delete(pool, i);
			__pool_invoke_activate(rv);
			return rv;
		}
		i++;
	}
	
	if (DEBUG_LOG_OBJECT_POOLS)
		vlog($"Creating new instance of '{object_get_name(object)}' in pool '{pool_name}'");
	var xp = vsget(self, "x", 0) ?? 0;
	var yp = vsget(self, "y", 0) ?? 0;
	var rv = instance_create(xp, yp, layer_name_or_depth_if_new, object);
	struct_set(rv, __POOL_SOURCE_NAME, pool_name);
	__pool_invoke_activate(rv);
	return rv;
}

/// @function					pool_return_instance(instance = self)
/// @description				Returns a previously fetched instance back into its pool
/// @param {instance=self} 
function pool_return_instance(instance = self) {
	if (vsget(instance, __POOL_SOURCE_NAME) != undefined) {
		var pool_name = instance[$ __POOL_SOURCE_NAME];
		with (instance)
			if (DEBUG_LOG_OBJECT_POOLS)
				vlog($"Sending instance '{MY_NAME}' back to pool '{pool_name}'");
		__pool_invoke_deactivate(instance);
		var pool = __get_pool_list(pool_name);
		instance_deactivate_object(instance);
		ds_list_add(pool, instance);
		return;
	}
	elog($"**ERROR** Tried to return instance to a pool, but this instance was not aquired from a pool!");
}

/// @function					pool_assign_instance(pool_name, instance)
/// @description				Assign an instance to a pool so it can be returned to it.
/// @param {string} pool_name
/// @param {instance} instance
function pool_assign_instance(pool_name, instance) {
	struct_set(instance, __POOL_SOURCE_NAME, pool_name);
}

/// @function		pool_get_size(pool_name)
/// @description	Gets current size of the pool
function pool_get_size(pool_name) {
	return ds_list_size(__get_pool_list(pool_name));
}

/// @function					pool_clear(pool_name)
/// @description				Clears a named pool and destroys all instances contained
/// @param {string} pool_name
function pool_clear(pool_name) {
	var pool = __get_pool_list(pool_name);
	var i = 0; repeat(ds_list_size(pool)) {
		var inst = pool[| i++];
		instance_activate_object(inst);
		instance_destroy(inst);
	}
	ds_list_clear(pool);
}

/// @function		pool_dump_all()
/// @description	Dumps the names and sizes of all registered pools to the log
function pool_dump_all() {
	var i = 0;
	ilog($"[--- OBJECT POOLS DUMP START ---]");
	var keys = ds_map_keys_to_array(__OBJECT_POOLS);
	array_sort(keys, true);
	array_foreach(keys, function(item) {
		ilog($"{pool_get_size(item)} in {item}");
	});
	ilog($"[--- OBJECT POOLS DUMP  END  ---]");
}

/// @function		pool_clear_all()
/// @description	Clear all pools. Use this when leaving the room.
///					NOTE: The ROOMCONTROLLER automatically does this for you in the RoomEnd event
function pool_clear_all() {
	ds_map_destroy(__OBJECT_POOLS);
	__OBJECT_POOLS = ds_map_create();
}

function __pool_invoke_activate(inst) {
	with (inst) {
		__statemachine_pause_all(self, false);
		invoke_if_exists(self, __POOL_ACTIVATE_RAPTOR_NAME);
		invoke_if_exists(self, __POOL_ACTIVATE_NAME);
	}
}

function __pool_invoke_deactivate(inst) {
	with (inst) {
		__statemachine_pause_all(self, true);
		animation_abort_all(self);
		invoke_if_exists(self, __POOL_DEACTIVATE_RAPTOR_NAME);
		invoke_if_exists(self, __POOL_DEACTIVATE_NAME);
	}
}