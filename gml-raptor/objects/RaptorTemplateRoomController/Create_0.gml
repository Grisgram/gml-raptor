/// @description onTransitFinished override
event_inherited();

onTransitFinished = function() {
}

// Invoked, when you start loading a game in a different room
// and when this room is the target room of the savegame.
// If something goes wrong during load and object restore,
// this function is invoked.
// The exception has already been written to the error log.
onGameLoadFailed = function(_exception) {
	elog($"**ERROR** Game load failed: {_exception.message}");
}

/// @func	onTransitBack(_transition_data)
/// @desc	Invoked, when the "transit_back" method is called
///			_transition_data has these members:
///			.cancel (set to true to stay in this room)
///			.target_room
///			.transition (set a transition to animate room change)
onTransitBack = function(_transition_data) {
}
