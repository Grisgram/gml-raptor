/*
	A StateMachine holds different states for an object.
	Construct one supplying an owner plus any number of states or
	simply add states later by calling the add_state() function.
	
	NOTE: All states are instances of the State() class (see down in this file)!
	
	The RoomController executes all existing states each step by calling the
	execute() function of the StateMachine. This function calls the state function
	you supplied when creating the state and delivers the data struct to the state
	function.
	
	if you call add_state(..) with a state name that already exists in this machine,
	the state gets replaced.
	
	NOTE: To avoid memory leaks and to avoid having the state machine queued forever,
	you MUST call destroy() in the state machine when you no longer need it!
	
*/

#macro	STATEMACHINES	global.__statemachine_pool
STATEMACHINES		= new ListPool("STATEMACHINES");

/// @func	 StateMachine(_owner, ...)
/// @desc Create a new state machine with a list of states
/// @param {instance} _owner  The owner of the StateMachine. MUST be an object instance!
/// @param {State...} states  Any number (up to 15) of State(...) instances that define the states
function StateMachine(_owner) constructor {
	owner				= _owner;
	__states			= [];
	active_state		= undefined;
	on_destroy			= undefined;
	__allow_re_enter	= false;
	__state_frame		= 0;
	__objectpool_paused = false;
	
	data				= new Bindable(self);
	
	locking_animation	= undefined;
	lock_state_buffered	= false;
	lock_end_state		= undefined;
	lock_end_enter		= undefined;
	lock_end_leave		= undefined;
	
	__listpool_processible = false;
	
	if (DEBUG_LOG_STATEMACHINE) with(owner) vlog($"{MY_NAME}: StateMachine created");
	
	for (var i = 1; i < argument_count; i++) {
		var st = argument[@ i];
		st.data = data;
		if (DEBUG_LOG_STATEMACHINE)
			with(owner) vlog($"{MY_NAME}: StateMachine added state '{st.name}' on creation");
		array_push(__states, st);
	}
	
	/// @func 		events_enabled()
	/// @desc	Invoked by the StateMachine when it needs to know, whether it should react
	///					on input events like key strokes or mouse clicks.
	///					The default implementation disables events if we are behind a popup or a 
	///					MessageBox is currently open.
	///					override/redefine if you need another condition
	///					ATTENTION! If you redeclare this, do it always in a with(states) {...} bracket
	///					in the create event of the object redefining it, otherwise you won't have access 
	///					to the state machine's variables, like the owner.
	/// @returns {bool} true/false Shall the StateMachine react on input events?
	events_enabled = function() {
		with(owner)
			return !__LAYER_OR_OBJECT_HIDDEN && !__HIDDEN_BEHIND_POPUP;
	}
	
	/// @func		set_events_enabled_func(func)
	/// @desc	Assigns a new events_enabled function to this state machine.
	///					This is a chainable convenience function, you can also assign a
	///					new events_enabled function by simply overriding (redefining)
	///					the .events_enabled member of this state machine directly.
	/// @param {func} func	The function to assign as events_enabled evaluator
	static set_events_enabled_func = function(func) {
		self[$ "events_enabled"] = method(self, func);
		return self;
	}
	
	/// @func		clear_states()
	/// @desc	Removes all known states, sets active_state = undefined and optionally 
	///					resets the data variable.
	///					NOTE: The on_leave callback of any active state will NOT be invoked!
	///					This reset is instant.
	/// @param {bool}	reset_data	Default true. The data variable will be reset also.
	static clear_states = function(reset_data = true) {
		__states			= [];
		active_state		= undefined;
		if (reset_data) 
			data = {};
		return self;
	}
	
	static __release_anim_lock = function() {
		locking_animation = undefined;
		lock_state_buffered = false;
		if (lock_end_state != undefined)
			set_state(lock_end_state, lock_end_enter, lock_end_leave);
		lock_end_state = undefined;
		lock_end_enter = undefined;
		lock_end_leave = undefined;
	}
	
	/// @func lock_animation(_animation, _buffer_state_change = true)
	/// @desc	runs an animation locked, which means, no state change
	///					is allowed until it is finished.
	///					If a state change occurs while running, and you have set the
	///					_buffer_state_change argument to true, then this state is remembered
	///					and will be set as soon as the animation finishes.
	///					Multiple state changes are ignored, only the first is remembered,
	///					because normally they form kind of a "sequence", and the FIRST change
	///					is the next to occur, not the LAST.
	static lock_animation = function(_animation, _buffer_state_change = true) {
		locking_animation = _animation;
		lock_state_buffered = _buffer_state_change;
		with (owner)
			_animation.add_finished_trigger(function() {
				// with(states) works, because this is run WITH(OWNER), and the owner
				// is a stateful object, which owns a "states" member (this statemachine)
				with (states)
					__release_anim_lock();
			});
	}
	
	/// @func		add_state(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined)
	/// @desc	Defines a new state for the StateMachine. 
	///					NOTE: If a state with that name already exists, it is overwritten!
	/// @param {string} _name		The name of the state
	/// @param {func}	_on_enter	Optional. Callback to invoke when this state gets entered
	/// @param {func}	_on_step	Optional. Callback to invoke every frame while in this state
	/// @param {func}	_on_leave	Optional. Callback to invoke when this state shall be left
	static add_state = function(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined) {
		if (DEBUG_LOG_STATEMACHINE)
			with(owner) vlog($"{MY_NAME}: StateMachine added state '{_name}'");
		if (get_state(_name) != undefined) {
			if (DEBUG_LOG_STATEMACHINE)
				with(owner) wlog($"{MY_NAME}: ** WARNING **: Name collision: '{_name}' overwrites an existing state!");
			delete_state(_name);
		}
		var st = new State(_name, _on_enter, _on_step, _on_leave);
		st.data = data;
		array_push(__states, st);
		return self;
	}
	
	/// @func		add_state_shared(_state)
	/// @desc	Adds a shared state to the StateMachine. 
	///					NOTE: If a state with that name already exists, it is overwritten!
	/// @param {State}  state The shared state to add
	static add_state_shared = function(_state) {
		var _name = _state.name;
		if (DEBUG_LOG_STATEMACHINE)
			with(owner) vlog($"{MY_NAME}: StateMachine added shared state '{_name}'");
		if (get_state(_name) != undefined) {
			if (DEBUG_LOG_STATEMACHINE)
				with(owner) wlog($"{MY_NAME}: ** WARNING **: Name collision: Shared state '{_name}' overwrites an existing state!");
			delete_state(_name);
		}
		array_push(__states, _state);
		return self;
	}
	
	/// @func __perform_state_change(action, rv)
	static __perform_state_change = function(action, rv) {
		if (rv != undefined && is_string(rv)) {
			if (!has_active_state() || rv != active_state.name) {
				if (DEBUG_LOG_STATEMACHINE)
					with(owner) vlog($"{MY_NAME}: '{other.active_state.name}.{action}' resulted in state change '{rv}'");
				set_state(rv);
			}
		}
	}
	
	/// @func		set_state(name, enter_override = undefined, leave_override = undefined)
	/// @desc	Transition to a new state. If the specified state does not exist,
	///					an error is logged and the object stays in the current state.
	/// @param {string} name state to enter
	/// @param {func} enter_override  Optional. Replace the original on_enter for this transition with something else
	/// @param {func} leave_override  Optional. Replace the original on_leave for this transition with something else	
	static set_state = function(name, enter_override = undefined, leave_override = undefined) {
		// automated state changes due to events may be blocked globally
		// through the events_enabled() function
		if (string_starts_with(name, "ev:") && !events_enabled())
			return self;
		
		if (locking_animation != undefined) {
			if (lock_state_buffered && lock_end_state == undefined) {
				lock_end_state = name;
				lock_end_enter = enter_override;
				lock_end_leave = leave_override;
			}
			return self;
		}
		
		var rv = undefined;
		if (active_state == undefined || __allow_re_enter || active_state.name != name) {
			if (active_state != undefined && state_exists(name)) {
				if (DEBUG_LOG_STATEMACHINE)
					with(owner) vlog($"{MY_NAME}: Leaving state '{other.active_state.name}'{(leave_override != undefined ? " (with leave-override)" : "")}");
				active_state.data = data;
				if (!active_state.leave(name, leave_override)) {
					if (DEBUG_LOG_STATEMACHINE)
						with(owner) vlog($"{MY_NAME}: State change '{other.active_state.name}'->'{name}' aborted by leave callback!");
					return self;
				}
			}
		
			var prev_state = active_state != undefined ? active_state		: undefined;
			var prev_name  = active_state != undefined ? active_state.name	: undefined;

			active_state = undefined;
			for (var i = 0, len = array_length(__states); i < len; i++) {
				if (__states[@i].name == name) {
					if (!__states[@i].enabled)
						break;
						
					active_state = __states[@i];
					active_state.data = data;
					__listpool_processible = (active_state.on_step != undefined);
					if (__listpool_processible)
						STATEMACHINES.add(self);
					else 
						STATEMACHINES.remove(self);

					if (DEBUG_LOG_STATEMACHINE)
						with(owner) 
							vlog($"{MY_NAME}: Entering state '{other.active_state.name}'{(enter_override != undefined ? " (with enter-override)" : "")}");
					
					__state_frame = 0;
					rv = active_state.enter(prev_name, enter_override);
					__perform_state_change("enter", rv);
					break;
				}
			}
			
			// log the warning only if it's not an auto-event-state
			if (active_state == undefined) {
				active_state = prev_state;
				if (!string_starts_with(name, "ev:"))
					if (DEBUG_LOG_STATEMACHINE)
						with(owner)
							wlog($"{MY_NAME}: ** WARNING ** Could not activate state '{name}'. State not found or not enabled!");
			}
		}
		return self;
	}
	
	/// @func set_state_enabled(name_or_wildcard, enabled)
	/// @desc	Set a state to be enabled or not
	///			A disabled state can not be entered.
	///			Disabling the active state does NOT cause
	///			the state to be left! You stay in there.
	///			NOTE: You may use a wildcard string (like "bc:*") as
	///			the state name here! If you do, all states, that match
	///			this wildcard will be set to the desired enabled state.
	static set_state_enabled = function(name_or_wildcard, enabled) {
		if (string_contains(name_or_wildcard, "*")) {
			for (var i = 0, len = array_length(__states); i < len; i++) {
				var st = __states[@i];
				if (string_match(st.name, name_or_wildcard))
					st.enabled = enabled;
			}
		} else {
			var st = get_state(name_or_wildcard);
			if (st != undefined) st.enabled = enabled;
		}
		return self;
	}
	
	/// @func		delete_state(_name)
	/// @desc	Delete a state from the StateMachine.
	///					If the object is currently in this state, the delete request is silently ignored.
	/// @param {string} 	_name  The name of the state to delete.
	static delete_state = function(name) {
		if (active_state_name() == name) 
			return;
		var delidx = -1;
		for (var i = 0, len = array_length(__states); i < len; i++) {
			if (__states[@i].name == name) {
				delidx = i;
				break;
			}
		}
		if (delidx != -1)
			array_delete(__states, delidx, 1);
		return self;
	}
	
	/// @func			has_active_state()
	/// @desc		Check whether the StateMachine is currently in a valid state
	/// @returns {bool} 	true/false Is the object in a valid state?
	static has_active_state = function() {
		return active_state != undefined;
	}
	
	/// @func			active_state_name()
	/// @desc		Get the name of the active state
	/// @returns {string} 	The name of the active state or undefined, if there is none.
	static active_state_name = function() {
		return active_state != undefined ? active_state.name : undefined;
	}
	
	/// @func			get_state(name)
	/// @desc		Get the state instance with the given name
	/// @returns {State} 	The requested state or undefined, if there is none.
	static get_state = function(name) {
		if (name == undefined)
			return undefined;
		
		for (var i = 0, len = array_length(__states); i < len; i++) {
			if (__states[@i].name == name)
				return __states[@i];
		}
		return undefined;
	}
	
	/// @func get_active_state()
	/// @desc		Get the state instance of the currently active state
	/// @returns {State} 	The requested state or undefined, if there is none.
	static get_active_state = function() {
		return get_state(active_state_name());
	}
	
	/// @func rename_state(old_name, new_name)
	/// @func rename_state(old_name, new_name)
	/// @desc	Rename an existing state.
	///					Useful to rename event states if you redefine keys or similar reasons.
	///					NOTE: If the state to rename does not exist, the rename request is silently ignored.
	/// @param {string} old_name   The current name of the state
	/// @param {string} new_name   The new name to assign.
	static rename_state = function(old_name, new_name) {
		var st = get_state(old_name);
		if (st != undefined) st.name = new_name;
	}
	
	/// @func		state_exists(name)
	/// @desc	Check whether the specified state exists
	/// @param {string} name   The name of the state to check
	/// @returns {bool} true/false State exists?
	static state_exists = function(name) {
		return get_state(name) != undefined;
	}
	
	/// @func step()
	static step = function() {
		if (!__objectpool_paused && active_state != undefined) {
			active_state.data = data;
			var rv = active_state.on_step != undefined ? active_state.step(__state_frame) : undefined;
			__state_frame++;
			if (rv != undefined)
				__perform_state_change("step", rv);
		}
	}
	
	/// @func		set_allow_re_enter_state(allow)
	/// @desc	Set whether re-entering the same state is allowed (Default = false).
	///					If you set this to true, a set_state with the name of the current state
	///					will cause the on_leave of the current state followed by on_enter of
	///					the same to be invoked.
	/// @param {bool}	allow  Set to true, if re-entering the current state is allowed (Default = false)
	static set_allow_re_enter_state = function(allow) {
		__allow_re_enter = allow;
		return self;
	}
	
	/// @func		set_on_destroy(func)
	/// @desc	Set a callback function to be invoked when this StateMachine is destroyed.
	///					Use this if you need to destroy/free resources allocated in the data of the
	///					StateMachine (like ds_lists or ds_maps).
	/// @param {func} func Function to invoke when this StateMachine is destroyed.
	static set_on_destroy = function(func) {
		on_destroy = func;
		return self;
	}
	
	/// @func		destroy()
	/// @desc	Destroy this StateMachine. The on_destroy callback will be invoked, if one is set.
	static destroy = function() {
		if (on_destroy != undefined)
			on_destroy();
		if (DEBUG_LOG_STATEMACHINE)
			with(owner) vlog($"{MY_NAME}: StateMachine destroyed");
		STATEMACHINES.remove(self);
	}
	
	/// @func set_data(_property, _value)
	/// @desc Lets you set a property in the data struct to a value.
	///				 This method is a convenience function for the builder pattern,
	///				 so you can declare your initial data values directly while
	///				 building the animation
	static set_data = function(_property, _value) {
		data[$ _property] = _value;
		return self;
	}
	
	/// @func binder()
	/// @desc Gets the PropertyBinder for the values of this animation
	static binder = function() {
		return data.binder();
	}
	
	toString = function() {
		var me = name_of(owner) ?? "";
		return $"{me}: state='{active_state_name()}'; locked='{locking_animation}'; paused={__objectpool_paused};";
	}
	
}

/// @func					State(_name, _on_enter = undefined, _on_step, _on_leave = undefined)
/// @desc				Defines a state for the StateMachine.
/// @param {string} _name		The name of the state
/// @param {func} _on_enter		callback to be invoked when this state becomes the active state
/// @param {func} _on_step		The function to run
/// @param {func} _on_leave		callback to be invoked when this state is no longer the active state
function State(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined) constructor {
	name		= _name;
	data		= {};
	on_enter	= _on_enter;
	on_step		= _on_step;
	on_leave	= _on_leave;
	enabled		= true;
	
	static enter = function(prev_state, enter_override = undefined) {
		var rv = undefined;
		if (enter_override != undefined)
			rv = enter_override(data, prev_state, on_enter);
		else if (on_enter != undefined)
			rv = on_enter(data, prev_state, undefined);
		return rv;
	}
	
	static leave = function(new_state, leave_override = undefined) {
		if (leave_override != undefined)
			return leave_override(data, new_state, on_leave) ?? true;
		else if (on_leave != undefined)
			return on_leave(data, new_state, undefined) ?? true;
		else
			return true;
	}
	
	static step = function(frame) {
		return on_step != undefined ? on_step(data, frame) : undefined;
	}
	
	toString = function() {
		return sprintf("[{0}]", name);
	}

}

/// @func		statemachine_clear_pool()
/// @desc	Instantly removes ALL state machines
function statemachine_clear_pool() {
	STATEMACHINES.clear();
}

/// @func		__statemachine_pause_all(_owner, _paused)
/// @desc	raptor-internal! Do not call!
function __statemachine_pause_all(_owner, _paused) {
	var mymachines = __listpool_get_all_owner_objects(STATEMACHINES, _owner);
	for (var i = 0; i < array_length(mymachines); i++)
		mymachines[@ i].__objectpool_paused = _paused;
}
