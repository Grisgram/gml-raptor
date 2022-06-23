/*
	Create a particle manager in a Controller Object (like a RoomController)
	Specify the layer name where particles shall be created (that's the layer, the particle system will use).
	
	NOTE: You MUST call the cleanup function in the CleanUp event of the controller to avoid memory leaks!
	
*/

/// @function					ParticleManager(particle_layer_name)
/// @description				Helps in organizing particles for a level
/// @param {string} particle_layer_name
/// @returns {struct} ParticleManager
function ParticleManager(particle_layer_name) constructor {
	system = part_system_create_layer(particle_layer_name, false);
	__particle_types = {};
	__emitters = {};
	
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
	
	/// @function					emitter_exists(name)
	/// @param {string} name
	/// @returns {bool}	y/n
	static emitter_exists = function(name) {
		return variable_struct_exists(__emitters, name);
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
	}

	/// @function			cleanup()
	/// @description		you MUST call this in the cleanup event of your controller!
	static cleanup = function() {
		part_system_destroy(system);
		var names = variable_struct_get_names(__particle_types);
		var i = 0; repeat(array_length(names)) {
			part_type_destroy(variable_struct_get(__particle_types, names[i]));
			variable_struct_set(__particle_types, names[i++], undefined);
		}
		__particle_types = {};
		
		names = variable_struct_get_names(__emitters);
		i = 0; repeat(array_length(names)) {
			var emitter = variable_struct_get(__emitters, names[i]);
			part_emitter_clear(system, emitter);
			part_emitter_destroy(system, emitter);
			variable_struct_set(__emitters, names[i++], undefined);
		}
		__emitters = {};
	}
	
	/// @function			stream(emitter_name, particle_name, particles_per_frame)
	/// @description		start streaming particles at a specified rate
	/// @param {string} emitter_name
	/// @param {string} particle_name
	/// @param {real} particles_per_frame
	static stream = function(emitter_name, particle_name, particles_per_frame) {
		part_emitter_stream(self, 
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
		part_emitter_clear(self, emitter_get(emitter_name));
	}
	
	/// @function			burst(emitter_name, particle_name, particles_per_frame)
	/// @description		one time particle explosion burst
	/// @param {string} emitter_name
	/// @param {string} particle_name
	/// @param {real} particle_count
	static burst = function(emitter_name, particle_name, particle_count) {
		part_emitter_burst(self, 
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
		part_particles_create(self, xpos, ypos,
			particle_type_get(particle_name), particle_count);
	}
}

