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

	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
	
*/

#macro __OBJECT_POOLS		global.__object_pools
__OBJECT_POOLS = ds_map_create();

function __get_pool_list(pool_name) {
	if (!ds_map_exists(__OBJECT_POOLS, pool_name)) {
		log(sprintf("Creating new object pool '{0}'", pool_name));
		ds_map_add_list(__OBJECT_POOLS, pool_name, ds_list_create());
	}
	
	return __OBJECT_POOLS[? pool_name];
}

/// @function					pool_get_instance(pool_name, object, at_layer_if_new = undefined)
/// @description				Gets (or creates) an instance for the specified pool.
///								NOTE: To store an instance later in a pool, it must have been
///								created with this function! You can not blindly add "anything" to a pool!
///								In the rare case, you need to manually assign an already existing instance
///								to a pool, use the function pool_assign_instance(...)
///								NOTE: You may supply a numeric value for at_layer_if_new if you want the
///								object to be created on a specific depth instead of a specific layer(name)!
/// @param {string} pool_name
/// @param {object_type} object type to retrieve or create
/// @param {string=undefined} at_layer_if_new layer to send this instance to (only for NEW instances!)
/// @returns {instance}
function pool_get_instance(pool_name, object, at_layer_if_new = undefined) {
	var pool = __get_pool_list(pool_name);
	var i = 0; repeat(ds_list_size(pool)) {
		var rv = pool[| i];
		if (rv.object_index == object) {
			log(sprintf("Found instance of '{0}' in pool '{1}'", object_get_name(object), pool_name));
			instance_activate_object(rv);
			rv.x = x;
			rv.y = y;
			ds_list_delete(pool, i);
			__pool_invoke_activate(rv);
			return rv;
		}
		i++;
	}
	
	log(sprintf("Creating new instance of '{0}' in pool '{1}'", object_get_name(object), pool_name));
	var rv;
	if (at_layer_if_new == undefined || is_string(at_layer_if_new)) {
		var dest_layer = (at_layer_if_new == undefined ? layer : at_layer_if_new);
		rv = instance_create_layer(x,y,dest_layer,object);
	} else {
		rv = instance_create_depth(x,y,at_layer_if_new,object);
	}
	rv.__object_pool_name = pool_name;
	__pool_invoke_activate(rv);
	return rv;
}

/// @function					pool_return_instance(instance = self)
/// @description				Returns a previously fetched instance back into its pool
/// @param {instance=self} 
function pool_return_instance(instance = self) {
	if (variable_instance_exists(instance, "__object_pool_name")) {
		var pool_name = instance.__object_pool_name;
		log(sprintf("Sending instance '{0}' back to pool '{1}'", object_get_name(instance.object_index), pool_name));
		__pool_invoke_deactivate(instance);
		var pool = __get_pool_list(pool_name);
		instance_deactivate_object(instance);
		ds_list_add(pool, instance);
		return;
	}
	log("*ERROR* Tried to return instance to a pool, but this instance was not aquired from a pool!");
}

/// @function					pool_assign_instance(pool_name, instance)
/// @description				Assign an instance to a pool so it can be returned to it.
/// @param {string} pool_name
/// @param {instance} instance
function pool_assign_instance(pool_name, instance) {
	instance.__object_pool_name = pool_name;
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

function __pool_invoke_activate(inst) {
	if (variable_instance_exists(inst, "onPoolActivate"))
		inst.onPoolActivate();
}

function __pool_invoke_deactivate(inst) {
	if (variable_instance_exists(inst, "onPoolDeactivate"))
		inst.onPoolDeactivate();
}