/// @description Docs inside!

/* 
	The particle emitter is an invisible object that can be placed anywhere in the room
	if you need "just a source for particles" not attached to a specific object.
	Any object could control the emitter by itself, but sometimes you want particles just
	as an effect on a specific position of the background graphics or similar.
	
	Check out the variable definitions! You can set everything you need there.
	
	A note on the "follow_instance" variable definition:
	This is by default undefined as the original intention of this object was a static position
	in the room. If you plan to move this ParticleEmitter, set this variable to an instance name, 
	but keep in mind, that this causes a emitter_set_range call every end_step to update the 
	x/y position of the emitter if the attached object has moved!
	
	The ParticleEmitter offers 3 methods:
	- stream()	start streaming
	- stop()	stops streaming
	- burst(n)	bursts out n particles immediately
	
	NOTE:	This object REQUIRES that you have a ParticleManager up and running
			through the RoomController!
			This object accesses the PARTSYS macro, which is filled by the
			RoomController, if you set one or more particle_layer_names in its Variable Definitions.
			
	About the PARTSYS_INDEX variable definition:
	You may setup a roomcontroller to host multiple particle systems on different layers,
	by specifying an array or strings instead of a single string for the "particle_layer_names"
	variable in a RoomController. 
	If you have multiple systems active, you must specify the index of the system this Emitter
	shall use. (Index 0 is the first system, in order of the strings you specified in the
	RoomController).
*/

// Inherit the parent event
event_inherited();

__clone_created = !stream_with_clone;
__my_emitter = emitter_name;

__raptor_onPoolDeactivate = function() {
	stop();
}

__get_partsys = function() {
	return (is_array(PARTSYS) ? PARTSYS[@ partsys_index] : PARTSYS);
}

/// @function		set_offset(xoff, yoff)
/// @description	sets a static offset distance to apply when following an instance
set_offset = function(xoff, yoff) {
	follow_offset.set(xoff, yoff);
	__update_position(,true);
	return self;
}

/// @function		__update_position(ps = undefined)
__update_position = function(ps = undefined, force = false) {
	if (follow_instance != undefined && instance_exists(follow_instance)) {
		x = follow_instance.x + follow_offset.x * follow_instance.image_xscale;
		y = follow_instance.y + follow_offset.y * follow_instance.image_yscale;
		if (x != xprevious || y != yprevious || force) {
			ps = ps ?? __get_partsys();
			ps.emitter_move_range_to(__my_emitter, x, y);
			if (scale_with_instance)
				ps.emitter_scale_to(__my_emitter, self);
		}
	}
}

/// @function		stream(particles_per_frame = undefined, particle_name = undefined)
/// @description	Starts streaming particles as defined for the emitter.
///					If you don't supply any parameters, the values from the variable definitions
///					are used.
stream = function(particles_per_frame = undefined, particle_name = undefined) {
	var pn = particle_name ?? stream_particle_name;
	var pc = particles_per_frame ?? stream_particle_count;
	
	stream_particle_count = pc;
	if (string_is_empty(__my_emitter)) {
		if (DEBUG_LOG_PARTICLES)
			wlog($"{MY_NAME} ignored stream() call - no emitter name");
		return;
	}
	
	var ps = __get_partsys();
	if (!__clone_created) {
		var temp_clone;
		if (follow_instance != undefined && instance_exists(follow_instance))
			temp_clone = ps.emitter_attach_clone(__my_emitter, follow_instance);
		else
			temp_clone = ps.emitter_clone(__my_emitter);
		temp_clone.follow_offset = follow_offset.clone2();
		__my_emitter = temp_clone.emitter_name;
		ps.emitter_move_range_to(__my_emitter, x, y);
		__clone_created = true;
	}
	
	if (string_is_empty(pn))
		pn = ps.emitter_get(__my_emitter).default_particle;
	
	if (string_is_empty(pn)) {
		if (DEBUG_LOG_PARTICLES)
			wlog($"{MY_NAME} ignored stream() call - no particle name");
		return;
	}
	
	__update_position(ps, true);
	if (DEBUG_LOG_PARTICLES)
		dlog($"{MY_NAME}: Started streaming {pc} '{pn}' ppf at {ps.emitter_get_range_min(__my_emitter)} through '{__my_emitter}'");
	ps.stream_stop(__my_emitter);
	ps.stream(__my_emitter, pc, pn);
	return self;
}

/// @function		stop()
/// @description	Stops streaming
stop = function() {
	if (DEBUG_LOG_PARTICLES)
		dlog($"{MY_NAME}: Stopped streaming through '{__my_emitter}'");
	var ps = __get_partsys();	
	ps.stream_stop(__my_emitter);
	return self;
}

/// @function		burst(particle_count = undefined, particle_name = undefined, stop_streaming = true)
/// @description	Immediately bursts out n particles
///					If you don't supply any parameters, the values from the variable definitions
///					are used.
///					If no burst_particle_name is set in the variable definitions, the
///					stream_particle_name is used.
burst = function(particle_count = undefined, particle_name = undefined, stop_streaming = true) {
	var pn = particle_name ?? burst_particle_name;
	pn = pn ?? stream_particle_name;
	var pc = particle_count ?? burst_particle_count;
	
	burst_particle_count = pc;
	
	var ps = __get_partsys();
	if (stop_streaming) stop();
	__update_position(ps, true);
	if (DEBUG_LOG_PARTICLES)
		dlog($"{MY_NAME}: Bursting {pc} '{pn}' particles at {ps.emitter_get_range_min(__my_emitter)} through '{__my_emitter}'");
	ps.burst(__my_emitter, pc, pn);
	return self;
}

prev_x = x;
prev_y = y;

if (!string_is_empty(__my_emitter)) {
	var initps = __get_partsys();	
	initps.emitter_move_range_to(__my_emitter, x, y);
}

__create_init_succeeded = false;
if (variable_global_exists("__room_particle_system") && !string_is_empty(__my_emitter)) {
	__create_init_succeeded = true;

	var ps = __get_partsys();
	ps.emitter_move_range_to(__my_emitter, x, y);

	if (stream_on_create) {
		stream_start_delay = max(stream_start_delay, 1);
		if (stream_start_delay > 0 && DEBUG_LOG_PARTICLES)
			ilog($"{MY_NAME}: Will start streaming in {stream_start_delay} frames");
		run_delayed(self, stream_start_delay, function() { stream(); });
	}
}
