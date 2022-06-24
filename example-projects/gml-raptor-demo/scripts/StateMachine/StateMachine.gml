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

/// @function StateMachine(self)
/// @description Create a new state machine with a list of states
/// @param {owner, ...} any number of new State(...) instances that define the states
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
	
	/// @function 	events_enabled()
	/// @description The default implementation disables events if we are behind a popup
	///				 override/redefine if you need another condition
	///				 ATTENTION! If you redeclare this, do it always in a with(states) {...} bracket
	///				 in the create event of the object redefining it, otherwise you won't have access 
	///				 to the state machine's variables, like the owner.
	events_enabled = function() {
		with(owner)
			return !HIDDEN_BEHIND_POPUP;
	}
	
	/// @function					add_state(_name, _on_enter = undefined, _on_step, _on_leave = undefined)
	/// @description				Defines a state for the StateMachine.
	static add_state = function(_name, _on_enter = undefined, _on_step = undefined, _on_leave = undefined) {
		with(owner) log(MY_NAME + sprintf(": StateMachine added state '{0}'", _name));
		if (get_state(_name) != undefined)
			delete_state(_name);
		var st = new State(_name, _on_enter, _on_step, _on_leave);
		st.data = data;
		array_push(__states, st);
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
	
	/// @function set_state(name, enter_override = undefined, leave_override = undefined)
	static set_state = function(name, enter_override = undefined, leave_override = undefined) {
		// automated state changes due to events may be blocked globally
		// through the events_enabled() function
		if (string_starts_with(name, "ev:") && !events_enabled())
			return;
			
		var rv = undefined;
		if (active_state == undefined || active_state.name != name) {
			if (active_state != undefined && state_exists(name)) {
				with(owner) log(MY_NAME + sprintf(": Leaving state '{0}'{1}", other.active_state.name, leave_override != undefined ? " (with leave-override)" : ""));
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
	
	/// @function delete_state(_name)
	static delete_state = function(name) {
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
	
	/// @function set_on_destroy(func)
	static set_on_destroy = function(func) {
		on_destroy = func;
		return self;
	}
	
	/// @function has_active_state()
	static has_active_state = function() {
		return active_state != undefined;
	}
	
	static active_state_name = function() {
		return active_state != undefined ? active_state.name : undefined;
	}
	
	/// @function get_state(name)
	static get_state = function(name) {
		for (var i = 0; i < array_length(__states); i++) {
			if (__states[i].name == name)
				return __states[i];
		}
		return undefined;
	}
	
	static state_exists = function(name) {
		return get_state(name) != undefined;
	}
	
	/// @function step()
	static step = function() {
		if (active_state != undefined) {
			var rv = active_state.step();
			__perform_state_change("step", rv);
		}
	}
	
	/// @function destroy()
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
			rv = on_enter(data, prev_state);
		return rv;
	}
	
	static leave = function(new_state, leave_override = undefined) {
		if (leave_override != undefined)
			return leave_override(data, new_state, on_leave) ?? true;
		else if (on_leave != undefined)
			return on_leave(data, new_state) ?? true;
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

