/// @description onGameSaving & state ev:user_14

// Inherit the parent event
event_inherited();
// push our data to the savegame
__RAPTORDATA.statemachine = {};
__RAPTORDATA.statemachine.state_data			= states.data;
__RAPTORDATA.statemachine.state_name			= states.active_state_name();
__RAPTORDATA.statemachine.__allow_re_enter		= states.__allow_re_enter;
__RAPTORDATA.statemachine.__state_frame			= states.__state_frame;
__RAPTORDATA.statemachine.__objectpool_paused	= states.__objectpool_paused;
states.set_state("ev:user_14");
