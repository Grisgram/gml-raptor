/// @description Docs inside!

/* 
	The particle emitter is an invisible object that can be placed anywhere in the room
	if you need "just a source for particles" not attached to a specific object.
	Any object could control the emitter by itself, but sometimes you want particles just
	as an effect on a specific position of the background graphics or similar.
	
	Check out the variable definitions! You can set everything you need there.
	
	A note on the "emitter_follow_object" variable definition:
	This is by default false as the original intention of this object was a static position
	in the room. If you plan to move this ParticleEmitter, set this variable to True, but keep
	in mind, that this causes a emitter_set_range call every end_step to update x/y position of
	the emitter!
	
	The ParticleEmitter offers 3 methods:
	- stream()	start streaming
	- stop()	stops streaming
	- burst(n)	bursts out n particles immediately
	
	NOTE:	This object REQUIRES that you have a ParticleManager up and running
			through the RoomController!
			This object accesses the PART_SYS macro, which is filled by the
			RoomController, if you set a particle_layer_name in its Variable Definitions.
*/

/// @function		stream(particle_name = undefined, particles_per_frame = undefined)
/// @description	Starts streaming particles as defined for the emitter.
///					If you don't supply any parameters, the values from the variable definitions
///					are used.
stream = function(particle_name = undefined, particles_per_frame = undefined) {
	var pn = particle_name ?? stream_particle_name;
	var pc = particles_per_frame ?? stream_particle_count;
	log(MY_NAME + sprintf(": Started streaming {0} '{1}' ppf at {2} through '{3}'", pc, pn, PARTSYS.emitter_get_range_min(emitter_name), emitter_name));
	PARTSYS.stream(emitter_name, pn, pc);
}

/// @function		stop()
/// @description	Stops streaming
stop = function() {
	log(MY_NAME + sprintf(": Stopped streaming through '{0}'", emitter_name));
	PARTSYS.stream_stop(emitter_name);
}

/// @function		burst(particle_name = undefined, particle_count = undefined)
/// @description	Immediately bursts out n particles
///					If you don't supply any parameters, the values from the variable definitions
///					are used.
///					If no burst_particle_name is set in the variable definitions, the
///					stream_particle_name is used.
burst = function(particle_name = undefined, particle_count = undefined) {
	var pn = particle_name ?? burst_particle_name;
	pn = pn ?? stream_particle_name;
	var pc = particle_count ?? burst_particle_count;
	log(MY_NAME + sprintf(": Bursting {0} '{1}' particles at {2} through '{3}'", pc, pn, PARTSYS.emitter_get_range_min(emitter_name), emitter_name));
	PARTSYS.burst(emitter_name, pn, pc);
}

prev_x = x;
prev_y = y;

PARTSYS.emitter_move_range_to(emitter_name, x, y);

// Inherit the parent event
event_inherited();

if (stream_on_create) {
	if (stream_start_delay > 0)
		log(MY_NAME + sprintf(": Will start streaming in {0} frames", stream_start_delay));
	run_delayed(self, stream_start_delay, function() { stream(); });
}