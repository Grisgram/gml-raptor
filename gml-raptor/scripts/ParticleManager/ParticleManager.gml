/*
	Create a particle manager in a Controller Object (like a RoomController)
	Specify the layer name where particles shall be created (that's the layer, the particle system will use).
	
	NOTE: You MUST call the cleanup function in the CleanUp event of the controller to avoid memory leaks!
	
*/

#macro __POOL_EMITTERS		"__particle_emitter_pool"

/// @function					ParticleManager(particle_layer_name)
/// @description				Helps in organizing particles for a level
/// @param {string} particle_layer_name
/// @returns {struct} ParticleManager
function ParticleManager(particle_layer_name) constructor {
	log(sprintf("ParticleManager created for layer '{0}'", particle_layer_name));
	system = part_system_create_layer(particle_layer_name, false);
	
	__emitter_object	= ParticleEmitter;
	__particle_types	= {};
	__emitters			= {};
	__emitter_ranges	= {};
	
	__buffered_delta	= {};
	__buffered_target	= {};
	
	/// @function		set_emitter_object(_emitter_object)
	/// @description	Set an object type to use when attaching emitters (default = ParticleEmitter)
	static set_emitter_object = function(_emitter_object) {
		__emitter_object = _emitter_object;
	}
	
	/// @function					particle_type_get(name)
	/// @description				register (or get existing) part type for leak-free destroying at end of level
	/// @param {string} name		
	static particle_type_get = function(name) {
		var rv = variable_struct_exists(__particle_types, name) ? variable_struct_get(__particle_types, name) : part_type_create();
		variable_struct_set(__particle_types, name, rv);
		return rv;
	}

	/// @function					particle_type_exists(name)
	/// @param {string} name
	/// @returns {bool}	y/n
	static particle_type_exists = function(name) {
		return variable_struct_exists(__particle_types, name);
	}

	/// @function					particle_type_destroy(name)
	/// @description				immediately destroy a particle type
	/// @param {string} name
	static particle_type_destroy = function(name) {
		if (variable_struct_exists(__particle_types, name)) {
			part_type_destroy(variable_struct_get(__particle_types, name));
			variable_struct_remove(__particle_types, name);
		}
	}
	
	/// @function					emitter_get(name)
	/// @description				register (or get existing) emitter for leak-free destroying at end of level
	/// @param {string} name		
	static emitter_get = function(name) {
		var rv = variable_struct_exists(__emitters, name) ? variable_struct_get(__emitters, name) : part_emitter_create(system);
		variable_struct_set(__emitters, name, rv);
		return rv;
	}
	
	/// @function					emitter_clone(name)
	/// @description				clone an emitter (and its range) to a new name
	/// @param {string} new_name	the name of the new emitter
	static emitter_clone = function(name, new_name) {
		if (!variable_struct_exists(__emitter_ranges, name))
			return undefined;
		
		var rv = emitter_get(new_name);
		var orig = variable_struct_get(__emitter_ranges, name);
		var rng = new __emitter_range(new_name, 
			orig.minco.x, orig.maxco.x,
			orig.minco.y, orig.maxco.y,
			orig.eshape,
			orig.edist
		);
		
		variable_struct_set(__emitter_ranges, new_name, rng);
		return rv;
	}
	
	/// @function		attach_emitter(name, instance, layer_name_or_depth, particle_type_name, follow_this_instance = true, use_object_pools = true)
	/// @description	Attach a new ParticleEmitter instance on the specified layer to an instance
	///					with optional follow-setting.
	///					NOTE: If you need more than one emitter of this kind, look at attach_emitter_clone
	/// @returns {ParticleEmitter}	the created object instance on the layer for cleanup if you no longer need it
	static attach_emitter = function(name, instance, layer_name_or_depth, particle_type_name, follow_this_instance = true, use_object_pools = true) {
		var xp	= instance.x;
		var yp	= instance.y;
		var rv	= use_object_pools ?
			pool_get_instance(__POOL_EMITTERS, __emitter_object, layer_name_or_depth) :
			instance_create(xp, yp, layer_name_or_depth, __emitter_object);

		with(rv) if (stream_on_create) stop(); // stop for now - you don't have a particle!

		emitter_get(name);
		emitter_move_range_to(name, xp, yp);

		with(rv) {
			x = xp;
			y = yp;
			follow_instance = follow_this_instance ? instance : undefined;
			emitter_name = name;
			stream_particle_name = particle_type_name;
			burst_particle_name = particle_type_name;
			if (stream_on_create) stream(); // NOW you may stream!
		}	
		
		return rv;
	}
	
	/// @function		attach_emitter_clone(name, new_name, instance, layer_name_or_depth, particle_type_name, follow_this_instance = true, use_object_pools = true)
	/// @description	Attach a clone of an existing emitter to a new ParticleEmitter instance 
	///					on the specified layer to an instance with optional follow-setting.
	/// @returns {ParticleEmitter}	the created object instance on the layer for cleanup if you no longer need it
	static attach_emitter_clone = function(name, new_name, instance, layer_name_or_depth, particle_type_name, follow_this_instance = true, use_object_pools = true) {
		emitter_clone(name, new_name);
		return attach_emitter(new_name, instance, layer_name_or_depth, particle_type_name, follow_this_instance, use_object_pools);
	}
	
	/// @function					emitter_exists(name)
	/// @param {string} name
	/// @returns {bool}	y/n
	static emitter_exists = function(name) {
		return variable_struct_exists(__emitters, name);
	}

	/// @function		emitter_set_range(name, xmin, xmax, ymin, ymax, shape, distribution)
	/// @description	Set the range of an emitter
	static emitter_set_range = function(name, xmin, xmax, ymin, ymax, shape, distribution) {
		emitter_get(name); // creates the emitter if it does not exist
		var rng = variable_struct_get(__emitter_ranges, name) ?? new __emitter_range(name, xmin, xmax, ymin, ymax, shape, distribution);
		rng.minco.set(xmin, ymin);
		rng.maxco.set(xmax, ymax);
		rng.eshape = shape;
		rng.edist = distribution;
		part_emitter_region(system, emitter_get(name), xmin, xmax, ymin, ymax, shape, distribution);
		variable_struct_set(__emitter_ranges, name, rng);
	}

	/// @function		emitter_move_range_by(name, xdelta, ydelta)
	/// @description	Move the range of the emitter by the specified delta, keeping its size, shape and distribution.
	///					Use this, if an emitter shall follow another object on screen (like the mouse cursor)
	static emitter_move_range_by = function(name, xdelta, ydelta) {
		var rng = variable_struct_get(__emitter_ranges, name);
		if (rng == undefined) {
			log(sprintf("*WARNING* Buffering range_by for '{0}', until the range exists!", name));
			variable_struct_set(__buffered_delta, name, new Coord2(xdelta, ydelta));
			return;
		}
		__buffered_delta = undefined;
		rng.minco.add(xdelta, ydelta);
		rng.maxco.add(xdelta, ydelta);
		part_emitter_region(system, emitter_get(name), rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
	}

	/// @function		emitter_move_range_to(name, newx, newy)
	/// @description	Move the range of the emitter a new position, keeping its shape and distribution.
	///					Use this, if an emitter shall follow another object on screen (like the mouse cursor)
	static emitter_move_range_to = function(name, newx, newy) {
		var rng = variable_struct_get(__emitter_ranges, name);
		if (rng == undefined) {
			log(sprintf("*WARNING* Buffering range_to for '{0}', until the range exists!", name));
			variable_struct_set(__buffered_target, name, new Coord2(newx, newy));
			return;
		}
		variable_struct_remove(__buffered_target, name);
		var diff = rng.maxco.clone2().minus(rng.minco);
		rng.minco.set(rng.baseminco.x + newx, rng.baseminco.y + newy);
		rng.maxco = rng.minco.clone2().plus(diff);
		part_emitter_region(system, emitter_get(name), rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
	}

	/// @function		emitter_get_range_min(name)
	/// @description	Gets the min coordinates of an emitter as Coord2 or Coord2(-1,-1) if not found
	static emitter_get_range_min = function(name) {
		var rng = variable_struct_get(__emitter_ranges, name);
		return (rng != undefined ? rng.minco : new Coord2(-1, -1));
	}
	
	/// @function		emitter_get_range_max(name)
	/// @description	Gets the min coordinates of an emitter as Coord2 or Coord2(-1,-1) if not found
	static emitter_get_range_max = function(name) {
		var rng = variable_struct_get(__emitter_ranges, name);
		return (rng != undefined ? rng.maxco : new Coord2(-1, -1));
	}

	/// @function					emitter_destroy(name)
	/// @description				immediately destroy an emitter
	/// @param {string} name
	static emitter_destroy = function(name) {
		if (variable_struct_exists(__emitters, name)) {
			var emitter = variable_struct_get(__emitters, name);
			part_emitter_clear(system, emitter);
			part_emitter_destroy(system, emitter);
			variable_struct_remove(__emitters, name);
		}
		if (variable_struct_exists(__emitter_ranges, name)) {
			variable_struct_remove(__emitters, name);
		}
	}

	/// @function			cleanup()
	/// @description		you MUST call this in the cleanup event of your controller!
	static cleanup = function() {
		part_system_destroy(system);
		var names = variable_struct_get_names(__particle_types);
		var i = 0; repeat(array_length(names)) {
			if (variable_struct_exists(__particle_types, names[i]) && 
				variable_struct_get   (__particle_types, names[i]) != undefined) {
				part_type_destroy(variable_struct_get(__particle_types, names[i]));
				variable_struct_set(__particle_types, names[i], undefined);
			}
			i++;
		}
		__particle_types = {};
		
		names = variable_struct_get_names(__emitters);
		i = 0; repeat(array_length(names)) {
			if (variable_struct_exists(__emitters, names[i]) && 
				variable_struct_get   (__emitters, names[i]) != undefined) {
				var emitter = variable_struct_get(__emitters, names[i]);
				part_emitter_clear(system, emitter);
				part_emitter_destroy(system, emitter);
				variable_struct_set(__emitters, names[i], undefined);
			}
			i++;
		}
		__emitters = {};
		__emitter_ranges = {};
	}
	
	/// @function		__apply_buffering()
	static __apply_buffering = function(name) {
		var r = variable_struct_get(__buffered_target, name);
		if (r != undefined) {
			emitter_move_range_to(name, r.x, r.y);
			log("range_to buffering apply " + (variable_struct_exists(__buffered_target, name) ? "FAILED" : "successful"));
		}
		r = variable_struct_get(__buffered_delta, name);
		if (r != undefined) {
			emitter_move_range_by(name, r.x, r.y);
			log("range_by buffering apply " + (variable_struct_exists(__buffered_delta, name) ? "FAILED" : "successful"));
		}
	}
	
	/// @function			stream(emitter_name, particle_name, particles_per_frame)
	/// @description		start streaming particles at a specified rate
	/// @param {string} emitter_name
	/// @param {string} particle_name
	/// @param {real} particles_per_frame
	static stream = function(emitter_name, particle_name, particles_per_frame) {
		__apply_buffering(emitter_name);
		part_emitter_stream(system, 
			emitter_get(emitter_name), 
			particle_type_get(particle_name), 
			particles_per_frame);
	}
	
	/// @function			stream_stop(emitter_name)
	/// @description		stop streaming particles.
	///						ATTENTION! You must setup part_emitter_region again if this
	///						emitter is going to be reused in the future!
	/// @param {string} emitter_name
	static stream_stop = function(emitter_name) {
		part_emitter_clear(system, emitter_get(emitter_name));
		var rng = variable_struct_get(__emitter_ranges, emitter_name);
		if (rng != undefined)
			part_emitter_region(system, emitter_get(emitter_name), rng.minco.x, rng.maxco.x, rng.minco.y, rng.maxco.y, rng.eshape, rng.edist);
	}
	
	/// @function			burst(emitter_name, particle_name, particles_per_frame)
	/// @description		one time particle explosion burst
	/// @param {string} emitter_name
	/// @param {string} particle_name
	/// @param {real} particle_count
	static burst = function(emitter_name, particle_name, particle_count) {
		__apply_buffering(emitter_name);
		part_emitter_burst(system, 
			emitter_get(emitter_name), 
			particle_type_get(particle_name), 
			particle_count);
	}
	
	/// @function			spawn_particles(xpos, ypos, particle_name, particle_count)
	/// @description		spawn particles at a specified position without an emitter
	/// @param {real} xpos
	/// @param {real} ypos
	/// @param {string} particle_name
	/// @param {real} particle_count
	static spawn_particles = function(xpos, ypos, particle_name, particle_count) {
		part_particles_create(system, xpos, ypos,
			particle_type_get(particle_name), particle_count);
	}
}


function __emitter_range(name, xmin, xmax, ymin, ymax, shape, distribution) constructor {
	ename = name;
	center = new Coord2((xmax - xmin) / 2, (ymax - ymin) / 2);
	minco = new Coord2(xmin, ymin);
	maxco = new Coord2(xmax, ymax);
	baseminco = minco.clone2();
	basemaxco = maxco.clone2();
	eshape = shape;
	edist = distribution;
}
