/// @description onGameLoaded & state ev:user_15

// Inherit the parent event
event_inherited();
// restore our data from the savegame
states.data					= __RAPTORDATA.statemachine.state_data;
states.__allow_re_enter		= __RAPTORDATA.statemachine.__allow_re_enter;
states.__state_frame		= __RAPTORDATA.statemachine.__state_frame;
states.__objectpool_paused	= __RAPTORDATA.statemachine.__objectpool_paused;
// Restore the active state
if (!string_is_empty(__RAPTORDATA.statemachine.state_name))
	states.active_state = states.get_state(__RAPTORDATA.statemachine.state_name);

states.set_state("ev:user_15");
