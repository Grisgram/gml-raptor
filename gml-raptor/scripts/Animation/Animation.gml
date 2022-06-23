/*
    The Animation class runs an animation on an object over an animcurve.
	The RoomController object manages animations for you by calling all active animations'
	step() method every step.
	For this to work, you have instanciated a RoomController in your room.
	If not, nothing bad happens, but you have to call step() for yourself on every animation.
	
	The Animation class will autodetect the channels in the animcurve and set the 
	properties of the object automatically based on the curve channels.
	The names of the channels must be identical to the variables you want to set.
	So, to modify the hspeed, name the channel "hspeed", to modify x or y name them "x" or "y"...
	
	TRIGGERS
	--------
	The Animation class supports triggers for various points in time during the animation.
	Four trigger types are supported:
	- loop_trigger		- all loop triggers get invoked after the animation reached its final frame
	- started_trigger	- all started triggers get invoked once before the first frame of the animation
						  is processed.
	- finished_trigger	- all finished triggers get invoked when the last repeat of the animation is completed
						  NOTE: infinite animations receive this trigger only if you call abort()!
	- frame_trigger		- add a trigger to a specific frame. it gets invoked BEFORE this frame is processed

	ALL TRIGGERS receive "self" (this animation instance) as first parameter.
	IN ADDITION, the frame_trigger callback receives a second parameter "frame" which holds the current frame
	number that is about to get processed.

	If you reuse the animation often, it may become handy, to clear out all triggers from previous
	interations. You can use the reset_triggers() function for that. It will delete ALL registered triggers.
	
	Every Animation instance has a data={} struct variable available.
	You can add any data to it. Each trigger will receive this data struct as first parameter.
	
*/

#macro	ANIMATIONS	global.__ANIMATIONS
ANIMATIONS		= new ListPool("ANIMATIONS");

/// @function		Animation(_obj_owner, _delay, _duration, _animcurve, _repeats = 1)
/// @description	Holds an animation. set repeats to -1 to loop forever until you call abort()
function Animation(_obj_owner, _delay, _duration, _animcurve, _repeats = 1) constructor {
	owner				= _obj_owner;
	delay				= _delay;
	duration			= _duration
	animcurve			= _animcurve != undefined ? animcurve_get_ext(_animcurve) : undefined;
	repeats				= _repeats;
	data				= {};

	func_x				= function(value) { if (__move_distance_mode) owner.x = __start_x + __move_xdistance * value; else owner.x	= value; };
	func_y				= function(value) { if (__move_distance_mode) owner.y = __start_y + __move_ydistance * value; else owner.y	= value; };
	func_hspeed			= function(value) { owner.hspeed		= value; };
	func_vspeed			= function(value) { owner.vspeed		= value; };
	func_speed			= function(value) { owner.speed			= value; };
	func_directon		= function(value) { owner.direction		= value; };
	func_image_alpha	= function(value) { owner.image_alpha	= value; };
	func_image_blend	= function(value) { owner.image_blend	= merge_color(__blend_start, __blend_end, value); };
	func_image_xscale	= function(value) { if (__relative_scale) owner.image_xscale = __start_xscale * value; else owner.image_xscale	= value; };
	func_image_yscale	= function(value) { if (__relative_scale) owner.image_yscale = __start_yscale * value; else owner.image_yscale	= value; };
	func_image_angle	= function(value) { if (__relative_angle) owner.image_angle  = __start_angle + __rotation_distance * value; else owner.image_angle = value; };
	func_image_index	= function(value) { owner.image_index	= value; };
	func_image_speed	= function(value) { owner.image_speed	= value; };
	func_image_scale	= function(value) { 
		if (__relative_scale) {
			owner.image_xscale = __start_xscale * value; 
			owner.image_yscale = __start_yscale * value; 
		} else {
			owner.image_xscale = value; 
			owner.image_yscale = value; 
		}
	};

	// these variables are used in the step loop
	__func				= undefined;
	__cname				= "";
	__cvalue			= 0;
	__first_step		= false;
	__play_forward		= true;

	__blend_start		 = c_white;
	__blend_end			 = c_white;
	
	__move_distance_mode = false;
	__move_xdistance	 = 0;
	__move_ydistance	 = 0;
	__relative_scale	 = false;
	__relative_angle	 = false;
	__rotation_distance	 = 0;

	#region TRIGGERS
	static __frame_trigger_class = function(_frame, _trigger, _interval) constructor {
		frame = _frame;
		trigger = _trigger;
		interval = _interval;
	};
		
	static add_started_trigger = function(trigger) {
		array_push(__started_triggers, trigger);
		return self;
	}
	
	static add_frame_trigger = function(frame, trigger, is_interval = false) {
		array_push(__frame_triggers, new __frame_trigger_class(frame, trigger));
		return self;
	}
	
	static add_loop_trigger = function(trigger) {
		array_push(__loop_triggers, trigger);
		return self;
	}
	
	static add_finished_trigger = function(trigger) {
		array_push(__finished_triggers, trigger);
		return self;
	}
	
	static reset_triggers = function() {
		__started_triggers	= [];
		__frame_triggers	= [];
		__loop_triggers		= [];
		__finished_triggers = [];
		return self;
	}
	
	static __invoke_triggers = function(array) {
		for (var i = 0; i < array_length(array); i++)
			array[@ i](data);
	}
	
	static __invoke_frame_triggers = function(frame) {
		var t;
		for (var i = 0; i < array_length(__frame_triggers); i++) {
			t = __frame_triggers[@ i];
			if (t.frame == frame || (t.interval && (t.frame mod frame == 0))) t.trigger(data, frame);
		}
	}
	#endregion

	/// @function		set_move_distance(xdistance, ydistance)
	/// @description	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier for the total
	///					distance you supply here (a "move by" curve).
	///					Both default move functions for x and y respect this setting.
	static set_move_distance = function(xdistance, ydistance) {
		__move_distance_mode = true;
		__move_xdistance  = xdistance;
		__move_ydistance  = ydistance;
		return self;
	}

	/// @function		set_move_target(xtarget, ytarget)
	/// @description	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier from the current
	///					to the target coordinates you supply here (a "move to" curve).
	///					Both default move functions for x and y respect this setting.
	static set_move_target = function(xtarget, ytarget) {
		__move_distance_mode = true;
		__move_xdistance = xtarget - __start_x;
		__move_ydistance = ytarget - __start_y;
		return self;
	}

	/// @function		set_scale_relative(relative)
	/// @description	tell the animation that image-scaling values are to be
	///					interpreted as relative multiplier to the current scale (default = false)
	static set_scale_relative = function(relative) {
		__relative_scale = relative;
		return self;
	}

	/// @function		set_rotation_distance(degrees)
	/// @description	use this function if the animcurve holds a standard 0..1 value
	///					for image_angle and the curve value shall be a multiplier for the total
	///					distance you supply here (a "rotate by" curve).
	static set_rotation_distance = function(degrees) {
		__relative_angle = true;
		__rotation_distance = degrees;
		return self;
	}

	/// @function		set_rotation_target(degrees)
	/// @description	use this function if the animcurve holds a standard 0..1 value
	///					for x/y and the curve value shall be a multiplier from the current
	///					to the target angle you supply here (a "rotate to" curve).
	///					Both default move functions for x and y respect this setting.
	static set_rotation_target = function(degrees) {
		__relative_angle = true;
		__rotation_distance = degrees - __start_angle;
		return self;
	}

	/// @function		set_blend_range(start_color = c_white, end_color = c_white)
	/// @description	set the two colors that shall be modified during an image_blend curve
	static set_blend_range = function(start_color = c_white, end_color = c_white) {
		__blend_start = start_color;
		__blend_end	  = end_color;
		return self;
	}

	/// @function play_forward()
	/// @description Animation shall play forward (this is default)
	static play_forward = function() {
		__play_forward = true;
		return self;
	}
	
	/// @function play_forward()
	/// @description Animation shall play backwards (Animcurve starts at 1 and goes back to 0)
	static play_backwards = function() {
		__play_forward = false;
		return self;
	}

	/// @function					set_function(channel_name, _function)
	/// @description				Assign a function that takes 1 argument (the value) for a channel
	static set_function = function(channel_name, _function) {
		self[$ "func_" + channel_name] = method(self, _function);
		return self;
	}

	/// @function					step()
	/// @description				call this every step!
	static step = function() {
		if (__finished) return;
		
		if (__active) {
			if (__first_step) {
				__first_step = false;
				__invoke_triggers(__started_triggers);
			}
			
			__frame_counter++;
			__invoke_frame_triggers(__frame_counter);
			
			if (animcurve != undefined) {
				var pit = __play_forward ? __frame_counter : (duration - __frame_counter);
				animcurve.update_values(pit / duration);
				for (var i = 0; i < array_length(animcurve.channel_names); i++) {
					__cname  = animcurve.channel_names[i];
					__cvalue = animcurve.channel_values[i];
				
					self[$ "func_" + __cname](__cvalue);
				}
			}
			
			if (__frame_counter >= duration) {
				__invoke_triggers(__loop_triggers);
				if (repeats > 0) {
					__repeat_counter++;
					__finished = __repeat_counter == repeats;
					if (__finished) { 
						ANIMATIONS.remove(self);
						__invoke_triggers(__finished_triggers);
					}
				}
				__frame_counter		= 0;
			}
		} else {
			__delay_counter++;
			__active = __delay_counter >= delay;
			__first_step = __active;
		}
	}
	
	/// @function		abort()
	/// @description	Stop immediately, but finished trigger WILL fire!
	static abort = function() {
		var was_finished = __finished;
		__finished = true;
		ANIMATIONS.remove(self);
		if (!was_finished)
			__invoke_triggers(__finished_triggers);
	}
		
	/// @function		reset()
	/// @description	All back to start. Animation will RUN now!
	static reset = function() {
		ANIMATIONS.add(self);
		
		__start_x			= owner.x;
		__start_y			= owner.y;
		__start_xscale		= owner.image_xscale;
		__start_yscale		= owner.image_yscale;
		__start_angle		= owner.image_angle;
		
		__delay_counter		= 0;
		__frame_counter		= 0;
		__repeat_counter	= 0;
		__active			= delay == 0;
		__finished			= repeats == 0;
		__first_step		= __active;
		
		return self;
	}

	reset();
	reset_triggers();

}

/// @function		animation_clear_pool()
/// @description	Instantly removes ALL animations.
function animation_clear_pool() {
	ANIMATIONS.clear();
}

/// @function		animation_remove_all(owner = self)
/// @description	Holds an animation. set repeats to -1 to loop forever until you call abort()
function animation_remove_all(owner = self) {
	var removers = [];
	var lst = ANIMATIONS.list;
	if (IS_HTML) {
		var myowner;
		with (owner) myowner = MY_NAME;
		// GMS HTML runtime is not able to recognize reference equality correctly, 
		// so we need to tweak here (UGLY!!!)
		for (var i = 0; i < ds_list_size(lst); i++) {
			var item = lst[| i];
			var otherowner;
			with (item.owner)
				otherowner = MY_NAME;
			if (myowner == otherowner)
				array_push(removers, item);
		}		
	} else {
		for (var i = 0; i < ds_list_size(lst); i++) {
			var item = lst[| i];
			if (item.owner == owner)
				array_push(removers, item);
		}
	}
	
	with (owner) 
		log(MY_NAME + sprintf(": Animation cleanup: anims_to_remove={0};", array_length(removers)));
		
	for (var i = 0; i < array_length(removers); i++) {
		var to_remove = removers[@ i];
		with (to_remove) 
			abort();
	}
}

/// @function		in_animation(owner = self)
/// @description	returns true, if there's at least one animation for the specified owner currently in the pool
function in_animation(owner = self) {
	var lst = ANIMATIONS.list;
	if (IS_HTML) {
		var myowner;
		with (owner) myowner = MY_NAME;
		// GMS HTML runtime is not able to recognize reference equality correctly, 
		// so we need to tweak here (UGLY!!!)
		for (var i = 0; i < ds_list_size(lst); i++) {
			var item = lst[| i];
			var otherowner;
			with (item.owner)
				otherowner = MY_NAME;
			if (myowner == otherowner)
				return true;
		}		
	} else {
		for (var i = 0; i < ds_list_size(lst); i++) {
			var item = lst[| i];
			if (item.owner == owner)
				return true;
		}
	}
	return false;
}

/// @function			animation_empty(_obj_owner, _delay, _duration, _repeats = 1)
/// @description		Convenience function to create a delay/duration/callback animation
///						without an animcurve, but you have still ALL callbacks available
///						(started, finished, frames, etc). It just has no animation.
///						You can use this to easily delay or repeat actions without the need of
///						actually design a real animation.
///						This function return an Animation struct instance for chaining.
/// @returns {Animation}
function animation_empty(_obj_owner, _delay, _duration, _repeats = 1) {
	return new Animation(_obj_owner, _delay, _duration, undefined, _repeats);
}

/// @function			animation_run(_obj_owner, _delay, _duration, _animcurve, _repeats = 1)
/// @description		constructor wrapper if you don't need to keep your own pointer
function animation_run(_obj_owner, _delay, _duration, _animcurve, _repeats = 1) {
	return new Animation(_obj_owner, _delay, _duration, _animcurve, _repeats);
}
