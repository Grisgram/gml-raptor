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

#macro	STATE_MACHINES	global.__statemachine_pool
STATE_MACHINES		= new ListPool("STATE_MACHINES");

/// @function	 StateMachine(_owner, ...)
/// @description Create a new state machine with a list of states
/// @param {instance} _owner  The owner of the StateMachine. MUST be an object instance!
/// @param {State...} states  Any number (up to 15) of State(...) instances that define the states
function StateMachine(_owner) constructor {
	owner		 = _owner;
	__states	 = [];
	data		 = {};
	active_state = undefined;
	on_destroy	 = undefined;
	
	with(owner) log(MY_NAME + ": StateMachine created");
	
	for (var i = 1; i < argument_count; i++) {
		var st = argument[@ i];
		st.data = data;
		with(owner) log(MY_NAME + sprintf(": StateMachine added state '{0}' on creation", state.name));
		array_push(__states, st);
	}
	
	/// @function 		events_enabled()
	/// @description	Invoked by the StateMachine when it needs to know, whether it should react
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
			return !HIDDEN_BEHIND_POPUP;
	}
	
	/// @function		add_state(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined)
	/// @description	Defines a new state for the StateMachine. 
	///					NOTE: If a state with that name already exists, it is overwritten!
	/// @param {func} _on_enter  Optional. Callback to invoke when this state gets entered
	/// @param {func} step       Optional. Callback to invoke every frame while in this state
	/// @param {func} _on_leave  Optional. Callback to invoke when this state shall be left
	static add_state = function(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined) {
		with(owner) log(MY_NAME + sprintf(": StateMachine added state '{0}'", _name));
		if (get_state(_name) != undefined) {
			with(owner) log(MY_NAME + sprintf(": WARNING: Name collision: '{0}' overwrites an existing state!", _name));
			delete_state(_name);
		}
		var st = new State(_name, _on_enter, _on_step, _on_leave);
		st.data = data;
		array_push(__states, st);
		return self;
	}
	
	/// @function		add_state_shared(_state)
	/// @description	Adds a shared state to the StateMachine. 
	///					NOTE: If a state with that name already exists, it is overwritten!
	/// @param {State}  state The shared state to add
	static add_state_shared = function(_state) {
		var _name = _state.name;
		with(owner) log(MY_NAME + sprintf(": StateMachine added shared state '{0}'", _name));
		if (get_state(_name) != undefined) {
			with(owner) log(MY_NAME + sprintf(": WARNING: Name collision: Shared state '{0}' overwrites an existing state!", _name));
			delete_state(_name);
		}
		array_push(__states, _state);
		return self;
	}
	
	/// @function __perform_state_change(action, rv)
	static __perform_state_change = function(action, rv) {
		if (rv != undefined && is_string(rv)) {
			if (!has_active_state() || rv != active_state.name) {
				with(owner) log(MY_NAME + sprintf(": '{0}.{1}' resulted in state change '{2}'", other.active_state.name, action, rv));
				set_state(rv);
			}
		}
	}
	
	/// @function		set_state(name, enter_override = undefined, leave_override = undefined)
	/// @description	Transition to a new state. If the specified state does not exist,
	///					an error is logged and the object stays in the current state.
	/// @param {func} enter_override  Optional. Replace the original on_enter for this transition with something else
	/// @param {func} leave_override  Optional. Replace the original on_leave for this transition with something else	
	static set_state = function(name, enter_override = undefined, leave_override = undefined) {
		// automated state changes due to events may be blocked globally
		// through the events_enabled() function
		if (string_starts_with(name, "ev:") && !events_enabled())
			return;
			
		var rv = undefined;
		if (active_state == undefined || active_state.name != name) {
			if (active_state != undefined && state_exists(name)) {
				with(owner) log(MY_NAME + sprintf(": Leaving state '{0}'{1}", other.active_state.name, leave_override != undefined ? " (with leave-override)" : ""));
				active_state.data = data;
				if (!active_state.leave(name, leave_override)) {
					with(owner) log(MY_NAME + sprintf(": Leave state '{0}' aborted by leave callback!", other.active_state.name));
					return;
				}
			}
		
			var prev_state = active_state != undefined ? active_state		: undefined;
			var prev_name  = active_state != undefined ? active_state.name	: undefined;
			active_state = undefined;
			for (var i = 0; i < array_length(__states); i++) {
				if (__states[i].name == name) {
					active_state = __states[i];
					active_state.data = data;
					with(owner) 
						log(MY_NAME + sprintf(": Entering state '{0}'{1}", other.active_state.name, enter_override != undefined ? " (with enter-override)" : ""));
						
					rv = active_state.enter(prev_name, enter_override);
					__perform_state_change("enter", rv);
					break;
				}
			}
			
			// log the warning only if it's not an auto-event-state
			if (active_state == undefined) {
				active_state = prev_state;
				if (!string_starts_with(name, "ev:"))
					with(owner)
						log(MY_NAME + ": *WARNING* Could not activate state '" + name + "'. State not found!");
			}
		}
		return self;
	}
	
	/// @function		delete_state(_name)
	/// @description	Delete a state from the StateMachine.
	///					If the object is currently in this state, the delete request is silently ignored.
	/// @param {string} 	_name  The name of the state to delete.
	static delete_state = function(name) {
		if (active_state_name() == name) 
			return;
		var delidx = -1;
		for (var i = 0; i < array_length(__states); i++) {
			if (__states[i].name == name) {
				delidx = i;
				break;
			}
		}
		if (delidx != -1)
			array_delete(__states, delidx, 1);
		return self;
	}
	
	/// @function			has_active_state()
	/// @description		Check whether the StateMachine is currently in a valid state
	/// @returns {bool} 	true/false Is the object in a valid state?
	static has_active_state = function() {
		return active_state != undefined;
	}
	
	/// @function			active_state_name()
	/// @description		Get the name of the active state
	/// @returns {string} 	The name of the active state or undefined, if there is none.
	static active_state_name = function() {
		return active_state != undefined ? active_state.name : undefined;
	}
	
	/// @function			get_state(name)
	/// @description		Get the state instance with the given name
	/// @returns {State} 	The requested state or undefined, if there is none.
	static get_state = function(name) {
		for (var i = 0; i < array_length(__states); i++) {
			if (__states[i].name == name)
				return __states[i];
		}
		return undefined;
	}
	
	/// @function rename_state(old_name, new_name)
	/// @function rename_state(old_name, new_name)
	/// @description	Rename an existing state.
	///					Useful to rename event states if you redefine keys or similar reasons.
	///					NOTE: If the state to rename does not exist, the rename request is silently ignored.
	/// @param {string} old_name   The current name of the state
	/// @param {string} new_name   The new name to assign.
	static rename_state = function(old_name, new_name) {
		var st = get_state(old_name);
		if (st != undefined) st.name = new_name;
	}
	
	/// @function		state_exists(name)
	/// @description	Check whether the specified state exists
	/// @param {string} name   The name of the state to check
	/// @returns {bool} true/false State exists?
	static state_exists = function(name) {
		return get_state(name) != undefined;
	}
	
	/// @function step()
	static step = function() {
		if (active_state != undefined) {
			active_state.data = data;
			var rv = active_state.step();
			__perform_state_change("step", rv);
		}
	}
	
	/// @function		set_on_destroy(func)
	/// @description	Set a callback function to be invoked when this StateMachine is destroyed.
	///					Use this if you need to destroy/free resources allocated in the data of the
	///					StateMachine (like ds_lists or ds_maps).
	/// @param {func} func Function to invoke when this StateMachine is destroyed.
	static set_on_destroy = function(func) {
		on_destroy = func;
		return self;
	}
	
	/// @function		destroy()
	/// @description	Destroy this StateMachine. The on_destroy callback will be invoked, if one is set.
	static destroy = function() {
		if (on_destroy != undefined)
			on_destroy();
		with(owner) log(MY_NAME + ": StateMachine destroyed");
		STATE_MACHINES.remove(self);
	}
	
	static toString = function() {
		return active_state != undefined ? sprintf("[{0}]", active_state.name) : "[-NO-STATE-]";
	}
	
	STATE_MACHINES.add(self);
	
}

/// @function					State(_name, _on_enter = undefined, _on_step, _on_leave = undefined)
/// @description				Defines a state for the StateMachine.
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
	
	static step = function() {
		return on_step != undefined ? on_step(data) : undefined;
	}
	
	static toString = function() {
		return sprintf("[{0}]", name);
	}

}

/// @function		state_machine_clear_pool()
/// @description	Instantly removes ALL state machines
function state_machine_clear_pool() {
	STATE_MACHINES.clear();
}

