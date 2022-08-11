/// @description onGameLoaded & state ev:user_15

// Inherit the parent event
event_inherited();
// restore our data from the savegame
states.data = __RAPTORDATA.state_data;
states.set_state("ev:user_15");
