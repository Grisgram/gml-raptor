/// @description onGameSaving & state ev:user_14

// Inherit the parent event
event_inherited();
// push our data to the savegame
__RAPTORDATA.state_data = states.data;
states.set_state("ev:user_14");
